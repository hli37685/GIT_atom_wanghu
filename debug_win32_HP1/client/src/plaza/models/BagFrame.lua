local BaseFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BaseFrame")
local BagFrame = class("BagFrame",BaseFrame)
local logincmd = appdf.req(appdf.HEADER_SRC .. "CMD_LogonServer")
local game_cmd = appdf.req(appdf.HEADER_SRC .. "CMD_GameServer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

function BagFrame:ctor(view,callbcak)
	BagFrame.super.ctor(self,view,callbcak)
end

-- 获取背包信息
BagFrame.OP_GET_BAGINFO = 0
-- 获取寄售行交易大厅信息
BagFrame.OP_GET_TRADINGFLOORINFO = 1
-- 寄售物品
BagFrame.OP_CONSIGNMENT = 2
-- 下架物品
BagFrame.OP_UNDERCARRIAGE = 3
-- 购买物品
BagFrame.OP_BUY = 4
-- 查询交易记录
BagFrame.OP_QUERYRECORD = 5
-- 道具合成
BagFrame.OP_COMPOUND = 6
-- 道具兑换
BagFrame.OP_CHANGE = 7
--使用喇叭
BagFrame.OP_USE_LABA = 8

--连接结果
function BagFrame:onConnectCompeleted()
	print("BagFrame:onConnectCompeleted oprateCode="..self._oprateCode)

	if self._oprateCode == BagFrame.OP_GET_BAGINFO then		
		self:sendQueryBag()
    elseif self._oprateCode == BagFrame.OP_GET_TRADINGFLOORINFO then		
		self:sendTradingFloorData(self._gameid, self._status)
    elseif self._oprateCode == BagFrame.OP_CONSIGNMENT then		
		self:sendConsignment(self._shopid, self._price, self._num)
    elseif self._oprateCode == BagFrame.OP_UNDERCARRIAGE then		
		self:sendUnderarriage(self._itemIndex)
    elseif self._oprateCode == BagFrame.OP_BUY then		
		self:sendBuy(self._itemIndex, self._pwd)   
    elseif self._oprateCode == BagFrame.OP_QUERYRECORD then		
		self:sendQueryTradingRecordData(self._gameid) 
    elseif self._oprateCode == BagFrame.OP_COMPOUND then		
		self:SendCompound(self._goodid,self._Comnum)
    elseif self._oprateCode == BagFrame.OP_CHANGE then		
		self:SendChange(self._Egoodid,self._EComnum)
    elseif self._oprateCode == BagFrame.OP_USE_LABA then		
		self:SendUseLaba(self._labaContent)
	else
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"未知操作模式！")
		end		
	end

end

--网络信息(短连接)
function BagFrame:onSocketEvent(main,sub,pData)
	local bCloseSocket = true
    local bNeedCloseSocket = true
	if main == yl.MDM_GP_USER_SERVICE then --道具命令
		if sub == yl.SUB_GP_GOODS_LIST then 	--背包查询
			self:onSubGetBagInfo(pData)
        elseif sub == yl.SUB_GP_GOODSSHOP_LIST then 
            if self._oprateCode == BagFrame.OP_GET_TRADINGFLOORINFO then
			    self:onSubGetTradingFloorInfo(pData)
            elseif self._oprateCode == BagFrame.OP_QUERYRECORD then
			    self:onSubGetTradingRecordInfo(pData)
            end
        --elseif sub == yl.SUB_GP_GOODSSHOPLIST_LIST then 
		--	self:onSubGetTradingRecordInfo(pData)
        elseif sub == yl.SUB_GP_GOODS_RESULT then 
            bNeedCloseSocket = false
	        self._use = 0
	        self:onCloseSocket()
			self:onSubOpResult(pData)
		else
			local message = string.format("未知命令码：%d-%d",main,sub)
			if nil ~= self._callBack then
				self._callBack(-1,message);
			end			
		end
	end

    if bNeedCloseSocket then
	    self._use = 0
	    self:onCloseSocket()
    end
end

--网络消息(长连接)
function BagFrame:onGameSocketEvent(main,sub,pData)
	if main == yl.MDM_GP_USER_SERVICE then
		print("GameSocket ShopDetail #" .. main .. "# #" .. sub .. "#")
		if sub == logincmd.SUB_GP_GOODS_QUERY then 		-- 背包查询
			self:onSubGetBagInfo(pData)
--		elseif sub == game_cmd.SUB_GR_GAME_PROPERTY_FAILURE then
--			self:onSubPropertyFailure(pData)
		end
	end
end

function BagFrame:onSubGetBagInfo(pData)
	local list = {}
    for i = 1, 6 do
        table.insert(list, pData:readdword())
    end

	if nil ~= self._callBack then
		self._callBack(yl.SUB_GP_GOODS_LIST,list)
	end

