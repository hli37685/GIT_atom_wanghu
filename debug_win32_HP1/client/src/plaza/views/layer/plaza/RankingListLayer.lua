local RankingListLayer = class("RankingListLayer", function(scene)
		local RankingListLayer = display.newLayer(cc.c4b(0, 0, 0, 255))
    return RankingListLayer
end)
local PopupInfoHead = appdf.req(appdf.EXTERNAL_SRC .. "PopupInfoHead")

local PopWait = appdf.req(appdf.BASE_SRC.."app.views.layer.other.PopWait")

--继续游戏
RankingListLayer.BT_CONTINUE = 101

-- 进入场景而且过渡动画结束时候触发。
function RankingListLayer:onEnterTransitionFinish()
---[[
	dump(self._myRank,"_myRank  onEnterTransitionFinish",6)
	if 0 == #self._rankList then
		self.m_bRequestData = true
		self:showPopWait()
		--appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/PhoneRank.ashx","GET","action=getscorerank&pageindex=1&pagesize=50&userid="..GlobalUserItem.dwUserID,function(jstable,jsdata)
          appdf.onHttpJsionTable("http://www.16yi.com/WS/PhoneRank.ashx","GET","action=getscorerank&pageindex=1&pagesize=20&userid="..GlobalUserItem.dwUserID,function(jstable,jsdata)
            self.m_bRequestData = false
			self:dismissPopWait()
			--dump(jstable, "jstable", 5)
	dump(self._myRank,"_myRank  回调function",6)
			if type(jstable) == "table" then
				for i = 1, #jstable do
					if i == 1 then
						if nil~=self._myRank then
							self._myRank.szNickName = jstable[i]["NickName"]
							self._myRank.lScore = jstable[i]["Score"]
							self._myRank.rank = jstable[i]["Rank"]..""
							self._myRank.lv = jstable[i]["Experience"]
						end
					else
						local item = {}
						item.szNickName = jstable[i]["NickName"]
						item.lScore = jstable[i]["Score"]..""
						item.wFaceID = tonumber(jstable[i]["FaceID"])
						item.lv = jstable[i]["Experience"]
						item.cbMemberOrder = tonumber(jstable[i]["MemberOrder"])
						item.dBeans = tonumber(jstable[i]["Currency"])
						item.lIngot = tonumber(jstable[i]["UserMedal"])
						item.dwGameID = tonumber(jstable[i]["GameID"])
						item.dwUserID = tonumber(jstable[i]["UserID"])
						item.szSign = jstable[i]["szSign"] or "此人很懒，没有签名"
						item.szIpAddress = jstable[i]["ip"]
						table.insert(self._rankList,item)
					end
				end
				GlobalUserItem.tabRankCache["rankMyInfo"] = self._myRank
				GlobalUserItem.tabRankCache["rankList"] = self._rankList
	--dump(self._rankList,"xxxxxx _rankList",6)
	--dump(GlobalUserItem.tabRankCache["rankList"],"123 tabRankCache",6)
				self:onUpdateShow()
			else
				showToast(self,"抱歉，获取排行榜信息失败！",2,cc.c3b(250,0,0))
			end
		end)
	else
		self:onUpdateShow()
	end
	--dump(self,"onEnterTransitionFinish self",6)
	--dump(self._rankList,"onEnterTransitionFinish _rankList",6)
    return self
	--]]
end

-- 退出场景而且开始过渡动画时候触发。
---[[
function RankingListLayer:onExitTransitionStart()
    return self
end
--]]

