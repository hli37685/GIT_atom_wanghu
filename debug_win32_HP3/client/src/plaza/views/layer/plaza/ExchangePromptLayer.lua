--
-- 寄售确认界面
-- 
--

local ExchangePromptLayer = class("ExchangePromptLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

ExchangePromptLayer.BAGITEMICONS = {"icon_xianhua.png", "icon_xingyunbi.png", "icon_yugu.png", "icon_yugu.png"}
ExchangePromptLayer.BAGITEMDIAMONDS = {"BlueDiamond.png", "YellowDiamond.png", "WhiteDiamond.png", "VIPDiamond.png"}
ExchangePromptLayer.BAGITEMDIAMONDDAYNUM = {"蓝钻7天", "黄钻7天", "白钻7天", "VIP1个月"}
ExchangePromptLayer.BAGITEMNAMES = {"鲜花", "幸运币", "鱼骨头", "鱼骨头"}
ExchangePromptLayer.BAGITEMID={3,4,5,5} 

ExchangePromptLayer.BTN_CLOSE = 1
ExchangePromptLayer.BTN_CONFIRM   = 2

function ExchangePromptLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Bag/ExchangePromptLayer.csb", self)
	self.mCsbNode = csbNode

    --按钮
    local btnOk = csbNode:getChildByName("btnClose")
    btnOk:setTag(ExchangePromptLayer.BTN_CLOSE)
    btnOk:addTouchEventListener(handler(self, self.onBtnCbk))
    --确认
    self.confirm = csbNode:getChildByName("btnBuy")
    self.confirm:setTag(ExchangePromptLayer.BTN_CONFIRM)
    self.confirm:addTouchEventListener(handler(self, self.onBtnCbk))

    --图标1
    self._Image_Item1 = csbNode:getChildByName("Image_Item1")
    self._ItemCount1 = self._Image_Item1:getChildByName("txtCount1")
    self._currentCount1 = self._Image_Item1:getChildByName("txtCount2")
    self._currentCount2 = self._Image_Item1:getChildByName("txtCount3")
    --图标2
    self._Image_Item2 = csbNode:getChildByName("Image_Item2")
    self._ItemCount2 = self._Image_Item2:getChildByName("txtCount1")
    --兑换比例
    self.Proportion=0
    --背包中的数量
    self.currentCount=0
end

function ExchangePromptLayer:resetUI()
end

--返回按钮事件
function ExchangePromptLayer:onBtnCbk(sender, type)
	if type == ccui.TouchEventType.ended then
        if sender:getTag() == ExchangePromptLayer.BTN_CLOSE then
            self:setVisible(false)
        elseif sender:getTag() == ExchangePromptLayer.BTN_CONFIRM then
            self:Econsignment()
        end
    end
end

function ExchangePromptLayer:Econsignment()
    if self.Proportion and self.Proportion>0 then
        self.mScene:ExchangeConfirm(ExchangePromptLayer.BAGITEMID[self._itemid],self.Proportion)
        self:setVisible(false)
    else
        showToast(self, "兑换数量错误", 2)
    end
end

function ExchangePromptLayer:setInfo(args)
    local temp_1 = ""
    if args then
        if args[1] then
            self._itemid = args[1]
            self._Image_Item1:loadTexture("Bag/"..ExchangePromptLayer.BAGITEMICONS[self._itemid])
            self._Image_Item2:loadTexture("Bag/"..ExchangePromptLayer.BAGITEMDIAMONDS[self._itemid])
            self._ItemCount2:setString(ExchangePromptLayer.BAGITEMDIAMONDDAYNUM[self._itemid])
            temp_1=ExchangePromptLayer.BAGITEMNAMES[self._itemid]
        end

        if args[2] then
            --背包中的数量
            self.currentCount = args[2]
            --self.currentCount=800
            self._currentCount1:setString(self.currentCount)
            self._currentCount2:setString(self.currentCount)
        end

        if args[3] then
            --扩展预留 合成比例
            self.Proportion = args[3]             
        end
    end
    self._ItemCount1:setString(temp_1.." "..self.Proportion.."/")
    --数量是否不足
    if self.currentCount<self.Proportion then
        self._currentCount1:setVisible(true)
        self._currentCount2:setVisible(false)
        self.confirm:setEnabled(false)
    else
        self._currentCount1:setVisible(false)
        self._currentCount2:setVisible(true)
        self.confirm:setEnabled(true)
    end
end


return ExchangePromptLayer
