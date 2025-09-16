---
--- Author: rock
--- DateTime: 2024-12-12 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local PreviewCompanionVM = require("Game/Preview/VM/PreviewCompanionVM")
local CommonUtil = require("Utils/CommonUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CompanionMgr = require("Game/Companion/CompanionMgr")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoRes = require("Protocol/ProtoRes")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local AnimMgr = _G.AnimMgr
local UE = _G.UE

-- local LightPreset = "LightPreset'/Game/UI/Render2D/LightPresets/Login/UniversalLightingPreset/UniversalLightingPreset01.UniversalLightingPreset01'"
-- local CompanionUITODSystemID = 9
-- local CompanionLightLevelID = LightDefine.LightLevelID.LIGHT_LEVEL_ID_COMPANION_ARCHIVE
-- local SCS_FinalColorLDRHasAlpha = _G.UE.ESceneCaptureSource.SCS_FinalColorLDRHasAlpha or 3
local ActorZLocation = 100000
local Interact1TimelineLabel = "IDLE_INACTIVE1"
local Interact2TimelineLabel = "IDLE_INACTIVE2"
local Interact3TimelineLabel = "IDLE_INACTIVE3"
local AttackTimelineLabel = "MINION_BATTLE_LOOP"
local MoveTimelineLable = "RUN"
local RotationX = -6 --Yaw值偏移角度，偏移数据以图鉴为基准，而预览在中间，所以需要偏移才能保持和图鉴一致

---@class PreviewCompanionView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAttack UFButton
---@field BtnAttackCancel UFButton
---@field BtnMove UFButton
---@field BtnMoveCancel UFButton
---@field BtnShow UFButton
---@field BtnShowCancel UFButton
---@field BtnSwitch UFButton
---@field CloseBtn CommonCloseBtnView
---@field CompanionRenderer CompanionRender2DView
---@field HorizontalType UHorizontalBox
---@field PanelInteract UFCanvasPanel
---@field PanelOwnInfo UFCanvasPanel
---@field TextCompanionExpository UFTextBlock
---@field TextCompanionName UFTextBlock
---@field TextMoveType UFTextBlock
---@field TextMoveTypeTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleButtonAttack UToggleButton
---@field ToggleButtonMove UToggleButton
---@field ToggleButtonShow UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimToggleButtonAttackChecked UWidgetAnimation
---@field AnimToggleButtonMoveChecked UWidgetAnimation
---@field AnimToggleButtonShowChecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PreviewCompanionView = LuaClass(UIView, true)

function PreviewCompanionView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAttack = nil
	--self.BtnAttackCancel = nil
	--self.BtnMove = nil
	--self.BtnMoveCancel = nil
	--self.BtnShow = nil
	--self.BtnShowCancel = nil
	--self.BtnSwitch = nil
	--self.CloseBtn = nil
	--self.CompanionRenderer = nil
	--self.HorizontalType = nil
	--self.PanelInteract = nil
	--self.PanelOwnInfo = nil
	--self.TextCompanionExpository = nil
	--self.TextCompanionName = nil
	--self.TextMoveType = nil
	--self.TextMoveTypeTitle = nil
	--self.TextTitle = nil
	--self.ToggleButtonAttack = nil
	--self.ToggleButtonMove = nil
	--self.ToggleButtonShow = nil
	--self.AnimIn = nil
	--self.AnimToggleButtonAttackChecked = nil
	--self.AnimToggleButtonMoveChecked = nil
	--self.AnimToggleButtonShowChecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	self.CompanionActor = nil --当前选中的对象
	self.CompanionEntityID = nil --当前选中的对象EntityID
	self.ModelLocation = nil
	self.InteractTimelineIndex = 0
	self.InteractTimelineList = {}
end

function PreviewCompanionView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CompanionRenderer)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PreviewCompanionView:OnInit()
	self.ViewModel = PreviewCompanionVM.New()
	self:InitPanelStaticText()
end

function PreviewCompanionView:OnDestroy()

