---
--- Author: Administrator
--- DateTime: 2024-01-29 11:14
--- Description:主界面
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local LightDefine = require("Game/Light/LightDefine")
local LightLevelID = LightDefine.LightLevelID
local LightLevelCreateLocation = LightDefine.LightLevelCreateLocation
local UIViewID = require("Define/UIViewID")
local LightMgr = require("Game/Light/LightMgr")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonDefine = require("Define/CommonDefine")
local RenderActorPath = "Class'/Game/UI/Render2D/FashionEvaluation/BP_Render2DLoginActor_FashionNPC.BP_Render2DLoginActor_FashionNPC_C'"
local LSTR = _G.LSTR
local ProtoRes = require("Protocol/ProtoRes")
local EquipmentType = ProtoRes.EquipmentType
local UKismetInputLibrary = UE.UKismetInputLibrary
local EFashionView = FashionEvaluationDefine.EFashionView

---@class FashionEvaluationMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStart CommBtnLView
---@field Bulletin FashionEvaluationBulletinItemView
---@field CloseBtn CommonCloseBtnView
---@field InforBtn CommInforBtnView
---@field MainPanel UFCanvasPanel
---@field PanelCeleBration UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field Render2D CommonRender2DView
---@field RossTips FashionEvaluationRossTipsView
---@field TableViewTab UTableView
---@field TextNumberOfChallenges UFTextBlock
---@field TextTitle1 UFTextBlock
---@field TextTitle2 UFTextBlock
---@field AnimInGrand UWidgetAnimation
---@field AnimInNormal UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationMainPanelView = LuaClass(UIView, true)

function FashionEvaluationMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStart = nil
	--self.Bulletin = nil
	--self.CloseBtn = nil
	--self.InforBtn = nil
	--self.MainPanel = nil
	--self.PanelCeleBration = nil
	--self.PanelNormal = nil
	--self.Render2D = nil
	--self.RossTips = nil
	--self.TableViewTab = nil
	--self.TextNumberOfChallenges = nil
	--self.TextTitle1 = nil
	--self.TextTitle2 = nil
	--self.AnimInGrand = nil
	--self.AnimInNormal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.Bulletin)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.Render2D)
	self:AddSubView(self.RossTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationMainPanelView:OnInit()
	self.ThemePartsAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, nil, true, false)
	self.AwardAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.Bulletin.TableViewTaskList, nil, true, false)
	self.MultiBinders = {
		{
			ViewModel = FashionEvaluationVM,
			Binders = {
				{"ProgressAwardVMList", UIBinderUpdateBindableList.New(self, self.AwardAdapterTableView)},
				{"RemainTimesText", UIBinderSetText.New(self, self.TextNumberOfChallenges)},
				{"WeekHighestScoreText", UIBinderSetText.New(self, self.Bulletin.TextHighestScore)},
				{"ThemeName", UIBinderSetText.New(self, self.TextTitle2)},
				{ "SettlementViewVisible", UIBinderValueChangedCallback.New(self, nil, self.OnSettlementViewVisibleChanged) },
				{ "MainViewVisible", UIBinderValueChangedCallback.New(self, nil, self.OnMainViewVisibleChanged) },
				{ "FittingViewVisible", UIBinderValueChangedCallback.New(self, nil, self.OnFittingViewVisibleChanged) },
				{ "NPCEquipViewVisible", UIBinderValueChangedCallback.New(self, nil, self.OnNPCEquipViewVisibleChanged) },
				{ "RecordViewVisible", UIBinderValueChangedCallback.New(self, nil, self.OnRecordViewVisibleChanged) },
				{ "ProgressViewVisible", UIBinderValueChangedCallback.New(self, nil, self.OnProgressViewVisibleChanged) },
				{ "IsCelebration", UIBinderValueChangedCallback.New(self, nil, self.OnIsCelebrationChanged) },
				{ "WeekRemainTimesColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNumberOfChallenges) },
				{ "IsRemainTimesNotEnough", UIBinderValueChangedCallback.New(self, nil, self.OnIsRemainTimesNotEnoughChanged) },
				{"PartThemeVMList", UIBinderUpdateBindableList.New(self, self.ThemePartsAdapterTableView)},
			}
		},
	}
	
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	--与射线选择NPC互斥的按钮
	self.MuteWithSelectTraceButtonList = {
		self.BtnStart,
	}
end

function FashionEvaluationMainPanelView:OnDestroy()
	
end

function FashionEvaluationMainPanelView:OnShow()
	self:SetLSTR()
	self.IsFirstTimesEnter = true
	self.ReadyNPCNum = 0
	self.MouseButtonActive = true
	self.TableViewTab:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
	UIUtil.SetIsVisible(self.RossTips, false)
	FashionEvaluationVM:InitViewsVisible()
	FashionEvaluationVM:OnFirstTimesEnterMainView(true)
	
	self:CreateRenderActor()
	LightMgr:LoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION, LightLevelCreateLocation[LightLevelID.LIGHT_LEVEL_ID_FASHION_EVALUATION], 1)
	FashionEvaluationMgr:OnFashionSceneVisibleChanged(true)
	_G.HUDMgr:SetIsDrawHUD(false)
