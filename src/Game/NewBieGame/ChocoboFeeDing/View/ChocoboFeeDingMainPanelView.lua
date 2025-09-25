---
--- Author: Administrator
--- DateTime: 2024-08-19 19:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ChocoboQteGameAtlCfg = require("TableCfg/ChocoboQteGameAtlCfg")
local ChocoboQteGameCfg = require("TableCfg/ChocoboQteGameCfg")
local EventID = require("Define/EventID")
local DataReportUtil = require("Utils/DataReportUtil")
local TimeUtil = require("Utils/TimeUtil")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ObjectGCType = require("Define/ObjectGCType")
local ActorUtil = require("Utils/ActorUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local AudioUtil = require("Utils/AudioUtil")

local EGAME_STATE = {
    NONE = 1,
    INIT = 2,
    READY = 3,
    BEGIN = 4,
    RESET = 5,
    OVER = 6,
}

local FVector2D = _G.UE.FVector2D
local TimerInterVal = 0.05

local GameID = 1
local BeginTime = 0
local StartPos = {}
local TargetPos = {}
local ScreenSize = {}
local WidgetSizeScaled = {}
local ControlPoint = {}
local BeginMove = false
local LastDistance = 0
local AnimationQueueCounter = 100000000
local ShopkeeperEntityID = -1
local NpcID = 40000060
local RemainingTime = 30
local RoundScale = 60
local ScalingSpeed = 10
local IconSize = 1
local MoveSpeed = 300
local PointHeight = 300

local FEE_DING_ATLID = {
    NULL = ProtoRes.CHOCOBO_QTE_GAME_ATL_TYPE.EXD_CHOCOBO_QTE_GAME_ATL_NULL,
    FAND_FOOD = ProtoRes.CHOCOBO_QTE_GAME_ATL_TYPE.EXD_CHOCOBO_QTE_GAME_ATL_FOOD,
    EXPECT = ProtoRes.CHOCOBO_QTE_GAME_ATL_TYPE.EXD_CHOCOBO_QTE_GAME_ATL_EXPECT,
    EXPECT_LOOP = ProtoRes.CHOCOBO_QTE_GAME_ATL_TYPE.EXD_CHOCOBO_QTE_GAME_ATL_EXPECT_LOOP,
    HAPPY = ProtoRes.CHOCOBO_QTE_GAME_ATL_TYPE.EXD_CHOCOBO_QTE_GAME_ATL_HAPPY,
    SAD = ProtoRes.CHOCOBO_QTE_GAME_ATL_TYPE.EXD_CHOCOBO_QTE_GAME_ATL_SAD,
    IDLE = ProtoRes.CHOCOBO_QTE_GAME_ATL_TYPE.EXD_CHOCOBO_QTE_GAME_ATL_IDLE,
}

local ReadyAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_prepare.Play_Mini_Gilgamesh_prepare'"
local BeginAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_start.Play_Mini_Gilgamesh_start'"
local SucAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_UI_ChocoboFeeding_success.Play_UI_ChocoboFeeding_success'"
local FailedAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_UI_ChocoboFeeding_fail.Play_UI_ChocoboFeeding_fail'"

---@class ChocoboFeeDingMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ChallengeBegins GoldSaucerCuffchallengeBeginsItemView
---@field EFF_Smell UFCanvasPanel
---@field EFF_Smell1 UFCanvasPanel
---@field FButton_102 UFButton
---@field FCanvasPanel_0 UFCanvasPanel
---@field FeeDingAperture ChocoboFeeDingApertureItemView
---@field FeeDingStatus ChocoboFeeDingStatusItemView
---@field FeeDingTips ChocoboFeeDingTipsItemView
---@field ImgVegetable UFImage
---@field ImgVegetableBG UFImage
---@field ImgVegetableLight UFImage
---@field ModelToImage CommonModelToImageView
---@field PanelMain UFCanvasPanel
---@field PanelSmellTarget UFCanvasPanel
---@field PanelTime UFHorizontalBox
---@field PanelVegetable UFCanvasPanel
---@field TextBirdName UFTextBlock
---@field TextHint UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---@field VegetableEndPos UFCanvasPanel
---@field VegetableStartPos UFCanvasPanel
---@field AnimEat UWidgetAnimation
---@field AnimFeedingReady UWidgetAnimation
---@field AnimHint UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimItemLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimVegetableDrop UWidgetAnimation
---@field AnimVegetableShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboFeeDingMainPanelView = LuaClass(UIView, true)

function ChocoboFeeDingMainPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ChallengeBegins = nil
	--self.EFF_Smell = nil
	--self.EFF_Smell1 = nil
	--self.FButton_102 = nil
	--self.FCanvasPanel_0 = nil
	--self.FeeDingAperture = nil
	--self.FeeDingStatus = nil
	--self.FeeDingTips = nil
	--self.ImgVegetable = nil
	--self.ImgVegetableBG = nil
	--self.ImgVegetableLight = nil
	--self.ModelToImage = nil
	--self.PanelMain = nil
	--self.PanelSmellTarget = nil
	--self.PanelTime = nil
	--self.PanelVegetable = nil
	--self.TextBirdName = nil
	--self.TextHint = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--self.VegetableEndPos = nil
	--self.VegetableStartPos = nil
	--self.AnimEat = nil
	--self.AnimFeedingReady = nil
	--self.AnimHint = nil
	--self.AnimIn = nil
	--self.AnimItemLoop = nil
	--self.AnimOut = nil
	--self.AnimVegetableDrop = nil
	--self.AnimVegetableShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboFeeDingMainPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ChallengeBegins)
	self:AddSubView(self.FeeDingAperture)
	self:AddSubView(self.FeeDingStatus)
	self:AddSubView(self.FeeDingTips)
	self:AddSubView(self.ModelToImage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboFeeDingMainPanelView:OnInit()
    self.GameState = EGAME_STATE.NONE
    self.FeedTimes = 0
    self.FallBackTimer = nil
end

function ChocoboFeeDingMainPanelView:OnDestroy()

end

function ChocoboFeeDingMainPanelView:OnShow()
    self:InitConstInfo()
    UIUtil.SetIsVisible(self.ModelToImage, false)
    UIUtil.SetIsVisible(self.EFF_Smell, false)

    GameID = 1
    if self.Params ~= nil and self.Params.GameID ~= nil then
        GameID = self.Params.GameID
    end

    self.GameState = EGAME_STATE.NONE
    self:InitChocobo()
end

function ChocoboFeeDingMainPanelView:InitConstInfo()
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 陆行鸟
    self.TextBirdName:SetText(_G.LSTR(440001))
    -- LSTR string: 投喂
    self.TextTitle:SetText(_G.LSTR(440002))
    -- LSTR string: 陆行鸟张嘴时投喂，有额外效果哦！
    self.TextHint:SetText(_G.LSTR(440003))
end

function ChocoboFeeDingMainPanelView:OnHide()
    -- 意外结束的情况
    if self.GameState < EGAME_STATE.OVER then
        _G.EventMgr:SendEvent(EventID.ChocoboFeedingQteRevert, { GameID = GameID, })
    end
    
    CommonUtil.DestroyActor(self.SceneActor)
    self.SceneActor = nil
    _G.UE.UActorManager.Get():RemoveClientActor(ShopkeeperEntityID)
    ShopkeeperEntityID = -1

    _G.LightMgr:DisableUIWeather()
end

function ChocoboFeeDingMainPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.FButton_102, self.OnBeginMoveClick)
end

