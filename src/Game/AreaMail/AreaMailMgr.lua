--
--Author: ds_herui
--Date: 2024-08-09 14:47
--Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Game.AreaMail.CS_AREA_MAIL_CMD

local GameNetworkMgr

---@class AreaMailMgr : MgrBase
local AreaMailMgr = LuaClass(MgrBase)


---OnInit
function AreaMailMgr:OnInit()
	self.Timer = nil
end

---OnBegin
function AreaMailMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
end

function AreaMailMgr:OnEnd()

end

function AreaMailMgr:OnShutdown()

end

function AreaMailMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_AREA_MAIL, SUB_MSG_ID.CS_AREA_MAIL_UPDATE, self.OnNetMsgAreaUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_AREA_MAIL, SUB_MSG_ID.CS_AREA_MAIL_GET, self.OnNetMsgAreaMailGet)
end

function AreaMailMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
end

function AreaMailMgr:OnGameEventRoleLoginRes(Params)
	if Params.bReconnect then
		self:OnNetMsgAreaMailReq()
	end
end

function AreaMailMgr:OnNetMsgAreaMailReq()
	local MsgID = CS_CMD.CS_CMD_AREA_MAIL
	local SubMsgID = SUB_MSG_ID.CS_AREA_MAIL_GET
	local MsgBody = {
		Cmd = SubMsgID
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function AreaMailMgr:OnNetMsgAreaUpdate(MsgBody)
	if MsgBody == nil then
		return
	end
	if self.Timer == nil then
		self.Timer = self:RegisterTimer(function() 
			self:OnNetMsgAreaMailReq()
			self:UnRegisterTimer(self.Timer)
			self.Timer = nil 
		end , math.random(1, 10))
	end
end

function AreaMailMgr:OnNetMsgAreaMailGet(MsgBody)
	-- 为了打印协议日志
end

--要返回当前类
return AreaMailMgr
