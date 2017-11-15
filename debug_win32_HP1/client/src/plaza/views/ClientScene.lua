--[[
	手游大厅界面
	2015_12_03 C.P
]]



local ClientScene = class("ClientScene", cc.load("mvc").ViewBase)

local PopWait = appdf.req(appdf.BASE_SRC.."app.views.layer.other.PopWait")

local Option = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.other.OptionLayer")

local GameListView	= appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.GameListLayer")

local RoomList = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RoomListLayer")

local UserInfo = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.UserInfoLayer")

local Bank = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BankLayer")

local RankingListInit = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RankingListInitLayer")

local RankingList = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RankingListLayer")

local Task = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.TaskLayer")

local EveryDay = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.EveryDayLayer")

local Checkin = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.CheckinLayer")

local CheckinFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.CheckinFrame")
local LevelFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.LevelFrame")

local TaskFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.TaskFrame")

local BankRecord = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BankRecordLayer")

local OrderRecord = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.OrderRecordLayer")

local Agent = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.AgentLayer")

local Shop = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")

local Bag = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BagLayer")

local BagDetail = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BagDetailLayer")

local BagTrans = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BagTransLayer")

local Binding = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BindingLayer")

local KeFuLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.KeFuLayer")

local BindPhoneLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BindPhoneLayer")

local Friend = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.friend.FriendLayer")

local ModifyPasswd = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.ModifyPasswdLayer")

local FeedbackLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.FeedbackLayer")

local FaqLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.FaqLayer")

local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")

local Room = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.room.RoomLayer")

local TrumpetSendLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.friend.TrumpetSendLayer")

local MessageListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.MessageListLayer")

local BindingRegisterLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.BindingRegisterLayer")

local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local NotifyMgr = appdf.req(appdf.EXTERNAL_SRC .. "NotifyMgr")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local chat_cmd = appdf.req(appdf.HEADER_SRC.."CMD_ChatServer")
local GameChatLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.game.GameChatLayer")


local QueryExit = appdf.req(appdf.BASE_SRC.."app.views.layer.other.QueryDialog")

ClientScene.BT_EXIT 		= 1
ClientScene.BT_CONFIG 		= 2
ClientScene.BT_USER 		= 3
ClientScene.BT_RECHARGE		= 4
ClientScene.BT_SHOP			= 6
ClientScene.BT_ACTIVITY		= 7
ClientScene.BT_RECORD		= 8
ClientScene.BT_BANK			= 9
ClientScene.BT_BAG			= 10
ClientScene.BT_FRIEND		= 11
ClientScene.BT_TASK			= 12
ClientScene.BT_RANK			= 13
ClientScene.BT_RANKINIT		= 101
ClientScene.BT_QUICKSTART	= 14
ClientScene.BT_EXCHANGE		= 15
ClientScene.BT_BOX			= 16
ClientScene.BT_CHECKIN		= 17
ClientScene.BT_TRUMPET		= 18
ClientScene.BT_PERSON		= 19
ClientScene.BT_KEFU         = 20
ClientScene.BT_GONGGAO      = 21--
ClientScene.BT_QDYL         = 23--
ClientScene.BT_QUIT 		= 100

ClientScene.DG_QUERYEXIT 	= 101


local HELP_LAYER_NAME = "__introduce_help_layer__"
local HELP_BTN_NAME = "__introduce_help_button__"
local VOICE_BTN_NAME = "__voice_record_button__"
local VOICE_LAYER_NAME = "__voice_record_layer__"
-- 进入场景而且过渡动画结束时候触发。
function ClientScene:onEnterTransitionFinish()
	if nil ~= self.m_touchFilter then
		self.m_touchFilter:dismiss()
		self.m_touchFilter = nil		
	end

	--根据会员等级确定裁剪资源
	local vipIdx = GlobalUserItem.cbMemberOrder or 0
	--裁切头像
    local head = HeadSprite:createNormal(GlobalUserItem, 62)
	if nil ~= head then
		head:setPosition(self._btPersonInfo:getPosition())
		self._headNick:addChild(head)
		self._head = head
	end

	--商城动画
    self.m_actShopAni = cc.CSLoader:createTimeline("Lobby/shop_2.csb")
	ExternalFun.SAFE_RETAIN(self.m_actShopAni)
	self._shop:stopAllActions()
	self.m_actShopAni:gotoFrameAndPlay(0,true)
	self._shop:runAction(self.m_actShopAni)

	--请求公告 切换页面中已经请求
	--self:requestNotice()

    return self
end

-- 退出场景而且开始过渡动画时候触发。
function ClientScene:onExitTransitionStart()
	self._sceneLayer:unregisterScriptKeypadHandler()

    return self
end

function ClientScene:onExit()
	if self._gameFrame:isSocketServer() then
		self._gameFrame:onCloseSocket()
	end
	self:disconnectFrame()	
    
	ExternalFun.SAFE_RELEASE(self.m_actShopAni)
	self.m_actShopAni = nil
	ExternalFun.SAFE_RELEASE(self.m_actBoxAni)
	self.m_actBoxAni = nil
	ExternalFun.SAFE_RELEASE(self.m_actStartBtnAni)
	self.m_actStartBtnAni = nil
	ExternalFun.SAFE_RELEASE(self.m_actChargeBtnAni)
	self.m_actChargeBtnAni = nil
	ExternalFun.SAFE_RELEASE(self.m_actCoinAni)
	self.m_actCoinAni = nil

	self:releasePublicRes()
	self:removeListener()

	self:unregisterNotify()		
	removebackgroundcallback()

	if PriRoom then
		PriRoom:getInstance():onExitPlaza()
	end			
	return self
end