---流水上报
---@param GameType number@1=结果、2=过程
---@param Result number@Type=1:1=成功、2=失败,Type=2:1=点击投喂
---@param Time number@Type=1:游戏耗时
---@param Times number@Type=1:游戏次数
local function ReportChocoboQTEFlow(GameType, Result, Time, Times)
    DataReportUtil.ReportData("ChocoboQTEFlow", true, false, true,
        "GameID", tostring(GameID),
        "GameType", tostring(GameType),
        "Result", tostring(Result),
        "Time", tostring(Time),
        "Times", tostring(Times))
end

function ChocoboFeeDingMainPanelView:OnBeginMoveClick()
    if self.GameState < EGAME_STATE.BEGIN or self.GameState >= EGAME_STATE.RESET then
        return
    end

    if BeginMove then
        return
    end

    LastDistance = 0
    BeginMove = true

    self.FeedTimes = self.FeedTimes + 1
    ReportChocoboQTEFlow(2, 1)
end

function ChocoboFeeDingMainPanelView:OnRegisterGameEvent()
end

function ChocoboFeeDingMainPanelView:OnRegisterBinder()

end

function ChocoboFeeDingMainPanelView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, TimerInterVal, 0)
end

function ChocoboFeeDingMainPanelView:ResetPanelVegetablePos()
    local Anchor = _G.UE.FAnchors()
    Anchor.Minimum = _G.UE.FVector2D(0.5, 0.5)
    Anchor.Maximum = _G.UE.FVector2D(0.5, 0.5)
    UIUtil.CanvasSlotSetAnchors(self.PanelVegetable, Anchor)

    local CanvasSize = UIUtil.GetWidgetSize(self.FCanvasPanel_0)
    local DefaultOffset = UIUtil.CanvasSlotGetOffsets(self.VegetableStartPos)
    UIUtil.CanvasSlotSetPosition(self.PanelVegetable, FVector2D(CanvasSize.X / 2 + DefaultOffset.Left, 0))