end

function FashionEvaluationMainPanelView:OnHide()
	self.CameraFocusCfgMap:SetAssetUserData(nil)
	self.Render2D:SwitchOtherLights(true)
	FashionEvaluationMgr:OnFashionSceneVisibleChanged(false)

	LightMgr:UnLoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION, 1)
	LightMgr:UnLoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION, 2)
	LightMgr:DisableUIWeather(true)
	FLOG_INFO("时尚品鉴：禁用UI天气")
	_G.HUDMgr:SetIsDrawHUD(true)
end

function FashionEvaluationMainPanelView:SetLSTR()
	self.TextTitle1:SetText(_G.LSTR(1120031)) -- 1120031("时尚品鉴")
	self.BtnStart:SetBtnName(_G.LSTR(1120032)) --1120032("开始挑战")
end

---@type 创建2D场景
function FashionEvaluationMainPanelView:CreateRenderActor()
	local CallBack = function(bSucc)
		if (type(bSucc) == "boolean" and bSucc == true) then
			self.RenderActor = self.Render2D.RenderActor
			self.VignetteIntensityDefaultValue = self.Render2D:GetPostProcessVignetteIntensity()
			self.Render2D:SwitchOtherLights(false)
			LightMgr:EnableUIWeather(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION)
			self.Render2D:ChangeUIState(false)
			self.Render2D.bAutoInitSpringArm = false
			self.Render2D:SetShowHead(true)
			FashionEvaluationMgr:ShowOrCreateAllNPC() -- 创建NPC
			local EntityID = MajorUtil.GetMajorEntityID()
			self.Render2D:SetUICharacterByEntityID(EntityID)
			self.CameraFocusCfgMap:SetAssetUserData(self.Render2D:GetEquipmentConfigAssetUserData())
			self:SetModelSpringArmToDefault(false, EFashionView.Main)
			self.Render2D:HidePlayer(true)
			self:ActivePresetLights(false)
		end
	end
	local ReCreateCallBack = function()
		self.CameraFocusCfgMap:SetAssetUserData(self.Render2D:GetEquipmentConfigAssetUserData())
	end
	self.Render2D:CreateRenderActor(RenderActorPath, 
	FashionEvaluationDefine.CharacterClass, "",
	false, CallBack, ReCreateCallBack)
end

---@type 显示玩家展示角色 与NPC显示互斥
function FashionEvaluationMainPanelView:ShowPlayerUICharacter(IsVisible)
	self.Render2D:HidePlayer(not IsVisible)
	FashionEvaluationMgr:HideCreatedNPCList(IsVisible)
end

