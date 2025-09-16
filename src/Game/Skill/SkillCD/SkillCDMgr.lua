--
-- Author: chaooren
-- Date: 2021-03-01
-- Description: 技能CD
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SkillUtil = require("Utils/SkillUtil")
local EventID = require("Define/EventID")
local ProtoCS = require ("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local AttrType = ProtoCommon.attr_type
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillCdGroupCfg = require("TableCfg/SkillCdGroupCfg")
local PworldCfg = require("TableCfg/PworldCfg")

---@class SkillCDMgr : MgrBase
local SkillCDMgr = LuaClass(MgrBase)

local SkillCDList = {}
SkillCDMgr.CDTickTime = 0.1 --0.1秒更新一次技能CD

local ChargeCDList = {}
local MaxChargeCountList = {}

local SkillCDGroupList = {}
local CDGroupMax = 1000		--跟策划约定下

function SkillCDMgr:OnInit()

	self.CDTimer = 0
	self.ChargeTimer = 0

	self.SkillCDLastTime = 0
	self.ChargeCDLastTime = 0
end

function SkillCDMgr:OnBegin()
end

function SkillCDMgr:OnEnd()
	MaxChargeCountList = {}
	SkillCDList = {}
	ChargeCDList = {}
	SkillCDGroupList = {}
end

function SkillCDMgr:OnShutdown()

end

function SkillCDMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_CD, self.OnNetMsgCombatCD)
	self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_CD_LIST, self.OnNetMsgCombatCDList)

	self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_UPDATE_CHARGE, self.OnCombatUpdateCharge)
	self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_CHARGE_LIST, self.OnCombatSyncChargeList)

	self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_CLEAR_ALL_CD, self.OnCombatClearAllCD)
end

function SkillCDMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CastShortenCDTime, self.CastShortenCDTime)

	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	--生活技能
	self:RegisterGameEvent(EventID.MajorLifeSkillActionRsp, self.OnMajorLifeSkillActionRsp)

	self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)

	self:RegisterGameEvent(EventID.MountSkillRelease, self.OnMountSkillRelease)

	self:RegisterGameEvent(EventID.PWorldExit, self.OnExitWorldEvent)

	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
	--local CurrPWorldResID = PWorldMgr:GetCurrPWorldResID()
	--local Cfg = PworldCfg:FindValue(CurrPWorldResID, "CanResettingCD")
end

function SkillCDMgr:OnRegisterTimer()
	
end

function SkillCDMgr:OnGameEventLoginRes(Params)
	-- if Params.bReconnect then
	-- 	self:QueryCombatCDList()
	-- end
end

function SkillCDMgr:OnExitWorldEvent()
	MaxChargeCountList = {}
end

function SkillCDMgr:OnGameEventPWorldMapEnter(Params)
	--相同地图内切换时不清理CD
	if not Params.bChangeMap then
		return
	end
	local CurrPWorldResID = Params.CurrPWorldResID
	local CanResettingCD = PworldCfg:FindValue(CurrPWorldResID, "CanResettingCD")
	if CanResettingCD == 1 then
		self:ResetAllCD()
	end
end

function SkillCDMgr:OnMajorCreate()
	self:QueryCombatChargeList()
	self:QueryCombatCDList()
end


function SkillCDMgr:OnCombatClearAllCD(MsgBody)
	self:ResetAllCD()
end

function SkillCDMgr:ResetAllCD()
	for key, value in pairs(SkillCDList) do
		_G.EventMgr:SendEvent(EventID.SkillCDUpdateLua, { SkillID = key, BaseCD = value.BaseCD, SkillCD = 0 })
	end
	SkillCDList = {}
	self:UnRegisterTimer(self.CDTimer)
	self.CDTimer = 0


	for key, value in pairs(SkillCDGroupList) do
		_G.EventMgr:SendEvent(EventID.SkillCDGroupUpdateLua, { GroupID = key, SkillCD = 0, BaseCD = value.BaseCD })
	end
	SkillCDGroupList = {}

	for key, value in pairs(ChargeCDList) do
		value.ReChargeCD = 0
		value.CurChargeCount = value.MaxChargeCount
		_G.EventMgr:SendEvent(EventID.SkillChargeUpdateLua, { SkillID = key, MaskPercent = 0, ChargeData = value })
	end
	ChargeCDList = {}
	self:UnRegisterTimer(self.ChargeTimer)
	self.ChargeTimer = 0
