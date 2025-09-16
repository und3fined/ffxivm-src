--
-- Author: chaooren
-- Date: 2021-01-26
-- Description: 技能预输入
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require ("Protocol/ProtoCommon")
local ProtoCS = require ("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local SpectrumCfg = require("TableCfg/SpectrumCfg")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap
local TimeUtil = require("Utils/TimeUtil")

---@class MainProSkillMgr : MgrBase
local MainProSkillMgr = LuaClass(MgrBase)

local AutoRaiseTickInterval = 0.5

function MainProSkillMgr:OnInit()
	self.SpectrumInfo = {}
    self.BtnClickMap = {}
    self.CurrentSpectrumIDs = {}
    self.LastPlayAnimPointTime = 0
    self.IsForbidSpectrum = false
end

function MainProSkillMgr:OnBegin()
    for _, value in pairs(SpectrumIDMap) do
        self.SpectrumInfo[value] = {CurValue = 0, IsStart = false, SpectrumMax = 0}
    end
	--begin：原来在OnPostInit中的内容
    self:LoadSpectrumTable()
    --end

    self.SpectrumInfoP3 = {}
end

function MainProSkillMgr:OnEnd()
end

function MainProSkillMgr:OnShutdown()

end

function MainProSkillMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SPECTRUM_ON, self.OnNetMsgSpectrumOn)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SPECTRUM_OFF, self.OnNetMsgSpectrumOff)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SPECTRUM_RESOURCE_UPDATE, self.OnNetMsgSpectrumUpdate)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_UPDATE_SPECTRUM_LIMIT, self.OnNetMsgUpdateSpectrumLimit)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_SPECTRUM, self.OnNetMsgSyncSpectrum)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SPECTRUM_CHANGE_VALUE, self.OnNetMsgSpectrumChangeValue)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_NOTIFY_IS_FORBID_SPECTRUM_SKILL, self.OnForbidSpectrumSkillNotify)
end

function MainProSkillMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorDead, self.OnMajorDead)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
end

function MainProSkillMgr:SendEventCondition(EventID, ...)
    if not self.IsForbidSpectrum then
        EventMgr:SendEvent(EventID, ...)
    end
end

function MainProSkillMgr:OnInitSpectrumIDMap(SpectrumIDs)
    self.CurrentSpectrumIDs = SpectrumIDs
end

function MainProSkillMgr:OnNetMsgUpdateSpectrumLimit(MsgBody)
    local SpectrumID = MsgBody.SpectrumLimit.SpectrumID
    local ResourceMax = MsgBody.SpectrumLimit.ResourceMax
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if SingleSpectrumInfo and SingleSpectrumInfo.SpectrumMax ~= ResourceMax then
        SingleSpectrumInfo.SpectrumMax = ResourceMax
        FLOG_INFO(string.format("[Spectrum]SPECTRUM_LIMIT_UPDATE: ID=%d, Max=%d", SpectrumID, ResourceMax))
        EventMgr:SendEvent(EventID.SkillSpectrumValueUpdate, {SpectrumID = SpectrumID, ResourceMax = ResourceMax})
    end
end

function MainProSkillMgr:OnNetMsgSpectrumChangeValue(MsgBody)
    local SpectrumID = MsgBody.SpectrumID
    local TargetValue = MsgBody.ResourceChange
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if SingleSpectrumInfo then
        FLOG_INFO(string.format("[Spectrum]SPECTRUM_AUTO_RAISE: ID=%d, Value=%d", SpectrumID, TargetValue))
        if SingleSpectrumInfo.AutoRaise ~= TargetValue then
            local CurValue = SingleSpectrumInfo.AutoRaise
            SingleSpectrumInfo.AutoRaise = TargetValue
            if TargetValue == 0 then
                self:RequireSimulateEnd(SpectrumID)     --无增长时，关闭模拟
            elseif SingleSpectrumInfo.IsStart and CurValue == 0 then
                self:RequireSimulateStart(SpectrumID)   --量谱开启且从无到有时，开启模拟
            end
        end
    end
end

function MainProSkillMgr:OnForbidSpectrumSkillNotify(MsgBody)
    local IsForbidSpectrumSkill = MsgBody.IsForbidSpectrumSkill
    if self.IsForbidSpectrum ~= IsForbidSpectrumSkill then
        self.IsForbidSpectrum = IsForbidSpectrumSkill
        EventMgr:SendEvent(EventID.SkillSpectrumForbidStatus, MsgBody.IsForbidSpectrumSkill)
    end