end

function ChocoboFeeDingMainPanelView:InitChocobo()
    UIUtil.SetIsVisible(self.PanelVegetable, true)
    UIUtil.SetIsVisible(self.ChallengeBegins, false)
    UIUtil.SetIsVisible(self.FeeDingTips, false)
    UIUtil.SetIsVisible(self.FeeDingStatus, false)

    local Cfg = ChocoboQteGameCfg:FindCfgByKey(GameID)
    if Cfg ~= nil then
        NpcID = Cfg.NpcID or NpcID
        RemainingTime = Cfg.Time or RemainingTime
        RoundScale = Cfg.RoundScale or RoundScale
        ScalingSpeed = Cfg.ScalingSpeed or ScalingSpeed
        IconSize = Cfg.IconSize or IconSize
        MoveSpeed = Cfg.MoveSpeed or MoveSpeed
        PointHeight = Cfg.PointHeight or PointHeight
    end

    self:ResetPanelVegetablePos()

    -- 菜大小
    local ImgVegetableSize = UIUtil.CanvasSlotGetSize(self.PanelVegetable)
    UIUtil.CanvasSlotSetSize(self.ImgVegetable, _G.UE.FVector2D(ImgVegetableSize.X * IconSize, ImgVegetableSize.Y * IconSize))
    UIUtil.CanvasSlotSetSize(self.ImgVegetableLight, _G.UE.FVector2D(ImgVegetableSize.X * IconSize, ImgVegetableSize.Y * IconSize))
    -- 内圈大小
    self.FeeDingAperture:SetScale(RoundScale / 100)

    local EndShowTime = LocalizationUtil.GetCountdownTimeForShortTime(RemainingTime, "mm:ss") or ""
    self.TextTime:SetText(EndShowTime)

    _G.LightMgr:EnableUIWeather(28)
    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)

    self.ModelToImage:SetAutoCreateDefaultScene(false)
    self:CreateScene()
    
    if self.FallBackTimer ~= nil then
        self:UnRegisterTimer(self.FallBackTimer)
    end
    self.FallBackTimer = self:RegisterTimer(self.GameInit, 5, 0.1, 0)
end

