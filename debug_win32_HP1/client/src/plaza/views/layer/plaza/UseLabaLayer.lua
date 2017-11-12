--
-- 使用喇叭界面
-- 
--

local UseLabaLayer = class("UseLabaLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

UseLabaLayer.BAGITEMICONS = {"icon_jnb.png", "icon_niujiao.png", "icon_xianhua.png", "icon_xingyunbi.png", "icon_yugu.png", "icon_laba.png"}

UseLabaLayer.BTN_CLOSE = 1
UseLabaLayer.BTN_CONSIGNMENT   = 2

function UseLabaLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Bag/UseLabaLayer.csb", self)
	self.mCsbNode = csbNode

    --按钮
    local btnOk = csbNode:getChildByName("btnClose")
    btnOk:setTag(UseLabaLayer.BTN_CLOSE)
    btnOk:addTouchEventListener(handler(self, self.onBtnCbk))
    local btnConsi = csbNode:getChildByName("btnConsi")
    btnConsi:setTag(UseLabaLayer.BTN_CONSIGNMENT)
    btnConsi:addTouchEventListener(handler(self, self.onBtnCbk))
    --输入框背景
    local EditboxBg = csbNode:getChildByName("Image_Bg_0")

    --消息内容
    self._edtMessage = ccui.EditBox:create(cc.size(440,180), "")
		:move(220,90)
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(20)
		:setPlaceholderFontSize(20)
		:setFontColor(cc.c4b(255,255,255,255))
		:setMaxLength(64)
		:setPlaceHolder("内容上限64字")
		--:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:addTo(EditboxBg)
    --self._edtMessage:registerScriptEditBoxHandler(handler(self, self.onMessage))
    

    self._textField = ccui.TextField:create("hello easy!","Arial", 36)
    self._textField:setPosition(cc.p(500, 300))
    self._textField:setMaxLength(240)
    self._textField:setMaxLengthEnabled( true)
    self._textField:ignoreContentAdaptWithSize( false)-------------关键
    self._textField:setContentSize(cc.size(600, 80))---------------关键
    self:addChild(self ._textField)
    self._textField:setTouchEnabled( true)

    
    local function textFieldEvent(ref,event)
        print(ref,event)
        self._textField:attachWithIME()
    end
    local function TextFiledCallBack(event)
        local sender = event.target 
        if event.name == "ATTACH_WITH_IME" then
            print("----------------------ATTACH_WITH_IME------------------------")
        elseif event.name == "DETACH_WITH_IME" then
            print("---------------------DETACH_WITH_IME-------------------------")
        elseif event.name == "INSERT_TEXT" then
            print("----------------------INSERT_TEXT------------------------")
        elseif event.name == "DELETE_BACKWARD" then
          print("---------------------DELETE_BACKWARD-------------------------")
        end
    end
    self._textField:addEventListener(TextFiledCallBack)
    

    self._Image_Item = csbNode:getChildByName("Image_Item")
    self._ItemCount = self._Image_Item:getChildByName("txtCount")
end

function UseLabaLayer:onExit()
    
end

--发送消息输入
function UseLabaLayer:onMessage(eventType,sender)
--print(ccui.TextFiledEventType.insert_text ,ccui.TextFiledEventType.delete_backward)
    if eventType=="began" then
    elseif eventType=="ended" then
    elseif eventType=="changed" then
    elseif eventType=="return" then
    end
end

function UseLabaLayer:resetUI()
    --重置界面
end

--返回按钮事件
function UseLabaLayer:onBtnCbk(sender, type)
	if type == ccui.TouchEventType.ended then
        if sender:getTag() == UseLabaLayer.BTN_CLOSE then
            self:setVisible(false)
        elseif sender:getTag() == UseLabaLayer.BTN_CONSIGNMENT then
            self:consignment()
        end
    end
end

function UseLabaLayer:consignment()
    local mes=self._edtMessage:getText()
print(mas)
    if nil~=mes then
        --self.mScene:sendMessage("好冷..2")
        self:setVisible(false)
    else
        showToast(self, "请输入消息内容", 2)
    end
end

function UseLabaLayer:setInfo(args)
    if args then
--        for i = 1, #args do
--            self._txtContentList[i]:setString(args[i])
--        end
        if args[1] then
            self._itemid = args[1]
            self._Image_Item:loadTexture("Bag/"..UseLabaLayer.BAGITEMICONS[self._itemid])
        end

        if args[2] then
            self._itemTotalCount = args[2]
            self._ItemCount:setString(self._itemTotalCount)
        end
    end
end


return UseLabaLayer
