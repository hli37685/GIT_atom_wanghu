--[[
	银行记录界面
	2016_06_21 Ravioyla
]]

local BankRecordLayer = class("BankRecordLayer", function(scene)
		local bankRecordLayer = display.newLayer(cc.c4b(0, 0, 0, 125))
    return bankRecordLayer
end)

-- 进入场景而且过渡动画结束时候触发。
function BankRecordLayer:onEnterTransitionFinish()
	self._scene:showPopWait()
	local this = self
	appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/MobileInterface.ashx","GET","action=getbankrecord&userid="..GlobalUserItem.dwUserID.."&signature="..GlobalUserItem:getSignature(os.time()).."&time="..os.time().."&number=20&page=1",function(jstable,jsdata)
			this._scene:dismissPopWait()
			if jstable then
				local code = jstable["code"]
				if tonumber(code) == 0 then
					local datax = jstable["data"]
					if datax then
						local valid = datax["valid"]
						if valid == true then
							local listcount = datax["total"]
							local list = datax["list"]
							if type(list) == "table" then
								for i=1,#list do
									local item = {}
						            item.tradeType = list[i]["TradeTypeDescription"]
						            item.swapScore = tonumber(list[i]["SwapScore"])
						            item.revenue = tonumber(list[i]["Revenue"])
						            item.date = GlobalUserItem:getDateNumber(list[i]["CollectDate"])
						            item.id = list[i]["TransferAccounts"]
						            table.insert(self._bankRecordList,item)
								end
							end
						end
					end
				end

				this:onUpdateShow()
			else
				showToast(this,"抱歉，获取银行记录信息失败！",2,cc.c3b(250,0,0))
			end
		end)
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function BankRecordLayer:onExitTransitionStart()
    return self
end

function BankRecordLayer:ctor(scene)
	--区域外屏蔽点击
	local  onShield = function(eventType, x, y)
    	return true
    end
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(onShield)
	--end
	
	local this = self

	self._scene = scene
	
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		end
	end)

	self._bankRecordList = {}

--	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_top_bg.png")
--	if nil ~= frame then
--		local sp = cc.Sprite:createWithSpriteFrame(frame)
--		sp:setPosition(yl.WIDTH/2,yl.HEIGHT - 51)
--		self:addChild(sp)
--	end
--	display.newSprite("BankRecord/title_bankrecord.png")
--		:move(yl.WIDTH/2,yl.HEIGHT - 51)
--		:addTo(self)
--	frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_public_frame_0.png")
--	if nil ~= frame then
--		local sp = cc.Sprite:createWithSpriteFrame(frame)
--		sp:setPosition(yl.WIDTH/2,326)
--		self:addChild(sp)
--	end
--	display.newSprite("BankRecord/frame_back_2.png")
--		:move(yl.WIDTH/2,326)
--		:addTo(self)

--	ccui.Button:create("bt_return_0.png","bt_return_1.png")
--		:move(75,yl.HEIGHT-51)
--		:addTo(self)
--		:addTouchEventListener(function(ref, type)
--       		 	if type == ccui.TouchEventType.ended then
--					this._scene:onKeyBack()
--				end
--			end)



    -- 背景
    local spriteMainBg = cc.Scale9Sprite:create("BankRecord/denglukuang.png")
    spriteMainBg:setCapInsets(CCRectMake(311,184,20,26))
    spriteMainBg:setContentSize(cc.size(1250, 660))
    spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(spriteMainBg)

    local spriteContentBg = cc.Scale9Sprite:create("BankRecord/frame.png")
    spriteContentBg:setCapInsets(CCRectMake(40,40,42,42))
    spriteContentBg:setContentSize(cc.size(1200, 470))
    spriteContentBg:setPosition(yl.WIDTH/2, yl.HEIGHT/2 -70)
    self:addChild(spriteContentBg)

	--标题背景
	display.newSprite("BankRecord/title_frame.png")
		:move(yl.WIDTH/2,yl.HEIGHT-90)
		:addTo(self)
	--标题
	display.newSprite("BankRecord/title_bankrecord.png")
		:move(yl.WIDTH/2,yl.HEIGHT-90)
		:addTo(self)
	--返回
	ccui.Button:create("BankRecord/closebtn.png","BankRecord/closebtn.png")
    	:move(1240,yl.HEIGHT-94)
    	:addTo(self)
    	:addTouchEventListener(function(ref, type)
       		 	if type == ccui.TouchEventType.ended then
					this._scene:onKeyBack()
				end
			end)

	--标题列
