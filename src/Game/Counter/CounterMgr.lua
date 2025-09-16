--
-- Author: lydianwang
-- Date: 2022-03-03
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local CounterCfg = require("TableCfg/CounterCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local CS_CMD = ProtoCS.CS_CMD
local COUNTER_CMD = ProtoCS.CS_COUNTER_CMD
local COUNTER_TYPE = ProtoRes.COUNTER_TYPE

---@class CounterMgr : MgrBase
local CounterMgr = LuaClass(MgrBase)

---TODO[lydianwang]: CounterData[ID][1]可以改成当前值，让后台也传当前值而非剩余值过来
function CounterMgr:OnInit()
	self.CounterData = {} -- map< CounterID, { RemainValue, Limit, Restore } >
end

function CounterMgr:OnBegin()
	local CfgList = CounterCfg:FindAllCfg()
	for _, CfgItem in ipairs(CfgList) do
		local bTypeForever = (CfgItem.CounterType == COUNTER_TYPE.COUNTER_TYPE_FOREVER)
		local InitRemainValue = bTypeForever and CfgItem.SumLimit or CfgItem.Restore
		self.CounterData[CfgItem.ID] = {InitRemainValue, CfgItem.SumLimit, CfgItem.Restore}
	end
end

-- function CounterMgr:OnEnd()
-- end

-- function CounterMgr:OnShutdown()
-- end

function CounterMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COUNTER, COUNTER_CMD.LIST, self.OnNetMsgList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COUNTER, COUNTER_CMD.UPDATE_NOTIFY, self.OnNetMsgUpdateNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COUNTER, COUNTER_CMD.CLEAR, self.OnNetMsgClear)
end

function CounterMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function CounterMgr:OnNetMsgList(MsgBody)
	local Params = {
		UpdatedCounters = self:UpdateCounter(MsgBody.Update.Counters),
	}
	_G.EventMgr:SendEvent(_G.EventID.CounterInit, Params)
end

function CounterMgr:OnNetMsgUpdateNotify(MsgBody)
	local Params = {
		UpdatedCounters = self:UpdateCounter(MsgBody.Update.Counters),
	}
	_G.EventMgr:SendEvent(_G.EventID.CounterUpdate, Params)
end

function CounterMgr:OnNetMsgClear(_)
	local AllCounterValues = {}
	for CounterID, Data in pairs(self.CounterData) do
		Data[1] = Data[3]
		AllCounterValues[CounterID] = Data[1]
	end
	local Params = {
		UpdatedCounters = AllCounterValues,
	}
	_G.EventMgr:SendEvent(_G.EventID.CounterClear, Params)
end

function CounterMgr:OnGameEventLoginRes(_)
	self:SendCounterReqList()
end

function CounterMgr.SendNetMsgCounter(MsgBody)
	local MsgID = CS_CMD.CS_CMD_COUNTER
	local SubMsgID = MsgBody.Cmd
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CounterMgr:SendCounterReqList()
	local MsgBody = {
		Cmd = COUNTER_CMD.LIST,
		List = {}
	}
	self.SendNetMsgCounter(MsgBody)
end

function CounterMgr:UpdateCounter(NetMsgCounters)
	local UpdatedCounters = {}

	for CounterID, CounterData in pairs(NetMsgCounters) do
		if self.CounterData[CounterID] ~= nil then
			local CounterValue = self:ClampCounterValue(CounterID, CounterData.RemainCount)
			self.CounterData[CounterID][1] = CounterValue
			UpdatedCounters[CounterID] = CounterValue
		end
	end

	return UpdatedCounters
end

function CounterMgr:ClampCounterValue(CounterID, CounterValue)
	if self.CounterData[CounterID] == nil then return 0 end

	local CounterLimit = self.CounterData[CounterID][2]
	if CounterValue < 0 or CounterValue > CounterLimit then
		return math.max(0, math.min(CounterValue, CounterLimit))
	else
		return CounterValue
	end
end

-- ==================================================
-- 外部接口
-- ==================================================

---获取计数器剩余计数
function CounterMgr:GetCounterRemainValue(CounterID)
	if self.CounterData[CounterID] == nil then return nil end
	return self.CounterData[CounterID][1]
end

---获取计数器当前计数
function CounterMgr:GetCounterCurrValue(CounterID)
	local RemainValue = self:GetCounterRemainValue(CounterID)
	local Limit = self:GetCounterLimit(CounterID)
	if (RemainValue == nil) or (Limit == nil) then return nil end
	return Limit - RemainValue

end

---获取计数器周期限额回复
function CounterMgr:GetCounterRestore(CounterID)
	if self.CounterData[CounterID] == nil then return nil end
	return self.CounterData[CounterID][3]
end

---获取计数器总限额
function CounterMgr:GetCounterLimit(CounterID)
	if self.CounterData[CounterID] == nil then return nil end
	return self.CounterData[CounterID][2]
end

---如果业务协议带有计数器值，则传入检查，否则使用CounterMgr自己维护的计数器值做检查
function CounterMgr:CheckCounterToLimit(CounterID, CounterValue)
	-- Counter为空视为计数器到达限额
	if self.CounterData[CounterID] == nil then return true end

	if CounterValue ~= nil then
		return self:ClampCounterValue(CounterID, CounterValue) == 0
	else
		return self.CounterData[CounterID] == 0
	end
end

return CounterMgr