--
-- 寄售确认界面
-- 
--

local ConsignmentLayer = class("ConsignmentLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

ConsignmentLayer.BAGITEMICONS = {"icon_jnb.png", "icon_niujiao.png", "icon_xianhua.png", "icon_xingyunbi.png", "icon_yugu.png", "icon_laba.png"}

ConsignmentLayer.BTN_CLOSE = 1
ConsignmentLayer.BTN_CONSIGNMENT   = 2
ConsignmentLayer.BTN_LESS = 3
ConsignmentLayer.BTN_MORE = 4

function ConsignmentLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Bag/ConsignmentLayer.csb", self)
	self.mCsbNode = csbNode

    --按钮
    local btnOk = csbNode:getChildByName("btnClose")
    btnOk:setTag(ConsignmentLayer.BTN_CLOSE)
    btnOk:addTouchEventListener(handler(self, self.onBtnCbk))
    local btnConsignment = csbNode:getChildByName("Image_Consignment"):getChildByName("btnConsignment")
    btnConsignment:setTag(ConsignmentLayer.BTN_CONSIGNMENT)
    btnConsignment:addTouchEventListener(handler(self, self.onBtnCbk))
    local changeCountContainer = csbNode:getChildByName("Image_ItemCount")
    local btnLess = changeCountContainer:getChildByName("btnLess")
    btnLess:setTag(ConsignmentLayer.BTN_LESS)
    btnLess:addTouchEventListener(handler(self, self.onBtnCbk))
    local btnMore = changeCountContainer:getChildByName("btnMore")
    btnMore:setTag(ConsignmentLayer.BTN_MORE)
    btnMore:addTouchEventListener(handler(self, self.onBtnCbk))
    self._txtSaleNum = changeCountContainer:getChildByName("txtSaleNum")
    self._txtSaleNum:setString("1")
    --数量输入框
    self._edtCount = ccui.EditBox:create(cc.size(140,30), "")
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
	self._edtCount:registerScriptEditBoxHandler(handler(self, self.onCountChange))

    self._Image_Item = csbNode:getChildByName("Image_Item")
    self._ItemCount = self._Image_Item:getChildByName("txtCount")

    local priceContainer = csbNode:getChildByName("Image_5"):getChildByName("Image_6")

    self._edtPrice = ccui.EditBox:create(cc.size(230,30), "")
		:move(122,20)
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(20)
		:setPlaceholderFontSize(20)
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceHolder("请输入寄售价格")
		:addTo(priceContainer)
	self._edtPrice:registerScriptEditBoxHandler(handler(self, self.onNumChange))

--    self._edtPrice = priceContainer:getChildByName("edtPrice")
--    self._edtPrice:addEventListener(handler(self, self.onNumChange));
    self._txtPriceCh = priceContainer:getChildByName("txtPriceCh")
end

function ConsignmentLayer:onExit()
    
end
--数量修改
function ConsignmentLayer:onCountChange(eventType,sender)
    if eventType=="began" then
        --解决重影问题 暂时不显示当前内容
        --self._edtCount:setText(self._txtSaleNum:getString())
        self._txtSaleNum:setString("")
    elseif eventType=="ended" then
        local num =self._edtCount:getText()
        if  num and tonumber(num) and tonumber(num) > 0 then
            self._txtSaleNum:setString(num)
        else
            showToast(self, "请输入上架个数", 2)
            self._txtSaleNum:setString(1)
        end
        self._edtCount:setText("")
    elseif eventType=="changed" then
    elseif eventType=="return" then
    end
end


function ConsignmentLayer:onNumChange(sender, eventType)
    if eventType == nil then
        if sender ~= "changed" then
            return;
        end
    else
        if eventType ~= ccui.TextFiledEventType.insert_text and eventType ~= ccui.TextFiledEventType.delete_backward then
            return;
        end        
    end

    self._price = tonumber(self._edtPrice:getString())
    if self._price and self._price > 0 then
        local upperNumStr = ExternalFun.numberTransiform(self._price)
        self._txtPriceCh:setString(upperNumStr)
    end
end

function ConsignmentLayer:resetUI()
    self._txtSaleNum:setString("1")
    self._edtPrice:setText("")
end

--返回按钮事件
function ConsignmentLayer:onBtnCbk(sender, type)
	if type == ccui.TouchEventType.ended then
        if sender:getTag() == ConsignmentLayer.BTN_CLOSE then
            self:setVisible(false)
        elseif sender:getTag() == ConsignmentLayer.BTN_CONSIGNMENT then
            self:consignment()
        elseif sender:getTag() == ConsignmentLayer.BTN_LESS then
            self:changeCount(true)
        elseif sender:getTag() == ConsignmentLayer.BTN_MORE then
            self:changeCount(false)
        end
    end
end

function ConsignmentLayer:changeCount(bLess)
    local num = tonumber(self._txtSaleNum:getString())
    local numTotal = tonumber(self._ItemCount:getString())
    if bLess then
        num = num - 1
        if num > 0 then
            self._txtSaleNum:setString(num)
        end
    else
        num = num + 1
        if num <= numTotal then
            self._txtSaleNum:setString(num)
        end
    end
end

function ConsignmentLayer:consignment()
    local price = self._edtPrice:getText() 
    local num = self._txtSaleNum:getString()
    if price and tonumber(price) and tonumber(price) > 0 and tonumber(num) > 0 then
        self.mScene:consignment(self._itemid, tonumber(price), tonumber(num))
        self:setVisible(false)
    else
        showToast(self, "请输入商品价格和个数", 2)
    end
end

function ConsignmentLayer:setInfo(args)
    if args then
--        for i = 1, #args do
--            self._txtContentList[i]:setString(args[i])
--        end
        if args[1] then
            self._itemid = args[1]
            self._Image_Item:loadTexture("Bag/"..ConsignmentLayer.BAGITEMICONS[self._itemid])
        end

        if args[2] then
            self._itemTotalCount = args[2]
            self._ItemCount:setString(self._itemTotalCount)
        end
    end
end


return ConsignmentLayer