end

--生活技能
function SkillCDMgr:OnMajorLifeSkillActionRsp(Params)
	local SkillID = Params.IntParam1
	local CD = SkillMainCfg:FindValue(SkillID, "CD") or 0
	if CD == 0 then
		return 
	end

	local CurTime = TimeUtil.GetServerTimeMS()
	local CDData = {ID = SkillID, Expd = CurTime + CD}
	self:DoSingleCD(CDData)
end

-- 坐骑技能
function SkillCDMgr:OnMountSkillRelease(SkillID)
	local CD = SkillMainCfg:FindValue(SkillID, "CD") or 0
	if CD == 0 then
		return 
	end

	local CurTime = TimeUtil.GetServerTimeMS()
	local CDData = {ID = SkillID, Expd = CurTime + CD}
	self:DoSingleCD(CDData)
end

--CD/Charge 修正
function SkillCDMgr:CastShortenCDTime(Params)
	if MajorUtil.GetMajorEntityID() ~= Params.ULongParam1 then
		return
	end
	local ShortenCDRate = Params.IntParam1 / 10000
	for key, value in pairs(ChargeCDList) do
		local SkillCD, QuickAttrInvalid = self:LoadSkillCDInfo(key)
		if SkillCD then
			if QuickAttrInvalid == 0 then
				SkillCD = SkillCD * (1 - ShortenCDRate)
				value.SkillCD = SkillCD
			end
		end
	end

	for key, value in pairs(SkillCDList) do
		local SkillCD, QuickAttrInvalid = self:LoadSkillCDInfo(key)
		if SkillCD then
			if QuickAttrInvalid == 0 then
				SkillCD = SkillCD * (1 - ShortenCDRate)
				value.BaseCD = SkillCD
			end
		end
	end
end


-------------------------------------CDGroup-------------------------------------------------------------------------
function SkillCDMgr:DoCDGroup(GroupID, SkillCD)
	if GroupID == 0 then
		return
	end

	if SkillCDGroupList[GroupID] == nil and SkillCD <= 0 then
		return
	end
	local BaseCD = (SkillCdGroupCfg:FindValue(GroupID, "Time") or 0) / 1000
	SkillCDGroupList[GroupID] = {SkillCD = SkillCD, BaseCD = BaseCD}
	if self.CDTimer == 0 then
		self.CDTimer = self:RegisterTimer(self.TickSkillCD, 0, self.CDTickTime, 0)
		self.SkillCDLastTime = TimeUtil.GetLocalTimeMS()
	end
end

-------------------------------------CDGroup End---------------------------------------------------------------------

-------------------------------------SkillCD----------------------------------------------------------------------------

function SkillCDMgr:QueryCombatCDList()
	local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
    local MsgBody = {};
    local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_CD_LIST
    MsgBody.Cmd = SubMsgID
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function SkillCDMgr:OnNetMsgCombatCD(MsgBody)
	local GCD = MsgBody.CD.CommCD
	self:DoSingleCD(MsgBody.CD.CD)
end

function SkillCDMgr:OnNetMsgCombatCDList(MsgBody)
	--local ObjID = MsgBody.ObjID
	local GCD = MsgBody.CDList.CommCD
	for _, value in ipairs(MsgBody.CDList.CoolDowns) do
		self:DoSingleCD(value)
	end
end

