---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-12 19:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local SignsMgr = require("Game/Signs/SignsMgr")
local CommonUtil = require("Utils/CommonUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UUIUtil = _G.UE.UUIUtil
local GestureMgr = _G.UE.UGestureMgr
local TArray = UE.TArray
local AActor = UE.AActor
local UGameplayStatics = UE.UGameplayStatics
local AStaticMeshActor = UE.AStaticMeshActor
local ABlockingVolume = UE.ABlockingVolume
local ASgLayoutActorBase = UE.ASgLayoutActorBase
local PWorldMgr = _G.PWorldMgr

_G.MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class SignsMainSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgDisable UFImage
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field ImgUse UFImage
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SignsMainSlotView = LuaClass(UIView, true)

function SignsMainSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgDisable = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.ImgUse = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.EffectActor = nil
	self.TempEffectActor = nil --移动时临时生成的对象
	self.TouchDown = false
	self.PointerIndex = -1
	--self.ResPath = "ParticleSystem'/Game/Assets/Effect/Particles/Sence/Common/PS_fld_mark_10f_1.PS_fld_mark_10f_1'"
	self.TouchDownTime = 0
end

function SignsMainSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SignsMainSlotView:OnInit()
	self.Binders = {
		{"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
		{"IsUsed", UIBinderSetIsVisible.New(self, self.ImgUse)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
	}
end

function SignsMainSlotView:OnDestroy()

end

function SignsMainSlotView:OnShow()

end

function SignsMainSlotView:OnHide()

end

function SignsMainSlotView:OnRegisterUIEvent()

end

function SignsMainSlotView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamSignsSelectedCancle, self.OnCancleSelected)
	self:RegisterGameEvent(_G.EventID.TeamTargetMarkBtnUseStateChanged, self.OnUsedStateChanged)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
	self:RegisterGameEvent(_G.EventID.TeamSceneMarkPosChangedEvent, self.TeamSceneMarkPosChanged)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseMove, self.OnPreprocessedMouseMove)
	self:RegisterGameEvent(EventID.NetStateUpdate,self.OnCombatStateUpdate)
end

function SignsMainSlotView:OnCombatStateUpdate(Params)
	if MajorUtil.IsMajor(Params.ULongParam1) and Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT then
		if self.TempEffectActor ~= nil then
			--进入战斗时如果标记还没有确定旋转则取消放置
			_G.CommonUtil.DestroyActor(self.TempEffectActor)
			self.TempEffectActor = nil
		end
	end
end

function SignsMainSlotView:OnUsedStateChanged(Index)
	if Index == 0 and self.ViewModel.IsUsed then
		self.ViewModel:SetIsUsed(false)
	end
	if self.ViewModel.ID == Index then
		self.ViewModel:SetIsUsed(true)
	end
end

function SignsMainSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function SignsMainSlotView:OnCancleSelected()
	if self.ViewModel.IsSelected then
		self.ViewModel.IsSelected = false
	end
end

function SignsMainSlotView:OnTouchStarted(InGeometry, InTouchEvent)
	FLOG_WARNING("TouchStart")

	if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.SceneMarkersMainPanel) then
		return
	end
	local DoubleClick = false

	if TimeUtil.GetServerTimeMS() - self.TouchDownTime <= 300 then
		DoubleClick = true
		self.TouchDownTime = 0
	else
		self.TouchDownTime = TimeUtil.GetServerTimeMS()
	end

	if DoubleClick then
		FLOG_WARNING("DoubleClick")
		self:OnDoubleClickButtonItem()
		return _G.UE.UWidgetBlueprintLibrary.Handled()
	end

	self.PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	self.TouchDown = true
	-- self.ImgSelect:SetVisibility(_G.UE.ESlateVisibility.Visible)
	_G.UE.ClickFeedbackInteraction.Get():EnableSendMoveEvent(true)

	return _G.UE.UWidgetBlueprintLibrary.Handled()
end

function SignsMainSlotView:ConfirmActorMoveLocation(Res)
	if Res then
		FLOG_WARNING("ConfirmActorMoveLocation")
		local Pos = self.TempEffectActor:GetWorldLocation()
		SignsMgr:AddSceneMarkEffect(self.ViewModel.ID, self.TempEffectActor,Pos)
		self.TempEffectActor = nil

		local Params = {}
		Params.Index = self.ViewModel.ID
		Params.Position = {X = Pos.X, Y = Pos.Y, Z = Pos.Z}
		_G.EventMgr:SendEvent(_G.EventID.TeamSceneMarkConfirmEvent, Params)
	else
		_G.MsgTipsUtil.ShowTips(LSTR(1240053))
	---失败了，当前位置不可放置
		if self.TempEffectActor then
			_G.CommonUtil.DestroyActor(self.TempEffectActor)
			self.TempEffectActor = nil
		end
	end