end

function MainProSkillMgr:OnNetMsgSpectrumOn(MsgBody)
    self:OnProSkillBegin(MsgBody.SpectrumOnID)
    FLOG_INFO("[Spectrum]SPECTRUM_ON: " .. tostring(MsgBody.SpectrumOnID))
end

function MainProSkillMgr:OnNetMsgSpectrumOff(MsgBody)
    self:OnProSkillEnd(MsgBody.SpectrumOffID)
    FLOG_INFO("[Spectrum]SPECTRUM_OFF: " .. tostring(MsgBody.SpectrumOffID))
end


function MainProSkillMgr:OnNetMsgSpectrumUpdate(MsgBody)
    local RoleID = MsgBody.SpectrumResourceUpdate.RoleID
    local RecordList = MsgBody.SpectrumResourceUpdate.RecordList
    --0表示本人，场景内广播有明确RoleID
    if RoleID == 0 then
        for _, value in ipairs(RecordList) do
            self:OnSpectrumUpdate(value.SpectrumID, value.Resource)
        end
    else
        local SpectrumValueP3 = {}
        for _, value in ipairs(RecordList) do
            SpectrumValueP3[value.SpectrumID] = value.Resource
        end
        self.SpectrumInfoP3[RoleID] = SpectrumValueP3
        EventMgr:SendEvent(EventID.SkillSpectrumUpdateThirdPlayer, {RoleID = RoleID, RecordList = RecordList})
    end
end

function MainProSkillMgr:LoadSpectrumTable()
	local Result = SpectrumCfg:FindAllCfg("1=1")
    for _, value in ipairs(Result) do
		local ID = value.ID
		if self.SpectrumInfo[ID] ~= nil then
            if value.ResourceInc ~= nil then
			    self.SpectrumInfo[ID].AutoRaise = value.ResourceInc
            else
                self.SpectrumInfo[ID].AutoRaise = 0
            end
            self.SpectrumInfo[ID].SpectrumMax = value.SpectrumMax
            self.SpectrumInfo[ID].ResourceInit = value.ResourceInit
            self.SpectrumInfo[ID].bDeadKeep = value.DeadKeep == 1
            if ID == SpectrumIDMap.WHITEMAGE_MP or ID == SpectrumIDMap.WHITEMAGE_HP then
                local WhiteMageTable = string.split(value.TypeParam1, ",")
                local TypeParam = {}
                for index, value1 in ipairs(WhiteMageTable) do
                    TypeParam[index] = tonumber(value1)
                end
                self.SpectrumInfo[ID].TypeParam = TypeParam
            elseif ID == SpectrumIDMap.BARD_1_1 or ID == SpectrumIDMap.BARD_2_1 or ID == SpectrumIDMap.BARD_3_1 then
                self.BtnClickMap[ID] = value.TypeParam1
                self.SpectrumInfo[ID].TypeParam2 = value.TypeParam2
            else
                self.SpectrumInfo[ID].TypeParam = value.TypeParam1
                self.SpectrumInfo[ID].TypeParam2 = value.TypeParam2
            end
		end
	end
end

