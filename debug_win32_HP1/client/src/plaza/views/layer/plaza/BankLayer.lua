local BankLayer = class("BankLayer", function(scene)
		local bankLayer = display.newLayer(cc.c4b(0, 0, 0, 125))
    return bankLayer
end)

local BankFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BankFrame")
local PopWait = appdf.req(appdf.BASE_SRC.."app.views.layer.other.PopWait")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

BankLayer.BT_TAKE 			= 2
BankLayer.BT_SAVE 			= 3
BankLayer.BT_TRANSFER		= 4
BankLayer.CBT_SAVEORTAKE 	= 5
BankLayer.CBT_TRANSFER 		= 6
BankLayer.EDIT_TRANSFER_DST = 9
BankLayer.CBT_BY_ID			= 10
BankLayer.CBT_BY_NAME		= 11
BankLayer.BT_EXIT			= 12
BankLayer.BT_FORGET			= 15
BankLayer.BT_CHECK			= 16
BankLayer.EDIT_SAVEORTAKE	= 17
BankLayer.BT_CLOSE			= 18
BankLayer.BT_ENABLE			= 19
BankLayer.BT_BACK  			= 20

BankLayer.NCBT_SAVE 		= 21
BankLayer.NCBT_TRANSFER		= 22
BankLayer.NCBT_MODIFYPASSWORD=23
BankLayer.BT_MODIFY_PASSWORD =24
BankLayer.BT_ALL_SAVE 		 =25
BankLayer.NCBT_SENDGLOD		 =26
BankLayer.BT_SEND_GLOD 		 =27

--开通银行
BankLayer.BT_ENABLE_RETURN	= 30
BankLayer.BT_ENABLE_BACK	= 31
BankLayer.BT_ENABLE_CONFIRM = 32

