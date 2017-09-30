--[[
	商城界面
	2016_06_28 Ravioyla
    ShopLayer
]]

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local ClientConfig = appdf.req(appdf.BASE_SRC .."app.models.ClientConfig")
local BankFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BankFrame")

--商城页面
local ShopLayer = class("ShopLayer", function(scene)
		local shopLayer = display.newLayer(cc.c4b(0, 0, 0, 125))
    return shopLayer
end)

ShopLayer.BT_SCORE			= 30
ShopLayer.BT_VIP			= 50
ShopLayer.BT_PROPERTY		= 60
ShopLayer.BT_GOODS			= 120
ShopLayer.BT_BEAN			= 520

local SHOP_BUY = {}
SHOP_BUY[ShopLayer.BT_SCORE] = "shop_score_buy"
SHOP_BUY[ShopLayer.BT_BEAN] = "shop_bean_buy"
SHOP_BUY[ShopLayer.BT_VIP] = "shop_vip_buy"
SHOP_BUY[ShopLayer.BT_PROPERTY] = "shop_prop_buy"
SHOP_BUY[ShopLayer.BT_GOODS] = "shop_goods_buy"

-- 支付模式
local APPSTOREPAY = 10 -- iap支付

-- 进入场景而且过渡动画结束时候触发。
function ShopLayer:onEnterTransitionFinish()

    --====查询银行存款 start ======
    self:showPopWait()
    self._bankFrame:onGetBankInfo()
    --====查询银行存款 end ======

	if 0 == table.nums(self._shopTypeIdList) then        
		self:updateCheckBoxList()
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
function ShopLayer:ctor(scene, stmod,gameFrame)

    self.m_nPayMethod = GlobalUserItem.tabShopCache["nPayMethod"] or APPSTOREPAY
	local this = self
	self._scene = scene

    --====查询银行存款 start ======
    
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
    --====查询银行存款 end ======
	
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		end
	end)

	--按钮回调
	self._btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	self._showList = {}

    --游戏豆购买列表
    self._beanList = GlobalUserItem.tabShopCache["shopBeanList"] or {}
    --商店物品typeid
    self._shopTypeIdList = GlobalUserItem.tabShopCache["shopTypeIdList"] or {}
    --购买界面
    self.m_payLayer = nil
    --竣付通支付界面
    self.m_bJunfuTongPay = false

    local spriteMainBg = cc.Scale9Sprite:create("Shop/frame.png")
    spriteMainBg:setCapInsets(CCRectMake(311,184,20,26))
    spriteMainBg:setContentSize(cc.size(yl.WIDTH, yl.HEIGHT))
    spriteMainBg:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(spriteMainBg)

	--返回
	ccui.Button:create("Shop/fanhui.png","Shop/fanhui.png")
    	:move(50,yl.HEIGHT-50)
    	:addTo(self)
    	:addTouchEventListener(function(ref, type)
       		 	if type == ccui.TouchEventType.ended then
					this._scene:onKeyBack()
				end
			end)

    --装饰BUTTON
    local zsBg = display.newSprite("Shop/btFrame.png")
        :move(150, 500)
        :addTo(self)
    local zsBgSize = zsBg:getContentSize()
    ccui.Button:create("Shop/zs.png","Shop/zs.png")
		:move(zsBgSize.width/2, zsBgSize.height/2)
		:addTo(zsBg)
    --[[
	display.newSprite("Shop/title_shop.png")
		:move(yl.WIDTH-250,yl.HEIGHT-80)
		:addTo(self)
    --]]

    --修改为银行金币
    local spriteItemBg_bean = cc.Scale9Sprite:create("Shop/moneyBox.png")
    spriteItemBg_bean:setCapInsets(CCRectMake(35,10,165,34))
    spriteItemBg_bean:setContentSize(cc.size(400, 54))
    spriteItemBg_bean:move(yl.WIDTH-250,yl.HEIGHT-45)
    spriteItemBg_bean:addTo(self)
    display.newSprite("Shop/icon_gold.png")
    :move(24,28)
	:addTo(spriteItemBg_bean)
    --cc.LabelAtlas:_create(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,"/"), "Shop/num_shop_0.png", 16, 22, string.byte("."))   
	cc.LabelTTF:create(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,","), "fonts/round_body.ttf", 28) 
        :setColor(cc.c3b(250, 254, 149))
        :move(60, 27)
        :setName("_txtBean")
        :setAnchorPoint(cc.p(0,0.5))
        :addTo(spriteItemBg_bean)
    self._txtBean = spriteItemBg_bean:getChildByName("_txtBean")

	self._scrollView = ccui.ScrollView:create()
        :setContentSize(cc.size(yl.WIDTH,700))
        :setAnchorPoint(cc.p(0.5, 0.5))
--		:setPosition(cc.p(805, 314))
        :setPosition(cc.p(yl.WIDTH/2, yl.HEIGHT/2-50))
        --:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        :setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        :setBounceEnabled(false)
        :setScrollBarEnabled(true)
        :addTo(self)
end

