local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SkillUtil = require("Utils/SkillUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require ("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
local RPNGenerator = require("Game/Skill/SelectTarget/RPNGenerator")
local LifeSkillConditionCfg = require("TableCfg/LifeSkillConditionCfg")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR
local AttrDefCfg = require("TableCfg/AttrDefCfg")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local CrafterConfig = require("Define/CrafterConfig")
local MsgTipsID = require("Define/MsgTipsID")
local SkillCheckErrorCode = CrafterConfig.SkillCheckErrorCode
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD

---@class CrafterSkillCheckMgr : MgrBase
local CrafterSkillCheckMgr = LuaClass(MgrBase)
--主要有以下内容
--1、刷新技能mask状态
--	判定是否是生产职业的生产技能、是不是技能ing、cd（工次）是否ok、技能条件、技能消耗是否足够
--2、cd相关管理
--3、CheckSkillCost消耗判定，技能流程可以直接调用：比如耐久、制作力、

function CrafterSkillCheckMgr:OnInit()
end

function CrafterSkillCheckMgr:OnBegin()
	self:Reset()
end

function CrafterSkillCheckMgr:OnEnd()
end

function CrafterSkillCheckMgr:OnShutdown()

end

--CrafterMgr:Reset的时候会触发
function CrafterSkillCheckMgr:Reset()
	--每次工次变化刷新
	self.SkillCDList = {}
    self.SkillCostListMap = {}
    self.bRandomEventLock = false
end

function CrafterSkillCheckMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_SYNC_COST, self.OnNetMsgSyncCost)
end

function CrafterSkillCheckMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
end

function CrafterSkillCheckMgr:OnRegisterTimer()
end

-- 属性修正
function CrafterSkillCheckMgr:OnNetMsgSyncCost(MsgBody)
    MsgBody = MsgBody or {}
    local SyncCost = MsgBody.SyncCost
    if SyncCost == nil then
        return
    end

    local SkillID = SyncCost.SkillID or 0
    local SkillCostList = self.SkillCostListMap[SkillID]
    if nil == SkillCostList then
        FLOG_ERROR("[CrafterSkillCheckMgr] Try to sync skill %d but no cost list found.", SkillID)
        return
    end

    local SyncType = SyncCost.Type or 0
    local SyncAttr = SyncCost.Attr or 0

    for _, Item in pairs(SkillCostList) do
        local AssetType = Item.AssetType
        local AssetID = Item.AssetId

        if AssetType == SyncType and AssetID == SyncAttr then
            Item.OriginCost = Item.OriginCost or Item.AssetCost
            Item.AssetCost = Item.OriginCost + SyncCost.Val
            return
        end
    end
    FLOG_ERROR(
        "[CrafterSkillCheckMgr] Try to sync skill %d but cannot find asset in cost list, type is %d, attr is %d.",
        SkillID, SyncType, SyncAttr)
end

function CrafterSkillCheckMgr:OnReconnect(SkillCDMap)
    local SkillCDList = {}
    local CachedSkillCDList = self.SkillCDList

    for SkillID, SkillCDInfo in pairs(CachedSkillCDList) do
        local NewSkillCD = SkillCDMap[SkillID]
        if NewSkillCD ~= nil then
            SkillCDList[SkillID] = { SkillID = SkillID, BaseCD = SkillCDInfo.BaseCD, SkillCD = NewSkillCD }
        else
            SkillCDList[SkillID] = SkillCDInfo
        end
    end
    self.SkillCDList = SkillCDList
    for SkillID, SkillCD in pairs(SkillCDMap) do
        if SkillCDList[SkillID] == nil then
            local BaseCD = SkillMainCfg:FindValue(SkillID, "CD")
            SkillCDList[SkillID] = { SkillID = SkillID, BaseCD = BaseCD, SkillCD = SkillCD }
        end
    end

    for _, SkillCDInfo in pairs(SkillCDList) do
        EventMgr:SendEvent(EventID.CrafterSkillCDUpdate, SkillCDInfo)
    end
end

local ProfConfig = CrafterConfig.ProfConfig

function CrafterSkillCheckMgr:RefreshConditionMask()
    local ProfID = _G.CrafterMgr.ProfID
    local Config = ProfConfig[ProfID]
    if not Config then
        return
    end
    local ConditionMaskIndexList = Config.ConditionMaskIndexList
    if not ConditionMaskIndexList then
        return
    end

    local CrafterMgr = _G.CrafterMgr
    for _, Index in pairs(ConditionMaskIndexList) do
        local Views = CrafterMgr:GetSkillViewsByIndex(Index)
        if Views then
            for _, View in pairs(Views) do
                local bIsValid = self:CheckCondition(View.BtnSkillID)
                View:UpdateConditionMaskFlag(not bIsValid)
            end
        end
    end
