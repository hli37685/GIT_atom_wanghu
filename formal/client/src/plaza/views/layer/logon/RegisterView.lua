local RegisterView = class("RegisterView",function()
		local registerView = display.newLayer()
    return registerView
end)

RegisterView.BT_REGISTER = 1
RegisterView.BT_RETURN	 = 2
RegisterView.BT_AGREEMENT= 3
RegisterView.CBT_AGREEMENT = 4
RegisterView.BT_HUOQVYZM = 5

RegisterView.bAgreement = true
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local BindFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BindPhoneFrame")

function RegisterView:ctor()
	local this = self
	self:setContentSize(yl.WIDTH,yl.HEIGHT)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("public/public.plist")

	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

--	--背景
--    display.newSprite("background_2.jpg")
--        :move(yl.WIDTH/2,yl.HEIGHT/2)
--        :addTo(self)

--    --Top背景
--    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_top_bg.png")
--    if nil ~= frame then
--        local sp = cc.Sprite:createWithSpriteFrame(frame)
--        sp:setPosition(yl.WIDTH/2,yl.HEIGHT-51)
--        self:addChild(sp)
--    end

--    --Top标题
--    display.newSprite("Regist/title_regist.png")
--    	:move(yl.WIDTH/2,yl.HEIGHT-51)
--    	:addTo(self)

--    --Top返回
--	ccui.Button:create("bt_return_0.png","bt_return_1.png")
--		:setTag(RegisterView.BT_RETURN)
--		:move(75,yl.HEIGHT-51)
--		:addTo(self)
--		:addTouchEventListener(btcallback)

--	--注册背景框
--	frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_public_frame_0.png")
--    if nil ~= frame then
--        local sp = cc.Sprite:createWithSpriteFrame(frame)
--        sp:setPosition(yl.WIDTH/2,320)
--        self:addChild(sp)
--    end


    -- 框背景
    local spriteDialogBg = cc.Scale9Sprite:create("Regist/denglukuang.png")
    spriteDialogBg:setCapInsets(CCRectMake(40,40,811,448))
    spriteDialogBg:setContentSize(cc.size(900, 600))
    spriteDialogBg:setPosition(yl.WIDTH/2 + 120,yl.HEIGHT/2)
    self:addChild(spriteDialogBg)

    --标题
	display.newSprite("Regist/zhucetitle.png")
		:move(yl.WIDTH/2 + 120,yl.HEIGHT-125)
		:addTo(self)

    -- 关闭
	ccui.Button:create("public/closebtn.png","public/closebtn.png")
		:setTag(RegisterView.BT_RETURN)
		:move(1230,yl.HEIGHT-80)
		:addTo(self)
		:addTouchEventListener(btcallback)

    -- 女郎
	display.newSprite("Regist/girl.png")
		:move(350,yl.HEIGHT/2)
		:addTo(self)
    -- 关闭
--	ccui.Button:create("public/closebtn.png","public/closebtn.png")
--		:setTag(RegisterView.BT_RETURN)
--		:move(yl.WIDTH/2 + 570,yl.HEIGHT-80)
--		:addTo(self)
--		:addTouchEventListener(btcallback)

    -- 手机号
    display.newSprite("Regist/phonetext.png")
		:move(640,490)
		:addTo(self)
 	self.edit_Phone = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,490)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(11)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("请输入11位手机号")
		:addTo(self)  
    -- 验证码
   -- display.newSprite("Regist/yanzhengmatext.png")
	--	:move(640,410)
	--	:addTo(self)

	--验证码	
--	self.edit_Code = ccui.EditBox:create(cc.size(279,65), ccui.Scale9Sprite:create("public/srkdt.png"))
--		:move(850,410)
--		:setAnchorPoint(cc.p(0.5,0.5))
--		:setFontName("fonts/round_body.ttf")
--		:setPlaceholderFontName("fonts/round_body.ttf")
--		:setFontSize(24)
--		:setPlaceholderFontSize(24)
--		:setMaxLength(26)
--		:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
--		:setPlaceHolder("6位验证码!")
--		:addTo(self)

  --  local btnHuoqvyzmBg = cc.Scale9Sprite:create("public/lvbtn.png")
   -- btnHuoqvyzmBg:setCapInsets(CCRectMake(20,10,66,27))
    --btnHuoqvyzmBg:setContentSize(cc.size(160, 50))
   -- btnHuoqvyzmBg:setPosition(1100,410)
   -- self:addChild(btnHuoqvyzmBg)

  --  local newBtnSize = btnHuoqvyzmBg:getContentSize()
	--ccui.Button:create("Regist/btnhqyzm.png","Regist/btnhqyzm.png")
	--	:move(newBtnSize.width/2, newBtnSize.height/2)
	--	:setTag(RegisterView.BT_HUOQVYZM)
	--	:addTo(btnHuoqvyzmBg)
	--	:addTouchEventListener(btcallback)

    -- 昵称
	display.newSprite("Regist/nickname.png")
		:move(650,330)
		:addTo(self)

	-- 昵称输入
	self.edit_NickName = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,330)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(31)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("6-31位字符")
		:addTo(self)


	--帐号提示
	--display.newSprite("Regist/icon_regist_tip.png")
	--	:move(650,410)
	--	:addTo(self)
	display.newSprite("Regist/text_regist_account.png")
		:move(650,420)
		:addTo(self)

--	--账号输入
    self.edit_Account = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,410)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(31)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("6-31位字符")
		:addTo(self)

	--密码提示
