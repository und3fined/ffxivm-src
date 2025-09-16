local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillButtonIndexRange = SkillCommonDefine.SkillButtonIndexRange
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require ("Protocol/ProtoRes")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local TimeUtil = require("Utils/TimeUtil")
local BuffCfg = require("TableCfg/BuffCfg")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")


local MajorTriggerSkillMgr = LuaClass(MgrBase)

local SkillLogicMgr
local FLOG_INFO = _G.FLOG_INFO
function MajorTriggerSkillMgr:OnInit()
    SkillLogicMgr = _G.SkillLogicMgr
    self.TriggerList = {[SkillButtonIndexRange.Trigger_Start] = {ExpireTimerID = 0}
                      , [SkillButtonIndexRange.Trigger_End] = {ExpireTimerID = 0}
                      , [SkillButtonIndexRange.Trigger_PVP] = {ExpireTimerID = 0}}
    self.ServerLimitSkillState = {}
    self.ExtraSkillIndex = 999
    self.SkillSpectrumInfo = {}
    self.IsForbidPerdueSkill = false
end

function MajorTriggerSkillMgr:OnBegin()
end

function MajorTriggerSkillMgr:OnEnd()
end

function MajorTriggerSkillMgr:OnShutdown()
end

function MajorTriggerSkillMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_UPDATE_PERDUE_SKILL, self.OnNetMsgCombatUpdatePerdueSkill)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_PERDUE_SKILL, self.OnNetMsgCombatSyncPerdueSkill)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_REMOVE_PERDUE_SKILL, self.OnNetMsgCombatRemovePerdueSkill)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_NOTIFY_IS_FORBID_PERDUE_SKILL, self.OnNetMsgCombatForbidPerdueSkill)
end

function MajorTriggerSkillMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.UpdateBuff, self.OnCastBuff)
    self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)

    self:RegisterGameEvent(EventID.SkillSpectrumSync, self.OnTriggerSkillSpectrumSync)
    self:RegisterGameEvent(EventID.SkillSpectrumUpdate, self.OnTriggerSkillResourcesChange)
    self:RegisterGameEvent(EventID.SkillSpectrumOff, self.OnTriggerSkillSpectrumOff)

    self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)

    self:RegisterGameEvent(EventID.SkillMainPanelShow, self.OnSkillMainPanelShow)

    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)

    self:RegisterGameEvent(EventID.MajorDead, self.OnMajorDead)
end

function MajorTriggerSkillMgr:GetTriggerDataByIndex(Index)
    return self.TriggerList[Index]
end

function MajorTriggerSkillMgr:HideAllTriggerSkill(bRealHide)
    for Index, _ in pairs(self.TriggerList) do
        self.TriggerList[Index] = {ExpireTimerID = 0, IsTrigger = not bRealHide, IsShow = false}
        _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
    end
end

function MajorTriggerSkillMgr:OnPWorldExit()
    self:HideAllTriggerSkill(true)
end

function MajorTriggerSkillMgr:OnMajorDead()
    self:HideAllTriggerSkill(true)
end

function MajorTriggerSkillMgr:OnCastBuff(Params)
    local EntityID = Params.ULongParam1
    if EntityID ~= MajorUtil.GetMajorEntityID() then
        return
    end
    local BuffID = Params.IntParam1
    for Index, TriggerData in pairs(self.TriggerList) do
        local SkillID = TriggerData.SkillID or 0
        if TriggerData.IsTrigger and SkillID > 0 then
            local RelyBuffID = SkillMainCfg:FindValue(SkillID, "RelyBuffID") or 0
            if RelyBuffID > 0 and RelyBuffID == BuffID then
                self:ReleaseTimer(Index)

                TriggerData.ExpireTime = Params.ULongParam3
                local LastTime = Params.ULongParam3 - TimeUtil.GetServerTimeMS()
                if LastTime > 0 then
                    TriggerData.IsShow = true
                    TriggerData.FullTime = BuffCfg:FindValue(RelyBuffID, "LiveTime") or 0
                    if TriggerData.FullTime > 0 then
                        TriggerData.ExpireTimerID = self:RegisterTimer(self.TriggerSkillExpire, LastTime / 1000, 1, 1, Index)
                    end
                else
                    TriggerData.IsShow = false
                end

                _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
            end
        end
    end