--角色拼装完成
function FashionEvaluationMainPanelView:OnAssembleAllEnd(Params)
	local ChildActor = self.Render2D:GetCharacter()
	if (ChildActor == nil) then return end
	local EntityID = Params.ULongParam1
	local ObjType = Params.IntParam1
	local AttrComp = ChildActor:GetAttributeComponent()
	if EntityID == AttrComp.EntityID and ObjType == AttrComp.ObjType then
		--self.Render2D:ResetLightPreset("")
		--隐藏主副手武器
		self.Render2D:HideWeapon(true)
		local UIComplexCharacter = self.Render2D.UIComplexCharacter
		if UIComplexCharacter then
			UIComplexCharacter:GetAvatarComponent():SetForcedLODForAll(1)
		end
	end
	--local NPCList = FashionEvaluationMgr:GetCreatedNPCList()
	local NpcList = FashionEvaluationVMUtils.GetNPCInfos()
	local ReadyResID = ActorUtil.GetActorResID(EntityID)
	local MaxNPCNum = NpcList and #NpcList or 1
	local FindNPC, Index = table.find_item(NpcList, ReadyResID, "NPCID")
	if FindNPC then
		self.ReadyNPCNum = self.ReadyNPCNum + 1
		local LoadingPercent = math.clamp(self.ReadyNPCNum / MaxNPCNum, 0, 1)
		local function OnAllNPCReady()
			FashionEvaluationMgr:OnLoadingEnd()
			local IsFirstOpenWithinWeek = FashionEvaluationMgr:GetIsFirstOpenWithinWeek()
			if IsFirstOpenWithinWeek then
				self:ShowPrologue()
			else
				UIUtil.SetIsVisible(self.RossTips, false)
				FashionEvaluationMgr:ShowFashionMainView(true)
			end
		end

		_G.EventMgr:SendEvent(_G.EventID.OnFashionNPCLoadingProgress, LoadingPercent)
		if self.ReadyNPCNum >= MaxNPCNum then
			self:RegisterTimer(OnAllNPCReady, 2)
		end
	end
end

function FashionEvaluationMainPanelView:ActivePresetLights(IsActive)
	if IsActive then
		local LightPresetPath = FashionEvaluationVMUtils.GetLightPresetPath()
		self.Render2D:ResetLightPreset(LightPresetPath)
	elseif self:CheckRenderActorValid() then
		self.RenderActor:SetLightsVisible(false)
	end
end

function FashionEvaluationMainPanelView:CheckRenderActorValid()
	return self.RenderActor and _G.UE.UCommonUtil.IsObjectValid(self.RenderActor)
end

function FashionEvaluationMainPanelView:OnRegisterUIEvent()
	self.CloseBtn:SetCallback(self, self.OnBtnCloseClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnFittingClicked)
end

function FashionEvaluationMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(_G.EventID.OnFashionNPCSelectedChanged, self.EventOnFashionNPCSelectedChanged)
	self:RegisterGameEvent(_G.EventID.ShowUI, self.OnShowView)
	self:RegisterGameEvent(_G.EventID.HideUI, self.OnHideView)
	self:RegisterGameEvent(_G.EventID.OnFashionEvaluationStart, self.OnFashionEvaluationStartChange)
end

function FashionEvaluationMainPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end

function FashionEvaluationMainPanelView:PlayMainPanelEffectAnim()
	local function PlayOpenAnim()
		local InAnimation = self.AnimInNormal
		if InAnimation then
			self.IsFirstTimesEnter = false
			UIUtil.SetIsVisible(self.MainPanel, true)
			self:PlayAnimation(InAnimation)
		end
	end

	if FashionEvaluationVM.IsCelebration and self.IsFirstTimesEnter then
		UIUtil.SetIsVisible(self.MainPanel, false)
		_G.UIViewMgr:ShowView(_G.UIViewID.FashionEvaluationCelebrationEffectPanel, {EfectFinishedCallback = PlayOpenAnim, View = self})
	else
		PlayOpenAnim()
	end
end

function FashionEvaluationMainPanelView:OnBtnCloseClicked()
	FashionEvaluationMgr:OnExitFashionEvaluation()
end

function FashionEvaluationMainPanelView:OnBtnFittingClicked()
	local FittingVM = FashionEvaluationVM:GetFittingVM()
	if FittingVM then
		FittingVM:UpdateThemePartList()
	end
	FashionEvaluationMgr:RestoreUICharacterAvatar()
	FashionEvaluationMgr:ShowFittingView(true, true)
	-- FashionEvaluationVM:SetSettlementViewVisible(true)
	-- local result = {
	-- 	CheckResult = {
	-- 		        TotalScore = 90, -- 总得分
	-- 		        EquipList = {
	-- 		            {PartID = { ResID =50273120, IsMatchTheme = false, IsOwn = true}}, 
	-- 		            {PartID = { ResID =50010197, IsMatchTheme = false, IsOwn = true}},
	-- 		        }, -- 各个部位详细得分
	-- 		        OwnScore = 5, -- 拥有外观的得分
	-- 		    }
	-- }
	-- FashionEvaluationVM:UpdateSettlementInfo(result)
