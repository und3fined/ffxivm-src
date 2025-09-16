
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillButtonStateMgr = require("Game/Skill/SkillButtonStateMgr")
local SkillBtnState = SkillButtonStateMgr.SkillBtnState
local SkillBtnTips = SkillButtonStateMgr.ButtonStateTips

local SkillMainCfg = require("TableCfg/SkillMainCfg")
local BuffCfg = require("TableCfg/BuffCfg")

local TimeUtil = require("Utils/TimeUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillSystemSeriesCfg = require("TableCfg/SkillSystemSeriesCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SkillUtil = require("Utils/SkillUtil")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local EventID = require("Define/EventID")

local SkillBuffMgr = require("Game/Skill/SkillBuffMgr")
local ProfUtil = require("Game/Profession/ProfUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsID = require("Define/MsgTipsID")

local GPressTimeInterval = 400
local ConstAffectedFlag = (2 ^ SkillBtnState.ValidStateMaxIndex) - 1

local SkillLogicData = LuaClass()

function SkillLogicData:Ctor(EntityID, bMajor)
    self.EntityID = EntityID
    self.bMajor = bMajor

    self.ProfID = 0
    self.Level = 0
    self.MapType = 0

--------------------------切换时数据继承--------------------------------
    --self.SkillMap[Index] = {SkillID = 技能主ID, LastPressTime = 记录最后按下的时间戳
        --, Press = 技能是否按下, StateList = 技能状态列表，遮罩用
        --, CostFlag = 按位记录不同消耗类型}
    self.SkillMap = {}
    self.PassiveList = {}   --被动技能

--------------------------切换时数据继承END------------------------------
--------------------------切换时数据不继承-------------------------------

    --服务器同步的数据都在这里
    self.ServerSkillSyncInfo = {}

    self.PostStateChange = false
    --------------------------切换时数据不继承END-------------------------

    self.bAllowAsync = bMajor

    --解锁的非一级技能轮盘上的技能
    self.NotFirstSkillUnlockList = {}

    --职能
    self.ProFunction = ProtoCommon.function_type.FUNCTION_TYPE_NULL

    --技能提示去重
    self.NowSkillBtnTipsList = {}
end

function SkillLogicData:GetReviseSkillSing(SkillID)
    if self.ServerSkillSyncInfo.ReviseSkillSingList then
        return self.ServerSkillSyncInfo.ReviseSkillSingList[SkillID]
    end
end

function SkillLogicData:GetReviseSkillAction(SkillID)
    if self.ServerSkillSyncInfo.ReviseSkillActionList then
        return self.ServerSkillSyncInfo.ReviseSkillActionList[SkillID]
    end
end

function SkillLogicData:GetSkillCost(SkillID)
    if self.ServerSkillSyncInfo.SkillCostList then
        return self.ServerSkillSyncInfo.SkillCostList[SkillID]
    end
end

function SkillLogicData:SetBaseInfo(Level, MapType, ProfID)
    self.ProfID = ProfID
    self.Level = Level
    self.MapType = MapType
    self.ProFunction = ProfUtil.Prof2Func(ProfID)
end

function SkillLogicData:GetLevel()
    return self.Level
end

function SkillLogicData:GetMapType()
    return self.MapType
end

function SkillLogicData:GetProfID()
    return self.ProfID
end

function SkillLogicData:AllowAsync()
    return self.bAllowAsync
end

function SkillLogicData:GetSkill(Index)
    return self.SkillMap[Index]
end

function SkillLogicData:GetBtnSkillID(Index)
    if self.SkillMap[Index] then
        return self.SkillMap[Index].SkillID
    else
        return 0
    end
end

function SkillLogicData:SetSkillID(Index, SkillID)
    if self.SkillMap[Index] then
        self.SkillMap[Index].SkillID = SkillID or 0
    else
        FLOG_WARNING(string.format("SkillLogicData:SetSkillID Invalid Index %d", Index))
    end
end

function SkillLogicData:GetButtonIndexBySkillID(SkillID)
    if SkillID and SkillID > 0 and self.SkillMap then
        for key, value in pairs(self.SkillMap) do
            if value.SkillID == SkillID then
                return key
            end
        end
    end
    return nil
end


function SkillLogicData:InitSkillMap(Index, SkillID)
    local _ <close> = CommonUtil.MakeProfileTag(string.format("SkillLogicData:InitSkillMap_%d_%d", Index, SkillID or 0))

    SkillID = SkillID or 0
    if SkillID == 0 then
        self.SkillMap[Index] = nil
        return
    end
    self.SkillMap[Index] = {}
    self.SkillMap[Index].SkillID = SkillID
    self.SkillMap[Index].LastPressTime = 0
    self.SkillMap[Index].Press = false
    self.SkillMap[Index].States = {ConditionStateList = {}, ConstStateList = {}, StateParams = {}, InValidStateCount = 0}
    self.SkillMap[Index].AffectedFlag = ConstAffectedFlag
    if self.bMajor ~= true and SkillID ~= 0 then
        local SeriesCfg = SkillSystemSeriesCfg:FindCfgByID(SkillID)
        if SeriesCfg then
            local GlobalMaxLevel = SkillUtil.GetGlobalConfigMaxLevel()
            local SeriesList = string.split(SeriesCfg.SkillQueue, ",")
            local NewSeriesList = {}
            for _, value in ipairs(SeriesList) do
                -- GlobalMaxLevel
                local SeriesID = tonumber(value)
                local UnLockLevel = SkillUtil.GetSkillLearnLevel(SeriesID, self.ProfID)
                if UnLockLevel <= GlobalMaxLevel then
                    table.insert(NewSeriesList, SeriesID)
                end
            end
            --连招队列大于1才会被记录
            if #NewSeriesList > 1 then
                self.SkillMap[Index].SeriesList = NewSeriesList
                self.SkillMap[Index].SeriesIndex = 1
                self.SkillMap[Index].bShowTableView = SeriesCfg.bShowTableView > 0
            end
        end
    end
end

function SkillLogicData:UpdateSingleSkill(Index, SkillID, bForceUpdate, bPostChange)
    if bForceUpdate or (self.SkillMap[Index] and self.SkillMap[Index].SkillID ~= SkillID) then
        if self.bMajor then
            local bLimitSkill = false
            local SkillButtonIndexRange = SkillCommonDefine.SkillButtonIndexRange
            if Index >= SkillButtonIndexRange.Limit_Start and Index <= SkillButtonIndexRange.Limit_End then
                local SkillType = SkillMainCfg:FindValue(SkillID, "Type")
                if SkillType == ProtoRes.skill_type.SKILL_TYPE_LIMIT then
                    bLimitSkill = true
                end
            end

            if bLimitSkill then
                _G.SkillLimitMgr:OnInitLimitSkills(Index, SkillID)
            end
        end

        self:InitSkillMap(Index, SkillID)
        if bPostChange then
            if self.bMajor then
                _G.SkillSeriesMgr:BreakSkillbyIndex(Index)
            end
            _G.SkillStorageMgr:BreakStorageSkill(self.EntityID, SkillID)

            _G.EventMgr:SendEvent(EventID.SkillReplace, {SkillIndex = Index, SkillID = SkillID, EntityID = self.EntityID})
        end
    end
end

function SkillLogicData:UpdatePassiveList(PassiveList)
    self.PassiveList = PassiveList or {}
end

function SkillLogicData:InitSkillList(InSkillList)
    if not InSkillList then
        FLOG_ERROR("[SkillLogic]Init SkillList Falid")
        return
    end

    self.ProfID = InSkillList.ProfID
    self.Level = InSkillList.Level
    self.MapType = InSkillList.MapType
    self.ProFunction = ProfUtil.Prof2Func(self.ProfID)
    local SkillList = InSkillList.SkillList

    for _, value in pairs(SkillList) do
        self:UpdateSingleSkill(value.Index, value.ID, true, false)
    end

    self:UpdatePassiveList(InSkillList.PassiveList)
end

function SkillLogicData:OnServerSkillListReplace(InSkillList, ClientSkillList)
    if not InSkillList then
        return
    end
    local _ <close> = CommonUtil.MakeProfileTag("SkillLogicData:OnServerSkillListReplace")
    local SkillList = InSkillList.SkillList

    for _, value in pairs(ClientSkillList) do
        local Index = value.Index
        local ServerID = SkillList[Index]
        local SkillID = ServerID ~= nil and ServerID.ID or value.ID
        _G.SkillSeriesMgr:ClearSkillbyIndex(Index)    --TODO[chaooren]变身主动清一下技能连招
        self:UpdateSingleSkill(Index, SkillID, true, true)
    end

    self:UpdatePassiveList(InSkillList.PassiveList)

    --TODO[chaooren] 暂时只让主角使用量谱
    if self.bMajor then
        local SpectrumList = InSkillList.SpectrumList or {}
        _G.MainProSkillMgr:OnInitSpectrumIDMap(SpectrumList)
        _G.EventMgr:SendEvent(EventID.SkillSpectrumReplace, self.EntityID)
    end
end

--频繁接受事件时会处理大量技能，这里计算好标志位，可在接受事件时提前判断是否需要响应
function SkillLogicData:RefreshAllAffectedFlag(Index, SkillID)
    local Flag = 0

    if self.SkillMap[Index] == nil then
        return
    end
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if Cfg == nil then
        self.SkillMap[Index].AffectedFlag = Flag
        return
    end

    local ProfID = self.ProfID

    if ProfID == ProtoCommon.prof_type.PROF_TYPE_FISHER then
        Flag = Flag | (1 << SkillBtnState.EnterFishingArea)
        Flag = Flag | (1 << SkillBtnState.FishState)
    end

    --这里可以再细化一下
    if _G.GatherMgr:IsGatherProf(ProfID) or ProfID == ProtoCommon.prof_type.PROF_TYPE_FISHER then
        Flag = Flag | (1 << SkillBtnState.SkillGP)
        if _G.GatherMgr:IsHighProductionSkill(SkillID) then
            Flag = Flag | (1 << SkillBtnState.GatherDurationMax)
            Flag = Flag | (1 << SkillBtnState.GatherHighProduceCnt)
        elseif _G.GatherMgr:IsDiscoverSkill(SkillID) then
            Flag = Flag | (1 << SkillBtnState.GatherStateCannotDiscover)
        elseif _G.GatherMgr:IsAddItemNumSkill(SkillID) then
            Flag = Flag | (1 << SkillBtnState.GatherAddItemNum)
        end
    else
        local CostList = Cfg.CostList
        if CostList then
            for _, value in pairs(CostList) do
                local AssetType = value.AssetType
                --需要消耗Mp的（有的技能配置消耗mp，但是mp消耗是0）
                if AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then
                    local AssetID = value.AssetId
                    local AdditionAssetID = value.AdditionAssetId
                    if AdditionAssetID == 0 then
                        AdditionAssetID = AssetID
                    end
                    if AdditionAssetID == ProtoCommon.attr_type.attr_mp then
                        Flag = Flag | (1 << SkillBtnState.SkillMP)
                    end
                end
            end
        end
        if SkillBuffMgr:CanBuffAffectSkill(SkillID) then
            Flag = Flag | (1 << SkillBtnState.BuffCondition)
        end
    end

    local ConditionFlagList = SkillButtonStateMgr.bSkillButtonStateConditionAffectedFlag
    for i = 1, SkillBtnState.ValidStateMaxIndex do
        if not ConditionFlagList[i] then
            Flag = Flag | (1 << i)
        end
    end

    self.SkillMap[Index].AffectedFlag = Flag
end

function SkillLogicData:CanSkillPressUp(Index)
    if self.SkillMap[Index] == nil then
        return false
    end
    local SkillID = self.SkillMap[Index].SkillID or 0
    local PressTimeInterval = SkillMainCfg:FindValue(SkillID, "PressTimeInterval") or 0
    PressTimeInterval = PressTimeInterval ~= 0 and PressTimeInterval or GPressTimeInterval
    local LastPressTime = self.SkillMap[Index].LastPressTime
    if LastPressTime == nil or TimeUtil.GetLocalTimeMS() - LastPressTime >= PressTimeInterval then
        return true
    end
    return false
end

function SkillLogicData:SetSkillPressUp(Index)
    if self.SkillMap[Index] then
        self.SkillMap[Index].LastPressTime = TimeUtil.GetLocalTimeMS()
    end
    return
end

function SkillLogicData:SetSkillPressFlag(Index, bPress)
    if self.SkillMap[Index] then
        self.SkillMap[Index].Press = bPress
    end
end

--返回指定按钮是否按下，若无指定按钮，返回是否存在按下按钮
function SkillLogicData:IsSkillPress(Index)
    if Index then
        return self.SkillMap[Index] and self.SkillMap[Index].Press or false
    else
        for _, value in pairs(self.SkillMap) do
            if value.Press then
                return true
            end
        end
        return false
    end
end

function SkillLogicData:GetButtonIndexState(Index)
    local SkillData = self.SkillMap[Index]
    if SkillData and SkillData.States then
        return  SkillData.States.InValidStateCount
    end
    return 0
end

--true valid, false invalid
function SkillLogicData:GetButtonState(Index, StateTag)
    local SkillData = self.SkillMap[Index]
    if not SkillData then
        return false, nil
    end
    local States = self.SkillMap[Index].States
    if not States or StateTag == nil then
        return true, nil
    end
    local Params = States.StateParams[StateTag]
    local State = nil
    if StateTag < SkillBtnState.SkillState_Max then
        State = States.ConditionStateList[StateTag]
    else
        State = States.ConstStateList[StateTag]
    end

    if State == nil then
        return true, Params
    end

    return State, Params
end

function SkillLogicData:UpdateAllStateList(Index, SkillID)
    local _ <close> = CommonUtil.MakeProfileTag("SkillLogicData:UpdateAllStateList" .. tostring(Index or 0))

    local SkillData = self.SkillMap[Index]
    if not SkillData then
        return
    end
    if not SkillData.States then
        SkillData.States = {ConditionStateList = {}, ConstStateList = {}, StateParams = {}, InValidStateCount = 0}
    else
        SkillData.States = {ConditionStateList = {}, ConstStateList = SkillData.States.ConstStateList, StateParams = {}, InValidStateCount = 0}
    end
    
    local SkillMainCfgData = SkillMainCfg:FindCfgByKey(SkillID)
    --不是个技能？
    if SkillMainCfgData == nil then
        return
    end

    local Character = ActorUtil.GetActorByEntityID(self.EntityID)
    if not Character then
        return
    end
    local StateParams = SkillData.States.StateParams
    local ConditionStateList = SkillData.States.ConditionStateList
    local ConstStateList = SkillData.States.ConstStateList

    local SkillLearnedStatus, LockLevel = self:IsSkillLearned(SkillID)
    local LearnStatus = SkillUtil.SkillLearnStatus
    if SkillLearnedStatus == LearnStatus.UnLockAdvancedProf then
       LockLevel = -1 
    end
    ConditionStateList[SkillBtnState.SkillLearn] = SkillLearnedStatus == LearnStatus.Learned
    StateParams[SkillBtnState.SkillLearn] = LockLevel

    if self.ProfID == ProtoCommon.prof_type.PROF_TYPE_FISHER then
        if _G.FishMgr:IsFishSkill(SkillID) then
            ConditionStateList[SkillBtnState.EnterFishingArea] = _G.FishMgr:FishSkillEnableStateInit(SkillID)
        end
        ConditionStateList[SkillBtnState.FishState] = _G.FishMgr:FishSkillValid(Index, SkillID)
    elseif MajorUtil.IsGatherProf() then
        if _G.GatherMgr:IsHighProductionSkill(SkillID) then
            _G.GatherMgr:RefreshSkillState()
        end
    end

    local StateComp = ActorUtil.GetActorStateComponent(self.EntityID)
    if StateComp then
        local SkillClass = SkillMainCfgData.Class

        ConstStateList[SkillBtnState.CanUseSkill] = (SkillClass & ProtoRes.skill_class.SKILL_CLASS_QUICK_STAND ~= 0)
            or (StateComp:GetActorControlState(_G.UE.EActorControllStat.CanUseSkill))

        if SkillClass & ProtoRes.skill_class.SKILL_CLASS_MOVE ~= 0 then
            ConditionStateList[SkillBtnState.CanUseMoveSkill] = StateComp:GetActorControlState(_G.UE.EActorControllStat.CanUseMoveSkill)
        end
    end

    local bValidSwimmingOrDivingOrFlying = SkillMainCfgData.ValidSwimmingOrDivingOrFlying == 1
    if not bValidSwimmingOrDivingOrFlying then
        local bSwimOrFly = Character:IsInFly() or Character:IsSwimming()
        ConditionStateList[SkillBtnState.Swimming_Fly] = not bSwimOrFly
    end

    local BuffComp = ActorUtil.GetActorBuffComponent(self.EntityID)
    if BuffComp then
        ConditionStateList[SkillBtnState.BuffCondition] = BuffComp:CanUseSkill(SkillID)
    end

    local CostList = SkillMainCfgData.CostList
    for _, value in pairs(CostList) do
        local AssetType = value.AssetType

        if AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then
            local AssetID = value.AssetId
            local AdditionAssetID = value.AdditionAssetId
            if AdditionAssetID == 0 then
                AdditionAssetID = AssetID
            end
            local Value = value.AssetCost
            local ValueType = value.ValueType
            local Min = value.Min

            local StateKey = nil
            local CurValue = 0
            if AdditionAssetID == ProtoCommon.attr_type.attr_mp then
                StateKey = SkillBtnState.SkillMP
                CurValue = ActorUtil.GetActorMP(self.EntityID)
            elseif AdditionAssetID == ProtoCommon.attr_type.attr_gp then
                StateKey = SkillBtnState.SkillGP
                CurValue = ActorUtil.GetActorGP(self.EntityID)
            end

            if StateKey then
                --属性修正信息替换数据库信息
                local SingleSkillCosts = self:GetSkillCost(SkillID)
                if SingleSkillCosts then
                    local SingleAttrCost = SingleSkillCosts[AssetID]
                    if SingleAttrCost then
                        Value = SingleAttrCost.Value
                        Min = SingleAttrCost.Min
                    end
                end
                local RequireCost = Min
                local bMpValid = true
                if CurValue < Min then
                    bMpValid = false
                else
                    local AttrComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
                    if AttrComp then
                        local CurAttrValue = AttrComp:GetAttrValue(AdditionAssetID)
                        if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX then
                            RequireCost = Value
                            if CurAttrValue < Value then
                                bMpValid = false
                            end
                        elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                            local AttrValue = AttrComp:GetAttrValue(AssetID)
                            RequireCost = AttrValue * Value / 10000
                            if CurAttrValue < RequireCost then
                                bMpValid = false
                            end
                        end
                    end
                end

                ConditionStateList[StateKey] = bMpValid
                StateParams[StateKey] = RequireCost
            end
        end
    end

    local UseStatus = SkillMainCfgData.UseStatus
    local SkillUseStatueEnum = ProtoRes.skill_use_status
    local IsCombatState = ActorUtil.IsCombatState(self.EntityID)
    if (UseStatus == SkillUseStatueEnum.SKILL_USE_STATUS_COMBAT and not IsCombatState)
         or (UseStatus == SkillUseStatueEnum.SKILL_USE_STATUS_ESCAPE and IsCombatState) then
            ConditionStateList[SkillBtnState.UseStatus] = false
    end

    local SkillWeight = SkillMainCfgData.SkillWeight
    if SkillWeight <= _G.SkillObjectMgr:GetCurrentSkillWeight(self.EntityID) then
        ConditionStateList[SkillBtnState.SkillWeight] = false
    end


    local InValidStateCount = 0
    for _, value in pairs(ConditionStateList) do
        InValidStateCount = InValidStateCount + (value and 0 or 1)
    end

    for _, value in pairs(SkillData.States.ConstStateList) do
        InValidStateCount = InValidStateCount + (value and 0 or 1)
    end

    SkillData.States.InValidStateCount = InValidStateCount
end

--按钮受某一状态/数值/属性影响的bool值
--true表示按钮不受该状态影响
function SkillLogicData:SetSkillButtonState(Index, Key, State, Params)
    local SkillData = self.SkillMap[Index]
    if Index == nil or SkillData == nil then
        return
    end

    local _ <close> = CommonUtil.MakeProfileTag(string.format("SkillLogicData:SetSkillButtonState_%d", Key))
    if not SkillData.States then
        SkillData.States = {ConditionStateList = {}, ConstStateList = {}, StateParams = {}, InValidStateCount = 0}
    end
    local BtnStates = SkillData.States

    BtnStates.StateParams[Key] = Params
    local StateList = Key > SkillBtnState.SkillState_Max and BtnStates.ConstStateList or BtnStates.ConditionStateList
    local CacheState = StateList[Key]
    if CacheState == State then
        return
    end

    local InValidStateCount = BtnStates.InValidStateCount
    if CacheState == false and State == true then
        BtnStates.InValidStateCount = InValidStateCount - 1
    elseif State == false then
        BtnStates.InValidStateCount = InValidStateCount + 1
    end

    StateList[Key] = State
end

function SkillLogicData:RequireSkillStatusUpdate()
    self.bRequireSkillStatusUpdate = true
end

--设置全部按钮可用性(目前为通用遮罩)(如major吟唱开始时需禁用全部按钮，结束时恢复)
--使用时应考虑各种边界情况，避免因未及时恢复导致按钮不可用
--Key SkillBtnState
--Condition 设置状态的条件，false表示不可用，true表示可用，nil表示无视
function SkillLogicData:SetSkillButtonEnable(Key, Listener, Condition, ...)
    if Condition == nil then
        return
    end
    local _ <close> = CommonUtil.MakeProfileTag("SkillLogicData:SetSkillButtonEnable_" .. tostring(Key or 0))

    local bConstType = Key > SkillBtnState.SkillState_Max

    local bEnable = nil
    local ConstStorageParams
    if bConstType then
        if Listener then
            bEnable, ConstStorageParams = Condition(Listener, ...)
        else
            bEnable, ConstStorageParams = Condition(...)
        end
        print(string.format("[SkillLogicData]SetConstStatus_%d_%s", Key, tostring(bEnable or 0)))
    end

    for index, value in pairs(self.SkillMap) do
        if value.SkillID and value.SkillID ~= 0 then
            local AffectedFlag = value.AffectedFlag or 0
            if not bConstType then
                if AffectedFlag & (1 << Key) > 0 then
                    local StorageParams
                    local bLocalEnable = nil
                    if Listener then
                        bLocalEnable, StorageParams = Condition(Listener, index, value.SkillID, ...)
                    else
                        bLocalEnable, StorageParams = Condition(index, value.SkillID, ...)
                    end

                    if bLocalEnable ~= nil then
                        self:SetSkillButtonState(index, Key, bLocalEnable, StorageParams)
                    end
                end
            else
                if bEnable ~= nil then
                    self:SetSkillButtonState(index, Key, bEnable, ConstStorageParams)
                end
            end
        end
    end
    self:RequireSkillStatusUpdate()
    --_G.EventMgr:SendEvent(EventID.SkillStatusUpdate)
end

--资源属性修改覆盖多个需求，单独拎出来
function SkillLogicData:OnSkillAssetAttrUpdate(Key, Params)
    for index, value in pairs(self.SkillMap) do
        local SkillID = value.SkillID
        if SkillID and SkillID ~= 0 then
            local AffectedFlag = value.AffectedFlag or 0
            if AffectedFlag & (1 << Key) > 0 then
                local bValid, RequireCost = self:PlayerAttrCheck(index, SkillID, Params)
                if bValid ~= nil then
                    self:SetSkillButtonState(index, Key, bValid, RequireCost)
                end
            end
        end
    end
    local EventParams = {Key = Key}
    self:RequireSkillStatusUpdate()
    --_G.EventMgr:SendEvent(EventID.SkillStatusUpdate)
    _G.EventMgr:SendEvent(EventID.SkillAssetAttrUpdate, EventParams)
end

function SkillLogicData:OnSkillProcessPreSlateTick()
    if self.PostStateChange == true then

        local StateComp = ActorUtil.GetActorStateComponent(self.EntityID)
        if StateComp then
            
            local StateCanUseSkill = StateComp:GetActorControlState(_G.UE.EActorControllStat.CanUseSkill)
            local StateCanUseMoveSkill = StateComp:GetActorControlState(_G.UE.EActorControllStat.CanUseMoveSkill)
            print(string.format("[SkillLogicData]PostStateChange_%s_%s", tostring(StateCanUseSkill), tostring(StateCanUseMoveSkill)))
            for Index, value in pairs(self.SkillMap) do
                self:ControlStateChange(Index, value.SkillID, StateCanUseSkill, StateCanUseMoveSkill)
            end
        end
        
        self:RequireSkillStatusUpdate()
        --_G.EventMgr:SendEvent(EventID.SkillStatusUpdate)
        self.PostStateChange = false
    end

    if self.bRequireSkillStatusUpdate then
        _G.EventMgr:PostEvent(EventID.SkillStatusUpdate)
        self.bRequireSkillStatusUpdate = false
    end
end

function SkillLogicData:ControlStateChange(Index, SkillID, StateCanUseSkill, StateCanUseMoveSkill)
    if SkillID ~= nil and SkillID ~= 0 then
        local CanUseSkill = false
        local SkillClass = SkillMainCfg:FindValue(SkillID, "Class") or 0

        if SkillClass & ProtoRes.skill_class.SKILL_CLASS_QUICK_STAND ~= 0 or StateCanUseSkill then
            CanUseSkill = true
        end

        self:SetSkillButtonState(Index, SkillBtnState.CanUseSkill, CanUseSkill)

        if SkillClass & ProtoRes.skill_class.SKILL_CLASS_MOVE ~= 0 then
            self:SetSkillButtonState(Index, SkillBtnState.CanUseMoveSkill, StateCanUseMoveSkill)
        end
    end
end

local AttrType2ButtonStatus = 
{
    [ProtoCommon.attr_type.attr_mp] = SkillBtnState.SkillMP,
    [ProtoCommon.attr_type.attr_gp] = SkillBtnState.SkillGP
}

function SkillLogicData:PlayerAttrCheck(Index, SkillID, AttrType)
    local SkillData = self.SkillMap[Index]
    if SkillData == nil then
        return
    end
    local AttrComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
    if SkillID and SkillID ~= 0 and AttrComp then
        local AttrValue = AttrComp:GetAttrValue(AttrType)
        local RequireValue = 0
        local CostList = SkillMainCfg:FindValue(SkillID, "CostList")
        for _, value1 in pairs(CostList or {}) do
            local AssetType = value1.AssetType
            local AssetID = value1.AssetId
            local ValueType = value1.ValueType
            local AdditionAssetID = value1.AdditionAssetId
            if AdditionAssetID == 0 then
                AdditionAssetID = AssetID
            end
            local Value = value1.AssetCost
            local Min = value1.Min
            if AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR and AdditionAssetID == AttrType then
                --属性修正信息替换数据库信息
                local SingleSkillCosts = self:GetSkillCost(SkillID)
                if SingleSkillCosts then
                    local SingleAttrCost = SingleSkillCosts[AssetID]
                    if SingleAttrCost then
                        Value = SingleAttrCost.Value
                        Min = SingleAttrCost.Min
                    end
                end
                RequireValue = Min
                if AttrType2ButtonStatus[AttrType] and (Value > 0 or Min > 0) then
                    SkillData.AffectedFlag = (self.SkillMap[Index].AffectedFlag or ConstAffectedFlag) | (1 << AttrType2ButtonStatus[AttrType])
                end

                if AttrValue < Min then
                    return false, RequireValue
                end
                RequireValue = Value
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and AttrValue < Value then
                    return false, Value
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                    RequireValue = AttrComp:GetAttrValue(AssetID) * Value / 10000
                    if AttrValue < RequireValue then
                        return false, RequireValue
                    end
                end
            end
        end
        return true, RequireValue
    end
    return false, 0
end

function SkillLogicData:PlayerGPCheck(_, SkillID)
    local AttrComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
    local CurMp = ActorUtil.GetActorMP(self.EntityID)
    if SkillID and SkillID ~= 0 and AttrComp then
        local CostList = SkillMainCfg:FindValue(SkillID, "CostList")
        for _, value1 in pairs(CostList) do
            local AssetType = value1.AssetType
            local AssetID = value1.AssetId
            local ValueType = value1.ValueType
            local AdditionAssetID = value1.AdditionAssetId
            if AdditionAssetID == 0 then
                AdditionAssetID = AssetID
            end
            local Value = value1.AssetCost
            local Min = value1.Min
            if
                AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR and
                    AdditionAssetID == ProtoCommon.attr_type.attr_gp
             then
                --属性修正信息替换数据库信息
                local SingleSkillCosts = self:GetSkillCost(SkillID)
                if SingleSkillCosts then
                    local SingleAttrCost = SingleSkillCosts[AssetID]
                    if SingleAttrCost then
                        Value = SingleAttrCost.Value
                        Min = SingleAttrCost.Min
                    end
                end

                if CurMp < Min then
                    return false
                end
                local CurAttrValue = AttrComp:GetAttrValue(AdditionAssetID)
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurAttrValue < Value then
                    return false
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                    local AttrValue = AttrComp:GetAttrValue(AssetID)
                    if CurAttrValue < AttrValue * Value / 10000 then
                        return false
                    end
                end
            end
        end
        return true
    end
    return false
end

local function CastSkillShowTips(Tag, Params, SkillID)
    local TipsConfig = SkillBtnTips[Tag]
    if TipsConfig then
        if type(TipsConfig) == "string" then
            MsgTipsUtil.ShowTips(TipsConfig)
        elseif type(TipsConfig) == "number" then
            MsgTipsUtil.ShowTipsByID(TipsConfig, nil, Params)
        else
            local TipsID, TipsString = TipsConfig(Params, SkillID)
            if TipsID then
                MsgTipsUtil.ShowTipsByID(TipsID, nil, Params)
            elseif TipsString then
                MsgTipsUtil.ShowTips(TipsString)
            end
        end
    end
end

--抽离部分需重复判断的技能释放条件，用于在 按下技能 预输入流程结束 吟唱流程结束时判断
--...无视多个mask
--默认给出蓝量不足提示
function SkillLogicData:CanCastSkill(Index, ShowTips, ...)
    -- 技能系统技能不作检查
    if not self.bMajor then
        return true
    end

	if _G.SingBarMgr:GetMajorIsSinging() then
		MsgTipsUtil.ShowTips(_G.LSTR(140074))  -- 读条中无法释放技能

		return false
	end
    if _G.MountMgr:IsRequestingMount() or _G.MountMgr:IsMajorAssembling() then
        _G.MountMgr:ReleaseRideComponentAssembleState()
        return false
    end

    local SkillID = self:GetBtnSkillID(Index)
    if SkillID == nil or SkillID == 0 then
        return false
    end
    -- 
    if _G.MountMgr:IsDisableOtherSkill() then
        if not MountMgr:IsMountSkill(SkillID) then
            MsgTipsUtil.ShowTipsByID(153020)  -- 请离开坐骑后再释放技能
            return false
        end
    end

    local States = self.SkillMap[Index].States
    local InValidStateCount = States.InValidStateCount
    local IgnoreTagList = {}
    for _, value in pairs({...}) do
        if value and (States.ConditionStateList[value] == false or States.ConstStateList[value] == false) then
            InValidStateCount = InValidStateCount - 1
        end
        IgnoreTagList[value] = true
    end

    if InValidStateCount > 0 then
        if ShowTips then
            local CurTime = TimeUtil.GetServerTimeMS()
            local SkillBtnTipTime = self.NowSkillBtnTipsList[Index]
            if nil == SkillBtnTipTime or (SkillBtnTipTime and CurTime - SkillBtnTipTime > 2000) then
                self.NowSkillBtnTipsList[Index] = CurTime
                for i = 1, SkillBtnState.ValidStateMaxIndex do
                    if not IgnoreTagList[i] and States.ConditionStateList[i] == false then
                        CastSkillShowTips(i, States.StateParams[i], SkillID)
                        return false
                    end
                end
            end
        end
        return false
    end

    local CostList = SkillMainCfg:FindValue(SkillID, "CostList")
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
            if AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_SPECTRUM then --量谱资源值判断
                local CurrentResource = _G.MainProSkillMgr:GetCurrentResource(AssetID) or 0
                if CurrentResource < Min then
                    return false
                end
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurrentResource < Value then
                    return false
                end
            elseif AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then --属性判断
                --属性修正信息替换数据库信息
                local SingleSkillCosts = self:GetSkillCost(SkillID)
                if SingleSkillCosts then
                    local SingleAttrCost = SingleSkillCosts[AssetID]
                    if SingleAttrCost then
                        Value = SingleAttrCost.Value
                        Min = SingleAttrCost.Min
                    end
                end
                local AttrComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
                local CurAttrValue = AttrComp and AttrComp:GetAttrValue(AdditionAssetID) or 0
                if CurAttrValue < Min then
                    return false
                end
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurAttrValue < Value then
                    return false
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                    local AttrValue = AttrComp and AttrComp:GetAttrValue(AssetID) or 0
                    if CurAttrValue < AttrValue * Value / 10000 then
                        return false
                    end
                end
            elseif AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_LIMIT_BREAK and self.bMajor then --极限技资源
                --TODO[chaooren] 暂时仅主角可用
                local CurrentResource = _G.SkillLimitMgr:GetLimitValue() or 0
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurrentResource < Value then
                    return false
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                    if CurrentResource < Min then
                        return false
                    end
                end
            end
        end
    end

    local Major = MajorUtil.GetMajor()
    if Major and Major.CharacterMovement:IsFalling() then
        local SkillClass = SkillMainCfg:GetSkillClass(SkillID)
        if (SkillClass & ProtoRes.skill_class.SKILL_CLASS_MOVE) ~= 0 then
            _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillLimitMoveFallingTips)
            return false
        end
    end
    
    
    return true
end

function SkillLogicData:CanCastSkillbyID(SkillID, ShowTips)
    if SkillID == nil or SkillID == 0 then
        return false
    end

    local CanUse,BuffIDs=_G.SkillBuffMgr:SkillUseCanUseByBuffLimit(SkillID)
    if not CanUse then
        return CanUse
    end

    local CostList = SkillMainCfg:FindValue(SkillID, "CostList")
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
            if AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_SPECTRUM then --量谱资源值判断
                local CurrentResource = _G.MainProSkillMgr:GetCurrentResource(AssetID) or 0
                if CurrentResource < Min then
                    return false
                end
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurrentResource < Value then
                    return false
                end
            elseif AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then --属性判断
                --属性修正信息替换数据库信息
                local SingleSkillCosts = self:GetSkillCost(SkillID)
                if SingleSkillCosts then
                    local SingleAttrCost = SingleSkillCosts[AssetID]
                    if SingleAttrCost then
                        Value = SingleAttrCost.Value
                        Min = SingleAttrCost.Min
                    end
                end
                local AttrComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
                local CurAttrValue = AttrComp:GetAttrValue(AdditionAssetID)
                local RetValue = true
                if CurAttrValue < Min then
                    RetValue = false
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurAttrValue < Value then
                    RetValue = false
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                    local AttrValue = AttrComp:GetAttrValue(AssetID)
                    if CurAttrValue < AttrValue * Value / 10000 then
                        RetValue = false
                    end
                end
                if AdditionAssetID == ProtoCommon.attr_type.attr_mp and RetValue == false then
                    --InternalShowTips("魔力不足")
                end
                if RetValue == false then
                    return false
                end
            elseif AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_LIMIT_BREAK and self.bMajor then --极限技资源
                --TODO[chaooren] 暂时仅主角可用
                local CurrentResource = _G.SkillLimitMgr:GetLimitValue() or 0
                if ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX and CurrentResource < Value then
                    return false
                elseif ValueType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
                    if CurrentResource < Min then
                        return false
                    end
                end
            end
        end
    end

    local StateComp = ActorUtil.GetActorStateComponent(self.EntityID)
    local SkillClass = SkillMainCfg:FindValue(SkillID, "Class")
    if
        StateComp == nil or
            ((SkillClass & ProtoRes.skill_class.SKILL_CLASS_QUICK_STAND == 0 and
                StateComp:GetActorControlState(_G.UE.EActorControllStat.CanUseSkill) == false))
        then
        return false
    end
    if SkillClass & ProtoRes.skill_class.SKILL_CLASS_MOVE ~= 0 then
        if StateComp:GetActorControlState(_G.UE.EActorControllStat.CanUseMoveSkill) == false then
            return false
        end
    end

    return true
end

function SkillLogicData:IsSkillLearned(SkillID)
    return SkillUtil.GetSkillLearnValid(SkillID, self.ProfID, self.Level)
end

function SkillLogicData:IsSkillLearnedMost(SkillID)
    local MinSkillLevel, MaxSkillLevel = SkillUtil.GetSkillLearnLevelRange(SkillID, self.ProfID)
    return self.Level >= MinSkillLevel and self.Level < MaxSkillLevel
end

--非主角使用，替代连招
function SkillLogicData:SkillMoveNext(SkillID, Index)
    local SkillInfo = self.SkillMap[Index]
    if SkillInfo then
        local NextSkillID, SeriesIndex = self:GetPlayerSeriesNext(SkillID, Index)
        if NextSkillID ~= SkillID then
            SkillInfo.SeriesIndex = SeriesIndex
            SkillInfo.SkillID = NextSkillID
            _G.EventMgr:SendEvent(EventID.SkillSystemReplace, {SkillIndex = Index, SkillID = NextSkillID, EntityID = self.EntityID, Type = 1}, true)
        end
    end
end

function SkillLogicData:SkillMoveTo(SkillID, Index, SeriesIndex)
    local SkillInfo = self.SkillMap[Index]
    if SkillInfo then
        local SeriesList = SkillInfo.SeriesList or {}
        local TargetSkillID = SeriesList[SeriesIndex]
        if TargetSkillID and TargetSkillID ~= SkillID then
            SkillInfo.SeriesIndex = SeriesIndex
            SkillInfo.SkillID = TargetSkillID
            _G.EventMgr:SendEvent(EventID.SkillSystemReplace, {SkillIndex = Index, SkillID = TargetSkillID, EntityID = self.EntityID, Type = 1}, true)
        end
    end
end

--Offset default 1
function SkillLogicData:GetPlayerSeriesNext(SkillID, Index, Offset)
    Offset = Offset or 1
    local SkillInfo = self.SkillMap[Index]
    local SeriesList = SkillInfo and SkillInfo.SeriesList or nil
    if SeriesList and #SeriesList > 1 then
        if SkillID ~= SkillInfo.SkillID and SkillID > 0 then
            print("[SkillLogicData] GetPlayerSeriesNext SkillID not equal")
        end
        local Length = #SeriesList
        local SeriesIndex = SkillInfo.SeriesIndex + Offset
        while SeriesIndex > Length do
            SeriesIndex = SeriesIndex - Length
        end
        local NextSkillID = SeriesList[SeriesIndex]
        return NextSkillID, SeriesIndex
    end
    return SkillID
end

function SkillLogicData:GetPlayerSeriesList(Index)
    local SkillInfo = self.SkillMap[Index]
    if SkillInfo then
        return SkillInfo.SeriesList or {}
    end
    return {}
end

--播放技能解锁动效
function SkillLogicData:PlaySkillUnLockEffect(SkillID)
    if self.ProFunction == ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION or self.ProFunction == ProtoCommon.function_type.FUNCTION_TYPE_GATHER then
       return
    end
    _G.EventMgr:SendEvent(EventID.PlaySkillUnLockEffect, SkillID)
end

--DEBUG
--输出按钮状态信息
function SkillLogicData:PrintButtonState()
    local PrintString = table_to_string(SkillBtnState) .. "\n"

    for key, value in pairs(self.SkillMap) do
        local SkillID = value.SkillID or 0

        if value.States and SkillID > 0 then
            PrintString = string.format("%s[%d:%d]:%s\n", PrintString, key, SkillID, table_to_string(value.States))
        end
    end
    return PrintString
end

-- 主角的EntityID更新
function SkillLogicData:OnEntityIDUpdate(MajorEntityID)
    self.EntityID = MajorEntityID
end


return SkillLogicData