function ChocoboFeeDingMainPanelView:CreateScene()
    if nil ~= self.SceneActor then
        CommonUtil.DestroyActor(self.SceneActor)
        _G.FLOG_ERROR("[ChocoboFeeding] Scene already exists, skipping creation")
    end
    
    _G.FLOG_INFO("[ChocoboFeeding] Starting Sync load of scene assets: %s", ModelDefine.ChocoboStagePath.Universe)
    _G.ObjectMgr:LoadClassSync(ModelDefine.ChocoboStagePath.Universe, ObjectGCType.LRU)

    _G.FLOG_INFO("[ChocoboFeeding] Scene assets loaded successfully")
    local Class1 = _G.ObjectMgr:GetClass(ModelDefine.ChocoboStagePath.Universe)
    if Class1 == nil then
        _G.FLOG_ERROR("[ChocoboFeeding] Failed to get scene class: "..ModelDefine.ChocoboStagePath.Universe)
        return
    end

    -- 创建场景Actor
    self.SceneActor = CommonUtil.SpawnActor(Class1, ModelDefine.DefaultLocation, ModelDefine.DefaultRotation)

    -- 创建看板娘
    local Params = _G.UE.FCreateClientActorParams()
    Params.bUIActor = true

    ShopkeeperEntityID = _G.UE.UActorManager:Get():CreateClientActorByParams(_G.UE.EActorType.Npc, 0, NpcID,
            ModelDefine.DefaultLocation, ModelDefine.DefaultRotation, Params)
    local Shopkeeper = ActorUtil.GetActorByEntityID(ShopkeeperEntityID)
    if not Shopkeeper then
        _G.FLOG_ERROR("[ChocoboFeeding] Failed to get NPC instance")
        return
    end

    _G.UE.UVisionMgr.Get():RemoveFromVision(Shopkeeper)
    local AvatarComponent = Shopkeeper:GetAvatarComponent()
    if AvatarComponent ~= nil then
        AvatarComponent:SwitchForceMipStreaming(true)
        AvatarComponent:SetForcedLODForAll(1)
    end
    Shopkeeper:SetOverrideFadeInTime(0.0)

    local ChildActorComp = self.SceneActor:GetComponentByClass(_G.UE.UFMChildActorComponent)
    if nil ~= ChildActorComp then
        ChildActorComp.ChildActorReCreateDelegate = { self.SceneActor, function()
            local SceneCaptureComp = self.SceneActor:GetComponentByClass(_G.UE.USceneCaptureComponent2D)
            SceneCaptureComp:ShowOnlyActorComponents(Shopkeeper, true)
        end }
    end

    local CameraComp = self.SceneActor:GetComponentByClass(_G.UE.UCameraComponent)
    if nil ~= CameraComp then
        local CameraPosX = 0
        local CameraPosY = 0
        local CameraPosZ = 90
        local CfgValue = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_CHOCOBO_TRANSPORT_QTE_CAMERA_POS)
        if CfgValue ~= nil then
            CameraPosX = CfgValue.Value[1] or 0
            CameraPosY = CfgValue.Value[2] or 0
            CameraPosZ = CfgValue.Value[3] or 90
        end
        CameraComp:K2_SetRelativeLocation(_G.UE.FVector(CameraPosX, CameraPosY, CameraPosZ), false, nil, false)
    end

    local SpringArmComp = self.SceneActor:GetComponentByClass(_G.UE.USpringArmComponent)
    if SpringArmComp ~= nil then
        local CameraDistance = 700
        local CfgValue = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_CHOCOBO_TRANSPORT_QTE_CAMERA_DISTANCE)
        if CfgValue ~= nil then
            CameraDistance = CfgValue.Value[1] or 700
        end
        SpringArmComp.TargetArmLength = CameraDistance
    end

    self.ModelToImage:SetFOV(30)
    self.ModelToImage:Show(Shopkeeper, self.SceneActor:GetComponentByClass(_G.UE.UCameraComponent))
end

function ChocoboFeeDingMainPanelView:PlayActionTimelineMulti(ActionTimelineIDList)
    if ShopkeeperEntityID <= 0 then
        return
    end

    local Shopkeeper = ActorUtil.GetActorByEntityID(ShopkeeperEntityID)
    if Shopkeeper == nil then
        return
    end

    local AnimComp = Shopkeeper:GetAnimationComponent()
    if AnimComp == nil or not CommonUtil.IsObjectValid(AnimComp) then
        return
    end

    AnimationQueueCounter = AnimationQueueCounter + 1
    for i = 1, #ActionTimelineIDList do
        local Param = ActionTimelineIDList[i]
        local AtlID = Param.AtlID
        local bLoop = Param.bLoop
        local GameCfg = ChocoboQteGameAtlCfg:FindCfgByKey(AtlID)
        local PathCfg = ActiontimelinePathCfg:FindCfgByKey(GameCfg.ChocoboAtlID)
        local ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
        local Callback = Param.Callback
        if Callback ~= nil then
            AnimComp:QueueAnimationCallback(ActionTimelinePath, Callback, 1, 0.25 , 0.25, 
                    true, _G.UE.EAvatarPartType.MASTER, bLoop, AnimationQueueCounter, false)
        else
            AnimComp:QueueAnimation(ActionTimelinePath, 1, 0.25, 0.25, true,
                    _G.UE.EAvatarPartType.MASTER, bLoop, AnimationQueueCounter, false)
        end
    end
    AnimComp:PlayQueuedAnimations(AnimationQueueCounter)
