--
-- 合成界面
-- 
--

local SynthesisPromptLayer = class("SynthesisPromptLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

SynthesisPromptLayer.BAGITEMICONS = {"icon_jnb.png", "icon_niujiao.png", "icon_xianhua.png", "icon_xingyunbi.png", "icon_yugu.png"}

SynthesisPromptLayer.BTN_CLOSE = 1
SynthesisPromptLayer.BTN_CONFIRM   = 2
SynthesisPromptLayer.BTN_LESS = 3
SynthesisPromptLayer.BTN_MORE = 4

function SynthesisPromptLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Bag/SynthesisPromptLayer.csb", self)
	self.mCsbNode = csbNode

    --按钮
    local btnOk = csbNode:getChildByName("btnClose")
    btnOk:setTag(SynthesisPromptLayer.BTN_CLOSE)
    btnOk:addTouchEventListener(handler(self, self.onBtnCbk))
    --确认
    self.confirm = csbNode:getChildByName("btnBuy")
    self.confirm:setTag(SynthesisPromptLayer.BTN_CONFIRM)
    self.confirm:addTouchEventListener(handler(self, self.onBtnCbk))
    --数量不足提示
    self.Notice=csbNode:getChildByName("Prompt")
    self.Notice:setVisible(false)
    --数量
    local changeCountContainer = csbNode:getChildByName("Image_ItemCount")
    local btnLess = changeCountContainer:getChildByName("btnLess")
    btnLess:setTag(SynthesisPromptLayer.BTN_LESS)
    btnLess:addTouchEventListener(handler(self, self.onBtnCbk))
    local btnMore = changeCountContainer:getChildByName("btnMore")
    btnMore:setTag(SynthesisPromptLayer.BTN_MORE)
    btnMore:addTouchEventListener(handler(self, self.onBtnCbk))
    self._txtSaleNum = changeCountContainer:getChildByName("txtSaleNum")
    self._txtSaleNum:setString("1")
    
    self._edtPrice = ccui.EditBox:create(cc.size(140,30), "")
		:move(70,16)
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(20)
		:setPlaceholderFontSize(20)
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceHolder("")
		:setMaxLength(10)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:addTo(changeCountContainer)
	self._edtPrice:registerScriptEditBoxHandler(handler(self, self.onNumChange))
    --self._edtPrice:registerScriptEditBoxHandler(function(eventname, sender) self:onNumChange(eventname, sender) end) 

    --图标1
    self._Image_Item1 = csbNode:getChildByName("Image_Item1")
    self._ItemCount = self._Image_Item1:getChildByName("txtCount2")
    self._currentCount = self._Image_Item1:getChildByName("txtCount")
    --图标2
    self._Image_Item2 = csbNode:getChildByName("Image_Item2")
    --合成比例 1:10 目前
    self.Proportion=10
    --背包中的数量
    self.currentCount=0
end

function SynthesisPromptLayer:onNumChange(eventType,sender)
print(eventType,sender)
    if eventType=="began" then
        --解决重影问题 暂时不显示当前内容
        --self._edtPrice:setText(self._txtSaleNum:getString())
        self._txtSaleNum:setString("")
    elseif eventType=="ended" then
        local num =self._edtPrice:getText()
        if  num and tonumber(num) and tonumber(num) > 0 then
            --如果大于现存的则返回背包最大个数
            if num*self.Proportion >= self.currentCount then
                num=math.floor(self.currentCount/10)
            end
            self._txtSaleNum:setString(num)
            self._ItemCount:setString(num*self.Proportion)
        else
            showToast(self, "请输入合成个数", 2)
            self._txtSaleNum:setString(1)
        end
        self._edtPrice:setText("")
    elseif eventType=="changed" then
    elseif eventType=="return" then
    end
end

function SynthesisPromptLayer:resetUI()
    self._txtSaleNum:setString("1")
    self._ItemCount:setString(self.Proportion)
end

--返回按钮事件
function SynthesisPromptLayer:onBtnCbk(sender, type)
	if type == ccui.TouchEventType.ended then
        if sender:getTag() == SynthesisPromptLayer.BTN_CLOSE then
            self:setVisible(false)
        elseif sender:getTag() == SynthesisPromptLayer.BTN_CONFIRM then
            self:Sconfirm()
        elseif sender:getTag() == SynthesisPromptLayer.BTN_LESS then
            self:changeCount(true)
        elseif sender:getTag() == SynthesisPromptLayer.BTN_MORE then
            self:changeCount(false)
        end
    end
end

function SynthesisPromptLayer:changeCount(bLess)
    local num = tonumber(self._txtSaleNum:getString())
    local numTotal = tonumber(self._ItemCount:getString())
    if bLess then
        num = num - 1
        if num > 0 then
            self._ItemCount:setString(num*self.Proportion)
            self._txtSaleNum:setString(num)
        end
    else
        num = num + 1
        if num*self.Proportion <= self.currentCount then
            self._ItemCount:setString(num*self.Proportion)
            self._txtSaleNum:setString(num)
        end
    end
end

function SynthesisPromptLayer:Sconfirm()
    local num = self._txtSaleNum:getString()
    if  num and tonumber(num) and tonumber(num) > 0 then
        self.mScene:SynthesisConfirm(self._itemid, tonumber(num))
        self:setVisible(false)
    else
        showToast(self, "请输入合成个数", 2)
    end
end

function SynthesisPromptLayer:setInfo(args)
    if args then
        if args[1] then
            self._itemid = args[1]
            self._Image_Item1:loadTexture("Bag/"..SynthesisPromptLayer.BAGITEMICONS[self._itemid])
            self._Image_Item2:loadTexture("Bag/"..SynthesisPromptLayer.BAGITEMICONS[self._itemid+1])
        end

        if args[2] then
            --背包中的数量
            self.currentCount = args[2]
            --self.currentCount=21            
            self._currentCount:setString(self.currentCount)
        end

        if args[3] then
            --扩展预留 合成比例
            self.Proportion = args[3]             
            self._ItemCount:setString(self.Proportion)
        end
    end
    --数量是否不足
    if self.currentCount<self.Proportion then
        self.Notice:setVisible(true)
        self.confirm:setEnabled(false)
    else
        self.Notice:setVisible(false)
        self.confirm:setEnabled(true)
    end
end

return SynthesisPromptLayer