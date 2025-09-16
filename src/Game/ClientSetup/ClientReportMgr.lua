--
-- Author: loiafeng
-- Date : 2023-04-14 09:56:38
-- Description: 客户端上报
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local ProtoCS = require("Protocol/ProtoCS")

-- @class ClientReportMgr : MgrBase
local ClientReportMgr = LuaClass(MgrBase)

function ClientReportMgr:OnInit()
end
function ClientReportMgr:OnBegin()
	self.AllowSendRoleLeave = true 
end
function ClientReportMgr:OnEnd()
end
function ClientReportMgr:OnShutDown()
end
function ClientReportMgr:OnRegisterNetMsg()
end
function ClientReportMgr:OnRegisterGameEvent()
end
function ClientReportMgr:OnRegisterTimer()
end

function ClientReportMgr:SetAllowSendRoleLeave(AllowSendRoleLeave)
	self.AllowSendRoleLeave = AllowSendRoleLeave
	_G.FLOG_INFO("ClientReportMgr Send RoleLeave : " .. tostring(AllowSendRoleLeave))
end

---上报客户端事件
---@param ReportType ProtoCS.ReportType 上报事件类型
---@param Value? string Json格式的数据
function ClientReportMgr:SendClientReport(Type, Params)
	if Type == ProtoCS.ReportType.ReportTypeRoleLeave and not self.AllowSendRoleLeave then
		return
	end
    local MsgID = ProtoCS.CS_CMD.CS_CMD_CLIENT_REPORT
	local SubMsgID = Type
	local MsgBody = {
		ReportType = SubMsgID,
	}

	for K, V in pairs(Params or {}) do
		MsgBody[K] = V
	end
	
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

return ClientReportMgr