end

function ChocoboFeeDingMainPanelView:OnAssembleAllEnd(Params)
    if nil == Params or Params.ULongParam1 ~= ShopkeeperEntityID then
        return
    end

    _G.FLOG_INFO("[ChocoboFeeding] OnAssembleAllEnd Successful")
    self:GameInit()
end

function ChocoboFeeDingMainPanelView:GameInit()
    if self.FallBackTimer ~= nil then
        self:UnRegisterTimer(self.FallBackTimer)
        self.FallBackTimer = nil
    end
    
    UIUtil.SetIsVisible(self.ModelToImage, true)
    self.GameState = EGAME_STATE.INIT
    local Params = {
        [1] = { AtlID = FEE_DING_ATLID.FAND_FOOD, bLoop = false, Callback = CommonUtil.GetDelegatePair(function(Params)
            AudioUtil.SyncLoadAndPlay2DSound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_vo_ChocoboFeeding_want.Play_vo_ChocoboFeeding_want'")
            end) },
        [2] = { AtlID = FEE_DING_ATLID.EXPECT, bLoop = false},
        [3] = { AtlID = FEE_DING_ATLID.IDLE, bLoop = true }
    }
    self:RegisterTimer(function()
        AudioUtil.SyncLoadAndPlay2DSound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_vo_ChocoboFeeding_found.Play_vo_ChocoboFeeding_found'")
    end, 2.66, 0, 1)
    self:PlayActionTimelineMulti(Params)
    self:PlayAnimation(self.AnimVegetableShow)

    local ReadyTime = 3
    local CfgValue = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_CHOCOBO_TRANSPORT_QTE_READY_TIME)
    if CfgValue ~= nil then
        ReadyTime = CfgValue.Value[1]
    end
    self.GameReadyTimerID = self:RegisterTimer(self.GameReady, ReadyTime, 0, 1)
end

function ChocoboFeeDingMainPanelView:GameReadyCallBack()
    self:PlayAnimation(self.AnimHint)
    AudioUtil.SyncLoadAndPlay2DSound(BeginAudioPath)
    self.ChallengeBegins:SetBegin(function()
        self.FeeDingAperture:GameBegin(ScalingSpeed / 100)
        BeginTime = TimeUtil.GetServerTime()
        self:GameBegin()
    end)
end

function ChocoboFeeDingMainPanelView:GameReady()
    if self.GameReadyTimerID ~= nil then
        self:UnRegisterTimer(self.GameReadyTimerID)
        self.GameReadyTimerID = nil
    end

    StartPos = UIUtil.GetWidgetAbsolutePosition(self.VegetableStartPos)
    TargetPos = UIUtil.GetWidgetAbsolutePosition(self.VegetableEndPos)
    ScreenSize = UIUtil.GetScreenSize()
    local WidgetSize = UIUtil.GetWidgetSize(self.PanelVegetable)
    WidgetSizeScaled = FVector2D(WidgetSize.X * IconSize, WidgetSize.Y * IconSize)
    ControlPoint = FVector2D((StartPos.X + TargetPos.X) / 2, StartPos.Y - PointHeight)

    self.GameState = EGAME_STATE.READY
    UIUtil.SetIsVisible(self.FeeDingAperture, true)
    self.FeeDingAperture:PlayAnimShow()
    self:PlayAnimation(self.AnimFeedingReady)
end

function ChocoboFeeDingMainPanelView:OnAnimationFinished(Animation)
    if self.AnimFeedingReady == Animation then
        UIUtil.SetIsVisible(self.ChallengeBegins, true)
        AudioUtil.SyncLoadAndPlay2DSound(ReadyAudioPath)
        self.ChallengeBegins:SetPrepare(function()
            self:GameReadyCallBack()
        end)
    elseif self.AnimVegetableShow == Animation then
        if self.GameState == EGAME_STATE.RESET then
            self:GameBegin()
        end
    end
end

function ChocoboFeeDingMainPanelView:GameBegin()
    self.GameState = EGAME_STATE.BEGIN
    local Params = { [1] = { AtlID = FEE_DING_ATLID.EXPECT_LOOP, bLoop = true } }
    self.LoopSound = AudioUtil.SyncLoadAndPlay2DSound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_vo_ChocoboFeeding_want_loop.Play_vo_ChocoboFeeding_want_loop'")
    self:PlayActionTimelineMulti(Params)
    UIUtil.SetIsVisible(self.TextHint, true)
    UIUtil.SetIsVisible(self.ImgVegetable, true)
