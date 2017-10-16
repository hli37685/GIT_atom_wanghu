local RoomListLayer = class("RoomListLayer", function(scene)
	local roomlist_layer = display.newLayer()
    return roomlist_layer
end)

-- 进入场景而且过渡动画结束时候触发。
function RoomListLayer:onEnterTransitionFinish()
	self:tableCellAtIndex()
    return self
end
-- 退出场景而且开始过渡动画时候触发。
function RoomListLayer:onExitTransitionStart()
    return self
end
function RoomListLayer:onSceneAniFinish()
end


function RoomListLayer:ctor(scene, isQuickStart)
	self._scene = scene
	local this = self
	roomselflistLayer=self
	self.m_bIsQuickStart = isQuickStart or false

	local enterGame = self._scene:getEnterGameInfo()
	--缓存资源
	local modulestr = string.gsub(enterGame._KindName, "%.", "/")
	local path = "game/" .. modulestr .. "res/roomlist/roomlist.plist"	
	if false == cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded(path) then
		if cc.FileUtils:getInstance():isFileExist(path) then
			cc.SpriteFrameCache:getInstance():addSpriteFrames(path)
		end
	end	
	self.m_fThree =400

	--区域设置
	self:setContentSize(yl.WIDTH,yl.HEIGHT)

	--左侧游戏
    self._gameFrame = ccui.ImageView:create("client/res/RoomList/icon_roomlist_frame.png")
		:setAnchorPoint(cc.p(1,0.5))
		:setPosition(cc.p(400, yl.HEIGHT/2-10))
        :addTo(self)
	local filestr = "client/res/GameList/game_"..enterGame._KindID..".png"
	if false == cc.FileUtils:getInstance():isFileExist(filestr) then
		filestr = "client/res/GameList/default.png"
	end
    ccui.ImageView:create(filestr)
		:setAnchorPoint(cc.p(1,0.5))
		:setPosition(cc.p(self._gameFrame:getContentSize().width/2+110,self._gameFrame:getContentSize().height/2))
        :addTo(self._gameFrame)
	
	--按钮回调
	self._btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	--房间列表
	--[[
	self._listView = cc.TableView:create(cc.size(yl.WIDTH-500, 440))
	self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)   
	self._listView:setPosition(cc.p(500, 130))
	self._listView:setDelegate()
	self._listView:addTo(self)
	self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
	self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._listView:registerScriptHandler(self.cellHightLight, cc.TABLECELL_HIGH_LIGHT)
	self._listView:registerScriptHandler(self.cellUnHightLight, cc.TABLECELL_UNHIGH_LIGHT)
	--]]
	self._cellList={}

	self._scrollView = ccui.ScrollView:create()
        :setContentSize(cc.size(yl.WIDTH-500, 600))
        :setAnchorPoint(cc.p(0, 1))
		:setPosition(cc.p(500,600))
        :setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        :setBounceEnabled(false)
        :setScrollBarEnabled(false)
        :addTo(self)

	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			this:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			this:onExitTransitionStart()
		end
	end)

	if true == self.m_bIsQuickStart then
		self:stopAllActions()
		GlobalUserItem.nCurRoomIndex = 1
		self:onStartGame()
	end

	self.m_tabRoomListInfo = {}
	for k,v in pairs(GlobalUserItem.roomlist) do
		if tonumber(v[1]) == GlobalUserItem.nCurGameKind then
			local listinfo = v[2]
			if type(listinfo) ~= "table" then
				break
			end
			local normalList = {}
			for k,v in pairs(listinfo) do
				if v.wServerType ~= yl.GAME_GENRE_PERSONAL then
					table.insert( normalList, v)
				end
			end
			self.m_tabRoomListInfo = normalList
			break
		end
	end
	RoomG_m_tabRoomListInfo=self.m_tabRoomListInfo
end

function RoomListLayer:onButtonClickedEvent(tag, cell)
	local index = cell:getTag()
	local roominfo = self.m_tabRoomListInfo[index]
	if not roominfo then
		return
	end
	GlobalUserItem.nCurRoomIndex = roominfo._nRoomIndex
	GlobalUserItem.bPrivateRoom = (roominfo.wServerType == yl.GAME_GENRE_PERSONAL)
	if self._scene:roomEnterCheck() then
		self:onStartGame()
	end
end

--获取子视图
function RoomListLayer:tableCellAtIndex()
	self._scrollView:setInnerContainerSize(cc.size(yl.WIDTH-500, 600))

	for i=1,4 do
		local iteminfo = self.m_tabRoomListInfo[i]