end

function MajorTriggerSkillMgr:OnRemoveBuff(Params)
    local EntityID = Params.ULongParam1
    if EntityID ~= MajorUtil.GetMajorEntityID() then
        return
    end
    local BuffID = Params.IntParam1
    for Index, TriggerData in pairs(self.TriggerList) do
        local SkillID = TriggerData.SkillID or 0
        if TriggerData.IsTrigger and SkillID > 0 then
            local RelyBuffID = SkillMainCfg:FindValue(SkillID, "RelyBuffID") or 0
            if RelyBuffID > 0 and RelyBuffID == BuffID then
                TriggerData.IsShow = false
                _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
            end
        end
    end
end

function MajorTriggerSkillMgr:OnTriggerSkillSpectrumSync()
    for Index, TriggerData in pairs(self.TriggerList) do
        local SkillID = TriggerData.SkillID or 0
        if TriggerData.IsTrigger and SkillID > 0 then
            TriggerData.IsShow = self:GetSkillStatusBySpectrum(SkillID)
            _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
        end
    end
end

function MajorTriggerSkillMgr:OnTriggerSkillResourcesChange(ResourcesType)
    local SpectrumID = ResourcesType.SpectrumID or 0
    if SpectrumID == 0 then
        return
    end
    local TargetValue = ResourcesType.TargetValue
    for Index, TriggerData in pairs(self.TriggerList) do
        if TriggerData.IsTrigger then
            local OutSpectrumID, AssetCost = self:GetSkillSpectrumCost(TriggerData.SkillID or 0)
            if SpectrumID == OutSpectrumID then
                TriggerData.IsShow = AssetCost <= TargetValue
                _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
            end
        end
    end
end

function MajorTriggerSkillMgr:OnTriggerSkillSpectrumOff(SpectrumID)
    if SpectrumID == nil or SpectrumID == 0 then
        return
    end
    for Index, TriggerData in pairs(self.TriggerList) do
        local SkillID = TriggerData.SkillID or 0
        if TriggerData.IsTrigger and SkillID > 0 then
            local OutSpectrumID, AssetCost = self:GetSkillSpectrumCost(SkillID)
            if SpectrumID == OutSpectrumID and AssetCost > 0 then
                TriggerData.IsShow = false
                _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
            end
        end
    end
end

function MajorTriggerSkillMgr:OnNetMsgCombatUpdatePerdueSkill(MsgBody)
    local PerdueSkill = MsgBody.UpdatePerdueSkill.Skill
    local Index = SkillMainCfg:FindValue(PerdueSkill.SkillID, "TriggerButtonIndex")
    self:NetMsgCombatUpdatePerdueSkill(Index, PerdueSkill)
end

function MajorTriggerSkillMgr:OnNetMsgCombatSyncPerdueSkill(MsgBody)

    local IsForbidPerdueSkill = MsgBody.SyncPerdueSkill.IsForbidPerdueSkill
    self:UpdateIsForbidPerdueSkill(IsForbidPerdueSkill)

    for index = 1, #MsgBody.SyncPerdueSkill.SkillList do
        local PerdueSkill = MsgBody.SyncPerdueSkill.SkillList[index]
        local Index = SkillMainCfg:FindValue(PerdueSkill.SkillID, "TriggerButtonIndex")
        self:NetMsgCombatUpdatePerdueSkill(Index, PerdueSkill)
    end
end

function MajorTriggerSkillMgr:OnNetMsgCombatForbidPerdueSkill(MsgBody)
    local IsForbidPerdueSkill = MsgBody.IsForbidPerdueSkill
    self:UpdateIsForbidPerdueSkill(IsForbidPerdueSkill, true)
end