---CDData {ID:int, Expd:int}
function SkillCDMgr:DoSingleCD(CDData)
	local SkillID = CDData.ID
	local Expd = CDData.Expd

	local SkillCD = SkillUtil.StampToTime(Expd)
	SKILL_FLOG_ERROR(string.format("[SkillCDMgr]Case SingleCD %d|%s|%s", SkillID, tostring(Expd), tostring(SkillCD)))

	if SkillID < CDGroupMax then
		--is CD group
		self:DoCDGroup(SkillID, SkillCD)
		return
	end

	if SkillCDList[SkillID] == nil then
		if SkillCD <= 0 then
			return
		end
		local BaseCD, QuickAttrInvalid = self:LoadSkillCDInfo(SkillID)
		if not BaseCD or BaseCD <= 0 then
			return
		end
		if QuickAttrInvalid == 0 then
			local ShortenCDRate = 0
			if MajorUtil.GetMajorAttributeComponent() ~= nil then
				ShortenCDRate = MajorUtil.GetMajorAttributeComponent():GetAttrValue(AttrType.attr_shorten_cd_time) / 10000
			end
			BaseCD = BaseCD * (1 - ShortenCDRate)
		end
		if BaseCD - SkillCD <= 0.2 and BaseCD - SkillCD >= 0 then
			SkillCD = BaseCD
		end
		self:SetSkillCD(SkillID, BaseCD, SkillCD)
		_G.EventMgr:SendEvent(EventID.SkillCDUpdateLua, { SkillID = SkillID, BaseCD = BaseCD, SkillCD = SkillCD })
	else
		self:SetSkillCD(SkillID, SkillCDList[SkillID].BaseCD, SkillCD)
	end
end

function SkillCDMgr:SetSkillCD(SkillID, BaseCD, SkillCD)
	SkillCDList[SkillID] = {}
	SkillCDList[SkillID].SkillCD = SkillCD
	SkillCDList[SkillID].BaseCD = BaseCD
	if self.CDTimer == 0 then
		self.CDTimer = self:RegisterTimer(self.TickSkillCD, 0, self.CDTickTime, 0)
		self.SkillCDLastTime = TimeUtil.GetLocalTimeMS()
	end
	_G.EventMgr:SendEvent(EventID.SkillSetSkillCD, { SkillID = SkillID, BaseCD = BaseCD, SkillCD = SkillCD })
end

function SkillCDMgr:TickSkillCD()
	local ElementCount = 0
	local RemoveIDList = {}

	local CurrentTime = TimeUtil.GetLocalTimeMS()
	local IntervalTime = (CurrentTime - self.SkillCDLastTime) / 1000
	self.SkillCDLastTime = CurrentTime

	for key, value in pairs(SkillCDList) do
		ElementCount = ElementCount + 1
		local SkillCD = value.SkillCD
		if SkillCD <= 0 then
			RemoveIDList[key] = 0
			SkillCD = 0
		end
		-- local GroupID = SkillMainCfg:FindValue(key, "CDGroup")
		-- if GroupID > 0 then
		-- 	local GroupCD = SkillCDGroupList[GroupID] or 0
		-- 	SkillCD = math.max(SkillCD, GroupCD)
		-- end
		
		_G.EventMgr:SendEvent(EventID.SkillCDUpdateLua, { SkillID = key, BaseCD = value.BaseCD, SkillCD = SkillCD })
		SkillCD = value.SkillCD - IntervalTime
		SkillCDList[key].SkillCD = SkillCD
	end

	for key, _ in pairs(RemoveIDList) do
		SkillCDList[key] = nil
	end

	RemoveIDList = {}
	for GroupID, value in pairs(SkillCDGroupList) do
		ElementCount = ElementCount + 1
		if value.SkillCD <= 0 then
			table.insert(RemoveIDList, GroupID)
			value.SkillCD = 0
		end

		_G.EventMgr:SendEvent(EventID.SkillCDGroupUpdateLua, { GroupID = GroupID, SkillCD = value.SkillCD, BaseCD = value.BaseCD })
		value.SkillCD = value.SkillCD - IntervalTime
	end

	for _, value in ipairs(RemoveIDList) do
		SkillCDGroupList[value] = nil
	end

	if ElementCount == 0 then
		self:UnRegisterTimer(self.CDTimer)
		self.CDTimer = 0
		return
	end
end

function SkillCDMgr:GetCDGroup(GroupID)
	return SkillCDGroupList[GroupID]
end

--ret {SkillCD:int, BaseCD:int}
--这个没有考虑到冷却组信息，改用GetSkillRealCDValue这个吧
--可能返回nil
function SkillCDMgr:GetSkillCD(SkillID)
	return SkillCDList[SkillID]
end

