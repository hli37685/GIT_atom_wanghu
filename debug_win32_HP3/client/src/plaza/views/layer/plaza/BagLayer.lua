--[[
	背包界面
	2016_07_06 Ravioyla
]]

local BagLayer = class("BagLayer", function(scene)
		local bagLayer = display.newLayer(cc.c4b(0, 0, 0, 125))
    return bagLayer
end)

local BagFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BagFrame")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local ConsignmentLayer =  appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ConsignmentLayer")
local ConsignmentBuyLayer =  appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ConsignmentBuyLayer")
local SynthesisPromptLayer =  appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.SynthesisPromptLayer")
local ExchangePromptLayer =  appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ExchangePromptLayer")
local BankFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BankFrame")

BagLayer.CBT_MYPROPERTY	    = 1         --我的道具
BagLayer.CBT_TRADINGFLOOR	= 2         --交易大厅
BagLayer.CBT_TRADINGRECORD	= 3         --交易记录
BagLayer.CBT_PROPSSYNTHESIS	= 4         --道具合成
BagLayer.CBT_PROPSEXCHANGE	= 5         --道具兑换
BagLayer.CBT_BUYRECORD	    = 11        --购买记录
BagLayer.CBT_SALERECORD	    = 12        --出售记录
BagLayer.CBT_BUY	        = 21        --商品列表
BagLayer.CBT_CONSIGNMENT	= 22        --我的寄售

BagLayer.BT_CLOSE           = 100
BagLayer.BT_SEARCH          = 101

BagLayer.BAGITEMICONS = {"icon_jnb.png", "icon_niujiao.png", "icon_xianhua.png", "icon_xingyunbi.png", "icon_yugu.png", "icon_laba.png"}
BagLayer.BAGITEMDIAMONDS = {"BlueDiamond.png", "YellowDiamond.png", "WhiteDiamond.png", "VIPDiamond.png"}
BagLayer.BAGITEMDIAMONDDAYS = {"BlueDiaDay7.png", "YellowDiaDay7.png", "WhiteDiaDay7.png", "VIPDay7.png"}
BagLayer.BAGITEMNAMES = {"纪念币", "牛角", "鲜花", "幸运币", "鱼骨头", "喇叭"}

-- 进入场景而且过渡动画结束时候触发。
function BagLayer:onEnterTransitionFinish()
	self._scene:showPopWait()
	self._BaglFrame:onSendQueryBag()
    self:iniUI()

    return self
end

-- 退出场景而且开始过渡动画时候触发。
function BagLayer:onExitTransitionStart()
    self.m_ConsignmentDlg:removeFromParent()
    self.m_ConsignmentBuyDlg:removeFromParent()
    return self
end