end

function SignsMainSlotView:OnMouseLeave(InTouchEvent)
	if self.TouchDown then
		FLOG_WARNING("MouseLeave")
		local AbsMousePos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
		local PlayerController = _G.GameplayStaticsUtil.GetPlayerController()
		local ScreenPos = _G.UE.FVector2D(AbsMousePos.X, AbsMousePos.Y)
		local WorldPosition = _G.UE.FVector()
		local WorldDirection = _G.UE.FVector()
		local LocalMousePos, ViewportMousePos = UIUtil.AbsoluteToViewport(AbsMousePos)
		_G.UE.UGameplayStatics.DeprojectScreenToWorld(PlayerController, LocalMousePos, WorldPosition, WorldDirection)

		if self.TempEffectActor == nil then
			local ModelClass = SignsMgr:CreateEffect()

			if not ModelClass then
				return _G.UE.UWidgetBlueprintLibrary.Handled()
			end

			self.TempEffectActor = _G.CommonUtil.SpawnActor(ModelClass, WorldPosition)
			self.TempEffectActor:SetEffect(self.ViewModel.ResPath)
			self.TempEffectActor:SetParent(self)
		end

		local Params = {}
		Params.BoolParam1 = true

		_G.EventMgr:SendEvent(_G.EventID.TeamSceneMarkMoveEvent, Params)
	end
end

function SignsMainSlotView:OnPreprocessedMouseMove(InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	if self.TouchDown == true and self.PointerIndex == PointerIndex and self.TempEffectActor ~= nil then
		local AbsMousePos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
		local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
		local CurPos = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, AbsMousePos)
		local LocalMousePos, ViewportMousePos = UIUtil.AbsoluteToViewport(AbsMousePos)

		self.TempEffectActor:OnMoving(LocalMousePos,_G.SignsMgr:GetIgnoreActors())

		--要把加入到GestureMgr中的touch干掉
		--if CommonUtil.GetPlatformName() == "IOS" then
			GestureMgr:Get():RemoveDataMapForLua(PointerIndex)
		--end
	end
end

function SignsMainSlotView:OnPreprocessedMouseButtonUp(InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	if self.TouchDown and self.PointerIndex == PointerIndex and self.TempEffectActor ~= nil then
		FLOG_WARNING("TouchEnd")
		self.TempEffectActor:SetInitFlag()
		self.TempEffectActor:OnMoveEnd(_G.SignsMgr:GetIgnoreActors())
		_G.UE.ClickFeedbackInteraction.Get():EnableSendMoveEvent(false)
		self.ImgSelect:SetVisibility(_G.UE.ESlateVisibility.Collapsed)

		local Params = {}
		Params.BoolParam1 = false
		_G.EventMgr:SendEvent(_G.EventID.TeamSceneMarkMoveEvent, Params)
	end

	if self.PointerIndex == PointerIndex then
		self.TouchDown = false
		self.PointerIndex = -1
	end
end

function SignsMainSlotView:OnDoubleClickButtonItem(InGeometry, InTouchEvent)
	local Major = MajorUtil.GetMajor()

	self.ImgSelect:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
	if not Major then
		return
	end

	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	SignsMgr:RemoveSceneMarkEffect(self.ViewModel.ID)
	SignsMgr:OnTeamSceneMarkAdd({Index = self.ViewModel.ID, Pos = {X = MajorPos.X, Y = MajorPos.Y, Z = MajorPos.Z} })

	local Params = {}
	Params.Index = self.ViewModel.ID
	Params.Position = {X = MajorPos.X, Y = MajorPos.Y, Z = MajorPos.Z}
	_G.EventMgr:SendEvent(_G.EventID.TeamSceneMarkConfirmEvent, Params)
end

function SignsMainSlotView:TeamSceneMarkPosChanged(param)
	if self.ViewModel.ID == param.Index then
		local WorldPosition = _G.UE.FVector()
		WorldPosition.X = param.Pos.X
		WorldPosition.Y = param.Pos.Y
		WorldPosition.Z = param.Pos.Z
		SignsMgr:SetEffectPosition(self.ViewModel.ID, WorldPosition)
	end
end

function SignsMainSlotView:GetID()
	return self.ViewModel.ID
end

return SignsMainSlotView