function ShopLayer:updateCheckBoxList()
    self:loadPropertyAndVip()
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
	if name == SHOP_BUY[ShopLayer.BT_BEAN] then
		--游戏豆获取
        local item = self._beanList[tag - ShopLayer.BT_BEAN]
        if nil == item then
            return
        end
--修改平台测试
targetPlatform=4
         if ClientConfig.APPSTORE_VERSION 
             and (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
--临时写死
self.m_nPayMethod = APPSTOREPAY
             if self.m_nPayMethod == APPSTOREPAY then
                 local payparam = {}
                 --payparam.http_url = yl.HTTP_URL
                 payparam.http_url = "http://ww1.16yi.com"
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
                         --更新用户游戏豆（银行存款）
                        GlobalUserItem.lUserInsure = GlobalUserItem.lUserInsure + item.count*14000
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
	end
end

--请求游戏币开始1
--网络请求
function ShopLayer:loadPropertyAndVip()
    if 0 ~= #self._beanList then
        self:onUpdateBeanList()
        return
    end
    self._scene:showPopWait()
    if ClientConfig.APPSTORE_VERSION 
        and (targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD) then
            -- 内购开关
            appdf.onHttpJsionTable(yl.HTTP_URL .. "/WS/iosnotappstorepayswitch1.txt","GET","action=iosnotappstorepayswitch",function(jstable,jsdata)
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
                                self:requestPayList(8)
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
end

--请求游戏币开始2
function ShopLayer:requestPayList(isIap)
print("==============ShopLayer:requestPayList->isIap",isIap)
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
        --dump(self._beanList,"====self._beanList ",6)
        --排列顺序待确认
                    table.sort(self._beanList, function(a,b)
                            return a.price > b.price
                        end)
                    --[[
                    table.sort(self._beanList, function(a,b)
                            if a.nOrder ~= b.nOrder then
                                return a.nOrder > b.nOrder
                            else
                                return a.sortid < b.sortid
                            end
                        end)
                    --]]
        --dump(self._beanList,"====self._beanList ",6)
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

function ShopLayer:reloadBeanList()
    self:onClearShowList()
    GlobalUserItem.tabShopCache["shopBeanList"] = {}
    self._beanList = {}
    self:loadPropertyAndVip()
end

function ShopLayer:updateScoreInfo()
   --self._txtGold:setString(string.formatNumberThousands(GlobalUserItem.lUserScore,true,"/"))
   --self._txtBean:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,","))

    --====查询银行存款 start ======
    self:showPopWait()
    self._bankFrame:onGetBankInfo()
    --====查询银行存款 end ======
end

--更新游戏豆
function ShopLayer:onUpdateBeanList()
	self:onClearShowList()
	self:onUpdateShowList(self._beanList,ShopLayer.BT_BEAN)
end

--清除当前显示
function ShopLayer:onClearShowList()
	for i=1,#self._showList do
		self._showList[i]:removeFromParent()
	end
	self._showList = nil
	self._showList = {}
end

