--[[
	商城界面
	2016_06_28 Ravioyla

    包含 JunFuTongPay ShopPay ShopLayer 三个类
]]


local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local ClientConfig = appdf.req(appdf.BASE_SRC .."app.models.ClientConfig")
local ShopFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ShopFrame")

local CBT_WECHAT = 101
local CBT_ALIPAY = 102
local CBT_JFT = 103

local BT_ZHIFUBAO			= 1001
local BT_WEIXIN				= 1002

local PAYTYPE = {}
PAYTYPE[CBT_WECHAT] =
{
    str = "wx",
    plat = yl.ThirdParty.WECHAT
}
PAYTYPE[CBT_ALIPAY] =
{
    str = "zfb",
    plat = yl.ThirdParty.ALIPAY
}
PAYTYPE[CBT_JFT] =
{
    str = "jft",
    plat = yl.ThirdParty.JFT
}

--竣付通页面
local JunFuTongPay = class("ShopPay", cc.Layer)
local JFT_RETURN = 1
function JunFuTongPay:ctor(parent, itemname, price, paylist, token)
    self.m_parent = parent
    self.m_parent.m_bJunfuTongPay = true
    GlobalUserItem.bJftPay = true
    self.m_token = token

    self.m_buyItemType = nil

    ExternalFun.registerTouchEvent(self, true)
    local btnpos =
    {
        {cc.p(0.5, 0.3)},
        {cc.p(0.35, 0.3), cc.p(0.65, 0.3)},
    }

    --加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("Shop/JunFuTongPay.csb", self)

    --背景
    local bg = csbNode:getChildByName("pay_bg")
    local bgsize = bg:getContentSize()

    itemname = itemname or ""
    price = price or 0

    --商品名称
    bg:getChildByName("text_name"):setString(itemname)

    --支付金额
    bg:getChildByName("text_price"):setString(price)

    --按钮回调
    local btcallback = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    --返回按钮
    local btn = bg:getChildByName("btn_return")
    btn:setTag(JFT_RETURN)
    btn:addTouchEventListener(btcallback)

    --微信支付
    btn = bg:getChildByName("jft_pay3")
    btn:addTouchEventListener(btcallback)
    btn:setVisible(true)
    btn:setEnabled(true)

    --支付宝支付
    btn = bg:getChildByName("jft_pay4")
    btn:addTouchEventListener(btcallback)
    btn:setVisible(true)
    btn:setEnabled(true)

    local str = ""
    local tpos = btnpos[#paylist] or {}
    for k,v in pairs(paylist) do
        str = "jft_pay" .. v
        local paybtn = bg:getChildByName(str)
        if nil ~= paybtn then
            paybtn:setEnabled(true)
            paybtn:setVisible(true)
            paybtn:setTag(v)
            local pos = tpos[k]
            if nil ~= pos then
                paybtn:setPosition(cc.p(pos.x * bgsize.width, pos.y * bgsize.height))
            end
        end
    end

    --调起支付
    self.m_bCallPay = false
    --监听
    local function eventCall( event )
        if true == self.m_bCallPay then
            self:queryUserScoreInfo()
        end
    end
    self.m_listener = cc.EventListenerCustom:create(yl.RY_JFTPAY_NOTIFY,handler(self, eventCall))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_listener, self)
end

function JunFuTongPay:queryUserScoreInfo()
    if nil ~= self.m_parent.queryUserScoreInfo then
        self.m_parent:queryUserScoreInfo(function(needUpdate)
            if true == needUpdate then
                self.m_parent:updateScoreInfo()
                --重新请求支付列表
                self.m_parent:reloadBeanList()
            end
            GlobalUserItem.bJftPay = false
            self:removeFromParent()
        end)
    end
end

function JunFuTongPay:onTouchBegan(touch, event)
    return self:isVisible()
end

function JunFuTongPay:onExit()
    if nil ~= self.m_listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_listener)
        self.m_listener = nil
    end
end

function JunFuTongPay:onButtonClickedEvent(tag, sender)
    print(tag)
    if tag == JFT_RETURN then
        self.m_parent.m_bJunfuTongPay = false
        GlobalUserItem.bJftPay = false
        --重新请求支付列表
        self.m_parent:reloadBeanList()
        self:removeFromParent()
    else
        local plat = 0
        local str = ""
        if 3 == tag then
            plat = yl.ThirdParty.WECHAT
            str = "微信未安装,无法进行微信支付"
        elseif 4 == tag then
            plat = yl.ThirdParty.ALIPAY
            str = "支付宝未安装,无法进行支付宝支付"
        end
        --判断应用是否安装
        if false == MultiPlatform:getInstance():isPlatformInstalled(plat) then
            showToast(self, str, 2, cc.c4b(250,0,0,255))
            return
        end
        self.m_parent:showPopWait()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
            self.m_parent:dismissPopWait()
            end)))
        local function payCallBack(param)
            --[[self.m_parent:dismissPopWait()
            if type(param) == "string" and "true" == param then
                GlobalUserItem.setTodayPay()

                showToast(self, "支付成功", 5)
                --更新用户游戏豆
                GlobalUserItem.lUserInsure = GlobalUserItem.lUserInsure + self.m_nCount*13000
                --通知更新
                local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
                eventListener.obj = yl.RY_MSG_USERWEALTH
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

                self:hide()
                --重新请求支付列表
                self.m_parent:reloadBeanList()
            else
                showToast(self, "支付异常", 3)
            end]]
        end
        self.m_bCallPay = true
        MultiPlatform:getInstance():thirdPartyPay(PAYTYPE[CBT_JFT].plat, {paytype = tag, token = self.m_token}, payCallBack)
    end
end

--支付选择页面
local ShopPay = class("ShopPay", cc.Layer)


local BT_CLOSE = 201
local BT_SURE = 202
local BT_CANCEL = 203