end
function BagFrame:onSubGetTradingFloorInfo(pData)
    local itemCount = pData:readword()
	local list = {}
    for i = 1, itemCount do
        list[i] = ExternalFun.read_netdata(logincmd.tagGoodsshopStatus, pData)
    end

	if nil ~= self._callBack then
		self._callBack(yl.SUB_GP_GOODSSHOP_LIST,list)
	end

end

function BagFrame:onSubGetTradingRecordInfo(pData)
    local itemCount = pData:readword()
	local list = {}
    for i = 1, itemCount do
        list[i] = ExternalFun.read_netdata(logincmd.tagGoodsshopStatus, pData)
    end

	if nil ~= self._callBack then
		self._callBack(yl.SUB_GP_GOODSSHOP_LIST,list)
	end

end

function BagFrame:onSubOpResult(pData)
--    local result = ExternalFun.read_netdata(logincmd.CMD_GP__GoodspayResult, pData)
    local bSuccess = pData:readbool()
    local dwCommand = pData:readword()
    local score = GlobalUserItem:readScore(pData)
    local strNotify = pData:readstring()
    local view = self:getViewFrame()
print(bSuccess,dwCommand,score,strNotify,view)
--    local topView = view:getTopView()
--    if topView then
--        view = topView
--    end
	--提示
    showToast(view, strNotify, 2)

    if bSuccess then
        if dwCommand == yl.SUB_GP_GOODS_PAY then
            if self._oprateCode == BagFrame.OP_CONSIGNMENT then	
                self:onSendQueryBag()
            elseif self._oprateCode == BagFrame.OP_UNDERCARRIAGE then	
                self:getViewFrame():getSaleList()
            elseif self._oprateCode == BagFrame.OP_BUY then
                -- 更新金币
                GlobalUserItem.lUserInsure = score
                self:getViewFrame():updateMoney()
                self:getViewFrame():getBuyList()
            end
        end
    end
	--合成
	if dwCommand == yl.SUB_GP_GOODS_COMPOUND then
		if bSuccess then
			print("合成成功")
			--showToast(self:getViewFrame(), "合成成功", 2)
			--更新背包
			self:getViewFrame()._BaglFrame:onSendQueryBag()
		else
			print("合成错误")
			--showToast(self:getViewFrame(), message, 2)
		end
	end
	--兑换
	if dwCommand == yl.SUB_GP_GOODS_CHANGE then
		if bSuccess then
			print("兑换成功")
			--showToast(self:getViewFrame(), "合成成功", 2)
			--更新背包
			self:getViewFrame()._BaglFrame:onSendQueryBag()
		else
			print("兑换错误")
			--showToast(self:getViewFrame(), message, 2)
		end
	end
	--喇叭使用
	if dwCommand == yl.SUB_GP_USELABA then
		if bSuccess then
			print("发送成功")
			self:getViewFrame()._BaglFrame:onSendQueryBag()
		else
			print("发送错误")
		end
	end
end

function BagFrame:onSubPropertyFailure(pData)
	print("============ BagFrame:onSubPropertyFailure ============")
	local code = pData:readdword()
	local szTip = pData:readstring()

	if nil ~= self._callBack then
		self._callBack(0,szTip)
	end
end

--获取背包
function BagFrame:sendQueryBag()
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsLoadInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_QUERY)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送背包查询失败！")
	end
end

function BagFrame:onSendQueryBag()
	self._oprateCode = BagFrame.OP_GET_BAGINFO
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsLoadInfo)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_QUERY)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)

	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送查询失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end


--查询当前寄售行正在出售商品
function BagFrame:sendTradingFloorData(gameid, status)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsshopLoadInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODSSHOP_QUERY)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
    gameid = gameid or 0
    buffer:pushdword(gameid)
    status = status or 0
    buffer:pushbyte(status)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送寄售行查询失败！")
	end
end

function BagFrame:onSendTradingFloorData(gameid, status)
	self._oprateCode = BagFrame.OP_GET_TRADINGFLOORINFO
    self._gameid = gameid
    self._status = status
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsshopLoadInfo)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODSSHOP_QUERY)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        gameid = gameid or 0
        buffer:pushdword(gameid)
        status = status or 0
        buffer:pushbyte(status)

	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送查询失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end


--寄售商品
function BagFrame:sendConsignment(shopid, price, num)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodspayLoadInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_PAY)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring("", yl.LEN_PASSWORD)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
    buffer:pushword(1)
    buffer:pushscore(price)
    buffer:pushword(shopid)
    buffer:pushdword(num)
    buffer:pushdword(0)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送寄售失败！")
	end
end

function BagFrame:onSendConsignment(shopid, price, num)
	self._oprateCode = BagFrame.OP_CONSIGNMENT
    self._shopid = shopid
    self._num = num
    self._price = price
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodspayLoadInfo)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_PAY)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring("", yl.LEN_PASSWORD)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        buffer:pushword(1)
        buffer:pushscore(price)
        buffer:pushword(shopid)
        buffer:pushdword(num)
        buffer:pushdword(0)

	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送查询失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end


