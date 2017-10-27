local RoomListLayer = class("RoomListLayer", function(scene)
	local roomlist_layer = display.newLayer()
    return roomlist_layer
end)

-- 进入场景而且过渡动画结束时候触发。
function RoomListLayer:onEnterTransitionFinish()
	self._listView:reloadData()
    return self
end
-- 退出场景而且开始过渡动画时候触发。
function RoomListLayer:onExitTransitionStart()
    return self
end
function RoomListLayer:onSceneAniFinish()
end


function RoomListLayer:ctor(scene, isQuickStart)
	--区域外屏蔽点击
	local  onShield = function(eventType, x, y)
    	return true
    end
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(onShield)
	--====================================
	
	self._scene = scene
	local this = self
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
	self.m_fThree = (yl.WIDTH-0) / 4

	--区域设置
	self:setContentSize(yl.WIDTH,yl.HEIGHT)

	--	背景
	local bg=""
	local temp=tonumber(enterGame._KindID)
	if temp and temp==100 then
		bg="RoomList/room1.png"
	elseif temp and temp==511 then
		bg="RoomList/room1.png"
	else
		bg="RoomList/room0.png"
	end
    local spriteMainBg = cc.Scale9Sprite:create(bg)
    spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
	self:addChild(spriteMainBg)
	
	--游戏标题
	local pathT = "client/res/GameList/title_" .. enterGame._KindID .. ".png"
	if false == cc.FileUtils:getInstance():isFileExist(pathT) then
		pathT = "client/res/GameList/title_0.png"
	end

	--返回
	ccui.Button:create("RoomList/closebtn.png","RoomList/closebtn.png")
    	:move(60,yl.HEIGHT-60)
    	:addTo(self)
    	:addTouchEventListener(function(ref, type)
       		 	if type == ccui.TouchEventType.ended then
					this._scene:onKeyBack()
				end
			end)

	display.newSprite(pathT)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setPosition(cc.p(yl.WIDTH/2,680))
		:addTo(self)

	--房间列表
	self._listView = cc.TableView:create(cc.size(yl.WIDTH, 400))
	self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	self._listView:setPosition(cc.p(0, 160))
	self._listView:setDelegate()
	self._listView:addTo(self)
	self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
	self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._listView:registerScriptHandler(self.cellHightLight, cc.TABLECELL_HIGH_LIGHT)
	self._listView:registerScriptHandler(self.cellUnHightLight, cc.TABLECELL_UNHIGH_LIGHT)

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
end

function RoomListLayer.cellHightLight(view,cell)

end

function RoomListLayer.cellUnHightLight(view,cell)

end

--子视图大小
function RoomListLayer:cellSizeForTable(view, idx)
  	return self.m_fThree , 328
end

--子视图数目
function RoomListLayer:numberOfCellsInTableView(view)
	return #self.m_tabRoomListInfo
end

function RoomListLayer:tableCellTouched(view, cell)
	local index= cell:getIdx()+1
	local roominfo = self.m_tabRoomListInfo[index]
	if not roominfo then
		return
	end
	GlobalUserItem.nCurRoomIndex = roominfo._nRoomIndex
	GlobalUserItem.bPrivateRoom = (roominfo.wServerType == yl.GAME_GENRE_PERSONAL)
	if view:getParent()._scene:roomEnterCheck() then
		view:getParent():onStartGame()
	end
end


--获取子视图
function RoomListLayer:tableCellAtIndex(view, idx)
	local iteminfo = self.m_tabRoomListInfo[idx+1]
	local cell = view:dequeueCell()
	local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)
	if cell == nil then
		cell = cc.TableViewCell:new()
	end
	cell:removeAllChildren()

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

		local cellpos = cc.p(self.m_fThree * 0.5, view:getViewSize().height * 0.5)

--检查房间背景资源
local modulestr = string.gsub(enterGame._KindName, "%.", "/")

dump(enterGame,"enterGame",6)
dump(iteminfo,"iteminfo",6)