function ShopPay:ctor(parent)
	self.m_parent = parent
	--价格
	self.m_fPrice = 0.00
	--数量
	self.m_nCount = 0
    -- appid
    self.m_nAppId = 0

	--注册触摸事件
	ExternalFun.registerTouchEvent(self, true)

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Shop/ShopPayLayer.csb", self)

	self.m_spBgKuang = csbNode:getChildByName("shop_pay_bg")
	self.m_spBgKuang:setScale(0.0001)
	local bg = self.m_spBgKuang

	--商品
	self.m_textProName = bg:getChildByName("text_name")
	self.m_textProName:setString("")

	--价格
	self.m_textPrice = bg:getChildByName("text_price")
	self.m_textPrice:setString("")

	--按钮回调
	local btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
    --关闭按钮
    local btn = bg:getChildByName("btn_close")
    btn:setTag(BT_CLOSE)
    btn:addTouchEventListener(btcallback)

    --确定按钮
    btn = bg:getChildByName("btn_sure")
    btn:setTag(BT_SURE)
    btn:addTouchEventListener(btcallback)

    --取消按钮
    btn = bg:getChildByName("btn_cancel")
    btn:setTag(BT_CANCEL)
    btn:addTouchEventListener(btcallback)

	local cbtlistener = function (sender,eventType)
    	self:onSelectedEvent(sender:getTag(),sender)
    end

    local enableList = {}
    --微信支付
    local cbt = bg:getChildByName("check_wechat")
    cbt:setTag(CBT_WECHAT)
    cbt:setSelected(true)
    cbt:addEventListener(cbtlistener)
    cbt:setVisible(true)
    cbt:setEnabled(true)
    self.m_cbtWeChat = cbt
    if yl.WeChat.PartnerID ~= " " and yl.WeChat.PartnerID ~= "" then
        table.insert(enableList, "check_wechat")
    end
    local wpos = cc.p(self.m_cbtWeChat:getPositionX(), self.m_cbtWeChat:getPositionY())
    local wtext = bg:getChildByName("check_wechat_t")
    wtext:setVisible(false)
    local wtpos = cc.p(wtext:getPositionX(), wtext:getPositionY())

    --支付宝支付
    cbt = bg:getChildByName("check_alipay")
    cbt:setTag(CBT_ALIPAY)
    cbt:setSelected(false)
    cbt:addEventListener(cbtlistener)
    cbt:setVisible(true)
    cbt:setEnabled(true)
    self.m_cbtAlipay = cbt
    if yl.AliPay.PartnerID ~= " " and yl.AliPay.PartnerID ~= "" then
        table.insert(enableList, "check_alipay")
    end
    local apos = cc.p(self.m_cbtAlipay:getPositionX(), self.m_cbtAlipay:getPositionY())
    local atext = bg:getChildByName("check_alipay_t")
    atext:setVisible(false)
    local atpos = cc.p(atext:getPositionX(), atext:getPositionY())

    --竣付通支付
    cbt = bg:getChildByName("check_jft")
    cbt:setTag(CBT_JFT)
    cbt:setSelected(false)
    cbt:addEventListener(cbtlistener)
    cbt:setVisible(false)
    cbt:setEnabled(false)
    self.m_cbtJft = cbt
    if yl.JFT.PartnerID ~= " " and yl.JFT.PartnerID ~= "" then
        table.insert(enableList, "check_jft")
    end
    local jpos = cc.p(self.m_cbtJft:getPositionX(), self.m_cbtJft:getPositionY())
    local jtext = bg:getChildByName("check_jft_t")
    jtext:setVisible(false)
    local jtpos = cc.p(jtext:getPositionX(), jtext:getPositionY())

    local cbtPosition =
    {
        {wpos},
        {wpos, apos},
        {wpos, apos, jpos}
    }
    local textPosition =
    {
        {wtpos},
        {wtpos, atpos},
        {wtpos, atpos, jtpos}
    }
    local poslist = cbtPosition[#enableList]
    local tposlist = textPosition[#enableList]
    for k,v in pairs(enableList) do
        local tmp = bg:getChildByName(v)
        if nil ~= tmp then
            tmp:setEnabled(true)
            tmp:setVisible(true)

            if v == "check_wechat" or v == "check_alipay" then
                tmp:setVisible(false)
            end

            local pos = poslist[k]
            if nil ~= pos then
                tmp:setPosition(pos)
            end
        end
        tmp = bg:getChildByName(v .. "_t")
        if nil ~= tmp then
            tmp:setVisible(true)
            if v == "check_wechat" or v == "check_alipay" then
                tmp:setVisible(false)
            end
            local pos = tposlist[k]
            if nil ~= pos then
                tmp:setPosition(pos)
            end
        end
    end

    self.m_select = nil
    if #enableList > 0 then
        local tmp = bg:getChildByName(enableList[1])
        if nil ~= tmp then
            tmp:setSelected(true)
            self.m_select = tmp:getTag()
        end
    end

    local cbtlistener2 = function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:btnTouchCbk(sender:getTag(),sender)
        end
    end

     -- 支付宝按钮
    local btnZhifubao = bg:getChildByName("btn_zhifubao")
    btnZhifubao:setTag(BT_ZHIFUBAO)
    btnZhifubao:addTouchEventListener( cbtlistener2)

    -- 微信按钮
    local btnWeixin = bg:getChildByName("btn_weixin")
    btnWeixin:setTag(BT_WEIXIN)
    btnWeixin:addTouchEventListener( cbtlistener2)

	--加载动画
	self.m_actShowAct = cc.ScaleTo:create(0.2, 1.0)
	ExternalFun.SAFE_RETAIN(self.m_actShowAct)

	local scale = cc.ScaleTo:create(0.2, 0.0001)
	local call = cc.CallFunc:create(function( )
		self:showLayer(false)
	end)
	self.m_actHideAct = cc.Sequence:create(scale, call)
	ExternalFun.SAFE_RETAIN(self.m_actHideAct)

	self:showLayer(false)
end

function ShopPay:btnTouchCbk(tag, sender)
    if BT_ZHIFUBAO == tag then
        self.m_select = CBT_ALIPAY
        self:onButtonClickedEvent(BT_SURE, nil)
    elseif BT_WEIXIN == tag then
        self.m_select = CBT_WECHAT
        self:onButtonClickedEvent(BT_SURE, nil)
    else

    end
end

function ShopPay:isPayMethodValid()
    if (yl.WeChat.PartnerID ~= " " and yl.WeChat.PartnerID ~= "")
        or (yl.AliPay.PartnerID ~= " " and yl.AliPay.PartnerID ~= "")
        or (yl.JFT.PartnerID ~= " " and yl.JFT.PartnerID ~= "")
    then
        return true
    else
        return false
    end
end

function ShopPay:showLayer(var)
	self:setVisible(var)

	if true == var then
		self.m_spBgKuang:stopAllActions()
		self.m_spBgKuang:runAction(self.m_actShowAct)
	end
end

function ShopPay:refresh(count, name, sprice, fprice, appid)
	self.m_textProName:setString(name)
	self.m_textPrice:setString(sprice)

	self.m_fPrice = fprice
	self.m_nCount = count
    self.m_nAppId = appid
end

function ShopPay:onButtonClickedEvent(tag, sender)
	if tag == BT_CLOSE or tag == BT_CANCEL then
		self:hide()
	elseif tag == BT_SURE then
        if nil == self.m_select then
            return
        end

        local str = "无法支付"
        local plat = PAYTYPE[self.m_select].plat
        if yl.ThirdParty.WECHAT == PAYTYPE[self.m_select].plat then
            plat = yl.ThirdParty.WECHAT
            str = "微信未安装,无法进行微信支付"
        elseif yl.ThirdParty.ALIPAY == PAYTYPE[self.m_select].plat then
            plat = yl.ThirdParty.ALIPAY
            str = "支付宝未安装,无法进行支付宝支付"
        end
        --判断应用是否安装
        if false == MultiPlatform:getInstance():isPlatformInstalled(plat) and plat ~= yl.ThirdParty.JFT then
            showToast(self, str, 2, cc.c4b(250,0,0,255))
            return
        end

		self.m_parent:showPopWait()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
            self.m_parent:dismissPopWait()
            end)))
		--生成订单
	--	local url = yl.HTTP_URL .. "/Pay/signatures_url.aspx“
        local url = yl.HTTP_URL .. "/Pay/signatures_url.aspx"

       local account = GlobalUserItem.dwGameID
       local count = self.m_fPrice

       if self.m_select == CBT_WECHAT then --微信支付
           url = yl.HTTP_URL .. "/Pay/wxapppay.aspx"
           count=self.m_fPrice*100--微信是按分来
       end






		local action = "gameid=" .. account .. "&count=" .. count .. "&username=" .. GlobalUserItem.szAccount .."&lua=1"
       --print(action)
		appdf.onHttpJsionTable(url,"GET",action,function(jstable,jsdata)
            dump(jstable, "jstable", 6)
			if type(jstable) == "table" then
				local data = jstable["data"]
				if type(data) == "table" then
					if nil ~= data["valid"] and true == data["valid"] then
						local payparam = {}
					if self.m_select == CBT_WECHAT then --微信支付
							--获取微信支付订单id
							local paypackage = data["PayPackage"]
							if type(paypackage) == "string" then
								local ok, paypackagetable = pcall(function()
					       			return cjson.decode(paypackage)
					    	end)
					    		if ok then
					    			local payid = paypackagetable["prepayid"]
					    			if nil == payid then
										showToast(self, "微信支付订单获取异常", 2)
										return
									end
									payparam["info"] = paypackagetable
					    		else
					    			showToast(self, "微信支付订单获取异常", 2)
					    			return
					    		end
							end
						elseif self.m_select == CBT_JFT then --竣付通支付
                            self:onJunFuTongPay(data)
                            return
                        end
						--订单id
						payparam["orderid"] = data["notice"]
						--价格
						payparam["price"] = self.m_fPrice
						--商品名
						payparam["name"] = self.m_textProName:getString()




						local function payCallBack(param)
                            print("param is ",param)
							self.m_parent:dismissPopWait()
							if type(param) == "string" and "true" == param then
                                GlobalUserItem.setTodayPay()


								--更新用户游戏豆
								GlobalUserItem.lUserInsure = GlobalUserItem.lUserInsure + self.m_fPrice*13000
								--通知更新
								local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
							    eventListener.obj = yl.RY_MSG_USERWEALTH
							    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

                               self:hide()
                                --重新请求支付列表
                              --  self.m_parent:reloadBeanList()

                                self.m_parent:updateScoreInfo()
                              showToast(self, "支付成功", 5)

							else
								showToast(self, "支付异常", 3)
							end
						end
						MultiPlatform:getInstance():thirdPartyPay(PAYTYPE[self.m_select].plat, payparam, payCallBack)
					else
                        if type(jstable["msg"]) == "string" and jstable["msg"] ~= "" then
                            showToast(self, jstable["msg"], 2)
                       end
                    end
				end
			end
		end)
	end
