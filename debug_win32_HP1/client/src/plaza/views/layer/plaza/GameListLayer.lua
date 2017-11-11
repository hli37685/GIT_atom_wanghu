local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local GameListLayer = class("GameListLayer", function(gamelist)
		local gamelist_layer =  display.newLayer()
    return gamelist_layer
end)

local Update = appdf.req(appdf.BASE_SRC.."app.controllers.ClientUpdate")
local QueryDialog = appdf.req(appdf.BASE_SRC.."app.views.layer.other.QueryDialog")
local LogonFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.LogonFrame")
local scheduler = cc.Director:getInstance():getScheduler()

-- 进入场景而且过渡动画结束时候触发。
function GameListLayer:onEnterTransitionFinish()
	self:tableCellAtIndex()
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function GameListLayer:onExitTransitionStart()
    return self
end

function GameListLayer:ctor(gamelist)
	print("============= 游戏列表界面创建 =============")
    --dump(gamelist,"gamelist",6)
	--print(#gamelist)
	self.m_bQuickStart = false

    self.updateLightScheduler = nil

	local this = self

	self:setContentSize(yl.WIDTH,yl.HEIGHT)

	self._gameList = gamelist
	--全局GameListLayer_gamelist
	Global_GameListLayer=self

    local logonCallBack = function (result,message)
		this:onLogonCallBack(result,message)
	end
	
	--按钮回调
	self._btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	self._logonFrame = LogonFrame:create(self,logonCallBack)
	

	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			this:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			this:onExitTransitionStart()
		elseif eventType == "exit" then
			if self._logonFrame:isSocketServer() then
				self._logonFrame:onCloseSocket()
			end
		end
	end)

    self.m_fThird = (yl.HEIGHT-240) / 2
    g_m_fThird = self.m_fThird

	--游戏列表
	--[[
	self._listView = cc.TableView:create(cc.size(self.m_fThird*3, self.m_fThird*2)) 
	self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
	self._listView:setPosition(cc.p(yl.WIDTH-self.m_fThird*3-120,100-10))
	self._listView:setDelegate()
	self._listView:addTo(self)
	self._listView:registerScriptHandler(self.tableCellTouched, cc.TABLECELL_TOUCHED)
	self._listView:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	self._listView:registerScriptHandler(self.tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	self._listView:registerScriptHandler(self.numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._listView:registerScriptHandler(self.cellHightLight, cc.TABLECELL_HIGH_LIGHT)
	self._listView:registerScriptHandler(self.cellUnHightLight, cc.TABLECELL_UNHIGH_LIGHT)
	--]]	
	self._cellList = {}

	cc.LabelTTF:create("在\n此\n上\n下\n滚\n动\n游\n戏", "Arial", 28)
			   :move(1250,yl.HEIGHT/2)
			   :addTo(self)

	self._scrollView = ccui.ScrollView:create()
        :setContentSize(cc.size(880,self.m_fThird*2))
        :setAnchorPoint(cc.p(0, 1))
		:setPosition(cc.p(400,yl.HEIGHT-150))
        --:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        :setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        :setBounceEnabled(false)
        :setScrollBarEnabled(true)
        :addTo(self)

	self._txtTips = ccui.Text:create("", "fonts/round_body.ttf", 32)
         	:setAnchorPoint(cc.p(1,0))
         	:move(yl.WIDTH,110)
         	:setTextColor(cc.c4b(0,250,0,255))
         	:addTo(self)

    --下载提示
    self.m_spDownloadMask = nil
    self.m_szMaskSize = cc.size(0,0)
    self.m_labDownloadTip = nil
    self.m_spDownloadCycle = nil
    self.m_bGameUpdate = false
end

--获取父场景节点(ClientScene)
function GameListLayer:getRootNode( )
	return self:getParent():getParent()
end

--更新游戏进入记录
function GameListLayer:updateEnterGameInfo(info)
	self:getRootNode():updateEnterGameInfo(info)
end

function GameListLayer:onEnterGame( gameinfo, isQuickStart)
	self:updateEnterGameInfo(gameinfo)
	self.m_bQuickStart = isQuickStart

	--判断房间获取
	local roomCount = GlobalUserItem.GetGameRoomCount(gameinfo._KindID)
	if not roomCount or 0 == roomCount then
		--self:onLoadGameList(gameinfo._KindID)
		print("GameListLayer 房间列表为空")		
	end
	GlobalUserItem.nCurGameKind = tonumber(gameinfo._KindID)
	GlobalUserItem.szCurGameName = gameinfo._KindName
	if MatchRoom and true == MatchRoom:getInstance():onLoginEnterRoomList() then
		print(" GameListLayer enter MatchGame ")
	elseif PriRoom and true == PriRoom:getInstance():onLoginEnterRoomList() then
		print(" GameListLayer enter priGame ")

	else      
		-- 处理锁表
		local lockRoom = GlobalUserItem.GetGameRoomInfo(GlobalUserItem.dwLockServerID)
		if GlobalUserItem.dwLockKindID == GlobalUserItem.nCurGameKind and nil ~= lockRoom then
			GlobalUserItem.nCurRoomIndex = lockRoom._nRoomIndex
			self:getParent():getParent():onStartGame()
		else
            local kindId = gameinfo._KindID
            print("gameinfo", tonumber(kindId), tonumber(kindId) == 140)
            local clientScene = self:getParent():getParent()
			--[[  注释 by Zml
            if tonumber(kindId) == 140 then
                local entergame = clientScene:getApp()._gameList[3]
			    clientScene:updateEnterGameInfo(entergame)
                clientScene:quickStartGame()
            elseif  tonumber(kindId) == 122 then
                local entergame = clientScene:getApp()._gameList[1]
			    clientScene:updateEnterGameInfo(entergame)
                clientScene:quickStartGame()
            else
			--]]
			--百人场快速开始
			if  tonumber(kindId) == 140 then
                local game = clientScene:getApp()._gameList
				for k,v in pairs(game) do
					local _KindID = v["_KindID"]
					if tonumber(_KindID)==140 then
						clientScene:updateEnterGameInfo(game[k])
						clientScene:quickStartGame()
					end
				end
			elseif  tonumber(kindId) == 122 then
                local game = clientScene:getApp()._gameList
				for k,v in pairs(game) do
					local _KindID = v["_KindID"]
					if tonumber(_KindID)==122 then
						clientScene:updateEnterGameInfo(game[k])
						clientScene:quickStartGame()
					end
				end
			elseif  tonumber(kindId) == 123 then
                local game = clientScene:getApp()._gameList
				for k,v in pairs(game) do
					local _KindID = v["_KindID"]
					if tonumber(_KindID)==123 then
						clientScene:updateEnterGameInfo(game[k])
						clientScene:quickStartGame()
					end
				end
			elseif  tonumber(kindId) == 104 then
                local game = clientScene:getApp()._gameList
				for k,v in pairs(game) do
					local _KindID = v["_KindID"]
					if tonumber(_KindID)==104 then
						clientScene:updateEnterGameInfo(game[k])
						clientScene:quickStartGame()
					end
				end
			else
                self:getParent():getParent():onChangeShowMode(yl.SCENE_ROOMLIST, self.m_bQuickStart)
			end
            --end
		end
	end	
end

---------------------------------------------------------------------

--子视图点击
function GameListLayer:onButtonClickedEvent(tag, cell)
	if GlobalUserItem.isAngentAccount() then
		return
	end
		
	local index = cell:getTag()
	print(tag,index)

	--获取游戏信息
	local gameinfo = self._gameList[index]
	if  not gameinfo then
		showToast(self:getParent():getParent(),"未找到游戏信息！",2)
		return
	end
	gameinfo.gameIndex = index

	--下载/更新资源 clientscene:getApp
    -- 临时屏蔽更新 by lqy
	local app = self:getParent():getParent():getApp()
	local version = tonumber(app:getVersionMgr():getResVersion(gameinfo._KindID))
	if not version or gameinfo._ServerResVersion > version then
		self:updateGame(gameinfo, index)
	else
		self:onEnterGame(gameinfo, false)
    end
end


	
--获取子视图
function GameListLayer:tableCellAtIndex()
	local game = nil
	local mask = nil
	local spTip = nil
	--计算scroll滑动高度
	local scrollHeight = 0
    local cellHeight = self.m_fThird
	if #self._gameList<6 then
        scrollHeight=cellHeight*2
		self._scrollView:setInnerContainerSize(cc.size(1084, scrollHeight))
	else
		scrollHeight = cellHeight * math.ceil(#self._gameList / 3) 
		self._scrollView:setInnerContainerSize(cc.size(1084, scrollHeight))
	end

	--(self._gameList,"_gameList",6)
	for i=1,#self._gameList do
		local item = self._gameList[i]
		--dump(item,"item",6)
		self._cellList[i]= cc.LayerColor:create(cc.c4b(100, 100, 100, 0), self.m_fThird, self.m_fThird)
			:move(150+cellHeight*((i-1)%3)-0,0+scrollHeight-cellHeight*(math.ceil(i / 3)))
			:addTo(self._scrollView)
			
		local gameinfo = self._gameList[i]
		local filestr = "GameList/default.png"
		--变相 continue 
		while true do
			if nul == gameinfo then break end
			gameinfo.gameIndex = idx
			filestr = "GameList/game_"..gameinfo._KindID..".png"
			if false == cc.FileUtils:getInstance():isFileExist(filestr) then
				filestr = "GameList/default.png"
			end
			break
		end
		--==========================================
		game = ccui.Button:create(filestr,filestr)
		game:addTo(self._cellList[i])
			:setAnchorPoint(cc.p(0.5, 0))
			:setPosition(0, 0)
			:setTag(i)
            :addTouchEventListener(self._btcallback)
		
		local maskSp = cc.Sprite:create(filestr)
		local pos = cc.p(0,0)
		if nil ~= maskSp then			
			maskSp:setColor(cc.BLACK)
			maskSp:setOpacity(100)
			local size = maskSp:getContentSize()
			maskSp:setPosition(cc.p(size.width * 0.5,size.height * 0.5))
			maskSp:setName("download_mask_sp")			

			mask = ccui.Layout:create()
			mask:setAnchorPoint(cc.p(0.5,0))
			mask:setPosition(0, 0)
			mask:setContentSize(size)
			mask:addChild(maskSp)
			self._cellList[i]:addChild(mask)
			mask:setName("download_mask")

			spTip = cc.Label:createWithTTF("", "fonts/round_body.ttf", 32)
				:enableOutline(cc.c4b(0,0,0,255), 1)
				:move(cc.p(0,size.height * 0.5))
				:setName("download_mask_tip")
				:addTo(self._cellList[i])

			local cycle = cc.Sprite:create("GameList/spinner_circle.png")
			if nil ~= cycle then
				cycle:setPosition(0,size.height * 0.5)
				cycle:setVisible(false)
				cycle:setScale(1.3)
				cycle:setName("download_cycle")
				self._cellList[i]:addChild(cycle)
			end
		end	
		--设置 显示等

		--变相 continue 
		while true do
			if nul == gameinfo then 
				game:setVisible(false)
				if nil ~= spTip then	spTip:setVisible(false)	end
				if nil ~= mask then		mask:setVisible(false)	end
			break 
			end		
			
			game:setVisible(true)	
			if nil ~= spTip then	spTip:setVisible(true)	end
			if nil ~= mask then		mask:setVisible(not gameinfo._Active)	end
			self._cellList[i]:setVisible(true)
			self._cellList[i]:setTag(i)				
			break
		end
		if nil ~= spTip then
			spTip:setString("")
		end
	end
end
---------------------------------------------------------------------

--链接游戏
function GameListLayer:onLoadGameList(nKindID)
	if not nKindID then
		self:dismissPopWait()
		local ru = cc.Director:getInstance():getRunningScene()
		if nil ~= ru then
			showToast(ru,"游戏ID有误！",1)
		end	
		return
	end
	GlobalUserItem.nCurGameKind = tonumber(nKindID)
	--如果是有游客
	if GlobalUserItem.bVisitor then		
		if self._logonFrame:onLogonByVisitor() then
			self:showPopWait()
		end
	--如果是第三方
	elseif GlobalUserItem.bThirdPartyLogin then
		local td = GlobalUserItem.thirdPartyData
		--szAccount, szNick, cbgender, platform
		if self._logonFrame:onLoginByThirdParty(td.szAccount,td.szNick, td.cbGender, td.platform) then
			self:showPopWait()
		end
	else
		if self._logonFrame:onLogonByAccount(GlobalUserItem.szAccount,GlobalUserItem.szPassword) then
			self:showPopWait()
		end
	end
end

--链接游戏回掉
function GameListLayer:onLogonCallBack(result,message)
	self:dismissPopWait()
	if  message ~= nil  and type(message) == "string" then
		local ru = cc.Director:getInstance():getRunningScene()
		if nil ~= ru then
			showToast(ru,message,2)
		end		
	end
	if result == 0 then
		self:onUpdataNotify()
	elseif result == 1 then		
		local clientscene = self:getParent():getParent()
		--判断是否是快速开始
		if nil ~= clientscene.m_bQuickStart and true == clientscene.m_bQuickStart then
			local roominfo = GlobalUserItem.GetRoomInfo(GlobalUserItem.nCurRoomIndex)
			if nil == roominfo then
				return
			end
			if bit:_and(roominfo.wServerKind, yl.GAME_GENRE_PERSONAL) ~= 0 then
				--showToast(self, "房卡房间不支持快速开始！", 2)
				return
			end
			clientscene:onStartGame()
		else
			if PriRoom and true == PriRoom:getInstance():onLoginEnterRoomList() then
				print("GameListLayer:onLogonCallBack:GameListLayer enter priGame ")
			else
				-- 处理锁表
				local lockRoom = GlobalUserItem.GetGameRoomInfo(GlobalUserItem.dwLockServerID)
				if GlobalUserItem.dwLockKindID == GlobalUserItem.nCurGameKind and nil ~= lockRoom then
					GlobalUserItem.nCurRoomIndex = lockRoom._nRoomIndex
					clientscene:onStartGame()
				else
					clientscene:onChangeShowMode(yl.SCENE_ROOMLIST, self.m_bQuickStart)
				end
			end
		end		
	end
end

--显示等待
function GameListLayer:showPopWait(isTransparent)
	self:getParent():getParent():showPopWait(isTransparent)
end

function GameListLayer:showGameUpdateWait()
	self.m_bGameUpdate = true
	ExternalFun.popupTouchFilter(1, false, "游戏更新中,请稍候！")
end

function GameListLayer:dismissGameUpdateWait()
	self.m_bGameUpdate = false
	ExternalFun.dismissTouchFilter()
end

--关闭等待
function GameListLayer:dismissPopWait()
	self:getParent():getParent():dismissPopWait()
end

function GameListLayer:updateGame(gameinfo, index)
	print("updateGame==gameinfo, index ",gameinfo)
	local cell = nil
	if nil ~= index then
		cell = self._cellList[index]
	end
	-- 测试更新动画 临时注释 by Zml
	self:onGameUpdate(gameinfo)
	if nil ~= cell then		
		self.m_spDownloadMask = cell:getChildByName("download_mask")
		print(self.m_spDownloadMask)
		if nil ~= self.m_spDownloadMask then
			self.m_szMaskSize = self.m_spDownloadMask:getContentSize()			
		end
		self.m_labDownloadTip = cell:getChildByName("download_mask_tip")
		if nil ~= self.m_labDownloadTip then
			self.m_labDownloadTip:setString("0%")
		end
		self.m_spDownloadCycle = cell:getChildByName("download_cycle")
		if nil ~= self.m_spDownloadCycle then
			self.m_spDownloadCycle:stopAllActions()
			self.m_spDownloadCycle:setVisible(true)
			self.m_spDownloadCycle:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.0, 360)))
		end
	end
