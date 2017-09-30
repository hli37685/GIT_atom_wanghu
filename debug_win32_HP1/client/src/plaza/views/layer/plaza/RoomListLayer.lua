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

	--房间列表
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
	
    R_m_fThird = self.m_fThree
	--触摸事件
	local touchListen = cc.EventListenerTouchOneByOne:create()
	touchListen:registerScriptHandler(self.onMyTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	touchListen:registerScriptHandler(self.onMyTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchListen,self)

	--初始化
	RoomListLayer_onMyTouchBegan_cellIndex = nil
	RoomListLayer_onMyTouchBegan_posX = nil

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

function RoomListLayer.cellHightLight(view,cell)

end

function RoomListLayer.cellUnHightLight(view,cell)

end

--触摸开始
function RoomListLayer.onMyTouchBegan( touch,event )
	local pos = touch:getLocation()
	RoomListLayer_onMyTouchBegan_x = pos.x
	RoomListLayer_onMyTouchBegan_y = pos.y
	return true
end

--触摸结束
function RoomListLayer.onMyTouchEnded(touch,event)
	local pos = touch:getLocation();
	local rx = pos.x
	local ry = pos.y
	local rrx = rx - RoomListLayer_onMyTouchBegan_x
	local rry = ry - RoomListLayer_onMyTouchBegan_y
	RoomListLayer_onMyTouchBegan_x=nil
	RoomListLayer_onMyTouchBegan_y=nil
	if math.abs(rrx) >= math.abs(rry) then
		if rrx>0 then
			print("右移动")
		elseif rrx < 0 then
			print("左移动")
		else
			print("一动不动")
			--分界
			if 1250>=pos.x and pos.x>945 then
				RoomListLayer:go(2,2)
			elseif 850>=pos.x and pos.x>545 then
				RoomListLayer:go(2,1)
			end
		end
	else
		if rry > 0 then
			print("上移动")
		elseif rry < 0 then
			print("下移动")
		end
	end
end

--子视图大小
function RoomListLayer:cellSizeForTable(view, idx)
  	return self.m_fThree , 220
end

--合并
function RoomListLayer:go(tag, index)
  	print("go",tag,index)
	if tag==1 then
		RoomListLayer_onMyTouchBegan_cellIndex = index
	elseif tag==2 then
		RoomListLayer_onMyTouchBegan_posX = index
	end
	if nil~=RoomListLayer_onMyTouchBegan_cellIndex and nil~=RoomListLayer_onMyTouchBegan_posX then
		--进入游戏
		local tempIndex= (RoomListLayer_onMyTouchBegan_cellIndex-1)*2+RoomListLayer_onMyTouchBegan_posX
		print("tempIndex::",tempIndex)
		---[[
		local roominfo = RoomG_m_tabRoomListInfo[tempIndex]
		if not roominfo then
			return
		end
		GlobalUserItem.nCurRoomIndex = roominfo._nRoomIndex
		GlobalUserItem.bPrivateRoom = (roominfo.wServerType == yl.GAME_GENRE_PERSONAL)
		if roomselflistLayer._scene:roomEnterCheck() then
			roomselflistLayer:onStartGame()
		end
		--]]
		--重置
		RoomListLayer_onMyTouchBegan_cellIndex = nil
		RoomListLayer_onMyTouchBegan_posX = nil
	end
end

--子视图数目
function RoomListLayer:numberOfCellsInTableView(view)
	return #self.m_tabRoomListInfo/2
end

function RoomListLayer:tableCellTouched(view, cell)
	local index= cell:getIdx()+1
	RoomListLayer:go(1,index)
	--[[
	local roominfo = self.m_tabRoomListInfo[index]
	if not roominfo then
		return
	end
	GlobalUserItem.nCurRoomIndex = roominfo._nRoomIndex
	GlobalUserItem.bPrivateRoom = (roominfo.wServerType == yl.GAME_GENRE_PERSONAL)
	if view:getParent()._scene:roomEnterCheck() then
		view:getParent():onStartGame()
	end
	--]]
end

--获取子视图
function RoomListLayer:tableCellAtIndex(view, idx)
	local cell = view:dequeueCell()
	for i=1,2 do
		local iteminfo = self.m_tabRoomListInfo[idx*2+i]
		local tempID=idx*2+i-1
--dump(self.m_tabRoomListInfo,"self.m_tabRoomListInfo",6)
print(tempID)
--dump(iteminfo,"iteminfo",6)
		local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)
		if cell == nil then
			cell = cc.TableViewCell:new()
			cell:setTag(tempID)
		end

		if tempID%2==0 then
			cell:removeAllChildren()  --不知道有什么意义
		end
			
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
			local enterGame = self._scene:getEnterGameInfo()
					
			local cellpos = cc.p(self.m_fThree * 0.5, view:getViewSize().height * 0.5)

		--检查房间背景资源
		local modulestr = string.gsub(enterGame._KindName, "%.", "/")
		--[[
		if modulestr == "yule/oxex/" or modulestr == "yule/oxnew/" or modulestr == "yule/oxsixex/" or modulestr == "yule/watermargin/"  or modulestr == "yule/zhajinhua/" or modulestr == "yule/fishyqs/" then
			if idx==0 then
				wRoom=1
			elseif idx==1 then
				wRoom=2
			elseif idx==2 then
				wRoom=3
			elseif idx==3 then
				wRoom=4
			else
				wRoom=4
			end
		end
		--]]

		--[[
			dump(iteminfo,"iteminfo",6)
			print("======",(nil==iteminfo["_nRoomIndex"] and 0 or iteminfo["_nRoomIndex"]))
			wRoom=(nil==iteminfo["_nRoomIndex"] and 0 or iteminfo["_nRoomIndex"])
		--]]

		--[[
				local path = "game/" .. modulestr .. "res/roomlist/icon_roomlist_" .. wRoom .. ".png"
				local framename = enterGame._KindID .. "_icon_roomlist_" .. wRoom .. ".png"
			
				local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framename)
				if nil ~= frame then
					local sp = cc.Sprite:createWithSpriteFrame(frame)
					sp:setPosition(cc.p(self.m_fThree * 0.5, view:getViewSize().height * 0.5 - 20))
					cell:addChild(sp)
				elseif cc.FileUtils:getInstance():isFileExist(path) then
					--房间类型
					display.newSprite(path)
						:setPosition(cc.p(self.m_fThree * 0.5, view:getViewSize().height * 0.5 - 20))
						:addTo(cell)
				end
		--]]
			local filestr = "client/res/RoomList/icon_roomlist_" .. tempID+1 .. ".png"
			if false == cc.FileUtils:getInstance():isFileExist(filestr) then
				filestr = "client/res/RoomList/icon_roomlist_1.png"
			end
			display.newSprite(filestr)
				:setPosition(cc.p(200+self.m_fThree *(tempID%2), 110))
				:addTo(cell)
		
			--[[
			--if modulestr == "yule/oxsixex/" then --通比牛牛
				--底注
				display.newSprite("RoomList/text_roomlist_cellscore.png")
					:setPosition(cc.p(self.m_fThree * 0.5 - 10,118))
					:setAnchorPoint(cc.p(1.0,0.5))
					:addTo(cell)
				cc.LabelAtlas:_create(szServerScore, "RoomList/num_roomlist_cellscore.png", 14, 19, string.byte("0")) 
					:move(self.m_fThree * 0.5 - 10,118)
					:setAnchorPoint(cc.p(0,0.5))
					:addTo(cell)
			--end
			--]]
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