end

function ShopPay:onSelectedEvent(tag, sender)
	if self.m_select == tag then
		self.m_spBgKuang:getChildByTag(tag):setSelected(true)
		return
	end

	self.m_select = tag

	for i=101,103 do
		if i ~= tag then
			self.m_spBgKuang:getChildByTag(i):setSelected(false)
		end
	end

	--微信支付
	if (tag == CBT_WECHAT) then
		print("wechat")
	end

	--支付宝
	if (tag == CBT_ALIPAY) then
		print("alipay")
	end

	--俊付通
	if (tag== CBT_JFT) then
		print("jft")
	end
end

function ShopPay:onTouchBegan(touch, event)
	return self:isVisible()
end

function ShopPay:onTouchEnded(touch, event)
	local pos = touch:getLocation();
	local m_spBg = self.m_spBgKuang
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self:hide()
    end
end

function ShopPay:onExit()
	ExternalFun.SAFE_RELEASE(self.m_actShowAct)
	self.m_actShowAct = nil
	ExternalFun.SAFE_RELEASE(self.m_actHideAct)
	self.m_actHideAct = nil
end

function ShopPay:onJunFuTongPay(data)
    --请求token
    local uid = yl.JFT["PartnerID"]
    local oid = data["OrderID"] or ""
    local mon = "" .. self.m_fPrice
    local rurl = yl.JFT["NotifyURL"]
    local nurl = yl.JFT["NotifyURL"]
    local tt = os.date("*t")
    local odrdertime = string.format("%d%02d%02d%02d%02d%02d", tt.year, tt.month, tt.day, tt.hour, tt.min, tt.sec)
    local sign_str = uid .. "&" .. oid .. "&" .. mon .. "&" .. rurl .. "&" .. nurl .. "&" .. odrdertime .. yl.JFT["PayKey"]
    local md5_signstr = md5(sign_str)
    local postdata = string.format("p1_usercode=%s&p2_order=%s&p3_money=%s&p4_returnurl=%s&p5_notifyurl=%s&p6_ordertime=%s&p7_sign=%s&p9_paymethod=SDK&p24_remark=2045",
        uid,
        oid,
        mon,
        rurl,
        nurl,
        odrdertime,
        md5_signstr)
    appdf.onHttpJsionTable(yl.JFT["TokenURL"],"GET",postdata,function(tokentable,tokendata)
        self.m_parent:dismissPopWait()
        dump(tokentable, "tokentable", 6)
        local msg = "竣付通token获取失败"
        if type(tokentable) == "table" then
            local flag = tokentable["flag"] or "0"
            if flag == "1" then
                msg = nil
                local token = tokentable["token"] or ""
                --获取支付列表
                self.m_parent:showPopWait()
                MultiPlatform:getInstance():getPayList(token, function(listjson)
                    self.m_parent:dismissPopWait()
                    if type(listjson) == "string" and "" ~= listjson then
                        local ok, listtable = pcall(function()
                            return cjson.decode(listjson)
                        end)
                        if ok then
                            dump(listtable, "listtable", 6)
                            -- typeid=3 为微信， typeid=4为支付宝
                            local itemname = self.m_textProName:getString()
                            local itemprice = self.m_textPrice:getString()
                            local jft = JunFuTongPay:create(self.m_parent, itemname, itemprice, listtable, token)
                            self.m_parent:addChild(jft)
                            self:hide()
                        end
                    end
                end)
            end
        end

        if type(msg) == "string" and "" ~= msg then
            showToast(self, msg, 3, cc.c4b(250,0,0,255))
        end
    end)
end

function ShopPay:hide()
    self.m_spBgKuang:stopAllActions()
    self.m_spBgKuang:runAction(self.m_actHideAct)
end

--商城页面
local ShopLayer = class("ShopLayer", function(scene)
		local shopLayer = display.newLayer(cc.c4b(0, 0, 0, 125))
    return shopLayer
end)

local PurchaseMember =  appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.PurchaseMember")
local BankFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BankFrame")
ShopLayer.SHOPITEMDIAMONDS = {"BlueDiamond.png", "YellowDiamond.png", "WhiteDiamond.png", "VIPDiamond.png","icon_laba.png"}
ShopLayer.CBT_SCORE			= 1
ShopLayer.CBT_BEAN			= 2
ShopLayer.CBT_VIP			= 3
ShopLayer.CBT_PROPERTY		= 4
ShopLayer.CBT_ENTITY		= 5
--特权商城
ShopLayer.CBT_PRIVILEGE		= 6

ShopLayer.BT_SCORE			= 30
ShopLayer.BT_VIP			= 50
ShopLayer.BT_PROPERTY		= 60
ShopLayer.BT_GOODS			= 120
ShopLayer.BT_BEAN			= 520
ShopLayer.BT_PRIVILEGE		= 600

ShopLayer.BT_ORDERRECORD    = 1001
ShopLayer.BT_BAG            = 1002

local SHOP_BUY = {}
SHOP_BUY[ShopLayer.BT_SCORE] = "shop_score_buy"
SHOP_BUY[ShopLayer.BT_BEAN] = "shop_bean_buy"
SHOP_BUY[ShopLayer.BT_VIP] = "shop_vip_buy"
SHOP_BUY[ShopLayer.BT_PROPERTY] = "shop_prop_buy"
SHOP_BUY[ShopLayer.BT_GOODS] = "shop_goods_buy"
SHOP_BUY[ShopLayer.BT_PRIVILEGE] = "shop_privilege"

-- 支付模式
local APPSTOREPAY = 10 -- iap支付
local THIRDPAY = 20 -- 第三方支付

-- 进入场景而且过渡动画结束时候触发。
function ShopLayer:onEnterTransitionFinish()

    --====查询银行存款 start ======
    self:showPopWait()
    self._bankFrame:onGetBankInfo()
    --====查询银行存款 end ======

	--self:loadPropertyAndVip(ShopLayer.CBT_BEAN)
	if 0 == table.nums(self._shopTypeIdList) then
		self:getShopPropertyType()
    else
        --刷新界面显示
        self:updateCheckBoxList()
	end
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function ShopLayer:onExitTransitionStart()
    return self
end

--scene
--stmod 进入商店后的选择类型
function ShopLayer:ctor(scene, stmod,gameFrame,curtag)
	stmod = stmod or ShopLayer.CBT_SCORE
    self.m_nPayMethod = GlobalUserItem.tabShopCache["nPayMethod"] or THIRDPAY

	local this = self
	self._scene = scene
    self._curtag=curtag --当前页面

	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
        elseif eventType == "exit" then
            if self._ShopFrame:isSocketServer() then
                self._ShopFrame:onCloseSocket()
            end
            if nil ~= self._ShopFrame._gameFrame then
                self._ShopFrame._gameFrame._shotFrame = nil
                self._ShopFrame._gameFrame = nil
            end
		end
	end)

    --  ======================================= 特权商城

    --网络回调
    local TQSCCallBack = function(result,message)
		this:onShopCallBack(result,message)
	end
	--网络处理
	self._ShopFrame = ShopFrame:create(self,TQSCCallBack)
    self._ShopFrame._gameFrame = gameFrame
    if nil ~= gameFrame then
        gameFrame._shotFrame = self._ShopFrame
    end
    --  ======================================= 特权商城

    --====查询银行存款 start ======

    --网络回调
    local  bankCallBack = function(result,message)
		this:onBankCallBack(result,message)
	end
    --银行存款 回调
	self._bankFrame = BankFrame:create(self,bankCallBack)
    self._bankFrame._gameFrame = gameFrame
    if nil ~= gameFrame then
        gameFrame._shotFrame = self._bankFrame
    end
    --====查询银行存款 end ======

	--按钮回调
	self._btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    local cbtlistener = function (sender,eventType)
    	this:onSelectedEvent(sender:getTag(),sender,eventType)
    end

    self._select = stmod

	self._showList = {}

	self._scoreList = GlobalUserItem.tabShopCache["shopScoreList"] or {}
    self._propertyList = GlobalUserItem.tabShopCache["shopPropertyList"] or {}
    self._vipList = GlobalUserItem.tabShopCache["shopVipList"] or {}
    --游戏豆购买列表
    self._beanList = GlobalUserItem.tabShopCache["shopBeanList"] or {}
    --实物兑换页面
    self._goodsList = nil
    --商店物品typeid
    self._shopTypeIdList = GlobalUserItem.tabShopCache["shopTypeIdList"] or {}
    --购买界面
    self.m_payLayer = nil
    --购买汇率
    self.m_nRate = GlobalUserItem.tabShopCache["shopRate"] or 0
    --竣付通支付界面
    self.m_bJunfuTongPay = false
    --道具关联信息
    self.m_tabPropertyRelate = GlobalUserItem.tabShopCache["propertyRelate"] or {}

