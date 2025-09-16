
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require ("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local PassiveSkillVM = require("Game/Skill/View/PassiveSkillVM")
local SkillDetailsVM = require("Game/Skill/View/SkillDetailsVM")
local UIBindableList = require("UI/UIBindableList")
local SkillUtil = require("Utils/SkillUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local SkillSystemConfig = require("Game/Skill/SkillSystem/SkillSystemConfig")
local SkillLearnedCfg = require("TableCfg/SkillLearnedCfg")
local SkillSystemAdvancedSkillListCfg = require("TableCfg/SkillSystemAdvancedSkillListCfg")
local SkillSystemBlacklistCfg = require("TableCfg/SkillSystemBlacklistCfg")
local SkillSystemReplaceCfg = require("TableCfg/SkillSystemReplaceCfg")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")

local EventID = require("Define/EventID")
local CommonDefine = require("Define/CommonDefine")
local EventMgr = _G.EventMgr
local LightMgr = _G.LightMgr
local SummonMgr = _G.SummonMgr
local SkillSystemMgr = _G.SkillSystemMgr
local SkillCustomMgr = _G.SkillCustomMgr
local SkillSystemSummonScale = 3  -- 小号
local USkillSystemUtil = _G.UE.USkillSystemUtil
local FLOG_ERROR = _G.FLOG_ERROR
local WeatherSystemID = require("Game/Weather/WeatherDefine").SystemID.SkillSystem

local CommonUtil = require("Utils/CommonUtil")

local Skill_Tag = ProtoRes.skill_tag
local SkillSystemConfigPath = SkillSystemConfig.SkillSystemConfigPath
local SkillSystemRenderActor = SkillUtil.SkillSystemRenderActor
local WorldOffset = UE.FVector(0, 0, 50000)
local DelayTime = 0

local WaitTime = 2
local MaxWaitLoadCount = 5

local DefaultSmoothTime = 0
local SkillStartSmoothTime = 0.5
local SkillSystemVolumeScaleMap = {}
local UAudioMgr
local CameraMgr = _G.UE.UCameraMgr.Get()

local AvatarType_Hair = _G.UE.EAvatarPartType.NAKED_BODY_HAIR
local HairRenderPriority = -1

local ActorNum <const> = 2
local FadeInTime <const> = 1
local HideReason <const> = _G.UE.EHideReason.SkillSystem



---@class SkillSystemVM : UIViewModel
local SkillSystemVM = LuaClass(UIViewModel)


--获取当前设备LOD标准
local function GetDeviceFXLODStandard()
    return 0
end

local function RenderActorSetHidden(RenderActor, bHidden)
    if RenderActor then
        RenderActor:SetActorHiddenInGame(bHidden)
        local SkyLightCompList = RenderActor:K2_GetComponentsByClass(_G.UE.USkyLightComponent)
        local CompLength = SkyLightCompList:Length()
        for i = 1, CompLength do
            local Comp = SkyLightCompList:Get(i)
            Comp:SetVisibility(bHidden, false)
        end
    end
end


function SkillSystemVM:Ctor(ParentSlot, ParentView)
    self.bShowDetail = false
    self.bShowSkillDetail = false
    self.CurrentLabel = 0
    self.bInitiatTabVisible = false
    self.bPassiveTabVisible = false
    self.bLimitSkillVisible = false


    self.SkillDetailData = {}

    -- # TODO - SkillSystemVM只应该处理表现相关，所有逻辑应该迁移到SkillSystemMgr里面
    local SkillSystemMgr = _G.SkillSystemMgr
    self.CasterResID = SkillSystemMgr.CasterResID
    self.TargetResID = SkillSystemMgr.TargetResID
    self.CasterEntityID = 0
    self.TargetEntityID = 0
    self.PassiveSkillList = UIBindableList.New(PassiveSkillVM)
    self.SkillDetailsList = UIBindableList.New(SkillDetailsVM)
    self.bLoadDA = false
    self.bLoadRenderActor = false
    self.RenderActor = nil
    self.ProfID = 0
    self.ProfFlags = nil
    self.bProductionProf = nil  --是否为采集职业(控制木桩显隐)
    self.bMakeProf = nil        --是否为生产职业(不显示主动技能) (控制木桩显隐)
    --{Prof = {PVE = {skilllist}, PVP = {skilllist}}}
    self.CacheSkillData = {}

    --camera view
    self.ViewTarget1 = nil
    self.ViewTarget2 = nil
    self.CurrentViewTargetIndex = 1

    --VM handle parentslot
    self.SubView = nil
    self.ParentSlot = ParentSlot

    self.DelayToHideEntity = 0

    self.WaitLoadTimer = 0

    self.bShowSpectrum = false
    self.bSpectrumSelected = false
    self.JobSkillDetailData = nil
    self.SpectrumDetailWidget = nil

    self.SubEntityIDList = {}

    self.TabLabelList = {}

    self.IndependentView = false
    self.bShowCloseButton = false
    self.bShowMapTypeTabs = false
    self.bShowCustomSkill = false
    self.bInCustomSkillState = false
    self.CustomBtnText = ""

    rawset(self, "bPanelMoreExpanded", false)
    rawset(self, "ParentView", ParentView)

    -- 计数器, actor每组装好一个+1, == 2的时候将所有actor fade in 
    self.ActorFadeInCnt = 0
end

function SkillSystemVM:OnInit()
    print("[SkillSystemVM] OnInit")
    -- local function Callback()
    --     local SkillSystemDA = ObjectMgr:GetObject(SkillSystemConfigPath)
    --     if SkillSystemDA then
    --         self.SkillSystemDA = SkillSystemDA
    --         self.bLoadDA = true
    --         SkillStartSmoothTime = SkillSystemDA.SkillStartSmoothTime
    --     end
    --     local RenderActorClass = ObjectMgr:GetClass(SkillSystemRenderActor)
    --     if RenderActorClass then
    --         self.RenderActorClass = RenderActorClass
    --         self.bLoadRenderActor = true
    --     end
    -- end
    -- local PathArray = UE.TArray("")
    -- PathArray:Add(SkillSystemConfigPath)
    -- PathArray:Add(SkillSystemRenderActor)
    self.RenderActorClass = ObjectMgr:LoadClassSync(SkillSystemRenderActor)
    self.RenderActorClassRef = UnLua.Ref(self.RenderActorClass)
    self.bLoadRenderActor = true
    self.SkillSystemDA = ObjectMgr:LoadObjectSync(SkillSystemConfigPath)
    self.SkillSystemDARef = UnLua.Ref(self.SkillSystemDA)
    self.bLoadDA = true
    SkillStartSmoothTime = self.SkillSystemDA.SkillStartSmoothTime
    SkillSystemVolumeScaleMap = self.SkillSystemDA.SkillSystemVolumeScaleMap:ToTable() or {}
    UAudioMgr = _G.UE.UAudioMgr.Get()
    self.LevelSequenceActor = _G.CommonUtil.SpawnActor(UE.ALevelSequenceActor.StaticClass())
    self.WorldCompositionOffset = WorldOffset + UE.UWorldMgr.Get():GetOriginLocation()

    self.MaxWaitLoadCount = MaxWaitLoadCount
    self.bShowSkillDetail = false
end

local function ReduceBusVolume()
    for Channel, Scale in pairs(SkillSystemVolumeScaleMap) do
        UAudioMgr:SetAudioVolumeScale(Channel, Scale)
    end
end

local function RestoreBusVolume()
    for Channel, _ in pairs(SkillSystemVolumeScaleMap) do
        UAudioMgr:SetAudioVolumeScale(Channel, 1)
    end
end

function SkillSystemVM:UpdateProfFlags(ProfID)
    self.ProfID = ProfID
    local ProfFlags = {
        ProfID = ProfID,
        bCombatProf = ProfUtil.IsCombatProf(ProfID),
        bProductionProf = ProfUtil.IsGpProf(ProfID),
        bMakeProf = ProfUtil.IsCrafterProf(ProfID),
        bFisherProf = ProfID == ProtoCommon.prof_type.PROF_TYPE_FISHER
    }
    self.ProfFlags = ProfFlags
    self.bProductionProf = ProfFlags.bProductionProf    -- 大地使者
    self.bMakeProf = ProfFlags.bMakeProf                -- 能工巧匠
    self.bFisherProf = ProfFlags.bFisherProf            -- 捕鱼人
end

function SkillSystemVM:OnBegin(RoleData)
    self.SubEntityIDList = {}
    if self.MaxWaitLoadCount < 0 then
        FLOG_WARNING("[SkillSystem]Time out")
        return
    end

    local ProfID = RoleData[1] or 0
    local RaceID = RoleData[2] or 0

    self.MaxWaitLoadCount = self.MaxWaitLoadCount - 1
    if self.bLoadDA == false or self.bLoadRenderActor == false then
        print("load skillsystem DA and renderactor, wait...")
        self.WaitLoadTimer = TimerMgr:AddTimer(self, self.OnBegin, WaitTime, 1, 1, RoleData)
        self.JobSkillDetailData = {SkillSystemVM = self}
        return
    end
    self.bPVE = _G.SkillSystemMgr:IsCurrentMapPVE()
    self.WaitLoadTimer = 0
    self.ActorFadeInCnt = 0
    self.RaceID = RaceID
    self.bShowMapTypeTabs = DemoMajorType ~= 1 and SkillSystemMgr.bPVPOpen
    self.bInCustomSkillState = false
    self:UpdateProfFlags(ProfID)
    self:UpdateTabLabel()
    rawset(self, "bPanelMoreExpanded", false)

    self:UpdateSpectrumView(ProfID, RaceID)

    local ProfSkillData = self:GetProfConfigData(ProfID, RaceID)
    local Caster = {Location = ProfSkillData.Location + self.WorldCompositionOffset, Rotation = ProfSkillData.Rotation}
    local Target = {Location = self.SkillSystemDA.Location + self.WorldCompositionOffset, Rotation = self.SkillSystemDA.Rotation}

    if self.DelayToHideEntity > 0 then
		TimerMgr:CancelTimer(self.DelayToHideEntity)
		self.DelayToHideEntity = 0
        local CasterActor = ActorUtil.GetActorByEntityID(self.CasterEntityID)
        local TargetActor = ActorUtil.GetActorByEntityID(self.TargetEntityID)
        if CasterActor == nil or TargetActor == nil then
            FLOG_WARNING("[SkillSystem] not found exist actor when begin")
            return
        end
        CasterActor:SetActorHiddenInGame(false)
        TargetActor:SetActorHiddenInGame(self.bProductionProf or self.bMakeProf)
        self:SyncTransform(self.CasterEntityID, ProfSkillData.Location + WorldOffset, Caster.Location, Caster.Rotation)
		self:OnPlayerCreateSuccess(self.CasterEntityID)
		self:OnMonsterCreateSuccess(self.TargetEntityID)
	elseif self.DelayToHideEntity == 0 then
		self:SendPerformSkillNetMsg(ProtoCS.skill_perform_status.SKILL_PERFORM_STATUS_ON, Caster, Target)
	end

    local ZeroVec = UE.FVector(0, 0, 0)
    local ZeroRot = UE.FRotator(0, 0, 0)
    self.ViewTarget1 = CameraMgr:CreateViewTarget(nil, ZeroVec, ZeroRot)
    self.ViewTarget2 = CameraMgr:CreateViewTarget(nil, ZeroVec, ZeroRot)

    self.ViewTarget1.Tags:AddUnique(CommonDefine.UIActorTag)
    self.ViewTarget2.Tags:AddUnique(CommonDefine.UIActorTag)

    self:ResetProfCamera(ProfID, RaceID)
    if self.bLoadRenderActor == true and self.RenderActorClass then
        if self.RenderActor == nil then
            self.RenderActor = CommonUtil.SpawnActor(self.RenderActorClass, WorldOffset)
        else
            RenderActorSetHidden(self.RenderActor, false)
            --self.RenderActor:SetActorHiddenInGame(false)
            USkillSystemUtil.ActivateSkillSystemParticles(self.RenderActor)
        end
    end

    -- 加载tod方案
    LightMgr:EnableUIWeather(WeatherSystemID)

    self.OriginSummonScale = SummonMgr.SummonScale
    SummonMgr:SetSummonScale(SkillSystemSummonScale)
end

function SkillSystemVM:OnEnd()
    _G.UIAsyncTaskMgr:UnRegisterTask(rawget(self, "SkillSystemCastSkillTaskID"))
    self:ClearAllSkillSystemEffectWithoutFade(true)
    self:ClearSkillSelectedStatus()

    local SpectrumDetailWidget = self.SpectrumDetailWidget
    if SpectrumDetailWidget then
        WidgetPoolMgr:RecycleWidget(SpectrumDetailWidget)
    end

    TimerMgr:CancelTimer(self.RandomPlayEmotionTimer or 0)

    local UActorManager = _G.UE.UActorManager.Get()
    local CasterEntityID = self.CasterEntityID
    if CasterEntityID then
        UActorManager:RemoveClientActor(CasterEntityID)
    end
    if self.TargetEntityID then
        -- Actor的销毁有几帧的延迟，技能系统进出过快会导致未销毁的Actor顶起来新的Actor, 这里清一下碰撞
        local Actor = ActorUtil.GetActorByEntityID(self.TargetEntityID)
        if Actor then
            Actor:SwitchCollision(false)
            Actor:SetActorVisibility(false, HideReason)
        end
        UActorManager:RemoveClientActor(self.TargetEntityID)
    end

	self:ResumeCameras()
    CommonUtil.DestroyActor(self.ViewTarget1)
    CommonUtil.DestroyActor(self.ViewTarget2)
    -- local CameraMgr = _G.UE.UCameraMgr.Get()
    -- if CameraMgr then
    --     CameraMgr:ResumeCamera(0)
    -- end

    self.bShowSpectrum = false
    self.JobSkillDetailData = nil
    -- self.DelayToHideEntity = TimerMgr:AddTimer(self, self.HideEntityImmediately, DelayTime, 1, 1)
    self:HideEntityImmediately()
    SkillUtil.TargetEntityID = 0

    local SubView = self.SubView
    if SubView then
        -- 防止Chant动画残留
        local Chant = SubView.Chant
        Chant:StopAllAnimations()

        -- 防止多选一残留
        self:HideMultiChoicePanel()

        UIUtil.SetIsVisible(SubView, false)
        SubView.bSubViewReady = false
    end
    -- 等Destroy的时候再回收
    -- _G.UIViewMgr:RecycleView(SubView)
    -- self.SubView = nil
    _G.SkillLogicMgr:RemoveSkillLogicData(CasterEntityID)

    self.ProfID = 0
    self.ProfFlags = nil
    self.CurrentLabel = 0
    rawset(self, "TargetLocation", nil)

    if CommonUtil.IsObjectValid(self.RenderActor) then
        RenderActorSetHidden(self.RenderActor, true)
    end

    self.MaxWaitLoadCount = MaxWaitLoadCount
    if self.WaitLoadTimer > 0 then
        TimerMgr:CancelTimer(self.WaitLoadTimer)
        self.WaitLoadTimer = 0
    end

    self:SetDetailVisible(false)

    RestoreBusVolume()

    self.SkillDetailsList = nil
    self.CasterEntityID = nil
    self.TargetEntityID = nil
    -- 同一VM复用SequenceActor, 这也意味着SkillSystemVM不可跨关卡复用
    -- self.LevelSequenceActor = nil

    if self.OriginSummonScale then
        SummonMgr:SetSummonScale(self.OriginSummonScale)
        self.OriginSummonScale = nil
    end

    LightMgr:DisableUIWeather()
end

function SkillSystemVM:OnShutdown()
    print("[SkillSystemVM] OnShutdown")
    CommonUtil.DestroyActor(self.LevelSequenceActor)
    if self.DelayToHideEntity > 0 then
        TimerMgr:CancelTimer(self.DelayToHideEntity)
        self:HideEntityImmediately()
    end
    if CommonUtil.IsObjectValid(self.RenderActor) then
        CommonUtil.DestroyActor(self.RenderActor)
        self.RenderActor = nil
    end
    self.RenderActorClassRef = nil
    self.SkillSystemDARef = nil
end

function SkillSystemVM:OnActive()
    local CasterActor = ActorUtil.GetActorByEntityID(self.CasterEntityID)
    local TargetActor = ActorUtil.GetActorByEntityID(self.TargetEntityID)
    if CasterActor == nil or TargetActor == nil then
        return
    end
    CasterActor:SetActorHiddenInGame(false)
    TargetActor:SetActorHiddenInGame(self.bProductionProf or self.bMakeProf)

    -- local ViewTarget = self[string.format("ViewTarget%d", self.CurrentViewTargetIndex + 1)]
    CameraMgr:GetCameraController():FOV(0)
    -- CameraMgr:SwitchCamera(ViewTarget, 0)

    if self.RenderActor == nil then
        self.RenderActor = CommonUtil.SpawnActor(self.RenderActorClass, WorldOffset)
    else
        RenderActorSetHidden(self.RenderActor, false)
        USkillSystemUtil.ActivateSkillSystemParticles(self.RenderActor)
    end
end

function SkillSystemVM:OnInactive()
    _G.UIAsyncTaskMgr:UnRegisterTask(rawget(self, "SkillSystemCastSkillTaskID"))
    self:ClearAllSkillSystemEffectWithoutFade(true)
    local Caster = ActorUtil.GetActorByEntityID(self.CasterEntityID)
    local Target = ActorUtil.GetActorByEntityID(self.TargetEntityID)
    if Caster then
        Caster:SetActorHiddenInGame(true)
    end

    if Target then
        Target:SetActorHiddenInGame(true)
    end
    if self.RenderActor then
        RenderActorSetHidden(self.RenderActor, true)
    end

    self:HideMultiChoicePanel()
end

local IdleHoldType <const> = _G.UE.EHoldWeaponType.HOLD

function SkillSystemVM:ClearAllSkillSystemEffectWithoutFade(bRemoveAllBuff)
    local Caster = ActorUtil.GetActorByEntityID(self.CasterEntityID)
    local Target = ActorUtil.GetActorByEntityID(self.TargetEntityID)

    if self.LevelSequenceActor and self.LevelSequenceActor.SequencePlayer then
        self.LevelSequenceActor.SequencePlayer:Stop()
    end

    if Caster then
        _G.SkillSingEffectMgr:PlayerSingBreak(self.CasterEntityID, false)
        if ActorUtil.GetActorStateComponent(self.CasterEntityID):IsInState(UE.EActorState.Attack) then
            ActorUtil.GetActorCombatComponent(self.CasterEntityID):BreakSkill()
        end
        local BuffComp = ActorUtil.GetActorBuffComponent(self.CasterEntityID)
        if BuffComp and bRemoveAllBuff then
            BuffComp:RemoveAllBuff(true)
        end
        local AvatarComp = Caster.AvatarCom
        if AvatarComp then
            AvatarComp:SetMasterHandWeaponState(IdleHoldType)
        end
    end

    if Target then
        local BuffComp = ActorUtil.GetActorBuffComponent(self.TargetEntityID)
        if BuffComp and bRemoveAllBuff then
            BuffComp:RemoveAllBuff(true)
        end
    end

    if #self.SubEntityIDList > 0 then
        for _, EntityID in ipairs(self.SubEntityIDList) do
            local CombatComp = ActorUtil.GetActorCombatComponent(EntityID)
            if CombatComp then
                CombatComp:BreakSkill()
            end
            -- body
        end
        self.SubEntityIDList = {}
    end
end

--这里缓存一个职业一个种族的数据
local ProfSkillDataSingleCache = {}
function SkillSystemVM:GetProfConfigData(ProfID, RaceID)
    if self.SkillSystemDA == nil then
        FLOG_ERROR("[SkillSystem]SkillSystemDA not Exist")
        return
    end

    local Hash = RaceID * 10000 + ProfID
    local CacheProfSkillData = ProfSkillDataSingleCache[Hash]
    if ProfSkillDataSingleCache[Hash] ~= nil then
        return CacheProfSkillData
    end

    local ProfSkillDataAdvance = self.SkillSystemDA:GetProfSkillData(ProfID, RaceID)
    ProfSkillDataSingleCache = {[Hash] = ProfSkillDataAdvance}
    return ProfSkillDataAdvance
end

-- function SkillSystemVM:OnSelectedProfChange(ProfID)
--     if self.ProfID == ProfID then
--         FLOG_WARNING("[SkillSystemVM]are you ok?")
--         return
--     end
--     self:UpdateProfFlags(ProfID)
--     self:ClearAllSkillSystemEffectWithoutFade(true)
--     self:SyncTransformByProf(self.CasterEntityID, ProfID, self.RaceID)
--     self:ResetProfCamera(ProfID, self.RaceID)
--     self:UpdateModel(self.CasterEntityID)
--     self:UpdateSkillLogicData(self.CasterEntityID)
--     self:PlayerCreateDoWork(self.CasterEntityID)
--     self.ParentSlot:ClearChildren()
--     local MapType = SkillSystemMgr:GetCurrentMapType()
--     -- 仅战斗职业显示轮盘, 制造职业不显示技能轮盘
--     if not self.bMakeProf and not self.bProductionProf then
--         self.SubView = _G.SkillLogicMgr:CreateSkillMainPanel(
--             self.CasterEntityID, false, MapType, self.ParentSlot, rawget(self, "ParentView"), rawget(self, "SkillPanelOffset"))
--     end

--     -- 页签
--     self:UpdateTabLabel()

--     --转职后隐藏Detail面板
--     self:SetDetailVisible(false)
--     rawset(self, "bPanelMoreExpanded", false)

--     --更新量谱表现
--     self:UpdateSpectrumView(ProfID, self.RaceID)

--     --生产职业不显示目标
--     local TargetActor = ActorUtil.GetActorByEntityID(self.TargetEntityID)
--     if TargetActor then
--         TargetActor:SetActorHiddenInGame(self.bProductionProf or self.bMakeProf)
--     end
-- end

function SkillSystemVM:HideEntityImmediately()
	self:SendPerformSkillNetMsg(ProtoCS.skill_perform_status.SKILL_PERFORM_STATUS_OFF)
	self.DelayToHideEntity = 0
    self.CasterEntityID = 0
    self.TargetEntityID = 0
end

function SkillSystemVM:OnGameEventVisionEnter(Params)
    local ResID = Params.IntParam2
    local EntityID = Params.ULongParam1
    if self.CasterResID == ResID then
        self:OnPlayerCreateSuccess(EntityID)
    elseif self.TargetResID == ResID then
        self:OnMonsterCreateSuccess(EntityID)
    else
        self:OnSubActorEnter(Params.ULongParam1)
        return
    end
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        Actor:MarkUIActor()
        Actor:SetActorVisibility(false, HideReason)
    end
end

function SkillSystemVM:OnSubActorEnter(EntityID)
    local AttrComp = ActorUtil.GetActorAttributeComponent(EntityID)
    if AttrComp and AttrComp.Owner > 0 and AttrComp.Owner == self.CasterEntityID then
        print("[SkillSystem]Add Owner Entity")
        table.insert(self.SubEntityIDList, EntityID)
    end
end

function SkillSystemVM:ResetTargetLocation()
    local Target = ActorUtil.GetActorByEntityID(self.TargetEntityID)
    if Target then
        local TargetLocation = rawget(self, "TargetLocation")
        if not TargetLocation then
            rawset(self, "TargetLocation", Target:K2_GetActorLocation())
            return
        end
        Target:K2_SetActorLocation(TargetLocation, false, nil, false)
    end
end

local AddUITagToCurrentViewTarget <const> = _G.UE.USkillSystemUtil.AddUITagToCurrentViewTarget

function SkillSystemVM:OnGameEventSkillStart(Params)
    if Params.ULongParam1 ~= self.CasterEntityID then
        return
    end
    if self.bLoadDA == false then
        FLOG_WARNING("[SkillSystem]SkillSystemDA not load")
        return
    end
    local SkillID = Params.IntParam2

    local ProfSkillData = self:GetProfConfigData(self.ProfID, self.RaceID)
    if not ProfSkillData then
        FLOG_ERROR("[SkillSystemVM] Cannot find config in DA, prof is %d, race is %d.", self.ProfID or -1, self.RaceID or -1)
        return
    end

    local SkillSequenceAsset = nil
    local SingleSkillData = ProfSkillData.SkillConfig:Find(SkillID)
    if SingleSkillData == nil then
        SingleSkillData = ProfSkillData
    else
        SkillSequenceAsset = SingleSkillData.Sequence:ToString()
    end

    self.CameraSequence = nil
    self:SetCameraConfig(SingleSkillData, SkillStartSmoothTime)
    self:ResetTargetLocation()
    self:SyncTransform(self.CasterEntityID, SingleSkillData.Location + WorldOffset, SingleSkillData.Location + self.WorldCompositionOffset, SingleSkillData.Rotation)


    if SkillSequenceAsset and SkillSequenceAsset ~= "" then
        local function Callback()
            local CameraSequence = _G.ObjectMgr:GetObject(SkillSequenceAsset)
            local LevelSequenceActor = self.LevelSequenceActor
            if CameraSequence and LevelSequenceActor then
                LevelSequenceActor.SequencePlayer:Stop()
                self.CameraSequence = CameraSequence
                USkillSystemUtil.SetAuxiliaryTrackActive(CameraSequence, false)
                LevelSequenceActor:SetSequence(CameraSequence)
                LevelSequenceActor:GetSequencePlayer():Play()
                AddUITagToCurrentViewTarget()
            end
        end

        _G.ObjectMgr:LoadObjectAsync(SkillSequenceAsset, Callback)
    end

    ReduceBusVolume()
end

local ZeroVector = _G.UE.FVector()

function SkillSystemVM:OnGameEventSkillEnd(Params)
    local EntityID = Params.ULongParam1
    if EntityID ~= self.CasterEntityID then
        return
    end
    --强制结束未被暂停的美术位移
    UE.UMoveSyncMgr.Get():StopArtPath(EntityID, 0, 0)
	--self:SyncTransformByProf(EntityID, self.ProfID)
    --技能结束时不重置相机，仅关闭sequence
	--self:ResetProfCamera(self.ProfID)
    if self.LevelSequenceActor and self.LevelSequenceActor.SequencePlayer then
        self.LevelSequenceActor.SequencePlayer:Stop()
        USkillSystemUtil.SetAuxiliaryTrackActive(self.CameraSequence, true)
    end
    self.CameraSequence = nil

    local Caster = ActorUtil.GetActorByEntityID(self.CasterEntityID)
    if Caster then
        Caster.CharacterMovement.Velocity = ZeroVector
    end
    RestoreBusVolume()
end

function SkillSystemVM:RemoveVisionLimit(EntityID)
    local TargetActor = ActorUtil.GetActorByEntityID(EntityID)
    if TargetActor then
        _G.UE.UVisionMgr.Get():RemoveFromVision(TargetActor)
    end
end

function SkillSystemVM:OnPlayerCreateSuccess(EntityID)
    self:RemoveVisionLimit(EntityID)
    UE.USkillSystemUtil.DisAllowAdjustFloor(EntityID)
    self:UpdateModel(EntityID)
    self:UpdateSkillLogicData(EntityID)
    if not self.bMakeProf and not self.bProductionProf then
        local MapType = SkillSystemMgr:GetCurrentMapType()
        SkillCustomMgr:ReqCustomIndexMap(false, function()
            if SkillSystemMgr.bIsActive then
                local View = rawget(self, "SubView")
                if View then
                    View:OnEntityIDUpdate(EntityID, false, MapType)
                    View:ViewSwitchFight()
                    UIUtil.SetIsVisible(View, true)
                else
                    View = _G.SkillLogicMgr:CreateSkillMainPanel(
                        EntityID,
                        false,
                        MapType,
                        self.ParentSlot,
                        rawget(self, "ParentView"),
                        rawget(self, "SkillPanelOffset")
                    )
                    rawset(self, "SubView", View)
                end
                View.bSubViewReady = true
                self:ForceUpdateCustomSkillState()
            end
        end)
    end
    self:PlayerCreateDoWork(EntityID)
end

function SkillSystemVM:ForceUpdateCustomSkillState(bState)
    if bState == nil then
        bState = self.bInCustomSkillState
    end
    self.bInCustomSkillState = nil
    self.bInCustomSkillState = bState
end

--能工巧匠每10s随机播放一个情感动作
local RandomEmotionList = {39, 33, 44}
local RandomEmotionInterval = 10
local function RandomPlayEmotion(EntityID)
    local Index = math.random(1, #RandomEmotionList)

    local Params = {}
    Params.ULongParam1 = EntityID
    Params.ULongParam2 = 0
    Params.IntParam1 = RandomEmotionList[Index]
    Params.BoolParam1 = false
    Params.BoolParam3 = false
    _G.EmotionMgr:OnPlayEmotion(Params)
end

function SkillSystemVM:PlayerCreateDoWork(EntityID)
    TimerMgr:CancelTimer(self.RandomPlayEmotionTimer or 0)
    if self.bProductionProf or self.bMakeProf then
        self.RandomPlayEmotionTimer = TimerMgr:AddTimer(nil, RandomPlayEmotion, 0, RandomEmotionInterval, 0, EntityID)
    end
end

-- 这里检查一个非常偶现的情况, 可能和视野包的顺序有关
-- 连续两次进入技能系统, 因为延迟原因两次Caster进入视野都挤到了这一次
function SkillSystemVM:CheckEntityUnique(EntityID, EntityIDKey, AssembleEndKey, FailedCallback)
    local LastEntityID = self[EntityIDKey]
    if LastEntityID and LastEntityID > 0 then
        FLOG_ERROR(
            "[SkillSystem] Got more than one %s enter vision, last: %d; now: %d.",
            EntityIDKey, LastEntityID, EntityID)

        if FailedCallback then
            FailedCallback(LastEntityID)
        end
        UE.UActorManager.Get():RemoveClientActor(LastEntityID)

        if SkillSystemMgr[AssembleEndKey] then
            SkillSystemMgr[AssembleEndKey] = false
            self.ActorFadeInCnt = self.ActorFadeInCnt - 1
        end
    end
end

function SkillSystemVM:OnMonsterCreateSuccess(EntityID)
    self:RemoveVisionLimit(EntityID)
    self:CheckEntityUnique(EntityID, "TargetEntityID", "bTargetAssembleEnd")

    self.TargetEntityID = EntityID
    SkillUtil.TargetEntityID = EntityID

    UE.USkillSystemUtil.DisAllowAdjustFloor(EntityID)
    local TargetActor = ActorUtil.GetActorByEntityID(EntityID)
    if TargetActor then
        TargetActor:LoadMesh()
    end
end

function SkillSystemVM:SetDetailVisible(bVisible, bSkillVisible, bSpectrumVisible, bBottomVisible)
    if bVisible ~= nil then
        self.bShowDetail = bVisible
    end

    if self.IndependentView then
        self.bShowCloseButton = not self.bShowDetail
    else
        -- self.bShowCloseButton = false
        if self.bInCustomSkillState then
            self.bShowCloseButton = not bVisible
        end
    end

    if bVisible == false then
        self.bShowSkillDetail = false
        self.bSpectrumSelected = false
        --self.bBottomSelected = false
    else
        self.bShowSkillDetail = bSkillVisible
        self.bSpectrumSelected = bSpectrumVisible
        --self.bBottomSelected = bBottomVisible
    end
end

function SkillSystemVM:SetSkillDetailVisibleAsync(bVisible, bSkillShowValid)
    self:SetDetailVisible(bVisible or nil, bSkillShowValid, false)
end

function SkillSystemVM:SetSkillDetailVisible(bVisible, SkillID, Index, bPassiveSkill, bLimitSkill, bShowMultiSkill)
    _G.UIAsyncTaskMgr:UnRegisterTask(rawget(self, "SkillSystemCastSkillTaskID"))
    local bSkillShowValid = true
    if not SkillID or SkillID == 0 then
        bSkillShowValid = false
    end
    local SelectIdList = SkillMainCfg:FindValue(SkillID, "SelectIdList")
    if SelectIdList and #SelectIdList > 0 then
        if SelectIdList[1].ID > 0 and not bShowMultiSkill then
            --多选一技能不显示详细面板
            bSkillShowValid = false
        end
    end
    local co = coroutine.create(self.SetSkillDetailVisibleAsync)
    
    local SkillSystemCastSkillTaskID = _G.UIAsyncTaskMgr:RegisterTask(co, self, bVisible or nil, bSkillShowValid)
    rawset(self, "SkillSystemCastSkillTaskID", SkillSystemCastSkillTaskID)

    if bSkillShowValid then
        local AppendImage = self.SkillSystemDA:GetAppendSkillImage(SkillID)
        local LastSkillDetailsList = self.SkillDetailsList
        if LastSkillDetailsList and #LastSkillDetailsList > 0 and LastSkillDetailsList[1].SkillID == SkillID then
            return
        end

        local AdvancedSkillListCfg = SkillSystemAdvancedSkillListCfg:FindCfgByKey(SkillID)
        local SkillList

        if bLimitSkill then
            SkillList = { SkillID, SkillID - 1, SkillID - 2 }
        elseif AdvancedSkillListCfg then
            SkillList = AdvancedSkillListCfg.SkillIDList
        else
            SkillList = { SkillID }
        end

        local SkillDetailsList = {}
        local CurrentLabel = self.CurrentLabel
        local EntityID = self.CasterEntityID
        local ProfFlags = self.ProfFlags
        local SkillNum = #SkillList

        rawset(self, "bPanelMoreExpanded", false)
        for IndexInSkillList, SkillIDInSkillList in ipairs(SkillList) do
            local Cfg = SkillMainCfg:FindCfgByKey(SkillIDInSkillList) or {}
            table.insert(SkillDetailsList, {
                SkillID = SkillIDInSkillList,
                Index = Index,
                bPassiveSkill = bPassiveSkill,
                bLimitSkill = bLimitSkill,
                CurrentLabel = CurrentLabel,
                EntityID = EntityID,
                AppendImage = AppendImage,
                ProfFlags = ProfFlags,
                Tag = Cfg.Tag,
                Class = Cfg.Class,
                ActionType = Cfg.ActionType,
                bPanelMoreVisible = SkillNum > 1 and IndexInSkillList == 1,
                bPanelMoreExpanded = false,
                AdapterOnGetIsVisible = function()
                    return self.bPanelMoreExpanded or IndexInSkillList == 1
                end,
            })
        end

        self.SkillDetailsList = SkillDetailsList
    end
end

function SkillSystemVM:PostSkillListChange(Prof, bPVE)
    --暂时用不上

    -- if self.Prof == Prof and self.bPVE == bPVE and self.LogicData == nil then
    --     return
    -- end
    -- self.Prof = Prof
    -- self.bPVE = bPVE
    -- local ProfData = self.CacheSkillData[Prof]
    -- if not ProfData then
    --     --load skilllist
    -- end
    -- if ProfData then
    --     local SkillList = ProfData[bPVE]
    --     self.LogicData:InitSkillList(SkillList)
    -- end
    --self.LogicData:InitSkillList()
end

function SkillSystemVM:SendPerformSkillNetMsg(Status, Caster, Target)
	if Status == ProtoCS.skill_perform_status.SKILL_PERFORM_STATUS_ON then
        self.PassiveSkillList:Clear(true)
	end
    _G.SkillSystemMgr:SendPerformSkillNetMsg(Status, Caster, Target)
end

function SkillSystemVM:UpdateModel(EntityID)
    local Destination = ActorUtil.GetActorByEntityID(EntityID)
    if Destination == nil then
        FLOG_ERROR("[SkillSystemVM:UpdateModel] Cannot find destination actor, EntityID is %d", EntityID or 0)
        return
    end
    --自行处理模型
    Destination.bNotInvokeLoadMesh = true
    _G.UE.USkillSystemUtil.CopyFromCharacter(MajorUtil.GetMajor(), Destination, self.ProfID)

    local AvatarComponent = Destination:GetAvatarComponent()
    if AvatarComponent then
        AvatarComponent:SetForcedLODForAll(1)
    end
end

local function ActorFadeIn(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        Actor:SetActorVisibility(true, HideReason)
        Actor:StartFadeIn(FadeInTime, false)
    end
end

function SkillSystemVM:OnAssembleAllEnd(Params)
    if self.ActorFadeInCnt >= ActorNum then
        return
    end

    local EntityID = Params.ULongParam1
	if EntityID == self.CasterEntityID then
        --FLOG_ERROR("Login OnAssembleAllEnd")
        local Major = MajorUtil.GetMajor()
        local Caster = ActorUtil.GetActorByEntityID(EntityID)
        if not Caster then
            return
        end
        Caster:SetWeaponAttachmentSocketByState()
        self:UpdateCombatStatus(EntityID)
		UE.USkillSystemUtil.CopyFromCharacterCallback(Major, Caster, self.ProfID)
        Caster.bVisionComponentTickEnabled = true
        _G.WorldMsgMgr:HideLoadingView()

        -- 适配需求, 头发渲染在特效后
        local AvatarComp = Caster:GetAvatarComponent()
        if AvatarComp then
            AvatarComp:SetPartTranslucencySortPriority(AvatarType_Hair, HairRenderPriority)
        end

        SkillSystemMgr.bCasterAssembleEnd = true
    elseif EntityID == self.TargetEntityID then
        -- 修改木桩碰撞预设为BlockAll, 防止穿模
        local Target = ActorUtil.GetActorByEntityID(EntityID)
        local CapsuleComp = Target and Target.CapsuleComponent
        if CapsuleComp then
            CapsuleComp:SetCollisionProfileName("BlockAll", true)
        end

        SkillSystemMgr.bTargetAssembleEnd = true
	end

    if EntityID == self.CasterEntityID or EntityID == self.TargetEntityID then
        self.ActorFadeInCnt = self.ActorFadeInCnt + 1
    end

    if self.ActorFadeInCnt >= ActorNum then
        ActorFadeIn(self.CasterEntityID)
        if not (self.bProductionProf or self.bMakeProf) then
            ActorFadeIn(self.TargetEntityID)
        end
    end
end

function SkillSystemVM:OnMonsterLoadAvatar(Params)
    local EntityID = Params.ULongParam1
	if EntityID == self.CasterEntityID then
        local Destination = ActorUtil.GetActorByEntityID(EntityID)
        --FLOG_ERROR("Login OnMonsterLoadAvatar")
        UE.USkillSystemUtil.CopyFromCharacter(MajorUtil.GetMajor(), Destination)
    end
end

-- 获取经去重筛选之后的表
local function GetSkillList(InSkillList)
    local SkillList = {}
    for _, value in ipairs(InSkillList) do
        local SkillID = value.ID
        if SkillID > 0 then
            table.insert(SkillList, SkillID)
        end
    end
    return SkillList
end

function SkillSystemVM:UpdateSkillLogicData(EntityID)
    local SkillLogicMgr = _G.SkillLogicMgr
    local SkillSystemMgr = _G.SkillSystemMgr

    self:CheckEntityUnique(EntityID, "CasterEntityID", "bCasterAssembleEnd", function(LastEntityID)
        SkillLogicMgr:RemoveSkillLogicData(LastEntityID)
    end)

    self.CasterEntityID = EntityID
    local LogicData = SkillLogicMgr:CreateSkillLogicData(EntityID, false)
    local MapType = SkillSystemMgr:GetCurrentMapType()
    if not MapType then
        FLOG_ERROR("[SkillSystem] Current map type is nil.")
        return
    end
    local ProfID = self.ProfID
    local Level = SkillUtil.GetGlobalConfigMaxLevel()
    local SkillGroupData = SkillUtil.GetBaseSkillListForInit(MapType, ProfID, Level)
    if not SkillGroupData then
        FLOG_ERROR("[SkillSystem] Cannot find SkillGroupData.")
        return
    end
    local SkillList = SkillGroupData.SkillList
    local RebuildRedData = {} --经过技能替换后本地红点数据需要修改，这里记录一下index和原始SkillID
    for _, SkillInfo in pairs(SkillList) do
        local ReplaceCfg = SkillSystemReplaceCfg:FindCfgByKey(SkillInfo.ID)
        if ReplaceCfg then
            RebuildRedData[SkillInfo.Index] = {SkillInfo = SkillInfo, OriginalSkillID = SkillInfo.ID}
            SkillInfo.ID = ReplaceCfg.ReplaceSkillID
        end
    end
    SkillSystemMgr:SetRebuildRedData(RebuildRedData)

    local PassiveList = SkillGroupData.PassiveList
    if self.bMakeProf or self.bProductionProf then
        PassiveList = GetSkillList(SkillGroupData.SkillList)
        --能工巧匠和大地使者主被动技能均用被动UI
        --TODO 大地使者后面会有变化
        rawset(self, "MakeProfInitiatSkillList", PassiveList)
        rawset(self, "MakeProfPassiveSkillList", SkillGroupData.PassiveList)

        -- 对应收藏品和捕鱼人的提竿组
        if self.bProductionProf then
            local ExtraSkillGroupData = SkillUtil.GetBaseSkillList(SkillUtil.MapType.PVP, ProfID, Level)
            rawset(self, "MakeProfExtraSkillList", GetSkillList(ExtraSkillGroupData.SkillList))
        end
    else
        LogicData:InitSkillList(SkillGroupData)
    end
    --Init Passsive Skill
    self:UpdatePassiveSkill(PassiveList)

    -- 技能系统红点
    local _ <close> = CommonUtil.MakeProfileTag("SkillSystem_RedDotTreeInit")
    SkillSystemMgr:RedDotTreeInit(EntityID)
end

local function SkillInfoComp(InfoA, InfoB)
    if InfoA.Level < InfoB.Level then
        return true
    end
    if InfoA.Level == InfoB.Level and InfoA.OriginID < InfoB.OriginID then
        return true
    end
    return false
end

function SkillSystemVM:UpdatePassiveSkill(Data)
    self.PassiveSkillList:Clear(false)
    if Data == nil then
        return
    end

    -- 按照学习等级作为第一关键字, 表内顺序作为第二关键字排序
    local SkillInfoList = {}
    local SkillExistedMap = {}  -- 去重
    local ProfID = ProfUtil.GetAdvancedProf(self.ProfID)
    for _, SkillID in ipairs(Data) do
        if SkillID == 0 or SkillSystemBlacklistCfg:FindCfgByKey(SkillID) or SkillExistedMap[SkillID] then
            goto continue
        end
        SkillExistedMap[SkillID] = true
        local Cfg = SkillLearnedCfg:FindCfgByParam(SkillID, ProfID)
        local OriginID = 0
        local Level = 0
        if Cfg then
            OriginID = Cfg.OriginID
            Level = Cfg.LearnedLevel
        end
        table.insert(SkillInfoList, {
            SkillID = SkillID,
            OriginID = OriginID,
            Level = Level,
        })
        ::continue::
    end
    table.sort(SkillInfoList, SkillInfoComp)
    for _, SkillInfo in ipairs(SkillInfoList) do
        if SkillInfo.SkillID ~= 0 then
            self.PassiveSkillList:AddByValue(SkillInfo.SkillID)
        end
    end
end

function SkillSystemVM:SyncTransform(EntityID, ClientPosition, ServerLocation, Rotation)
    --TODO[chaooren] 这里能不能客户端改变位置后告诉服务器，服务器不需要和客户端再同步
    --ActorUtil.GetActorByEntityID(EntityID):FSetActorLocation("SkillSystemVM:SyncTransform", Position)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        ClientPosition = ClientPosition + UE.FVector(0, 0, Actor:GetCapsuleHalfHeight())
        if Actor:K2_GetActorLocation() ~= ClientPosition or Actor:K2_GetActorRotation() ~= Rotation then
            Actor:K2_SetActorLocation(ClientPosition, false, nil, false)
            local AnimComp = Actor:GetAnimationComponent()
            if AnimComp then
                AnimComp:ForceSetRotation(Rotation, 0)
            end
            -- local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
            -- local MsgBody = {}
            -- local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_PERFORM_POS
            -- MsgBody.Cmd = SubMsgID
            -- local PerformMove = {EntityID = EntityID, Pos = SkillUtil.ConvertVector2Position(ServerLocation), Dir = Rotation.Yaw}
            -- MsgBody.PerformMove = PerformMove
            -- _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
        end
    end
end

function SkillSystemVM:SyncTransformByProf(EntityID, ProfID, RaceID)
    local ProfSkillData = self:GetProfConfigData(ProfID, RaceID)
    if ProfSkillData == nil then
        return
    end
    self:SyncTransform(EntityID, ProfSkillData.Location + WorldOffset, ProfSkillData.Location + self.WorldCompositionOffset, ProfSkillData.Rotation)
end

function SkillSystemVM:ResetProfCamera(ProfID, RaceID, SmoothTime)
    if self.LevelSequenceActor then
        self.LevelSequenceActor.SequencePlayer:Stop()
    end
    local ProfSkillData = self:GetProfConfigData(ProfID, RaceID)
    if ProfSkillData == nil then
        return
    end
    self:SetCameraConfig(ProfSkillData, SmoothTime)
end

function SkillSystemVM:GetCurrentViewTarget()
    local ViewTarget
    if self.CurrentViewTargetIndex == 1 then
        ViewTarget = self.ViewTarget1
    else
        ViewTarget = self.ViewTarget2
    end
    return ViewTarget
end

function SkillSystemVM:SetCameraConfig(ProfSkillData, SmoothTime)
    if ProfSkillData == nil then
        FLOG_ERROR("[SkillSystem]Prof Skill Data not Exist")
        return
    end
    local ViewTarget = self:GetCurrentViewTarget()
    if CameraMgr and ViewTarget then
        self.CurrentViewTargetIndex = 1 - self.CurrentViewTargetIndex
        CameraMgr:GetCameraController():FOV(0)
        ViewTarget:K2_SetActorLocation(ProfSkillData.CameraLocation + WorldOffset, false, nil, false)
        ViewTarget:K2_SetActorRotation(ProfSkillData.CameraRotation, false)
        ViewTarget.CameraComponent:SetFieldOfView(ProfSkillData.FOV)
        CameraMgr:SwitchCamera(ViewTarget, SmoothTime or DefaultSmoothTime)
    end
end

function SkillSystemVM:ResumeCameras()
	if CameraMgr then
		if nil ~= self.ViewTarget1 then
			CameraMgr:ResumeCamera(0, false, self.ViewTarget1)
		end
		if nil ~= self.ViewTarget2 then
			CameraMgr:ResumeCamera(0, false, self.ViewTarget2)
		end
	end
end

function SkillSystemVM:ClearSkillSelectedStatus()
    EventMgr:SendEvent(EventID.PlayerPrepareCastSkill, {EntityID = self.CasterEntityID, Index = -1, SkillID = self.BtnSkillID})
end

------------------Spectrum Show-----------------
function SkillSystemVM:UpdateSpectrumView(ProfID, RaceID)
    local ProfSkillData = self:GetProfConfigData(ProfID, RaceID)
    if ProfSkillData == nil then
        self.bShowSpectrum = false
        return
    end

    -- PVP使用统一的量谱
    local JobSkillIcon = ProfSkillData.JobSkillIcon
    local JobSkillDetail = ProfSkillData.JobSkillDetail
    if not self.bPVE then
        local DA = self.SkillSystemDA
        if not DA then
            return
        end
        -- JobSkillIcon = DA.JobSkillIcon_Pvp
        JobSkillIcon = nil
        JobSkillDetail = DA.JobSkillDetail_Pvp
    end

    self.JobSkillDetailData = {ProfID = ProfID, JobSkillIcon = JobSkillIcon, JobSkillDetail = JobSkillDetail, SkillSystemVM = self}

    -- 采集职业默认不显示
    if not self.bProductionProf then
        self.bShowSpectrum = true
    else
        self.bShowSpectrum = false
    end
end

function SkillSystemVM:SetSpectrumDetailWidget(Widget)
    if Widget == nil then
        FLOG_ERROR("[SkillMainPanelView:UpdateSpectrumDetail] Config Error")
        return
    end

    local SpectrumDetailWidget = self.SpectrumDetailWidget
    if SpectrumDetailWidget ~= Widget then
        if SpectrumDetailWidget then
            WidgetPoolMgr:RecycleWidget(SpectrumDetailWidget)
        end
        self.SpectrumDetailWidget = Widget
    end
end

function SkillSystemVM:OnSpectrumSelected(bSelected)
    self:SetDetailVisible(bSelected or nil, false, bSelected)
    if bSelected then
        self:ClearSkillSelectedStatus()

        -- 2024.8.19 - 需求变更 - 点量谱不中断技能, 中断逻辑已删除
        --选中量谱时中断技能，主要是为了中断吟唱效果
    end
end

function SkillSystemVM:UpdateCombatStatus(EntityID)
    local StateComponent = ActorUtil.GetActorStateComponent(EntityID)
    if StateComponent then
        StateComponent:SetNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT, not (self.bProductionProf or self.bMakeProf), false)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.ULongParam1 = EntityID
        EventParams.BoolParam1 = true
        _G.EventMgr:SendCppEvent(EventID.ChangeHoldWeaponState, EventParams)
        _G.EventMgr:SendEvent(EventID.ChangeHoldWeaponState, EventParams)
    end
end

local ELabelType = {
    Combat_PVE = 1,
    Combat_PVP = 2,
    Crafter = 3,
    Collection = 4,
    Fisher = 5,
}

local CrafterSkillListNameMap = {
    [ELabelType.Combat_PVE] = {
        "MakeProfInitiatSkillList",
        "MakeProfPassiveSkillList",
        "MakeProfExtraSkillList",
    },
    [ELabelType.Combat_PVP] = {
        "MakeProfInitiatSkillList",
        "MakeProfPassiveSkillList",
        "MakeProfExtraSkillList",
    },
    [ELabelType.Crafter] = {
        "MakeProfInitiatSkillList",
        "MakeProfPassiveSkillList",
        "MakeProfExtraSkillList",
    },
    [ELabelType.Collection] = {
        "MakeProfInitiatSkillList",
        "MakeProfPassiveSkillList",
        "MakeProfExtraSkillList",
    },
    [ELabelType.Fisher] = {
        "MakeProfInitiatSkillList",
        "MakeProfExtraSkillList",
        "MakeProfPassiveSkillList",
    },
}

local LSTR = _G.LSTR
local LocalStrID = SkillSystemConfig.LocalStrID

local LabelListMap = {
    [ELabelType.Combat_PVE] = { LocalStrID.Active, LocalStrID.Passive, LocalStrID.LimitSkill },
    [ELabelType.Combat_PVP] = {LocalStrID.Active, LocalStrID.Passive },
    [ELabelType.Crafter] = { LocalStrID.Active, LocalStrID.Passive },
    [ELabelType.Collection] = { LocalStrID.Normal, LocalStrID.Passive, LocalStrID.Collection },
    [ELabelType.Fisher] = { LocalStrID.FishDrop, LocalStrID.FishLift, LocalStrID.Passive },
}

function SkillSystemVM:GetLabelType()
    if self.bFisherProf then
        return ELabelType.Fisher
    elseif self.bProductionProf then
        return ELabelType.Collection
    elseif self.bMakeProf then
        return ELabelType.Crafter
    else
        if self.bPVE then
            return ELabelType.Combat_PVE
        else
            return ELabelType.Combat_PVP
        end
    end
end

function SkillSystemVM:SwitchSkillPage_MakeProf(Index)
    local LabelType = self:GetLabelType()
    local CrafterSkillListName = CrafterSkillListNameMap[LabelType][Index]
    if CrafterSkillListName then
        self:UpdatePassiveSkill(rawget(self, CrafterSkillListName))
    end

    self.CurrentLabel = LabelListMap[LabelType][Index]

    -- 收藏品量谱的处理
    if self.bProductionProf then
        if LabelListMap[ELabelType.Collection][Index] == LocalStrID.Collection then
            self.bShowSpectrum = true
        else
            self.bShowSpectrum = false
            -- self:OnSpectrumSelected(false)
        end
    end
end

-- 更新页签
function SkillSystemVM:UpdateTabLabel()
    local LabelType = self:GetLabelType()
    local LocalStrIDList = LabelListMap[LabelType]
    local TabLabelList = {}
    for _, LocalStrID in ipairs(LocalStrIDList) do
        table.insert(TabLabelList, LSTR(LocalStrID))
    end
    self.TabLabelList = TabLabelList
    self.CurrentLabel = LocalStrIDList[1]
end

function SkillSystemVM:HideMultiChoicePanel()
    local SubView = self.SubView
    if SubView then
        SubView.MultiChoiceDisplay:ViewHide()
    end

    _G.EventMgr:SendEvent(EventID.SkillSystemMultiChoiceFinish, _G.SkillSystemMgr.PressedButtonIndex)
end

function SkillSystemVM:IsCurrentLabelPassive()
    return self.CurrentLabel == LocalStrID.Passive
end

return SkillSystemVM