-- 初始化界面
function ClientScene:onCreate()
	self.m_listener = nil
	self:cachePublicRes()
	self.m_actBoxAni = nil
	self.m_actShopAni = nil
	self.m_actStartBtnAni = nil
	self.m_actChargeBtnAni = nil
		
	local this = self
	--保存进入的游戏记录信息
	GlobalUserItem.m_tabEnterGame = nil
	--上一个场景
	self.m_nPreTag = nil
	--喇叭发送界面 改为 消息列表界面
	self.m_messagelistLayer = nil	
	GlobalUserItem.bHasLogon = true
	self._gameFrame = GameFrameEngine:create(self,function (code,result)
		this:onRoomCallBack(code,result)
	end)
	
	if PriRoom then
		PriRoom:getInstance():onEnterPlaza(self, self._gameFrame)
	end
	
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。			
			self:onEnterTransitionFinish()			
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		elseif eventType == "exit" then
			self:onExit()
		end
	end)

	--背景音乐
	ExternalFun.playPlazzBackgroudAudio()

    --
    -- 背景
    self._bg = ccui.ImageView:create("public/background_2.png")
        :move(display.center)
        :addTo(self)


	local btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	self._sceneRecord = {}

	self._sceneLayer = display.newLayer()
		:setContentSize(yl.WIDTH,yl.HEIGHT)
		:addTo(self)	

	--返回键事件
	self._sceneLayer:registerScriptKeypadHandler(function(event)
		if event == "backClicked" then
			 if this._popWait == nil then
			 	if #self._sceneRecord > 0 then
					local cur_layer =  this._sceneLayer:getChildByTag(self._sceneRecord[#self._sceneRecord])
					if cur_layer  and cur_layer.onKeyBack then
						if cur_layer:onKeyBack() == true then
							return
						end
					end
				end
				this:onKeyBack()
			end
		end
	end)
	self._sceneLayer:setKeyboardEnabled(true)


	self.m_touchFilter = PopWait:create()
			:show(self,"请稍候！")
	-- 定时关闭
	self.m_touchFilter:runAction(cc.Sequence:create(cc.DelayTime:create(3),
			cc.CallFunc:create(function()
				if nil ~= self.m_touchFilter then
					self.m_touchFilter:dismiss()
					self.m_touchFilter = nil
				end														

				-- 网络断开
				self:disconnectFrame()
			end)
			)
		)    
    
    -- 背景头部
    self._bg_top = ccui.ImageView:create("public/background_2-top.png")
		:setAnchorPoint(cc.p(0,1))
        :move(display.left_top)
        :addTo(self)
    -- 背景底部
    self._bg_bottom = ccui.ImageView:create("public/background_2-bot1.png")
		:setAnchorPoint(cc.p(0,0))
        :move(display.left_bottom)
        :addTo(self)

	--商城
	local shop = ExternalFun.loadCSB("Lobby/shop_2.csb", self)
	self._shop = shop
    --加载csb资源
    local rootLayer,csbNode = ExternalFun.loadRootCSB("Lobby/LobbyLayer.csb",self)
    self.m_plazaLayer = csbNode
 
	local headNick = csbNode:getChildByName("headNick")
	self._headNick = headNick

	--返回
	self._btExit = headNick:getChildByName("Btn_Back")
	self._btExit:setTag(ClientScene.BT_EXIT)
	self._btExit:addTouchEventListener(btcallback)

    --查看玩家信息
	self._btPersonInfo = headNick:getChildByName("Btn_Person")
	self._btPersonInfo:setTag(ClientScene.BT_PERSON)
	self._btPersonInfo:addTouchEventListener(btcallback)

    --玩家昵称
    local testen = cc.Label:createWithSystemFont("A","Arial", 24)
    self._enSize = testen:getContentSize().width
    local testcn = cc.Label:createWithSystemFont("游","Arial", 24)
    self._cnSize = testcn:getContentSize().width

    local nickname = string.stringEllipsis(GlobalUserItem.szNickName,self._enSize,self._cnSize,165)

    self.mNickname = headNick:getChildByName("Text_Nickname")
	self.mNickname:setString(nickname)

	----vip信息
   	self.mLevel = headNick:getChildByName("Img_LvNum")
	self.mLevel:setString("VIP "..GlobalUserItem.cbMemberOrder)

	local coinnum = csbNode:getChildByName("Image_coinnumbg")
	self._coinnum = coinnum

    --金币
    self._gold = coinnum:getChildByName("Text_Coin")
    self._gold:setColor(cc.c3b(250, 254, 149))
    local btn = coinnum:getChildByName("Btn_QuQian")
    btn:setTag(ClientScene.BT_BANK)
    btn:addTouchEventListener(btcallback)

	---[[
    --快速开始
	self._btKSKS = csbNode:getChildByName("Btn_QuickStart")
    self._btKSKS:setTag(ClientScene.BT_QUICKSTART)
    self._btKSKS:addTouchEventListener(btcallback)
	--]]

    --签到有礼
	self._btQDYL = csbNode:getChildByName("btn_qdyl")
    self._btQDYL:setTag(ClientScene.BT_QDYL)
    self._btQDYL:addTouchEventListener(btcallback)

    --设置
	self._btSetting = csbNode:getChildByName("Btn_Setting")
    self._btSetting:setTag(ClientScene.BT_CONFIG)
    self._btSetting:addTouchEventListener(btcallback)

    --广告框
	self._AdvFrame = csbNode:getChildByName("AdvFrame")


	local Btn_upper = csbNode:getChildByName("Btn_upper")
	self._Btn_upper = Btn_upper

	--银行
	btn = Btn_upper:getChildByName("Btn_Bank")
	btn:setTag(ClientScene.BT_BANK)
	btn:addTouchEventListener(btcallback)

	--客服
	btn = Btn_upper:getChildByName("Btn_KeFu")
	btn:setTag(ClientScene.BT_KEFU)
	btn:addTouchEventListener(btcallback)
	self.m_btKeFu = btn;

	--背包
	btn = Btn_upper:getChildByName("Btn_Bag")
	btn:setTag(ClientScene.BT_BAG)
	btn:addTouchEventListener(btcallback)
	self.m_btBag = btn;

	--背包
	btn = Btn_upper:getChildByName("Btn_Rank")
	btn:setTag(ClientScene.BT_RANK)
	btn:addTouchEventListener(btcallback)
    
    --商场按钮
	btn = shop:getChildByName("Button_1")
	btn:setTag(ClientScene.BT_SHOP)
	btn:addTouchEventListener(btcallback)
	--商城动画
	shop:setPosition(yl.WIDTH-150,45)

	--喇叭
	self._notify = csbNode:getChildByName("Trumpet_Bg")
	btn = self._notify:getChildByName("Trumpet")
	btn:setTag(ClientScene.BT_TRUMPET)
	btn:move(14, 18.5)
	btn:addTouchEventListener(btcallback)

	local stencil  = display.newSprite()
		:setAnchorPoint(cc.p(0,0.5))
	stencil:setTextureRect(cc.rect(0,0,627,50))
	--stencil:setTextureRect(cc.rect(0,0,1334,750))
	self._notifyClip = cc.ClippingNode:create(stencil)
		:setAnchorPoint(cc.p(0,0.5))
	self._notifyClip:setInverted(false)
	self._notifyClip:move(26,18.5)
	self._notifyClip:addTo(self._notify)

	self._notifyText = cc.Label:createWithTTF("", "fonts/round_body.ttf", 24)
		:addTo(self._notifyClip)
		:setTextColor(cc.c4b(255,191,123,255))
		:setAnchorPoint(cc.p(0,0.5))
		:enableOutline(cc.c4b(79,48,35,255), 1)

	self.m_tabInfoTips = {}
	self._tipIndex = 1
	self.m_nNotifyId = 0
	-- 系统公告列表
	self.m_tabSystemNotice = {}
	self._sysIndex = 1
	-- 公告是否运行
	self.m_bNotifyRunning = false

	self.m_bSingleGameMode = false
	if 1 == #self:getApp()._gameList and yl.SINGLE_GAME_MODOLE then
		--默认使用第一个游戏
		local entergame = self:getApp()._gameList[1]
		if nil ~= entergame then
			self.m_bSingleGameMode = true
			self:updateEnterGameInfo(entergame)
			GlobalUserItem.nCurGameKind = tonumber(entergame._KindID)

			GlobalUserItem.bFilterTask = false
			if MatchRoom and true == MatchRoom:getInstance():isCurrentGameOpenMatch(GlobalUserItem.nCurGameKind) then
				self:onChangeShowMode(MatchRoom.LAYTAG.MATCH_TYPELIST)
			elseif PriRoom and true == PriRoom:getInstance():isCurrentGameOpenPri(GlobalUserItem.nCurGameKind) then
				self:onChangeShowMode(PriRoom.LAYTAG.LAYER_ROOMLIST)
			else
				self:onChangeShowMode(yl.SCENE_ROOMLIST)
			end

			self._bg:loadTexture("public/background_2.png")
		else
			self:onChangeShowMode(yl.SCENE_GAMELIST)
		end	
	else
		self:onChangeShowMode(yl.SCENE_GAMELIST)
	end

	local checkInInfo = function(result, msg, subMessage)
		local bRes = false
		if result == 1 then
			if false == GlobalUserItem.bTodayChecked then
				self:onChangeShowMode(yl.SCENE_CHECKIN)
				self._checkInFrame = nil
			elseif GlobalUserItem.cbMemberOrder ~= 0 then
				self._checkInFrame:sendCheckMemberGift()
				bRes = true
			else
				-- 显示广告
				if GlobalUserItem.isShowAdNotice() then
					local webview = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.WebViewLayer"):create(self)
					local runScene = cc.Director:getInstance():getRunningScene()
					if nil ~= runScene then
						runScene:addChild(webview, yl.ZORDER.Z_AD_WEBVIEW)
					end
				end
				self._checkInFrame = nil
			end
		elseif result == self._checkInFrame.QUERYMEMBERGIFT then

		else
			self._checkInFrame = nil
		end
		if nil ~= self._checkInFrame and self._checkInFrame.QUERYMEMBERGIFT == result then
			if true == subMessage then
				self:onChangeShowMode(yl.SCENE_CHECKIN)
			else
				-- 显示广告
				if GlobalUserItem.isShowAdNotice() then
					local webview = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.WebViewLayer"):create(self)
					local runScene = cc.Director:getInstance():getRunningScene()
					if nil ~= runScene then
						runScene:addChild(webview, yl.ZORDER.Z_AD_WEBVIEW)
					end
				end
			end
			self._checkInFrame = nil
		end

		if nil == self._checkInFrame then
			if nil ~= self.m_touchFilter then
				self.m_touchFilter:dismiss()
				self.m_touchFilter = nil
			end			
		end
		return bRes
	end
	self._checkInFrame = CheckinFrame:create(self, checkInInfo)
	self.m_bFirstQueryCheckIn = true

	setbackgroundcallback(function (bEnter)
		if type(self.onBackgroundCallBack) == "function" then
			self:onBackgroundCallBack(bEnter)
		end
	end)

	self:initListener()

	--快速开始
	self.m_bQuickStart = false	

	--游戏喇叭列表
	self.m_gameTrumpetList = {}
	self.m_spGameTrumpetBg = nil

	-- 回退
	self.m_bEnableKeyBack = true

	-- 金币、金币动画
	self.m_nodeCoinAni = nil
	self.m_actCoinAni = nil	
end

function ClientScene:unregisterNotify()
	-- 代理帐号不显示
	if GlobalUserItem.bIsAngentAccount then
		return
	end

	NotifyMgr:getInstance():unregisterNotify(chat_cmd.MDM_GC_USER, chat_cmd.SUB_GC_USER_CHAT_NOTIFY, "client_friend_chat")
	NotifyMgr:getInstance():unregisterNotify(chat_cmd.MDM_GC_USER, chat_cmd.SUB_GC_APPLYFOR_NOTIFY, "client_friend_apply")
	NotifyMgr:getInstance():unregisterNotify(chat_cmd.MDM_GC_USER, chat_cmd.SUB_GC_RESPOND_NOTIFY, "client_friend_response")
	NotifyMgr:getInstance():unregisterNotify(chat_cmd.MDM_GC_USER, chat_cmd.SUB_GC_INVITE_GAME_NOTIFY, "client_friend_invite")
	NotifyMgr:getInstance():unregisterNotify(chat_cmd.MDM_GC_USER, chat_cmd.SUB_GC_USER_SHARE_NOTIFY, "client_friend_share")
	NotifyMgr:getInstance():unregisterNotify(chat_cmd.MDM_GC_USER, chat_cmd.SUB_GC_INVITE_PERSONAL_NOTIFY, "client_pri_friend_invite")
	NotifyMgr:getInstance():unregisterNotify(chat_cmd.MDM_GC_USER, chat_cmd.SUB_GC_TRUMPET_NOTIFY, "trumpet")
	NotifyMgr:getInstance():unregisterNotify(yl.MDM_GP_USER_SERVICE, yl.SUB_GP_TASK_INFO, "client_task_info")
end

function ClientScene:onBackgroundCallBack(bEnter)
	if not bEnter then
		print("onBackgroundCallBack not bEnter")
		local curScene = self._sceneRecord[#self._sceneRecord]
		if curScene == yl.SCENE_GAME then
		end
		if curScene == yl.SCENE_ROOM then
			self:onKeyBack()
		end

		if nil ~= self._gameFrame and self._gameFrame:isSocketServer() and GlobalUserItem.bAutoConnect then			
			self._gameFrame:onCloseSocket()
		end

		self:disconnectFrame()

		--关闭好友服务器
		FriendMgr:getInstance():reSetAndDisconnect()

		self:dismissPopWait()

		-- 关闭介绍
		if self:getChildByName(HELP_LAYER_NAME) then
			self:removeChildByName(HELP_LAYER_NAME)
		end
	else
		print("onBackgroundCallBack  bEnter")
		if #self._sceneRecord > 0 then
			local curScene = self._sceneRecord[#self._sceneRecord]
			if curScene == yl.SCENE_GAME then				
				if self._gameFrame:isSocketServer() == false and GlobalUserItem.bAutoConnect then
					self._gameFrame:OnResetGameEngine()
					self:onStartGame()
				end
			end
		end

		--查询财富
		if GlobalUserItem.bJftPay then
			--通知查询     
            local eventListener = cc.EventCustom:new(yl.RY_JFTPAY_NOTIFY)
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
		end
	end
end

function ClientScene:onRoomCallBack(code,message)
	print("onRoomCallBack:"..code)
	if message then
		showToast(self,message,1)
	end
	if code == -1  then
		self:dismissPopWait()
		local curScene = self._sceneRecord[#self._sceneRecord]
		if curScene == yl.SCENE_ROOM or curScene == yl.SCENE_GAME then
			print("onRoomCallBack curscene is "..curScene)
			local curScene = self._sceneLayer:getChildByTag(curScene)
			if curScene and curScene.onExitRoom then
				curScene:onExitRoom()
			else
				self:onChangeShowMode(yl.SCENE_ROOMLIST)
			end
		end
	end
end

function ClientScene:onReQueryFailure(code, msg)
	self:dismissPopWait()
	if nil ~= msg and type(msg) == "string" then
		showToast(self,msg,2)
	end
end

function ClientScene:onEnterRoom()
	print("client onEnterRoom")
	self:dismissPopWait()
	-- 防作弊房间
	if GlobalUserItem.isAntiCheat() then
		print("防作弊")
		if self._gameFrame:SitDown(yl.INVALID_TABLE,yl.INVALID_CHAIR) then
			self:showPopWait()
		end
		return
	end

	--如果是快速游戏
	local entergame = self:getEnterGameInfo()
	if self.m_bQuickStart and nil ~= entergame then
		self.m_bQuickStart = false
		local t,c = yl.INVALID_TABLE,yl.INVALID_CHAIR
		-- 找桌
		local bGet = false
		for k,v in pairs(self._gameFrame._tableStatus) do
			-- 未锁 未玩			
			if v.cbTableLock == 0 and v.cbPlayStatus == 0 then
				local st = k - 1
				local chaircount = self._gameFrame._wChairCount
				for i = 1, chaircount  do					
					local sc = i - 1
					if nil == self._gameFrame:getTableUserItem(st, sc) then
						t = st
						c = sc
						bGet = true
						break
					end
				end
			end

			if bGet then
				break
			end
		end
		print( " fast enter " .. t .. " ## " .. c)
		if self._gameFrame:SitDown(t,c) then
			self:showPopWait()
		end
	else
		--自定义房间界面处理登陆成功消息
		local entergame = self:getEnterGameInfo()
		if nil ~= entergame then
			local modulestr = string.gsub(entergame._KindName, "%.", "/")
			local targetPlatform = cc.Application:getInstance():getTargetPlatform()
			local customRoomFile = ""
			if cc.PLATFORM_OS_WINDOWS == targetPlatform then
				customRoomFile = "game/" .. modulestr .. "src/views/GameRoomListLayer.lua"
			else
				customRoomFile = "game/" .. modulestr .. "src/views/GameRoomListLayer.luac"
			end
			if cc.FileUtils:getInstance():isFileExist(customRoomFile) then
				if (appdf.req(customRoomFile):onEnterRoom(self._gameFrame)) then
					self:showPopWait()
					return
				else
					--断网、退出房间
					if nil ~= self._gameFrame then
						self._gameFrame:onCloseSocket()
						GlobalUserItem.nCurRoomIndex = -1
					end
				end
			end
		end

		if #self._sceneRecord >0  then
			if self._sceneRecord[#self._sceneRecord] == yl.SCENE_GAME then
				self:onChangeShowMode()
			elseif self._sceneRecord[#self._sceneRecord] == yl.SCENE_ROOM then
				self._gameFrame:setViewFrame(self._sceneLayer:getChildByTag(yl.SCENE_ROOM))
			else
				self:onChangeShowMode(yl.SCENE_ROOM, self.m_bQuickStart)
				self.m_bQuickStart = false
			end
		end
	end
end

function ClientScene:onEnterTable()
	print("ClientScene onEnterTable")

	if PriRoom and GlobalUserItem.bPrivateRoom then
		-- 动作记录
		PriRoom:getInstance().m_nLoginAction = PriRoom.L_ACTION.ACT_ENTERTABLE
	end
	local tag = self._sceneRecord[#self._sceneRecord]
	if tag == yl.SCENE_GAME then
		self._gameFrame:setViewFrame(self._sceneLayer:getChildByTag(yl.SCENE_GAME))
	else
		self:onChangeShowMode(yl.SCENE_GAME)
	end
end

--启动游戏
function ClientScene:onStartGame()
	local app = self:getApp()
	local entergame = self:getEnterGameInfo()
	if nil == entergame then
		showToast(self, "游戏信息获取失败", 3)
		return
	end
	self:getEnterGameInfo().nEnterRoomIndex = GlobalUserItem.nCurRoomIndex
	if nil ~= self.m_touchFilter then
		self.m_touchFilter:dismiss()
		self.m_touchFilter = nil
	end

	self:showPopWait()
	self._gameFrame:onInitData()
	self._gameFrame:setKindInfo(GlobalUserItem.nCurGameKind, entergame._KindVersion)
	local curScene = self._sceneRecord[#self._sceneRecord]
	self._gameFrame:setViewFrame(self)
	self._gameFrame:onCloseSocket()
	self._gameFrame:onLogonRoom()
end

function ClientScene:onCleanPackage(name)
	if not name then
		return
	end
	for k ,v in pairs(package.loaded) do
		if k ~= nil then 
			if type(k) == "string" then
				if string.find(k,name) ~= nil or string.find(k,name) ~= nil then
					print("package kill:"..k) 
					package.loaded[k] = nil
				end
			end
		end
	end
end

function ClientScene:onLevelCallBack(result,msg)
end

function ClientScene:onUserInfoChange( event )
	print("----------userinfo change notify------------")

	local msgWhat = event.obj
	
	if nil ~= msgWhat and msgWhat == yl.RY_MSG_USERHEAD then
		--更新头像
		if nil ~= self._head then
			self._head:updateHead(GlobalUserItem)
		end
	end

	if nil ~= msgWhat and msgWhat == yl.RY_MSG_USERWEALTH then
		--更新财富
		self:updateInfomation()
	end
end

function ClientScene:initListener(  )
	self.m_listener = cc.EventListenerCustom:create(yl.RY_USERINFO_NOTIFY,handler(self, self.onUserInfoChange))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_listener, self)
end

function ClientScene:removeListener(  )
	if nil ~= self.m_listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_listener)
		self.m_listener = nil
	end	
end

function ClientScene:onShare()
	local function sharecall( isok )
		if type(isok) == "string" and isok == "true" then
			showToast(self, "分享成功", 2)
			--获取奖励
			local ostime = os.time()
			local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
			local param = "action=GetMobileShare&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime) .. "&machineid=" .. GlobalUserItem.szMachine
			appdf.onHttpJsionTable(url ,"GET", param, function(jstable,jsdata)
				dump(jstable, "desciption", 6)
                --LogAsset:getInstance():logData(jsonStr,true)
                GlobalUserItem.setTodayShare()
                        
                if type(jstable) == "table" then
                    local data = jstable["data"]
                    local msg = jstable["msg"]
                    if type(data) == "table" and type(msg) == "string" and "" ~= msg then
                        GlobalUserItem.lUserScore = data["Score"] or GlobalUserItem.lUserScore
                        --通知更新        
                        local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
                        eventListener.obj = yl.RY_MSG_USERWEALTH
                        cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

                        if type(msg) == "string" and "" ~= msg then
                            showToast(self, msg, 3)
                        end                         
                    end
                end
						
			end)
		end
	end
    local url = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
    MultiPlatform:getInstance():customShare(sharecall, nil, nil, url, "")
end

function ClientScene:onQDYL()
    self:onChangeShowMode(yl.SCENE_CHECKIN)
end

function ClientScene:onGonggao()
    local webview = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.WebViewLayer"):create(self)
	local runScene = cc.Director:getInstance():getRunningScene()
	if nil ~= runScene then
        print("ClientScene:onGonggao1")
		runScene:addChild(webview, yl.ZORDER.Z_AD_WEBVIEW)
    else
        print("=====ClientScene:onGonggao2")
	end
end

function ClientScene:onKeyBack(tag)
	if not self.m_bEnableKeyBack then
		return
	end

	local curScene = self._sceneRecord[#self._sceneRecord] 
	if curScene then
		if curScene == yl.SCENE_ROOM then
			self._gameFrame:onCloseSocket()
			GlobalUserItem.nCurRoomIndex = -1
		elseif curScene == yl.SCENE_GAMELIST then
			if PriRoom then
				PriRoom:getInstance():exitRoom()
			end
		end
	end
	self:onChangeShowMode(tag)
end

function ClientScene:onKeyBackGameList(tag)
    self:onKeyBack(yl.SCENE_GAMELIST)
end

--跑马灯更新
function ClientScene:onChangeNotify(msg)
---[[
	self._notifyText:stopAllActions()
	if not msg or not msg.str or #msg.str == 0 then
		--[[
		self._notifyText:setString("")
		self.m_bNotifyRunning = false
		self._tipIndex = 1
		self._sysIndex = 1
		return
		--]] 
	end
	self.m_bNotifyRunning = true
	local msgcolor = msg.color or cc.c4b(255,191,123,255)
	self._notifyText:setVisible(false)
	self._notifyText:setString(msg.str)
	self._notifyText:setTextColor(msgcolor)

	if true == msg.autoremove then
		msg.showcount = msg.showcount or 0
		msg.showcount = msg.showcount - 1
		if msg.showcount <= 0 then
			self:removeNoticeById(msg.id)
		end
	end

	local tmpWidth = self._notifyText:getContentSize().width
	local runTimg=0
	if self:FStingWidth(msg.str)> 24 then
		--0.5s/字
		runTimg=8+(self:FStingWidth(msg.str)-24)*0.3
	else
		runTimg=8
	end
	if not msg or not msg.str or #msg.str == 0 then
		runTimg=0 
	end
	self._notifyText:runAction(
			cc.Sequence:create(
				cc.CallFunc:create(	function()
					self._notifyText:move(yl.WIDTH-500,0)
					self._notifyText:setVisible(true)
				end),
				cc.MoveTo:create((runTimg),cc.p(0-tmpWidth,0)),
				cc.CallFunc:create(	function()
					local tipsSize = 0
					local tips = {}
					local index = 1
					if 0 ~= #self.m_tabInfoTips then
						-- 喇叭等
						local tmp = self._tipIndex + 1
						if tmp > #self.m_tabInfoTips then
							tmp = 1
						end
						self._tipIndex = tmp
						self:onChangeNotify(self.m_tabInfoTips[self._tipIndex])
					else
						-- 系统公告
						local tmp = self._sysIndex + 1
						if tmp > #self.m_tabSystemNotice then
							tmp = 1
						end
						self._sysIndex = tmp
						self:onChangeNotify(self.m_tabSystemNotice[self._sysIndex])
					end				
				end)
			)
	)
--]]
end

function ClientScene:FStingWidth(str)
	local fontSize = 2
	local lenInByte = #str
	local width = 0
	 
	for i=1,lenInByte do
		local curByte = string.byte(str, i)
		local byteCount = 1;
		if curByte>0 and curByte<=127 then
			byteCount = 1
		elseif curByte>=192 and curByte<223 then
			byteCount = 2
		elseif curByte>=224 and curByte<239 then
			byteCount = 3 --汉字
		elseif curByte>=240 and curByte<=247 then
			byteCount = 4
		end
		 
		local char = string.sub(str, i, i+byteCount-1)
		i = i + byteCount -1
		 
		if byteCount == 1 then
			--width = width + 1
		else
			width = width + 1
			--print(byteCount,char,i)
		end
	end
	 
	return lenInByte-width*2
end

function ClientScene:ExitClient()
	self._sceneLayer:setKeyboardEnabled(false)
	GlobalUserItem.nCurRoomIndex = -1
	self:updateEnterGameInfo(nil)
	self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.LogonScene","FADE",1)

	GlobalUserItem.reSetData()
	--读取配置
	GlobalUserItem.LoadData()
	--通知管理
	NotifyMgr:getInstance():clear()
	-- 私人房数据
	if PriRoom then
		PriRoom:getInstance():reSet()
	end
end

--按钮事件
function ClientScene:onButtonClickedEvent(tag,ref)

	if tag == ClientScene.BT_EXIT then
		self:onKeyBack()
	elseif tag == ClientScene.BT_QUIT then

	local a =  Integer64.new()

	print(a:getstring())
	
		if self:getChildByTag(ClientScene.DG_QUERYEXIT) then
			return
		end
		QueryExit:create("确认退出APP吗？(切换账号在设置中）",function(ok)
				if ok == true then
					os.exit(0)
				end
			end)
			:setTag(ClientScene.DG_QUERYEXIT)
			:addTo(self)
    elseif tag == ClientScene.BT_QDYL then
        self:onQDYL()
	elseif tag == ClientScene.BT_QUICKSTART then
		if GlobalUserItem.isAngentAccount() then
			return
		end
		--判断当前场景
		local curScene = self._sceneRecord[#self._sceneRecord]
		if PriRoom and not PriRoom.enableQuickStart( curScene ) then
			--showToast(self, "房卡房间不支持快速开始！", 2)
			return
		end

		--默认使用第一个游戏
		local entergame = self:getEnterGameInfo()
		if nil == entergame then
			entergame = self:getApp()._gameList[1]
			self:updateEnterGameInfo(entergame)
		end
		if nil == entergame then
			print("未找到游戏信息")
			return
		end
		--快速开始
		self.m_bQuickStart = true	

		--游戏列表
		if curScene == yl.SCENE_GAMELIST then			
			self:quickStartGame()
		elseif curScene == yl.SCENE_ROOMLIST then 			--游戏房间列表	
			GlobalUserItem.nCurRoomIndex = entergame.nEnterRoomIndex or GlobalUserItem.normalRoomIndex(entergame._KindID)
			local roominfo = GlobalUserItem.GetRoomInfo(GlobalUserItem.nCurRoomIndex)
			if nil == roominfo then
				showToast(self, "房间信息获取失败！", 2)
				return
			end
			if roominfo.wServerType == yl.GAME_GENRE_PERSONAL then
				--showToast(self, "房卡房间不支持快速开始！", 2)
				return
			end
			if self:roomEnterCheck() then
				--进入房间
				self:onStartGame()
			end
		elseif curScene == yl.SCENE_ROOM then 				--房间桌子列表
			--坐下
			self:onEnterRoom()
		end
	else
		if tag ~= ClientScene.BT_CONFIG and tag ~= ClientScene.BT_PERSON then
			if GlobalUserItem.isAngentAccount() then
				return
			end
		end

		if #self._sceneRecord > 0 then
			local curScene = self._sceneRecord[#self._sceneRecord]
			if curScene == yl.SCENE_ROOM then
				if tag == ClientScene.BT_QUICKSTART  then --自动找位
					local room = self._sceneLayer:getChildByTag(curScene)
					if room then
						room:onQuickStart()
					end
					return					
				end
			end
		end
		if tag == ClientScene.BT_CONFIG then
			self:onChangeShowMode(yl.SCENE_OPTION)
		elseif tag == ClientScene.BT_USER then
			self:onChangeShowMode(yl.SCENE_USERINFO)
		elseif tag == ClientScene.BT_BANK then
			-- 当前金币场
			local rom = GlobalUserItem.GetRoomInfo()
			if nil ~= rom then
				if rom.wServerType ~= yl.GAME_GENRE_GOLD then
					showToast(self, "当前房间禁止操作银行!", 2)
					return
				end
			end	
			self:onChangeShowMode(yl.SCENE_BANK)		
		elseif tag == ClientScene.BT_RANK then
			local param = self.m_nPreTag
			self:onChangeShowMode(yl.SCENE_RANKINGLIST, param)
		elseif tag == ClientScene.BT_TASK then
		--[[
			if false == GlobalUserItem.bEnableTask then
				showToast(self, "当前功能暂未开放,敬请期待!", 2)
				return
			end
		--]]
			NotifyMgr:getInstance():hideNotify(self.m_btnTask)
			self:onChangeShowMode(yl.SCENE_TASK)
		elseif self.cur_Scene == yl.SCENE_BANKRECORD then
			self:onChangeShowMode(yl.SCENE_BANK)
		elseif tag == ClientScene.BT_CHECKIN then
			self:onChangeShowMode(yl.SCENE_CHECKIN)
		elseif tag == ClientScene.BT_RECHARGE then
			self:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_ENTITY)
		elseif tag == ClientScene.BT_EXCHANGE then
			self:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_BEAN)
		elseif tag == ClientScene.BT_BOX then
			self:onChangeShowMode(yl.SCENE_EVERYDAY)
		elseif tag == ClientScene.BT_BAG then
			self:onChangeShowMode(yl.SCENE_BAG)			
		elseif tag == ClientScene.BT_FRIEND then
			NotifyMgr:getInstance():hideNotify(self.m_btnFriend)
			self:onChangeShowMode(yl.SCENE_FRIEND)
        elseif tag == ClientScene.BT_KEFU then
            self:onChangeShowMode(yl.SCENE_KEFU)
		elseif tag == ClientScene.BT_TRUMPET then			
			self:getMessageListLayer()
		elseif tag == ClientScene.BT_PERSON then
			self:onChangeShowMode(yl.SCENE_USERINFO)
		elseif tag == ClientScene.BT_SHOP then
			self:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_BEAN)
		else
			showToast(self,"功能尚未开放，敬请期待！",2)
		end
	end
end

--切换页面
function ClientScene:onChangeShowMode(nTag, param)

	local tag = nTag
	local curtag 			--当前页面ID
	local bIn 				--进入判断
	--当前页面

	if #self._sceneRecord > 0 then
		curtag = self._sceneRecord[#self._sceneRecord]
	end
	
	--游戏房间不能点击背包
	if tag==yl.SCENE_BAG then
		if curtag==yl.SCENE_ROOM or curtag==yl.SCENE_GAME then
			showToast(self, "请退出游戏房间再打开背包", 2)
			return
		end
	end

	ExternalFun.dismissTouchFilter()

	--退出判断
	if not tag then
		--返回登录
		if #self._sceneRecord < 2 then
			self:ExitClient()
			return
		end
		--清除记录
		local cur = self._sceneRecord[#self._sceneRecord]
		self._sceneRecord[#self._sceneRecord] = nil
		--上一页面
		tag = self._sceneRecord[#self._sceneRecord]
		--当前为游戏界面
		if cur == yl.SCENE_GAME then
			--防作弊房间
			if GlobalUserItem.isAntiCheat() then
				tag = yl.SCENE_ROOMLIST
				local bHaveRoomList = false
				local tmpRecord = {}
				for i = 1, #self._sceneRecord do
					if self._sceneRecord[i] ~= yl.SCENE_ROOM then
						table.insert(tmpRecord, self._sceneRecord[i])
					end

					if self._sceneRecord[i] == yl.SCENE_ROOMLIST then
						bHaveRoomList = true
					end
				end
				if false == bHaveRoomList then
					tmpRecord[#tmpRecord + 1] = yl.SCENE_ROOMLIST
				end
				self._sceneRecord = tmpRecord

				self._gameFrame:onCloseSocket()
			-- 私人房
			elseif GlobalUserItem.bPrivateRoom then
				if PriRoom then
					tag = PriRoom.LAYTAG.LAYER_ROOMLIST
					-- 清理记录
					self._sceneRecord = {}
					if not self.m_bSingleGameMode then
						-- 非单游戏模式, 保存游戏列表界面记录
						self._sceneRecord[1] = yl.SCENE_GAMELIST
					end					
					self._sceneRecord[#self._sceneRecord + 1] = tag
					PriRoom:getInstance():exitGame()
				end
				self._gameFrame:onCloseSocket()		
			--网络已经关闭 回退到房间列表
			elseif self._gameFrame:isSocketServer() ~= true then
				tag = yl.SCENE_ROOMLIST
				local bHaveRoomList = false
				local tmpRecord = {}
				for i = 1, #self._sceneRecord do
					if self._sceneRecord[i] ~= yl.SCENE_ROOM then
						table.insert(tmpRecord, self._sceneRecord[i])
					end

					if self._sceneRecord[i] == yl.SCENE_ROOMLIST then
						bHaveRoomList = true
					end
				end
				if false == bHaveRoomList then
					tmpRecord[#tmpRecord + 1] = yl.SCENE_ROOMLIST
				end
				self._sceneRecord = tmpRecord
			elseif tag ~= yl.SCENE_ROOM then --回退到房间桌子界面
				self._sceneRecord[#self._sceneRecord+1] = yl.SCENE_ROOM
				tag = yl.SCENE_ROOM
			end
			
			-- 游戏喇叭关闭
			if nil ~= self.m_spGameTrumpetBg then
				self.m_spGameTrumpetBg:stopAllActions()
				self.m_spGameTrumpetBg:removeFromParent()
			end
			-- 玩法按钮
			if self:getChildByName(HELP_BTN_NAME) then
				self:removeChildByName(HELP_BTN_NAME)
			end
			-- 移除语音按钮
			if self:getChildByName(VOICE_BTN_NAME) then
				self:removeChildByName(VOICE_BTN_NAME)
			end
			-- 移除语音
			self:cancelVoiceRecord()
			if nil ~= self._gameFrame and type(self._gameFrame.clearVoiceQueue) == "function" then
				self._gameFrame:clearVoiceQueue()
			end
		end
	else
		--查找已有
		local oldIndex
		for i = 1 ,#self._sceneRecord do
			if self._sceneRecord[i] == tag then
				oldIndex = i 
				break
			end
		end

		if not oldIndex then --新界面
			bIn = true --进入判断
			self._sceneRecord[#self._sceneRecord+1] = tag --记录ID
		else
			--重复过滤
		 	if oldIndex == #self._sceneRecord then
		 		return
		 	end

		 	--回退至已有记录
		 	for i = #self._sceneRecord,oldIndex+1 ,-1 do
		 		table.remove(self._sceneRecord, i)
		 	end
		end
	end
	--上一个页面
	self.m_nPreTag = self._sceneRecord[#self._sceneRecord]

	local this = self
	--当前页面
	print("====== curtag",curtag)
	print("====== tag",tag)
	if curtag then
		local cur_layer = self._sceneLayer:getChildByTag(curtag)
		if cur_layer then
			cur_layer:stopAllActions()
			--游戏界面不触发切换动画
			if tag == yl.SCENE_GAME or curtag == yl.SCENE_GAME then
				cur_layer:removeFromParent()
				ExternalFun.playPlazzBackgroudAudio()
			--排行榜不触发切换动画  测试代码  --需要删除 by zml
			--[[
			elseif tag == yl.SCENE_RANKINGLISTINIT or curtag == yl.SCENE_RANKINGLISTINIT then
				cur_layer:removeFromParent()
				ExternalFun.playPlazzBackgroudAudio()
				--]]
			else				
				--动画判断
				local curAni
				if not bIn then
                print("====  动画判断 111")
					curAni = cc.MoveTo:create(0.3,cc.p(yl.WIDTH/2,0)) 
				else
                print("====  动画判断 222")
					curAni = cc.MoveTo:create(0.3,cc.p(yl.WIDTH/2,0)) 
				end
				cur_layer:runAction(cc.Sequence:create(curAni,cc.RemoveSelf:create(true)))
			end			
		end
	end
	if tag == yl.SCENE_SHOP then
	--商城页面 带入参数
	param=Shop.CBT_BEAN
	end
	--目标页面
	local dst_layer = self:getTagLayer(tag, param,curtag)
	if dst_layer then
		--游戏界面不触发切换动画
		if tag == yl.SCENE_GAME then
			self._sceneLayer:setKeyboardEnabled(false)
			dst_layer:addTo(self._sceneLayer)
			if dst_layer.onSceneAniFinish then
				dst_layer:onSceneAniFinish()
			end
			this._sceneLayer:setKeyboardEnabled(true)
		else
			--触摸过滤
			ExternalFun.popupTouchFilter()
			self._sceneLayer:setKeyboardEnabled(false)
			if not bIn then
				dst_layer:move(yl.HEIGHT,0)
			else 
				dst_layer:move(yl.WIDTH,0)
			end
			dst_layer:addTo(self._sceneLayer)
			dst_layer:stopAllActions()
			dst_layer:runAction(cc.Sequence:create(
							cc.MoveTo:create(0.3,cc.p(0,0)),
							cc.CallFunc:create(
								function()
									if dst_layer.onSceneAniFinish then
										dst_layer:onSceneAniFinish()
									end
									this._sceneLayer:setKeyboardEnabled(true)
									ExternalFun.dismissTouchFilter()
							end)
					)
				)
		end		
	else
		print("dst_layer is nil")
		self:ExitClient()
		return
	end

	if tag == yl.SCENE_GAME or tag == yl.SCENE_ROOM then
		self._gameFrame:setViewFrame(dst_layer)
	end

	--旧头部底部动画替换
	self._bg_top:stopAllActions()
	self._bg_bottom:stopAllActions()
	self._headNick:stopAllActions()
	self._coinnum:stopAllActions()
	--self._beannum:stopAllActions()
	self._Btn_upper:stopAllActions()
	self._shop:stopAllActions()
	--self._Btn_frame_menu:stopAllActions()
	self._AdvFrame:stopAllActions()
	self._btKSKS:stopAllActions()
	--
	if tag == yl.SCENE_GAMELIST then
		self._AdvFrame:runAction(cc.MoveTo:create(0.3,cc.p(231,348)))
		self._AdvFrame:setVisible(true)
	end
	if  tag == yl.SCENE_ROOMLIST  or tag == yl.SCENE_ROOM then
		self._AdvFrame:runAction(cc.MoveTo:create(0.3,cc.p(-231,348)))
		self._AdvFrame:setVisible(false)
	end
	if tag == yl.SCENE_GAMELIST or tag == yl.SCENE_ROOMLIST  or tag == yl.SCENE_ROOM then
		self._bg_top:runAction(cc.MoveTo:create(0.3,display.left_top))
		self._bg_bottom:runAction(cc.MoveTo:create(0.3,display.left_bottom))
		self._headNick:runAction(cc.MoveTo:create(0.3,cc.p(260,710)))
		self._coinnum:runAction(cc.MoveTo:create(0.3,cc.p(640,708)))
		--self._beannum:runAction(cc.MoveTo:create(0.3,cc.p(660,708)))
		self._Btn_upper:runAction(cc.MoveTo:create(0.3,cc.p(65,34)))
		self._shop:runAction(cc.MoveTo:create(0.3,cc.p(yl.WIDTH-150,45)))
		--self:setUpDownVisible2()
		if tag == yl.SCENE_ROOMLIST  or tag == yl.SCENE_ROOM then
			self._AdvFrame:runAction(cc.MoveTo:create(0.3,cc.p(-231,348)))
			self._btKSKS:runAction(cc.EaseExponentialIn:create(cc.MoveTo:create(0.5,cc.p(yl.WIDTH+50,yl.HEIGHT/2))))
		elseif tag==yl.SCENE_GAMELIST then
			self._btKSKS:runAction(cc.EaseExponentialIn:create(cc.MoveTo:create(0.5,cc.p(yl.WIDTH,yl.HEIGHT/2))))
		end
	else
		if PriRoom and PriRoom.haveBottomTop(tag) then
			if self._Btn_upper:getPositionY() < 0 then
				self._bg_top:runAction(cc.MoveTo:create(0.3,display.left_top))
				self._bg_bottom:runAction(cc.MoveTo:create(0.3,display.left_bottom))
				self._headNick:runAction(cc.MoveTo:create(0.3,cc.p(260,710)))
				self._coinnum:runAction(cc.MoveTo:create(0.3,cc.p(640,708)))
				self._Btn_upper:runAction(cc.MoveTo:create(0.3,cc.p(65,34)))
				self._shop:runAction(cc.MoveTo:create(0.3,cc.p(yl.WIDTH-150,45)))
				self._AdvFrame:runAction(cc.MoveTo:create(0.3,cc.p(231,348)))
				self._btKSKS:runAction(cc.EaseExponentialIn:create(cc.MoveTo:create(0.5,cc.p(yl.WIDTH,yl.HEIGHT/2))))
			end
		else
			if tag == yl.SCENE_GAME then
				self._bg_top:setPosition(cc.p(0, 900))
				self._bg_bottom:setPosition(cc.p(0, -170))
				self._headNick:setPosition(cc.p(260,900))
				self._coinnum:setPosition(cc.p(640,900))
				self._Btn_upper:setPosition(cc.p(65,-170))
				self._shop:setPosition(cc.p(yl.WIDTH-150,-170))
				self._AdvFrame:setPosition(cc.p(-231,348))
				self._btKSKS:setPosition(cc.p(yl.WIDTH,yl.HEIGHT/2))
				--[[
			elseif tag == yl.SCENE_SHOP then
				--商城页面
				self._bg_top:runAction(cc.MoveTo:create(0.3,display.left_top))
				self._headNick:runAction(cc.MoveTo:create(0.3,cc.p(260,710)))
				self._coinnum:runAction(cc.MoveTo:create(0.3,cc.p(640,708)))
				
				self._bg_bottom:runAction(cc.MoveTo:create(0.3,cc.p(0, -170)))
				self._Btn_upper:runAction(cc.MoveTo:create(0.3,cc.p(65,-170)))
				self._shop:runAction(cc.MoveTo:create(0.3,cc.p(yl.WIDTH-150,-170)))
				self._AdvFrame:runAction(cc.MoveTo:create(0.3,cc.p(-231,348)))
				self._btKSKS:runAction(cc.EaseExponentialIn:create(cc.MoveTo:create(0.5,cc.p(yl.WIDTH+50,yl.HEIGHT/2))))
				]]--
			else
				self._bg_top:runAction(cc.MoveTo:create(0.3,cc.p(0, 900)))
				self._bg_bottom:runAction(cc.MoveTo:create(0.3,cc.p(0, -170)))
				self._headNick:runAction(cc.MoveTo:create(0.3,cc.p(260,900)))
				self._coinnum:runAction(cc.MoveTo:create(0.3,cc.p(640,900)))
				self._Btn_upper:runAction(cc.MoveTo:create(0.3,cc.p(65,-170)))
				self._shop:runAction(cc.MoveTo:create(0.3,cc.p(yl.WIDTH-150,-170)))
				self._AdvFrame:runAction(cc.MoveTo:create(0.3,cc.p(-231,348)))
				self._btKSKS:runAction(cc.EaseExponentialIn:create(cc.MoveTo:create(0.5,cc.p(yl.WIDTH+50,yl.HEIGHT/2))))
			end
		end				
	end

    --控制商城动画 新加 SCENE_ROOMLIST场景
	local infoShow = (tag == yl.SCENE_GAMELIST or bRoomList or tag == yl.SCENE_ROOM or tag == yl.SCENE_ROOMLIST)
	if true == infoShow then
		if nil ~= self.m_actShopAni then
			--self._shop:stopAllActions() 会停止商城返回动画 暂时注释
			self.m_actShopAni:gotoFrameAndPlay(0,true)
			self._shop:runAction(self.m_actShopAni)
		end
	end

	local bRoomList = true
	local bEnableBackBtn = false
	if PriRoom then
		bRoomList = PriRoom.isRoomListLayer(tag)
		bEnableBackBtn = PriRoom.enableBackBtn(tag)
	else
		bRoomList = (tag == yl.SCENE_ROOMLIST)
	end

	if bRoomList then
		local var = true
		-- 单游戏
		if self.m_bSingleGameMode then
			if MatchRoom and true == MatchRoom:getInstance():isCurrentGameOpenMatch(GlobalUserItem.nCurGameKind) then
				var = true
				if PriRoom and true == PriRoom:getInstance():isCurrentGameOpenPri(GlobalUserItem.nCurGameKind) then
					if PriRoom.isRoomListLayer(tag) then
						-- 普通房列表
						var = false
					end	
				end
				if tag == MatchRoom.LAYTAG.MATCH_ROOMLIST then
					-- 普通房列表
					var = false
				end
			elseif PriRoom and true == PriRoom:getInstance():isCurrentGameOpenPri(GlobalUserItem.nCurGameKind) then
				-- 私人房单游戏
				-- 私人房列表
				var = true
				if tag == yl.SCENE_ROOMLIST then
					-- 普通房列表
					var = false
				end				
			elseif tag == yl.SCENE_ROOMLIST then
				-- 普通房间
				var = true
			else
				var = false
			end
		else
			var = false
		end

		--self._btExit:setVisible(not var)
		--self._btExit:setEnabled(not var)
		--self._btPersonInfo:setEnabled(var)
		if nil ~= self._head then
			--self._head:setVisible(var)
		end
		self._bg:loadTexture("public/background_2.png")
	elseif tag == yl.SCENE_SHOP then
		--商城界面
		var = false
		--self._btExit:setVisible(not var)
		--self._btExit:setEnabled(not var)
		--self._btPersonInfo:setEnabled(var)
		if nil ~= self._head then
			--self._head:setVisible(var)
		end
		self._bg:loadTexture("public/background_2.png")
	elseif tag == yl.SCENE_ROOM then

		--self._btExit:setVisible(true)
		--self._btExit:setEnabled(true)
		--self._btPersonInfo:setEnabled(false)
		if nil ~= self._head then
			--self._head:setVisible(false)
		end			
		self._bg:loadTexture("public/background_2.png")
	elseif tag == yl.SCENE_GAMELIST then
		--self._btExit:setVisible(false)
		--self._btExit:setEnabled(false)

		if nil ~= self._head then
			--self._head:setVisible(true)
		end
		--self._btPersonInfo:setEnabled(true)
		self._bg:loadTexture("public/background_2.png")
	elseif bEnableBackBtn then
		--self._btExit:setVisible(true)
		--self._btExit:setEnabled(true)
		
		--self._btPersonInfo:setEnabled(false)

		if nil ~= self._head then
			--self._head:setVisible(false)
		end	
	else
		self._bg:loadTexture("public/background_2.png")
	end

	--控制宝箱、喇叭显示	
	local infoShow = (tag == yl.SCENE_GAMELIST or bRoomList or tag == yl.SCENE_ROOM)
	self._notify:setVisible(infoShow)
	--公告重新获取 进入/返回大厅 进入游戏房间
	if infoShow then
		self:requestNotice()
	end

    --控制幸运转盘、签到有礼、快速开始显示   待添加 排行榜
    self._btQDYL:setVisible(infoShow)
    self._btSetting:setVisible(infoShow)
    self._btKSKS:setVisible(infoShow)



	--更新金币
	infoShow = (tag == yl.SCENE_GAMELIST or tag == yl.SCENE_ROOMLIST or tag == yl.SCENE_ROOM or bRoomList)
	if true == infoShow then
		self:updateInfomation()
	end

	if tag == yl.SCENE_GAME then
	end

	--游戏信息
	GlobalUserItem.bEnterGame = ( tag == yl.SCENE_GAME )
	if tag == yl.SCENE_ROOMLIST then
		GlobalUserItem.dwServerRule = 0
	end
end

--获取页面
function ClientScene:getTagLayer(tag, param,curtag)
	local dst
	if tag == yl.SCENE_GAMELIST then
		dst =  GameListView:create(self:getApp()._gameList)
 --       dst:setLocalZOrder(-2000)
	elseif tag == yl.SCENE_ROOMLIST then
		--是否有自定义房间列表
		local entergame = self:getEnterGameInfo()
		if nil ~= entergame then
			local modulestr = string.gsub(entergame._KindName, "%.", "/")
			local targetPlatform = cc.Application:getInstance():getTargetPlatform()
			local customRoomFile = ""
			if cc.PLATFORM_OS_WINDOWS == targetPlatform then
				customRoomFile = "game/" .. modulestr .. "src/views/GameRoomListLayer.lua"
			else
				customRoomFile = "game/" .. modulestr .. "src/views/GameRoomListLayer.luac"
			end
			if cc.FileUtils:getInstance():isFileExist(customRoomFile) then
				dst = appdf.req(customRoomFile):create(self, self._gameFrame, param)
			end
		end
		if nil == dst then
			dst = RoomList:create(self, param)
		end		
	elseif tag == yl.SCENE_USERINFO then
		dst = UserInfo:create(self)
	elseif tag == yl.SCENE_OPTION then
		dst = Option:create(self)
	elseif tag == yl.SCENE_BANK then
		dst = Bank:create(self, self._gameFrame)
	--elseif tag == yl.SCENE_RANKINGLISTINIT then
	--	dst = RankingListInit:create(self, param)
	elseif tag == yl.SCENE_RANKINGLIST then
		dst = RankingList:create(self, param)
	elseif tag == yl.SCENE_TASK then
        dst = Task:create(self, self._gameFrame)
	elseif tag == yl.SCENE_ROOM then
		dst = Room:create(self._gameFrame,self, param)
	elseif tag == yl.SCENE_GAME then
		local entergame = self:getEnterGameInfo()
		if nil ~= entergame then
			local modulestr = entergame._KindName
			local gameScene = appdf.req(appdf.GAME_SRC.. modulestr .. "src.views.GameLayer")
			if gameScene then
				dst = gameScene:create(self._gameFrame,self)				
			end
			if PriRoom and nil ~= dst and true == GlobalUserItem.bPrivateRoom then
				PriRoom:getInstance():enterGame(dst, self)
			end
		else
			print("游戏记录错误")
		end			
    elseif tag == yl.SCENE_CHECKIN then
		dst = Checkin:create(self)
	elseif tag == yl.SCENE_BANKRECORD then
		dst = BankRecord:create(self)
	elseif tag == yl.SCENE_ORDERRECORD then
		dst = OrderRecord:create(self)
	elseif tag == yl.SCENE_EVERYDAY then
		dst = EveryDay:create(self)
	elseif tag == yl.SCENE_AGENT then
		dst = Agent:create(self)
	elseif tag == yl.SCENE_SHOP then
		--dst = Shop:create(self, param, self._gameFrame)
		dst = Shop:create(self, param,self._gameFrame,curtag)
	elseif tag == yl.SCENE_BAG then
		dst = Bag:create(self, self._gameFrame)
	elseif tag == yl.SCENE_BAGDETAIL then
		dst = BagDetail:create(self, self._gameFrame)
	elseif tag == yl.SCENE_BAGTRANS then
		dst = BagTrans:create(self, self._gameFrame)
	elseif tag == yl.SCENE_BINDING then
		dst = Binding:create(self)
	elseif tag == yl.SCENE_FRIEND then
		dst = Friend:create(self)
    elseif tag == yl.SCENE_KEFU then
		dst = KeFuLayer:create(self)
    elseif tag == yl.SCENE_PHONE then
		dst = BindPhoneLayer:create(self)
	elseif tag == yl.SCENE_MODIFY then				
		dst = ModifyPasswd:create(self)
	elseif tag == yl.SCENE_FEEDBACK then
		dst = FeedbackLayer:create(self)
	elseif tag == yl.SCENE_FEEDBACKLIST then
		dst = FeedbackLayer.createFeedbackList(self)
	elseif tag == yl.SCENE_FAQ then
		dst = FaqLayer:create(self)
	elseif tag == yl.SCENE_BINDINGREG then
		dst = BindingRegisterLayer:create(self)
	elseif PriRoom then
		dst = PriRoom:getInstance():getTagLayer(tag, param, self)
	end
	if dst then
		dst:setTag(tag)
	end
	return dst
end

--显示等待
function ClientScene:showPopWait(isTransparent)
	if not self._popWait then
		self._popWait = PopWait:create(isTransparent)
			:show(self,"请稍候！")
		self._popWait:setLocalZOrder(yl.MAX_INT)
	end
end

--关闭等待
function ClientScene:dismissPopWait()
	if self._popWait then
		self._popWait:dismiss()
		self._popWait = nil
	end
end

--更新进入游戏记录
function ClientScene:updateEnterGameInfo( info )
	GlobalUserItem.m_tabEnterGame = info
end

function ClientScene:getEnterGameInfo(  )
	return GlobalUserItem.m_tabEnterGame
end

--获取游戏信息
function ClientScene:getGameInfo(wKindID)
	for k,v in pairs(self:getApp()._gameList) do
		if tonumber(v._KindID) == tonumber(wKindID) then
			return v
		end
	end
	return nil
end

--获取喇叭发送界面
function ClientScene:getMessageListLayer()
	if nil == self.m_messagelistLayer then
		self.m_messagelistLayer = MessageListLayer:create(self,self.m_tabSystemNotice)
		self.m_plazaLayer:addChild(self.m_messagelistLayer)
	end
	self.m_messagelistLayer:showLayer(true,self.m_tabSystemNotice)
end

function ClientScene:getSceneRecord(  )
	return self._sceneRecord
end

function ClientScene:updateInfomation(  )
	local str = string.formatNumberThousands(GlobalUserItem.lUserScore,true,",")
	if string.len(str) > 11 then
		str = string.sub(str, 1, 11) .. "..."
	end
	self._gold:setString(str)
	str = string.formatNumberThousands(GlobalUserItem.dUserBeans,true,",")
	if string.len(str) > 11 then
		str = string.sub(str, 1, 11) .. "..."
	end
	--self._bean:setString(str)
	str = string.formatNumberThousands(GlobalUserItem.lUserIngot,true,",")
	if string.len(str) > 11 then
		str = string.sub(str, 1, 11) .. "..."
	end
end

--缓存公共资源
function ClientScene:cachePublicRes(  )
	cc.SpriteFrameCache:getInstance():addSpriteFrames("public/public.plist")
	local dict = cc.FileUtils:getInstance():getValueMapFromFile("public/public.plist")

	local framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame then
				frame:retain()
			end
		end
	end

	cc.SpriteFrameCache:getInstance():addSpriteFrames("plaza/plaza.plist")	
	dict = cc.FileUtils:getInstance():getValueMapFromFile("plaza/plaza.plist")
	framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame then
				frame:retain()
			end
		end
	end
end

--释放公共资源
function ClientScene:releasePublicRes(  )
	local dict = cc.FileUtils:getInstance():getValueMapFromFile("public/public.plist")
	local framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame and frame:getReferenceCount() > 0 then
				frame:release()
			end
		end
	end

	dict = cc.FileUtils:getInstance():getValueMapFromFile("plaza/plaza.plist")
	framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame and frame:getReferenceCount() > 0 then
				frame:release()
			end
		end
	end
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("public/public.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("public/public.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("plaza/plaza.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("plaza/plaza.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

--输出日志
function ClientScene:logData(msg, addExtral)
	addExtral = addExtral or false
	local logtable = {}
	local entergame = self:getEnterGameInfo()
	if nil ~= entergame then
		logtable.name = entergame._KindName
		logtable.id = entergame._KindID
	end
	logtable.msg = msg
	local jsonStr = cjson.encode(logtable)
	LogAsset:getInstance():logData(jsonStr,true)
end

--快速登录逻辑
function ClientScene:quickStartGame()	
	--进入游戏房间/进入第一个桌子
	local gamelist = self._sceneLayer:getChildByTag(yl.SCENE_GAMELIST)
	local gameinfo = self:getEnterGameInfo()
	if nil ~= gamelist and nil ~= gameinfo then
		--进入游戏第一个房间
		GlobalUserItem.nCurRoomIndex = gameinfo.nEnterRoomIndex
		if nil == GlobalUserItem.nCurRoomIndex or -1 == GlobalUserItem.nCurRoomIndex then
			GlobalUserItem.nCurRoomIndex = GlobalUserItem.normalRoomIndex(gameinfo._KindID)
		end
		if not GlobalUserItem.nCurRoomIndex then
			showToast(self, "未找到房间信息!", 2)
			return
		end

		--快速开始  add zml
		self.m_bQuickStart = true	

		--获取更新
		if not self:updateGame() then -- 临时屏蔽更新 by lqy
		---[[
			--获取房间信息
			local roomCount = GlobalUserItem.GetRoomCount(gameinfo._KindID)
			if not roomCount or 0 == roomCount then
				--gamelist:onLoadGameList(gameinfo._KindID)
				print("ClientScene:quickStartGame 房间列表为空")
			end
			GlobalUserItem.nCurGameKind = tonumber(gameinfo._KindID)
			GlobalUserItem.szCurGameName = gameinfo._KindName			

			local roominfo = GlobalUserItem.GetRoomInfo(GlobalUserItem.nCurRoomIndex)
			if roominfo.wServerType == yl.GAME_GENRE_PERSONAL then
				--showToast(self, "房卡房间不支持快速开始！", 2)
				return
			end
			if self:roomEnterCheck() then
				--启动游戏
				self:onStartGame()
			end
			--]]
		end
	end
end

-- 游戏更新处理
function ClientScene:updateGame(dwKindID)


	local gameinfo = self:getEnterGameInfo()
	if nil ~= dwKindID then
		gameinfo = self:getGameInfo(dwKindID)
	end
	if nil == gameinfo then
		return false
	end
	local gamelist = self._sceneLayer:getChildByTag(yl.SCENE_GAMELIST)
	if nil == gamelist then
		return false
	end

	--获取更新
	local app = self:getApp()
	local version = app:getVersionMgr():getResVersion(gameinfo._KindID)
	if not version or gameinfo._ServerResVersion > version then
		gamelist:updateGame(gameinfo, gameinfo.gameIndex)
		return true
	end
	return false
end

-- 链接游戏
function ClientScene:loadGameList(dwKindID)
	local gameinfo = self:getEnterGameInfo()
	if nil ~= dwKindID then
		gameinfo = self:getGameInfo(dwKindID)
	end
	if nil == gameinfo then
		return false
	end
	local gamelist = self._sceneLayer:getChildByTag(yl.SCENE_GAMELIST)
	if nil == gamelist then
		return false
	end

	self:updateEnterGameInfo(gameinfo)
	local roomCount = GlobalUserItem.GetRoomCount(gameinfo._KindID)
	if not roomCount or 0 == roomCount then
		--gamelist:onLoadGameList(gameinfo._KindID)
		print("ClientScene:loadGameList 房间列表为空")
		return true
	end
	return false
end

function ClientScene:roomEnterCheck()
	local roominfo = GlobalUserItem.GetRoomInfo(GlobalUserItem.nCurRoomIndex)

	-- 密码
	if bit:_and(roominfo.wServerKind, yl.SERVER_GENRE_PASSWD) ~= 0 then
		self.m_bEnableKeyBack = false
		self:createPasswordEdit("请输入房间密码", function(pass)
			self.m_bEnableKeyBack = true
			GlobalUserItem.szRoomPasswd = pass
			self:onStartGame()
		end, "RoomList/sp_pwroom_title.png")
		return false
	end

	-- 比赛
	if bit:_and(roominfo.wServerType ,yl.GAME_GENRE_MATCH )  ~= 0 then
		showToast(self,"暂不支持比赛房间！",1)
		return false
	end
	return true
end

--网络通知
function ClientScene:onNotify(msg)
	local bHandled = false
	local main = msg.main or 0
	local sub = msg.sub or 0
	local name = msg.name or ""
	local param = msg.param
	local group = msg.group
	
	if group == "client_trumpet" 
		and type(msg.param) == "table" then
		--喇叭消息获取		--
		local item = {}
		item.str =  msg.param.szNickName .. "说:" ..   string.gsub(msg.param.szMessageContent, "\n", "")
		item.color = cc.c4b(255,191,123,255)
		item.autoremove = true
		item.showcount = 1
		item.bNotice = false
		item.id = self:getNoticeId()
		self:addNotice(item)
		bHandled = true

		--当前场景为游戏
		local curScene = self._sceneRecord[#self._sceneRecord]		
		if curScene == yl.SCENE_GAME then
			table.insert(self.m_gameTrumpetList, item.str)

			local chat = {}
			chat.szNick = msg.param.szNickName
			chat.szChatString = msg.param.szMessageContent
			GameChatLayer.addChatRecordWith(chat)

			if nil == self.m_spGameTrumpetBg then
				local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_trumpet_bg.png")
				if nil ~= frame then
					local trumpetBg = cc.Sprite:createWithSpriteFrame(frame)
					local runScene = cc.Director:getInstance():getRunningScene()
					if nil ~= runScene and nil ~= trumpetBg then 
						self.m_spGameTrumpetBg = trumpetBg
						trumpetBg:setScaleX(0.0001)
						runScene:addChild(trumpetBg)
						local trumpetsize = trumpetBg:getContentSize()
						trumpetBg:setPosition(appdf.WIDTH * 0.5, appdf.HEIGHT - trumpetsize.height * 0.5)
						local stencil  = display.newSprite()
							:setAnchorPoint(cc.p(0,0.5))
						stencil:setTextureRect(cc.rect(0,0,700,50))
						local notifyClip = cc.ClippingNode:create(stencil)
							:setAnchorPoint(cc.p(0,0.5))
						notifyClip:setInverted(false)
						notifyClip:move(50,30)
						notifyClip:addTo(trumpetBg)
						local notifyText = cc.Label:createWithTTF("", "fonts/round_body.ttf", 24)
									:addTo(notifyClip)
									:setTextColor(cc.c4b(255,191,123,255))
									:setAnchorPoint(cc.p(0,0.5))
									:enableOutline(cc.c4b(79,48,35,255), 1)
									:move(700,0)
						self.m_spGameTrumpetBg.trumpetText = notifyText

						trumpetBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.0), cc.CallFunc:create(function()
							self:onGameTrumpet()
						end)))	
					end
				end
			end		
		else
			self.m_gameTrumpetList = {}
		end	
	elseif group == "client_task" then 		-- 任务
		bHandled = true
		--当前场景非任务
		local curScene = self._sceneRecord[#self._sceneRecord]
		if curScene ~= yl.SCENE_TASK and true == GlobalUserItem.bEnableTask then
			NotifyMgr:getInstance():showNotify(self.m_btnTask, msg, cc.p(254, 88))
		end
	elseif group == "client_friend" then
		bHandled = true
		local curScene = self._sceneRecord[#self._sceneRecord]		
		if curScene ~= yl.SCENE_FRIEND then
			NotifyMgr:getInstance():showNotify(self.m_btnFriend, msg, cc.p(50, 50))
		end
	end
	return bHandled
end

function ClientScene:onGameTrumpet()
	if nil ~= self.m_spGameTrumpetBg and 0 ~= #self.m_gameTrumpetList then
		local str = self.m_gameTrumpetList[1]
		table.remove(self.m_gameTrumpetList,1)		
		local text = self.m_spGameTrumpetBg.trumpetText						
		if nil ~= text then
			text:setString(str)
			text:setPosition(cc.p(700, 0))
			text:stopAllActions()
			local tmpWidth = text:getContentSize().width
			text:runAction(cc.Sequence:create(cc.MoveTo:create(16 + (tmpWidth / 172),cc.p(0-text:getContentSize().width,0)),cc.CallFunc:create(function()
				if 0 ~= #self.m_gameTrumpetList then
					self:onGameTrumpet()
				else
					self.m_spGameTrumpetBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 0.0001, 1.0), cc.CallFunc:create(function()
						self.m_spGameTrumpetBg:removeFromParent()
						self.m_spGameTrumpetBg = nil
					end)))
				end														
			end)))
		end
	end
end

--请求公告
function ClientScene:requestNotice()
---[[
	local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx?action=GetMobileRollNotice" 
	url="http://www.16yi.com//WS/MobileInterface.ashx?action=getmobilenotice&kindId=122"        	
	appdf.onHttpJsionTable(url ,"GET","",function(jstable,jsdata)
		if type(jstable) == "table" then
			local data = jstable["data"]
			local msg = jstable["msg"]
			if type(data) == "table" then
				local valid = data["valid"]
				if nil ~= valid and true == valid then
					local list = data["notice"]
					if type(list)  == "table" then
						--清理消息
						self.m_tabSystemNotice = {}
						local listSize = #list
						self.m_nNoticeCount = listSize
						for i = 1, listSize do
							local item = {}
							item.str = list[i].content or ""
							item.id = self:getNoticeId()
							item.color = cc.c4b(255,191,123,255)
							item.autoremove = false
							item.showcount = 0
							table.insert(self.m_tabSystemNotice, item)
						end
						self:onChangeNotify(self.m_tabSystemNotice[self._sysIndex])
					end
				end
			end
			if type(msg) == "string" and "" ~= msg then
				showToast(self, msg, 3)
			end
		end
	end)
	--]]
end

function ClientScene:addNotice(item)
	if nil == item then
		return
	end
	table.insert(self.m_tabInfoTips, 1, item)
	if not self.m_bNotifyRunning then
		self:onChangeNotify(self.m_tabInfoTips[self._tipIndex])
	end
end

function ClientScene:removeNoticeById(id)
	if nil == id then
		return
	end

	local idx = nil
	for k,v in pairs(self.m_tabInfoTips) do
		if nil ~= v.id and v.id == id then
			idx = k
			break
		end
	end

	if nil ~= idx then
		table.remove(self.m_tabInfoTips, idx)
	end
end

function ClientScene:getNoticeId()
	local tmp = self.m_nNotifyId
	self.m_nNotifyId = self.m_nNotifyId + 1
	return tmp
end

local BT_CLOSE_DLG = 1
local BT_CONFIRM = 2
function ClientScene:createPasswordEdit(placeholder, confirmFun, titleFile)
	local runScene = cc.Director:getInstance():getRunningScene()
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(appdf.WIDTH, appdf.HEIGHT))
	layout:setTouchEnabled(true)
	layout:setSwallowTouches(true)
	runScene:addChild(layout)

	local bg = display.newSprite("plaza/plaza_query_bg.png")
		:move(appdf.WIDTH/2,appdf.HEIGHT/2)
		:addTo(layout)
	local bg_size = bg:getContentSize()

	--编辑框
	local editpass = ccui.EditBox:create(cc.size(490,67), "RoomList/sp_pwedit_bg.png")
		:move(bg_size.width * 0.5,180)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(32)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder(placeholder)
		:setFontColor(cc.c4b(254,164,107,255))	
		:addTo(bg)

	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			local tag = sender:getTag()
			if BT_CLOSE_DLG == tag then
				layout:removeFromParent()
				self.m_bEnableKeyBack = true
			elseif  BT_CONFIRM == tag then
				local editText = string.gsub(editpass:getText(), " ", "")
				if ExternalFun.stringLen(editText) < 1 then
					showToast(runScene, "密码不能为空", 2)
					return
				end

				if type(confirmFun) == "function" then
					confirmFun(editText)
				end
				layout:removeFromParent()
			end
		end
	end

	titleFile = titleFile or "RoomList/sp_pwtitle_room.png"
	--标题
	local sp = cc.Sprite:create(titleFile)
	bg:addChild(sp)
	sp:setPosition(bg_size.width * 0.5, bg_size.height - 50)

	ccui.Button:create("p_bt_close_0.png", "p_bt_close_1.png", "p_bt_close_0.png", UI_TEX_TYPE_PLIST)
		:move(bg_size.width -  50, bg_size.height - 50)
		:setTag(BT_CLOSE_DLG)
		:addTo(bg)
		:addTouchEventListener(btnEvent)

	ccui.Button:create("General/bt_confirm_0.png", "General/bt_confirm_1.png")
		:move(bg_size.width * 0.5, 50)
		:setTag(BT_CONFIRM)
		:addTo(bg)
		:addTouchEventListener(btnEvent)
end

function ClientScene:queryUserScoreInfo(queryCallBack)
	local ostime = os.time()
    local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx"

    self:showPopWait()
    appdf.onHttpJsionTable(url ,"GET","action=GetScoreInfo&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        self:dismissPopWait()
        dump(sjstable, "sjstable", 5)
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    local score = tonumber(data["Score"]) or 0
                    local bean = tonumber(data["Currency"]) or 0
                    local ingot = tonumber(data["UserMedal"]) or 0
                    local roomcard = tonumber(data["RoomCard"]) or 0

                    local needupdate = false
                    if score ~= GlobalUserItem.lUserScore 
                    	or bean ~= GlobalUserItem.dUserBeans
                    	or ingot ~= GlobalUserItem.lUserIngot
                    	or roomcard ~= GlobalUserItem.lRoomCard then
                    	GlobalUserItem.dUserBeans = bean
                    	GlobalUserItem.lUserScore = score
                    	GlobalUserItem.lUserIngot = ingot
                    	GlobalUserItem.lRoomCard = roomcard
                        needupdate = true
                    end
                    if needupdate then
                        print("update score")
                        --通知更新        
                        local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
                        eventListener.obj = yl.RY_MSG_USERWEALTH
                        cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
                    end 
                    if type(queryCallBack) == "function" then
                    	queryCallBack(needupdate)
                    end                   
                end
            end
        end
    end)
end

function ClientScene:queryTaskInfo()
	local taskResult = function(result, msg)
		if result == 1 then -- 获取到 SUB_GP_TASK_INFO
			if self.m_bFirstQueryCheckIn and nil ~= self._checkInFrame then
				self.m_bFirstQueryCheckIn = false
				if true == GlobalUserItem.bEnableCheckIn then
					--签到页面
					self._checkInFrame:onCheckinQuery()
				else
					if nil ~= self.m_touchFilter then
						self.m_touchFilter:dismiss()
						self.m_touchFilter = nil
					end
					-- 显示广告
					if GlobalUserItem.isShowAdNotice() then
						local webview = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.WebViewLayer"):create(self)
						local runScene = cc.Director:getInstance():getRunningScene()
						if nil ~= runScene then
							runScene:addChild(webview, yl.ZORDER.Z_AD_WEBVIEW)
						end
					end
				end
			end
			self:queryLevelInfo()
			if nil ~= self._taskFrame._gameFrame then
                self._taskFrame._gameFrame._shotFrame = nil
               self._taskFrame._gameFrame = nil
            end
			 self._taskFrame = nil
		end
	end
	self._taskFrame = TaskFrame:create(self, taskResult)
	self._taskFrame._gameFrame = self._gameFrame
   if nil ~= self._gameFrame then
        self._gameFrame._shotFrame = self._taskFrame
    end
	self._taskFrame:onTaskLoad()
end

function ClientScene:queryLevelInfo()
	local levelCallBack = function(result,msg)
			self:onLevelCallBack(result,msg)
		end
	self._levelFrame = LevelFrame:create(self,levelCallBack)	
	self._levelFrame:onLoadLevel()
end

function ClientScene:disconnectFrame()
	if nil ~= self._levelFrame and self._levelFrame:isSocketServer() then
		self._levelFrame:onCloseSocket()
		self._levelFrame = nil
	end

	if nil ~= self._checkInFrame and self._checkInFrame:isSocketServer() then
		self._checkInFrame:onCloseSocket()
		self._checkInFrame = nil
	end

	if nil ~= self._taskFrame and self._taskFrame:isSocketServer() then
		self._taskFrame:onCloseSocket()

		if nil ~= self._taskFrame._gameFrame then
            self._taskFrame._gameFrame._shotFrame = nil
            self._taskFrame._gameFrame = nil
        end
        self._taskFrame = nil
	end
end

function ClientScene:coinDropDownAni( funC )	
	local runScene = cc.Director:getInstance():getRunningScene()
	if nil == runScene then
		return
	end
	ExternalFun.popupTouchFilter(1, false)
	if nil == self.m_nodeCoinAni then		
		self.m_nodeCoinAni = ExternalFun.loadCSB( "plaza/CoinAni.csb", runScene)
		self.m_nodeCoinAni:setPosition(30, yl.HEIGHT + 30)

		self.m_actCoinAni = ExternalFun.loadTimeLine( "plaza/CoinAni.csb" )
		ExternalFun.SAFE_RETAIN(self.m_actCoinAni)	
	end
	local function onFrameEvent( frame )
		if nil == frame then
            return
        end
        local str = frame:getEvent()
        print("frame event ==> "  .. str)
        if str == "drop_over" then
        	self.m_nodeCoinAni:setVisible(false)
        	self.m_nodeCoinAni:stopAllActions()
        	if type(funC) == "function" then
        		funC()
        	end
        	ExternalFun.dismissTouchFilter()
        end
	end
	self.m_actCoinAni:setFrameEventCallFunc(onFrameEvent)
		
	local child = runScene:getChildren() or {}
	local childCount = #child
	self.m_nodeCoinAni:setVisible(true)
	self.m_nodeCoinAni:setLocalZOrder(childCount + 1)
	self.m_nodeCoinAni:stopAllActions()
	self.m_actCoinAni:gotoFrameAndPlay(0,false)
	self.m_nodeCoinAni:runAction(self.m_actCoinAni)
end

function ClientScene:popTargetShare( callback )
	local TargetShareLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.TargetShareLayer")
	local lay = TargetShareLayer:create(callback)
	self:addChild(lay)
	lay:setLocalZOrder(yl.ZORDER.Z_TARGET_SHARE)
end

function ClientScene:createHelpBtn(pos, zorder, url, parent)
	parent = parent or self
	zorder = zorder or yl.ZORDER.Z_HELP_BUTTON
	url = url or yl.HTTP_URL
	local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:popHelpLayer(url, zorder)
        end
    end
	pos = pos or cc.p(100, 100)
	local btn = ccui.Button:create("pub_btn_introduce_0.png", "pub_btn_introduce_1.png", "pub_btn_introduce_0.png", UI_TEX_TYPE_PLIST)
	btn:setPosition(pos)
	btn:setName(HELP_BTN_NAME)
	btn:addTo(parent)
	btn:setLocalZOrder(zorder)
    btn:addTouchEventListener(btncallback)
end

function ClientScene:popHelpLayer( url, zorder)
	zorder = zorder or yl.ZORDER.Z_HELP_WEBVIEW
	local IntroduceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.IntroduceLayer")
	local lay = IntroduceLayer:create(self, url)
	lay:setName(HELP_LAYER_NAME)
	local runScene = cc.Director:getInstance():getRunningScene()
	if nil ~= runScene then
		runScene:addChild(lay)
		lay:setLocalZOrder(zorder)
	end
end

function ClientScene:createHelpBtn2(pos, zorder, nKindId, nType, parent)
	parent = parent or self
	zorder = zorder or yl.ZORDER.Z_HELP_BUTTON
	url = url or yl.HTTP_URL
	local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:popHelpLayer2(nKindId, nType, zorder)
        end
    end
	pos = pos or cc.p(100, 100)
	local btn = ccui.Button:create("pub_btn_introduce_0.png", "pub_btn_introduce_1.png", "pub_btn_introduce_0.png", UI_TEX_TYPE_PLIST)
	btn:setPosition(pos)
	btn:setName(HELP_BTN_NAME)
	btn:addTo(parent)
	btn:setLocalZOrder(zorder)
    btn:addTouchEventListener(btncallback)
end

function ClientScene:popHelpLayer2( nKindId, nType, nZorder)
	nZorder = nZorder or yl.ZORDER.Z_HELP_WEBVIEW
	local IntroduceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.IntroduceLayer")
	local lay = IntroduceLayer:createLayer(self, nKindId, nType)
	if nil ~= lay then
		lay:setName(HELP_LAYER_NAME)
		local runScene = cc.Director:getInstance():getRunningScene()
		if nil ~= runScene then
			runScene:addChild(lay)
			lay:setLocalZOrder(nZorder)
		end
	end
end

--appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.game.VoiceRecorderKit") --ethj 如果加上了,会一进大厅,背景音就从扬声器转到了听筒
function ClientScene:createVoiceBtn(pos, zorder, parent)
	parent = parent or self
	zorder = zorder or yl.ZORDER.Z_VOICE_BUTTON
	local function btncallback(ref, tType)
		if tType == ccui.TouchEventType.began then
			self:startVoiceRecord()
        elseif tType == ccui.TouchEventType.ended 
        	or tType == ccui.TouchEventType.canceled then
            self:stopVoiceRecord()
        end
    end
	pos = pos or cc.p(100, 100)
	local btn = ccui.Button:create("btn_voice_chat_0.png", "btn_voice_chat_1.png", "btn_voice_chat_0.png", UI_TEX_TYPE_PLIST)
	btn:setPosition(pos)
	btn:setName(VOICE_BTN_NAME)
	btn:addTo(parent)
	btn:setLocalZOrder(zorder)
    btn:addTouchEventListener(btncallback)
end

function ClientScene:startVoiceRecord()
	--防作弊不聊天
	if GlobalUserItem.isAntiCheat() then
		local runScene = cc.Director:getInstance():getRunningScene()
		showToast(runScene, "防作弊房间禁止聊天", 3)
		return
	end
	
	local lay = VoiceRecorderKit.createRecorderLayer(self, self._gameFrame)
	if nil ~= lay then
		lay:setName(VOICE_LAYER_NAME)
		self:addChild(lay)
	end
end

function ClientScene:stopVoiceRecord()
	local voiceLayer = self:getChildByName(VOICE_LAYER_NAME)
	if nil ~= voiceLayer then
		voiceLayer:removeRecorde()
	end
end

function ClientScene:cancelVoiceRecord()
	local voiceLayer = self:getChildByName(VOICE_LAYER_NAME)
	if nil ~= voiceLayer then
		voiceLayer:cancelVoiceRecord()
	end
end

-- 好友邀请
function ClientScene:inviteFriend(inviteFriend, gameKind, serverId, tableId, inviteMsg)
	local tab = {}
    tab.dwInvitedUserID = inviteFriend
    tab.wKindID = gameKind
    tab.wServerID = serverId
    tab.wTableID = tableId
    tab.szInviteMsg = inviteMsg
    FriendMgr:getInstance():sendInviteGame(tab)
end

-- 好友截图分享
function ClientScene:imageShareToFriend( toFriendId, imagepath, shareMsg )
	local param = imagepath
    if cc.FileUtils:getInstance():isFileExist(param) then
    	self:showPopWait()
        --发送上传头像
        local url = yl.HTTP_URL .. "/WS/Account.ashx?action=uploadshareimage"
        local uploader = CurlAsset:createUploader(url,param)
        if nil == uploader then
            showToast(self, "分享图上传异常", 2)
            return
        end
        local nres = uploader:addToFileForm("file", param, "image/png")
        --用户标示
        nres = uploader:addToForm("userID", GlobalUserItem.dwUserID)
        --分享用户
        nres = uploader:addToForm("suserID", toFriendId)
        --登陆时间差
        local delta = tonumber(currentTime()) - tonumber(GlobalUserItem.LogonTime)
        print("time delta " .. delta)
        nres = uploader:addToForm("time", delta .. "")
        --客户端ip
        local ip = MultiPlatform:getInstance():getClientIpAdress() or "192.168.1.1"
        nres = uploader:addToForm("clientIP", ip)
        --机器码
        local machine = GlobalUserItem.szMachine or "A501164B366ECFC9E249163873094D50"
        nres = uploader:addToForm("machineID", machine)
        --会话签名
        nres = uploader:addToForm("signature", GlobalUserItem:getSignature(delta))
        if 0 ~= nres then
            showToast(self, "上传表单提交异常,error code ==> " .. nres, 2)
            return
        end

        uploader:uploadFile(function(sender, ncode, msg)
            local logtable = {}
            logtable.msg = msg
            logtable.ncode = ncode
            local jsonStr = cjson.encode(logtable)
            LogAsset:getInstance():logData(jsonStr,true)

            local ok, msgTab = pcall(function()
				return cjson.decode(msg)
			end)
            if ok then
            	local dataTab = msgTab["data"]
            	if type(dataTab) == "table" then
            		local address = ""
            		if true == dataTab["valid"] then
            			address = dataTab["ShareUrl"] or ""
            		end
            		local tab = {}
		            tab.dwSharedUserID = toFriendId
		            tab.szShareImageAddr = address
		            tab.szMessageContent = shareMsg
		            tab.szImagePath = imagepath
		            if FriendMgr:getInstance():sendShareMessage(tab) then
		            	showToast(self, "分享成功!", 2)
		           	end
            	end
            else

            end
            self:dismissPopWait()
        end)
    else
    	showToast(self, "您要分享的图片不存在, 请重试", 2)
    end
end

return ClientScene