--    display.newSprite("Shop/frame_shop_0.png")
--		:move(yl.WIDTH/2,yl.HEIGHT - 51)
--		:addTo(self)
--	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sp_public_frame_0.png")
--	if nil ~= frame then
--		local sp = cc.Sprite:createWithSpriteFrame(frame)
--		sp:setPosition(yl.WIDTH/2,320)
--		self:addChild(sp)
--	end


    local spriteMainBg = cc.Scale9Sprite:create("public/dialogframe.png")
    spriteMainBg:setCapInsets(CCRectMake(311,184,20,26))
    spriteMainBg:setContentSize(cc.size(1280, 680))
    spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(spriteMainBg)

	display.newSprite("Shop/title_shop.png")
		:move(yl.WIDTH/2,yl.HEIGHT-75)
		:addTo(self)
	--返回
	ccui.Button:create("public/closebtn.png","public/closebtn.png")
    	:move(1300,yl.HEIGHT-100)
    	:addTo(self)
    	:addTouchEventListener(function(ref, type)
       		 	if type == ccui.TouchEventType.ended then
					this._scene:onKeyBack()
				end
			end)

    --兑换记录
    local topBtn = ccui.Button:create("Information/btn_ubag_0.png","Information/btn_ubag_1.png")
    topBtn:move(yl.WIDTH - 90,yl.HEIGHT-51)
        :addTo(self)
        :setTag(ShopLayer.BT_BAG)
        :addTouchEventListener(function(ref, tType)
                if tType == ccui.TouchEventType.ended then
                    local tag = ref:getTag()
                    if tag == ShopLayer.BT_ORDERRECORD then
                        this._scene:onChangeShowMode(yl.SCENE_ORDERRECORD)
                    elseif tag == ShopLayer.BT_BAG then
                        this._scene:onChangeShowMode(yl.SCENE_BAG)
                    end
                end
            end)
    topBtn:setVisible(false)
    self.m_btnTopBtn = topBtn

    -- 金币
    local spriteItemBg0 = cc.Scale9Sprite:create("public/dialogcontentbg.png")
    spriteItemBg0:setCapInsets(CCRectMake(40,40,42,42))
    spriteItemBg0:setContentSize(cc.size(400, 80))
    spriteItemBg0:setPosition(230, 550)
    spriteMainBg:addChild(spriteItemBg0)
    display.newSprite("Shop/icon_gold.png")
		:move(40, spriteItemBg0:getContentSize().height/2)
		:addTo(spriteItemBg0)
    cc.LabelAtlas:_create(string.formatNumberThousands(GlobalUserItem.lUserScore,true,"/"), "Shop/num_shop_0.png", 16, 22, string.byte("."))
    		:move(80, spriteItemBg0:getContentSize().height/2)
    		:setAnchorPoint(cc.p(0,0.5))
            :setName("_txtGold")
    		:addTo(spriteItemBg0)
    self._txtGold = spriteItemBg0:getChildByName("_txtGold")

    -- 金豆
    local spriteItemBg_bean = cc.Scale9Sprite:create("public/dialogcontentbg.png")
    spriteItemBg_bean:setCapInsets(CCRectMake(40,40,42,42))
    spriteItemBg_bean:setContentSize(cc.size(400, 80))
    spriteItemBg_bean:setPosition(230 + 500, 550)
    spriteMainBg:addChild(spriteItemBg_bean)
  --  display.newSprite("Shop/icon_bean.png")
    display.newSprite("Shop/icon_gold.png")
    :move(20, spriteItemBg_bean:getContentSize().height/2)
		:addTo(spriteItemBg_bean)
    cc.LabelAtlas:_create(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,"/"), "Shop/num_shop_0.png", 16, 22, string.byte("."))
    		:move(80, spriteItemBg0:getContentSize().height/2)
            :setName("_txtBean")
    		:setAnchorPoint(cc.p(0,0.5))
    		:addTo(spriteItemBg_bean)
    self._txtBean = spriteItemBg_bean:getChildByName("_txtBean")

    -- 左侧背景框
    local spriteItemBg1 = cc.Scale9Sprite:create("public/dialogcontentbg.png")
    spriteItemBg1:setCapInsets(CCRectMake(40,40,42,42))
    spriteItemBg1:setContentSize(cc.size(260, 480))
    spriteItemBg1:setPosition(150, 260)
    spriteMainBg:addChild(spriteItemBg1)

     --右侧背景框
    local spriteItemBg2 = cc.Scale9Sprite:create("public/dialogcontentbg.png")
    spriteItemBg2:setCapInsets(CCRectMake(40,40,42,42))
    spriteItemBg2:setContentSize(cc.size(950, 480))
 --   spriteItemBg2:setPosition(780, 295)
    spriteItemBg2:setPosition(780, 260)
    spriteMainBg:addChild(spriteItemBg2)


    local cbPositionX = 170
    local cbPositionYStart = 470
    local cbIntervalY = 115


    --==============================================================特权商城    不同体系
    ccui.CheckBox:create("Shop/btn.png","","Shop/btn_on.png","","")
		:move(cbPositionX,cbPositionYStart-cbIntervalY)
		:addTo(self)
		:setSelected(false)
        :setVisible(true)
        :setEnabled(true)
        :setName("check" .. 10)
		:setTag(ShopLayer.CBT_PRIVILEGE)
		:addEventListener(cbtlistener)

    local cTeQuan = self:getChildByTag(ShopLayer.CBT_PRIVILEGE)
    local cbSize = cTeQuan:getContentSize()
    display.newSprite("Shop/tqsc.png")
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(cTeQuan)
    --==============================================================特权商城 end

    --游戏币
    ccui.CheckBox:create("Shop/btn.png","","Shop/btn_on.png","","")
		:move(cbPositionX,cbPositionYStart)
		:addTo(self)
		:setSelected(false)
        :setVisible(false)
        :setEnabled(false)
        :setName("check" .. 5)
		:setTag(ShopLayer.CBT_SCORE)
		:addEventListener(cbtlistener)

    local ckYouxibi = self:getChildByTag(ShopLayer.CBT_SCORE)
    local cbSize = ckYouxibi:getContentSize()
    display.newSprite("Shop/youxibiwenzi.png")
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(ckYouxibi)


	--游戏豆
    ccui.CheckBox:create("Shop/btn.png","","Shop/btn_on.png","","")
		:move(cbPositionX,cbPositionYStart-cbIntervalY)
		:addTo(self)
		:setSelected(false)
        :setVisible(false)
        :setEnabled(false)
        :setName("check" .. 6)
		:setTag(ShopLayer.CBT_BEAN)
		:addEventListener(cbtlistener)

        local ckYouxidou = self:getChildByTag(ShopLayer.CBT_BEAN)
        display.newSprite("Shop/youxibiwenzi.png")
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(ckYouxidou)

	--VIP
    ccui.CheckBox:create("Shop/btn.png","","Shop/btn_on.png","","")
		:move(cbPositionX,cbPositionYStart-cbIntervalY*2)
		:addTo(self)
		:setSelected(false)
        :setVisible(false)
        :setEnabled(false)
        :setName("check" .. 7)
		:setTag(ShopLayer.CBT_VIP)
		:addEventListener(cbtlistener)

        local ckVIP = self:getChildByTag(ShopLayer.CBT_VIP)
        display.newSprite("Shop/vipwenzi.png")
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(ckVIP)

	--道具
    ccui.CheckBox:create("Shop/btn.png","","Shop/btn_on.png","","")
		:move(cbPositionX,cbPositionYStart-cbIntervalY*3)
		:addTo(self)
		:setSelected(false)
        :setVisible(false)
        :setEnabled(false)
        :setName("check" .. 8)
		:setTag(ShopLayer.CBT_PROPERTY)
		:addEventListener(cbtlistener)

        local ckDaoju = self:getChildByTag(ShopLayer.CBT_PROPERTY)
        display.newSprite("Shop/daojuwenzi.png")
		:move(cbSize.width/2, cbSize.height/2)
		:addTo(ckDaoju)

	--实物
    ccui.CheckBox:create("Shop/bt_shop_4_0.png","","Shop/bt_shop_4_1.png","","")
		:move(cbPositionX,cbPositionYStart-cbIntervalY*4)
		:addTo(self)
		:setSelected(false)
        :setVisible(false)
        :setEnabled(false)
        :setName("check" .. 9)
		:setTag(ShopLayer.CBT_ENTITY)
		:addEventListener(cbtlistener)
