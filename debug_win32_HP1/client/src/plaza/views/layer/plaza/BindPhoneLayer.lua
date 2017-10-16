--
-- 绑定手机号层
-- LiuXueCheng 2017-03-18
--

local BindPhoneLayer = class("BindPhoneLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local BindFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BindPhoneFrame")

local _OPERATE_CODE = 1  -- 获取验证码
local _OPERATE_BIND = 2  -- 绑定手机


function BindPhoneLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("BindPhone/BindPhoneLayer.csb", self)
	self.mCsbNode = csbNode

    --顶部区域
--	local areaTop = csbNode:getChildByName("Top_Bg")

    --返回按钮
    local btnBack = csbNode:getChildByName("Btn_Back")
    btnBack:addTouchEventListener(handler(self, self.onBtnBack))

    --内容区域
--    local areaContent = csbNode:getChildByName("Content_Bg")

    --获取验证码按钮
    local btnGetCode = csbNode:getChildByName("Btn_GetCode")
    btnGetCode:addTouchEventListener(handler(self, self.onBtnCode))

    --绑定按钮
    local btnBind = csbNode:getChildByName("Btn_Bind")   
    btnBind:addTouchEventListener(handler(self, self.onBtnBind))

    --手机号EditBox
    local phoneEditBoxBg = csbNode:getChildByName("Img_Phone")
    local editbox = ccui.EditBox:create(cc.size(phoneEditBoxBg:getContentSize().width - 10, phoneEditBoxBg:getContentSize().height - 10), "blank.png", UI_TEX_TYPE_PLIST)
        :setPosition(phoneEditBoxBg:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(30)
        :setPlaceholderFontSize(30)
        :setMaxLength(26)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :setPlaceHolder("请输入您的手机号")
    csbNode:addChild(editbox)
    self.mPhoneEditBox = editbox
    
    --验证码EditBox
    phoneEditBoxBg = csbNode:getChildByName("Img_Code")
    editbox = ccui.EditBox:create(cc.size(phoneEditBoxBg:getContentSize().width - 10, phoneEditBoxBg:getContentSize().height - 10), "blank.png", UI_TEX_TYPE_PLIST)
        :setPosition(phoneEditBoxBg:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(30)
        :setPlaceholderFontSize(30)
        :setMaxLength(26)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :setPlaceHolder("请输入验证码")
    csbNode:addChild(editbox)
    self.mCodeEditBox = editbox

    --网络回调
    local bindCallBack = function(result,message)
        self:onBindCallBack(result,message)
    end

    --网络处理
    self._bindFrame = BindFrame:create(self,bindCallBack)
end

function BindPhoneLayer:onBindCallBack( result, tips )
   
    if type(tips) == "string" and "" ~= tips then
        showToast(self, tips, 2)
    end

    if self._oprateCode == nil or self._oprateCode ~= _OPERATE_BIND then
        return
    end

    if 0 == result then
        GlobalUserItem.szMobilePhone = self._phone

        self.mPhoneEditBox:setText("")
        self.mCodeEditBox:setText("")
    end
end

function BindPhoneLayer:onExit()
    if self._bindFrame:isSocketServer() then
        self._bindFrame:onCloseSocket()
    end
end

--返回按钮事件
function BindPhoneLayer:onBtnBack(sender, type)
	if type == ccui.TouchEventType.ended then
        self.mScene:onKeyBack()
    end
end

--复获取验证码按钮事件
function BindPhoneLayer:onBtnCode(sender, type)
	if type ~= ccui.TouchEventType.ended then
        return
    end

    local phone = string.gsub(self.mPhoneEditBox:getText(), "[.]", "")
    if ( phone == "" ) then
        showToast( self, "请输入手机号码!", 2 )
        return
    end

    local length = string.len( phone )
    if ( length ~= 11 ) then
        showToast( self, "请输入正确的手机号码!", 2 )
        return
    end


    local intvalue = tonumber( phone )
    if ( intvalue == nil ) then
        showToast( self, "请输入正确的手机号码!", 2 )
        return
    end

    -- 发送验证码请求
    self._oprateCode = _OPERATE_CODE
    self._bindFrame:SendQueryCode(phone)
end

--绑定按钮事件
function BindPhoneLayer:onBtnBind(sender, type)
	if type ~= ccui.TouchEventType.ended then
        return
    end

    if GlobalUserItem.szMobilePhone ~= "" then
        showToast( self, "已经绑定手机, 请勿重复操作!", 2 )
        return
    end

    -- 手机号码
    local phone = string.gsub(self.mPhoneEditBox:getText(), "[.]", "")
    if ( phone == "" ) then
        showToast( self, "请输入手机号码!", 2 )
        return
    end

    local length = string.len( phone )
    if ( length ~= 11 ) then
        showToast( self, "请输入正确的手机号码!", 2 )
        return
    end


    local intvalue = tonumber( phone )
    if ( intvalue == nil ) then
        showToast( self, "请输入正确的手机号码!", 2 )
        return
    end

    -- 验证码
    local code = string.gsub(self.mCodeEditBox:getText(), "[.]", "")
    if ( code == "" ) then
        showToast( self, "请输入验证码!", 2 )
        return
    end

    length = string.len( code )
    if ( length ~= 6 ) then
        showToast( self, "请输入正确的验证码!", 2 )
        return
    end

    -- 发送绑定请求
    self._oprateCode = _OPERATE_BIND
    self._phone = phone
    self._bindFrame:SendBindPhone(phone,code)
end

return BindPhoneLayer