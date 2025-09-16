--
-- Author: anypkvcai
-- Date: 2020-08-11 18:55:03
-- Description:
--

local LuaClass = require("Core/LuaClass")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local RegisterUtil = require("Register/RegisterUtil")

local FLOG_ERROR
local FLOG_WARNING

---@class GameNetMsgRegister
local GameNetMsgRegister = LuaClass()

function GameNetMsgRegister:Ctor()
	FLOG_ERROR = _G.FLOG_ERROR
	FLOG_WARNING = _G.FLOG_WARNING
	self.Registers = {}
end

---Register
---@param MsgID number          @ProtoCS.CS_CMD
---@param SubMsgID number
---@param Listener table | nil  @如果回调函数是类成员函数 Listener为self 其他情况为nil
---@param Callback function     @Callback function
function GameNetMsgRegister:Register(MsgID, SubMsgID, Listener, Callback)
	if nil == MsgID then
		FLOG_ERROR("GameNetMsgRegister:Register MsgID is nil!")
		FLOG_WARNING(debug.traceback())
		return
	end

	if nil == SubMsgID then
		FLOG_ERROR("GameNetMsgRegister:Register SubMsgID is nil!")
		FLOG_WARNING(debug.traceback())
		return
	end

	if nil == Callback then
		FLOG_ERROR("GameNetMsgRegister:Register Callback is nil!")
		FLOG_WARNING(debug.traceback())
		return
	end

	local Registers = self.Registers

	for i = 1, #Registers do
		local v = Registers[i]
		if v.MsgID == MsgID and SubMsgID == v.SubMsgID then
			FLOG_ERROR("GameNetMsgRegister:Repeat Register GameEvent MsgID:%d SubMsgID:%d", MsgID, SubMsgID)
			FLOG_WARNING(debug.traceback())
			return
		end
	end

	table.insert(self.Registers, { Listener = Listener, MsgID = MsgID, SubMsgID = SubMsgID })

	GameNetworkMgr:RegisterMsg(MsgID, SubMsgID, Listener, Callback, RegisterUtil.GetListenerName(Listener))
end

---UnRegisterMsg
---@param MsgID number          @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number
---@param Listener table | nil  @如果回调函数是类成员函数 Listener为self 其他情况为nil
function GameNetMsgRegister:UnRegister(MsgID, SubMsgID, Listener)
	local Registers = self.Registers

	for i = #Registers, 1, -1 do
		local v = Registers[i]
		if nil ~= v and v.MsgID == MsgID and v.SubMsgID == SubMsgID and v.Listener == Listener then
			table.remove(self.Registers, i)
			GameNetworkMgr:UnRegisterMsg(MsgID, SubMsgID, Listener)
			return
		end
	end
end

function GameNetMsgRegister:UnRegisterAll()
	local Registers = self.Registers

	for i = #Registers, 1, -1 do
		local v = Registers[i]
		GameNetworkMgr:UnRegisterMsg(v.MsgID, v.SubMsgID, v.Listener)
	end

	table.clear(self.Registers)
end

return GameNetMsgRegister