--    self.m_tabCheckBoxPosition =
--    {
--        {cc.p(190,530)},
--        {cc.p(190,530), cc.p(190,426)},
--        {cc.p(190,530), cc.p(190,426), cc.p(190,322)},
--        {cc.p(190,530), cc.p(190,426), cc.p(190,322), cc.p(190,218)},
--        {cc.p(190,530), cc.p(190,426), cc.p(190,322), cc.p(190,218), cc.p(190,114)},
--        {cc.p(190,530), cc.p(190,426), cc.p(190,322), cc.p(190,218), cc.p(190,114), cc.p(190,10)}
--    }

    self.m_tabCheckBoxPosition = {}
    for i=1,6 do
        self.m_tabCheckBoxPosition[i] = {}
        for j=1,i do
            self.m_tabCheckBoxPosition[i][j] = cc.p(cbPositionX,cbPositionYStart-cbIntervalY*(j-1))
        end
    end

    self.m_tabActiveCheckBox = GlobalUserItem.tabShopCache["shopActiveCheckBox"] or {}

	self._scrollView = ccui.ScrollView:create()
        :setContentSize(cc.size(938,520))
        :setAnchorPoint(cc.p(0.5, 0.5))
        --:setPosition(cc.p(805, 314))
        :setPosition(cc.p(805, 285))
        :setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        :setBounceEnabled(true)
        :setScrollBarEnabled(false)
        :addTo(self)

    self.m_PurchaseMemberDlg = PurchaseMember:create(self)
    self.m_PurchaseMemberDlg:addTo(self, yl.MAX_INT)
    self.m_PurchaseMemberDlg:setVisible(false)
end

--
function ShopLayer:updateCheckBoxList()
    local poslist = self.m_tabCheckBoxPosition[#self.m_tabActiveCheckBox]
    if nil == poslist then
        return
    end
    for k,v in pairs(self.m_tabActiveCheckBox) do
        local tmp = self:getChildByName(v)
        if nil ~= tmp then
            tmp:setEnabled(true)
            tmp:setVisible(true)

            local pos = poslist[k]
            if nil ~= pos then
                tmp:setPosition(pos)
            end
        end
    end

    --选择的类型
    local tmp = self:getChildByTag(self._select)
    if nil ~= tmp and tmp:isVisible() then
        tmp:setSelected(true)
        --请求物品列表
        self:loadPropertyAndVip(self._select)
    end
end

function ShopLayer:getShopPropertyType()
    self._scene:showPopWait()
	--appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/MobileInterface.ashx","GET","action=GetMobilePropertyType",function(jstable,jsdata)
    appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/GetMobilePropertyType.txt","GET","action=GetMobilePropertyType",function(jstable,jsdata)
    self._scene:dismissPopWait()
        dump(jstable, "jstable", 6)
        if type(jstable) == "table" then
			local data = jstable["data"]
			if type(data) == "table" then
				if nil ~= data["valid"] and true == data["valid"] then
					local list = data["list"]
					if type(list) == "table" then
						for k,v in pairs(list) do
                            --隐藏按钮
                            if v.TypeID == 6 then
							    self._shopTypeIdList["check" .. v.TypeID] = v
                                table.insert(self.m_tabActiveCheckBox, "check" .. v.TypeID)
                            end
						end
                        GlobalUserItem.tabShopCache["shopTypeIdList"] = self._shopTypeIdList
                        GlobalUserItem.tabShopCache["shopActiveCheckBox"] = self.m_tabActiveCheckBox
                        --刷新界面显示
                        self._select=2
                        self:updateCheckBoxList()
						return
					end
				end
			end

			local msg = jstable["msg"]
			if type(msg) == "string" then
				showToast(self, msg, 2)
			end
		end
	end)

end

--按键监听
function ShopLayer:onButtonClickedEvent(tag,sender)
    local beginPos = sender:getTouchBeganPosition()
    local endPos = sender:getTouchEndPosition()
    if math.abs(endPos.x - beginPos.x) > 30
        or math.abs(endPos.y - beginPos.y) > 30 then
        print("ShopLayer:onButtonClickedEvent ==> MoveTouch Filter")
        return
    end

	local name = sender:getName()
	if name == SHOP_BUY[ShopLayer.BT_SCORE] then
		--游戏币获取
		GlobalUserItem.buyItem = self._scoreList[tag-ShopLayer.BT_SCORE]
        if GlobalUserItem.buyItem.id == "game_score" and PriRoom then
            self:getParent():getParent():onChangeShowMode(PriRoom.LAYTAG.LAYER_EXCHANGESCORE, GlobalUserItem.buyItem.resultGold)
        else
            self:getParent():getParent():onChangeShowMode(yl.SCENE_SHOPDETAIL,name)
        end
	elseif name == SHOP_BUY[ShopLayer.BT_BEAN] then
		--游戏豆获取
        local item = self._beanList[tag - ShopLayer.BT_BEAN]
        if nil == item then
            return
        end
        local bThirdPay = true

         if ClientConfig.APPSTORE_VERSION
             and (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
             if self.m_nPayMethod == APPSTOREPAY then
                 bThirdPay = false
                 local payparam = {}
                 payparam.http_url = yl.HTTP_URL
                 payparam.uid = GlobalUserItem.dwUserID
                 payparam.productid = item.nProductID
                 payparam.price = item.price

                 self:showPopWait()
                 self:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
                     self:dismissPopWait()
                 end)))
                 showToast(self, "正在连接iTunes Store...", 4)
                 local function payCallBack(param)
                     if type(param) == "string" and "true" == param then
                         GlobalUserItem.setTodayPay()

                         showToast(self, "支付成功", 2)
                         --更新用户游戏豆
                        GlobalUserItem.lUserInsure = GlobalUserItem.lUserInsure + item.count*13000
                         --通知更新
                         local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
                         eventListener.obj = yl.RY_MSG_USERWEALTH
                         cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)

                        --重新请求支付列表
                         self:reloadBeanList()

                         self:updateScoreInfo()
                     else
                         showToast(self, "支付异常", 2)
                     end
                end
                 MultiPlatform:getInstance():thirdPartyPay(yl.ThirdParty.IAP, payparam, payCallBack)
             end
         end

        if bThirdPay then
            if false == ShopPay:isPayMethodValid() then
                showToast(self, "支付服务未开通!", 2, cc.c4b(250,0,0,255))
                return
            end
            if nil == self.m_payLayer then
                self.m_payLayer = ShopPay:create(self)
                self:addChild(self.m_payLayer)
            end
            local sprice = string.format("%.2f元", item.price)
            self.m_payLayer:refresh(item.count, item.description, sprice, item.price, item.appid)
            self.m_payLayer:showLayer(true)
        end
	elseif name == SHOP_BUY[ShopLayer.BT_VIP] then
		--vip购买
		GlobalUserItem.buyItem = self._vipList[tag-ShopLayer.BT_VIP]
		self:getParent():getParent():onChangeShowMode(yl.SCENE_SHOPDETAIL,name)
	elseif name == SHOP_BUY[ShopLayer.BT_PROPERTY] then
		--道具购买
		GlobalUserItem.buyItem = self._propertyList[tag-ShopLayer.BT_PROPERTY]
        if GlobalUserItem.buyItem.id == "room_card" and PriRoom then
            self:getParent():getParent():onChangeShowMode(PriRoom.LAYTAG.LAYER_BUYCARD, GlobalUserItem.buyItem)
        else
            self:getParent():getParent():onChangeShowMode(yl.SCENE_SHOPDETAIL,name)
        end
	elseif name == SHOP_BUY[ShopLayer.BT_PRIVILEGE] then
        --特权商城
        local temp_i=tag-ShopLayer.BT_PRIVILEGE
        local temp_arg3=1
        if temp_i>=4 then
           temp_i=temp_i+1
        end
        if temp_i>=6 then
        --修改喇叭标题
           temp_arg3=2
        end
