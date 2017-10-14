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


LogonView.BT_EXIT 			= 11
LogonView.DG_QUERYEXIT 	= 12



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

    -- 登录框背景
    local spriteDialogBg = cc.Scale9Sprite:create("Logon/denglukuang.png")
    spriteDialogBg:setCapInsets(CCRectMake(40,40,811,448))
    spriteDialogBg:setContentSize(cc.size(900, 600))
    spriteDialogBg:setPosition(yl.WIDTH/2 + 120,yl.HEIGHT/2)
    self:addChild(spriteDialogBg)

    --标题
	display.newSprite("Logon/dltitle.png")
		:move(yl.WIDTH/2 + 120,yl.HEIGHT-125)
		:addTo(self)

    -- 女郎
	display.newSprite("Logon/girl.png")
		:move(350,yl.HEIGHT/2)
		:addTo(self)

    -- 扑克
	self.pork = display.newSprite("Logon/poker.png")
		:move(580,yl.HEIGHT/2 - 150)
        :setScale(0.7)
		:addTo(self)
    
    local moveby = cc.MoveBy:create(1.4, cc.p(20, -30))
    local scaleto = cc.ScaleBy:create(1.4, 1.3)
    local spawnAction = cc.Spawn:create(moveby, scaleto)
    local sqe = cc.Sequence:create(spawnAction, spawnAction:reverse()) 
    self.pork:runAction(cc.RepeatForever:create(sqe))

    -- 筹码
    self.chouma = display.newSprite("Logon/chouma.png")
		:move(100,yl.HEIGHT/2 - 20)
        :setScale(1.2)
		:addTo(self)
    
    local moveby = cc.MoveBy:create(1.2, cc.p(-20, -80))
    local scaleto = cc.ScaleBy:create(1.2, 1.6)
    local spawnAction = cc.Spawn:create(moveby, scaleto)
    local sqe = cc.Sequence:create(spawnAction, spawnAction:reverse()) 
    self.chouma:runAction(cc.RepeatForever:create(sqe))

	--帐号提示
	display.newSprite("Logon/account_text.png")
		:move(650,480)
		:addTo(self)

	--账号输入
	self.edit_Account = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,480)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(31)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)		
		:addTo(self)
	self.edit_Account:registerScriptEditBoxHandler(editHanlder)

	--密码提示
	display.newSprite("Logon/password_text.png")
		:move(650,380)
		:addTo(self)

	--密码输入	
	self.edit_Password = ccui.EditBox:create(cc.size(490,67), ccui.Scale9Sprite:create("public/srkdt.png"))
		:move(950,380)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(26)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)		
		:addTo(self)

	-- 忘记密码
	ccui.Button:create("Logon/btn_login_fgpw.png")
		:setTag(LogonView.BT_FGPW)
		:move(900,280)
		:addTo(self)
        :setEnabled(false)
        :setVisible(false)
        :addTouchEventListener(btcallback)


--退出
self._btQUIT= ccui.Button:create("Logon/closebtn.png","Logon/closebtn.png")
self._btQUIT:setTag(LogonView.BT_EXIT)
self._btQUIT:setPosition(yl.WIDTH- 120 ,yl.HEIGHT-80)
self._btQUIT:addTo(self)
--self._btQUIT:setEnabled(false)
--self._btQUIT:setVisible(false)
self._btQUIT:addTouchEventListener(btcallback)



	--记住密码
	self.cbt_Record = ccui.CheckBox:create("Logon/rem_password_button.png","","Logon/choose_button.png","","")
		:move(640,280)
		:setSelected(GlobalUserItem.bSavePassword)
		:setTag(LogonView.CBT_RECORD)
		:addTo(self)
	display.newSprite("Logon/textRemPwd.png")
		:move(710,280)
		:addTo(self)

	-- --自动登录
	-- self.cbt_Auto = ccui.CheckBox:create("cbt_auto_0.png","","cbt_auto_1.png","","")
	-- 	:move(700-93,245)
	-- 	:setSelected(GlobalUserItem.bAutoLogon)
	-- 	:setTag(LogonView.CBT_AUTO)
	-- 	:addTo(self)

	--账号登录