end

function PreviewCompanionView:OnShow()
	if self.Params and self.Params.CompanionId then
		local CompanionId = self.Params.CompanionId
		self.ViewModel:UpdateCompanionInfo(CompanionId)
		self:OnShowModel()
	end

	--禁止移动控制(虚拟摇杆)
	CommonUtil.DisableShowJoyStick(true)
	CommonUtil.HideJoyStick()

	_G.HUDMgr:SetIsDrawHUD(false)
end

function PreviewCompanionView:OnHide()
	_G.HUDMgr:SetIsDrawHUD(true)

	--解除移动控制(虚拟摇杆)
	CommonUtil.DisableShowJoyStick(false)
	CommonUtil.ShowJoyStick()

	self:RestoreRefelctionCubemap()
	self:ResetAnimationState()
	self.ViewModel:ResetAnimaionState()

	self.ViewModel:ClearData()

	UE.UActorManager:Get():RemoveClientActor(self.CompanionEntityID)
	self.CompanionActor = nil
	self.CompanionEntityID = nil
end

function PreviewCompanionView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnBtnSwitchClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnShow, self.OnBtnShowClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnShowCancel, self.OnBtnShowCancelClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnAttack, self.OnBtnAttackClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnAttackCancel, self.OnBtnAttackCancelClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMove, self.OnBtnMoveClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMoveCancel, self.OnBtnMoveCancelClicked)
	
	self.CompanionRenderer:SetSingleClickCallback(self, self.OnClickRenderer)
end

function PreviewCompanionView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CompanionArchiveModelStartRotate, self.OnCompanionArchiveModelStartRotate)
	self:RegisterGameEvent(EventID.CompanionArchiveModelEndRotate, self.OnCompanionArchiveModelEndRotate)
end