end

function FashionEvaluationMainPanelView:OnBtnNPCClicked()
	FashionEvaluationMgr:ShowFashionNPCView()
end

function FashionEvaluationMainPanelView:OnShowView(ViewID)
	if ViewID == UIViewID.HelpInfoLargeWinView or ViewID == UIViewID.HelpInfoMidWinView then
		self.MouseButtonActive = false
	end
end

function FashionEvaluationMainPanelView:OnHideView(ViewID)
	if ViewID == UIViewID.HelpInfoLargeWinView or ViewID == UIViewID.HelpInfoMidWinView then
		self.MouseButtonActive = true
	end
end

function FashionEvaluationMainPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	if _G.UIViewMgr:IsViewVisible(UIViewID.FashionEvaluationLoadingPanel) then
		return
	end

	self:ShowPrologue()
	if FashionEvaluationVM.MainViewVisible == false then
		return
	end
	
	if self.MouseButtonActive == false then
		return
	end
	
	if _G.NewTutorialMgr.TutorialState and _G.NewTutorialMgr:GetRunningSubGroup() then	
		return
	end

	if FashionEvaluationMgr:GetIsFirstOpenWithinWeek() and not FashionEvaluationMgr:GetIsPrologueEnd() then
		return
	end
	
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	local LocalMousePos, ViewportMousePos = UIUtil.AbsoluteToViewport(MousePosition)
	if self:IsOnButtonArea(ViewportMousePos) then
		return
	end

	local WorldPosition = _G.UE.FVector()
	local WorldDirection = _G.UE.FVector()
	local PlayerIndex = 1
    if CommonDefine.NoCreateController == true then
        PlayerIndex = 0
    end
	UIUtil.DeprojectScreenToWorld(LocalMousePos, WorldPosition, WorldDirection, PlayerIndex)
	if not self:CheckRenderActorValid() then
		return
	end

	local ArmActorComponent = self.RenderActor:GetComponentByClass(_G.UE.USpringArmComponent)
	if ArmActorComponent == nil then
		return
	end

	local ArmActorLocation = ArmActorComponent:K2_GetComponentLocation()
	local TraceEndLocation = WorldPosition + WorldDirection * math.abs(ArmActorLocation.X + 10000)
	local TraceUtil = _G.UE.UTraceUtil
	if TraceUtil then
		local HitOut = _G.UE.FHitResult()
		local Channel = _G.UE.ECollisionChannel.ECC_WorldStatic
		local World = _G.UE.UFGameInstance.Get():GetWorld()
		if TraceUtil.LineTrace(World, self.RenderActor, ArmActorLocation, TraceEndLocation, HitOut, Channel, false, false) then
			local HitActor = HitOut.Actor	
			local IsSelected, NPCIndex= self:IsSelectedNPC(HitActor)
			if IsSelected and NPCIndex then
				self:OnSelectedNPC(NPCIndex)
			end
		end
	end
end

---@type 是否处于按钮区域
function FashionEvaluationMainPanelView:IsOnButtonArea(MousePosition)
	if self.MuteWithSelectTraceButtonList == nil or next(self.MuteWithSelectTraceButtonList) == nil then
		return false
	end

	for _, Button in ipairs(self.MuteWithSelectTraceButtonList) do
		local SlotSize = Button:GetDesiredSize()
		local ButtonPos = UIUtil.GetWidgetPosition(Button)
		self.DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
		if MousePosition.X > ButtonPos.X and MousePosition.X < ButtonPos.X + SlotSize.X and
			MousePosition.Y > ButtonPos.Y and MousePosition.Y < ButtonPos.Y + SlotSize.Y then
			return true
		end
	end
	return false
end