function MainProSkillMgr:OnProSkillBegin(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if SingleSpectrumInfo == nil then
        return
    end
    
    if SingleSpectrumInfo.IsStart == true then
        --FLOG_WARNING("Spectrum is Running, SpectrumID = " .. SpectrumID)
        return
    end

    SingleSpectrumInfo.IsStart = true
    SingleSpectrumInfo.CurValue = SingleSpectrumInfo.ResourceInit or 0

    EventMgr:SendEvent(EventID.SkillSpectrumOn, SpectrumID)
    self:RequireSimulateStart(SpectrumID)
end

function MainProSkillMgr:OnSpectrumUpdate(SpectrumID, Value)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if SingleSpectrumInfo == nil then
        FLOG_WARNING("[Spectrum] Update " .. tostring(SpectrumID) .. " not exist in SpectrumInfo")
        return
    end

    if Value > SingleSpectrumInfo.SpectrumMax then
        Value = SingleSpectrumInfo.SpectrumMax
    end

    if SingleSpectrumInfo.IsStart == false then
		return
	end
    local CurSpectrumValue = SingleSpectrumInfo.CurValue
    SingleSpectrumInfo.CurValue = Value
    EventMgr:SendEvent(EventID.SkillSpectrumUpdate, {SpectrumID = SpectrumID, CurValue = CurSpectrumValue, TargetValue = Value})
end

function MainProSkillMgr:OnProSkillEnd(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if SingleSpectrumInfo == nil then
        return
    end
    if SingleSpectrumInfo.IsStart == false then
        --FLOG_WARNING("Spectrum is Stop, SpectrumID = " .. SpectrumID)
		return
	end
	SingleSpectrumInfo.IsStart = false
    SingleSpectrumInfo.CurValue = SingleSpectrumInfo.ResourceInit or 0

    EventMgr:SendEvent(EventID.SkillSpectrumOff, SpectrumID)
    self:RequireSimulateEnd(SpectrumID)
end

function MainProSkillMgr:RequireSimulateStart(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if SingleSpectrumInfo == nil then
        return
    end

    if SingleSpectrumInfo.IsStart == false then
		return
	end

    if SingleSpectrumInfo.AutoRaise == 0 then
        return
    end

    SingleSpectrumInfo.LastSimulateTimeMS = TimeUtil.GetLocalTimeMS()

    if SingleSpectrumInfo.AutoRaiseTimer == nil then
        SingleSpectrumInfo.AutoRaiseTimer = self:RegisterTimer(self.OnSpectrumSimulateUpdate, AutoRaiseTickInterval, AutoRaiseTickInterval, 0, SpectrumID)
    end
end

function MainProSkillMgr:OnSpectrumSimulateUpdate(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if SingleSpectrumInfo == nil then
        FLOG_WARNING("[Spectrum] SimulateUpdate " .. tostring(SpectrumID) .. " not exist in SpectrumInfo")
        return
    end

    if SingleSpectrumInfo.IsStart == false then
		return
	end

    local DurtionTime = 500
    local LastSimulateTimeMS = SingleSpectrumInfo.LastSimulateTimeMS
    local CurSimulatteTimeMS = TimeUtil.GetLocalTimeMS()
    if LastSimulateTimeMS and LastSimulateTimeMS > 0 then
        DurtionTime = CurSimulatteTimeMS - LastSimulateTimeMS
    else
        FLOG_WARNING("[Spectrum] SimulateUpdate " .. tostring(SpectrumID) .. " no last simulate time")
    end
    SingleSpectrumInfo.LastSimulateTimeMS = CurSimulatteTimeMS

    local AutoRaise = (DurtionTime * 2 * SingleSpectrumInfo.AutoRaise) / 1000
    local CurValue = SingleSpectrumInfo.CurValue
    local TargetValue = CurValue + AutoRaise

    if TargetValue > SingleSpectrumInfo.SpectrumMax then
        TargetValue = SingleSpectrumInfo.SpectrumMax
    end

    if CurValue == TargetValue then
        return
    end

    SingleSpectrumInfo.CurValue = TargetValue
    EventMgr:SendEvent(EventID.SkillSpectrumUpdate, {SpectrumID = SpectrumID, CurValue = CurValue, TargetValue = TargetValue})
end

function MainProSkillMgr:RequireSimulateEnd(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if SingleSpectrumInfo == nil then
        return
    end

    SingleSpectrumInfo.LastSimulateTimeMS = nil
    if SingleSpectrumInfo.AutoRaiseTimer ~= nil then
        self:UnRegisterTimer(SingleSpectrumInfo.AutoRaiseTimer)
        SingleSpectrumInfo.AutoRaiseTimer = nil
    end
end

function MainProSkillMgr:OnMajorDead()
    return self:ClearAllSpectrum(false)
end

function MainProSkillMgr:OnPWorldExit()
    self:ClearAllSpectrum(true)
    self.SpectrumInfoP3 = {}
end

function MainProSkillMgr:ClearAllSpectrum(bForce)
    for key, value in pairs(self.SpectrumInfo or {}) do
        if value.IsStart == true and (not value.bDeadKeep or bForce) then
            self:OnProSkillEnd(key)
        end
    end
end

function MainProSkillMgr:GetSpectrumForbidStatus()
    return self.IsForbidSpectrum
end

function MainProSkillMgr:GetCurrentResource(SpectrumID)
    if not SpectrumID then
        return 0
    end
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if nil ~= SingleSpectrumInfo and SingleSpectrumInfo.IsStart == true then
        return SingleSpectrumInfo.CurValue
    end
    return 0
end

--获取广播的值，默认0
function MainProSkillMgr:GetSpectrumValueByRoleID(RoleID, SpectrumID)
    local RoleSpectrumInfo = self.SpectrumInfoP3[RoleID]
    if RoleSpectrumInfo then
        return RoleSpectrumInfo[SpectrumID] or 0
    end
    return 0
end

function MainProSkillMgr:GetSpectrumStart(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if nil ~= SingleSpectrumInfo then
        return SingleSpectrumInfo.IsStart
    end
    return nil
end

function MainProSkillMgr:GetSpectrumTypeParams(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if nil ~= SingleSpectrumInfo then
        return SingleSpectrumInfo.TypeParam
    end
    return nil
end

function MainProSkillMgr:GetSpectrumTypeParam2(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID]
    if nil ~= SingleSpectrumInfo then
        return SingleSpectrumInfo.TypeParam2
    end
    return nil
end

--触发技能针对资源的额外显示条件
--如骑士连招第一段要求资源小于10000隐藏，反之显示
function MainProSkillMgr:GetSkillLimitCfg(SpectrumID, SkillID)
    if SpectrumID == SpectrumIDMap.PALADIN then
        local TypeParam = self:GetSpectrumTypeParam2(SpectrumID)
        for _, value in ipairs(TypeParam) do
            if value.SkillID == SkillID then
                return true, value.Resource
            end
        end
    else
        --其他职业条件
    end
    return false
end

function MainProSkillMgr:GetSpectrumMaxValue(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID or -1]
    if SingleSpectrumInfo then
        return SingleSpectrumInfo.SpectrumMax
    end
    return 10000
end

function MainProSkillMgr:GetSpectrumAutoRaise(SpectrumID)
    local SingleSpectrumInfo = self.SpectrumInfo[SpectrumID or -1]
    if SingleSpectrumInfo then
        return SingleSpectrumInfo.AutoRaise
    end
    return 0
end

function MainProSkillMgr:ReqSpectrumData(_)
    --local bReconnect = Params.bReconnect
    local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
    local MsgBody = {};
    local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_SPECTRUM
    MsgBody.Cmd = SubMsgID
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    self:OnInitSpectrumIDMap({})
end

function MainProSkillMgr:OnNetMsgSyncSpectrum(MsgBody)
    local SpectrumSync = MsgBody.SpectrumSync
    local RecordList = MsgBody.SpectrumSync.RecordList
    print("[Spectrum]Connect: " .. table_to_string(SpectrumSync))
    local ActivateSpectrum = {}
    for _, value in ipairs(RecordList) do
        local SpectrumData = self.SpectrumInfo[value.SpectrumID]
        if SpectrumData then
            SpectrumData.IsStart = value.IsOpen
            SpectrumData.CurValue = value.Resource
            SpectrumData.SpectrumMax = value.ResourceMax
            SpectrumData.AutoRaise = value.ResourceChange or 0

            self:RequireSimulateStart(value.SpectrumID)
        end

        table.insert(ActivateSpectrum, value.SpectrumID)
    end
    self:OnInitSpectrumIDMap(ActivateSpectrum)
    --手动推送一次量谱替换，会存在量谱重连信息在量谱界面初始化之后，导致初始化流程未用到重连信息
    _G.EventMgr:SendEvent(EventID.SkillSpectrumSync)

    local IsForbidSpectrumSkill = SpectrumSync.IsForbidSpectrumSkill
    if self.IsForbidSpectrum ~= IsForbidSpectrumSkill then
        self.IsForbidSpectrum = IsForbidSpectrumSkill
        EventMgr:SendEvent(EventID.SkillSpectrumForbidStatus, MsgBody.IsForbidSpectrumSkill)
    end
end


local UseSkillNotSummonTipsIDList = ProSkillDefine.UseSkillNotSummonTipsIDList
--无召唤兽|小仙女使用需要召唤兽|小仙女的技能时，召唤师|学者量谱的表现逻辑
function MainProSkillMgr:UseSkillNotSummon(BuffLimitTipsID)
    for _, value in pairs(UseSkillNotSummonTipsIDList) do
        if BuffLimitTipsID == value then
            local CurTime = _G.TimeUtil.GetServerTimeMS()
            if CurTime - self.LastPlayAnimPointTime > 2000 then
                self.LastPlayAnimPointTime = CurTime
                _G.EventMgr:SendEvent(EventID.UseSkillNotSummonEvent)
                _G.EventMgr:SendEvent(EventID.SkillUnLockView)
            end
        end
    end
end

return MainProSkillMgr