end

local IgnoreCDSkillMap = CrafterConfig.IgnoreCDSkillMap

local AttrTypeList <const> = {
    ProtoCommon.attr_type.attr_mk
}

local function UpdateCost()
    local AttrComp = MajorUtil.GetMajorAttributeComponent()
    if not AttrComp then
        return
    end

    local AttrCostMap = {}
    for _, AttrType in pairs(AttrTypeList) do
        local AttrValue = AttrComp and AttrComp:GetAttrValue(AttrType) or 0
        AttrCostMap[AttrType] = AttrValue
    end

    EventMgr:SendEvent(EventID.CrafterSkillCostUpdate, AttrCostMap)
end

function CrafterSkillCheckMgr:OnEventCrafterSkillRsp(MsgBody)
	local CrafterSkill = MsgBody.CrafterSkill
	local SkillID = MsgBody.LifeSkillID
	if not CrafterSkill or not SkillID or IgnoreCDSkillMap[SkillID] == true then
		return 
	end

	--走到这里的默认是生产技能，而生产技能的cd都是工次
	--这里就不再check一级分类是不是生产技能了

    -- 生产职业Cost更新(目前只有制作力)
    UpdateCost()

	--先刷新所有的技能的cd
	local RemoveIDList = {}
	for key, value in pairs(self.SkillCDList) do
		value.SkillCD = value.SkillCD - 1
		FLOG_INFO("Crafter CDUpdate: skillID %d 'cd = %d", key, value.SkillCD)
		EventMgr:SendEvent(EventID.CrafterSkillCDUpdate
			, { SkillID = key, BaseCD = value.BaseCD, SkillCD = value.SkillCD })

		if value.SkillCD <= 0 then
			RemoveIDList[key] = 0
		end
	end

	for key, _ in pairs(RemoveIDList) do
		self.SkillCDList[key] = nil
	end

	if self.SkillCDList[SkillID] == nil then
		local BaseCD = SkillMainCfg:FindValue(SkillID, "CD")
		if BaseCD and BaseCD > 0 then
			local CDInfo = {BaseCD = BaseCD, SkillCD = BaseCD}
			self.SkillCDList[SkillID] = CDInfo
			FLOG_INFO("Crafter CDUpdate-new: skillID %d 'cd = %d", SkillID, BaseCD)
			EventMgr:SendEvent(EventID.CrafterSkillCDUpdate
				, { SkillID = SkillID, BaseCD = BaseCD, SkillCD = BaseCD })
		end
	else
		FLOG_INFO("Crafter CDUpdate1: skillID %d 'cd = %d", SkillID, self.SkillCDList[SkillID].BaseCD)
		self.SkillCDList[SkillID].SkillCD = self.SkillCDList[SkillID].BaseCD
	end
end

function CrafterSkillCheckMgr:GetSkillCDInfo(SkillID)
    if self.SkillCDList[SkillID] then
        return self.SkillCDList[SkillID]
    end

	return nil
end

function CrafterSkillCheckMgr:GetSkillCD(SkillID)
    if self.SkillCDList[SkillID] then
        return self.SkillCDList[SkillID].SkillCD
    end

	return 0
end

local function SignCompute(CompareA, CompareB, Sign)
    if CompareA == nil or CompareB == nil or Sign == nil then
        return false
    end
    local SignEnum = ProtoRes.condition_sign
    if Sign == SignEnum.CONDITION_SIGN_NULL then
        return true
    elseif Sign == SignEnum.CONDITION_SIGN_EQ then
        return CompareA == CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_LT then
        return CompareA < CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_LE then
        return CompareA <= CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_GT then
        return CompareA > CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_GE then
        return CompareA >= CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_NE then
        return CompareA ~= CompareB
    end

    return false
end

local FeatureType = ProtoCS.FeatureType