dump(self._itemCountList[temp_i],"item",6)
        --弹框确认
        if temp_i~=6 then --喇叭暂时不能购买
            self.m_PurchaseMemberDlg:resetUI()
            self.m_PurchaseMemberDlg:setInfo({temp_i, self._itemCountList[temp_i]["lMemberPrice"],temp_arg3})
            self.m_PurchaseMemberDlg:setVisible(true)
        else
            showToast(self,"暂不支购买",2);
        end
	end
end

--发送购买特权
function ShopLayer:PurchaseMemberConfirm(itemid,num)
    self._ShopFrame:onSendPurchaseMember(itemid,num)
end

function ShopLayer:onSelectedEvent(tag,sender,eventType)

    --游戏房间暂不支持打开
	if (tag == ShopLayer.CBT_PRIVILEGE) then
        if self._curtag==yl.SCENE_ROOM or self._curtag==yl.SCENE_GAME then
            showToast(self, "请退出游戏房间再打开特权商城", 2)
            self:getChildByTag(tag):setSelected(false)
            return
        end
    end

	if self._select == tag then
		self:getChildByTag(tag):setSelected(true)
		return
	end

	self._select = tag

	for i=1,6 do
		if i ~= tag then
			self:getChildByTag(i):setSelected(false)
		end
	end
    --特权商城
	if (tag == ShopLayer.CBT_PRIVILEGE) then
    --请求特权商城信息
        self._ShopFrame:onSendQueryExchange()
	end

	--游戏币
	if (tag == ShopLayer.CBT_SCORE) then
		if 0 == #self._scoreList then
			self:loadPropertyAndVip(tag)
		else
			self:onUpdateScore()
		end
	end

	--游戏豆
	if (tag == ShopLayer.CBT_BEAN) then
		self:onClearShowList()
		if 0 == #self._beanList then
			self:loadPropertyAndVip(tag)
		else
			self:onUpdateBeanList()
		end
	end

	--vip
	if (tag==ShopLayer.CBT_VIP) then
		if (#self._vipList==0) then
			self:loadPropertyAndVip(tag)
		else
			self:onUpdateVIP();
		end
	end

	--道具
	if (tag==ShopLayer.CBT_PROPERTY) then
		if (#self._propertyList==0) then
			self:loadPropertyAndVip(tag)
		else
			self:onUpdateProperty()
		end
	end

    local topBtnTag = ShopLayer.BT_BAG
    local normalFile = "Information/btn_ubag_0.png"
    local pressFile = "Information/btn_ubag_1.png"
	--实物
	if (tag == ShopLayer.CBT_ENTITY) then
		self:onClearShowList()
		self:onUpdateGoodsList()

        topBtnTag = ShopLayer.BT_ORDERRECORD
        normalFile = "Shop/bt_shop_exchange_0.png"
        pressFile = "Shop/bt_shop_exchange_1.png"
	end
    self.m_btnTopBtn:setTag(topBtnTag)
    self.m_btnTopBtn:loadTextureNormal(normalFile)
    self.m_btnTopBtn:loadTexturePressed(pressFile)
end

--特权商城
--操作结果
function ShopLayer:onShopCallBack(result, message)
print("===================操作结果",result,message)
dump(message,"message",6)
	self._scene:dismissPopWait()
    if result==yl.SUB_GP_EXCHANGE_PARAMETER then
        --  特权商城
		if #message == 0 then
			showToast(self, "商品为空", 2)
			return
		end

    	self._itemCountList = {}

		for i=1,#message do
			local item = message[i]
	        table.insert(self._itemCountList,item)
		end
        self:onUpdateExchangeList()
    end
end

--网络请求
function ShopLayer:loadPropertyAndVip(tag)
	local this = self
    local typid = 0

    local cbt = self:getChildByTag(tag)
    if nil ~= cbt then
        if nil ~= self._shopTypeIdList[cbt:getName()] then
            typid = self._shopTypeIdList[cbt:getName()].TypeID
        end
    end

    --实物特殊处理
    if tag == ShopLayer.CBT_ENTITY then
    	self:onUpdateGoodsList()
    --游戏豆额外处理
    elseif tag == ShopLayer.CBT_BEAN then
        if 0 ~= #self._beanList then
            self:onUpdateBeanList()
            return
        end
    	self._scene:showPopWait()
        if ClientConfig.APPSTORE_VERSION
            and (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
             -- 内购开关
             appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/iosnotappstorepayswitch.txt","GET","action=iosnotappstorepayswitch",function(jstable,jsdata)
                 local errmsg = "获取支付配置异常!"
                 if type(jstable) == "table" then
                     local jdata = jstable["data"]
                     if type(jdata) == "table" then
                         local valid = jdata["valid"] or false
                         if true == valid then
                             errmsg = nil
                             local value = jdata["State"] or "0"
                             value = tonumber(value)
                             if 1 == value then
                                 GlobalUserItem.tabShopCache["nPayMethod"] = APPSTOREPAY
                                 self.m_nPayMethod = APPSTOREPAY
                                 self:requestPayList(1)
                             else
                                 GlobalUserItem.tabShopCache["nPayMethod"] = THIRDPAY
                                 self.m_nPayMethod = THIRDPAY
                                 -- 请求列表
                                 self:requestPayList(2)
                             end
                         end
                     end
                 end

                 self._scene:dismissPopWait()
                 if type(errmsg) == "string" and "" ~= errmsg then
                     showToast(self,errmsg,2,cc.c3b(250,0,0))
                 end
             end)
        else
            -- 请求列表
            self:requestPayList()
        end
    else
        if tag == ShopLayer.CBT_VIP and 0 ~= #self._vipList then
            self:onUpdateVIP()
            return
        elseif tag == ShopLayer.CBT_PROPERTY and 0 ~= #self._propertyList then
            self:onUpdateProperty()
            return
        elseif tag == ShopLayer.CBT_SCORE and 0 ~= #self._scoreList then
            self:onUpdateScore()
            return
        end
        self:requestPropertyList(typid, tag)
    end
end

function ShopLayer:requestPayList(isIap)
    isIap = isIap or 2
    local beanurl = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
    local ostime = os.time()

    self._scene:showPopWait()
    appdf.onHttpJsionTable(beanurl ,"GET","action=GetPayProduct&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime) .. "&typeID=" .. isIap,function(sjstable,sjsdata)
        dump(sjstable, "支付列表", 6)
        local errmsg = "获取支付列表异常!"

        self._scene:dismissPopWait()
        if type(sjstable) == "table" then
            local sjdata = sjstable["data"]
            local msg = sjstable["msg"]
            errmsg = nil
            if type(msg) == "string" then
                errmsg = msg
            end

            if type(sjdata) == "table" then
                local isFirstPay = sjdata["IsPay"] or "0"
                isFirstPay = tonumber(isFirstPay)
                local sjlist = sjdata["list"]
                if type(sjlist) == "table" then
                    for i = 1, #sjlist do
                        local sitem = sjlist[i]
                        local item = {}
                        item.price = sitem["Price"]
                        item.isfirstpay = isFirstPay
                        item.paysend = sitem["AttachCurrency"] or "0"
                        item.paysend = tonumber(item.paysend)
                        item.paycount = sitem["PresentCurrency"] or "0"
                        item.paycount = tonumber(item.paycount)
                        item.price = tonumber(item.price)
                        item.count = item.paysend + item.paycount
                        item.description  = sitem["Description"]
                        item.name = sitem["ProductName"]
                        item.sortid = tonumber(sitem["SortID"]) or 0
                        item.nOrder = 0
                        --item.appid = tonumber(sitem["AppID"])
                        item.appid = tonumber(sitem["AppID"]) or 1
                        item.nProductID = sitem["ProductID"] or ""

                        --首充赠送
                        if 0 ~= item.paysend then
                            --当日未首充
                            if 0 == isFirstPay then
                                item.nOrder = 1
                                table.insert(self._beanList, item)
                            end
                        else
                            table.insert(self._beanList, item)
                        end
                    end
                    table.sort(self._beanList, function(a,b)
                            if a.nOrder ~= b.nOrder then
                                return a.nOrder > b.nOrder
                            else
                                return a.sortid < b.sortid
                            end
                        end)
                    GlobalUserItem.tabShopCache["shopBeanList"] = self._beanList
                    self:onUpdateBeanList()
                end
            end
        end

        if type(errmsg) == "string" and "" ~= errmsg then
            showToast(self,errmsg,2,cc.c3b(250,0,0))
        end
    end)
end

function ShopLayer:requestPropertyList(nTypeID, tag)
    nTypeID = nTypeID or 0
    self._scene:showPopWait()
    appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/MobileInterface.ashx","GET","action=GetMobileProperty&TypeID=" .. nTypeID,function(jstable,jsdata)
        self._scene:dismissPopWait()
        dump(jstable, "jstable", 7)
        if type(jstable) == "table" then
            local code = jstable["code"]
            local tmpList = {}

            if tonumber(code) == 0 then
                local datax = jstable["data"]
                if datax then
                    local valid = datax["valid"]
                    if valid == true then
                        local listcount = datax["total"]
                        local list = datax["list"]
                        if type(list) == "table" then
                            for i=1,#list do
                                local id = list[i]["ID"];
                                if ( id ~= nil and id ~= 0 ) then
                                    local item = {}
                                    item.id = tonumber(list[i]["ID"])
                                    item.name = list[i]["Name"]
                                    item.bean = tonumber(list[i]["Cash"])
                                    item.gold = tonumber(list[i]["Gold"])
                                    item.ingot = tonumber(list[i]["UserMedal"])
                                    item.loveliness = tonumber(list[i]["LoveLiness"])
                                    item.resultGold = tonumber(list[i]["UseResultsGold"])
                                    item.description = list[i]["RegulationsInfo"]
                                    item.sortid = list[i]["SortID"] or "0"
                                    item.sortid = tonumber(item.sortid)
                                    item.minPrice = tonumber(list[i]["minPrice"]) or 0

                                    if (item.loveliness ~= 0) and (item.bean == 0 and item.gold == 0 and item.ingot == 0) then

                                    else
                                        if tag == ShopLayer.CBT_PROPERTY and item.id == 501 then
                                            if GlobalUserItem.bEnableRoomCard then
                                                item.id = "room_card"
                                                table.insert(tmpList, item)
                                            end
                                        elseif tag == ShopLayer.CBT_SCORE and item.id == 501 and 0 ~= item.resultGold then
                                            if GlobalUserItem.bEnableRoomCard then
                                                item.id = "game_score"
                                                item.minPrice = item.resultGold
                                                item.bean = 0
                                                item.gold = 0
                                                item.ingot = 0
                                                item.loveliness = 0
                                                table.insert(tmpList, item)
                                            end
                                        else
                                            table.insert(tmpList, item)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            --产品排序
            table.sort(tmpList, function(a,b)
                return a.sortid < b.sortid
            end)

            if tag == ShopLayer.CBT_VIP then
                GlobalUserItem.tabShopCache["shopVipList"] = tmpList
                self._vipList = tmpList
                self:onUpdateVIP()
            elseif tag == ShopLayer.CBT_PROPERTY then
                GlobalUserItem.tabShopCache["shopPropertyList"] = tmpList
                self._propertyList = tmpList
                self:onUpdateProperty()
            elseif tag == ShopLayer.CBT_SCORE then
                GlobalUserItem.tabShopCache["shopScoreList"] = tmpList
                self._scoreList = tmpList
                self:onUpdateScore()
            end
        else
            showToast(self,"抱歉，获取道具信息失败！",2,cc.c3b(250,0,0))
        end
    end)
end

function ShopLayer:reloadBeanList()
    self:onClearShowList()
    GlobalUserItem.tabShopCache["shopBeanList"] = {}
    self._beanList = {}
    self:loadPropertyAndVip(ShopLayer.CBT_BEAN)
end

--操作结果 银行存款
function ShopLayer:onBankCallBack(result,message)
	self:dismissPopWait()
	if  message ~= nil and message ~= "" then
		showToast(self._scene,message,2)
	end
	if result == self._bankFrame.OP_GET_BANKINFO then
        print("================ GlobalUserItem.lUserInsure onBankCallBack",GlobalUserItem.lUserInsure)
       -- self._txtBean:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,","))
        --self._txtBean:setString(string.stringEllipsis(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,","),self._enSize,self._cnSize,300))
        self._txtGold:setString(string.formatNumberThousands(GlobalUserItem.lUserScore,true,"/"))
        self._txtBean:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,"/"))
	end