--	ccui.Button:create("Logon/logon_button_0.png", "Logon/logon_button_1.png", "Logon/logon_button_2.png")
--		:setTag(LogonView.BT_LOGON)
--		:move(cc.p(0,0))
--		:setName("btn_1")
--		:addTo(self)
--		:addTouchEventListener(btcallback)
    local btnZhanghaodlBg = display.newSprite("public/lianglvbtn.png")
		:move(730, 150)
        :setName("Parentbtn_1")
		:addTo(self)
    local newBtnSize = btnZhanghaodlBg:getContentSize()
	ccui.Button:create("Logon/denglu.png","Logon/denglu.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(LogonView.BT_LOGON)
        :setName("btn_1")
		:addTo(btnZhanghaodlBg)
		:addTouchEventListener(btcallback)


	--注册按钮
--	ccui.Button:create("Logon/regist_button.png","")
--		:setTag(LogonView.BT_REGISTER)
--		:move(766,165)
--		:addTo(self)
--		:addTouchEventListener(btcallback)

    local btnZhuceBg = display.newSprite("public/lvbtn.png")
		:move(1100, 280)
		:addTo(self)
    local newBtnSize2 = btnZhuceBg:getContentSize()
	ccui.Button:create("Logon/regtext.png","Logon/regtext.png")
		:move(newBtnSize2.width/2, newBtnSize2.height/2)
		:setTag(LogonView.BT_REGISTER)
		:addTo(btnZhuceBg)
		:addTouchEventListener(btcallback)


	--游客登录
	ccui.Button:create("Logon/visitor_button_0.png", "Logon/visitor_button_1.png", "Logon/visitor_button_2.png")
		:setTag(LogonView.BT_VISITOR)
		:move(cc.p(0,0))
		:setEnabled(false)
		:setVisible(false)
		:setName("btn_2")
		:addTo(self)
		:addTouchEventListener(btcallback)

	--微信登陆
--	ccui.Button:create("Logon/thrid_part_wx_0.png", "Logon/thrid_part_wx_1.png", "Logon/thrid_part_wx_2.png")
--		:setTag(LogonView.BT_WECHAT)
--		:move(cc.p(0,0))
--		:setVisible(false)
--		:setEnabled(false)
--		:setName("btn_3")
--		:addTo(self)
--		:addTouchEventListener(btcallback)

    local btnWeixindlBg = display.newSprite("public/lanlvbtn.png")
		:move(1000, 150)
        :setName("Parentbtn_3")
		:addTo(self)
	ccui.Button:create("Logon/weixindl.png","Logon/weixindl.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(LogonView.BT_WECHAT)
        :setName("btn_3")
		:addTo(btnWeixindlBg)
		:addTouchEventListener(btcallback)

	self.m_serverConfig = serverConfig or {}
	self:refreshBtnList()
end

function LogonView:refreshBtnList( )
	for i = 1, 3 do
		local btn = self:getChildByName("btn_" .. i)
		if btn ~= nil then
			btn:setVisible(false)
			btn:setEnabled(false)
		end
	end
	
	local btncount = 1
	local btnpos = 
	{
		{cc.p(667, 70), cc.p(0, 0), cc.p(0, 0)},
		{cc.p(463, 70), cc.p(868, 70), cc.p(0, 0)},
		{cc.p(730, 150), cc.p(667, 70), cc.p(1000, 150)}
	}	
	-- 1:帐号 2:游客 3:微信
	local btnlist = {"btn_1"}
	if false == GlobalUserItem.getBindingAccount() then
		table.insert(btnlist, "btn_2")
	end

	local enableWeChat = self.m_serverConfig["wxLogon"] or 1
	if 0 == enableWeChat then
		table.insert(btnlist, "btn_3")
	end

	local poslist = btnpos[#btnlist]
	for k,v in pairs(btnlist) do
        local tmp = nil
        if v == "btn_1" or v == "btn_3" then
            tmp = self:getChildByName("Parent"..v)
        else
            tmp = self:getChildByName(v)
        end
		if nil ~= tmp then
            if v == "btn_2" then
			    tmp:setEnabled(true)
                tmp:setVisible(false)
            else
			    tmp:setVisible(true)
            end

			local pos = poslist[k]
            if nil ~= pos then
            	tmp:setPosition(pos)
            end
		end
	end
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