--获取技能的CD值，考虑group信息
function SkillCDMgr:GetSkillRealCDValue(SkillID)
	if SkillID == 0 then return 0 end
	local CDGroup = SkillMainCfg:FindValue(SkillID, "CDGroup")
	local GroupCDValue = 0
	if CDGroup and CDGroup > 0 then
		local SkillCDGroupData = SkillCDGroupList[CDGroup]
		if SkillCDGroupData then
			GroupCDValue = SkillCDGroupData.SkillCD
		end
	end

	local NormalCDValue = 0
	local SkillCDData = SkillCDList[SkillID]
	if SkillCDData then
		NormalCDValue = SkillCDData.SkillCD
	end

	return math.max(NormalCDValue, GroupCDValue)
end

--返回技能基础CD，单位秒
function SkillCDMgr:LoadSkillCD(SkillID)
	if SkillID == nil then
		return 0
	end
	local CD = SkillMainCfg:FindValue(SkillID, "CD")
	if CD ~= nil then
		return CD / 1000
	end
	return 0
end

function SkillCDMgr:LoadSkillCDInfo(SkillID)
	if SkillID == nil then
		return 0, 0
	end
	local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
	if Cfg == nil then
		return 0, 0
	end
	return Cfg.CD / 1000, Cfg.QuickAttrInvalid
end

-------------------------------------SkillCD End------------------------------------------------------------------------

-------------------------------------ChargeCD---------------------------------------------------------------------------
function SkillCDMgr:QueryCombatChargeList()
	local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
    local MsgBody = {};
    local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_CHARGE_LIST
    MsgBody.Cmd = SubMsgID
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function SkillCDMgr:OnCombatUpdateCharge(MsgBody)
	local ChargeSkill = MsgBody.UpdateCharge
	self:SetChargeSkill(ChargeSkill.SkillID, ChargeSkill.ChargeBeginTime, ChargeSkill.MaxChargeCount)
end

function SkillCDMgr:OnCombatSyncChargeList(MsgBody)
	for _, value in pairs(MsgBody.ChargeList.List) do
		self:SetChargeSkill(value.SkillID, value.ChargeBeginTime, value.MaxChargeCount)
	end
end

function SkillCDMgr:SetChargeSkill(SkillID, ChargeBeginTime, MaxChargeCount)
	SKILL_FLOG_ERROR(string.format("[SkillCDMgr]Case ChargeBeginTime: %d, %d, %d", SkillID, ChargeBeginTime, MaxChargeCount))
	if MaxChargeCountList[SkillID] == nil or MaxChargeCountList[SkillID] ~= MaxChargeCount then
		--最大充能次数改变
		MaxChargeCountList[SkillID] = MaxChargeCount
		_G.EventMgr:SendEvent(EventID.SkillMaxChargeCountChange, { SkillID = SkillID, MaxChargeCount = MaxChargeCount})
	end
	local Time = (TimeUtil.GetServerTimeMS() - ChargeBeginTime) / 1000
	local SkillCD, QuickAttrInvalid = self:LoadSkillCDInfo(SkillID)
	if not SkillCD or SkillCD <= 0 then
		return
	end
	if QuickAttrInvalid == 0 then
		local ShortenCDRate = 0
		if MajorUtil.GetMajorAttributeComponent() ~= nil then
			ShortenCDRate = MajorUtil.GetMajorAttributeComponent():GetAttrValue(AttrType.attr_shorten_cd_time) / 10000
		end
		SkillCD = SkillCD * (1 - ShortenCDRate)
	end

	if ChargeCDList[SkillID] ~= nil then
		ChargeCDList[SkillID].SkillCD = SkillCD
		ChargeCDList[SkillID].LastTime = Time
		ChargeCDList[SkillID].MaxChargeCount = MaxChargeCount
		return
	end

	local MaxTime = SkillCD * MaxChargeCount
	--Time修正
	if SkillCD - Time % SkillCD < 0.5 then
		Time = math.ceil(Time / SkillCD) * SkillCD
	end

	if ChargeBeginTime == 0 then
		Time = MaxTime
	end
	--ReChargeCD:记录当充能次数为0时，应倒计时的充能CD
	ChargeCDList[SkillID] = {SkillCD = SkillCD, MaxChargeCount = MaxChargeCount, CurChargeCount = MaxChargeCount, LastTime = Time, ReChargeCD = 0}
	if self.ChargeTimer == 0 then
		self.ChargeTimer = self:RegisterTimer(self.TickChargeCD, 0, self.CDTickTime, 0)
		self.ChargeCDLastTime = TimeUtil.GetLocalTimeMS()
	end