end

function ShopLayer:updateScoreInfo()
    --[[
   self._txtGold:setString(string.formatNumberThousands(GlobalUserItem.lUserScore,true,"/"))
   self._txtBean:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,"/"))
   --]]
    --====查询银行存款 start ======
    self:showPopWait()
    self._bankFrame:onGetBankInfo()
    --====查询银行存款 end ======
end

--更新游戏币
function ShopLayer:onUpdateScore()
	self:onClearShowList()
	self:onUpdateShowList(self._scoreList,ShopLayer.BT_SCORE)
end

--更新游戏豆
function ShopLayer:onUpdateBeanList()
	self:onClearShowList()
	self:onUpdateShowList(self._beanList,ShopLayer.BT_BEAN)
end

--更新VIP
function ShopLayer:onUpdateVIP()
	self:onClearShowList()
	self:onUpdateShowList(self._vipList,ShopLayer.BT_VIP)
end

--更新道具
function ShopLayer:onUpdateProperty()
	self:onClearShowList()
	self:onUpdateShowList(self._propertyList,ShopLayer.BT_PROPERTY)
end

--更新特权商城
function ShopLayer:onUpdateExchangeList()
	self:onClearShowList()
    --添加喇叭数据
    local item={}
    item.cbMemberOrder = 6
    item.lMemberPrice = 5000000
    table.insert(self._itemCountList, item)
	self:onUpdateShowList(self._itemCountList,ShopLayer.BT_PRIVILEGE)
end

--更新实物兑换列表
function ShopLayer:onUpdateGoodsList()
	local url = yl.HTTP_URL .. "/SyncLogin.aspx?userid=" .. GlobalUserItem.dwUserID .. "&time=".. os.time() .. "&signature="..GlobalUserItem:getSignature(os.time()).."&url=/Mobile/Shop/Goods.aspx"
	if nil == self._goodsList then
		--平台判定
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
			self._goodsList = ccexp.WebView:create()
		    self._goodsList:setPosition(cc.p(805,324))
		    self._goodsList:setContentSize(cc.size(938,520))

            self._goodsList:setJavascriptInterfaceScheme("ryweb")
		    self._goodsList:setScalesPageToFit(true)
		    self._goodsList:setOnJSCallback(function ( sender, url )
                self:queryUserScoreInfo(function(ok)
                    if ok then
                        self:updateScoreInfo()
                        self._goodsList:reload()
                    end
                end)
		    end)

		    self._goodsList:setOnDidFailLoading(function ( sender, url )
		    	self._scene:dismissPopWait()
		    	print("open " .. url .. " fail")
		    end)
		    self._goodsList:setOnShouldStartLoading(function(sender, url)
		        print("onWebViewShouldStartLoading, url is ", url)
		        return true
		    end)
		    self._goodsList:setOnDidFinishLoading(function(sender, url)
		    	self._scene:dismissPopWait()
                ExternalFun.visibleWebView(self._goodsList, true)
		        print("onWebViewDidFinishLoading, url is ", url)
		    end)
		    self:addChild(self._goodsList)
		end
	end

	if nil ~= self._goodsList then
		self._scene:showPopWait()
        ExternalFun.visibleWebView(self._goodsList, false)
		self._goodsList:loadURL(url)
	end