function MajorTriggerSkillMgr:NetMsgCombatUpdatePerdueSkill(Index, PerdueSkill)
    FLOG_INFO("[TriggerSkillMgr]=====Update PerdueSkill: " .. tostring(Index) .. " \n" .. table_to_string(PerdueSkill))

    if Index == 0 then
        local MajorLogicData = SkillLogicMgr:GetMajorSkillLogicData()
        if not MajorLogicData then
            self.ServerLimitSkillState[Index] = PerdueSkill
        else
            MajorLogicData:InitSkillMap(self.ExtraSkillIndex, PerdueSkill.SkillID)
            _G.EventMgr:SendEvent(EventID.CastLimitSkill, Index, PerdueSkill)
        end
        return
    end

    self:ReleaseTimer(Index)

    local SkillID = PerdueSkill.SkillID
    local TriggerData = self.TriggerList[Index]
    TriggerData.SkillID = SkillID
    TriggerData.ExpireTime = PerdueSkill.ExpireTime
    TriggerData.LastCount = PerdueSkill.LastCount or 0
    TriggerData.IsTrigger = true
    TriggerData.IsShow = self:GetSkillStatusBySpectrum(SkillID)

    if not self:TriggerSkillBuffCondition(Index, SkillID) then
        self:TriggerSkillServerTimeCondition(Index, SkillID)
    end
    _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
end

function MajorTriggerSkillMgr:OnNetMsgCombatRemovePerdueSkill(MsgBody)
    local Index = SkillMainCfg:FindValue(MsgBody.RemovePerdueSkill.SkillID, "TriggerButtonIndex")
    self:NetMsgCombatRemovePerdueSkill(Index, MsgBody.RemovePerdueSkill)
end

function MajorTriggerSkillMgr:NetMsgCombatRemovePerdueSkill(Index, RemovePerdueSkill)
    FLOG_INFO("[TriggerSkillMgr]=====Remove PerdueSkill: " .. table_to_string(RemovePerdueSkill))
    if Index == 0 then
        local MajorLogicData = SkillLogicMgr:GetMajorSkillLogicData()
        if not MajorLogicData then
            self.ServerLimitSkillState[Index] = nil
        else
            MajorLogicData:InitSkillMap(self.ExtraSkillIndex, 0)
            _G.EventMgr:SendEvent(EventID.RemoveLimitSkill, Index, RemovePerdueSkill)
        end

        return
    end

    self:ReleaseTimer(Index)
    self.TriggerList[Index] = {ExpireTimerID = 0}
    _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
end

function MajorTriggerSkillMgr:GetSkillSpectrumCost(SkillID)
    if SkillID == 0 then
        return nil
    end
	local SpectrumInfo = self.SkillSpectrumInfo[SkillID]
	if SpectrumInfo ~= nil then
		return SpectrumInfo[1], SpectrumInfo[2]
	end
	self.SkillSpectrumInfo = {}

	local CostList = SkillMainCfg:FindValue(SkillID, "CostList")
	if CostList == nil then
		return nil
	end
	for _, value in pairs(CostList) do
		local AssetID = value.AssetId
		local AssetCost = value.AssetCost
        local ValueType = value.ValueType
        local Min = value.Min
		--技能量谱资源值大于0时需隐藏
		if value.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_SPECTRUM then
			local RetAssetCost = Min
			if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX then
				RetAssetCost = math.max(RetAssetCost, AssetCost)
			end
			self.SkillSpectrumInfo[SkillID] = { AssetID, RetAssetCost}
			return AssetID, RetAssetCost
		end
	end
	return nil
end

--true 显示         false 隐藏
function MajorTriggerSkillMgr:GetSkillStatusBySpectrum(SkillID)
    local LogicData = _G.SkillLogicMgr:GetSkillLogicData(_G.PWorldMgr.MajorEntityID)
    local SkillLearnedStatus = true
    if LogicData then
        SkillLearnedStatus = LogicData:IsSkillLearned(SkillID) == SkillUtil.SkillLearnStatus.Learned
    end
    local SpectrumID, AssetCost = self:GetSkillSpectrumCost(SkillID)
    if SpectrumID == nil then
       return true and SkillLearnedStatus
    end

    local CurResource = _G.MainProSkillMgr:GetCurrentResource(SpectrumID) or 0
    return AssetCost <= CurResource and SkillLearnedStatus
end

