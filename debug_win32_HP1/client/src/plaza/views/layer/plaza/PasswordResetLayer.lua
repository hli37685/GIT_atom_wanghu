--
-- 重置密码层
-- LiuXueCheng 2017-03-19
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

local PasswordResetLayer = class("PasswordResetLayer", cc.Layer)

function PasswordResetLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("FindPassword/ResetPasswordLayer.csb", self)
	self.mCsbNode = csbNode

    --顶部区域
	local areaTop = csbNode:getChildByName("Top_Bg")
    --返回按钮
    local btnBack = areaTop:getChildByName("Btn_Back")
    btnBack:addTouchEventListener(handler(self, self.onBtnBack))

    --内容区域
    local areaContent = csbNode:getChildByName("Content_Bg")
    --重置按钮
    local btnReset = areaContent:getChildByName("Btn_Reset")
    btnReset:addTouchEventListener(handler(self, self.onBtnReset))

    --密码1EditBox
    local phoneEditBoxBg = areaContent:getChildByName("Img_Pwd1")
    local editbox = ccui.EditBox:create(cc.size(phoneEditBoxBg:getContentSize().width - 10, phoneEditBoxBg:getContentSize().height - 10), "blank.png")
        :setPosition(phoneEditBoxBg:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(30)
        :setPlaceholderFontSize(30)
        :setMaxLength(26)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :setPlaceHolder("请输入密码")
    areaContent:addChild(editbox)
    self.mPwd1EditBox = editbox
    
    --密码2EditBox
    phoneEditBoxBg = areaContent:getChildByName("Img_Pwd2")
    editbox = ccui.EditBox:create(cc.size(phoneEditBoxBg:getContentSize().width - 10, phoneEditBoxBg:getContentSize().height - 10), "blank.png")
        :setPosition(phoneEditBoxBg:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(30)
        :setPlaceholderFontSize(30)
        :setMaxLength(26)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :setPlaceHolder("请再次输入密码")
    areaContent:addChild(editbox)
    self.mPwd2EditBox = editbox
end

--返回按钮事件
function PasswordResetLayer:onBtnBack(sender, type)
	if type == ccui.TouchEventType.ended then
        self.mScene:onKeyBack()
    end
end

--重置按钮事件
function PasswordResetLayer:onBtnReset(sender, type)
	if type == ccui.TouchEventType.ended then
        self.mScene:onKeyBack()
    end
end

return PasswordResetLayer