--	display.newSprite("Regist/icon_regist_tip.png")
--		:move(650,380)
--		:addTo(self)
	display.newSprite("Regist/text_regist_password.png")
		:move(650,250)
		:addTo(self)

	--密码输入	
	self.edit_Password = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,250)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(26)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("6-26位英文字母，数字，下划线组合")
		:addTo(self)

	--确认密码提示
--	display.newSprite("Regist/icon_regist_tip.png")
--		:move(293,358)
--		:addTo(self)
	display.newSprite("Regist/text_regist_confirm.png")
		:move(620,330)
        :setVisible(false)
		:addTo(self)

	--确认密码输入	
	self.edit_RePassword = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,330)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(26)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("6-26位英文字母，数字，下划线组合")
        :setVisible(false)
		:addTo(self)

	--推广员
	display.newSprite("Regist/text_regist_tuiguang.png")
		:move(640,250)
        :setVisible(false)
		:addTo(self)

	--推广员	
	self.edit_Spreader = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,250)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(32)
        :setVisible(false)
		:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)--:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入推广员ID")
		:addTo(self)

--	--条款协议
--	self.cbt_Agreement = ccui.CheckBox:create("Regist/choose_regist_0.png","","Regist/choose_regist_1.png","","")
--		:move(510,183)
--		:setSelected(RegisterView.bAgreement)
--		:setTag(RegisterView.CBT_AGREEMENT)
--		:addTo(self)

--	--显示协议
--	ccui.Button:create("Regist/bt_regist_agreement.png","")
--		:setTag(RegisterView.BT_AGREEMENT)
--		:move(780,181)
--		:addTo(self)
--		:addTouchEventListener(btcallback)

	--注册按钮
--	ccui.Button:create("Regist/bt_regist_0.png","")
--		:setTag(RegisterView.BT_REGISTER)
--		:move(yl.WIDTH/2,93)
--		:addTo(self)
--		:addTouchEventListener(btcallback)

    local btnZhuceBg = display.newSprite("public/lanlvbtn.png")
		:move(yl.WIDTH/2 + 150, 140)
		:addTo(self)
    newBtnSize = btnZhuceBg:getContentSize()
	ccui.Button:create("Regist/bt_regist.png","Regist/bt_regist.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(RegisterView.BT_REGISTER)
		:addTo(btnZhuceBg)
		:addTouchEventListener(btcallback)


    --网络回调
    local bindCallBack = function(result,message)
        self:onBindCallBack(result,message)
    end

    --网络处理
    self._oprateCode = 0
    self._bindFrame = BindFrame:create(self,bindCallBack)
end



function RegisterView:onBindCallBack( result, tips )
   
    if type(tips) == "string" and "" ~= tips then
        showToast(self, tips, 2)
    end

    if self._oprateCode ~= 1 then
        return
    end

--    if 0 == result then
--        self.edit_Account:setText("")
--        self.edit_Code:setText("")
--        self.edit_Password:setText("")
--        self.edit_RePassword:setText("")     
--    end
end


function RegisterView:onQueryPhoneCode()
    local phone = string.gsub(self.edit_Phone:getText(), "[.]", "")
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


	print(phone)
    -- 发送验证码请求
    self._oprateCode = 1
    self._bindFrame:SendQueryCode(phone)
end

function RegisterView:onButtonClickedEvent(tag,ref)
	if tag == RegisterView.BT_RETURN then
		self:getParent():getParent():onShowLogon()
    elseif tag == RegisterView.BT_HUOQVYZM then
        self:onQueryPhoneCode()
	elseif tag == RegisterView.BT_AGREEMENT then
		self:getParent():getParent():onShowService()
	elseif tag == RegisterView.BT_REGISTER then
        local phone = string.gsub(self.edit_Phone:getText(), "[.]", "")
        if ( phone == "" or 11 ~= #phone ) then
            showToast( self, "请正确输入11位手机号码!", 2 )
            return
        end
        local intvalue = tonumber( phone )
        if ( intvalue == nil ) then
            showToast( self, "请正确输入11位手机号码!", 2 )
            return
        end

        -- 验证码
       -- local szYanzhengma = string.gsub(self.edit_Code:getText(), " ", "")
        --if szYanzhengma == "" then
          --  showToast( self, "请输入验证码!", 2 )
           -- return
        --end

--		-- 判断 非 数字、字母、下划线、中文 的帐号
		local szAccount = self.edit_Account:getText()
		local filter = string.find(szAccount, "^[a-zA-Z0-9_\128-\254]+$")
		if nil == filter then
			showToast(self, "帐号包含非法字符, 请重试!", 1)
			return
		end
--		szAccount = string.gsub(szAccount, " ", "")
  --      local szAccount = phone
        local szNickName = self.edit_NickName:getText()
		filter = string.find(szNickName, "^[a-zA-Z0-9_\128-\254]+$")
		if nil == filter then
			showToast(self, "昵称包含非法字符, 请重试!", 1)
			return
		end
		szNickName = string.gsub(szNickName, " ", "")
		local szPassword = string.gsub(self.edit_Password:getText(), " ", "")
		local szRePassword = szPassword
		local bAgreement = true
		local szSpreader = string.gsub(self.edit_Spreader:getText(), " ", "")
		self:getParent():getParent():onRegister(szAccount,szPassword,szRePassword,bAgreement,szSpreader,szNickName,szYanzhengma,phone)
	end
end

function RegisterView:setAgreement(bAgree)
	self.cbt_Agreement:setSelected(bAgree)
end

return RegisterView
