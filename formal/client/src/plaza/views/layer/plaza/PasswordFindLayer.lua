--
-- 找回密码层
-- LiuXueCheng 2017-03-19
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local PasswordResetLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.PasswordResetLayer")
local PasswordFindLayer = class("PasswordFindLayer", cc.Layer)


function PasswordFindLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("FindPassword/FindPasswordLayer.csb", self)
	self.mCsbNode = csbNode

    --顶部区域
	local areaTop = csbNode:getChildByName("Top_Bg")
   
    --返回按钮
    local btnBack = areaTop:getChildByName("Btn_Back")
    btnBack:addTouchEventListener(handler(self, self.onBtnBack))

    --内容区域
    local areaContent = csbNode:getChildByName("Content_Bg")
    --获取验证码按钮
    local btnGetCode = areaContent:getChildByName("Btn_GetCode")
    btnGetCode:addTouchEventListener(handler(self, self.onBtnGetCode))
    --确定按钮
    local btnSubmit = areaContent:getChildByName("Btn_Submit")
    btnSubmit:addTouchEventListener(handler(self, self.onBtnSubmit))

    --游戏帐号
    local phoneEditBoxBg = areaContent:getChildByName("Img_AccountBg")
    local editbox = ccui.EditBox:create(cc.size(phoneEditBoxBg:getContentSize().width - 10, phoneEditBoxBg:getContentSize().height - 10), "blank.png")
        :setPosition(phoneEditBoxBg:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(30)
        :setPlaceholderFontSize(30)
        :setMaxLength(26)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE) 
        :setPlaceHolder("请输入您的帐号")
    areaContent:addChild(editbox)
    self.mAccountEditBox = editbox

    --手机号EditBox
    phoneEditBoxBg = areaContent:getChildByName("Img_PhoneBg")
    editbox = ccui.EditBox:create(cc.size(phoneEditBoxBg:getContentSize().width - 10, phoneEditBoxBg:getContentSize().height - 10), "blank.png")
        :setPosition(phoneEditBoxBg:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(30)
        :setPlaceholderFontSize(30)
        :setMaxLength(26)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :setPlaceHolder("请输入您的手机号")
    areaContent:addChild(editbox)
    self.mPhoneEditBox = editbox
    
    --验证码EditBox
    phoneEditBoxBg = areaContent:getChildByName("Img_Code")
    editbox = ccui.EditBox:create(cc.size(phoneEditBoxBg:getContentSize().width - 10, phoneEditBoxBg:getContentSize().height - 10), "blank.png")
        :setPosition(phoneEditBoxBg:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(30)
        :setPlaceholderFontSize(30)
        :setMaxLength(26)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :setPlaceHolder("请输入验证码")
    areaContent:addChild(editbox)
    self.mCodeEditBox = editbox
end

--返回按钮事件
function PasswordFindLayer:onBtnBack(sender, type)
	if type == ccui.TouchEventType.ended then
        self.mScene:onShowLogon()
    end
end

--获取验证码按钮事件
function PasswordFindLayer:onBtnGetCode(sender, type)
	if type == ccui.TouchEventType.ended then
        self.mScene:onKeyBack()
        --local tipLayer = TipLayer:create()
        --cc.Director:getInstance():getRunningScene():addChild(tipLayer)
    end
end

--确定按钮事件
function PasswordFindLayer:onBtnSubmit(sender, type)
	if type == ccui.TouchEventType.ended then
        --取消密码找回界面
       -- self.runAction(cc.MoveTo:create(0.3,cc.p(yl.WIDTH,0)))

        if(nil == self._PasswordResetLayer) then
            self._PasswordResetLayer = PasswordResetLayer:create(self.mScene)
            :move(-yl.WIDTH,0)
			:addTo(self.mScene._backLayer)
        else
            self._PasswordResetLayer:stopAllActions()
        end
        self._PasswordResetLayer:runAction(cc.MoveTo:create(0.3,cc.p(0,0)))
    end
end

return PasswordFindLayer