dump("enterGame",enterGame,6)
print(modulestr)
--print(wRoom)

		local temp=tonumber(enterGame._KindID)
		local path = "client/res/RoomList/icon_roomlist_" .. idx+1 .. ".png"
		if temp and temp==100 then
			path = "client/res/RoomList/s" .. idx+1 .. ".png"
		elseif temp and temp==511 then
			path = "client/res/RoomList/s" .. idx+1 .. ".png"
		end
		if false == cc.FileUtils:getInstance():isFileExist(path) then
			path = "client/res/RoomList/icon_roomlist_1.png"
		end

		if cc.FileUtils:getInstance():isFileExist(path) then
         	--房间类型
			display.newSprite(path)
				--缩小后留出空间
				:setScale(1)
				:setPosition(cc.p(self.m_fThree * 0.5, view:getViewSize().height * 0.5 - 20))
				:addTo(cell)
		end

        if modulestr == "yule/oxsixex/" then --通比牛牛
		    --底注
			cc.Label:createWithTTF("底注","fonts/round_body.ttf",26)
			    :setPosition(cc.p(self.m_fThree * 0.5 ,64))
				:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				:setTextColor(cc.c4b(255,255,255,255))
				:setAnchorPoint(cc.p(0.5,0.5))
				:addTo(cell)
			cc.Label:createWithTTF(szServerScore,"fonts/round_body.ttf",26)
			    :setPosition(cc.p(self.m_fThree * 0.5 ,36))
				:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				:setTextColor(cc.c4b(255,255,255,255))
				:setAnchorPoint(cc.p(0.5,0.5))
				:addTo(cell)
			--[[
		    display.newSprite("RoomList/text_roomlist_cellscore.png")
			    :setPosition(cc.p(self.m_fThree * 0.5 - 10,118))
			    :setAnchorPoint(cc.p(1.0,0.5))
			    :addTo(cell)

		    cc.LabelAtlas:_create(szServerScore, "RoomList/num_roomlist_cellscore.png", 14, 19, string.byte("0"))
			    :move(self.m_fThree * 0.5 - 10,40)
			    :setAnchorPoint(cc.p(0,0.5))
			    :addTo(cell)
			--]]
		elseif modulestr == "yule/oxnew/" or modulestr == "yule/oxex/" or modulestr == "yule/watermargin/"then
		    --入场
			cc.Label:createWithTTF("入场","fonts/round_body.ttf",26)
			    :setPosition(cc.p(self.m_fThree * 0.5 ,64))
				:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				:setTextColor(cc.c4b(255,255,255,255))
				:setAnchorPoint(cc.p(0.5,0.5))
				:addTo(cell)
			cc.Label:createWithTTF(szServerEScore,"fonts/round_body.ttf",26)
			    :setPosition(cc.p(self.m_fThree * 0.5 ,36))
				:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				:setTextColor(cc.c4b(255,255,255,255))
				:setAnchorPoint(cc.p(0.5,0.5))
				:addTo(cell)
		elseif modulestr == "yule/fishyqs/" or modulestr == "yule/fishlk/" then
			cc.Label:createWithTTF(szName,"fonts/round_body.ttf",26)
			    :setPosition(cc.p(self.m_fThree * 0.5 ,50))
				:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				:setTextColor(cc.c4b(255,255,255,255))
				:setAnchorPoint(cc.p(0.5,0.5))
				:addTo(cell)
		else
		    --其他 入场
			cc.Label:createWithTTF("入场","fonts/round_body.ttf",26)
			    :setPosition(cc.p(self.m_fThree * 0.5 ,64))
				:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				:setTextColor(cc.c4b(255,255,255,255))
				:setAnchorPoint(cc.p(0.5,0.5))
				:addTo(cell)
			cc.Label:createWithTTF(szServerEScore,"fonts/round_body.ttf",26)
			    :setPosition(cc.p(self.m_fThree * 0.5 ,64))
				:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				:setTextColor(cc.c4b(255,255,255,255))
				:setAnchorPoint(cc.p(0.5,0.5))
				:addTo(cell)
        end
	end

	return cell
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