---@type 显示开场白
function FashionEvaluationMainPanelView:ShowPrologue()
	if not FashionEvaluationMgr:GetIsLoadingEnd() then
		return
	end

	local IsFirstOpenWithinWeek = FashionEvaluationMgr:GetIsFirstOpenWithinWeek()
	if not IsFirstOpenWithinWeek then
		return
	end

	if FashionEvaluationMgr:GetIsPrologueEnd() then
		return
	end

	UIUtil.SetIsVisible(self.RossTips, true)
	if self.RossTips:IsVisible() then
		self.RossTips:OnShowNextPrologue()
	end
end

---@type NPC选中处理
function FashionEvaluationMainPanelView:OnSelectedNPC(NPCIndex)
	FashionEvaluationMgr:OnSelectedNPC(NPCIndex)
end

---@type NPC切换
function FashionEvaluationMainPanelView:EventOnFashionNPCSelectedChanged()
	self:SetModelSpringArmToDefault(false, EFashionView.NPCEquip)
end

-- ---@type NPC选择检测
-- function FashionEvaluationMainPanelView:IsSelectedNPC(ClickLocation)
-- 	local CreatedNPCList = FashionEvaluationMgr:GetCreatedNPCList()
-- 	if CreatedNPCList == nil or next(CreatedNPCList) == nil then
-- 		return false
-- 	end

-- 	local ClickLocYZ = _G.UE.FVector(0, ClickLocation.Y, ClickLocation.Z)
-- 	for index, NPCEntityID in ipairs(CreatedNPCList) do
-- 		local NpcActor = ActorUtil.GetActorByEntityID(NPCEntityID)
-- 		if NpcActor then
-- 			local NpcLocation = NpcActor:K2_GetActorLocation()
-- 			local NpcLocYZ = _G.UE.FVector(0, NpcLocation.Y, NpcLocation.Z)
-- 			local DeltaVector = ClickLocYZ - NpcLocYZ
-- 			local Radius = NpcActor:GetCapsuleRadius()
-- 			local Height = NpcActor:GetCapsuleHalfHeight()
-- 			if math.abs(DeltaVector.Y) <= Radius and math.abs(DeltaVector.Z) <= Height then
-- 				return true, index
-- 			end
-- 		end
-- 	end
-- 	return false
-- end

---@type NPC选择检测
function FashionEvaluationMainPanelView:IsSelectedNPC(SelectActor)
	if SelectActor == nil then
		return false
	end

	local CreatedNPCList = FashionEvaluationMgr:GetCreatedNPCList()
	if CreatedNPCList == nil or next(CreatedNPCList) == nil then
		return false
	end

	for index, NPCEntityID in ipairs(CreatedNPCList) do
		local NpcActor = ActorUtil.GetActorByEntityID(NPCEntityID)
		if NpcActor == SelectActor then
			return true, index
		end
	end
	return false
end

function FashionEvaluationMainPanelView:SetModelSpringArmToDefault(bInterp, EFashionView)
	self.Render2D:EnableRotator(true)
	self.Render2D:SetCameraFocusScreenLocation(nil, nil, nil, nil)
	self.Render2D:SetModelRotation(0, 0 , 0, true)
	self.Render2D:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)

	if EFashionView == nil then
		return
	end

	local CameraFocusInfo = self:GetCameraParams(EFashionView)
	if CameraFocusInfo then
		self.Render2D:SetSpringArmDistance(CameraFocusInfo.Distance, bInterp)
		if CameraFocusInfo.Offset then
			self.Render2D:SetSpringArmLocation(CameraFocusInfo.Offset.X, CameraFocusInfo.Offset.Y, CameraFocusInfo.Offset.Z, bInterp)
		end
		if CameraFocusInfo.Rotation then
			self.Render2D:SetSpringArmRotation(CameraFocusInfo.Rotation.X, CameraFocusInfo.Rotation.Y, CameraFocusInfo.Rotation.Z, false, 10)
		end
		self.Render2D:SetCameraFOV(CameraFocusInfo.FOV)
	end

	self:SetActorLookAtCamera(EFashionView)
end

