local PasswordView = class("PasswordView",function()
		local passwordView = display.newLayer()
    return passwordView
end)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local PasswordFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.PasswordFrame")
------------------------------------------------------------------------------

PasswordView.BT_RETURN	 = 1
PasswordView.BT_QUERY	 = 2
PasswordView.BT_FIND	 = 3

----------------------------------------------
local _OPERATE_CODE  = 1  -- 获取验证码
local _OPERATE_RESET = 2  -- 重置密码
----------------------------------------------

function PasswordView:ctor()

	local this = self

	self:setContentSize(yl.WIDTH,yl.HEIGHT)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("public/public.plist")

	local btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

--	--背景
--    display.newSprite("background_2.jpg")
--        :move(yl.WIDTH/2,yl.HEIGHT/2)
--        :addTo(self)

--    --Top背景
--    display.newSprite("FindPassword/Top_Bg.png")
--    	:move(yl.WIDTH/2,yl.HEIGHT-40)
--    	:addTo(self)

--    --Top标题
--    display.newSprite("FindPassword/Top_Title.png")
--    	:move(yl.WIDTH/2,yl.HEIGHT-40)
--    	:addTo(self)

--    --Top返回
--	ccui.Button:create("bt_return_0.png","bt_return_1.png")
--		:setTag(PasswordView.BT_RETURN)
--		:move(75,yl.HEIGHT-40)
--		:addTo(self)
--		:addTouchEventListener(btcallback)

