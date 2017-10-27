local BaseFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.BaseFrame")
local PasswordFrame = class("PasswordFrame",BaseFrame)
local logincmd = appdf.req(appdf.HEADER_SRC .. "CMD_LogonServer")
local game_cmd = appdf.req(appdf.HEADER_SRC .. "CMD_GameServer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")



function PasswordFrame:ctor(view,callbcak)
	PasswordFrame.super.ctor(self,view,callbcak)
end

--获得认证码
PasswordFrame.OP_GET_CODE = 1

--绑定手机
PasswordFrame.OP_RESET_PASSWORD = 2


--网络消息(长连接)
function PasswordFrame:onGameSocketEvent(main,sub,pData)
	
end

--网络信息(短连接)
function PasswordFrame:onSocketEvent(main,sub,pData)
	if main == game_cmd.MDM_GR_USER then --用户服务

		if sub == yl.SUB_GP_OPERATE_FAILURE then
			self:OnSubOperateResult( pData )
		elseif sub == yl.SUB_GP_OPERATE_SUCCESS then
			self:OnSubOperateResult( pData )
		else
			local message = string.format("未知命令码：%d-%d",main,sub)
			if nil ~= self._callBack then
				self._callBack(-1,message);
			end			
		end

	end

	self:onCloseSocket()
end

function PasswordFrame:OnSubOperateResult(pData)
	local lResultCode = pData:readint()
	local szDescribe = pData:readstring()
	if nil ~= self._callBack then
		self._callBack(lResultCode,szDescribe)
	end	
end

--连接结果
function PasswordFrame:onConnectCompeleted()
	print("PasswordFrame:onConnectCompeleted oprateCode="..self._oprateCode)

	if self._oprateCode == PasswordFrame.OP_GET_CODE then			--获得认证码
		self:OnSendQueryCode()
	elseif self._oprateCode == PasswordFrame.OP_RESET_PASSWORD then	--重置密码
		self:OnResetPassword()
	else
		self:onCloseSocket()
		if nil ~= self._callBack then
			self._callBack(-1,"未知操作模式！")
		end		
	end

end

function PasswordFrame:SendQueryCode(account)
	
	--操作记录
	self._oprateCode = PasswordFrame.OP_GET_CODE
	self._account = account

	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end

function PasswordFrame:OnSendQueryCode()

	local buffer = ExternalFun.create_netdata(logincmd.CMD_MB_Forget_PW_Query_Code)

	buffer:setcmdinfo(yl.MDM_MB_LOGON, yl.SUB_MB_FORGET_PW_QUERY_CODE )
	buffer:pushstring(self._account,yl.LEN_ACCOUNTS)

	local machineid = MultiPlatform:getInstance():getMachineId()
	buffer:pushstring(machineid,yl.LEN_MACHINE_ID)

	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送请求验证码失败！")
	end
end

function PasswordFrame:SendResetPassword( account, password, code )
	--操作记录
	self._oprateCode = PasswordFrame.OP_RESET_PASSWORD
	self._account = account
	self._password = md5( password )
	self._phone_code = code
	
	if not self:onCreateSocket(yl.LOGONSERVER,yl.LOGONPORT) and nil ~= self._callBack then
		self._callBack(-1,"建立连接失败！")
		return false
	end
	return true
end

function PasswordFrame:OnResetPassword()
	
	local buffer = ExternalFun.create_netdata(logincmd.CMD_MB_Forget_PW_Reset)

	buffer:setcmdinfo(yl.MDM_MB_LOGON,yl.SUB_MB_FORGET_PW_RESET)
	buffer:pushstring(self._account,yl.LEN_ACCOUNTS)
	buffer:pushstring(self._phone_code, yl.LEN_PHONE_CODE)
	buffer:pushstring(self._password,yl.LEN_PASSWORD)

	local machineid = MultiPlatform:getInstance():getMachineId()
	buffer:pushstring(machineid,yl.LEN_MACHINE_ID)	
	if not self:sendSocketData(buffer) and nil ~= self._callBack then
		self._callBack(-1,"发送重置密码失败！")
	end
end

return PasswordFrame