function BagLayer:ctor(scene, gameFrame)
	
	local this = self

	self._scene = scene
	
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
        elseif eventType == "exit" then
            if self._BaglFrame:isSocketServer() then
                self._BaglFrame:onCloseSocket()
            end  
            if nil ~= self._BaglFrame._gameFrame then
                self._BaglFrame._gameFrame._shotFrame = nil
                self._BaglFrame._gameFrame = nil
            end          
		end
	end)

	--按钮回调
	local _btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    local cbtlistener = function (sender,eventType)
        local tag = sender:getTag()
        if tag >= BagLayer.CBT_MYPROPERTY and tag <= BagLayer.CBT_PROPSEXCHANGE then
    	    this:onClassSelectedEvent(tag,sender,eventType)
        elseif tag >= BagLayer.CBT_BUYRECORD and tag <= BagLayer.CBT_SALERECORD then
    	    this:onRecordSelectedEvent(tag,sender,eventType)
        elseif tag >= BagLayer.CBT_BUY and tag <= BagLayer.CBT_CONSIGNMENT then
    	    this:onOperateSelectedEvent(tag,sender,eventType)
        end
    end

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

    --网络回调
    local bagCallBack = function(result,message)
		this:onBagCallBack(result,message)
	end

	--网络处理
	self._BaglFrame = BagFrame:create(self,bagCallBack)
    self._BaglFrame._gameFrame = gameFrame
    if nil ~= gameFrame then
        gameFrame._shotFrame = self._BaglFrame
    end

    self._topView = self

    --显示队列
	self._showList = {}
	--数据队列
    self._dataList  = {}
    --
    self._PanelList = {}
    self._cbClassList = {}
    self._cbRecordList = {}
    self._cbOperateList = {}

    self._select = BagLayer.CBT_MYPROPERTY	
    self._tradingfloorSelect = BagLayer.CBT_BUY
    self.RecordSelectedFlag=BagLayer.CBT_BUYRECORD

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Bag/BagLayer.csb", self)
	self.mCsbNode = csbNode

    self._btnClose = csbNode:getChildByName("btnClose");
    self._btnClose:setTag(BagLayer.BT_CLOSE)
    self._btnClose:addTouchEventListener(_btcallback)

    self._txtBankMoney = csbNode:getChildByName("txtBankMoney");
    local image_Left = csbNode:getChildByName("Image_Left");
    --左侧按钮列表
    self._cb_MyProperty = image_Left:getChildByName("CheckBox_MyProperty");
    table.insert(self._cbClassList, self._cb_MyProperty)
    self._cb_MyProperty:setTag(BagLayer.CBT_MYPROPERTY)
    self._cb_MyProperty:addEventListener(cbtlistener)

    self._cb_TradingFloor = image_Left:getChildByName("CheckBox_TradingFloor");
    table.insert(self._cbClassList, self._cb_TradingFloor)
    self._cb_TradingFloor:setTag(BagLayer.CBT_TRADINGFLOOR)
    self._cb_TradingFloor:addEventListener(cbtlistener)

    self._cb_TradingRecord = image_Left:getChildByName("CheckBox_TradingRecord");
    table.insert(self._cbClassList, self._cb_TradingRecord)
    self._cb_TradingRecord:setTag(BagLayer.CBT_TRADINGRECORD)
    self._cb_TradingRecord:addEventListener(cbtlistener)

    self._cb_PropsSynthesis  = image_Left:getChildByName("PropsSynthesis");
    table.insert(self._cbClassList, self._cb_PropsSynthesis)
    self._cb_PropsSynthesis:setTag(BagLayer.CBT_PROPSSYNTHESIS)
    self._cb_PropsSynthesis:addEventListener(cbtlistener)

    self._cb_PropsExchange = image_Left:getChildByName("PropsExchange");
    table.insert(self._cbClassList, self._cb_PropsExchange)
    self._cb_PropsExchange:setTag(BagLayer.CBT_PROPSEXCHANGE)
    self._cb_PropsExchange:addEventListener(cbtlistener)

    self._cb_MyProperty:setSelected(true)
    self._cb_TradingFloor:setSelected(false)
    self._cb_TradingRecord:setSelected(false)
    self._cb_PropsSynthesis:setSelected(false)
    self._cb_PropsExchange:setSelected(false)

    --右侧显示框
    self._Panel_MyProperty = csbNode:getChildByName("Panel_MyProperty");
    table.insert(self._PanelList, self._Panel_MyProperty)

    self._Panel_TradingFloor = csbNode:getChildByName("Panel_TradingFloor");
    table.insert(self._PanelList, self._Panel_TradingFloor)

    self._Panel_TradingRecord = csbNode:getChildByName("Panel_TradingRecord");
    table.insert(self._PanelList, self._Panel_TradingRecord)

    self._Panel_PropsSynthesis = csbNode:getChildByName("Panel_PropsSynthesis");
    table.insert(self._PanelList, self._Panel_PropsSynthesis)

    self._Panel_PropsExchange = csbNode:getChildByName("Panel_PropsExchange");
    table.insert(self._PanelList, self._Panel_PropsExchange)
    --END

    --交易大厅-商品列表
    self._CheckBox_Buy = self._Panel_TradingFloor:getChildByName("CheckBox_Buy");
    self._CheckBox_Buy:setTag(BagLayer.CBT_BUY)
    self._CheckBox_Buy:addEventListener(cbtlistener)
    table.insert(self._cbOperateList, self._CheckBox_Buy)
    --交易大厅-我的寄售
    self._CheckBox_MyMerchandisies = self._Panel_TradingFloor:getChildByName("CheckBox_MyMerchandisies");
    self._CheckBox_MyMerchandisies:setTag(BagLayer.CBT_CONSIGNMENT)
    self._CheckBox_MyMerchandisies:addEventListener(cbtlistener)
    table.insert(self._cbOperateList, self._CheckBox_MyMerchandisies)

    --交易记录-出售记录
    self._CheckBox_BuyRecord = self._Panel_TradingRecord:getChildByName("CheckBox_BuyRecord");
    self._CheckBox_BuyRecord:setTag(BagLayer.CBT_BUYRECORD)
    self._CheckBox_BuyRecord:addEventListener(cbtlistener)
    table.insert(self._cbRecordList, self._CheckBox_BuyRecord)
    --交易记录-购买记录
    self._CheckBox_SaleRecord = self._Panel_TradingRecord:getChildByName("CheckBox_SaleRecord");
    self._CheckBox_SaleRecord:setTag(BagLayer.CBT_SALERECORD)
    self._CheckBox_SaleRecord:addEventListener(cbtlistener)
    table.insert(self._cbRecordList, self._CheckBox_SaleRecord)
    --交易大厅-搜索框
    self._Image_Search = self._Panel_TradingFloor:getChildByName("Image_Search")
    --按钮
    self._btnSearch = self._Image_Search:getChildByName("btnSearch");
    self._btnSearch:setTag(BagLayer.BT_SEARCH)
    self._btnSearch:addTouchEventListener(_btcallback)
    self.txtSearchID = ccui.EditBox:create(cc.size(210,30), "")
		:move(122,21)
		:setFontName("Bag/fzcyjt.ttf")
		:setPlaceholderFontName("Bag/fzcyjt.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setFontColor(cc.c4b(255,255,255,255))
		:setPlaceHolder("查找寄售人ID")
		:addTo(self._Image_Search)

    --scrollview
    self._ScrollView_Property = self._Panel_MyProperty:getChildByName("ScrollView_Property")

    self._ScrollView_TradingFloor = self._Panel_TradingFloor:getChildByName("ScrollView_TradingFloor")

    self._ScrollView_TradingRecord = self._Panel_TradingRecord:getChildByName("ScrollView_TradingRecord")

    self._ScrollView_PropsSynthesis = self._Panel_PropsSynthesis:getChildByName("ScrollView_PropsSynthesis")

    self._ScrollView_PropsExchange = self._Panel_PropsExchange:getChildByName("ScrollViewl_PropsExchange")

    self.m_ConsignmentDlg = ConsignmentLayer:create(self)
    self.m_ConsignmentDlg:addTo(self, yl.MAX_INT)
    self.m_ConsignmentDlg:setVisible(false)

    self.m_ConsignmentBuyDlg = ConsignmentBuyLayer:create(self)
    self.m_ConsignmentBuyDlg:addTo(self, yl.MAX_INT)
    self.m_ConsignmentBuyDlg:setVisible(false)

    self.m_SynthesisDlg = SynthesisPromptLayer:create(self)
    self.m_SynthesisDlg:addTo(self, yl.MAX_INT)
    self.m_SynthesisDlg:setVisible(false)

    self.m_ExchangeDlg = ExchangePromptLayer:create(self)
    self.m_ExchangeDlg:addTo(self, yl.MAX_INT)
    self.m_ExchangeDlg:setVisible(false)
end

function BagLayer:updateMoney()
    self._txtBankMoney:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,"/"))