end

function SkillCDMgr:TickChargeCD()
	local CurrentTime = TimeUtil.GetLocalTimeMS()
	local IntervalTime = (CurrentTime - self.ChargeCDLastTime) / 1000
	self.ChargeCDLastTime = CurrentTime

	local ElementCount = 0
	local RemoveIDList = {}
	for key, value in pairs(ChargeCDList) do
		ElementCount = ElementCount + 1
		local LastTime = value.LastTime
		if LastTime >= value.MaxChargeCount * value.SkillCD then
			RemoveIDList[key] = 0
		end

		local CurChargeCount = math.floor(LastTime / value.SkillCD)
		local MaskPercent = 1 - (LastTime % value.SkillCD) / value.SkillCD

		if CurChargeCount >= value.MaxChargeCount then
			CurChargeCount = value.MaxChargeCount
			MaskPercent = 0
		end
		local ReChargeCD = 0
		if CurChargeCount < 1 then
			ReChargeCD = MaskPercent * value.SkillCD
		end
		ChargeCDList[key].ReChargeCD = ReChargeCD
		ChargeCDList[key].CurChargeCount = CurChargeCount
		_G.EventMgr:SendEvent(EventID.SkillChargeUpdateLua, { SkillID = key, MaskPercent = MaskPercent, ChargeData = ChargeCDList[key] })
		LastTime = LastTime + IntervalTime
		ChargeCDList[key].LastTime = LastTime
	end
	
	for key, _ in pairs(RemoveIDList) do
		ChargeCDList[key] = nil
	end

	if ElementCount == 0 then
		self:UnRegisterTimer(self.ChargeTimer)
		self.ChargeTimer = 0
		return
	end
end


function SkillCDMgr:GetSkillChargeCount(SkillID)
	local CurrentCount = 0
	local MaxCount = 0

	if MaxChargeCountList[SkillID] ~= nil then
		MaxCount = MaxChargeCountList[SkillID]
	else
		local MaxChargeCount, IsCharge = self:LoadSkillChargeInfo(SkillID)
		if IsCharge == 1 then
			MaxCount = MaxChargeCount
		end
	end

	local ChargeSkill = ChargeCDList[SkillID]
	if ChargeSkill ~= nil then
		CurrentCount = math.clamp(math.floor(ChargeSkill.LastTime / ChargeSkill.SkillCD), 0, MaxCount)
	else
		CurrentCount = MaxCount
	end

	return CurrentCount, MaxCount
end

--return nil 代表技能不是充能技能,bExist == false意味着即使技能不在当前充能队列，也会通过db获取
function SkillCDMgr:GetSkillCurCharge(SkillID, bExist)
	local ChargeSkill = ChargeCDList[SkillID]
	if ChargeSkill ~= nil then
		return math.floor(ChargeSkill.LastTime / ChargeSkill.SkillCD)
	end
	return self:GetMaxChargeCount(SkillID, bExist)
end

--return nil 代表技能不是充能技能,bExist == false意味着即使技能不在当前充能队列，也会通过db获取
function SkillCDMgr:GetMaxChargeCount(SkillID, bExist)
	if MaxChargeCountList[SkillID] ~= nil then
		return MaxChargeCountList[SkillID]
	elseif bExist == false then
		local MaxChargeCount, IsCharge = self:LoadSkillChargeInfo(SkillID)
		if IsCharge == 1 then
			return MaxChargeCount
		end
	end
	return -1
end

function SkillCDMgr:GetReChargeCD(SkillID)
	local ChargeSkill = ChargeCDList[SkillID]
	if ChargeSkill ~= nil then
		return ChargeSkill.ReChargeCD or 0
	end
	return 0
end

function SkillCDMgr:LoadSkillChargeInfo(SkillID)
	if SkillID == nil then
		return 0, 0
	end
	local MaxChargeCount = SkillMainCfg:FindValue(SkillID, "MaxChargeCount")
	local IsCharge = SkillMainCfg:FindValue(SkillID, "IsCharge")
	return MaxChargeCount, IsCharge
end
-------------------------------------ChargeCD End--------------------------------------------------------------------

return SkillCDMgr