--更新当前显示
function ShopLayer:onUpdateShowList(theList,tag)
	local bBean = true

	--计算scroll滑动高度
	local scrollHeight = 0
	local scrollWidth = 0
    local cellHeight = 340
    local cellWidth = 1200
    local cellWidthC2 = cellWidth/2
	if #theList<8 then
        scrollHeight=700
		self._scrollView:setInnerContainerSize(cc.size(1134, 700))
	else
		scrollHeight = cellHeight * math.ceil(#theList / 4) --math.floor((#theList+math.floor(#theList%3))/3) 下部分为320 第一第二排高度和为290*2
		scrollWidth = cellWidth * math.ceil(#theList / 4)
		--self._scrollView:setInnerContainerSize(cc.size(scrollWidth, 580))
		self._scrollView:setInnerContainerSize(cc.size(1134, scrollHeight))
	end

    --[[ 假数据测试_scrollView 高度 by Zml
    scrollHeight = cellHeight * math.ceil(11 / 3)-30*2
    self._scrollView:setInnerContainerSize(cc.size(1134, scrollHeight))
    --]]

	for i=1,#theList do
        --[[ 假数据测试 by Zml
	for i=1,11 do
        temp='{"1":{"appid":0,"count":0,"description":"7000000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"6","name":"7000000","paycount":0,"paysend":0,"price":500,"sortid":0},"2":{"appid":0,"count":0,"description":"2800000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"5","name":"2800000","paycount":0,"paysend":0,"price":200,"sortid":0},"3":{"appid":0,"count":0,"description":"1400000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"4","name":"1400000","paycount":0,"paysend":0,"price":100,"sortid":0},"4":{"appid":0,"count":0,"description":"700000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"3","name":"700000","paycount":0,"paysend":0,"price":50,"sortid":0},"5":{"appid":0,"count":0,"description":"280000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"2","name":"280000","paycount":0,"paysend":0,"price":20,"sortid":0},"6":{"appid":0,"count":0,"description":"140000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"1","name":"140000","paycount":0,"paysend":0,"price":10,"sortid":0},"7":{"appid":0,"count":0,"description":"70000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"1","name":"70000","paycount":0,"paysend":0,"price":10,"sortid":0},"8":{"appid":0,"count":0,"description":"80000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"1","name":"80000","paycount":0,"paysend":0,"price":10,"sortid":0},"9":{"appid":0,"count":0,"description":"90000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"1","name":"90000","paycount":0,"paysend":0,"price":10,"sortid":0},"10":{"appid":0,"count":0,"description":"100000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"1","name":"100000","paycount":0,"paysend":0,"price":10,"sortid":0},"11":{"appid":0,"count":0,"description":"110000游戏币","isfirstpay":0,"nOrder":0,"nProductID":"1","name":"110000","paycount":0,"paysend":0,"price":10,"sortid":0}}'
        theList = cjson.decode(temp);
        print("=============onUpdateShowList ",theList["1"])
        print("=============onUpdateShowList ",theList)
        print("=============onUpdateShowList getn",table.getn(theList))
        local tempi=tostring(i)
        print("=============tempi ",tempi)
		local item = theList[tempi]
        --]]

		local item = theList[i]
        --[[
		self._showList[i] = cc.LayerColor:create(cc.c4b(100, 100, 100, 0), cellWidthC2, 240)
    		:move(160+math.floor((i-1)%3)*310-130,scrollHeight-(8+120+math.floor((i-1)/3)*220)-100)
    		:addTo(self._scrollView)
        --]]

        local btn
        if true then
            --四栏位
            self._showList[i] = cc.LayerColor:create(cc.c4b(100, 100, 100, 0), cellWidthC2, 240)
                --:move(320+92/2-25*2+236*((i-3)%4)-130,72+scrollHeight-700-cellHeight*(math.ceil((i-2) / 4)-1))
                :move(410+92/2-25*2+260*((i-1)%4)-130,65+scrollHeight-350-cellHeight*(math.ceil(i / 4)-1))
                :addTo(self._scrollView)
		    btn = ccui.Button:create("Shop/frame_shop_12.png","Shop/frame_shop_12.png")
            --btn:setContentSize(cc.size(cellWidthC2, 240))
		        :setAnchorPoint(cc.p(0.5,0.5))
                :move(130,120)
                --:setScale(1.1, 0.86)
                :setTag(tag+i)
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
            -- showSp = display.newSprite("Shop/icon_shop_5.png")
                --现存icon 仅6张 by Zml
                local tempIcon
                if i>6 then
                    tempIcon=6
                else
                    tempIcon=i
                end
                showSp = display.newSprite("Shop/icon_shop_bean"..tempIcon..".png")
                local atlas = cc.LabelAtlas:_create(string.gsub(item.name .. "", "[.]", "/"), "Shop/num_shop_5.png", 20, 25, string.byte("/"))
                atlas:setAnchorPoint(cc.p(1.0,0.5))
                self._showList[i]:addChild(atlas) 
                local name = display.newSprite("Shop/text_shop_0.png")
                name:setAnchorPoint(cc.p(0,0.5))
                self._showList[i]:addChild(name)
                local wid = (atlas:getContentSize().width + name:getContentSize().width) / 2   			
                atlas:setPosition(130 + (atlas:getContentSize().width - wid), 82)
                name:setPosition(atlas:getPositionX(), 82)

                price = item.price
                pricestr = "￥"..string.formatNumberThousands(price,true,",")

                --首充
                if nil ~= item.paysend and 0 ~= item.paysend then
                    local fsp = cc.Sprite:create("Shop/shop_firstpay_sp.png")
                    fsp:setAnchorPoint(cc.p(0,1.0))
                    fsp:setPosition(-8,248)
                    self._showList[i]:addChild(fsp)
                    local isFirstPay = item.isfirstpay == 0
                    btn:setEnabled(isFirstPay)
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
        --               :setVisible(false)
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
                showSp:setPosition(130, 170)
                self._showList[i]:addChild(showSp)
            end
            if nil ~= titleSp then
                titleSp:setPosition(130, 220)
                self._showList[i]:addChild(titleSp)
            end		

            local priceContentBg = cc.Scale9Sprite:create("Shop/srkdt.png")
            priceContentBg:setCapInsets(CCRectMake(20,20,146,28))
            --priceContentBg:setContentSize(cc.size(190, 68))
            priceContentBg:setPosition(130,15)
            self._showList[i]:addChild(priceContentBg)


            local priceLabel = cc.Label:createWithTTF(pricestr, "fonts/round_body.ttf", 28)
                :setAnchorPoint(cc.p(0.5,0.5))
                :move(130,20)
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
            end  
        end     	
	end
end
--操作结果 银行存款
function ShopLayer:onBankCallBack(result,message)
	self:dismissPopWait()
	if  message ~= nil and message ~= "" then
		showToast(self._scene,message,2)
	end
	if result == self._bankFrame.OP_GET_BANKINFO then
        print("================ GlobalUserItem.lUserInsure onBankCallBack",GlobalUserItem.lUserInsure)
        self._txtBean:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,","))
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