end

--按键监听
function BagLayer:onButtonClickedEvent(tag,sender)
--    local beginPos = sender:getTouchBeganPosition()
--    local endPos = sender:getTouchEndPosition()
--    if math.abs(endPos.x - beginPos.x) > 30 
--        or math.abs(endPos.y - beginPos.y) > 30 then
--        print("BagLayer:onButtonClickedEvent ==> MoveTouch Filter")
--        return
--    end
--	print("***** button clicked-"..tag.." ******")

--	if (tag>BagLayer.BT_GEM) and (tag<BagLayer.BT_CARD) then
--		GlobalUserItem.useItem = self._gemList[tag-BagLayer.BT_GEM]
--		self:getParent():getParent():onChangeShowMode(yl.SCENE_BAGDETAIL)
--	elseif (tag>BagLayer.BT_CARD) and (tag<BagLayer.BT_ITEM) then
--		GlobalUserItem.useItem = self._cardList[tag-BagLayer.BT_CARD]
--		self:getParent():getParent():onChangeShowMode(yl.SCENE_BAGDETAIL)
--	elseif (tag>BagLayer.BT_ITEM) and (tag<BagLayer.BT_GIFT) then
--		GlobalUserItem.useItem = self._itemList[tag-BagLayer.BT_ITEM]
--		self:getParent():getParent():onChangeShowMode(yl.SCENE_BAGDETAIL)
--	elseif (tag>BagLayer.BT_GIFT) and (tag<BagLayer.BT_GIFT+200) then
--		showToast(self,"手机端暂不支持礼物道具，请前往PC客户端使用！",2);
--	end

    if tag == BagLayer.BT_CLOSE then
        self._scene:onKeyBack()
    elseif tag == BagLayer.BT_SEARCH then
        self:SearchByID()
    end
end

function BagLayer:showUndercarriageNofify(args)

end

--操作结果 银行存款
function BagLayer:onBankCallBack(result,message)
	self._scene:dismissPopWait()
	if  message ~= nil and message ~= "" then
		showToast(self._scene,message,2)
	end
	if result == self._bankFrame.OP_GET_BANKINFO then
        print("================ GlobalUserItem.lUserInsure onBankCallBack",GlobalUserItem.lUserInsure)
        self:updateMoney() 
	end
end

--初始化UI
function BagLayer:iniUI()
    self._txtBankMoney:setString(string.formatNumberThousands(GlobalUserItem.lUserInsure,true,"/"))
    self:onClassSelectedEvent(BagLayer.CBT_MYPROPERTY)

    --查询存款
	self._scene:showPopWait()
    self._bankFrame:onGetBankInfo()
