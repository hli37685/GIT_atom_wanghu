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

    self.TStext = cc.Label:createWithTTF("内容上限64字", "fonts/round_body.ttf", 24)
        :addTo(EditboxBg)
        :setTextColor(cc.c4b(255,255,255,255))
        :setAnchorPoint(cc.p(0.5,0.5))
        :move(220,90)
    --消息内容
    self._edtMessage = ccui.EditBox:create(cc.size(440,40), "")
		:move(220,110)
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(22)
		:setPlaceholderFontSize(22)
		:setFontColor(cc.c4b(255,255,255,255))
        :setMaxLength(64)
        :setContentSize(440,120) 
		:setPlaceHolder("")
		:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
		:addTo(EditboxBg)
    self._edtMessage:registerScriptEditBoxHandler(handler(self, self.onMessage))

    self._Image_Item = csbNode:getChildByName("Image_Item")
    self._ItemCount = self._Image_Item:getChildByName("txtCount")
end

function UseLabaLayer:onExit()
    
end

--发送消息输入
function UseLabaLayer:onMessage(eventType,sender)
--print(ccui.TextFiledEventType.insert_text ,ccui.TextFiledEventType.delete_backward)
    if eventType=="began" then
        self.TStext:setVisible(false)
    elseif eventType=="ended" then
    elseif eventType=="changed" then
        if nil==self._edtMessage:getText() or ""==self._edtMessage:getText() then
            self.TStext:setVisible(true)
        else
            self.TStext:setVisible(false)
        end
    elseif eventType=="return" then
    end
end

function UseLabaLayer:resetUI()
    --重置界面
    self._edtMessage:setText("")
    --输入提示
    self.TStext:setVisible(true)
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
print(mes)

    --判断emoji
    if ExternalFun.isContainEmoji(mes) then
        showToast(self, "喇叭内容包含非法字符,请重试", 2)
        return
    end
    --敏感词过滤  
    if true == ExternalFun.isContainBadWords(mes) then
        showToast(self, "喇叭内容包含敏感词汇!", 3)
        return
    end

    if string.len(mes) < 1  then
        self.mScene:sendMessage(mes)
        self:setVisible(false)
    else
        showToast(self, "喇叭内容不能为空", 2)
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
