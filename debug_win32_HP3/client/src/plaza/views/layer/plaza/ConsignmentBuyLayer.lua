--
-- 寄售行购买确认界面
-- 
--

local ConsignmentBuyLayer = class("ConsignmentBuyLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

ConsignmentBuyLayer.BAGITEMICONS = {"icon_jnb.png", "icon_niujiao.png", "icon_xianhua.png", "icon_xingyunbi.png", "icon_yugu.png", "icon_laba.png"}

ConsignmentBuyLayer.BTN_CLOSE = 1
ConsignmentBuyLayer.BTN_BUY   = 2


function ConsignmentBuyLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Bag/ConsignmentBuyLayer.csb", self)
	self.mCsbNode = csbNode

    --按钮
    local btnOk = csbNode:getChildByName("btnClose")
    btnOk:setTag(ConsignmentBuyLayer.BTN_CLOSE)
    btnOk:addTouchEventListener(handler(self, self.onBtnCbk))

    local btnBuy = csbNode:getChildByName("Image_Buy"):getChildByName("btnBuy")
    btnBuy:setTag(ConsignmentBuyLayer.BTN_BUY)
    btnBuy:addTouchEventListener(handler(self, self.onBtnCbk))

    self._Image_Item = csbNode:getChildByName("Image_Item")
    self._ItemCount = self._Image_Item:getChildByName("txtCount")
    local priceContainer = csbNode:getChildByName("Image_5")
    self._txtPrice = priceContainer:getChildByName("txtPrice")
    self._txtPriceCh = priceContainer:getChildByName("txtPriceCh")
    local pwdContainer = csbNode:getChildByName("Image_Pwd")

    self._txtPwd = ccui.EditBox:create(cc.size(230,30), "")
		:move(127,20)
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(20)
		:setPlaceholderFontSize(20)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceHolder("请输入银行密码")
		:addTo(pwdContainer)
end

function ConsignmentBuyLayer:onExit()
    
end

function ConsignmentBuyLayer:resetUI()
    self._txtPwd:setText("")
end

--返回按钮事件
function ConsignmentBuyLayer:onBtnCbk(sender, type)
	if type == ccui.TouchEventType.ended then
        if sender:getTag() == ConsignmentBuyLayer.BTN_CLOSE then
            self:setVisible(false)
        elseif sender:getTag() == ConsignmentBuyLayer.BTN_BUY then
            self:buy()
        end
    end
end

--
function ConsignmentBuyLayer:buy()
    local pwd = self._txtPwd:getText()
    if pwd and #pwd > 0 then
        self.mScene:buy(self._itemIndex, pwd)
        self:setVisible(false)
    else
        showToast(self, "请输入银行密码", 2)
    end
end

function ConsignmentBuyLayer:setInfo(args)
    if args then
        if args[1] then
            self._itemid = args[1]
            self._Image_Item:loadTexture("Bag/"..ConsignmentBuyLayer.BAGITEMICONS[self._itemid])
        end

        if args[2] then
            self._itemTotalCount = args[2]
            self._ItemCount:setString(self._itemTotalCount)
        end

        if args[3] then
            self._itemPrice = args[3]
            self._txtPrice:setString(self._itemPrice)
            self._txtPriceCh:setString(ExternalFun.numberTransiform(self._itemPrice))
        end

        if args[4] then
            self._itemIndex = args[4]
        end
    end
end


return ConsignmentBuyLayer