--	display.newSprite("BankRecord/table_bankrecord_line.png")
--		:move(yl.WIDTH/2,520)
--		:addTo(self)
	cc.Label:createWithTTF("交易日期","fonts/round_body.ttf",24)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(102,100,101,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:move(230,570)
		:addTo(self)
	cc.Label:createWithTTF("交易类别","fonts/round_body.ttf",24)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(102,100,101,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:move(500,570)
		:addTo(self)
	cc.Label:createWithTTF("交易金额","fonts/round_body.ttf",24)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(102,100,101,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:move(700,570)
		:addTo(self)
	cc.Label:createWithTTF("转账ID","fonts/round_body.ttf",24)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(102,100,101,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:move(900,570)
		:addTo(self)
	cc.Label:createWithTTF("服务费","fonts/round_body.ttf",24)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(102,100,101,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:move(1100,570)
		:addTo(self)

	--无记录提示
	self._nullTipLabel = cc.Label:createWithTTF("没有银行记录","fonts/round_body.ttf",32)
			:move(yl.WIDTH/2,326)
			:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			:setTextColor(cc.c4b(102,100,101,255))
			:setAnchorPoint(cc.p(0.5,0.5))
			-- :setVisible(false)
			:addTo(self)

	--记录列表
	self._listView = cc.TableView:create(cc.size(1161, 450))
	self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
	self._listView:setPosition(cc.p(90,84))
	self._listView:setDelegate()
	self._listView:addTo(self)
	self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self._listView:registerScriptHandler(self.cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	self._listView:registerScriptHandler(self.tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	self._listView:registerScriptHandler(self.numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

--	display.newSprite("BankRecord/frame_back_1.png")
--		:move(yl.WIDTH/2,326)
--		:addTo(self)

end

function BankRecordLayer:onUpdateShow()
	print("BankRecordLayer:onUpdateShow")

	if not self._bankRecordList then
		print("self._nullTipLabel:setVisible(true)")
		self._nullTipLabel:setVisible(true)
	else
		self._nullTipLabel:setVisible(false)
	end

	self._listView:reloadData()

end

---------------------------------------------------------------------

--子视图大小
function BankRecordLayer.cellSizeForTable(view, idx)
  	return 1161 , 75
end

--子视图数目
function BankRecordLayer.numberOfCellsInTableView(view)
	return #view:getParent()._bankRecordList
end
	
--获取子视图
function BankRecordLayer.tableCellAtIndex(view, idx)		
	local cell = view:dequeueCell()
	
	local item = view:getParent()._bankRecordList[idx+1]

	local width = 1161
	local height= 75

	if not cell then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end

--	display.newSprite("BankRecord/table_bankrecord_cell_"..(idx%2)..".png")
--		:move(width/2,height/2)
--		:addTo(cell)

    local hr = cc.Scale9Sprite:create("BankRecord/hr.png")
    hr:setCapInsets(cc.rect(1,1,773,1))
    hr:setContentSize(cc.size(width, height))
    hr:setPosition(width/2-5, -height/2+4)
    cell:addChild(hr)

	--日期
	local date = os.date("%Y/%m/%d %H:%M:%S", tonumber(item.date)/1000)
	-- print(date)
	-- print(""..tonumber(item.date))
	cc.Label:createWithTTF(date,"fonts/round_body.ttf",24)
		:move(142,height/2+1)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(255,153,0,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)

	cc.Label:createWithTTF(item.tradeType,"fonts/round_body.ttf",24)
		:move(412,height/2+1)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(255,153,0,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)

	cc.Label:createWithTTF(string.formatNumberThousands(item.swapScore,true,","),"fonts/round_body.ttf",24)
		:move(612,height/2+1)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(255,153,0,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)

	cc.Label:createWithTTF(item.id,"fonts/round_body.ttf",24)
		:move(812,height/2+1)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(255,153,0,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)

	cc.Label:createWithTTF(string.formatNumberThousands(item.revenue,true,","),"fonts/round_body.ttf",24)
		:move(1028,height/2+1)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:setTextColor(cc.c4b(255,153,0,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(cell)

	return cell
end
---------------------------------------------------------------------
return BankRecordLayer