local function CrafterSkillCondition(Executor, _, ConditionID)
    local Cfg = LifeSkillConditionCfg:FindCfgByKey(ConditionID)
    if Cfg == nil or Executor == nil then
        return false
    end

    local Condition = ProtoRes.lifeskill_condition_type

    local Type = Cfg.Type
    local Param1 = Cfg.Param1
    local Param2 = Cfg.Param2
    local Sign = Cfg.Sign

    if Type == Condition.LIFESKILL_CONDITION_INVALID then
    elseif Type == Condition.LIFESKILL_CONDITION_CRAFT_STEPS then	--工次
		local FeatureValue = _G.CrafterMgr:GetFeatureValue(ProtoCS.FeatureType.FEATURE_TYPE_STEPS)
        return SignCompute(FeatureValue, Param2, Sign)
    elseif Type == Condition.LIFESKILL_CONDITION_PROCESS then		--进度
		local FeatureValue = _G.CrafterMgr:GetFeatureValue(ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS)
        return SignCompute(FeatureValue, Param2, Sign)
    elseif Type == Condition.LIFESKILL_CONDITION_REACTION_INTENSITY then	--反应强度
		local FeatureValue = _G.CrafterMgr:GetFeatureValue(ProtoCS.FeatureType.FEATURE_TYPE_REACTION_INTENSITY)
        return SignCompute(FeatureValue, Param2, Sign)
    elseif Type == Condition.LIFESKILL_CONDITION_STAT_EXIST then	--存在状态
        local ContainBuffInt = _G.LifeSkillBuffMgr:GetMajorBuffPile(Param1) or 0
        return SignCompute(ContainBuffInt, Param2, Sign)
    elseif Type == Condition.LIFESKILL_CONDITION_MIN_TEMPERATURE then  -- 最低温度
        local Features = _G.CrafterMgr:GetFeatures()
        local FeatureValue = 0
        if Features then
            FeatureValue = math.min(
                Features[FeatureType.FEATURE_TYPE_HEAT_AA] or 0,
                Features[FeatureType.FEATURE_TYPE_HEAT_AB] or 0,
                Features[FeatureType.FEATURE_TYPE_HEAT_BA] or 0,
                Features[FeatureType.FEATURE_TYPE_HEAT_BB] or 0
            )
        end
        return SignCompute(FeatureValue, Param2, Sign)
    end

    return true
end

--判定是否是生产职业的生产技能、是不是技能ing、cd（工次）是否ok、技能条件
function CrafterSkillCheckMgr:CrafterSkillValid(Index, SkillID, ExtraParams)
	local SkillFirstClass = SkillMainCfg:FindValue(SkillID, "SkillFirstClass")
	if SkillFirstClass ~= ProtoRes.skill_first_class.PRODUCTION_SKILL then
        return nil, SkillCheckErrorCode.SkillFirstClass
    end

	local IsCrafterProf = MajorUtil.IsCrafterProf()
    if not IsCrafterProf then
        return nil, SkillCheckErrorCode.NotCrafterProf
    end

	--正在等技能回包ing，不可释放技能，所以需要禁用
	if _G.CrafterMgr.IsWaitingSkillRsp then
		return nil, SkillCheckErrorCode.WaitingSkillRsp
	end

    if self.bRandomEventLock then
        return nil, SkillCheckErrorCode.RandomEvent
    end

	local CD = self:GetSkillCD(SkillID)
	if CD > 0 then
		return nil, SkillCheckErrorCode.CD
	end
    
    local CurSkillWeight = _G.SkillPreInputMgr:GetCurrentSkillWeight()
    if CurSkillWeight then
        local SubSkillID = _G.SkillLogicMgr:GetMultiSkillReplaceResult(SkillID, MajorUtil.GetMajorEntityID())
        local ToCastSkillWeight = _G.SkillPreInputMgr:GetInputSkillWeight(SubSkillID)
        if ToCastSkillWeight and ToCastSkillWeight <= CurSkillWeight then
            FLOG_INFO("Crafter CurSkillWeight: %d ToCastSkillWeight: %d", CurSkillWeight, ToCastSkillWeight)
            return nil, SkillCheckErrorCode.SkillWeight
        end
    end

    if _G.SkillLogicMgr:IsSkillLearned(MajorUtil.GetMajorEntityID(), SkillID) ~= SkillUtil.SkillLearnStatus.Learned then
        FLOG_INFO("Skill %d not learned.", SkillID)
        return nil, SkillCheckErrorCode.NotLeaned
    end

    local CostOk, AssetType, AssetID = self:CheckSkillCost(SkillID)
	if not CostOk then
        if AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then
            MsgTipsUtil.ShowTipsByID(MsgTipsID.CrafterAttrNotEnough, nil, AttrDefCfg:GetAttrNameByID(AssetID))
        elseif AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_DURABILITY then
            MsgTipsUtil.ShowTipsByID(MsgTipsID.CrafterDurabilityNotEnough)
        end

		return nil, SkillCheckErrorCode.Cost
	end

    local Result = self:CheckCondition(SkillID)
    if not Result then
        return Result, SkillCheckErrorCode.SkillCondition
    end

    -- 职业特定的技能释放检查
    local ProfID = _G.CrafterMgr.ProfID
    local ProfMainPanelView = _G.UIViewMgr:FindVisibleView(CrafterConfig.ProfConfig[ProfID].MainPanelID)

    if ProfMainPanelView and ProfMainPanelView.CustomCheckSkillValid then
        local bIsValid, ErrorCode = ProfMainPanelView:CustomCheckSkillValid(Index, SkillID, ExtraParams)
        if bIsValid == false then
            return nil, ErrorCode
        end
    end

    return Result, 0
