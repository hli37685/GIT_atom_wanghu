--[[
	设置界面
	2015_12_03 C.P
	功能：音乐音量震动等
]]

local OptionLayer = class("OptionLayer", function(scene)
		local optionLayer = display.newLayer(cc.c4b(0, 0, 0, 125))
    return optionLayer
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local WebViewLayer = appdf.CLIENT_SRC .. "plaza.views.layer.plaza.WebViewLayer"
appdf.req(appdf.CLIENT_SRC.."plaza.models.FriendMgr")
local NotifyMgr = appdf.req(appdf.EXTERNAL_SRC .. "NotifyMgr")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

OptionLayer.CBT_SILENCE 	= 1
OptionLayer.CBT_SOUND   	= 2
OptionLayer.BT_EXIT			= 7

OptionLayer.BT_QUESTION		= 8
OptionLayer.BT_COMMIT		= 9
OptionLayer.BT_MODIFY		= 10
OptionLayer.BT_EXCHANGE		= 11
OptionLayer.BT_LOCK         = 12
OptionLayer.BT_UNLOCK       = 13

OptionLayer.PRO_WIDTH		= yl.WIDTH

function OptionLayer:ctor(scene)
	
	--区域外屏蔽点击
	local  onShield = function(eventType, x, y)
    	return true
    end
	self:setTouchEnabled(true)
    self:registerScriptTouchHandler(onShield)
    
	self._scene = scene
	self:setContentSize(yl.WIDTH,yl.HEIGHT)
	local this = self
    self.MainUIs = {}


    local cbtlistener = function (sender,eventType)
    	this:onSelectedEvent(sender:getTag(),sender,eventType)
    end
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	local areaWidth = yl.WIDTH
	local areaHeight = yl.HEIGHT
    
    self.MainUI_spriteMainBg = cc.Scale9Sprite:create("Option/dialogframe-1.png")
    --self.MainUI_spriteMainBg:setCapInsets(CCRectMake(311,184,20,26))
    --self.MainUI_spriteMainBg:setContentSize(cc.size(900, 560))
    self.MainUI_spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    local BgSize = self.MainUI_spriteMainBg:getContentSize()
    self:addChild(self.MainUI_spriteMainBg)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_spriteMainBg

	--标题
	self.MainUI_title = display.newSprite("Option/title_option.png")
		:move(yl.WIDTH/2,yl.HEIGHT-65)
		:addTo(self)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_title

	--返回
	ccui.Button:create("Option/closebtn-1.png","Option/closebtn-1.png")
    	:move(60,yl.HEIGHT-60)
    	:setTag(OptionLayer.BT_EXIT)
    	:addTo(self)
    	:addTouchEventListener(btcallback)
    self.MainUI_returnBtn = self:getChildByTag(OptionLayer.BT_EXIT)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_returnBtn

    --[[
        第一分区
    --]]

    -- 当前账号信息
    --[[
	local testen = cc.Label:createWithSystemFont("A","Arial", 28)
    self._enSize = testen:getContentSize().width
    local testcn = cc.Label:createWithSystemFont("游","Arial", 28)
    self._cnSize = testcn:getContentSize().width
	self._nickname = cc.Label:createWithTTF("玩家信息：", "fonts/round_body.ttf", 32)
        :move(170, BgSize.height-100)
        :setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        :setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        :setAnchorPoint(cc.p(1,0.5))
       	:setWidth(200)
       	:setHeight(30)
       	:setLineBreakWithoutSpace(false)
		:setTextColor(cc.c4b(146,215,255,255))
       	:addTo(self.MainUI_spriteMainBg)
	self._nickname = cc.Label:createWithTTF("昵称", "fonts/round_body.ttf", 28)
        :move(180, BgSize.height-140)
        :setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        :setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        :setAnchorPoint(cc.p(1,0.5))
       	:setWidth(200)
       	:setHeight(30)
       	:setLineBreakWithoutSpace(false)
       	:setTextColor(cc.c4b(240,240,240,255))
       	:addTo(self.MainUI_spriteMainBg)
	self._nickname = cc.Label:createWithTTF(string.stringEllipsis(GlobalUserItem.szNickName,self._enSize,self._cnSize,300), "fonts/round_body.ttf", 28)
        :move(190, BgSize.height-140)
        :setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        :setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        :setAnchorPoint(cc.p(0,0.5))
       	:setWidth(280)
       	:setHeight(30)
       	:setLineBreakWithoutSpace(false)
       	:setTextColor(cc.c4b(240,240,240,255))
       	:addTo(self.MainUI_spriteMainBg)
    --]]      

    --音乐
	display.newSprite("Option/text_music.png")
		:move(yl.WIDTH/2-300, BgSize.height-190)
		:addTo(self.MainUI_spriteMainBg)
	self._cbtSound = ccui.CheckBox:create("Option/bt_option_switch_0.png","","Option/bt_option_switch_1.png","","")
		:move(yl.WIDTH/2-150, BgSize.height-190)
		:setSelected(GlobalUserItem.bVoiceAble)
		:addTo(self.MainUI_spriteMainBg)
		:setTag(self.CBT_SILENCE)
	self._cbtSound:addEventListener(cbtlistener)

    --音效
	display.newSprite("Option/text_sound.png")
		:move(yl.WIDTH/2+90, BgSize.height-190)
		:addTo(self.MainUI_spriteMainBg)
	self._cbtSilence = ccui.CheckBox:create("Option/bt_option_switch_0.png","","Option/bt_option_switch_1.png","","")
		:move(yl.WIDTH/2+240, BgSize.height-190)
		:setSelected(GlobalUserItem.bSoundAble)
		:addTo(self.MainUI_spriteMainBg)
		:setTag(self.CBT_SOUND)
	self._cbtSilence:addEventListener(cbtlistener)

    --[[
        第二分区
    --]]
    
    --内容框背景
    
    local frame=cc.Scale9Sprite:create("Option/frame-1.png")
        :setCapInsets(CCRectMake(30,30,116,134))
        :setContentSize(cc.size(900, 150))
		:move(BgSize.width/2,BgSize.height/2-20)
		:addTo(self.MainUI_spriteMainBg)

    --头像
    local head = ccui.ImageView:create("Lobby/tx1.png")
                :move(BgSize.width/2-400, BgSize.height-400)
                :addTo(self.MainUI_spriteMainBg)

    bGender = (GlobalUserItem.cbGender == yl.GENDER_MANKIND and true or false)
	local _personInfo="Lobby/tx1.png"
	if bGender then
		_personInfo="Lobby/tx1.png"
	else
		_personInfo="Lobby/tx2.png"
	end
    head:loadTexture(_personInfo)

    --玩家昵称
    local testen = cc.Label:createWithSystemFont("A","fonts/round_body.ttf", 30)
    self._enSize = testen:getContentSize().width
    local testcn = cc.Label:createWithSystemFont("游","fonts/round_body.ttf", 30)
    self._cnSize = testcn:getContentSize().width

    local mNick=cc.Label:createWithSystemFont("当前账号：","fonts/round_body.ttf", 30)
            :move(BgSize.width/2-230, BgSize.height-400)
            :addTo(self.MainUI_spriteMainBg)

    --账号
    local nickname = string.stringEllipsis(GlobalUserItem.szAccount,self._enSize,self._cnSize,300)
    local mNick=cc.Label:createWithSystemFont("","fonts/round_body.ttf", 30)
            :setAnchorPoint(cc.p(0,0.5))
            :move(BgSize.width/2-150, BgSize.height-400)
            :addTo(self.MainUI_spriteMainBg)
    mNick:setString(nickname)

        --切换帐号
    local xgmmBg = display.newSprite("Option/huangbtn.png")
		:move(yl.WIDTH/2+300, BgSize.height-400)
        :addTo(self.MainUI_spriteMainBg)
    local xgmmBgSize = xgmmBg:getContentSize()
    ccui.Button:create("Option/qhzh.png","Option/qhzh.png")
		:move(xgmmBgSize.width/2, xgmmBgSize.height/2+5)
		:setTag(OptionLayer.BT_EXCHANGE)
		:addTo(xgmmBg)
		:addTouchEventListener(btcallback)  
        
    --锁定帐号
    local lockTag = nil
    if 1 == GlobalUserItem.cbLockMachine then
        lockTag = OptionLayer.BT_UNLOCK 
    else
        lockTag = OptionLayer.BT_LOCK
    end
    local sdzhBg = display.newSprite("Option/lanlvbtn.png")
        :move(BgSize.width/2-170, BgSize.height-560)
        :addTo(self.MainUI_spriteMainBg)
    local sdzhBgSize = sdzhBg:getContentSize()
    ccui.Button:create("Option/suoding.png","Option/suoding.png")
		:move(sdzhBgSize.width/2, sdzhBgSize.height/2+3)
        :setTag(lockTag)
		:addTo(sdzhBg)
		:addTouchEventListener(btcallback)
    self.m_btnLock = sdzhBg:getChildByTag(lockTag)    
    local normal = "Option/suoding.png"
    local disable = "Option/suoding.png"
    local press = "Option/suoding.png"
    if 1 == GlobalUserItem.cbLockMachine then
        normal = "Option/unlock.png"
        disable = "Option/unlock.png"
        press = "Option/unlock.png"
    end
    self.m_btnLock:loadTextureDisabled(disable)
    self.m_btnLock:loadTextureNormal(normal)
    self.m_btnLock:loadTexturePressed(press)

    --修改密码
    local sdzhBg = display.newSprite("Option/lanlvbtn.png")
        :move(BgSize.width/2+170, BgSize.height-560)
        :addTo(self.MainUI_spriteMainBg)
    local sdzhBgSize = sdzhBg:getContentSize()
    ccui.Button:create("Option/xiugaimm.png","Option/xiugaimm.png")
		:move(sdzhBgSize.width/2, sdzhBgSize.height/2+3)
        :addTo(sdzhBg)
        :setTag(OptionLayer.BT_MODIFY)
		:addTouchEventListener(btcallback)

--    -- 锁定
--    if 1 == GlobalUserItem.cbLockMachine then
--        self.m_btnLock = ccui.Button:create("Option/btn_unlockmachine_0.png","Option/btn_unlockmachine_1.png","Option/btn_unlockmachine_0.png")
--        self.m_btnLock:setTag(OptionLayer.BT_UNLOCK)
--    else
--        self.m_btnLock = ccui.Button:create("Option/btn_lockmachine_0.png","Option/btn_lockmachine_1.png","Option/btn_lockmachine_0.png")
--        self.m_btnLock:setTag(OptionLayer.BT_LOCK)
--    end    
--    self.m_btnLock:move(631,166)        
--        :addTo(self)
--        :addTouchEventListener(btcallback)

--    local mgr = self._scene:getApp():getVersionMgr()
--    local verstr = mgr:getResVersion() or "0"
--    -- 版本号
--    cc.Label:createWithTTF("版本号:" .. appdf.BASE_C_VERSION .. "." .. verstr, "fonts/round_body.ttf", 24)
--        :move(yl.WIDTH,0)
--        :setAnchorPoint(cc.p(1,0))
--        :addTo(self)
end

function OptionLayer:ShowMainBankUI(bShow)
    for v,k in pairs(self.MainUIs) do
        k:setVisible(bShow)
    end
end

function OptionLayer:onSelectedEvent(tag,sender,eventType)
	if tag == OptionLayer.CBT_SILENCE then
		GlobalUserItem.setVoiceAble(eventType == 0)
		--背景音乐
        ExternalFun.playPlazzBackgroudAudio()
	elseif tag == OptionLayer.CBT_SOUND then
		GlobalUserItem.setSoundAble(eventType == 0)
	end
end

--按键监听
function OptionLayer:onButtonClickedEvent(tag,sender)
	if tag ~= OptionLayer.BT_EXCHANGE and tag ~= OptionLayer.BT_EXIT then
		if GlobalUserItem.isAngentAccount() then
			return
		end
	end	
	
	if tag == OptionLayer.BT_EXCHANGE then
        self._scene:ExitClient()
	elseif tag == OptionLayer.BT_EXIT then
		self._scene:onKeyBack()
	elseif tag == OptionLayer.BT_QUESTION then
		self._scene:onChangeShowMode(yl.SCENE_FAQ)
	elseif tag == OptionLayer.BT_MODIFY then
        if self._scene._gameFrame:isSocketServer() then
            showToast(self,"当前页面无法使用此功能！",1)
            return
        end
		self._scene:onChangeShowMode(yl.SCENE_MODIFY)
	elseif tag == OptionLayer.BT_COMMIT then
		self._scene:onChangeShowMode(yl.SCENE_FEEDBACK)
    elseif tag == OptionLayer.BT_LOCK then
        print("锁定机器")
        self:ShowMainBankUI(true)
        self:showLockMachineLayer(self)
    elseif tag == OptionLayer.BT_UNLOCK then
        print("解锁机器")
        self:ShowMainBankUI(true)
        self:showLockMachineLayer(self)
	end
end

---[[
local TAG_MASK = 101
local BTN_CLOSE = 102
function OptionLayer:showLockMachineLayer( parent )
    if nil == parent then
        return
    end
    --网络回调
    local modifyCallBack = function(result,message)
        self:onModifyCallBack(result,message)
    end
    --网络处理
    self._modifyFrame = ModifyFrame:create(self,modifyCallBack)

    -- 加载csb资源
    local csbNode = ExternalFun.loadCSB("Option/LockMachineLayer.csb", parent )

    local touchFunC = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            local tag = ref:getTag()
            if TAG_MASK == tag or BTN_CLOSE == tag then
                csbNode:removeFromParent()
                self:ShowMainBankUI(true)
            elseif OptionLayer.BT_LOCK == tag then
                local txt = csbNode.m_editbox:getText()
                if txt == "" then
                    showToast(self, "密码不能为空!", 2)
                    return 
                end
                self._modifyFrame:onBindingMachine(1, txt)
                self:ShowMainBankUI(true)
                csbNode:removeFromParent()
            elseif OptionLayer.BT_UNLOCK == tag then
                local txt = csbNode.m_editbox:getText()
                if txt == "" then
                    showToast(self, "密码不能为空!", 2)
                    return 
                end
                self._modifyFrame:onBindingMachine(0, txt)
                self:ShowMainBankUI(true)
                csbNode:removeFromParent()
            end
        end
    end

    -- 遮罩
    local mask = csbNode:getChildByName("panel_mask")
    mask:setTag(TAG_MASK)
 --   mask:addTouchEventListener( touchFunC )

    local image_bg = csbNode:getChildByName("image_bg")
 --   image_bg:setSwallowTouches(true)

    -- 输入
    local tmp = image_bg:getChildByName("sp_lockmachine_bankpw")
    local editbox = ccui.EditBox:create(cc.size(tmp:getContentSize().width -50, tmp:getContentSize().height - 10),"blank.png")
        :setPosition(tmp:getPositionX()+0,tmp:getPositionY())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(28)
        :setPlaceholderFontSize(28)
        :setMaxLength(32)
		:setPlaceholderFontColor(cc.c4b(102,100,101,255))
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入密码")
    image_bg:addChild(editbox)
    csbNode.m_editbox = editbox

    -- 锁定/解锁
print("====== GlobalUserItem.cbLockMachine",GlobalUserItem.cbLockMachine)
    local btn = image_bg:getChildByName("btn_lock")
    btn:setTag(OptionLayer.BT_LOCK)
    btn:addTouchEventListener( touchFunC )
    local normal = "Option/suodingbtn.png"
    local disable = "Option/suodingbtn.png"
    local press = "Option/suodingbtn.png"
    if 1 == GlobalUserItem.cbLockMachine then
        btn:setTag(OptionLayer.BT_UNLOCK)
        normal = "Option/unlockbtn.png"
        disable = "Option/unlockbtn.png"
        press = "Option/unlockbtn.png"
    end
    btn:loadTextureDisabled(disable)
    btn:loadTextureNormal(normal)
    btn:loadTexturePressed(press)  

    -- 关闭
    btn = image_bg:getChildByName("btn_close")
    btn:setTag(BTN_CLOSE)
    btn:addTouchEventListener( touchFunC )
end
--]]

function OptionLayer:onModifyCallBack(result, tips)
    if type(tips) == "string" and "" ~= tips then
        showToast(self, tips, 2)
    end 

    local normal = "Option/suoding.png"
    local disable = "Option/suoding.png"
    local press = "Option/suoding.png"
dump(result,"result",6)
dump(self._modifyFrame.BIND_MACHINE,"self._modifyFrame.BIND_MACHINE",6)
print("====== GlobalUserItem.cbLockMachine",GlobalUserItem.cbLockMachine)
    if self._modifyFrame.BIND_MACHINE == result then
        if 0 == GlobalUserItem.cbLockMachine then
            GlobalUserItem.cbLockMachine = 1
            self.m_btnLock:setTag(OptionLayer.BT_UNLOCK)
            normal = "Option/unlock.png"
            disable = "Option/unlock.png"
            press = "Option/unlock.png"
        else
            GlobalUserItem.cbLockMachine = 0
            self.m_btnLock:setTag(OptionLayer.BT_LOCK)
        end
    end   
    self.m_btnLock:loadTextureDisabled(disable)
    self.m_btnLock:loadTextureNormal(normal)
    self.m_btnLock:loadTexturePressed(press)
end

return OptionLayer