dump(iteminfo,"iteminfo",6)
		local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)

		if 8 == wLv then
			--比赛场单独处理
		else
			local rule = (iteminfo == nil and 0 or iteminfo.dwServerRule)
			wLv = (bit:_and(yl.SR_ALLOW_AVERT_CHEAT_MODE, rule) ~= 0) and 10 or iteminfo.wServerLevel
			wLv = (wLv ~= 0) and wLv or 1
			local wRoom = math.mod(wLv, 5)--bit:_and(wLv, 3)
			local szName = (iteminfo == nil and "房间名称" or iteminfo.szServerName)
			local szCount = (iteminfo == nil and "0" or(iteminfo.dwOnLineCount..""))
			local szServerScore = (iteminfo == nil and "0" or iteminfo.lCellScore)
			local szServerEScore = (iteminfo == nil and "0" or iteminfo.lEnterScore)
			local enterGame = self._scene:getEnterGameInfo()
					
			--检查房间背景资源
			local modulestr = string.gsub(enterGame._KindName, "%.", "/")
		
			self._cellList[i]= cc.LayerColor:create(cc.c4b(100, 100, 100, 0), self.m_fThree, 220)
				:move(150+self.m_fThree*((i-1)%2)-0,580-220*(math.ceil(i / 2)))
				:addTo(self._scrollView)

			local filestr = "client/res/RoomList/icon_roomlist_" .. i .. ".png"
			if false == cc.FileUtils:getInstance():isFileExist(filestr) then
				filestr = "client/res/RoomList/icon_roomlist_1.png"
			end
			ccui.Button:create(filestr,filestr)	
				:addTo(self._cellList[i])	
				:setAnchorPoint(cc.p(0.5, 0))
				:setPosition(0, 0)
				:setTag(i)
				:addTouchEventListener(self._btcallback)
			
			
			if modulestr == "yule/oxsixex/" then --通比牛牛
				--底注
				cc.Label:createWithTTF("底注","fonts/round_body.ttf",26)
					:setPosition(cc.p(-20, 62))
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
					:setTextColor(cc.c4b(255,255,255,255))
					:setAnchorPoint(cc.p(1.0,0.5))
					:addTo(self._cellList[i])
				cc.Label:createWithTTF(szServerScore,"fonts/round_body.ttf",26)
					:setPosition(cc.p(-20, 62))
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
					:setTextColor(cc.c4b(255,255,255,255))
					:setAnchorPoint(cc.p(0,0.5))
					:addTo(self._cellList[i])
			elseif modulestr == "yule/oxnew/" or modulestr == "yule/oxex/" or modulestr == "yule/watermargin/"then
				--入场
				cc.Label:createWithTTF("入场","fonts/round_body.ttf",26)
					:setPosition(cc.p(-20, 62))
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
					:setTextColor(cc.c4b(255,255,255,255))
					:setAnchorPoint(cc.p(1,0.5))
					:addTo(self._cellList[i])
				cc.Label:createWithTTF(szServerEScore,"fonts/round_body.ttf",26)
					:setPosition(cc.p(-20, 62))
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
					:setTextColor(cc.c4b(255,255,255,255))
					:setAnchorPoint(cc.p(0,0.5))
					:addTo(self._cellList[i])
			elseif modulestr == "yule/fishyqs/" or modulestr == "yule/fishlk/" then
				cc.Label:createWithTTF(szName,"fonts/round_body.ttf",26)
					:setPosition(cc.p(0, 62))
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
					:setTextColor(cc.c4b(255,255,255,255))
					:setAnchorPoint(cc.p(0.5,0.5))
					:addTo(self._cellList[i])
			else
				--其他 入场
				cc.Label:createWithTTF("入场","fonts/round_body.ttf",26)
					:setPosition(cc.p(-20, 62))
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
					:setTextColor(cc.c4b(255,255,255,255))
					:setAnchorPoint(cc.p(1,0.5))
					:addTo(self._cellList[i])
				cc.Label:createWithTTF(szServerEScore,"fonts/round_body.ttf",26)
					:setPosition(cc.p(-20, 62))
					:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
					:setTextColor(cc.c4b(255,255,255,255))
					:setAnchorPoint(cc.p(0,0.5))
					:addTo(self._cellList[i])
			end
		end
	end
end

--显示等待
function RoomListLayer:showPopWait()
	if self._scene then
		self._scene:showPopWait()
	end
end

--关闭等待
function RoomListLayer:dismissPopWait()
	if self._scene then
		self._scene:dismissPopWait()
	end
end


function RoomListLayer:onStartGame(index)
	local iteminfo = GlobalUserItem.GetRoomInfo(index)
	if iteminfo ~= nil then
		self._scene:onStartGame(index)
	end
end

return RoomListLayer