end

function ChocoboFeeDingMainPanelView:PlayHappyEffect()
    local Params = { [1] = { AtlID = FEE_DING_ATLID.HAPPY, bLoop = false } }
    if self.LoopSound ~= nil then
        AudioUtil.StopSound(self.LoopSound)
        self.LoopSound = nil
    end
    AudioUtil.SyncLoadAndPlay2DSound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Stop_vo_ChocoboFeeding_want_loop.Stop_vo_ChocoboFeeding_want_loop'")
    AudioUtil.SyncLoadAndPlay2DSound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_vo_ChocoboFeeding_success.Play_vo_ChocoboFeeding_success'")
    self:PlayActionTimelineMulti(Params)

    self:PlayAnimation(self.AnimEat)
    self.FeeDingAperture:PlayAnimSuccessHide()
    UIUtil.SetIsVisible(self.FeeDingStatus, true)
    self.FeeDingStatus:PlayHappyEffect(self,function()
        _G.EventMgr:SendEvent(EventID.ChocoboFeedingQteFinishNotify, {
            GameID = GameID,
            GameResult = ChocoboDefine.CHOCOBO_FEE_QTE_RESULT.SUCCESS
        })
        UIUtil.SetIsVisible(self.FeeDingTips, true)
        self.FeeDingTips:PlayHappyEffect()
        AudioUtil.SyncLoadAndPlay2DSound(SucAudioPath)
        self:ExitGame()
    end)

    local CostTime = TimeUtil.GetServerTime() - BeginTime
    ReportChocoboQTEFlow(1, 1, CostTime, self.FeedTimes)
end

function ChocoboFeeDingMainPanelView:PlaySadEffect()
    local Params = { [1] = { AtlID = FEE_DING_ATLID.SAD, bLoop = false } }
    if self.LoopSound ~= nil then
        AudioUtil.StopSound(self.LoopSound)
        self.LoopSound = nil
    end
    AudioUtil.SyncLoadAndPlay2DSound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Stop_vo_ChocoboFeeding_want_loop.Stop_vo_ChocoboFeeding_want_loop'")
    AudioUtil.SyncLoadAndPlay2DSound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_vo_ChocoboFeeding_fail.Play_vo_ChocoboFeeding_fail'")
    self:PlayActionTimelineMulti(Params)

    UIUtil.SetIsVisible(self.PanelVegetable, false)
    UIUtil.SetIsVisible(self.FeeDingStatus, true)
    self.IsPlayingSadEffect = true
    self.FeeDingStatus:PlaySadEffect(self, self.PlaySadEffectCallBack)
end

function ChocoboFeeDingMainPanelView:PlaySadEffectCallBack()
    self.IsPlayingSadEffect = false
    local CanReset = self.GameState < EGAME_STATE.OVER

    if CanReset then
        local Anchor = _G.UE.FAnchors()
        Anchor.Minimum = _G.UE.FVector2D(0.5, 0.5)
        Anchor.Maximum = _G.UE.FVector2D(0.5, 0.5)
        UIUtil.CanvasSlotSetAnchors(self.PanelVegetable, Anchor)

        local CanvasSize = UIUtil.GetWidgetSize(self.FCanvasPanel_0)
        local DefaultOffset = UIUtil.CanvasSlotGetOffsets(self.VegetableStartPos)
        UIUtil.CanvasSlotSetPosition(self.PanelVegetable, FVector2D(CanvasSize.X / 2 + DefaultOffset.Left, 0))
        self:PlayAnimation(self.AnimVegetableShow)
    else
        _G.EventMgr:SendEvent(EventID.ChocoboFeedingQteFinishNotify, {
            GameID = GameID,
            GameResult = ChocoboDefine.CHOCOBO_FEE_QTE_RESULT.FAIL
        })
        UIUtil.SetIsVisible(self.FeeDingTips, true)
        self.FeeDingTips:PlaySadEffect()
        AudioUtil.SyncLoadAndPlay2DSound(FailedAudioPath)
        self.FeeDingAperture:PlayAnimHide()
        self:ExitGame()
        
        local CostTime = TimeUtil.GetServerTime() - BeginTime
        ReportChocoboQTEFlow(1, 2, CostTime, self.FeedTimes)
    end