function BankLayer:ctor(scene, gameFrame)
	ExternalFun.registerNodeEvent(self)

	self._scene = scene

	self:setContentSize(yl.WIDTH,yl.HEIGHT)

	local this = self
    --银行配置信息
    self.m_tabBankConfigInfo = {}

	local editHanlder = function(event,editbox)
		this:onEditEvent(event,editbox)
	end

	local editHanlderJB = function(event,editbox)
		this:onEditEventJB(event,editbox)
	end

	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    local cbtlistener = function (sender,eventType)
    	this:onSelectedEvent(sender,eventType)
    end

    --网络回调
    local  bankCallBack = function(result,message)
		this:onBankCallBack(result,message)
	end

	--网络处理
	self._bankFrame = BankFrame:create(self,bankCallBack)
    self._bankFrame._gameFrame = gameFrame
    if nil ~= gameFrame then
        gameFrame._shotFrame = self._bankFrame
    end

	----==================修改密码

	--网络回调
    local modifyCallBack = function(result,message)
		self:onModifyCallBack(result,message)
	end
    --网络处理
	self._modifyFrame = ModifyFrame:create(self,modifyCallBack)

	--==================修改密码

	local areaWidth = yl.WIDTH
	local areaHeight = yl.HEIGHT

    self.MainUIs = {}

    -- 背景
    self.MainUI_spriteMainBg = cc.Scale9Sprite:create("Bank/dialogframe.png")
    --self.MainUI_spriteMainBg:setCapInsets(CCRectMake(311,184,20,26))
    --self.MainUI_spriteMainBg:setContentSize(cc.size(1100, 600))
    self.MainUI_spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(self.MainUI_spriteMainBg)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_spriteMainBg

	--标题
	self.MainUI_title = display.newSprite("Bank/title_bank.png")
		:move(yl.WIDTH/2,yl.HEIGHT-165)
		:addTo(self)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_title

	--返回
	ccui.Button:create("public/closebtn.png","public/closebtn.png")
    	:move(1055,yl.HEIGHT-155)
    	:setTag(BankLayer.BT_EXIT)
    	:addTo(self)
    	:addTouchEventListener(btcallback)
    self.MainUI_returnBtn = self:getChildByTag(BankLayer.BT_EXIT)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_returnBtn

	--转换区域
	self._takesaveArea = display.newLayer()
		:setContentSize(1250,520)
		:move(42,0)
		:addTo(self)
    self.MainUIs[#self.MainUIs+1] = self._takesaveArea

	--右侧内容框
	display.newSprite("Bank/frame.png")
		:move(720,342)
		:addTo(self._takesaveArea)

    --其他功能

    self._notifyText = cc.Label:createWithTTF("提示：存入游戏币免手续费，取出将扣除 的手续费。存款无需输入银行密码。", "fonts/round_body.ttf", 24)
			:addTo(self._takesaveArea)
			:setVisible(false)
			:setTextColor(cc.c4b(136,164,224,255))
			:move(1250/2,38)
---[[
	--选择存款
	ccui.CheckBox:create("Bank/btnBg.png", "", "Bank/btnBg_on.png", "", "")
		:move(385,500)
		:addTo(self)
		:setSelected(true)
		:setTag(BankLayer.NCBT_SAVE)
		:setName("NCBT_1")
		:addEventListener(cbtlistener)
	local CheBox=self:getChildByTag(BankLayer.NCBT_SAVE)
    local cbSize = CheBox:getContentSize()
	display.newSprite("Bank/bt_bank_save.png")
		--:setScale(1.3)
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(CheBox)
	--选择取款
	ccui.CheckBox:create("Bank/btnBg.png", "", "Bank/btnBg_on.png", "", "")
		:move(385,420)
		:addTo(self)
		:setSelected(false)
		:setTag(BankLayer.NCBT_TRANSFER)
		:setName("NCBT_2")
		:addEventListener(cbtlistener)
	local CheBox=self:getChildByTag(BankLayer.NCBT_TRANSFER)
    local cbSize = CheBox:getContentSize()
	display.newSprite("Bank/bt_bank_take.png")
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(CheBox)
	--选择存款
	local CheBox=ccui.CheckBox:create("Bank/btnBg.png", "", "Bank/btnBg_on.png", "", "")
		:move(385,340)
		:addTo(self)
		:setSelected(false)
		:setTag(BankLayer.NCBT_MODIFYPASSWORD)
		:setName("NCBT_3")
		:addEventListener(cbtlistener)
	local CheBox=self:getChildByTag(BankLayer.NCBT_MODIFYPASSWORD)
    local cbSize = CheBox:getContentSize()
	display.newSprite("Bank/modifypassword.png")
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(CheBox)
	--金币赠送
	local CheBox=ccui.CheckBox:create("Bank/btnBg.png", "", "Bank/btnBg_on.png", "", "")
		:move(385,260)
		:addTo(self)
		:setSelected(false)
		:setTag(BankLayer.NCBT_SENDGLOD)
		:setName("NCBT_4")
		:addEventListener(cbtlistener)
	local CheBox=self:getChildByTag(BankLayer.NCBT_SENDGLOD)
    local cbSize = CheBox:getContentSize()
	display.newSprite("Bank/jinbzs.png")
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(CheBox)
--]]

	--	携带金币
    self.txtFrame1=cc.Scale9Sprite:create("Bank/moneyBox.png")
        --spriteSigneBg:setCapInsets(CCRectMake(43,40,479,44))
        :setContentSize(cc.size(500, 52))
		:move(720,490)
		:addTo(self._takesaveArea)

    self.txtBank1=cc.Label:createWithSystemFont("携带金币","Arial", 26)
			:move(500,490)
    		:setAnchorPoint(cc.p(0,0.5))
			:setTextColor(cc.c4b(146,215,255,255))
    		:addTo(self._takesaveArea)

	self.txtQian1=display.newSprite("Bank/qian.png")
		:move(630,490)
		:addTo(self._takesaveArea)

    self._txtScore = cc.Label:createWithSystemFont(string.formatNumberThousands(GlobalUserItem.lUserScore,true,","),"Arial", 26)
    		:move(660,490)
    		:setAnchorPoint(cc.p(0,0.5))
			:setTextColor(cc.c4b(255,214,115,255))
    		:addTo(self._takesaveArea)
	--[[
	display.newSprite("Bank/text_bank_gold.png")
		:setScale(1.3)
		:move(320,490)
		:addTo(self._takesaveArea)
	self._txtScore = cc.LabelAtlas:_create(string.formatNumberThousands(GlobalUserItem.lUserScore,true,"/"), "Bank/bank_num_1.png", 19, 24, string.byte("/"))
    		:move(420,490)
    		:setAnchorPoint(cc.p(0,0.5))
    		:addTo(self._takesaveArea)
	--]]

	--银行存款
    self.txtFrame=cc.Scale9Sprite:create("Bank/moneyBox.png")
        --spriteSigneBg:setCapInsets(CCRectMake(43,40,479,44))
        :setContentSize(cc.size(500, 52))
		:move(720,420)
		:addTo(self._takesaveArea)

    self.txtBank=cc.Label:createWithSystemFont("我的银行","Arial", 26)
			:move(500,420)
    		:setAnchorPoint(cc.p(0,0.5))
			:setTextColor(cc.c4b(146,215,255,255))
    		:addTo(self._takesaveArea)

	self.txtQian=display.newSprite("Bank/qian.png")
		:move(630,420)
		:addTo(self._takesaveArea)

    self._txtInsure = cc.Label:createWithSystemFont(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,","),"Arial", 26)
    		:move(660,420)
    		:setAnchorPoint(cc.p(0,0.5))
			:setTextColor(cc.c4b(255,214,115,255))
    		:addTo(self._takesaveArea)

	--金额输入
    self.number_frame=cc.Scale9Sprite:create("Bank/moneyBox.png")
        --spriteSigneBg:setCapInsets(CCRectMake(43,40,479,44))
        :setContentSize(cc.size(500, 52))
		:move(720 ,350)
		:addTo(self._takesaveArea)

    self.number_label=cc.Label:createWithSystemFont("金币数量","Arial", 26)
			:move(500,350)
    		:setAnchorPoint(cc.p(0,0.5))
			:setTextColor(cc.c4b(146,215,255,255))
    		:addTo(self._takesaveArea)

	self.edit_Score = ccui.EditBox:create(cc.size(200,30), "")
		:move(630,350)
		:setAnchorPoint(cc.p(0,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(12)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("在此输入数量")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(68,91,143,255))
    	:addTo(self._takesaveArea)
	self.edit_Score:registerScriptEditBoxHandler(editHanlder)

    -- 全部存入
    self.all_save = display.newSprite("Bank/lanlvbtn.png")
		:move(930, 350)
		:setScale(0.8)
		:addTo(self)
    newBtnSize = self.all_save:getContentSize()
	ccui.Button:create("Bank/all_save.png","Bank/all_save.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(BankLayer.BT_ALL_SAVE)
		:addTo(self.all_save)
		:addTouchEventListener(btcallback)

--[[
	self.edit_Score = ccui.EditBox:create(cc.size(492,70), ccui.Scale9Sprite:create("Bank/bank_frame_1.png"))
		:move(635,380)
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(13)
		:setFontColor(cc.c4b(255,255,255,255))
		:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
		:setTag(BankLayer.EDIT_SAVEORTAKE)
		:setPlaceHolder("请输入操作金额")
		:addTo(self._takesaveArea)
	self.edit_Score:registerScriptEditBoxHandler(editHanlder)
--]]

    --金额大写提示
	---[[
    self.m_textNumber = ClipText:createClipText(cc.size(550,24), "", "fonts/round_body.ttf", 18)
    self:addChild(self.m_textNumber)
    self.m_textNumber:setPosition(525,318)
    self.m_textNumber:setAnchorPoint(cc.p(0,0.5))
    self.m_textNumber:setTextColor(cc.c4b(68,91,143,255))
    self.MainUIs[#self.MainUIs+1] = self.m_textNumber
	--]]

    --金额大写提示 -金币赠送
    self.m_textNumberJB = ClipText:createClipText(cc.size(550,24), "", "fonts/round_body.ttf", 20)
    self:addChild(self.m_textNumberJB)
    self.m_textNumberJB:setPosition(525,355)
    self.m_textNumberJB:setAnchorPoint(cc.p(0,0.5))
	self.m_textNumberJB:setVisible(false)
    self.m_textNumberJB:setTextColor(cc.c4b(68,91,143,255))
    self.MainUIs[#self.MainUIs+1] = self.m_textNumberJB

	--密码输入
    self.edit_Password_frame=cc.Scale9Sprite:create("Bank/moneyBox.png")
        --spriteSigneBg:setCapInsets(CCRectMake(43,40,479,44))
        :setContentSize(cc.size(500, 52))
		:move(720 ,280)
		:setVisible(false)
		:addTo(self._takesaveArea)

    self.edit_Password_label=cc.Label:createWithSystemFont("取款密码","Arial", 26)
			:move(500,280)
    		:setAnchorPoint(cc.p(0,0.5))
			:setTextColor(cc.c4b(146,215,255,255))
			:setVisible(false)
    		:addTo(self._takesaveArea)

	self.edit_Password = ccui.EditBox:create(cc.size(300,30), "")
		:move(630,280)
		:setAnchorPoint(cc.p(0,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(20)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("在此输入密码")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(68,91,143,255))
		:setVisible(false)
    	:addTo(self._takesaveArea)
	self.edit_Score:registerScriptEditBoxHandler(editHanlder)
	--密码输入
	--[[
	self.edit_Password = ccui.EditBox:create(cc.size(492,70), ccui.Scale9Sprite:create("Bank/bank_frame_1.png"))
		:move(635,280)
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(32)
		:setFontColor(cc.c4b(195,199,239,255))
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("存款不需要密码(默认密码888888)")
		:addTo(self._takesaveArea)

    --取款按钮
   	ccui.Button:create("Bank/bt_bank_take.png", "Bank/bt_bank_take.png")
		:setScale(1.4)
		:move(763,160)
		:setTag(BankLayer.BT_TAKE)
		:addTo(self._takesaveArea)
        :addTouchEventListener(btcallback)
    display.newSprite("Bank/text_bank_take.png")
		:setScale(1.5)
    	:move(305,380)
    	:addTo(self._takesaveArea)
    display.newSprite("Bank/text_bank_password.png")
		:setScale(1.5)
    	:move(305,280)
    	:addTo(self._takesaveArea)
		--]]

	-- 存款 确定
    self.cunkuan = display.newSprite("Bank/lanlvbtn.png")
		:move(700, 200)
		:addTo(self._takesaveArea)
    newBtnSize = self.cunkuan:getContentSize()
	ccui.Button:create("Bank/bt_regist.png","Bank/bt_regist.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:addTo(self.cunkuan)
		:setTag(BankLayer.BT_SAVE)
        :addTouchEventListener(btcallback)

	-- 取款 确定
    self.qukuan = display.newSprite("Bank/lanlvbtn.png")
		:move(700, 200)
		:setVisible(false)
		:addTo(self._takesaveArea)
    newBtnSize = self.qukuan:getContentSize()
	ccui.Button:create("Bank/bt_regist.png","Bank/bt_regist.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:addTo(self.qukuan)
		:setTag(BankLayer.BT_TAKE)
        :addTouchEventListener(btcallback)

	--修改密码 确定
    self.xiugaimima = display.newSprite("Bank/lanlvbtn.png")
		:move(700, 200)
		:setVisible(false)
		:addTo(self._takesaveArea)
    newBtnSize = self.xiugaimima:getContentSize()
	ccui.Button:create("Bank/bt_regist.png","Bank/bt_regist.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:addTo(self.xiugaimima)
		:setTag(BankLayer.BT_MODIFY_PASSWORD)
        :addTouchEventListener(btcallback)

	--金币赠送 确定
    self.jinbizs = display.newSprite("Bank/lanlvbtn.png")
		:move(700, 220)
		:setScale(1)
		:setVisible(false)
		:addTo(self._takesaveArea)
    newBtnSize = self.jinbizs:getContentSize()
	ccui.Button:create("Bank/bt_regist.png","Bank/bt_regist.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:addTo(self.jinbizs)
		:setTag(BankLayer.BT_SEND_GLOD)
        :addTouchEventListener(btcallback)

    cc.Label:createWithTTF("存款不需要密码(银行默认密码888888)", "fonts/round_body.ttf", 20)
			:addTo(self._takesaveArea)
			:setTextColor(cc.c4b(68,91,143,255))
			:move(700,155)

	-- ====修改密码
	self._modifypassword= display.newLayer()
		:setContentSize(1250,520)
		:move(42,0)
		:setVisible(false)
		:addTo(self)

	--旧密码
    cc.Scale9Sprite:create("Bank/moneyBox.png")
        :setContentSize(cc.size(500, 52))
		:move(720 ,490)
		:addTo(self._modifypassword)

    cc.Label:createWithSystemFont("旧密码","Arial", 26)
		:move(500,490)
		:setAnchorPoint(cc.p(0,0.5))
		:setTextColor(cc.c4b(146,215,255,255))
		:addTo(self._modifypassword)

	ccui.EditBox:create(cc.size(300,30), "")
		:move(620,490)
		:setAnchorPoint(cc.p(0,0.5))
		:setName("edit_AreaOldPassword")
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(20)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("在此输入密码")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(68,91,143,255))
    	:addTo(self._modifypassword)

	--新密码
    cc.Scale9Sprite:create("Bank/moneyBox.png")
        :setContentSize(cc.size(500, 52))
		:move(720 ,390)
		:addTo(self._modifypassword)

    cc.Label:createWithSystemFont("新密码","Arial", 26)
		:move(500,390)
		:setAnchorPoint(cc.p(0,0.5))
		:setTextColor(cc.c4b(146,215,255,255))
		:addTo(self._modifypassword)

	ccui.EditBox:create(cc.size(300,30), "")
		:move(620,390)
		:setAnchorPoint(cc.p(0,0.5))
		:setName("edit_AreaNewPassword")
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(20)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("在此输入密码")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(68,91,143,255))
    	:addTo(self._modifypassword)

	--确认密码
    cc.Scale9Sprite:create("Bank/moneyBox.png")
        :setContentSize(cc.size(500, 52))
		:move(720 ,280)
		:addTo(self._modifypassword)

    cc.Label:createWithSystemFont("确认密码","Arial", 26)
		:move(500,280)
		:setAnchorPoint(cc.p(0,0.5))
		:setTextColor(cc.c4b(146,215,255,255))
		:addTo(self._modifypassword)

	ccui.EditBox:create(cc.size(300,30), "")
		:move(620,280)
		:setAnchorPoint(cc.p(0,0.5))
		:setName("edit_AreaQRPassword")
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(20)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("在此输入密码")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(68,91,143,255))
    	:addTo(self._modifypassword)
	--[[
	self.edit_QRPassword:registerScriptEditBoxHandler( function(event,editbox)
		this:onEditEvent(event,editbox)
	end)
	--]]

	-- ====END

	--=====赠送界面
	self._transferArea= display.newLayer()
		:setContentSize(1250,520)
		:move(42,0)
		:setVisible(false)
		:addTo(self)

	--旧密码
    cc.Scale9Sprite:create("Bank/moneyBox.png")
        :setContentSize(cc.size(500, 52))
		:move(720 ,500)
		:addTo(self._transferArea)

    cc.Label:createWithSystemFont("收款人ID","Arial", 26)
		:move(500,500)
		:setAnchorPoint(cc.p(0,0.5))
		:setTextColor(cc.c4b(146,215,255,255))
		:addTo(self._transferArea)

	ccui.EditBox:create(cc.size(300,30), "")
		:move(620,500)
		:setAnchorPoint(cc.p(0,0.5))
		:setName("edit_transferAreaID")
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(20)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("在此输入ID")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(68,91,143,255))
    	:addTo(self._transferArea)

	--新密码
    cc.Scale9Sprite:create("Bank/moneyBox.png")
        :setContentSize(cc.size(500, 52))
		:move(720 ,405)
		:addTo(self._transferArea)

    cc.Label:createWithSystemFont("赠送金额","Arial", 26)
		:move(500,405)
		:setAnchorPoint(cc.p(0,0.5))
		:setTextColor(cc.c4b(146,215,255,255))
		:addTo(self._transferArea)

	ccui.EditBox:create(cc.size(300,30), "")
		:move(620,405)
		:setAnchorPoint(cc.p(0,0.5))
		:setName("edit_transferAreaJE")
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(20)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("在此输入金额")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(68,91,143,255))
    	:addTo(self._transferArea)
		:registerScriptEditBoxHandler(editHanlderJB)

	--确认密码
    cc.Scale9Sprite:create("Bank/moneyBox.png")
        :setContentSize(cc.size(500, 52))
		:move(720 ,300)
		:addTo(self._transferArea)

    cc.Label:createWithSystemFont("银行密码","Arial", 26)
		:move(500,300)
		:setAnchorPoint(cc.p(0,0.5))
		:setTextColor(cc.c4b(146,215,255,255))
		:addTo(self._transferArea)

	ccui.EditBox:create(cc.size(300,30), "")
		:move(620,300)
		:setAnchorPoint(cc.p(0,0.5))
		:setName("edit_transferAreaPassword")
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(26)
		:setPlaceholderFontSize(26)
		:setMaxLength(20)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("在此输入密码")
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceholderFontColor(cc.c4b(68,91,143,255))
    	:addTo(self._transferArea)

	--操作记录
    local czjlBg=display.newSprite("Bank/lanlvbtn.png")
		:move(880, 215)
		:setScale(0.8)
		:addTo(self._transferArea)
    newBtnSize = czjlBg:getContentSize()
	ccui.Button:create("Bank/bt_bank_check.png","Bank/bt_bank_check.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:addTo(czjlBg)
    	:setTag(BankLayer.BT_CHECK)
        :addTouchEventListener(btcallback)

	-- ====END

	--提示区域  暂无用
	self._notifyLayer = ccui.Layout:create()
		:setContentSize(yl.WIDTH,yl.HEIGHT)
		:move(0,0)
		:addTo(self)
		:setVisible(false)
    self._notifyLayer:setTouchEnabled(true)
    self._notifyLayer:setSwallowTouches(true)
--[[
	display.newSprite("General/frame_0.png")
    	:move(yl.WIDTH/2,yl.HEIGHT/2)
    	:addTo(self._notifyLayer)

    ccui.Button:create("General/bt_close_0.png","General/bt_close_1.png")
    	:move(1070,560)
    	:setTag(BankLayer.BT_CLOSE)
    	:addTo(self._notifyLayer)
    	:addTouchEventListener(btcallback)

    display.newSprite("General/title_general.png")
    	:move(yl.WIDTH/2,530)
    	:addTo(self._notifyLayer)

    cc.Label:createWithTTF("初次使用，请先开通银行！", "fonts/round_body.ttf", 24)
			:addTo(self._notifyLayer)
			:setTextColor(cc.c4b(255,255,255,255))
			:move(yl.WIDTH/2,430)

	ccui.Button:create("General/bt_cancel_0.png","General/bt_cancel_1.png")
    	:move(529,239)
    	:setTag(BankLayer.BT_CLOSE)
    	:addTo(self._notifyLayer)
    	:addTouchEventListener(btcallback)

    ccui.Button:create("General/bt_confirm_0.png","General/bt_confirm_1.png")
    	:move(809,239)
    	:setTag(BankLayer.BT_ENABLE)
    	:addTo(self._notifyLayer)
    	:addTouchEventListener(btcallback)
	--开通银行
    if 0 == GlobalUserItem.cbInsureEnabled then
        self:initEnableBankLayer()
        self:ShowMainBankUI(false)
    end
--]]
end

function BankLayer:ShowMainBankUI(bShow)
    for v,k in pairs(self.MainUIs) do
        k:setVisible(bShow)
    end
end

function BankLayer:initEnableBankLayer()
    local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
    local areaWidth = yl.WIDTH

    --开通区域
    self._enableLayer = ccui.Layout:create()
        :setContentSize(yl.WIDTH,yl.HEIGHT)
        :move(0,0)
        :addTo(self)
    self._enableLayer:setTouchEnabled(true)
    self._enableLayer:setSwallowTouches(true)

    -- 背景
    local spriteMainBg = cc.Scale9Sprite:create("public/dialogframe.png")
    spriteMainBg:setCapInsets(CCRectMake(311,184,20,26))
    spriteMainBg:setContentSize(cc.size(1050, 660))
    spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self._enableLayer:addChild(spriteMainBg)

	display.newSprite("Bank/enablebanktitle.png")
		:move(yl.WIDTH/2,yl.HEIGHT-75)
		:addTo(self._enableLayer)

	--返回
	ccui.Button:create("public/closebtn.png","public/closebtn.png")
    	:move(1180,yl.HEIGHT-80)
    	:addTo(self._enableLayer)
        :setTag(BankLayer.BT_ENABLE_RETURN)
    	:addTouchEventListener(btcallback)

    --银行密码提示
    display.newSprite("Bank/text_setpass_enable.png")
        :move(400,470)
        :addTo(self._enableLayer)
    display.newSprite("Bank/text_confirm_enable.png")
        :move(400,320)
        :addTo(self._enableLayer)

    --密码输入
    self.edit_EnablePassword = ccui.EditBox:create(cc.size(492,70), "Bank/bank_frame_1.png")
        :move(770,470)
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setFontColor(cc.c4b(195,199,239,255))
        :setPlaceHolder("请输入您的银行密码")
        :addTo(self._enableLayer)
    --密码确认
    self.edit_EnablePassConfirm = ccui.EditBox:create(cc.size(492,70), "Bank/bank_frame_1.png")
        :move(770,320)
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setFontColor(cc.c4b(195,199,239,255))
        :setPlaceHolder("请输入您的银行密码")
        :addTo(self._enableLayer)

	ccui.Button:create("Bank/bt_bank_enable.png", "Bank/bt_bank_enable.png")
		:move(yl.WIDTH/2,110)
		:setTag(BankLayer.BT_ENABLE_CONFIRM)
		:addTo(self._enableLayer)
        :addTouchEventListener(btcallback)
end

function BankLayer:onFlushBank()
	self:showPopWait()
	self._bankFrame:onFlushBank()
end

--按键监听
function BankLayer:onButtonClickedEvent(tag,sender)
	if tag == BankLayer.BT_TAKE then
		self:onTakeScore()
	elseif tag == BankLayer.BT_SAVE then
		self:onSaveScore()
	elseif tag == BankLayer.BT_TRANSFER then
		self:onTransferScore()
	elseif tag == BankLayer.BT_MODIFY_PASSWORD then
		self:onModifyPassword()
	elseif tag == BankLayer.BT_SEND_GLOD then
		self:onSendGlod()
	elseif tag == BankLayer.BT_ALL_SAVE then
		self:onAllSave()
	elseif tag == BankLayer.BT_EXIT then
		self._scene:onKeyBack()
	elseif tag == BankLayer.BT_CLOSE then
		self._notifyLayer:setVisible(false)
	elseif tag == BankLayer.BT_ENABLE then
		self._notifyLayer:setVisible(false)
        if nil ~= self._enableLayer then
            self._enableLayer:runAction(cc.MoveTo:create(0.3,cc.p(0,0)))
        end
	elseif tag == BankLayer.BT_ENABLE_RETURN then
        self._scene:onKeyBack()
        --[[if nil ~= self._enableLayer then
            self._enableLayer:runAction(cc.MoveTo:create(0.3,cc.p(yl.WIDTH,0)))
        end]]
	elseif tag == BankLayer.BT_ENABLE_CONFIRM then
		self:onEnableBank()
	elseif tag == BankLayer.BT_CHECK then
		self:getParent():getParent():onChangeShowMode(yl.SCENE_BANKRECORD)
	end
end

--输入框监听
function BankLayer:onEditEvent(event,editbox)
---[[
print(event)
	if event == "changed" then
		local src = editbox:getText()

		local dst =  src --string.gsub(src,"([^0-9])","")
		--editbox:setText(dst)

		local ndst = tonumber(dst)
		if type(ndst) == "number" and ndst < 9999999999999 then
			self.m_textNumber:setString(ExternalFun.numberTransiform(dst))
		else
			self.m_textNumber:setString("")
		end
	elseif event == "return" then
		local src = editbox:getText()
		local numstr = self.m_textNumber:getString()
		if src ~= numstr then
			local dst =  string.gsub(src,"([^0-9])","")
			local ndst = tonumber(dst)
			if type(ndst) == "number" and ndst < 9999999999999 then
				self.m_textNumber:setString(ExternalFun.numberTransiform(dst))
			else
				self.m_textNumber:setString("")
			end
            editbox:setText(dst)
		end
	end
--]]
end
--输入框监听
function BankLayer:onEditEventJB(event,editbox)
---[[
	if event == "changed" then
		local src = editbox:getText()

		local dst =  src --string.gsub(src,"([^0-9])","")
		--editbox:setText(dst)

		local ndst = tonumber(dst)
		if type(ndst) == "number" and ndst < 9999999999999 then
			self.m_textNumberJB:setString(ExternalFun.numberTransiform(dst))
		else
			self.m_textNumberJB:setString("")
		end
	elseif event == "return" then
		local src = editbox:getText()
		local numstr = self.m_textNumberJB:getString()
		if src ~= numstr then
			local dst =  string.gsub(src,"([^0-9])","")
			local ndst = tonumber(dst)
			if type(ndst) == "number" and ndst < 9999999999999 then
				self.m_textNumberJB:setString(ExternalFun.numberTransiform(dst))
			else
				self.m_textNumberJB:setString("")
			end
            editbox:setText(dst)
		end
	end
--]]
end


function BankLayer:onSelectedEvent(sender,eventType)
	local tag = sender:getName()
	local btn=self:getChildByName(tag)

	if btn:isSelected() then
	else
		btn:setSelected(true)
		return
	end

	for i = 1, 4 do
		local tempBtn = self:getChildByName("NCBT_" .. i)
		if tempBtn ~= nil then
			tempBtn:setSelected(false)
			tempBtn:setEnabled(true)
		end
	end

	--判断显示的全部内容 有些未统一添加
	self.edit_Password:setVisible(false)
	self.edit_Password_frame:setVisible(false)
	self.edit_Password_label:setVisible(false)
	self.cunkuan:setVisible(false)
	self.qukuan:setVisible(false)
	self.xiugaimima:setVisible(false)
	self.all_save:setVisible(false)
	self.jinbizs:setVisible(false)

	self.txtFrame1:setVisible(true)
	self.txtBank1:setVisible(true)
	self.txtQian1:setVisible(true)
	self._txtScore:setVisible(true)

	self.txtFrame:setVisible(true)
	self.txtBank:setVisible(true)
	self.txtQian:setVisible(true)
	self._txtInsure:setVisible(true)
	self.number_frame:setVisible(true)
	self.number_label:setVisible(true)
	self.edit_Score:setVisible(true)
	
--[[	切换后重影 暂时处理
	self.edit_Score:setText("")
	self.m_textNumber:setString("")
--]]

	self.m_textNumber:setVisible(true)
	self.m_textNumberJB:setVisible(false)
	--修改密码区域
	self._modifypassword:setVisible(false)
	--金币赠送界面
	self._transferArea:setVisible(false)

	if tag=="NCBT_1" then
		btn:setSelected(true)
		print("存款")
		self.cunkuan:setVisible(true)
		self.all_save:setVisible(true)
	elseif tag=="NCBT_2" then
		btn:setSelected(true)
		self.edit_Password:setVisible(true)
		self.edit_Password_frame:setVisible(true)
		self.edit_Password_label:setVisible(true)
		self.qukuan:setVisible(true)
		print("取款")
	elseif tag=="NCBT_3" then
		btn:setSelected(true)

		self.txtFrame1:setVisible(false)
		self.txtBank1:setVisible(false)
		self.txtQian1:setVisible(false)
		self._txtScore:setVisible(false)

		self.txtFrame:setVisible(false)
		self.txtBank:setVisible(false)
		self.txtQian:setVisible(false)
		self._txtInsure:setVisible(false)
		self.number_frame:setVisible(false)
		self.number_label:setVisible(false)
		self.edit_Score:setVisible(false)
		self.all_save:setVisible(false)
		self.m_textNumber:setVisible(false)

		self._modifypassword:setVisible(true)
		self.xiugaimima:setVisible(true)
	elseif tag=="NCBT_4" then
		btn:setSelected(true)

		self.txtFrame1:setVisible(false)
		self.txtBank1:setVisible(false)
		self.txtQian1:setVisible(false)
		self._txtScore:setVisible(false)

		self.txtFrame:setVisible(false)
		self.txtBank:setVisible(false)
		self.txtQian:setVisible(false)
		self._txtInsure:setVisible(false)
		self.number_frame:setVisible(false)
		self.number_label:setVisible(false)
		self.edit_Score:setVisible(false)
		self.all_save:setVisible(false)
		self.m_textNumber:setVisible(false)
		self.m_textNumberJB:setVisible(true)

		self._transferArea:setVisible(true)
		self.jinbizs:setVisible(true)
		print("金币赠送")
	end
--[[

	if tag == BankLayer.CBT_SAVEORTAKE or tag == BankLayer.CBT_TRANSFER then
		local transfermode = (tag == BankLayer.CBT_TRANSFER)
		self._takesaveArea:setVisible(not transfermode)

		self.edit_Score:setText("")
		self.m_textNumber:setString("")

        --手续费
        local str = string.format("提示:存入游戏币免手续费,取出将扣除%d‰的手续费。存款无需输入银行密码。", self.m_tabBankConfigInfo.wRevenueTake)
		--调整位置
		if transfermode then
			self.m_textNumber:setPosition(930, 365)
            str = string.format("提示:普通玩家游戏币赠送需扣除%d‰的手续费。", self.m_tabBankConfigInfo.wRevenueTransfer)
            if 0 ~= GlobalUserItem.cbMemberOrder then
                local vipConfig = GlobalUserItem.MemberList[GlobalUserItem.cbMemberOrder]
                str = str .. vipConfig._name .. "扣除" .. vipConfig._insure .. "‰手续费。"
            end
            self._notifyTextPresent:setString(str)
		else
			self.m_textNumber:setPosition(930, 330)
            self._notifyText:setString(str)
		end
	elseif tag == BankLayer.CBT_BY_ID or tag == BankLayer.CBT_BY_NAME then
		local byID = (tag == BankLayer.CBT_BY_ID)
		self.cbt_TransferByID:setSelected(byID)
		self.cbt_TransferByName:setSelected(not byID)

		local szRes = (byID and "bnak_word_targetid.png" or "bnak_word_targetname.png")
		self._labelTarget:setTexture(szRes)
	end
	--]]
end

--开通银行
function BankLayer:onEnableBank()

	--参数判断
	local szPass = self.edit_EnablePassword:getText()
	local szPassConfirm = self.edit_EnablePassConfirm:getText()

	if #szPass < 1 then
		showToast(self,"请输入银行密码！",2)
		return
	end
	if #szPass < 6 then
		showToast(self,"密码必须大于6个字符，请重新输入！",2)
		return
	end

	if #szPassConfirm < 1 then
		showToast(self,"请在确认栏输入银行密码！",2)
		return
	end
	if #szPassConfirm < 6 then
		showToast(self,"确认栏密码必须大于6个字符，请重新输入！",2)
		return
	end

	if szPass ~= szPassConfirm then
		showToast(self,"设置栏和确认栏的密码不相同，请重新输入！",2)
        return
	end

    -- 与帐号不同
    if string.lower(szPass) == string.lower(GlobalUserItem.szAccount) then
        showToast(self,"密码不能与帐号相同，请重新输入！",2)
        return
    end

    -- 银行不同登陆
    if string.lower(szPass) == string.lower(GlobalUserItem.szPassword) then
        showToast(self, "银行密码不能与登录密码一致!", 2)
        return
    end

    --[[-- 首位为字母
    if 1 ~= string.find(szPass, "%a") then
        showToast(self,"密码首位必须为字母，请重新输入！",2)
        return
    end]]

	self:showPopWait()
	self._bankFrame:onEnableBank(szPass)
end

--取款操作
function BankLayer:onTakeScore()

	--[[
	if GlobalUserItem.cbInsureEnabled==0 then
		self._notifyLayer:setVisible(true)
		return
	end
	--]]

	--参数判断
	local szScore =  string.gsub(self.edit_Score:getText(),"([^0-9])","")
    szScore = string.gsub(szScore, "[.]", "")
	local szPass = self.edit_Password:getText()
    if #szScore < 1 then
        showToast(self,"请输入操作金额！",2)
        return
    end

	local lOperateScore = tonumber(szScore)
	if lOperateScore < 1 then
		showToast(self,"请输入正确金额！",2)
		return
	end

    if lOperateScore > GlobalUserItem.lUserInsure then
        showToast(self,"您银行游戏币的数目余额不足,请重新输入游戏币数量！",2)
        return
    end

	if #szPass < 1 then
		showToast(self,"请输入银行密码！",2)
		return
	end
	if #szPass <6 then
		showToast(self,"密码必须大于6个字符，请重新输入！",2)
		return
	end

	self:showPopWait()
	self._bankFrame:onTakeScore(lOperateScore,szPass)
end

--存款
function BankLayer:onSaveScore()
	--[[
	if GlobalUserItem.cbInsureEnabled==0 then
		self._notifyLayer:setVisible(true)
		return
	end
	--]]

	--参数判断
	local szScore =  string.gsub(self.edit_Score:getText(),"([^0-9])","")
    szScore = string.gsub(szScore, "[.]", "")
	if #szScore < 1 then
		showToast(self,"请输入操作金额！",2)
		return
	end

	local lOperateScore = tonumber(szScore)

	if lOperateScore<1 then
		showToast(self,"请输入正确金额！",2)
		return
	end

    if lOperateScore > GlobalUserItem.lUserScore then
        showToast(self,"您所携带游戏币的数目余额不足,请重新输入游戏币数量!",2)
        return
    end

	self:showPopWait()

	self._bankFrame:onSaveScore(lOperateScore)
end

--全部存入
function BankLayer:onAllSave()
print("GlobalUserItem.lUserScore",GlobalUserItem.lUserScore)
	self:showPopWait()

	self._bankFrame:onSaveScore(GlobalUserItem.lUserScore)
end

--修改密码
function BankLayer:onModifyPassword()
	print("修改密码")
	--参数判断
	local oldPassword =  string.gsub(self._modifypassword:getChildByName("edit_AreaOldPassword"):getText(),"([^0-9])","")
    oldPassword = string.gsub(oldPassword, "[.]", "")
	if #oldPassword < 1 then
		showToast(self,"请输入旧密码！",2)
		return
	end
	local newPassword =  string.gsub(self._modifypassword:getChildByName("edit_AreaNewPassword"):getText(),"([^0-9])","")
    newPassword = string.gsub(newPassword, "[.]", "")
	if #newPassword < 1 then
		showToast(self,"请输入新密码！",2)
		return
	end
	local qrPassword =  string.gsub(self._modifypassword:getChildByName("edit_AreaQRPassword"):getText(),"([^0-9])","")
    qrPassword = string.gsub(qrPassword, "[.]", "")
	if #qrPassword < 1 then
		showToast(self,"请输入再次输入新密码！",2)
		return
	end
	if #oldPassword <6 or #newPassword <6 or #qrPassword <6 then
		showToast(self,"密码必须大于6个字符，请重新输入！",2)
		return
	end
	if newPassword ~= qrPassword then
		showToast(self,"两次密码输入不一致！",2)
		return
	end
print("mima ",oldPassword,newPassword,qrPassword)
	self._modifyFrame:onModifyBankPass(oldPassword, newPassword)
end

--	银行回调
function BankLayer:onModifyCallBack( result, tips )
	if type(tips) == "string" and "" ~= tips then
		showToast(self, tips, 2)
	end

	if -1 ~= result then
		self:clearEdit()
	end
end

--金币赠送
function BankLayer:onSendGlod()
	print("金币赠送")
	print("GlobalUserItem.cbMemberOrder",GlobalUserItem.cbMemberOrder)
	--[[
	if GlobalUserItem.cbInsureEnabled==0 then
		self._notifyLayer:setVisible(true)
		return
	end
	--]]

	--参数判断
	local szTarget = self._transferArea:getChildByName("edit_transferAreaID"):getText()
	local szScore = self._transferArea:getChildByName("edit_transferAreaJE"):getText()
	local szPass =  string.gsub(self._transferArea:getChildByName("edit_transferAreaPassword"):getText(),"([^0-9])","")
	local byID = 1--self.cbt_TransferByID:isSelected() and 1 or 0;
	if #szTarget < 1 then
		showToast(self,"请输入赠送用户ID！",2)
		return
	end

	if #szScore < 1 then
		showToast(self,"请输入操作金额！",2)
		return
	end

	local lOperateScore = tonumber(szScore)
	if lOperateScore<1 then
		showToast(self,"请输入正确金额！",2)
		return
	end

	if #szPass < 1 then
		showToast(self,"请输入钱包密码！",2)
		return
	end
	if #szPass <6 then
		showToast(self,"密码必须大于6个字符，请重新输入！",2)
		return
	end

    if GlobalUserItem.cbMemberOrder < 0  then
        showToast(self,"成为VIP会员可享受该功能！",3)
		return
    end

	self:showPopWait()
	self._bankFrame:onTransferScore(lOperateScore,szTarget,szPass,byID)
end

function BankLayer:clearEdit()
	self._modifypassword:getChildByName("edit_AreaOldPassword"):setText("")
	self._modifypassword:getChildByName("edit_AreaNewPassword"):setText("")
	self._modifypassword:getChildByName("edit_AreaQRPassword"):setText("")
end

--操作结果
function BankLayer:onBankCallBack(result,message)
	print("================操作结果 result",result)

	self:dismissPopWait()
	if  message ~= nil and message ~= "" then
		showToast(self._scene,message,2)
	end

	if result == 2 then
		if GlobalUserItem.cbInsureEnabled~=0 then
            self:ShowMainBankUI(true)
			showToast(self,"银行开通成功！",2)
            if nil ~= self._enableLayer then
                self._enableLayer:runAction(cc.MoveTo:create(0.3,cc.p(yl.WIDTH,0)))
            end
            self:showPopWait()
            self._bankFrame:sendGetBankInfo()
		end
	end

    if result == BankFrame.OP_ENABLE_BANK_GAME then
        self:ShowMainBankUI(true)
        showToast(self,"银行开通成功！",2)
        if nil ~= self._enableLayer then
            self._enableLayer:runAction(cc.MoveTo:create(0.3,cc.p(yl.WIDTH,0)))
        end
        self:showPopWait()
        self._bankFrame:onGetBankInfo()
    end

	if result == 1 then
		self._txtScore:setString(string.formatNumberThousands(GlobalUserItem.lUserScore,true,","))
		self._txtInsure:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,","))
		self._transferArea:getChildByName("edit_transferAreaID"):setText("")
		self._transferArea:getChildByName("edit_transferAreaJE"):setText("")
		self._transferArea:getChildByName("edit_transferAreaPassword"):setText("")
		self.edit_Score:setText("")
		self.edit_Password:setText("")
		self.m_textNumber:setString("")
		self.m_textNumberJB:setString("")
		--更新大厅
		self:getParent():getParent()._gold:setString(string.formatNumberThousands(GlobalUserItem.lUserScore,true,"/"))
print("转账 ",self._bankFrame._oprateCode,BankFrame.OP_SEND_SCORE)
        if self._bankFrame._oprateCode == BankFrame.OP_SEND_SCORE then
            -- 转账凭证
            self:showCerLayer(self._bankFrame._tabTarget)
        end
	end

	if result == self._bankFrame.OP_GET_BANKINFO then

print("self._bankFrame.OP_GET_BANKINFO " .. message.cbEnjoinTransfer .. "!")
local enableTransfer = (1 == message.cbEnjoinTransfer)
        self.m_tabBankConfigInfo = message
		--取款收费比例
		local str = string.format("提示:存入游戏币免手续费,取出将扣除%d‰的手续费。存款无需输入银行密码。", message.wRevenueTake)
        self._notifyText:setString(str)

        self._txtInsure:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,","))
        self._txtScore:setString(string.formatNumberThousands(GlobalUserItem.lUserScore,true,","))
	end
end

--显示等待
function BankLayer:showPopWait()
	self._scene:showPopWait()
end

--关闭等待
function BankLayer:dismissPopWait()
	self._scene:dismissPopWait()
end

function BankLayer:onEnterTransitionFinish( )
    if 1 == GlobalUserItem.cbInsureEnabled then
        self:showPopWait()
        self._bankFrame:onGetBankInfo()
    end
end

function BankLayer:onExit()
    if self._bankFrame:isSocketServer() then
        self._bankFrame:onCloseSocket()
    end
    if nil ~= self._bankFrame._gameFrame then
        self._bankFrame._gameFrame._shotFrame = nil
        self._bankFrame._gameFrame = nil
    end

	--银行 修改密码
	if self._modifyFrame:isSocketServer() then
		self._modifyFrame:onCloseSocket()
	end
end

local TAG_MASK = 101
local BTN_SHARE = 102
local BTN_SAVEPIC = 103
-- 显示凭证
function BankLayer:showCerLayer( tabData )
    if type(tabData) ~= "table" then
        return
    end
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("Bank/BankCerLayer.csb", self)
    local stamp = tabData.opTime or os.time()

    local hide = function()
        local scale1 = cc.ScaleTo:create(0.2, 0.0001)
        local call1 = cc.CallFunc:create(function()
            rootLayer:removeFromParent()
        end)
        csbNode.m_imageBg:runAction(cc.Sequence:create(scale1, call1))
    end
    local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
    -- 截图分享
    local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local area = cc.rect(0, 0, framesize.width, framesize.height)

    local touchFunC = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            local tag = ref:getTag()
            if TAG_MASK == tag then
                hide()
            elseif BTN_SHARE == tag then
                ExternalFun.popupTouchFilter(0, false)
                captureScreenWithArea(area, "ce_code.png", function(ok, savepath)
                    ExternalFun.dismissTouchFilter()
                    if ok then
                        MultiPlatform:getInstance():customShare(function(isok)
                                    end, "转账凭证", "分享我的转账凭证", url, savepath, "true")
                    end
                end)
            elseif BTN_SAVEPIC == tag then
                ExternalFun.popupTouchFilter(0, false)
                captureScreenWithArea(area, "ce_code.png", function(ok, savepath)
                    if ok then
                        if true == MultiPlatform:getInstance():saveImgToSystemGallery(savepath, stamp .. "ce_code.png") then
                            showToast(self, "您的转账凭证图片已保存至系统相册", 1)
                        end
                    end
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
                        ExternalFun.dismissTouchFilter()
                    end)))
                end)
            end
        end
    end

    -- 遮罩
    local mask = csbNode:getChildByName("panel_mask")
    mask:setTag(TAG_MASK)
    mask:addTouchEventListener( touchFunC )

    -- 底板
    local image_bg = csbNode:getChildByName("image_bg")
    image_bg:setTouchEnabled(true)
    image_bg:setSwallowTouches(true)
    image_bg:setScale(0.00001)
    csbNode.m_imageBg = image_bg

    -- 赠送人昵称
    local sendnick = ClipText:createClipText(cc.size(210, 30), GlobalUserItem.szNickName, nil, 30)
    sendnick:setTextColor(cc.c3b(79, 212, 253))
    sendnick:setAnchorPoint(cc.p(0, 0.5))
    sendnick:setPosition(cc.p(260, 507))
    image_bg:addChild(sendnick)

    -- 赠送人ID
    local sendid = image_bg:getChildByName("txt_senduid")
    sendid:setString(GlobalUserItem.dwGameID .. "")

    -- 接收人昵称
    local recnick = ClipText:createClipText(cc.size(210, 30), tabData.opTargetAcconts or "", nil, 30)
    recnick:setTextColor(cc.c3b(79, 212, 253))
    recnick:setAnchorPoint(cc.p(0, 0.5))
    recnick:setPosition(cc.p(810, 507))
    image_bg:addChild(recnick)

    -- 接收人ID
    local recid = image_bg:getChildByName("txt_recuid")
    local reuid = tabData.opTargetID or 0
    recid:setString(reuid .. "")

    -- 赠送游戏币
    local sendcount = image_bg:getChildByName("atlas_sendnum")
    local count = tabData.opScore or 0
    sendcount:setString("" .. count)

    -- 大写
    local szcount = image_bg:getChildByName("txt_sendnum")
    local szstr = ""
    if count < 9999999999999 then
        szstr = ExternalFun.numberTransiform(count)
    end
    szcount:setString(szstr)

    -- 日期
    local txtdate = image_bg:getChildByName("txt_date")
    local tt = os.date("*t", stamp)
    txtdate:setString(string.format("%d.%02d.%02d-%02d:%02d:%02d", tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec))

    -- 凭证
    local cer = image_bg:getChildByName("txt_cerno")
    cer:setString(md5(stamp))

    -- 分享
    local btnBg = image_bg:getChildByName("Image_3")
    btnBg:setPosition(cc.p(340, 70))
    local btn = image_bg:getChildByName("btn_share")
    btn:setTag(BTN_SHARE)
    btn:setPosition(cc.p(340, 70))
    btn:addTouchEventListener( touchFunC )

    -- 保存
    local btnBg = image_bg:getChildByName("Image_4")
    btnBg:setPosition(cc.p(727, 70))
    btn = image_bg:getChildByName("btn_save")
    btn:setTag(BTN_SAVEPIC)
    btn:setPosition(cc.p(727,70))
    btn:addTouchEventListener( touchFunC )

    -- 加载动画
    image_bg:runAction(cc.ScaleTo:create(0.2, 1.0))
end

return BankLayer