function MajorTriggerSkillMgr:TriggerSkillBuffCondition(Index, SkillID)
    local RelyBuffID = SkillMainCfg:FindValue(SkillID, "RelyBuffID")
    if RelyBuffID == 0 then
        return false
    end
    local TriggerData = self.TriggerList[Index]
    local BuffInfo = _G.SkillBuffMgr:GetBuffInfo(RelyBuffID)
    if BuffInfo then
        TriggerData.ExpireTime = BuffInfo.ExpdTime
        local LastTime = BuffInfo.ExpdTime - TimeUtil.GetServerTimeMS()
        if LastTime > 0 then
            TriggerData.FullTime = BuffCfg:FindValue(RelyBuffID, "LiveTime") or 0
            if TriggerData.FullTime > 0 then
                TriggerData.ExpireTimerID = self:RegisterTimer(self.TriggerSkillExpire, LastTime / 1000, 1, 1, Index)
            end
        else
            TriggerData.IsShow = false
        end
    else
        TriggerData.IsShow = false
    end
    return true
end

function MajorTriggerSkillMgr:TriggerSkillServerTimeCondition(Index, SkillID)
    local TriggerData = self.TriggerList[Index]
    local ServerTargetTime = TriggerData.ExpireTime
    if ServerTargetTime > 0 then
        local ServerTime = TimeUtil.GetServerTimeMS()
        local LastTime = ServerTargetTime - ServerTime
        if LastTime > 0 then
            TriggerData.FullTime = SkillMainCfg:FindValue(SkillID, "SkillValidTime") or 0
            if TriggerData.FullTime > 0 then
                TriggerData.ExpireTimerID = self:RegisterTimer(self.TriggerSkillExpire, LastTime / 1000, 1, 1, Index)
            else
                TriggerData.IsShow = false
                TriggerData.IsTrigger = false
            end
        else
            TriggerData.IsShow = false
            TriggerData.IsTrigger = false
        end
    end
end

function MajorTriggerSkillMgr:ReleaseTimer(Index)
    local TriggerData = self.TriggerList[Index]
    if TriggerData == nil then return end
    local ExpireTimerID = TriggerData.ExpireTimerID
    if ExpireTimerID > 0 then
        self:UnRegisterTimer(ExpireTimerID)
        TriggerData.ExpireTimerID = 0
    end
end

function MajorTriggerSkillMgr:TriggerSkillExpire(Index)
    self.TriggerList[Index] = {ExpireTimerID = 0}
    _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
end


function MajorTriggerSkillMgr:OnSkillReplace(Params)
    local SkillID = Params.SkillID
    local Index = Params.SkillIndex
    local TriggerData = self.TriggerList[Index]
    if TriggerData then
        --TODO:--story=119732613 【战斗模块】升级时的技能显示逻辑优化（待策划确认）完成后修改逻辑
        if Params.RawSkill then
            TriggerData.SkillID = SkillID
        else
            SkillID = TriggerData.SkillID
        end
        if TriggerData.IsTrigger then
            self:ReleaseTimer(Index)
            TriggerData.IsShow = self:GetSkillStatusBySpectrum(SkillID)
            if not self:TriggerSkillBuffCondition(Index, SkillID) then
                self:TriggerSkillServerTimeCondition(Index, SkillID)
            end
            _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
        end
    end
end


function MajorTriggerSkillMgr:OnSkillMainPanelShow(Params)
    if _G.PWorldMgr.MajorEntityID == Params.EntityID then
        for Index, PerdueSkill in pairs(self.ServerLimitSkillState) do
            self:NetMsgCombatUpdatePerdueSkill(Index, PerdueSkill)
        end
        self.ServerLimitSkillState = {}
    end
end

function MajorTriggerSkillMgr:ReqTriggerSkillList()
    local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
	local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_PERDUE_SKILL
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MajorTriggerSkillMgr:UpdateIsForbidPerdueSkill(IsForbidPerdueSkill, bUpdateTriggerBtn)
    if nil == IsForbidPerdueSkill then
        return
    end
    self.IsForbidPerdueSkill = IsForbidPerdueSkill or false
    if bUpdateTriggerBtn then
        for Index, _ in pairs(self.TriggerList) do
            _G.EventMgr:SendEvent(EventID.TriggerSkillUpdate, Index)
        end
    end
end

return MajorTriggerSkillMgr