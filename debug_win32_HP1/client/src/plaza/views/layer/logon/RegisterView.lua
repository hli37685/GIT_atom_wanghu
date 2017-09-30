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

    -- 框背景
    local spriteDialogBg = cc.Scale9Sprite:create("Logon/denglukuang.png")
    spriteDialogBg:setCapInsets(CCRectMake(40,40,560,428))
    spriteDialogBg:setContentSize(cc.size(900, 600))
    spriteDialogBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(spriteDialogBg)

    --标题
	display.newSprite("Regist/zhucetitle.png")
		:move(yl.WIDTH/2,yl.HEIGHT-118)
		:addTo(self)
	
	local PosX=430


    -- 输入框背景
    local editBoxBg = cc.Scale9Sprite:create("Logon/text_field_frame.png")
    	:setCapInsets(CCRectMake(10,10,60,32))
    	:setContentSize(cc.size(560, 70))
    	:setPosition(PosX+260,540)
    self:addChild(editBoxBg)
    -- 手机号
	--[[
    display.newSprite("Regist/phonetext.png")
		:move(PosX,490)
		:addTo(self)
	--]]
 	self.edit_Phone = ccui.EditBox:create(cc.size(490,67), "")
		:move(PosX+260,540)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(11)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("请点击输入11位手机号")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(88,126,184,255))
		:addTo(self)  

	--帐号
    -- 输入框背景
    local editBoxBg = cc.Scale9Sprite:create("Logon/text_field_frame.png")
    	:setCapInsets(CCRectMake(10,10,60,32))
    	:setContentSize(cc.size(560, 70))
    	:setPosition(PosX+260,445)
    self:addChild(editBoxBg)
	--账号输入
    self.edit_Account = ccui.EditBox:create(cc.size(490,67),"")
		:move(PosX+260,445)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(31)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请点击输入账号（6-31位字符）")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(88,126,184,255))
		:addTo(self)

    -- 昵称
    local editBoxBg = cc.Scale9Sprite:create("Logon/text_field_frame.png")
    	:setCapInsets(CCRectMake(10,10,60,32))
    	:setContentSize(cc.size(560, 70))
    	:setPosition(PosX+260,355)
    self:addChild(editBoxBg)
	-- 昵称输入
	self.edit_NickName = ccui.EditBox:create(cc.size(490,67),"")
		:move(PosX+260,355)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(31)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("请点击输入昵称（6-31位字符）")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(88,126,184,255))
		:addTo(self)

	--密码
    local editBoxBg = cc.Scale9Sprite:create("Logon/text_field_frame.png")
    	:setCapInsets(CCRectMake(10,10,60,32))
    	:setContentSize(cc.size(560, 70))
    	:setPosition(PosX+260,260)
    self:addChild(editBoxBg)
	--密码输入	
	self.edit_Password = ccui.EditBox:create(cc.size(490,67),"")
		:move(PosX+260,260)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(26)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("输入密码 6-26位英文字母,数字,下划线组合")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(88,126,184,255))
		:addTo(self)

	--推广员	
	self.edit_Spreader = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("Regist/text_field_regist.png"))
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

	--注册
    local btnZhuceBg = display.newSprite("Regist/lianglvbtn.png")
		:move(510, 160)
		:setScale(1.2)
		:addTo(self)
    newBtnSize = btnZhuceBg:getContentSize()
	ccui.Button:create("Regist/bt_regist.png","Regist/bt_regist.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(RegisterView.BT_REGISTER)
		:addTo(btnZhuceBg)
		:addTouchEventListener(btcallback)

    -- 取消
    local btnZhuceBg = display.newSprite("Regist/lanlvbtn.png")
		:move(880, 160)
		:setScale(1.2)
		:addTo(self)
    newBtnSize = btnZhuceBg:getContentSize()
	ccui.Button:create("Regist/bt_qx.png","Regist/bt_qx.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(RegisterView.BT_RETURN)
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
