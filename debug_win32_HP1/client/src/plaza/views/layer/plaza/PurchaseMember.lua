--
-- 特权商城
-- 
--

local PurchaseMember = class("PurchaseMember", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

PurchaseMember.SHOPICON = {"gmtq.png", "gmlb.png"}
PurchaseMember.SHOPITEMICONS = {"BlueDiamond.png", "YellowDiamond.png", "WhiteDiamond.png","", "VIPDiamond.png", "icon_laba.png"}
PurchaseMember.SHOPITEMTEXT = {"蓝钻", "黄钻", "白钻","", "VIP", "喇叭"}

PurchaseMember.BTN_CLOSE = 1
PurchaseMember.BTN_CONFIRM   = 2
PurchaseMember.BTN_LESS = 3
PurchaseMember.BTN_MORE = 4

function PurchaseMember:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Bag/PurchaseMember.csb", self)
    self.mCsbNode = csbNode
    
    --是否为购买喇叭
    self.isBuylaba=0

    --标题
    self.title=csbNode:getChildByName("Image_2")
    --购买价格 --银行密码
    self.Image_Pje=csbNode:getChildByName("Image_Pje")

    self.Image_11=self.Image_Pje:getChildByName("Image_11")
    --价格
    self.txtPjeT=self.Image_Pje:getChildByName("txtPje")
    
    self.txtPje = self.Image_Pje:getChildByName("txtPje")
    --繁体
    self.txtPjeF =csbNode:getChildByName("describe")

    --按钮
    local btnOk = csbNode:getChildByName("btnClose")
    btnOk:setTag(PurchaseMember.BTN_CLOSE)
    btnOk:addTouchEventListener(handler(self, self.onBtnCbk))
    --确认
    self.confirm = csbNode:getChildByName("Image_Buy"):getChildByName("btnBuy")
    self.confirm:setTag(PurchaseMember.BTN_CONFIRM)
    self.confirm:addTouchEventListener(handler(self, self.onBtnCbk))
    --数量
    local changeCountContainer = csbNode:getChildByName("Image_ItemCount")
    local btnLess = changeCountContainer:getChildByName("btnLess")
    btnLess:setTag(PurchaseMember.BTN_LESS)
    btnLess:addTouchEventListener(handler(self, self.onBtnCbk))
    local btnMore = changeCountContainer:getChildByName("btnMore")
    btnMore:setTag(PurchaseMember.BTN_MORE)
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
    --支付金额 显示

    --银行密码
    self._bankPassword = ccui.EditBox:create(cc.size(230,40), "")
		:move(120,22)
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(20)
		:setPlaceholderFontSize(20)
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceHolder("请输入银行密码")
		:setMaxLength(26)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :addTo(self.Image_Pje)
        :setVisible(false)

    --图标1
    self._Image_Item1 = csbNode:getChildByName("Image_Item1")
    self._ItemCount = self._Image_Item1:getChildByName("txtCount1")
    --商品价格
    self.Proportion=0
end

function PurchaseMember:onNumChange(eventType,sender)
print(eventType,sender)
    if eventType=="began" then
        --解决重影问题 暂时不显示当前内容
        --self._edtPrice:setText(self._txtSaleNum:getString())
        self._txtSaleNum:setString("")
    elseif eventType=="ended" then
        local num =self._edtPrice:getText()
        if  num and tonumber(num) and tonumber(num) > 0 then
            self._txtSaleNum:setString(num)
            self.txtPje:setString(num*self.Proportion)            
            self:FT(num*self.Proportion)
        else
            showToast(self, "请输入购买数量", 2)
            self._txtSaleNum:setString(1)
        end
        self._edtPrice:setText("")
    elseif eventType=="changed" then
    elseif eventType=="return" then
    end
end

function PurchaseMember:resetUI()
    self._txtSaleNum:setString("1")
    self.txtPje:setString("0")
    self.txtPjeF:setString("零")
    self._ItemCount:setString(PurchaseMember.SHOPITEMTEXT[1])
    self._Image_Item1:loadTexture("Bag/"..PurchaseMember.SHOPITEMICONS[1])
    self.title:loadTexture("Bag/"..PurchaseMember.SHOPICON[1])
end

--返回按钮事件
function PurchaseMember:onBtnCbk(sender, type)
	if type == ccui.TouchEventType.ended then
        if sender:getTag() == PurchaseMember.BTN_CLOSE then
            self:setVisible(false)
        elseif sender:getTag() == PurchaseMember.BTN_CONFIRM then
            self:Pconfirm()
        elseif sender:getTag() == PurchaseMember.BTN_LESS then
            self:changeCount(true)
        elseif sender:getTag() == PurchaseMember.BTN_MORE then
            self:changeCount(false)
        end
    end
end

function PurchaseMember:changeCount(bLess)
    local num = tonumber(self._txtSaleNum:getString())
    if bLess then
        num = num - 1
        if num > 0 then
            self.txtPje:setString(num*self.Proportion)
            self:FT(num*self.Proportion)
            self._txtSaleNum:setString(num)
        end
    else
        num = num + 1
        self.txtPje:setString(num*self.Proportion)
        self:FT(num*self.Proportion)
        self._txtSaleNum:setString(num)
    end
end

function PurchaseMember:Pconfirm()
    local num = self._txtSaleNum:getString()
    if  num and tonumber(num) and tonumber(num) > 0 then
        if self.isBuylaba~=1 then
            self.mScene:PurchaseMemberConfirm(self._itemid, tonumber(num))
            self:setVisible(false)
        else
            local bankPassword=self._bankPassword:getText()
            if bankPassword~=nil and ""~=bankPassword then
                if #bankPassword<6 then
                    showToast(self, "请输入6位以上银行密码", 2)
                    return
                end
                self.mScene:PurchaseLabaConfirm(tonumber(num),bankPassword)
                self:setVisible(false)
            else
                showToast(self, "请输入银行密码", 2)
            end
        end
    else
        showToast(self, "请输入购买个数", 2)
    end
end

function PurchaseMember:setInfo(args)
    if args then
        if args[1] then
            self._itemid = args[1]
            self._Image_Item1:loadTexture("Bag/"..PurchaseMember.SHOPITEMICONS[self._itemid])
            self._ItemCount:setString(PurchaseMember.SHOPITEMTEXT[self._itemid])
        end

        if args[2] then
            --商品价格
            self.Proportion = args[2]   
            self.txtPje:setString(self.Proportion) 
            self:FT(self.Proportion)       
        end

        if args[3] then
            if args[3]==1 then
                self.title:loadTexture("Bag/"..PurchaseMember.SHOPICON[1])
                self.Image_11:loadTexture("Bag/zfje.png")
                self.txtPjeF:setVisible(true)
                self.txtPjeT:setVisible(true)      
                self._bankPassword:setVisible(false)          
                self.isBuylaba=0
            elseif args[3]==2 then
                --喇叭
                self.title:loadTexture("Bag/"..PurchaseMember.SHOPICON[2])
                --修改为银行密码
                self.Image_11:loadTexture("Bag/fieldPwd.png")
			    self.txtPjeF:setVisible(false)
                self.txtPjeT:setVisible(false)
                self._bankPassword:setText("")
                self._bankPassword:setVisible(true) --银行密码
                self.isBuylaba=1
            end
        end
    end
end

function PurchaseMember:FT(dst)
		local ndst = tonumber(dst)
		if type(ndst) == "number" and ndst < 9999999999999 then
			self.txtPjeF:setString(ExternalFun.numberTransiform(dst))
		else
			self.txtPjeF:setString("")
		end
end

return PurchaseMember