end

--更新游戏
function GameListLayer:onGameUpdate(gameinfo)
	--失败重试
	if not gameinfo and self._update ~= nil then
		self:showGameUpdateWait()
		self._update:UpdateFile()
		return 
	end

	if not gameinfo and not self._downgameinfo then 
		showToast(self,"无效游戏信息！",1)
		return
	end

	self:showGameUpdateWait()
	
	--记录
	if gameinfo ~= nil then
		self._downgameinfo = gameinfo
	end
	
	--更新参数
	local newfileurl = self:getParent():getParent():getApp()._updateUrl.."/game/"..self._downgameinfo._Module.."/res/filemd5List.json"
	local dst = device.writablePath .. "game/" .. self._downgameinfo._Type .. "/"
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_WINDOWS == targetPlatform then
		--dst = device.writablePath .. "download/game/" .. self._downgameinfo._Type .. "/"
	end
	
	local src = device.writablePath.."game/"..self._downgameinfo._Module.."/res/filemd5List.json"
	local downurl = self:getParent():getParent():getApp()._updateUrl .. "/game/" .. self._downgameinfo._Type .. "/"

	--创建更新
	self._update = Update:create(newfileurl,dst,src,downurl)
	self._update:upDateClient(self)
end

function GameListLayer:onUpdataNotify()
	showToast(self,"游戏版本信息错误！",1)