function RankingListLayer:ctor(scene, preTag)
	local this = self
	self.m_bRequestData = false

	self._scene = scene
	--上一个页面
	--self.m_preTag = preTag

	self._myRank = GlobalUserItem.tabRankCache["rankMyInfo"] or {name = GlobalUserItem.szNickName,lScore = "0",rank = "0"}
	self._rankList = GlobalUserItem.tabRankCache["rankList"] or {}
	
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		end
	end)

	--dump(GlobalUserItem.tabRankCache["rankList"],"ctor tabRankCache",6)
	--游戏列表
    local tableVuew = self._scene._frame_rank:getChildByTag(1)
    if tableVuew then
        tableVuew:removeFromParent() 
    end
	
	self._listView = cc.TableView:create(cc.size(self._scene._fme_rk_size.width-8, self._scene._fme_rk_size.height-68))
	self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
	self._listView:setPosition(cc.p(4,4))
	self._listView:setTag(1)
	self._listView:setDelegate()
	--self._listView:addTo(self._scene)
	self._listView:addTo(self._scene._frame_rank)
	self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	
	self._listView:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	self._listView:registerScriptHandler(self.tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	self._listView:registerScriptHandler(self.tableCellTouched, cc.TABLECELL_TOUCHED)
	self._listView:registerScriptHandler(self.numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function RankingListLayer:onUpdateShow()

	local rank = tonumber(self._myRank.rank)
	if rank > 0 and rank < 21 then
--print("onUpdateShow  1",rank)
		--self._myRankFlag:setTexture("Rank/tubiao9.png")
	else
--print("onUpdateShow  2",rank)
	 	--self._myRankFlag:setTexture("Rank/tubiao8.png")
	end 
	--self._myScore:setString(string.formatNumberThousands(self._myRank.lScore,true,"/"))
	self._listView:reloadData()
end

function RankingListLayer:onKeyBack()
	return self.m_bRequestData
end

---------------------------------------------------------------------

--子视图大小
function RankingListLayer.cellSizeForTable(view, idx)
  	return 369-8 , 70
end

--子视图数目
function RankingListLayer.numberOfCellsInTableView(view)
	if not GlobalUserItem.tabRankCache["rankList"] then
		return 0
	else
		return #GlobalUserItem.tabRankCache["rankList"]
  	end
end
	
--获取子视图
function RankingListLayer.tableCellAtIndex(view, idx)	

--print("idx",idx)

	local cell = view:dequeueCell()
	
	--local item = view:getParent()._rankList[idx+1]
	local item = GlobalUserItem.tabRankCache["rankList"][idx+1]
--dump(item,"item",6)
	local width = 369
	local height= 79

    local testen = cc.Label:createWithSystemFont("A","Arial", 28)
    local _enSize = testen:getContentSize().width
    local testcn = cc.Label:createWithSystemFont("游","Arial", 28)
    local _cnSize = testcn:getContentSize().width

	if not cell then
		local cy = 35
		cell = cc.TableViewCell:new()
        local spriteContentBg = cc.Scale9Sprite:create("RankInit/itembg.png")
        spriteContentBg:setCapInsets(CCRectMake(40,10,351,62))
        spriteContentBg:setContentSize(cc.size(width-10, height-10))
        spriteContentBg:setPosition(361/2, cy)
        spriteContentBg:setTag(1)
        cell:addChild(spriteContentBg, -100)


		display.newSprite("RankInit/tubiao1.png")
			:move(40,cy)
			:setTag(2)
			:addTo(cell)

		--名次数字
		cc.LabelAtlas:_create("10", "RankInit/shuzi2.png", 25, 34 , string.byte("0")) 
			:move(40,cy)
			:setTag(3)
			:setAnchorPoint(cc.p(0.5,0.5))
			:addTo(cell)

		--昵称
		--[[
		cc.Label:createWithTTF("游戏玩家","fonts/round_body.ttf",24)
			:move(305,cy)
			:setTag(5)
			:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			:setAnchorPoint(cc.p(0,0.5))
            :setColor(cc.c3b(255, 104, 0))
			:addTo(cell)
			--]]

		--圆角矩形
        local RoundRect = cc.Scale9Sprite:create("RankInit/roundedRectangle.png")
        	:setCapInsets(CCRectMake(40,10,180,42))
        	:setContentSize(cc.size(200, 42))
			:move(260,cy)
			:setTag(4)
			:addTo(cell)

		local RRect_size=RoundRect:getContentSize()

		display.newSprite("Lobby/qian.png")
			:move(22,22)
			:addTo(RoundRect)

		--金币
		--cc.LabelAtlas:_create("0", "RankInit/shuzi3.png", 19, 24, string.byte("/")) 
     	cc.Label:createWithSystemFont("0","Arial", 28)
			:move(52,21)
			:setTag(2)
			:setAnchorPoint(cc.p(0,0.5))
            :setColor(cc.c3b(250, 254, 149))
			:addTo(RoundRect)

     	cc.Label:createWithSystemFont("万","Arial", 28)
		--cc.Label:createWithTTF("万","fonts/round_body.ttf",24)
			:move(RRect_size.width-52,21)
			:setAnchorPoint(cc.p(0.5,0.5))
            :setColor(cc.c3b(250, 254, 149))
			:setTag(3)
			:addTo(RoundRect)

	end

	if cell:getChildByName("cell_face") then
		cell:getChildByName("cell_face"):updateHead(item)
	else
		--头像
--		local head = PopupInfoHead:createClipHead(item, 50)
        local head = PopupInfoHead:createNormal(item, 60)
		head:setPosition(110,35)
		head:setIsGamePop(false)
--		head:enableHeadFrame(true)
        head:enableHeadFrame(false)
		head:enableInfoPop(true, cc.p(397+18, 152), cc.p(0, 0.5))
		cell:addChild(head)
		head:setName("cell_face")
	end

	local rankidx = (idx+1)..""
--	if  rankidx ~= view:getParent()._myRank.rank then
--		cell:getChildByTag(1):setTexture("Rank/dikuang5.png")
--	else
--		cell:getChildByTag(1):setTexture("Rank/dikuang4.png")
--	end
    local nodeTag1 = cell:getChildByTag(1)
    if nodeTag1 then
        nodeTag1:removeFromParent()    
    end
    local picTag1 = "RankInit/itembg.png"
    local imgTag1Bg = cc.Scale9Sprite:create(picTag1)
    imgTag1Bg:setCapInsets(CCRectMake(40,10,351,62))
    imgTag1Bg:setContentSize(cc.size(width-10, height-10))
    imgTag1Bg:setPosition(361/2, 35)
    imgTag1Bg:setTag(1)
    cell:addChild(imgTag1Bg, -100)

	if idx == 0 then
		cell:getChildByTag(2):setTexture("RankInit/tubiao1.png")
		cell:getChildByTag(2):setVisible(true)
		cell:getChildByTag(3):setVisible(false)
		cell:getChildByTag(2):setScale(0.8)
	elseif idx == 1 then
		cell:getChildByTag(2):setTexture("RankInit/tubiao2.png")
		cell:getChildByTag(2):setVisible(true)
		cell:getChildByTag(3):setVisible(false)
		cell:getChildByTag(2):setScale(0.8)
	elseif idx == 2 then 
		cell:getChildByTag(2):setTexture("RankInit/tubiao3.png")
		cell:getChildByTag(2):setVisible(true)
		cell:getChildByTag(3):setVisible(false)
		cell:getChildByTag(2):setScale(0.8)
	else
		cell:getChildByTag(2):setVisible(false)
		cell:getChildByTag(3):setString((idx+1).."")
		cell:getChildByTag(3):setVisible(true)
	end
	--cell:getChildByTag(7):setString(item.lv)
	--cell:getChildByTag(5):setString(item.szNickName)
	--print("==== tag 6 ",string.formatNumberThousands(item.lScore,true,"/"))
	--cell:getChildByTag(4):getChildByTag(2):setString(math.floor(item.lScore/10000))
	if tonumber(item.lScore)>=100000000 then
		local temp=math.floor(item.lScore/1000000)
		local money = string.stringEllipsis(temp/100,_enSize,_cnSize,115)
		cell:getChildByTag(4):getChildByTag(2):setString(string.format("%0.2f", money))
		cell:getChildByTag(4):getChildByTag(3):setString("亿")
	else
		local money = string.stringEllipsis(math.floor(item.lScore/10000),_enSize,_cnSize,115)
		cell:getChildByTag(4):getChildByTag(2):setString(money)
		cell:getChildByTag(4):getChildByTag(3):setString("万")
	end

	return cell
end

function RankingListLayer.tableCellTouched(view, cell)
	if nil ~= cell then
		local face = cell:getChildByName("cell_face")
		if nil ~= face then
			face:onTouchHead()
		end
	end
end

--显示等待
function RankingListLayer:showPopWait(isTransparent)
local width=self._scene._fme_rk_size.width
local height=self._scene._fme_rk_size.height
	if not self._popWait then
		--self._popWait = PopWait:create(isTransparent,width-8,height-68,369/2,appdf.HEIGHT/2,68)
		self._popWait = PopWait:create(isTransparent,nil,nil,369/2,appdf.HEIGHT/2,nil)
			:show(self,"请稍候！")
		self._popWait:setLocalZOrder(yl.MAX_INT)
	end
end

--关闭等待
function RankingListLayer:dismissPopWait()
	if self._popWait then
		self._popWait:dismiss()
		self._popWait = nil
	end
end

---------------------------------------------------------------------
return RankingListLayer
