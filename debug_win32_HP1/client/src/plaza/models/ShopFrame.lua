local BaseFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BaseFrame")
local ShopFrame = class("ShopFrame",BaseFrame)
local logincmd = appdf.req(appdf.HEADER_SRC .. "CMD_LogonServer")
local game_cmd = appdf.req(appdf.HEADER_SRC .. "CMD_GameServer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

function ShopFrame:ctor(view,callbcak)
	ShopFrame.super.ctor(self,view,callbcak)
end

-- 获取特权商城信息
ShopFrame.OP_GET_EXCHANGEINFO = 0
-- 购买会员
ShopFrame.OP_GET_PurchaseMember = 1
-- 购买喇叭
ShopFrame.OP_GET_TRUMPET = 2

--连接结果
function ShopFrame:onConnectCompeleted()
	print("ShopFrame:onConnectCompeleted oprateCode="..self._oprateCode)

	if self._oprateCode == ShopFrame.OP_GET_EXCHANGEINFO then
		self:SendQueryExchange()
	elseif self._oprateCode==ShopFrame.OP_GET_PurchaseMember then
		self:SendPurchaseMember(self._goodid,self._Comnum)
	elseif self._oprateCode==ShopFrame.OP_GET_TRUMPET then
		self:sendBuyTrumpet(self._buyTrumpetCnt,self._pwd)
	else
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"未知操作模式！")
		end		
	end

end

--网络信息(短连接)
function ShopFrame:onSocketEvent(main,sub,pData)
	local bCloseSocket = true
    local bNeedCloseSocket = true
	if main == yl.MDM_GP_USER_SERVICE then --道具命令
		if sub == yl.SUB_GP_EXCHANGE_PARAMETER then 	--特权商城查询
	        self._use = 0
	        self:onCloseSocket()
			self:onSubGetExChangeInfo(pData)
		elseif sub == yl.SUB_GP_PURCHASE_RESULT then
            bNeedCloseSocket = false
	        self._use = 0
	        self:onCloseSocket()
			self:onSubOpResult(pData)
		--喇叭购买
		elseif sub == yl.SUB_GP_GOODS_RESULT then
	        self._use = 0
	        self:onCloseSocket()
			self:onSubLabaInfo(pData)
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
function ShopFrame:onGameSocketEvent(main,sub,pData)
	if main == yl.MDM_GP_USER_SERVICE then
		print("GameSocket ShopDetail #" .. main .. "# #" .. sub .. "#")
		if sub == logincmd.SUB_GP_EXCHANGE_PARAMETER then 		-- 背包查询
			self:onSubGetExChangeInfo(pData)
--		elseif sub == game_cmd.SUB_GR_GAME_PROPERTY_FAILURE then
--			self:onSubPropertyFailure(pData)
		end
	end
end

function ShopFrame:onSubGetExChangeInfo(pData)
	local list = {}
print(pData:readdword())
print(pData:readdword())
print(pData:readdword())
	local itemCount=pData:readword()

	local list = {}
    for i = 1, itemCount do
        list[i] = ExternalFun.read_netdata(logincmd.tagMemberParameter, pData)
    end

	if nil ~= self._callBack then
		self._callBack(yl.SUB_GP_EXCHANGE_PARAMETER,list)
	end

end

--喇叭
function ShopFrame:onSubLabaInfo(pData)
	local cmdtable = ExternalFun.read_netdata(logincmd.CMD_GP__GoodspayResult, pData)
    local bSuccess = cmdtable.bSuccessed
    local wCommandID = cmdtable.wCommandID  --258购买喇叭 259发送喇叭
	local lCurrScore = cmdtable.lCurrScore
	local szNotifyContent = cmdtable.szNotifyContent
	if wCommandID==logincmd.SUB_GP_BUYLABA then
		if bSuccess then
			GlobalUserItem.lUserInsure =lCurrScore --银行存款
		end
		if nil ~= self._callBack then
			self._callBack(yl.SUB_GP_BUYLABA,szNotifyContent)
		end
	end
end

function ShopFrame:onSubOpResult(pData)
--    local result = ExternalFun.read_netdata(logincmd.CMD_GP__GoodspayResult, pData)
    local bSuccess = pData:readbool()
    local dwCommand = pData:readbyte()
    local score = GlobalUserItem:readScore(pData)
    local x = pData:readdouble()
    local strNotify = pData:readstring()

    local view = self:getViewFrame()
print(bSuccess,dwCommand,score,strNotify,view)
    showToast(view, strNotify, 2)
	if bSuccess then	
		--购买成功刷新金币	
        self:getViewFrame():updateScoreInfo()
	end

end

function ShopFrame:onSubPropertyFailure(pData)
	print("============ ShopFrame:onSubPropertyFailure ============")
	local code = pData:readdword()
	local szTip = pData:readstring()

	if nil ~= self._callBack then
		self._callBack(0,szTip)
	end
end

--获取特权商城信息
function ShopFrame:SendQueryExchange()
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsLoadInfo)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_EXCHANGE_QUERY)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送特权商品查询失败！")
	end
end

--获取特权商城信息
function ShopFrame:onSendQueryExchange()
	self._oprateCode = ShopFrame.OP_GET_EXCHANGEINFO
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_GoodsLoadInfo)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_EXCHANGE_QUERY)
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

--购买会员
function ShopFrame:SendPurchaseMember(goodid,num)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_PurchaseMember)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_PURCHASE_MEMBER)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushbyte(goodid)
        buffer:pushdword(num)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送购买会员失败！")
	end
end

--购买会员
function ShopFrame:onSendPurchaseMember(goodid,num)
print(goodid,num)
    self._goodid = goodid
    self._Comnum = num
	self._oprateCode = ShopFrame.OP_GET_PurchaseMember
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_PurchaseMember)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_PURCHASE_MEMBER)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushword(goodid)
        buffer:pushdword(num)
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

--购买喇叭
function ShopFrame:sendBuyTrumpet(tCnt, pwd)
	local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_buylaba)
	buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_BUYLABA)
	buffer:pushdword(GlobalUserItem.dwUserID)
    buffer:pushstring(md5(pwd),yl.LEN_PASSWORD)
    buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
    buffer:pushword(tCnt)

	--发送失败
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送背包查询失败！")
	end
end

--购买喇叭
function ShopFrame:onSendBuyTrumpet(tCnt, pwd)
	self._oprateCode = ShopFrame.OP_GET_TRUMPET
    self._buyTrumpetCnt = tCnt
    self._pwd = pwd
	if nil ~= self._gameFrame and self._gameFrame:isSocketServer() then
	    local buffer = ExternalFun.create_netdata(logincmd.CMD_GP_buylaba)
	    buffer:setcmdinfo(yl.MDM_GP_USER_SERVICE, logincmd.SUB_GP_BUYLABA)
	    buffer:pushdword(GlobalUserItem.dwUserID)
        buffer:pushstring(md5(pwd),yl.LEN_PASSWORD)
        buffer:pushstring(MultiPlatform:getInstance():getMachineId(), yl.LEN_MACHINE_ID)
        buffer:pushword(tCnt)

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


return ShopFrame