end

function CrafterSkillCheckMgr:CheckCondition(SkillID)
    local ConditionStr = SkillMainCfg:FindValue(SkillID, "LifeSkillCondition")
    if ConditionStr and ConditionStr ~= "" then
        local Result = RPNGenerator:ExecuteRPNBoolExpression(ConditionStr, self, nil, CrafterSkillCondition)
        return Result
    end

    return true
end

--刷新技能状态：到时候看是不是类似战斗技能那样的mask表示禁用
function CrafterSkillCheckMgr:RefreshSkillState()
	-- local MajorEntityID = MajorUtil.GetMajorEntityID()
    -- _G.SkillLogicMgr:SetSkillButtonEnable(MajorEntityID, SkillBtnState.CrafterSkillState
	-- 	, self, self.CrafterSkillValid)
end

--FeatureType:	ProtoCS.FeatureType.FEATURE_TYPE_DURABILITY  、FEATURE_TYPE_STEPS
--LimitValue:是不是够这个数值
function CrafterSkillCheckMgr:CheckFeature(FeatureType, LimitValue)
	local IsSuccess = false
	local FeatureValue = _G.CrafterMgr:GetFeatureValue(FeatureType)
	if LimitValue <= FeatureValue then
		IsSuccess = true
	end

	return IsSuccess
end

function CrafterSkillCheckMgr:CheckSkillCost(SkillID)
    local SkillCostListMap = self.SkillCostListMap
    local CostList = SkillCostListMap[SkillID]
    if CostList == nil then
        CostList = SkillMainCfg:FindValue(SkillID, "CostList")
        SkillCostListMap[SkillID] = table.deepcopy(CostList)
    end

    if CostList then
        for _, value in pairs(CostList) do
            local AssetType = value.AssetType
            local AssetID = value.AssetId
            local AdditionAssetID = value.AdditionAssetId
            if AdditionAssetID == 0 then
                AdditionAssetID = AssetID
            end
            local Value = value.AssetCost
            local ValueType = value.ValueType
            local Min = value.Min
            --[[
                属性判断
                - 2025.1.13更新 - 耐久资源前台不再判断
                - 2025.4.22更新 - 因为平衡性原因, 恢复上次的改动, 还是需要判断
            ]]
            if AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then
                local AttrComp = MajorUtil.GetMajorAttributeComponent()
                local CurAttrValue = AttrComp and AttrComp:GetAttrValue(AdditionAssetID) or 0
                if CurAttrValue < Min then
                    return false, AssetType, AdditionAssetID
                end
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurAttrValue < Value then
                    return false, AssetType, AdditionAssetID
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                    local AttrValue = AttrComp and AttrComp:GetAttrValue(AssetID) or 0
                    if CurAttrValue < AttrValue * Value / 10000 then
                        return false, AssetType, AdditionAssetID
                    end
                end
            elseif AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_DURABILITY and _G.CrafterMgr:CheckWeaverSkillCost(SkillID) == false then --耐久资源
                local CurDuration = _G.CrafterMgr:GetFeatureValue(ProtoCS.FeatureType.FEATURE_TYPE_DURABILITY)
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurDuration < Value then
                    return false, AssetType
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                    local MaxDuration = _G.CrafterMgr:GetCurTargetMaxDuration()
                    if CurDuration < MaxDuration * Value / 10000 then
                        return false, AssetType
                    end
                end
            end
        end
    end

	return true, nil
end

return CrafterSkillCheckMgr