function FashionEvaluationMainPanelView:GetCameraParams(FashionView)
	--正式读表
	local AttachType = nil
	if FashionView == EFashionView.Fitting or
		FashionView == EFashionView.Settlement or 
		FashionView == EFashionView.Record or
		FashionView == EFashionView.Progress then  --主角相关界面
		local MajorAvatarComp= MajorUtil.GetMajorAvatarComponent()
		if MajorAvatarComp then
			AttachType = MajorAvatarComp:GetAttachTypeIgnoreChangeRole()
		end	
	elseif FashionView == EFashionView.NPCEquip then  -- NPC界面
		local SelectNPCActor = FashionEvaluationMgr:GetSelectedNPCActor()
		if SelectNPCActor then
			local NpcAvatarComp = SelectNPCActor:GetAvatarComponent()
			if NpcAvatarComp then
				AttachType = NpcAvatarComp:GetAttachTypeIgnoreChangeRole()
			end	
		end
	end

	return FashionEvaluationVMUtils.GetCameraControlParams(FashionView, AttachType)
end

---@type 看向镜头
function FashionEvaluationMainPanelView:SetActorLookAtCamera(FashionView)
	local CameraLoc = self.Render2D:GetSpringArmLocation()
	if FashionView == EFashionView.Fitting or
		FashionView == EFashionView.Settlement or 
		FashionView == EFashionView.Record or
		FashionView == EFashionView.Progress then  --主角相关界面
		local CharacterLoc = self.Render2D:GetModelLocation()
		local LookAtRot = _G.UE.UKismetMathLibrary.FindLookAtRotation(CharacterLoc, CameraLoc)
		self.Render2D:SetModelRotation(0, LookAtRot.Yaw, 0, true)
	elseif FashionView == EFashionView.NPCEquip then  -- NPC界面
		local SelectNPCActor = FashionEvaluationMgr:GetSelectedNPCActor()
		if SelectNPCActor then
			local NpcLoc = SelectNPCActor:K2_GetActorLocation()
			local LookAtRot = _G.UE.UKismetMathLibrary.FindLookAtRotation(NpcLoc, CameraLoc)
			SelectNPCActor:K2_SetActorRotation(_G.UE.FRotator(0, LookAtRot.Yaw, 0), false)
		end
	end
end

function FashionEvaluationMainPanelView:ClearPreView()
	self.PreViewMap = {}
	self.Render2D:ResumeAvatar()
end

---@type 新手引导 追踪目标
function FashionEvaluationMainPanelView:CheckTrackTutorial()
	local RemainTimesInfo = FashionEvaluationVM:GetFashionEvaluationSingleInfo()
	local TrackVM = FashionEvaluationVM:GetTrackVM()
	local IsTrackListEmpty = TrackVM and TrackVM.IsTrackListEmpty
	local NotFirstEvaluation = RemainTimesInfo and RemainTimesInfo.WeekRemainTimes < RemainTimesInfo.MaxWeekRemainTimes
	if not IsTrackListEmpty and NotFirstEvaluation then
		local function ShowFashionCheckRecptTutorial(Params)
			local EventParams = _G.EventMgr:GetEventParams()
			EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
			EventParams.Param1 = TutorialDefine.GameplayType.FashionCheckRecpt
			EventParams.Param2 = TutorialDefine.GamePlayStage.FashionCheckRecptRepeatEnter
			_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
		end
		local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowFashionCheckRecptTutorial, Params = {}}
		_G.TipsQueueMgr:AddPendingShowTips(TutorialConfig) --玩法节点
	end
end

---@type 新手引导 玩法解锁
function FashionEvaluationMainPanelView:CheckStartTutorial()
	local function ShowFashionEvaluationTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.FashionCheckRecpt
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowFashionEvaluationTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig) --玩法解锁
end

---@type 主界面
function FashionEvaluationMainPanelView:OnMainViewVisibleChanged(IsVisible)
	UIUtil.SetIsVisible(self.MainPanel, IsVisible)
	if IsVisible then
		self:PlayMainPanelEffectAnim()
		FashionEvaluationVM:ClearSelectedNPC()
		self:ShowPlayerUICharacter(false)
		self:SetModelSpringArmToDefault(false, EFashionView.Main)
		local FocusAwardIndex = FashionEvaluationVM:GetHaveGetProgressNum()
		if FocusAwardIndex and FocusAwardIndex > 0 then
			self.AwardAdapterTableView:ScrollToIndex(FocusAwardIndex)
		end
		
		self:CheckStartTutorial()
	end