--下架商品
function BagFrame:sendUnderarriage(itemindex)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodspayLoadInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_PAY)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring("", yl.LEN_PASSWORD)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
    buffer:pushword(2)
    buffer:pushscore(0)
    buffer:pushword(0)
    buffer:pushdword(0)
    buffer:pushdword(itemindex)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送寄售失败！")
	end
end

function BagFrame:onSendUnderarriage(itemindex)
	self._oprateCode = BagFrame.OP_UNDERCARRIAGE
    self._itemIndex = itemindex
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodspayLoadInfo)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_PAY)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring("", yl.LEN_PASSWORD)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        buffer:pushword(2)
        buffer:pushscore(0)
        buffer:pushword(0)
        buffer:pushdword(0)
        buffer:pushdword(itemindex)

	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送查询失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end


--购买商品
function BagFrame:sendBuy(itemIndex, pwd)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodspayLoadInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_PAY)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring(md5(pwd),yl.LEN_PASSWORD)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
    buffer:pushword(3)
    buffer:pushscore(0)
    buffer:pushword(0)
    buffer:pushdword(0)
    buffer:pushdword(itemIndex)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送购买失败！")
	end
end

function BagFrame:onSendBuy(itemIndex, pwd)
	self._oprateCode = BagFrame.OP_BUY
    self._itemIndex = itemIndex
    self._pwd = pwd
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodspayLoadInfo)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_PAY)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring(md5(pwd),yl.LEN_PASSWORD)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        buffer:pushword(3)
        buffer:pushscore(0)
        buffer:pushword(0)
        buffer:pushdword(0)
        buffer:pushdword(itemIndex)

	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送购买失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end


--查询交易记录
function BagFrame:sendQueryTradingRecordData(gameid)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsshopLoadInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODSSHOP_QUERY)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
    buffer:pushdword(gameid)
    buffer:pushbyte(1)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送交易记录查询失败！")
	end
end

function BagFrame:onSendQueryTradingRecordData(gameid)
	self._oprateCode = BagFrame.OP_QUERYRECORD
    self._gameid = gameid
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsshopLoadInfo)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODSSHOP_QUERY)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        buffer:pushdword(gameid)
        buffer:pushbyte(1)

	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送交易记录查询失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end

--道具合成
function BagFrame:onSendCompound(goodid,num)
	self._oprateCode = BagFrame.OP_COMPOUND
    self._goodid = goodid
    self._Comnum = num
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
		local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsCOMPOUNDInfo)
		buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_COMPOUND)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring("", yl.LEN_PASSWORD)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        buffer:pushword(goodid)
        buffer:pushdword(num)
	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送查询失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end

--道具合成
function BagFrame:SendCompound(goodid,num)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsCOMPOUNDInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_COMPOUND)
	buffer:pushdword(GlobalUserItem.dwUserID)
	buffer:pushstring("", yl.LEN_PASSWORD)
	buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
	buffer:pushword(goodid)
	buffer:pushdword(num)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发生合成失败！")
	end
end

--道具兑换
function BagFrame:onSendChange(goodid,num)
	self._oprateCode = BagFrame.OP_CHANGE
    self._Egoodid = goodid
    self._EComnum = num
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
		local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodschangeInfo)
		buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_CHANGE)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring("", yl.LEN_PASSWORD)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        buffer:pushword(goodid)
        buffer:pushdword(num)
	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送查询失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end

--道具兑换
function BagFrame:SendChange(goodid,num)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodschangeInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_GOODS_CHANGE)
	buffer:pushdword(GlobalUserItem.dwUserID)
	buffer:pushstring("", yl.LEN_PASSWORD)
	buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
	buffer:pushword(goodid)
	buffer:pushdword(num)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送兑换失败！")
	end
end

--使用喇叭
function BagFrame:SendUseLaba(strContent)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_uselaba)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_USELABA)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring("",yl.LEN_PASSWORD)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
    buffer:pushstring(strContent, yl.LEN_USER_CHAT)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送使用喇叭失败！")
	end
end

function BagFrame:onSendUseLaba(strContent)
	self._oprateCode = BagFrame.OP_USE_LABA
    self._labaContent = strContent
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_uselaba)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_USELABA)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring("",yl.LEN_PASSWORD)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        buffer:pushstring(strContent, yl.LEN_USER_CHAT)

	    --发送失败
	    if not self:sendSocketData(buffer) then
		    self._callBack(-1,"发送查询失败！")
	    end
	else
		if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
			self._callBack(-1,"建立连接失败！")
		end
	end	
end

return BagFrame