end

--更新进度
function GameListLayer:updateProgress(sub, msg, mainpersent)
	local permsg = string.format("%d%%", mainpersent)
	if nil ~= self.m_spDownloadMask then
		local scale = (95 - mainpersent) / 100		
		self.m_spDownloadMask:setContentSize(self.m_szMaskSize.width, self.m_szMaskSize.height * scale)
	end
	if nil ~= self.m_labDownloadTip then
		self.m_labDownloadTip:setString(permsg)
	end
end

--更新结果
function GameListLayer:updateResult(result,msg)
	if nil ~= self.m_spDownloadCycle then
		self.m_spDownloadCycle:stopAllActions()
		self.m_spDownloadCycle:setVisible(false)
	end
	self:dismissGameUpdateWait()
	
	if result == true then
		local app = self:getParent():getParent():getApp()

		--更新版本号
		for k,v in pairs(app._gameList) do
			if v._KindID == self._downgameinfo._KindID then
				app:getVersionMgr():setResVersion(v._ServerResVersion, v._KindID)
				v._Active = true
				break
			end
		end

		self._txtTips:setString("OK")
		self:onEnterGame(self._downgameinfo)
	else
		local runScene = cc.Director:getInstance():getRunningScene()
		if nil ~= runScene then			
			if nil ~= self.m_spDownloadMask then	
				self.m_spDownloadMask:setContentSize(self.m_szMaskSize.width, self.m_szMaskSize.height)
			end

			if nil ~= self.m_labDownloadTip then
				self.m_labDownloadTip:setString("")
			end

			self._txtTips:setString("")
			QueryDialog:create(msg.."\n是否重试？",function(bReTry)
					if bReTry == true then
						self:onGameUpdate(self._downgameinfo)
					end
				end)
				:addTo(runScene)
		end		
	end
end

function GameListLayer:onKeyBack()
	return self.m_bGameUpdate ~= false
end

return GameListLayer
