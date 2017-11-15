local MessageListLayer = class("MessageListLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

-- 进入场景而且过渡动画结束时候触发。
function MessageListLayer:onEnterTransitionFinish()
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function MessageListLayer:onExitTransitionStart()
    return self
end

function MessageListLayer:ctor(scene, NoticeMes)
    self._scene = scene
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)
    --加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("public/MessageListLayer.csb", self)
    -- 遮罩
    self.m_mask = csbNode:getChildByName("panel_mask")	
	
	local this = self
	self._NoticeMes=NoticeMes
	
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		end
	end)

	--返回
    btn = csbNode:getChildByName("bg"):getChildByName("close_btn")
    btn:addTouchEventListener(function(ref, type)
			if type == ccui.TouchEventType.ended then
				this:setVisible(false)
			end
		end)

	self._showList = nil
	self._showList = {}
	--ScrollView
	self._MESlist = csbNode:getChildByName("bg"):getChildByName("MESlist")
	self:showLayer(true,self._NoticeMes)
end

function MessageListLayer:showLayer(bShow,NoticeMes)
	self._NoticeMes=NoticeMes
--
dump(self._NoticeMes,"NoticeMes",6)
	self:setVisible(bShow)
	self:Update()
end

--刷新显示内容
function MessageListLayer:Update()
	--清理旧内容
	for i,v in pairs(self._showList) do
		self._showList[i]:removeFromParent()
	end
	--计算scroll滑动高度
    local intervalY = 60
    local scrollWidth = 730
    local scrollHeight = 390;
    local itemCount = #self._NoticeMes
	--
	if intervalY*itemCount>scrollHeight then
		scrollHeight = intervalY*itemCount
	end
	self._MESlist:setInnerContainerSize(cc.size(scrollWidth, scrollHeight))

	for i=1, itemCount do
	local item = self._NoticeMes[i]
--print(item.str)
		
		self._showList[i] = cc.LayerColor:create(cc.c4b(100, 100, 100, 0), scrollWidth, intervalY)
			:move(0,scrollHeight-intervalY*(i-1)-22)
			:addTo(self._MESlist)

		--cc.Label:createWithTTF("的点点滴滴多点点滴三的点点滴滴多点点滴三的点点滴滴多点点滴三的点点滴滴多点点滴三的点点滴滴多点点滴三的点点滴滴多点点滴三一二三四", "fonts/round_body.ttf", 20)
		cc.Label:createWithTTF(item.str, "fonts/round_body.ttf", 20)
			:setTextColor(cc.c4b(255,255,255,255))
			:setAnchorPoint(cc.p(0,0.5))
			:setDimensions(scrollWidth-35,intervalY-5)
			:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			:move(30,2)
			:addTo(self._showList[i])

		--喇叭
		display.newSprite("Lobby/Trumpet.png")
			:move(10,0)
			:addTo(self._showList[i])

		cc.Scale9Sprite:create("Rank/Line.png")
			--:setCapInsets(CCRectMake(1,1,754,1))
			:setCapInsets(cc.rect(1,1,754,1))
			:setContentSize(cc.size(scrollWidth-10,2))
			:setPosition(scrollWidth/2, -intervalY/2+1)
			:addTo(self._showList[i])

	end
end

return MessageListLayer
