local LogonView = class("LogonView",function()
		local logonView =  display.newLayer()
    return logonView
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local QueryExit = appdf.req(appdf.BASE_SRC.."app.views.layer.other.QueryDialog")

LogonView.BT_LOGON = 1
LogonView.BT_REGISTER = 2
LogonView.CBT_RECORD = 3
LogonView.CBT_AUTO = 4
LogonView.BT_VISITOR = 5
LogonView.BT_WEIBO = 6
LogonView.BT_QQ	= 7
LogonView.BT_THIRDPARTY	= 8
LogonView.BT_WECHAT	= 9
LogonView.BT_FGPW = 10 	-- 忘记密码


LogonView.BT_EXIT 		= 11
LogonView.DG_QUERYEXIT 	= 12
LogonView.BT_EXIT2 		= 13

function LogonView:ctor(serverConfig)
	local this = self
	self:setContentSize(yl.WIDTH,yl.HEIGHT)
	--ExternalFun.registerTouchEvent(self)

	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
	local cbtlistener = function (sender,eventType)
    	this:onSelectedEvent(sender,eventType)
    end

    local editHanlder = function ( name, sender )
		self:onEditEvent(name, sender)
	end

	--[[
    -- 登录框背景
    local spriteDialogBg = cc.Scale9Sprite:create("Logon/denglukuang.png")
    spriteDialogBg:setCapInsets(CCRectMake(40,40,560,428))
    spriteDialogBg:setContentSize(cc.size(900, 600))
    spriteDialogBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(spriteDialogBg)

    --标题
	display.newSprite("Logon/dltitle.png")
		:move(yl.WIDTH/2,yl.HEIGHT-118)
		:addTo(self)
	--]]

    -- 背景
    local spriteMainBg = cc.Scale9Sprite:create("Logon/denglukuang.png")
    spriteMainBg:setCapInsets(CCRectMake(311,184,20,26))
    spriteMainBg:setContentSize(cc.size(900, 600))
    spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(spriteMainBg)

    local spriteContentBg = cc.Scale9Sprite:create("Logon/frame.png")
    spriteContentBg:setCapInsets(CCRectMake(40,40,42,42))
    spriteContentBg:setContentSize(cc.size(820, 450))
    spriteContentBg:setPosition(yl.WIDTH/2, yl.HEIGHT/2 -20)
    self:addChild(spriteContentBg)

	--标题背景
	display.newSprite("Logon/title_frame.png")
		:move(yl.WIDTH/2,yl.HEIGHT-120)
		:addTo(self)
	--标题
	display.newSprite("Logon/t_denglu.png")
		:move(yl.WIDTH/2,yl.HEIGHT-120)
		:addTo(self)
		
	--返回
	ccui.Button:create("Logon/bt_qx.png","Logon/bt_qx.png")
    	:move(1065,yl.HEIGHT-125)
		:setTag(LogonView.BT_EXIT2)
    	:addTo(self)
		:addTouchEventListener(btcallback)

	--girl
    display.newSprite("Logon/girl.png")
		:move(50,0)
		:setAnchorPoint(cc.p(0,0))
		:addTo(self)

	local PosX=430

    -- 输入框背景
    local editBoxBg = cc.Scale9Sprite:create("Logon/text_field_frame.png")
    	:setCapInsets(CCRectMake(40,28,400,0))
    	:setContentSize(cc.size(560, 50))
    	:setPosition(PosX+300,450)
    self:addChild(editBoxBg)

	--帐号提示
	display.newSprite("Logon/account_text.png")
		:move(PosX+10,450)
		:setAnchorPoint(cc.p(1,0.5))
		:addTo(self)

	--账号输入
	self.edit_Account = ccui.EditBox:create(cc.size(410,67),"")
		:move(PosX+250,450)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(31)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setFontColor(cc.c4b(129,90,90,255))
		:setPlaceholderFontColor(cc.c4b(102,100,101,255))
		:addTo(self)
	self.edit_Account:registerScriptEditBoxHandler(editHanlder)

    -- 输入框背景
    local editBoxBg = cc.Scale9Sprite:create("Logon/text_field_frame.png")
    	:setCapInsets(CCRectMake(40,28,400,0))
    	:setContentSize(cc.size(560, 50))
    	:setPosition(PosX+300,360)
    self:addChild(editBoxBg)

	--密码提示
	display.newSprite("Logon/password_text.png")
		:move(PosX+10,360)
		:setAnchorPoint(cc.p(1,0.5))
		:addTo(self)

	--密码输入	
	self.edit_Password = ccui.EditBox:create(cc.size(410,67),"")
		:move(PosX+250,360)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(26)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setFontColor(cc.c4b(129,90,90,255))
		:setPlaceholderFontColor(cc.c4b(102,100,101,255))
		:addTo(self)

	--记住密码
	self.cbt_Record = ccui.CheckBox:create("Logon/rem_password_button.png","","Logon/choose_button.png","","")
		:move(PosX-10,270)
		:setSelected(GlobalUserItem.bSavePassword)
		:setTag(LogonView.CBT_RECORD)
		:addTo(self)
	display.newSprite("Logon/textRemPwd.png")
		:move(PosX+90,270)
		:addTo(self)

	--注册
	ccui.Button:create("Logon/regtext.png","Logon/regtext.png")
		:move(PosX+500, 270)
		:setTag(LogonView.BT_REGISTER)
        :setName("btn_3")
		:addTo(self)
		:addTouchEventListener(btcallback)

	-- 忘记密码
	ccui.Button:create("Logon/btn_login_fgpw.png")
		:setTag(LogonView.BT_FGPW)
		:move(PosX+250,280)
		:addTo(self)
        :setEnabled(false)
        :setVisible(false)
		:addTouchEventListener(btcallback)
		
	--[[
	--微信登录
    local btnZhanghaodlBg= display.newSprite("Logon/lanlvbtn.png")
		:move(880, 185)
		:setScale(1)
        :setName("Parentbtn_2")
		:addTo(self)
    local newBtnSize = btnZhanghaodlBg:getContentSize()
	ccui.Button:create("Logon/weixin.png","Logon/weixin.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(LogonView.BT_WECHAT)
		:setScale(1)
        :setName("btn_2")
		:addTo(btnZhanghaodlBg)
		:addTouchEventListener(btcallback)
	--]]

	--登录
    local btnZhanghaodlBg = display.newSprite("Logon/lianglvbtn.png")
		:move(yl.WIDTH/2, 125)
		:setScale(1)
        :setName("Parentbtn_1")
		:addTo(self)
    local newBtnSize = btnZhanghaodlBg:getContentSize()
	ccui.Button:create("Logon/bt_regist.png","Logon/bt_regist.png")
		:move(newBtnSize.width/2, newBtnSize.height/2+5)
		:setTag(LogonView.BT_LOGON)
        :setName("btn_1")
		:addTo(btnZhanghaodlBg)
		:addTouchEventListener(btcallback)

	self.m_serverConfig = serverConfig or {}
end

function LogonView:onEditEvent(name, editbox)
	--print(name)
	if "changed" == name then
		if editbox:getText() ~= GlobalUserItem.szAccount then
			self.edit_Password:setText("")
		end		
	end
end

function LogonView:onReLoadUser()
	if GlobalUserItem.szAccount ~= nil and GlobalUserItem.szAccount ~= "" then
		self.edit_Account:setText(GlobalUserItem.szAccount)
	else
		self.edit_Account:setPlaceHolder("请输入您的游戏帐号")
	end

	if GlobalUserItem.szPassword ~= nil and GlobalUserItem.szPassword ~= "" then
		self.edit_Password:setText(GlobalUserItem.szPassword)
	else
		self.edit_Password:setPlaceHolder("请输入您的游戏密码")
	end
end

function LogonView:onButtonClickedEvent(tag,ref)

--退出按钮
	if tag == LogonView.BT_EXIT then
		local a =  Integer64.new()

		print(a:getstring())

		if self:getChildByTag(LogonView.DG_QUERYEXIT) then
		return
		end
		QueryExit:create("确认退出APP吗？",function(ok)
		if ok == true then
		os.exit(0)
		end
		end)
		:setTag(LogonView.DG_QUERYEXIT)
		:addTo(self)
	elseif tag ==LogonView.BT_EXIT2 then
		self:getParent():getParent():onLogonSignOut()
	elseif tag == LogonView.BT_REGISTER then
		GlobalUserItem.bVisitor = false
		self:getParent():getParent():onShowRegister()
	elseif tag == LogonView.BT_VISITOR then
		GlobalUserItem.bVisitor = true
		self:getParent():getParent():onVisitor()
	elseif tag == LogonView.BT_LOGON then
		GlobalUserItem.bVisitor = false
		local szAccount = string.gsub(self.edit_Account:getText(), " ", "")
		local szPassword = string.gsub(self.edit_Password:getText(), " ", "")
		local bAuto = self:getChildByTag(LogonView.CBT_RECORD):isSelected()
		local bSave = self:getChildByTag(LogonView.CBT_RECORD):isSelected()
		self:getParent():getParent():onLogon(szAccount,szPassword,bSave,bAuto)
	elseif tag == LogonView.BT_THIRDPARTY then
		self.m_spThirdParty:setVisible(true)
	elseif tag == LogonView.BT_WECHAT then
		--平台判定
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
			self:getParent():getParent():thirdPartyLogin(yl.ThirdParty.WECHAT)
		else
			showToast(self, "不支持的登录平台 ==> " .. targetPlatform, 2)
		end
	elseif tag == LogonView.BT_FGPW then
        GlobalUserItem.bVisitor = false
		self:getParent():getParent():onShowFindPassword()
	end
end

function LogonView:onTouchBegan(touch, event)
	return self:isVisible()
end

function LogonView:onTouchEnded(touch, event)
	local pos = touch:getLocation();
	local m_spBg = self.m_spThirdParty
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self.m_spThirdParty:setVisible(false)
    end
end

return LogonView