function PreviewCompanionView:OnRegisterBinder()
	local Binders = {
		{ "CompanionName", UIBinderSetText.New(self, self.TextCompanionName) },
		{ "CompanionExpository", UIBinderSetText.New(self, self.TextCompanionExpository) },

		{ "CanBattle", UIBinderSetIsVisible.New(self, self.BtnAttack, false, true) },
		{ "HasShow", UIBinderSetIsVisible.New(self, self.ToggleButtonShow) },
		{ "IsShowing", UIBinderSetIsChecked.New(self, self.ToggleButtonShow) },
		{ "IsAttacking", UIBinderSetIsChecked.New(self, self.ToggleButtonAttack) },
		{ "IsMoving", UIBinderSetIsChecked.New(self, self.ToggleButtonMove) },

		{ "CompanionMoveType", UIBinderValueChangedCallback.New(self, nil, self.OnCompanionMoveTypeChanged) },
		{ "IsMergeCompanion", UIBinderSetIsVisible.New(self, self.BtnSwitch, false, true) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function PreviewCompanionView:OnShowModel()
	self:InitCompanionModel(self.ViewModel.SelectedCompanionID)
	self:UpdateInteractList(self.ViewModel.SelectedCompanionID)
end

function PreviewCompanionView:InitCompanionModel(CompanionID)
	local function RenderSceneCallBack(IsSuccess)
        if (IsSuccess) then
			self.CompanionRenderer:SwitchSceneLights(false)
			self.CompanionRenderer:SetFOVY(25, false)
			self:SetSpringArmToDefault(false)
        end
    end

	local function RenderActorCallBack(EntityID, CompanionActor)
		self.CompanionEntityID = EntityID
		self.CompanionActor = CompanionActor
		local ID = CompanionActor:GetAttributeComponent().ResID
		self.CompanionActor:AdjustGround(false)
		self.ModelLocation = self.CompanionActor:FGetLocation(UE.EXLocationType.ServerLoc)
		self:SetModelScale(ID)
		self:SetModelLocation(ID)
		self:SetModelRotation(ID)

		self.CompanionRenderer:SetActorVisible(true)
		self.CompanionRenderer:SetInteractionActive(true)

		self.CompanionRenderer:SetActorLOD(1)
		self:TryPlayInteractWhenSelect()
	end

	local CreateParam = {
		Location = UE.FVector(0, 0, ActorZLocation),
		Rotation = UE.FRotator(0, 0, 0),
		SystemID = 30,
	}
	self.CompanionRenderer:ShowCompanion(_G.PreviewMgr.CompanionSceneActorPath, CompanionID, 
	RenderSceneCallBack, RenderActorCallBack, CreateParam)
end

function PreviewCompanionView:UpdateInteractList(CompanionID)
	self.InteractTimelineList = {}
	self.InteractTimelineIndex = 0
	local Cfg = CompanionMgr:GetCompanionExternalCfg(CompanionID)
	if Cfg.InactiveIdle1 > 0 then
		table.insert(self.InteractTimelineList, Interact1TimelineLabel)
	end
	if Cfg.InactiveIdle2 > 0 then
		table.insert(self.InteractTimelineList, Interact2TimelineLabel)
	end

    -- 检查是否解锁了特殊的表演动作
	local IsUnlockAction = CompanionMgr:IsActionUnlock(CompanionID, ProtoRes.CompanionUnlockActionType.Action1)
	if IsUnlockAction then
		table.insert(self.InteractTimelineList, Interact3TimelineLabel)
	end

	self.ViewModel.HasShow = self.InteractTimelineList and #self.InteractTimelineList > 0 or false
end

function PreviewCompanionView:SetModelScale(CompanionID)
	if self.CompanionActor == nil then return end

	local ScaleBase = 100
	local Cfg = CompanionMgr:GetCompanionExternalCfg(CompanionID)
	if Cfg ~= nil and Cfg.ArchiveModelScale > 0 then
		ScaleBase = 125--Cfg.ArchiveModelScale
	end

	local ScaleFactor = ScaleBase / 100
	local CompanionCharacter = self.CompanionActor:Cast(UE.ACompanionCharacter)
	if CompanionCharacter ~= nil then
		CompanionCharacter:SetScaleFactor(ScaleFactor, true)
	end
end

function PreviewCompanionView:SetModelRotation(CompanionID)
	if self.CompanionActor == nil then return end

	local RotationAngle = 0
	local Cfg = CompanionMgr:GetCompanionExternalCfg(CompanionID)

	local Threshold = 0.001
	if Cfg ~= nil and math.abs(Cfg.ArchiveModelRotation) > Threshold then
		RotationAngle = Cfg.ArchiveModelRotation
	end
	
	local Rotation = UE.FRotator(0, RotationX, 0)
	self.CompanionActor:K2_SetActorRotation(Rotation, false)
	self.CompanionRenderer:SetModelRotation(0, RotationAngle, 0, false)
end

function PreviewCompanionView:SetModelLocation(CompanionID)
	if self.CompanionActor == nil then return end

	local MeshComponent = self.CompanionRenderer:GetSkeletalMeshComponent(self.CompanionActor)
	local MeshOriginPosition =  UE.FVector(0, 0, 0)
	if MeshComponent then
		MeshOriginPosition = MeshComponent:GetRelativeLocation()
	end
	local Cfg = CompanionMgr:GetCompanionExternalCfg(CompanionID)

	-- 配置了才调整位置，没配置则使用模型的默认位置
	if Cfg and Cfg.ArchiveModelLocation then
		local CfgX = Cfg.ArchiveModelLocation.X
		local CfgY = Cfg.ArchiveModelLocation.Y
		local CfgZ = Cfg.ArchiveModelLocation.Z
		local ModelX = CfgX or MeshOriginPosition.X
		local ModelY = CfgY or MeshOriginPosition.Y
		-- 模型XY直接设置Mesh
		self.CompanionRenderer:SetModelLocation(ModelX, ModelY, MeshOriginPosition.Z, false)
		-- 模型Z需要透过接口另外设置
		local CompanionCharacter = self.CompanionActor:Cast(UE.ACompanionCharacter)
		CompanionCharacter:SetModelFloatHeight(CfgZ, true)

		-- 背景位置需要根据模型位置调整
		local MeshLocationForBG = UE.FVector(ModelX, ModelY, 0)
		local ActorTransform = self.CompanionActor:GetTransform()
		local BGLocation = _G.UE.UKismetMathLibrary.TransformLocation(ActorTransform, MeshLocationForBG)
		BGLocation.Z = ActorZLocation
		self.CompanionRenderer:SetBackgroundLocation(BGLocation)
	end
end

function PreviewCompanionView:SetSpringArmToDefault(bInterp)
	--self.CompanionRenderer:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self:SetSpringArmLocationToDefault(bInterp)
	self:SetSpringArmRotationToDefault(bInterp)
	self:SetSpringArmDistanceToDefault(bInterp)
	--self:SetSpringArmCenterOffsetYoDefault(bInterp)
end

function PreviewCompanionView:SetSpringArmLocationToDefault(bInterp)
	self.CompanionRenderer:SetSpringArmLocation(0, 0, 95, bInterp)
end

function PreviewCompanionView:SetSpringArmRotationToDefault(bInterp)
	self.CompanionRenderer:SetSpringArmRotation(0, 180, 0, bInterp)
end

function PreviewCompanionView:SetSpringArmDistanceToDefault(bInterp)
	self.CompanionRenderer:SetSpringArmDistance(600, bInterp)
end

function PreviewCompanionView:SetSpringArmCenterOffsetYoDefault(bInterp)
	self.CompanionRenderer:SetSpringArmCenterOffsetY(90)
end

function PreviewCompanionView:ResetAnimationState()
	self:StopActionTimeline()
	self.ViewModel:ResetAnimaionState()
end

function PreviewCompanionView:RestoreRefelctionCubemap()
	if self.CurWorldRef == nil then return end
	
	self.CurWorldRef.CaptureComponent.Cubemap = self.OriginCubeMap
	self.OriginCubeMap = nil
end

function PreviewCompanionView:OnCompanionMoveTypeChanged(NewValue, OldValue)
	if NewValue == nil then return end

    local MoveTypeText = ProtoEnumAlias.GetAlias(ProtoRes.CompanionMoveType, NewValue)
	self.TextMoveType:SetText(MoveTypeText)

	local CanCompanionMove = NewValue ~= ProtoRes.CompanionMoveType.Immobile
	UIUtil.SetIsVisible(self.BtnMove, CanCompanionMove, true)
end

function PreviewCompanionView:InitPanelStaticText()
	self.TextTitle:SetText(LSTR(120032))
	self.TextMoveTypeTitle:SetText(LSTR(120027))
end

--特殊宠物-切换个体
function PreviewCompanionView:OnBtnSwitchClicked()
	local CompanionList = self.ViewModel.CompanionList
	if self.ViewModel.MergeCompanionIndex == #CompanionList then
		self.ViewModel.MergeCompanionIndex = 1
	else
		self.ViewModel.MergeCompanionIndex = self.ViewModel.MergeCompanionIndex + 1
	end
	self.ViewModel.SelectedCompanionID = CompanionList[self.ViewModel.MergeCompanionIndex]

	self:ResetAnimationState()
	self.CompanionRenderer:SwitchModel(self.ViewModel.SelectedCompanionID)
end

function PreviewCompanionView:OnBtnShowClicked()
	self.ViewModel:SetAutoPlayInteract(false)
	self.ViewModel:SetShowState(true)
	local function Callback()
		self.ViewModel:SetShowState(false)
	end

	self:PlayInteractTimelineByList(Callback)
end

function PreviewCompanionView:OnBtnShowCancelClicked()
	self:StopActionTimeline()
end

function PreviewCompanionView:OnBtnAttackClicked()
	self.ViewModel:SetAutoPlayInteract(false)
	self.ViewModel:SetAttackState(true)
	local function Callback()
		self.ViewModel:SetAttackState(false)
	end
	self:PlayActionTimeline(AttackTimelineLabel, Callback)
end

function PreviewCompanionView:OnBtnAttackCancelClicked()
	self:StopActionTimeline()
end

function PreviewCompanionView:OnBtnMoveClicked()
	self.ViewModel:SetAutoPlayInteract(false)
	self.ViewModel:SetMoveState(true)
	local function Callback()
		self.ViewModel:SetMoveState(false)
	end
	self:PlayActionTimeline(MoveTimelineLable, Callback)
end

function PreviewCompanionView:OnBtnMoveCancelClicked()
	self:StopActionTimeline()
end

function PreviewCompanionView:PlayActionTimeline(TimelineLabel, Callback)
	local SearchCondition = string.format("Label = \"%s\"", TimelineLabel)
	local ActiontimelineCfg = ActiontimelinePathCfg:FindCfg(SearchCondition)
	if ActiontimelineCfg then
		AnimMgr:PlayActionTimeLine(self.CompanionEntityID, ActiontimelineCfg.Filename, Callback)
	end
end


function PreviewCompanionView:StopActionTimeline()
	if self.CompanionActor then
		local AnimationComponent = self.CompanionActor:GetAnimationComponent()
		if AnimationComponent then
			local AnimationInstance = AnimationComponent:GetAnimInstance()
			if AnimationInstance then
				local BlendOutTime = 0.25
				AnimationInstance:Montage_Stop(BlendOutTime)
			end
		end
	end
end

function PreviewCompanionView:OnClickRenderer()
	local MouseX = self.CompanionRenderer.StartPosX
	local MouseY = self.CompanionRenderer.StartPosY
	local MousePosition = UE.FVector2D(MouseX, MouseY)
	if UIUtil.IsUnderLocation(self.PanelInteract, MousePosition) then
		self.ViewModel:SetAutoPlayInteract(not self.ViewModel:GetAutoPlayInteract())
		self:TryPlayInteractTimeline()
	end
end


-- function PreviewCompanionView:TryShowCryBubble()
-- 	if self.HasInteracted then return end

-- 	self.HasInteracted = true
-- 	local Cfg = CompanionGlobalCfg:FindCfgByKey(ProtoRes.CompanionParamCfgID.CompanionParamCfgIDArchiveCryDisplayTime)
-- 	local CryDisplayTime = Cfg.Value[1]
-- 	self.ViewModel:SetCompanionCryVisible(true)
-- 	self.CryDisplayTimerID = self:RegisterTimer(function() self.ViewModel:SetCompanionCryVisible(false) end, CryDisplayTime)
-- end

function PreviewCompanionView:TryPlayInteractTimeline()
	local function Callback()
		if self.ViewModel:GetAutoPlayInteract() then
			self:PlayInteractTimelineByList(Callback)
		end
	end

	if self.ViewModel:GetAutoPlayInteract() then
		self:PlayInteractTimelineByList(Callback)
	else
		self:StopActionTimeline()
	end
end

function PreviewCompanionView:PlayInteractTimelineByList(Callback)
	local InteractCount = #self.InteractTimelineList
	if InteractCount > 0 then
		if self.InteractTimelineIndex == InteractCount then
			self.InteractTimelineIndex = 1
		else
			self.InteractTimelineIndex = self.InteractTimelineIndex + 1
		end
		local TimelineLabel = self.InteractTimelineList[self.InteractTimelineIndex]
		self:PlayActionTimeline(TimelineLabel, Callback)
	end
end

function PreviewCompanionView:TryPlayInteractWhenSelect()
	self:PlayActionTimeline(Interact1TimelineLabel)
end

function PreviewCompanionView:OnCompanionArchiveModelStartRotate()
	self:ResetAnimationState()
end

function PreviewCompanionView:OnCompanionArchiveModelEndRotate()
	
end

return PreviewCompanionView