end

function ChocoboFeeDingMainPanelView:CheckGameResult()
    if self.GameState >= EGAME_STATE.OVER then
        return
    end
    
    BeginMove = false
    self.GameState = EGAME_STATE.RESET
    
    local CurOuterScale = self.FeeDingAperture:GetCurOuterCircle()
    local CurInnerScale = self.FeeDingAperture:GetCurInnerCircle()

    CurOuterScale = math.floor(CurOuterScale * 100) / 100
    CurInnerScale = math.floor(CurInnerScale * 100) / 100
    _G.FLOG_INFO("ChocoboFeeDingMainPanelView.CheckGameResult CurOuterScale = " .. CurOuterScale .. "  CurInnerScale = " .. CurInnerScale)
    local IsSuc = true
    if IsSuc then
        self:GameOver(true)
    else
        self:PlaySadEffect()
    end
end

function ChocoboFeeDingMainPanelView:GameOver(IsSuc)
    BeginMove = false
    self.GameState = EGAME_STATE.OVER
    --self.FeeDingAperture:StopAnimScale()
    UIUtil.SetIsVisible(self.TextHint, false)
    
    if IsSuc then
        self:PlayHappyEffect()
    else
        if self.IsPlayingSadEffect == nil or self.IsPlayingSadEffect == false then
            self:PlayAnimation(self.AnimVegetableDrop)
            self:PlaySadEffect()
        end
    end
end

function ChocoboFeeDingMainPanelView:Hide()
    UIUtil.SetIsVisible(self.FeeDingAperture, false)
    _G.UIViewMgr:HideView(self.ViewID)
end

function ChocoboFeeDingMainPanelView:ExitGame()
    self:RegisterTimer(self.Hide, 0.8, 0, 1)
end

local function V2DQuadraticBezier(InStartPos, InTargetPos, Percent, InControlPoint)
    local OneMinusT = 1 - Percent
    local X = InStartPos.X * OneMinusT * OneMinusT + 2 * InControlPoint.X * OneMinusT * Percent + InTargetPos.X * Percent * Percent
    local Y = InStartPos.Y * OneMinusT * OneMinusT + 2 * InControlPoint.Y * OneMinusT * Percent + InTargetPos.Y * Percent * Percent
    return _G.UE.FVector2D(X, Y)
end

function ChocoboFeeDingMainPanelView:OnTimer()
    if self.GameState < EGAME_STATE.BEGIN then
        return
    end
    
    local CurrentTime = TimeUtil.GetServerTime()
    local ElapsedTime = RemainingTime - math.ceil(CurrentTime - BeginTime)
    
    if ElapsedTime <= 0 then
        ElapsedTime = 0
        self.TextTime:SetText("00:00")
        if self.GameState < EGAME_STATE.OVER and not BeginMove then
            self:GameOver(false)
            return
        end
    end
    
    local DisplayTime = LocalizationUtil.GetCountdownTimeForShortTime(ElapsedTime, "mm:ss") or ""
    self.TextTime:SetText(DisplayTime)

    if self.GameState < EGAME_STATE.RESET then
        if BeginMove then
            local EndPos = FVector2D(TargetPos.X + WidgetSizeScaled.X / 2, StartPos.Y)

            local TotalDistanceSq = (EndPos - StartPos):SizeSquared()
            LastDistance = LastDistance + MoveSpeed * TimerInterVal

            local CurDistanceSq = LastDistance ^ 2
            local Percent = CurDistanceSq / TotalDistanceSq

            if Percent >= 0.99 then
                Percent = 1
            end

            local NextViewportPos = V2DQuadraticBezier(StartPos, TargetPos, Percent, ControlPoint)
            local CurLocalPos = UIUtil.AbsoluteToLocal(self.FCanvasPanel_0, NextViewportPos)
            local CurWidgetPos = CurLocalPos - FVector2D(ScreenSize.X / 2, ScreenSize.Y / 2) + WidgetSizeScaled / 2
            UIUtil.CanvasSlotSetPosition(self.PanelVegetable, CurWidgetPos)

            if Percent >= 0.99 then
                self:CheckGameResult()
            end
        end
    end
end

return ChocoboFeeDingMainPanelView