--	-- 查找背景框
--    display.newSprite("FindPassword/Content_Find_Bg.png")
--    	:move(yl.WIDTH/2,320)
--    	:addTo(self)


    -- 框背景
    local spriteDialogBg = cc.Scale9Sprite:create("FindPassword/denglukuang.png")
    spriteDialogBg:setCapInsets(CCRectMake(40,40,811,448))
    spriteDialogBg:setContentSize(cc.size(900, 600))
    spriteDialogBg:setPosition(yl.WIDTH/2 + 120,yl.HEIGHT/2)
    self:addChild(spriteDialogBg)

    --标题
	display.newSprite("FindPassword/Top_Title.png")
		:move(yl.WIDTH/2 + 120,yl.HEIGHT-125)
		:addTo(self)
    -- 关闭
	ccui.Button:create("public/closebtn.png","public/closebtn.png")
		:setTag(PasswordView.BT_RETURN)
		:move(1230,yl.HEIGHT-80)
		:addTo(self)
		:addTouchEventListener(btcallback)

    -- 女郎
	display.newSprite("FindPassword/girl.png")
		:move(350,yl.HEIGHT/2)
		:addTo(self)

    -- 账号
	display.newSprite("FindPassword/text_regist_account.png")
		:move(660,490)
		:addTo(self)

	--账号输入
	self.edit_Account = ccui.EditBox:create(cc.size(461,65), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,490)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(31)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("6-31位字符!")
		:addTo(self)

    -- 密码
	display.newSprite("FindPassword/text_regist_password.png")
		:move(650,410)
		:addTo(self)

	--密码输入
	self.edit_Password = ccui.EditBox:create(cc.size(461,65), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,410)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(26)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
		:setPlaceHolder("6-26位英文字母，数字，下划线组合!")
		:addTo(self)

    -- 确认密码
	display.newSprite("FindPassword/text_confirm_pwd.png")
		:move(630,330)
		:addTo(self)

	-- 确认密码输入
	self.edit_RePassword = ccui.EditBox:create(cc.size(461,65), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,330)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(26)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
		:setPlaceHolder("请再次输入新密码!")
		:addTo(self)

    -- 验证码
    display.newSprite("FindPassword/yanzhengmatext.png")
		:move(650,250)
		:addTo(self)

	--验证码	
	self.edit_Code = ccui.EditBox:create(cc.size(279,65), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(860,250)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(26)
		:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
		:setPlaceHolder("6位验证码!")
		:addTo(self)

	-- 获取验证码按钮
--	ccui.Button:create("FindPassword/Btn_GetCode.png","")
--		:setTag(PasswordView.BT_QUERY)
--		:move(1000,250)
--		:addTo(self)
--		:addTouchEventListener(btcallback)
    local btnHuoqvyzmBg = cc.Scale9Sprite:create("public/lvbtn.png")
    btnHuoqvyzmBg:setCapInsets(CCRectMake(20,10,66,27))
    btnHuoqvyzmBg:setContentSize(cc.size(160, 50))
    btnHuoqvyzmBg:setPosition(1100,250)
    self:addChild(btnHuoqvyzmBg)

    local newBtnSize = btnHuoqvyzmBg:getContentSize()
	ccui.Button:create("FindPassword/btnhqyzm.png","FindPassword/btnhqyzm.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(PasswordView.BT_QUERY)
		:addTo(btnHuoqvyzmBg)
		:addTouchEventListener(btcallback)


	-- 提交按钮
--	ccui.Button:create("FindPassword/Btn_Submit.png","")
--		:setTag(PasswordView.BT_FIND)
--		:move(yl.WIDTH/2,125)
--		:addTo(self)
--		:addTouchEventListener(btcallback)
    local btnSubmitBg = display.newSprite("public/lanlvbtn.png")
		:move(yl.WIDTH/2 + 150, 140)
		:addTo(self)
    local newBtnSize2 = btnSubmitBg:getContentSize()
	ccui.Button:create("FindPassword/Btn_Submit.png","FindPassword/Btn_Submit.png")
		:move(newBtnSize2.width/2, newBtnSize2.height/2)
		:setTag(PasswordView.BT_FIND)
		:addTo(btnSubmitBg)
		:addTouchEventListener(btcallback)

    --网络回调
    local bindCallBack = function(result,message)
        self:onBindCallBack(result,message)
    end

    --网络处理
    self._oprateCode = 0
    self._passwordFrame = PasswordFrame:create(self,bindCallBack)
end

function PasswordView:onBindCallBack( result, tips )
   
    if type(tips) == "string" and "" ~= tips then
        showToast(self, tips, 2)
    end

    if self._oprateCode ~= _OPERATE_RESET then
        return
    end

    if 0 == result then
        self.edit_Account:setText("")
        self.edit_Code:setText("")
        self.edit_Password:setText("")
        self.edit_RePassword:setText("")     
    end
end


function PasswordView:onButtonClickedEvent(tag,ref)
	if tag == PasswordView.BT_RETURN then
		self:getParent():getParent():onShowLogon()
	elseif tag == PasswordView.BT_QUERY then
		self:onQueryPhoneCode()
	elseif tag == PasswordView.BT_FIND then
		self:onFindPassword()		
	end
end

function PasswordView:onQueryPhoneCode()
    local account = string.gsub(self.edit_Account:getText(), "[.]", "")
    if ( account == "" ) then
        showToast( self, "请输入账号!", 2 )
        return
    end

	print(account)
    -- 发送验证码请求
    self._oprateCode = _OPERATE_CODE
    self._passwordFrame:SendQueryCode(account)
end

function PasswordView:onFindPassword()
    -- 账号
    local account = string.gsub(self.edit_Account:getText(), "[.]", "")
    if ( phone == "" ) then
        showToast( self, "请输入账号!", 2 )
        return
    end

    -- 验证码
    local code = string.gsub(self.edit_Code:getText(), "[.]", "")
    if ( code == "" ) then
        showToast( self, "请输入验证码!", 2 )
        return
    end

    --密码
	local password = string.gsub(self.edit_Password:getText(), " ", "")
	local repassword = string.gsub(self.edit_RePassword:getText(), " ", "")
	if ( password == "" ) then
		showToast( self, "请输入新密码!", 2 )
        return
    end

    if ( password ~= repassword ) then
    	showToast( self, "两次输入的密码不一致!", 2 )
        return
    end

	self._oprateCode = _OPERATE_RESET
    self._passwordFrame:SendResetPassword(account, password,code)
end

return PasswordView