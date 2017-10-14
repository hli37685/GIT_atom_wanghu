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

	--显示背景
--	display.newSprite("Option/bg_option.png")
--		:move(yl.WIDTH/2,yl.HEIGHT/2)
--		:addTo(self)
    
    self.MainUI_spriteMainBg = cc.Scale9Sprite:create("public/dialogframe.png")
    self.MainUI_spriteMainBg:setCapInsets(CCRectMake(311,184,20,26))
    self.MainUI_spriteMainBg:setContentSize(cc.size(900, 560))
    self.MainUI_spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(self.MainUI_spriteMainBg)

    self.MainUIs[#self.MainUIs+1] = self.MainUI_spriteMainBg

	--上方背景
--    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_top_bg.png")
--    if nil ~= frame then
--        local sp = cc.Sprite:createWithSpriteFrame(frame)
--        sp:setPosition(yl.WIDTH/2,yl.HEIGHT-51)
--        self:addChild(sp)
--    end
	--标题
	self.MainUI_title = display.newSprite("Option/title_option.png")
		:move(areaWidth/2,yl.HEIGHT-130)
		:addTo(self)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_title
	--返回
	ccui.Button:create("public/closebtn.png","public/closebtn.png")
    	:move(1100,yl.HEIGHT-155)
    	:setTag(OptionLayer.BT_EXIT)
    	:addTo(self)
    	:addTouchEventListener(btcallback)
    self.MainUI_returnBtn = self:getChildByTag(OptionLayer.BT_EXIT)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_returnBtn

	--音效开关
    self.MainUI_spriteItemBg1 = cc.Scale9Sprite:create("public/dialogcontentbg.png")
    self.MainUI_spriteItemBg1:setCapInsets(CCRectMake(40,40,42,42))
    self.MainUI_spriteItemBg1:setContentSize(cc.size(800, 140))
    self.MainUI_spriteItemBg1:setPosition(yl.WIDTH/2, yl.HEIGHT-260)
    self:addChild(self.MainUI_spriteItemBg1)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_spriteItemBg1
    local itemBgSize = self.MainUI_spriteItemBg1:getContentSize()

--	display.newSprite("Option/frame_option_0.png")
--		:move(1000,510)
--		:addTo(self)
	display.newSprite("Option/text_sound.png")
		:move(120, itemBgSize.height/2)
		:addTo(self.MainUI_spriteItemBg1)
	self._cbtSilence = ccui.CheckBox:create("Option/bt_option_switch_0.png","","Option/bt_option_switch_1.png","","")
		:move(300, itemBgSize.height/2)
		:setSelected(GlobalUserItem.bSoundAble)
		:addTo(self.MainUI_spriteItemBg1)
		:setTag(self.CBT_SOUND)
	self._cbtSilence:addEventListener(cbtlistener)

	--音乐开关
--	display.newSprite("Option/frame_option_0.png")
--		:move(330,510)
--		:addTo(self)
	display.newSprite("Option/text_music.png")
		:move(520, itemBgSize.height/2)
		:addTo(self.MainUI_spriteItemBg1)
	self._cbtSound = ccui.CheckBox:create("Option/bt_option_switch_0.png","","Option/bt_option_switch_1.png","","")
		:move(700, itemBgSize.height/2)
		:setSelected(GlobalUserItem.bVoiceAble)
		:addTo(self.MainUI_spriteItemBg1)
		:setTag(self.CBT_SILENCE)
	self._cbtSound:addEventListener(cbtlistener)

	--常见问题
    self.MainUI_spriteItemBg2 = cc.Scale9Sprite:create("public/dialogcontentbg.png")
    self.MainUI_spriteItemBg2:setCapInsets(CCRectMake(40,40,42,42))
    self.MainUI_spriteItemBg2:setContentSize(cc.size(800, 140))
    self.MainUI_spriteItemBg2:setPosition(yl.WIDTH/2, yl.HEIGHT-260-150)
    self:addChild(self.MainUI_spriteItemBg2)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_spriteItemBg2

    local cjwtBg = display.newSprite("Option/cjwtbtnbg.png")
		:move(200, itemBgSize.height/2)
        :setVisible(false)
		:addTo(self.MainUI_spriteItemBg2)
    local newBtnSize = cjwtBg:getContentSize()
	ccui.Button:create("Option/cjwt.png","Option/cjwt.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(OptionLayer.BT_QUESTION)
		:addTo(cjwtBg)
		:addTouchEventListener(btcallback)

	--游戏反馈
	local yxfkBg = display.newSprite("Option/yxfkbtn.png")
		:move(600, itemBgSize.height/2)
        :setVisible(false)
		:addTo(self.MainUI_spriteItemBg2)
	ccui.Button:create("Option/yxfk.png","Option/yxfk.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(OptionLayer.BT_COMMIT)
		:addTo(yxfkBg)
		:addTouchEventListener(btcallback)
	
	--帐号信息
    self.MainUI_spriteItemBg3 = cc.Scale9Sprite:create("public/dialogcontentbg.png")
    self.MainUI_spriteItemBg3:setCapInsets(CCRectMake(40,40,42,42))
    self.MainUI_spriteItemBg3:setContentSize(cc.size(800, 140))
    self.MainUI_spriteItemBg3:setPosition(yl.WIDTH/2, yl.HEIGHT-260-150 - 150)
    self:addChild(self.MainUI_spriteItemBg3)
    self.MainUIs[#self.MainUIs+1] = self.MainUI_spriteItemBg3

--	锁定帐号
    local lockTag = nil
    if 1 == GlobalUserItem.cbLockMachine then
        lockTag = OptionLayer.BT_UNLOCK
    else
        lockTag = OptionLayer.BT_LOCK
    end
    local sdzhBg = display.newSprite("Option/yellowbtn.png")
--		:move(130, itemBgSize.height/2)
--		:addTo(self.MainUI_spriteItemBg3)
        :move(200, itemBgSize.height/2)
        :addTo(self.MainUI_spriteItemBg2)
    ccui.Button:create("Option/suodingbtn.png","Option/suodingbtn.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
        :setTag(lockTag)
		:addTo(sdzhBg)
		:addTouchEventListener(btcallback)
    self.m_btnLock = sdzhBg:getChildByTag(lockTag)

    --修改密码
    local xgmmBg = display.newSprite("Option/xgmmbtn.png")
--		:move(400, itemBgSize.height/2)
--		:addTo(self.MainUI_spriteItemBg3)
        :move(600, itemBgSize.height/2)
        :addTo(self.MainUI_spriteItemBg2)
    ccui.Button:create("Option/xgmm.png","Option/xgmm.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(OptionLayer.BT_MODIFY)
		:addTo(xgmmBg)
		:addTouchEventListener(btcallback)

    -- 当前账号信息
	display.newSprite("Option/text_account.png")
		:move(160, itemBgSize.height/2)
		:addTo(self.MainUI_spriteItemBg3)

	local testen = cc.Label:createWithSystemFont("A","Arial", 24)
    self._enSize = testen:getContentSize().width
    local testcn = cc.Label:createWithSystemFont("游","Arial", 24)
    self._cnSize = testcn:getContentSize().width
	self._nickname = cc.Label:createWithTTF(string.stringEllipsis(GlobalUserItem.szNickName,self._enSize,self._cnSize,200), "fonts/round_body.ttf", 24)
        :move(360, itemBgSize.height/2)
        :setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        :setAnchorPoint(cc.p(0.5,0.5))
       	:setWidth(210)
       	:setHeight(25)
       	:setLineBreakWithoutSpace(false)
       	:setTextColor(cc.c4b(240,240,240,255))
       	:addTo(self.MainUI_spriteItemBg3)

	--切换帐号
    local qhzhBg = display.newSprite("Option/qhzhbtn.png")
--		:move(670, itemBgSize.height/2)
        :move(600, itemBgSize.height/2)
		:addTo(self.MainUI_spriteItemBg3)
    ccui.Button:create("Option/qhzh.png","Option/qhzh.png")
		:move(newBtnSize.width/2, newBtnSize.height/2)
		:setTag(OptionLayer.BT_EXCHANGE)
		:addTo(qhzhBg)
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
        self:ShowMainBankUI(false)
        self:showLockMachineLayer(self)
    elseif tag == OptionLayer.BT_UNLOCK then
        print("解锁机器")
        self:ShowMainBankUI(false)
        self:showLockMachineLayer(self)
	end
end

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
    local editbox = ccui.EditBox:create(cc.size(tmp:getContentSize().width - 10, tmp:getContentSize().height - 10),"blank.png",UI_TEX_TYPE_PLIST)
        :setPosition(tmp:getPosition())
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(30)
        :setPlaceholderFontSize(30)
        :setMaxLength(32)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入密码")
    image_bg:addChild(editbox)
    csbNode.m_editbox = editbox

    -- 锁定/解锁
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

    btn = image_bg:getChildByName("btn_cancel")
    btn:setTag(BTN_CLOSE)
    btn:addTouchEventListener( touchFunC )

    -- 关闭
    btn = image_bg:getChildByName("btn_close")
    btn:setTag(BTN_CLOSE)
    btn:addTouchEventListener( touchFunC )
end

function OptionLayer:onModifyCallBack(result, tips)
    if type(tips) == "string" and "" ~= tips then
        showToast(self, tips, 2)
    end 

    local normal = "Option/suodingbtn.png"
    local disable = "Option/suodingbtn.png"
    local press = "Option/suodingbtn.png"
    if self._modifyFrame.BIND_MACHINE == result then
        if 0 == GlobalUserItem.cbLockMachine then
            GlobalUserItem.cbLockMachine = 1
            self.m_btnLock:setTag(OptionLayer.BT_UNLOCK)
            normal = "Option/unlockbtn.png"
            disable = "Option/unlockbtn.png"
            press = "Option/unlockbtn.png"
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