end

--清除当前显示
function ShopLayer:onClearShowList()
	for i=1,#self._showList do
		self._showList[i]:removeFromParent()
	end
	self._showList = nil
	self._showList = {}

	if nil ~= self._goodsList then
        self._goodsList:removeFromParent()
        self._goodsList = nil
	end
end

--更新当前显示
function ShopLayer:onUpdateShowList(theList,tag)
	local bGold = (self._select==ShopLayer.CBT_SCORE)
	local bOther= (self._select~=ShopLayer.CBT_SCORE)
	local bBean = (self._select==ShopLayer.CBT_BEAN)
    --特权商城
	local bPrivilege = (self._select==ShopLayer.CBT_PRIVILEGE)

	--计算scroll滑动高度
	local scrollHeight = 0
    local cellHeight = 260
	if #theList<7 then
		scrollHeight = 520
		self._scrollView:setInnerContainerSize(cc.size(1130, 550))
	else
		scrollHeight = cellHeight * math.ceil(#theList / 3)--math.floor((#theList+math.floor(#theList%3))/3)
		self._scrollView:setInnerContainerSize(cc.size(1130, scrollHeight))
	end

	for i=1,#theList do
		local item = theList[i]

        --特权商城 排除数据4 红钻
        if 4 == item.cbMemberOrder and bPrivilege then
        else
            local temp_i
            if bPrivilege and item.cbMemberOrder and item.cbMemberOrder>=5 then
                temp_i=i-1
            else
                temp_i=i
            end

            self._showList[i] = cc.LayerColor:create(cc.c4b(100, 100, 100, 0), 281, 240)
                :move(160+math.floor((temp_i-1)%3)*310-130,scrollHeight-(8+120+math.floor((temp_i-1)/3)*220)-100)
                :addTo(self._scrollView)

            local btn = ccui.Button:create("Shop/frame_shop_7.png","Shop/frame_shop_7.png")
            btn:setContentSize(cc.size(281, 240))
                :move(130,120)
                :setScale(1.1, 0.86)
                :setTag(tag+temp_i)
                :setSwallowTouches(false)
                :setName(SHOP_BUY[tag])
                :addTo(self._showList[i])
                :addTouchEventListener(self._btcallback)

            local price = 0
            local sign = nil
            local pricestr = ""

            --物品信息
            local showSp = nil
            --标题
            local titleSp = nil
            if bBean then
                --   showSp = display.newSprite("Shop/icon_shop_5.png")
                showSp = display.newSprite("Shop/icon_shop_bean"..i..".png")
                local atlas = cc.LabelAtlas:_create(string.gsub(item.name .. "", "[.]", "/"), "Shop/num_shop_5.png", 20, 25, string.byte("/"))
                atlas:setAnchorPoint(cc.p(1.0,0.5))
                self._showList[i]:addChild(atlas)
                local name = display.newSprite("Shop/text_shop_0.png")
                name:setAnchorPoint(cc.p(0,0.5))
                self._showList[i]:addChild(name)
                local wid = (atlas:getContentSize().width + name:getContentSize().width) / 2
                atlas:setPosition(130 + (atlas:getContentSize().width - wid), 190)
                name:setPosition(atlas:getPositionX(), 190)

                price = item.price
                pricestr = string.formatNumberThousands(price,true,",").."元"

                --首充
                if nil ~= item.paysend and 0 ~= item.paysend then
                    local fsp = cc.Sprite:create("Shop/shop_firstpay_sp.png")
                    fsp:setAnchorPoint(cc.p(0,1.0))
                    fsp:setPosition(-8,248)
                    self._showList[i]:addChild(fsp)
                    local isFirstPay = item.isfirstpay == 0
                    btn:setEnabled(isFirstPay)
                end
            elseif bPrivilege then
                --特权商城
                local temp_i
                if item.cbMemberOrder>=5 then
                    temp_i=i-1
                else
                    temp_i=i
                end
                showSp = display.newSprite("Shop/"..ShopLayer.SHOPITEMDIAMONDS[temp_i])
                price = item.lMemberPrice/10000
                pricestr = price.."W金币/月"
                if item.cbMemberOrder==6 then
                    pricestr = price.."W金币/个"
                end
            else
                local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("icon_public_"..item.id..".png")
                if nil ~= frame then
                    showSp = cc.Sprite:createWithSpriteFrame(frame)
                end

                -- todo
                --if cc.FileUtils:getInstance():isFileExist("Shop/title_property_"..item.id..".png") then
                    --titleSp = display.newSprite("Shop/title_property_"..item.id..".png")
                -- end

                local titlelabel = cc.Label:createWithTTF(item.description, "fonts/round_body.ttf", 24)
                    :setTextColor(cc.c4b(255,255,255,255))
                    :setAnchorPoint(cc.p(0,0.5))
                    --  :setVisible(false)
                    :move(90,220)
                    :addTo(self._showList[i])

                local width = (cellHeight-titlelabel:getContentSize().width) * 0.5
                titlelabel:setPosition(width,190)

                sign = 0
                if item.bean == 0 then
                    if item.ingot == 0 then
                        if item.gold == 0 then
                            if item.loveliness == 0 then
                                price = item.minPrice
                                sign = 4
                            else
                                price = item.loveliness
                                sign = 3
                            end
                        else
                            price = item.gold
                            sign = 2
                        end
                    else
                        price = item.ingot
                        sign = 1
                    end
                else
                    price = item.bean
                end
                pricestr = string.formatNumberThousands(price,true,",")

                --
                local icon_star = cc.Sprite:create("Shop/icon_star_sp.png")
                if nil ~= icon_star then
                    icon_star:setPosition(130, 140)
                    self._showList[i]:addChild(icon_star, 1)
                end
            end

            if price == 0 then
                print("======= ***** 价格信息有误 ***** =======")
                return
            end

            if nil ~= showSp then
                showSp:setPosition(130, 120)
                self._showList[i]:addChild(showSp)
            end
            if nil ~= titleSp then
                titleSp:setPosition(130, 220)
                --titleSp:setVisible(bOther)
                self._showList[i]:addChild(titleSp)
            end

            local priceContentBg = cc.Scale9Sprite:create("public/srkdt.png")
            priceContentBg:setCapInsets(CCRectMake(40,15,351,52))
            priceContentBg:setContentSize(cc.size(190, 40))
            priceContentBg:setPosition(130,50)
            self._showList[i]:addChild(priceContentBg)

            local priceLabel = cc.Label:createWithTTF(pricestr, "fonts/round_body.ttf", 24)
                :setAnchorPoint(cc.p(0.5,0.5))
                :move(130,50)
                :setTextColor(cc.c4b(255,255,255,255))
                :addTo(self._showList[i])

            if nil ~= sign then
                local width = 0
                if cc.FileUtils:getInstance():isFileExist("Shop/sign_shop_"..sign..".png") then
                    local spsign = display.newSprite("Shop/sign_shop_"..sign..".png")
                    width = spsign:getContentSize().width + priceLabel:getContentSize().width
                    spsign:setAnchorPoint(cc.p(0.0,0.5))
                        :move((260-width)/2,50)
                        :addTo(self._showList[i])
                    width = (260-width) * 0.5 + spsign:getContentSize().width

                    priceLabel:setAnchorPoint(cc.p(0,0.5))
                    priceLabel:setPosition(width,50)
                end
            end --排除特权商城4 红钻
       	end
	end
end

function ShopLayer:onKeyBack()
    if nil ~= self.m_payLayer then
        if true == self.m_payLayer:isVisible() then
            return true
        end

        if true == self.m_bJunfuTongPay then
            return true
        end
    end
    return false
end

function ShopLayer:showPopWait()
	self._scene:showPopWait()
end

function ShopLayer:dismissPopWait()
	self._scene:dismissPopWait()
end

function ShopLayer:queryUserScoreInfo(queryCallback)
    if nil ~= self._scene.queryUserScoreInfo then
        self._scene:queryUserScoreInfo(queryCallback)
    end
end

return ShopLayer