end

function BagLayer:SearchByID()
    local id = self.txtSearchID:getText()
    if id and tonumber(id) and tonumber(id) > 0 then
        self:getBuyList(tonumber(id))
    else
        showToast(self, "请输入有效ID进行查找", 2)
    end
end

--左侧按钮列表
function BagLayer:onClassSelectedEvent(tag,sender,eventType)
	self._select = tag

	for i=1,5 do
		if i ~= tag then
			self._cbClassList[i]:setSelected(false)
            self._PanelList[i]:setVisible(false)
        else
		    self._cbClassList[i]:setSelected(true)
            self._PanelList[i]:setVisible(true)
		end
	end

	--刷新界面
	self:onClearShowList()
    if tag == BagLayer.CBT_MYPROPERTY then
    --我的道具
        self._BaglFrame:onSendQueryBag()
    elseif tag == BagLayer.CBT_TRADINGFLOOR then
    --交易大厅
        self:onOperateSelectedEvent(BagLayer.CBT_BUY)
    elseif tag == BagLayer.CBT_TRADINGRECORD then
    --交易记录
        self:onRecordSelectedEvent(BagLayer.CBT_BUYRECORD)
    elseif tag == BagLayer.CBT_PROPSSYNTHESIS then
    --道具合成  临时使用我的道具接口取得数量
        --self:onBagCallBack(yl.SUB_GP_GOODS_COMPOUND,"")
        self._BaglFrame:onSendQueryBag()
    elseif tag == BagLayer.CBT_PROPSEXCHANGE then
    --道具兑换  临时使用我的道具接口取得数量
        self._BaglFrame:onSendQueryBag()
    end

--	self:onUpdateShowList()

end

function BagLayer:getTopView()
    if not self._topView then
        return self
    else
        return self._topView
    end
end
-- ==================================================================交易记录 start
function BagLayer:onRecordSelectedEvent(tag,sender,eventType)
	for i=1,2 do
		if i ~= tag-10 then
			self._cbRecordList[i]:setSelected(false)
        else
		    self._cbRecordList[i]:setSelected(true)
		end
    end
    self.RecordSelectedFlag=tag
    if tag == BagLayer.CBT_BUYRECORD then
        self:getBuyRecords()
    elseif tag == BagLayer.CBT_SALERECORD then
        self:getSaleRecords()
    end

end

function BagLayer:getBuyRecords()
    print("========================BagLayer:getBuyRecords")
    self:onClearShowList()
    self._BaglFrame:onSendQueryTradingRecordData(3)
end

function BagLayer:getSaleRecords()
    self:onClearShowList()
    self._BaglFrame:onSendQueryTradingRecordData(1)
end
--=====================================================================交易记录 end

--=====================================================================弹框内容操作
function BagLayer:consignment(itemid, price, num)
    self._BaglFrame:onSendConsignment(itemid, price, num)
end

function BagLayer:buy(itemIndex, pwd)
    self._BaglFrame:onSendBuy(itemIndex, pwd)
end

function BagLayer:underarriage(itemindex)
    self._BaglFrame:onSendUnderarriage(itemindex)
end

function BagLayer:SynthesisConfirm(itemid,num)
    self._BaglFrame:onSendCompound(itemid,num*10)  
end

function BagLayer:ExchangeConfirm(itemid,num)
    self._BaglFrame:onSendChange(itemid,num)  
end


--==========================================================交易大厅 
--交易大厅
function BagLayer:getBuyList(searchid)
    self:onClearShowList()
    self._BaglFrame:onSendTradingFloorData(searchid, 0)
end

--交易大厅
function BagLayer:getSaleList()
    self:onClearShowList()
    self._BaglFrame:onSendTradingFloorData(GlobalUserItem.dwGameID, 0)
end

--交易大厅
function BagLayer:hideSearchUI(bVisible)
    self._Image_Search:setVisible(bVisible)
end

--交易大厅
function BagLayer:onOperateSelectedEvent(tag,sender,eventType)
    self._tradingfloorSelect = tag
	for i=1,2 do
		if i ~= tag-20 then
			self._cbOperateList[i]:setSelected(false)
        else
		    self._cbOperateList[i]:setSelected(true)
		end
	end
    if tag == BagLayer.CBT_BUY then
        self:hideSearchUI(true)
        self:getBuyList()
    elseif tag == BagLayer.CBT_CONSIGNMENT then
        self:hideSearchUI(false)
        self:getSaleList()
    end
end

--操作结果
function BagLayer:onBagCallBack(result,message)
	print("======== BagLayer:onBagCallBack ========")

	self._scene:dismissPopWait()