end

---@type 试衣界面
function FashionEvaluationMainPanelView:OnFittingViewVisibleChanged(IsVisible)
	if IsVisible then
		self:ShowPlayerUICharacter(true)
		self:SetModelSpringArmToDefault(false, EFashionView.Fitting)
		self:SetUIComplexCharacterLocation(EFashionView.Fitting)
		self:CheckTrackTutorial()
	end
    _G.ObjectMgr:CollectGarbage(false)
end

---@type 时尚达人界面
function FashionEvaluationMainPanelView:OnNPCEquipViewVisibleChanged(IsVisible)
	if IsVisible then
		FashionEvaluationMgr:HideCreatedNPCList(true)
		self:SetModelSpringArmToDefault(false, EFashionView.NPCEquip)
		LightMgr:LoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION, LightLevelCreateLocation[LightLevelID.LIGHT_LEVEL_ID_FASHION_EVALUATION_FOCU], 2)
	else
		LightMgr:UnLoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION, 2)
	end
	self:ActivePresetLights(IsVisible)
end

---@type 挑战记录界面
function FashionEvaluationMainPanelView:OnRecordViewVisibleChanged(IsVisible)
	if IsVisible then
		self:ShowPlayerUICharacter(true)
		self:SetModelSpringArmToDefault(false, EFashionView.Record)
		self:SetUIComplexCharacterLocation(EFashionView.Record)
	end
end

---@type 评分过程界面
function FashionEvaluationMainPanelView:OnProgressViewVisibleChanged(IsVisible)
	if IsVisible then
		self:ShowPlayerUICharacter(true)
		self:SetModelSpringArmToDefault(false, EFashionView.Progress)
		self:SetUIComplexCharacterLocation(EFashionView.Progress)
	end
end

---@type 结算界面
function FashionEvaluationMainPanelView:OnSettlementViewVisibleChanged(IsVisible)
	if IsVisible then
		self:ShowPlayerUICharacter(true)
		self:SetModelSpringArmToDefault(false, EFashionView.Settlement)
		self:SetUIComplexCharacterLocation(EFashionView.Settlement)
	end
end

---@type 时尚庆典提示
function FashionEvaluationMainPanelView:OnIsCelebrationChanged(IsCelebration)
	-- TODO
end

function FashionEvaluationMainPanelView:OnIsRemainTimesNotEnoughChanged(IsRemainTimesNotEnough)
	self.BtnStart:SetIsEnabled(not IsRemainTimesNotEnough, false)
end

function FashionEvaluationMainPanelView:OnFashionEvaluationStartChange(IsStart)
	-- 评分播放LCut时，卸载灯光关卡
	if IsStart then
		local function DisableLight()
			LightMgr:UnLoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION, 1)
			LightMgr:DisableUIWeather(true)
		end
		self:RegisterTimer(DisableLight, 1.0) -- 延迟禁用灯光与天气，防止试衣界面穿帮
	else
		LightMgr:LoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION, LightLevelCreateLocation[LightLevelID.LIGHT_LEVEL_ID_FASHION_EVALUATION], 1)
		LightMgr:EnableUIWeather(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_FASHION_EVALUATION)
	end
end

function FashionEvaluationMainPanelView:GetUIComplexCharacter()
	if not self.Render2D then
		return nil
	end

	return self.Render2D.UIComplexCharacter
end

function FashionEvaluationMainPanelView:SetUIComplexCharacterLocation(EFashionView)
	local Location, Rotation = FashionEvaluationVMUtils.GetShowLocationAndRotation(EFashionView)
	if Location == nil then
		return
	end
	local CharacterLoc = self.Render2D:GetModelLocation()
	if CharacterLoc then
		self.Render2D:SetModelLocation(Location.X, Location.Y, CharacterLoc.Z, false)
	end
end

function FashionEvaluationMainPanelView:GetRenderActorLocation()
	if not self:CheckRenderActorValid() then
		return nil
	end

	return self.RenderActor:K2_GetActorLocation()
end


return FashionEvaluationMainPanelView