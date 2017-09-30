local BaseFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BaseFrame")
local BindPhoneFrame = class("BindPhoneFrame",BaseFrame)
local logincmd = appdf.req(appdf.HEADER_SRC .. "CMD_LogonServer")
local game_cmd = appdf.req(appdf.HEADER_SRC .. "CMD_GameServer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

function BindPhoneFrame:ctor(view,callbcak)
	BindPhoneFrame.super.ctor(self,view,callbcak)
end

--获得认证码
BindPhoneFrame.OP_GET_CODE = 1

--绑定手机
BindPhoneFrame.OP_BIND_PHONE = 2


--网络消息(长连接)
function BindPhoneFrame:onGameSocketEvent(main,sub,pData)
	
end

--网络信息(短连接)
function BindPhoneFrame:onSocketEvent(main,sub,pData)
	if main == game_cmd.MDM_GR_USER then --用户服务

		if sub == yl.SUB_GP_OPERATE_FAILURE then
			self:OnSubOperateResult(pData)
		elseif sub == yl.SUB_GP_OPERATE_SUCCESS then
			self:OnSubOperateResult(pData)
		else
			local message = string.format("未知命令码：%d-%d",main,sub)
			if nil ~= self._callBack then
				self._callBack(-1,message);
			end			
		end
	end

	self:onCloseSocket()
end

function BindPhoneFrame:OnSubOperateResult(pData)
	local lResultCode = pData:readint()
	local szDescribe = pData:readstring()

	if nil ~= self._callBack then
		self._callBack(lResultCode,szDescribe)
	end	
end

--连接结果
function BindPhoneFrame:onConnectCompeleted()
	print("BindPhoneFrame:onConnectCompeleted oprateCode="..self._oprateCode)

	if self._oprateCode == BindPhoneFrame.OP_GET_CODE then			--获得认证码
		self:OnSendQueryCode()
	elseif self._oprateCode == BindPhoneFrame.OP_BIND_PHONE then	--绑定手机
		self:OnSendBindPhone()
	else
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"未知操作模式！")
		end		
	end

end

function BindPhoneFrame:SendQueryCode(phone)
	
	--操作记录
	self._oprateCode = BindPhoneFrame.OP_GET_CODE
	self._phone_number = phone

	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end

function BindPhoneFrame:OnSendQueryCode()

	local buffer = ExternalFun.create_netdata(game_cmd.CMD_GP_Query_Bind_Phone_Code)

	buffer:setcmdinfo(game_cmd.MDM_GR_USER,game_cmd.SUB_GP_QUERY_BIND_PHONE_VALIDCODE)
	buffer:pushdword(GlobalUserItem.dwUserID)
	buffer:pushstring(self._phone_number,yl.LEN_MOBILE_PHONE)
	buffer:pushstring(GlobalUserItem.szMachine,yl.LEN_MACHINE_ID)
	
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送请求验证码失败！")
	end
end

function BindPhoneFrame:SendBindPhone( phone, code )
	--操作记录
	self._oprateCode = BindPhoneFrame.OP_BIND_PHONE
	self._phone_number = phone
	self._bind_code = code

	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end

function BindPhoneFrame:OnSendBindPhone()
	
	local buffer = ExternalFun.create_netdata(game_cmd.CMD_GP_Bind_Phone)

	buffer:setcmdinfo(game_cmd.MDM_GR_USER,game_cmd.SUB_GP_BIND_PHONE)
	buffer:pushdword(GlobalUserItem.dwUserID)
	buffer:pushstring(GlobalUserItem.szloginPasswords,33)
	buffer:pushstring(GlobalUserItem.szMachine,yl.LEN_MACHINE_ID)
	buffer:pushstring(self._phone_number,yl.LEN_MOBILE_PHONE)
	buffer:pushstring(self._bind_code,yl.LEN_PHONE_CODE)
	
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送请求验证码失败！")
	end
end

return BindPhoneFrame