--	if  message ~= nil and message ~= "" then
--		showToast(self,message,2);
--	end
	--刷新界面
	self:onClearShowList()
dump(message,"message",6)
print("========result ",result)
	if result==yl.SUB_GP_GOODS_LIST then
		if #message == 0 then
			showToast(self, "背包为空", 2)
			return
		end

    	self._itemCountList = {}

		for i=1,#message do
			local item = message[i]
	        table.insert(self._itemCountList,item)
		end
        if self._select == BagLayer.CBT_MYPROPERTY then
            --我的道具
		    self:onUpdateMyPropertyList()
        elseif self._select == BagLayer.CBT_PROPSSYNTHESIS then
             --道具合成
		    self:onUpdatePropsSynthesisList()
        elseif self._select == BagLayer.CBT_PROPSEXCHANGE then
             --道具兑换
		    self:onUpdateExchangeList()
        end
    elseif result==yl.SUB_GP_GOODSSHOP_LIST then
		if #message == 0 then
			showToast(self, "查询结果为空", 2)
			return
		end
        if self._select == BagLayer.CBT_TRADINGFLOOR then
    	    self._TradingFloorList = {}
		    for i=1,#message do
			    local item = message[i]
	            table.insert(self._TradingFloorList,item)
		    end

		    self:onUpdateTradingFloorList()
        elseif self._select == BagLayer.CBT_TRADINGRECORD then
    	    self._TradingRecordList = {}
		    for i=1,#message do
			    local item = message[i]
	            table.insert(self._TradingRecordList,item)
		    end

		    self:onUpdateTradingRecordList()
        end     
    --[[
    elseif result==yl.SUB_GP_GOODS_COMPOUND then
        --道具合成

        temp={}
        temp[1],temp[2],temp[3],temp[4]=2,1,1,5
        dump(temp,"message",6)
        print("===== ",#temp)
        message=temp 

		if #message == 0 then
			showToast(self, "道具为空", 2)
			return
		end

    	self._itemCountList = {}

		for i=1,#message do
			local item = message[i]
	        table.insert(self._itemCountList,item)
		end
		self:onUpdatePropsSynthesisList()
    --]]
    --[[ 
    elseif result==yl.SUB_GP_GOODSSHOPLIST_LIST then
		if #message == 0 then
			showToast(self, "查询结果为空", 2)
			return
		end

    	self._TradingRecordList = {}
		for i=1,#message do
			local item = message[i]
	        table.insert(self._TradingRecordList,item)
		end

		self:onUpdateTradingRecordList()
        --]] 
	end

end

--清除当前显示
function BagLayer:onClearShowList()
	for i=1,#self._showList do
		self._showList[i].rootNode:removeFromParent()
	end
	self._showList = nil
	self._showList = {}
end

--更新当前显示 我的道具
function BagLayer:onUpdateMyPropertyList()
	--计算scroll滑动高度
	local scrollHeight = 0
    local intervalY = 210
    local intervalX = 300
    local posX = 40
    local posY = 40
    local scrollWidth = 900
    local scrollHeight = 440;
    local itemCount = #self._itemCountList
	if #self._itemCountList<7 then
		self._ScrollView_Property:setInnerContainerSize(cc.size(scrollWidth, scrollHeight))
        posY = scrollHeight - intervalY;
	else
		self._ScrollView_Property:setInnerContainerSize({width = scrollWidth , height = intervalY*math.ceil(itemCount/3)});
        posY = intervalY*math.ceil(itemCount/3) - intervalY; 
	end

	for i=1, itemCount do
		local item = {}

        item.rootNode = cc.CSLoader:createNode("Bag/PropertyItemLayer.csb")
        item.Image_Bg = item.rootNode:getChildByName("Image_Bg")
        item.Image_Bg:setTag(i)
        item.itemIcon = item.Image_Bg:getChildByName("Image_Item")
        item.itemName = item.Image_Bg:getChildByName("Image_ItemName"):getChildByName("txtItemName")
        item.itemIcon:loadTexture("Bag/"..BagLayer.BAGITEMICONS[i])
        item.itemCount = self._itemCountList[i]
        local strName = BagLayer.BAGITEMNAMES[i].."x"..item.itemCount
        item.itemName:setString(strName)
        self._ScrollView_Property:addChild(item.rootNode)
        self._showList[i] = item

        item.rootNode:setPosition(posX, posY);
        posX = posX + intervalX;
        if math.mod(i, 3) == 0 then
            posX = 40;
            posY = posY - intervalY;
        end

        local this = self
        function onclickItem(sender,eventType)
            local tmpItem = self._showList[sender:getTag()]
            self.m_ConsignmentDlg:resetUI()
            self.m_ConsignmentDlg:setInfo({sender:getTag(), tmpItem.itemCount})
            self.m_ConsignmentDlg:setVisible(true)
            self._topView = self.m_ConsignmentDlg
        end
        item.Image_Bg:addTouchEventListener(onclickItem)
	end
end


--更新当前显示
function BagLayer:onUpdateTradingFloorList()
	--计算scroll滑动高度
	local scrollHeight = 0
    local intervalY = 80
    local intervalX = 250
    local posX = 0
    local posY = 10
    local scrollWidth = 790
    local scrollHeight = 370;
    local itemCount = #self._TradingFloorList
	if #self._TradingFloorList<5 then
		self._ScrollView_TradingFloor:setInnerContainerSize(cc.size(scrollWidth, scrollHeight))
        posY = scrollHeight - intervalY;
	else
		self._ScrollView_TradingFloor:setInnerContainerSize({width = scrollWidth , height = intervalY*itemCount});
        posY = intervalY*itemCount - intervalY; 
	end


    if self._tradingfloorSelect == BagLayer.CBT_BUY then
	    for i=1, itemCount do
		    local item = {}
            item.rootNode = cc.CSLoader:createNode("Bag/ConsignmentBuyItemLayer.csb")
            item.Image_Bg = item.rootNode:getChildByName("Image_Bg")
            item.itemIcon = item.Image_Bg:getChildByName("Image_ItemIcon")
            item.itemName = item.Image_Bg:getChildByName("txtName")
            local priceBg = item.Image_Bg:getChildByName("Image_3")
            item.itemPrice = priceBg:getChildByName("txtPrice")
            item.itemHour = item.Image_Bg:getChildByName("Image_4"):getChildByName("txtHour")
            item.itemSalerID = item.Image_Bg:getChildByName("Text_3"):getChildByName("txtID")
            item.btnBuy = item.Image_Bg:getChildByName("Image_Buy"):getChildByName("btnBuy")
            item.itemIndex = self._TradingFloorList[i].ID
            item.shopid = self._TradingFloorList[i].wShopID
            item.itemIcon:loadTexture("Bag/"..BagLayer.BAGITEMICONS[item.shopid])
            local strName = BagLayer.BAGITEMNAMES[self._TradingFloorList[i].wShopID].."x"..self._TradingFloorList[i].wCountID
            item.itemName:setString(strName)
            item.itemPrice:setString(self._TradingFloorList[i].lGOODScore)
            local pricesize = item.itemPrice:getContentSize()
            item.itemPrice:setPositionX(priceBg:getContentSize().width + pricesize.width/2)
            local time = math.ceil(24 - (currentTime()/1000 - self._TradingFloorList[i].GoodsshopTime)/3600)
            item.itemHour:setString(time)
            item.itemSalerID:setString(self._TradingFloorList[i].dwBYGameID)
            item.itemCount = self._TradingFloorList[i].wCountID
            self._ScrollView_TradingFloor:addChild(item.rootNode)
            self._showList[i] = item

            item.rootNode:setPosition(posX, posY);
            posY = posY - intervalY;

            local this = self
            function onclickItem(sender,eventType)
                local tmpItem = self._showList[sender:getTag()]
                if tonumber(tmpItem.itemSalerID:getString()) == tonumber(GlobalUserItem.dwGameID) then
                    showToast(this, "不能购买自己上架的商品!", 2)
                    return
                end
                self.m_ConsignmentBuyDlg:resetUI()
                self.m_ConsignmentBuyDlg:setInfo({tmpItem.shopid, tmpItem.itemCount, tmpItem.itemPrice:getString(), tmpItem.itemIndex})
                self.m_ConsignmentBuyDlg:setVisible(true)
                self._topView = self.m_ConsignmentBuyDlg
            end
            item.btnBuy:addTouchEventListener(onclickItem)
            item.btnBuy:setTag(i)
	    end
    elseif self._tradingfloorSelect == BagLayer.CBT_CONSIGNMENT then
	    for i=1, itemCount do
		    local item = {}
            item.rootNode = cc.CSLoader:createNode("Bag/ConsignmentItemLayer.csb")
            item.Image_Bg = item.rootNode:getChildByName("Image_Bg")
            item.itemIcon = item.Image_Bg:getChildByName("Image_ItemIcon")
            item.itemName = item.Image_Bg:getChildByName("txtName")
            local priceBg = item.Image_Bg:getChildByName("Image_3")
            item.itemPrice = priceBg:getChildByName("txtPrice")
            item.itemHour = item.Image_Bg:getChildByName("Image_4"):getChildByName("txtHour")
            item.btnUndercarriage = item.Image_Bg:getChildByName("Image_Undercarriage"):getChildByName("btnUndercarriage")
            item.itemIndex = self._TradingFloorList[i].ID
            item.itemIcon:loadTexture("Bag/"..BagLayer.BAGITEMICONS[self._TradingFloorList[i].wShopID])
            local strName = BagLayer.BAGITEMNAMES[self._TradingFloorList[i].wShopID].."x"..self._TradingFloorList[i].wCountID
            item.itemName:setString(strName)
            item.itemCount = self._TradingFloorList[i].wCountID
            item.itemPrice:setString(self._TradingFloorList[i].lGOODScore)
            local pricesize = item.itemPrice:getContentSize()
            item.itemPrice:setPositionX(priceBg:getContentSize().width + pricesize.width/2)
            local time = math.ceil(24 - (currentTime()/1000 - self._TradingFloorList[i].GoodsshopTime)/3600)
            item.itemHour:setString(time)


            self._ScrollView_TradingFloor:addChild(item.rootNode)
            self._showList[i] = item

            item.rootNode:setPosition(posX, posY);
            posY = posY - intervalY;


            local this = self
            function onclickItem(sender,eventType)
                local tmpItem = self._showList[sender:getTag()]
                this:underarriage(tmpItem.itemIndex)
            end
            item.btnUndercarriage:addTouchEventListener(onclickItem)
            item.btnUndercarriage:setTag(i)
	    end
    end
end



--更新当前显示
function BagLayer:onUpdateTradingRecordList()
	--计算scroll滑动高度
	local scrollHeight = 0
    local intervalY = 80
    local intervalX = 250
    local posX = 0
    local posY = 0
    local scrollWidth = 790
    local scrollHeight = 430;
    local itemCount = #self._TradingRecordList
	if #self._TradingRecordList<5 then
		self._ScrollView_TradingRecord:setInnerContainerSize(cc.size(scrollWidth, scrollHeight))
        posY = scrollHeight - intervalY;
	else
		self._ScrollView_TradingRecord:setInnerContainerSize({width = scrollWidth , height = intervalY*itemCount});
        posY = intervalY*itemCount - intervalY; 
	end

	for i=1, itemCount do
		local item = {}
        item.rootNode = cc.CSLoader:createNode("Bag/ConsignmentRecordItemLayer.csb")
        item.Image_Bg = item.rootNode:getChildByName("Image_Bg")
        item.itemIcon = item.Image_Bg:getChildByName("Image_ItemIcon")
        item.itemName = item.Image_Bg:getChildByName("txtName")
        local priceBg = item.Image_Bg:getChildByName("Image_3")
        item.itemPrice = priceBg:getChildByName("txtPrice")
        item.itemSalerID = item.Image_Bg:getChildByName("Text_3"):getChildByName("txtID")
        item.time = item.Image_Bg:getChildByName("txtTime")
        item.itemIcon:loadTexture("Bag/"..BagLayer.BAGITEMICONS[self._TradingRecordList[i].wShopID])
        local strName = BagLayer.BAGITEMNAMES[self._TradingRecordList[i].wShopID].."x"..self._TradingRecordList[i].wCountID
        item.itemName:setString(strName)
        item.itemPrice:setString(self._TradingRecordList[i].lGOODScore)
        local pricesize = item.itemPrice:getContentSize()
        item.itemPrice:setPositionX(priceBg:getContentSize().width + pricesize.width/2)
        local baseTime = os.time({year=1970, month=1, day=2, hour = 0, minute = 0, second = 0})
        local strTime = os.date("%Y-%m-%d %H:%M", baseTime + tonumber(self._TradingRecordList[i].GoodsshopbuyTime) + (8-24)*3600)
        item.time:setString(strTime)
        item.itemSalerID:setString(self._TradingRecordList[i].dwBYGameID)
        if BagLayer.CBT_SALERECORD==self.RecordSelectedFlag then
            item.itemSalerID:setString(self._TradingRecordList[i].dwToGameID)
        end

        self._ScrollView_TradingRecord:addChild(item.rootNode)
        self._showList[i] = item

        item.rootNode:setPosition(posX, posY);
        posY = posY - intervalY;

	end

end

--更新当前显示 道具合成
function BagLayer:onUpdatePropsSynthesisList()
	--计算scroll滑动高度
	local scrollHeight = 0
    local intervalY = 210
    local intervalX = 300
    local posX = 40
    local posY = 40
    local scrollWidth = 900
    local scrollHeight = 440;
    local itemCount = #self._itemCountList

    --合成比例
    local Proportion=10
	if #self._itemCountList<7 then
		self._ScrollView_PropsSynthesis:setInnerContainerSize(cc.size(scrollWidth, scrollHeight))
        posY = scrollHeight - intervalY;
	else
		self._ScrollView_PropsSynthesis:setInnerContainerSize({width = scrollWidth , height = intervalY*math.ceil(itemCount/3)});
        posY = intervalY*math.ceil(itemCount/3) - intervalY; 
	end

    --注 这里使用背包中的数据
	for i=1, itemCount-2 do
        --需要限制数量 或者判断图标是否存在
		local item = {}

        item.rootNode = cc.CSLoader:createNode("Bag/PropertyItemLayer.csb")
        item.Image_Bg = item.rootNode:getChildByName("Image_Bg")
        item.Image_Bg:setTag(i)
        item.itemIcon = item.Image_Bg:getChildByName("Image_Item")
        item.itemName = item.Image_Bg:getChildByName("Image_ItemName"):getChildByName("txtItemName")
        item.itemIcon:loadTexture("Bag/"..BagLayer.BAGITEMICONS[i+1])
        item.itemCount = self._itemCountList[i]
        local strName = BagLayer.BAGITEMNAMES[i].."x"..Proportion
        item.itemName:setString(strName)
        self._ScrollView_PropsSynthesis:addChild(item.rootNode)
        self._showList[i] = item

        item.rootNode:setPosition(posX, posY);
        posX = posX + intervalX;
        if math.mod(i, 3) == 0 then
            posX = 40;
            posY = posY - intervalY;
        end

        local this = self
        function onclickItem(sender,eventType)
            if ccui.TouchEventType.ended==eventType then                
                local tmpItem = self._showList[sender:getTag()]
                self.m_SynthesisDlg:resetUI()
                self.m_SynthesisDlg:setInfo({sender:getTag(), tmpItem.itemCount,Proportion})
                self.m_SynthesisDlg:setVisible(true)
                self._topView = self.m_SynthesisDlg
            end
        end
        item.Image_Bg:addTouchEventListener(onclickItem)
	end
end

--更新当前显示 道具兑换
function BagLayer:onUpdateExchangeList()
	--计算scroll滑动高度
	local scrollHeight = 0
    local intervalY = 210
    local intervalX = 300
    local posX = 40
    local posY = 40
    local scrollWidth = 900
    local scrollHeight = 440;

    --兑换比例
    local Proportion={588,888,168,1668}

	--if #self._itemCountList<7 then
		self._ScrollView_PropsExchange:setInnerContainerSize(cc.size(scrollWidth, scrollHeight))
        posY = scrollHeight - intervalY;
	--else
	--	self._ScrollView_PropsExchange:setInnerContainerSize({width = scrollWidth , height = intervalY*math.ceil(itemCount/3)});
    --    posY = intervalY*math.ceil(itemCount/3) - intervalY; 
	--end

    --注 这里使用背包中的数据 1:鲜花数量 2:幸运币数量 3:鱼骨头数量 4:鱼骨头数量
	for i=1,4 do
        --需要限制数量 或者判断图标是否存在
		local item = {}
        local temp_i
        if i~=4 then
            temp_i=i+2
        else
            temp_i=i+1
        end

        item.rootNode = cc.CSLoader:createNode("Bag/ExchangeItemLayer.csb")
        item.Image_Bg = item.rootNode:getChildByName("Image_Bg")
        item.Image_Bg:setTag(i)
        item.itemIcon = item.Image_Bg:getChildByName("Image_Item")
        item.itemIcon0 = item.Image_Bg:getChildByName("Image_Item_0")
        item.itemName = item.Image_Bg:getChildByName("Image_ItemName"):getChildByName("txtItemName")
        item.itemIcon:loadTexture("Bag/"..BagLayer.BAGITEMDIAMONDS[i])
        item.itemIcon0:loadTexture("Bag/"..BagLayer.BAGITEMDIAMONDDAYS[i])
        item.itemCount = self._itemCountList[temp_i]
        local strName = BagLayer.BAGITEMNAMES[temp_i].."x"..Proportion[i]
        item.itemName:setString(strName)
        self._ScrollView_PropsExchange:addChild(item.rootNode)
        self._showList[i] = item

        item.rootNode:setPosition(posX, posY);
        posX = posX + intervalX;
        if math.mod(i, 3) == 0 then
            posX = 40;
            posY = posY - intervalY;
        end

        local this = self
        function onclickItem(sender,eventType)
            if ccui.TouchEventType.ended==eventType then
                local tmpItem = self._showList[sender:getTag()]
                self.m_ExchangeDlg:resetUI()
                self.m_ExchangeDlg:setInfo({sender:getTag(), tmpItem.itemCount,Proportion[sender:getTag()]})
                self.m_ExchangeDlg:setVisible(true)
                self._topView = self.m_ExchangeDlg
            end
        end
        item.Image_Bg:addTouchEventListener(onclickItem)
	end
end 

return BagLayer