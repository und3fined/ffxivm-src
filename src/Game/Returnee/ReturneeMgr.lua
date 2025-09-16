
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")

local GameNetworkMgr
local EventMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.GuideOptCmd

---@class ReturneeMgr : MgrBase
local ReturneeMgr = LuaClass(MgrBase)

---OnInit
function ReturneeMgr:OnInit()
	self.Edition = nil
	self.IsReturnee = nil
end

---OnBegin
function ReturneeMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
end

function ReturneeMgr:OnEnd()

end

function ReturneeMgr:OnShutdown()

end

function ReturneeMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_ReturneeStatus, self.ReturneeStatusRsp)
end

function ReturneeMgr:OnRegisterGameEvent()

end

-- 请求回归者状态
function ReturneeMgr:ReturneeStatusReq()
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_ReturneeStatus
	local MsgBody = { Cmd = SUB_MSG_ID.GuideOptCmd_ReturneeStatus }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ReturneeMgr:ReturneeStatusRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.ReturneeStatus then
		return
	end
	self.Edition = MsgBody.ReturneeStatus.Edition
	self.IsReturnee = MsgBody.ReturneeStatus.IsReturnee
end

function ReturneeMgr:SetIsReturnee(IsReturnee)
	self.IsReturnee = IsReturnee
end

function ReturneeMgr:SetEdition(Edition)
	self.Edition = Edition
end

return ReturneeMgr