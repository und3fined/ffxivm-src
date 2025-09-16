---
--- Author: chaooren
--- DateTime: 2022-02-28 19:47
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MainSkillBaseView = require("Game/MainSkillBtn/MainSkillBaseView")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local EventID = require("Define/EventID")
local EventMgr = _G.EventMgr
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ESlateVisibility = _G.UE.ESlateVisibility
local KIL = _G.UE.UKismetInputLibrary
local WBL = _G.UE.UWidgetBlueprintLibrary
local SBL = _G.UE.USlateBlueprintLibrary
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local SkillCustomMgr = require("Game/Skill/SkillCustomMgr")
local SkillUtil = require("Utils/SkillUtil")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local ObjectGCType = require("Define/ObjectGCType")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local MsgTipsID = require("Define/MsgTipsID")

local RoleInitCfg = require("TableCfg/RoleInitCfg")

local MinMoveDistSquared = 200	--拖拽视为移动时的最小判定

---@class SkillAbleBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Charge_CD URadialImage
---@field CommonRedDot CommonRedDotView
---@field EFF_ADD_Inst_25 UFImage
---@field EFF_Circle_012 UFImage
---@field FCanvasPanel_59 UFCanvasPanel
---@field FImg_CDNormal UFImage
---@field IconSkillReplace UFImage
---@field IconSkillReplaceBtn UFButton
---@field Icon_Skill UFImage
---@field ImgAll UFImage
---@field ImgChargeBase UFImage
---@field ImgLock UFImage
---@field ImgMultiSelect UFImage
---@field Img_CD URadialImage
---@field MultiChoiceSlot UFCanvasPanel
---@field PanelAll UFCanvasPanel
---@field PanelConsume UFCanvasPanel
---@field PanelTaskGuide UFCanvasPanel
---@field QueueSkill UFCanvasPanel
---@field SecondJoyStick SecondJoyStickView
---@field TagRechargeCD UFCanvasPanel
---@field TextNum UFTextBlock
---@field TextQuantity UFTextBlock
---@field Text_RechargeTimes UFTextBlock
---@field Text_SkillCD UFTextBlock
---@field AnimAlternate UWidgetAnimation
---@field AnimCDFinish UWidgetAnimation
---@field AnimChange UWidgetAnimation
---@field AnimChangeIn UWidgetAnimation
---@field AnimChangeOut UWidgetAnimation
---@field AnimClick UWidgetAnimation
---@field AnimSelectedIn UWidgetAnimation
---@field AnimSelectedOut UWidgetAnimation
---@field AnimSkillCharge UWidgetAnimation
---@field AnimSkillChargeLoop UWidgetAnimation
---@field AnimSkillChargeStop UWidgetAnimation
---@field AnimSkillChargeStopRelease UWidgetAnimation
---@field AnimSkillChoiceIn UWidgetAnimation
---@field AnimSkillChoiceOut UWidgetAnimation
---@field AnimSkillLimitLoop UWidgetAnimation
---@field AnimSkillLimitStop UWidgetAnimation
---@field AnimSkillUnlock UWidgetAnimation
---@field AnimSkillUnlockMulti UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillAbleBtnView = LuaClass(MainSkillBaseView, true)

function SkillAbleBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Charge_CD = nil
	--self.CommonRedDot = nil
	--self.EFF_ADD_Inst_25 = nil
	--self.EFF_Circle_012 = nil
	--self.FCanvasPanel_59 = nil
	--self.FImg_CDNormal = nil
	--self.IconSkillReplace = nil
	--self.IconSkillReplaceBtn = nil
	--self.Icon_Skill = nil
	--self.ImgAll = nil
	--self.ImgChargeBase = nil
	--self.ImgLock = nil
	--self.ImgMultiSelect = nil
	--self.Img_CD = nil
	--self.MultiChoiceSlot = nil
	--self.PanelAll = nil
	--self.PanelConsume = nil
	--self.PanelTaskGuide = nil
	--self.QueueSkill = nil
	--self.SecondJoyStick = nil
	--self.TagRechargeCD = nil
	--self.TextNum = nil
	--self.TextQuantity = nil
	--self.Text_RechargeTimes = nil
	--self.Text_SkillCD = nil
	--self.AnimAlternate = nil
	--self.AnimCDFinish = nil
	--self.AnimChange = nil
	--self.AnimChangeIn = nil
	--self.AnimChangeOut = nil
	--self.AnimClick = nil
	--self.AnimSelectedIn = nil
	--self.AnimSelectedOut = nil
	--self.AnimSkillCharge = nil
	--self.AnimSkillChargeLoop = nil
	--self.AnimSkillChargeStop = nil
	--self.AnimSkillChargeStopRelease = nil
	--self.AnimSkillChoiceIn = nil
	--self.AnimSkillChoiceOut = nil
	--self.AnimSkillLimitLoop = nil
	--self.AnimSkillLimitStop = nil
	--self.AnimSkillUnlock = nil
	--self.AnimSkillUnlockMulti = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.bAbleBtn = true
end

function SkillAbleBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.SecondJoyStick)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
	for _, value in ipairs(self.SubViews) do
		value.EntityID = self.EntityID
		value.bMajor = self.bMajor
	end
end

function SkillAbleBtnView:OnInit()
	self.Super:OnInit()
	self.OriginalButtonIndex = self.ButtonIndex
	self.MultiChoicePanel = nil
	self.MultiChoiceCount = 0
	self.bCurSelectSkill = false
	self.bPreSelectSkill = false

	self.HasReChargeConfig = true

	self.SimulateReplaceTimer = 0
	self.bSelected = false

	self.bChargeSkill = false	--是否为充能技能(最大充能次数不超过1也是为非充能技能)

	if self.ButtonIndex >= SkillCommonDefine.SkillButtonIndexRange.Multi_Start and self.ButtonIndex <= SkillCommonDefine.SkillButtonIndexRange.Multi_End then
		self.Binders = {
			{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill)},
			{"SkillCDText", UIBinderSetText.New(self, self.Text_SkillCD)},
			{"ImgLockIcon", UIBinderValueChangedCallback.New(self, nil, self.OnImgLockIconChange) },
			{"NormalCDPercent", UIBinderSetPercent.New(self, self.Img_CD) },
			{"bNormalCD", UIBinderSetIsVisible.New(self, self.Img_CD)},
			{"bCommonMask", UIBinderSetIsVisible.New(self, self.FImg_CDNormal)},
			{"SkillCostText", UIBinderSetText.New(self, self.TextNum) },
			{"SkillCostColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNum) },
			{"bSkillCost", UIBinderSetIsVisible.New(self, self.PanelConsume)},
		}
	else
		self.Binders = {
			{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill)},
			{"ImgLockIcon", UIBinderValueChangedCallback.New(self, nil, self.OnImgLockIconChange) },
			{"bChargeProcessVisible", UIBinderSetIsVisible.New(self, self.ImgChargeBase)},
			{"bChargeProcessVisible", UIBinderSetIsVisible.New(self, self.Charge_CD)},
			{"bTextRechargeTimes", UIBinderSetIsVisible.New(self, self.Text_RechargeTimes)},
			{"bAnimSkillLimitLoop", UIBinderIsLoopAnimPlay.New(self, nil,self.AnimSkillLimitLoop) },
			{"RechargeTimesColorAndOpacity", UIBinderSetColorAndOpacity.New(self, self.Text_RechargeTimes) },
			{"SkillCDText", UIBinderSetText.New(self, self.Text_SkillCD)},
			{"RechargeTimeText", UIBinderSetText.New(self, self.Text_RechargeTimes)},
			{"ChargeCDPercent", UIBinderSetPercent.New(self, self.Charge_CD) },
			{"NormalCDPercent", UIBinderSetPercent.New(self, self.Img_CD) },
			{"bNormalCD", UIBinderSetIsVisible.New(self, self.Img_CD)},
			{"bCommonMask", UIBinderSetIsVisible.New(self, self.FImg_CDNormal)},
			{"SkillCostText", UIBinderSetText.New(self, self.TextNum) },
			{"SkillCostColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNum) },
			{"bSkillCost", UIBinderSetIsVisible.New(self, self.PanelConsume)},
		}
	end

	self.IsForceImmediatelyHide = true

	self.SecondCancelParams = {OnMoveCallbackPtr = self, OnMoveCallback = self.OnMultiChoiceCancelJSMoveCB, bInvalidateWhenEnter = true}
	self.DragSecondCancelParams = {OnMoveCallbackPtr = self.SecondJoyStick, OnMoveCallback = self.SecondJoyStick.OnCancelJSMoveCB, bInvalidateWhenEnter = true}
end

function SkillAbleBtnView:OnDestroy()
	if self.MultiChoicePanel then
		UIViewMgr:RecycleView(self.MultiChoicePanel)
		self.MultiChoiceSlot:ClearChildren()
		self.MultiChoicePanel = nil
	end

	rawset(self, "ButtonIndex", nil)
	self.Super:OnDestroy()
end

function SkillAbleBtnView:DoCustomIndexReplace(CustomIndexMap)
	local bMajor = self.bMajor
	if bMajor == nil then
		return
	end
	local _ <close> = CommonUtil.MakeProfileTag("SkillAbleBtnView:DoCustomIndexReplace")
	local OriginalButtonIndex = self.OriginalButtonIndex

	local ReplacedButtonIndex
	if CustomIndexMap then
		ReplacedButtonIndex = CustomIndexMap[OriginalButtonIndex] or OriginalButtonIndex
	else
		ReplacedButtonIndex = SkillCustomMgr:GetCustomIndex(OriginalButtonIndex, bMajor)
	end

	if self.ButtonIndex ~= ReplacedButtonIndex then
		-- 直接用ParentView调用, 比SendEvent速度快
		local ParentView = self.ParentView
		local OnButtonIndexChanged = ParentView and ParentView.OnButtonIndexChanged
		if OnButtonIndexChanged then
			OnButtonIndexChanged(ParentView, self.ButtonIndex, ReplacedButtonIndex, self)
		end

		-- ButtonIndex在蓝图里面, 这里设置Lua侧Table的Index
		-- 不直接改蓝图的ButtonIndex, 防止蓝图回收后再Init, 蓝图里面的ButtonIndex不是初始值
		rawset(self, "ButtonIndex", ReplacedButtonIndex)
	end
end

function SkillAbleBtnView:OnShow()
	self.Super:OnShow()
	if not self.bMajor then
		_G.SkillSystemMgr:RegisterSkillButtonRedDotWidget(self.ButtonIndex, self.BtnSkillID, self.CommonRedDot)
	end
end

function SkillAbleBtnView:OnHide()
	self.Super:OnHide()

	--关闭后解锁动画不能继续播放
	self:StopSkillUnlockAnimation()

	self:CancelPressStatus()
end

function SkillAbleBtnView:OnRegisterUIEvent()
	if not self.bMajor then
		UIUtil.AddOnClickedEvent(self, self.IconSkillReplaceBtn, self.IconSkillReplaceClicked)
	end
end

function SkillAbleBtnView:OnRegisterGameEvent()
	local _ <close> = CommonUtil.MakeProfileTag("SkillAbleBtnView:OnRegisterGameEvent")
	self.Super:OnRegisterGameEvent()

	local RegisterGameEventFunc = self.RegisterGameEvent

	if not self.bMajor then
		RegisterGameEventFunc(self, EventID.PlayerPrepareCastSkill, self.OnPlayerPrepareCastSkill)
		RegisterGameEventFunc(self, EventID.SkillSystemClickBlank, self.OnSkillSystemClickBlank)
	else
		RegisterGameEventFunc(self, EventID.SkillChargeUpdateLua, self.OnSkillChargeUpdate)
		RegisterGameEventFunc(self, EventID.SkillMaxChargeCountChange, self.OnSkillMaxChargeCountChange)
		RegisterGameEventFunc(self, EventID.SkillMedicineCDUpdate, self.OnSkillMedicineCDUpdate)
		RegisterGameEventFunc(self, EventID.BagManualSetMedicine, self.OnBagManualSetMedicine)
		RegisterGameEventFunc(self, EventID.PlaySkillUnLockEffect, self.OnPlaySkillUnLockEffect)
		RegisterGameEventFunc(self, EventID.SkillAssetAttrUpdate, self.OnSkillAssetAttrUpdate)
		RegisterGameEventFunc(self, EventID.MajorDead, self.OnGameEventMajorDead)
	end

	if not self:CanParentPanelRouteEvent() then
		RegisterGameEventFunc(self, EventID.StorageStart, self.StartStorageAnim)
		RegisterGameEventFunc(self, EventID.StorageEnd, self.StopStorageAnim)

		RegisterGameEventFunc(self, EventID.SkillGuideStart, self.StartStorageAnim)
		RegisterGameEventFunc(self, EventID.SkillGuideEnd, self.StopStorageAnim)
	end
	local ParentView = rawget(self, "ParentView")
	if ParentView and rawget(ParentView, "bMainMountPanel") then
		RegisterGameEventFunc(self, EventID.OnShowMountPanel, self.OnShowMountPanelEvent)
	end
end

function SkillAbleBtnView:OnRegisterBinder()
	local _ <close> = CommonUtil.MakeProfileTag("SkillAbleBtnView:OnRegisterBinder")
	self:RegisterBinders(self.BaseBtnVM, self.Binders)
end

function SkillAbleBtnView:CancelPressStatus()
	if self.CanPressSelectSkill then
		self.SkillMultiChoiceDisplay:ViewHide()
		self.MultiChoicePanel:OnMultiChoiceFinish()
		self.CanPressSelectSkill = false
	else
		UIUtil.SetIsVisible(self.SecondJoyStick, false)
	end
	if self.SkillCancelJoyStickTask then
		_G.UIAsyncTaskMgr:HideViewAsync(UIViewID.SkillCancelJoyStick, true)
		self.SkillCancelJoyStickTask = nil
	end

	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData then
		LogicData:SetSkillPressFlag(self.ButtonIndex, false)
	end
end

local MedicineSkill = 2061
function SkillAbleBtnView:OnSkillMedicineCDUpdate(EndFreezeTime, FreezeCD)
	if self.bCurSelectSkill and self.MultiChoicePanel then
		for index, value in ipairs(self.SelectIdList) do
			if value.ID == MedicineSkill then
				self.MultiChoicePanel:OnUpdateSelectCD(index, EndFreezeTime / FreezeCD)
			end
		end
	end
end

function SkillAbleBtnView:OnBagManualSetMedicine(ProfID, _)
	if ProfID == MajorUtil.GetMajorProfID() then
		--reset cd
		self:OnSkillMedicineCDUpdate(0, 1)
	end
end

function SkillAbleBtnView:OnShowMountPanelEvent(Params)
	local bIsShowMountPanel = Params.bIsShowMountPanel
	if not bIsShowMountPanel then
		self:OnHide()
	end
end

function SkillAbleBtnView:UnRegisterAsyncTask()
	self.Super:UnRegisterAsyncTask()
	local UseSkillEventTaskID = rawget(self, "UseSkillEventTaskID")
	if UseSkillEventTaskID then
		_G.UIAsyncTaskMgr:UnRegisterTask(UseSkillEventTaskID)
		rawset(self, "UseSkillEventTaskID", nil)
	end
end

function SkillAbleBtnView:ClearAllTask()
	self:UnRegisterAsyncTask()
	self:StopLongClickTimer()
end

function SkillAbleBtnView:OnGameEventMajorUseSkill(Params)
	_G.UIAsyncTaskMgr:UnRegisterTask(rawget(self, "UseSkillEventTaskID"))
	local co = coroutine.create(self.OnGameEventMajorUseSkillAsync)
	local UseSkillEventTaskID = _G.UIAsyncTaskMgr:RegisterTask(co, self, Params.IntParam1)
	rawset(self, "UseSkillEventTaskID", UseSkillEventTaskID)
end

function SkillAbleBtnView:OnGameEventMajorUseSkillAsync(Params)
	local IsSing = SkillMainCfg:FindValue(Params, "IsSing")

	--多选一技能不播点击动效，和选中效果资产冲突
	if IsSing == 0 and SkillCommonDefine.GetButtonIndexType(self.ButtonIndex) ~= SkillCommonDefine.SkillButtonIndexType.MultiSkill then
		self:PlayAnimationToEndTime(self.AnimClick)
	end
	rawset(self, "UseSkillEventTaskID", nil)
end

function SkillAbleBtnView:PlayerClearButtonState()
	self:PlayerClearSimulateReplace()
	if self.bSelected then
		if self:IsAnimationPlaying(self.AnimSelectedIn) == true then
			self:StopAnimation(self.AnimSelectedIn)
		end
		self:PlayAnimation(self.AnimSelectedOut)
		self:BreakStorageAnim()
		self.bSelected = false
	end

	if self.bCurSelectSkill and self.MultiChoicePanel then
		self.MultiChoicePanel:ClearSelectedEffect()
	end
end

function SkillAbleBtnView:PlayerClearSimulateReplace()
	if self.bDisplaySimulateReplace then
		self.bDisplaySimulateReplace = false
		self:StopAnimation(self.AnimChangeIn)
		self:StopAnimation(self.AnimChange)
		if self.SimulateReplaceTimer > 0 then
			self:UnRegisterTimer(self.SimulateReplaceTimer)
			self.SimulateReplaceTimer = 0
		end
		self:PlayAnimationToEndTime(self.AnimChangeOut)
		EventMgr:SendEvent(EventID.SkillSystemReplaceChange, {
			OriginalButtonIndex = self.OriginalButtonIndex,
			ButtonIndex = self.ButtonIndex,
			bShow = false
		})
	end
end

function SkillAbleBtnView:OnPlayerPrepareCastSkill(Params)
	if Params.Index ~= self.ButtonIndex and
	   self.EntityID == Params.EntityID and
	   not self.CanPressSelectSkill then
		self:PlayerClearButtonState()
	end
end

function SkillAbleBtnView:OnSkillSystemClickBlank()
	self:PlayerClearButtonState()
end

function SkillAbleBtnView:OnPlayerUseSkill(Params)
	if Params.Index == self.ButtonIndex and SkillCommonDefine.GetButtonIndexType(self.ButtonIndex) ~= SkillCommonDefine.SkillButtonIndexType.MultiSkill then
		self:PlayAnimation(self.AnimSelectedIn)
		self.bSelected = true
	end
	if not self.bDisplaySimulateReplace then
		-- LuaClass bug, 这里强制恢复一下__Current
		self.__Current = self.__BaseType
		self.Super:OnPlayerUseSkill(Params)
	end

	-- 位置同步在SkillStart, 对于需要先吟唱的技能时机比较晚, 这里预先同步下
	if Params.bShouldSing then
		_G.SkillSystemMgr:SyncPlayerTransform(Params.SkillID)
	end
end

function SkillAbleBtnView:OnMultiChoiceCancelJSMoveCB(OldStatus, NewStatus)
	if OldStatus ~= NewStatus then
		self.SkillMultiChoiceDisplay:OnSelectedCancelChange(NewStatus)
		self.MultiChoicePanel:OnSelectedCancelChange(NewStatus)
	end
end

function SkillAbleBtnView:MainSkillButtonDown(MyGeometry, MouseEvent)
	local Handled = WBL.Handled()
	local _ <close> = CommonUtil.MakeProfileTag("SkillAbleBtnView:MainSkillButtonDown")
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData == nil or not LogicData:CanCastSkill(self.ButtonIndex, true) then
		return WBL.ReleaseMouseCapture(Handled)
	end
	LogicData:SetSkillPressFlag(self.ButtonIndex, true)
	local SelectIdList = self.SelectIdList
	self.CanPressSelectSkill = true

	if self.CanPressSelectSkill then
		self.SkillMultiChoiceDisplay:ViewShow({SelectIdList = SelectIdList, BaseSkillIndex = self.ButtonIndex, MultiChoiceCount = self.MultiChoiceCount})

		self.SkillCancelJoyStickTask = _G.UIAsyncTaskMgr:ShowViewAsync(UIViewID.SkillCancelJoyStick, self.SecondCancelParams)

		self.MultiChoicePanel:SetBkgVisibility(true)
		local MousePosition = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
		local Geometry = self.FCanvasPanel_59:GetCachedGeometry()
		local _, BasePos = _G.UE.USlateBlueprintLibrary.LocalToViewport(self, Geometry, _G.UE.FVector2D(0,0))
		local BaseSize = UIUtil.CanvasSlotGetSize(self.FCanvasPanel_59)

		local WidgetCenter = BaseSize * 0.5 + BasePos

		local SelectIndex = self.MultiChoicePanel:GetHoverButtonIndex(MousePosition, true, WidgetCenter)
		self.SkillMultiChoiceDisplay:OnHoverSkillSelect(SelectIndex)
	end
	return WBL.CaptureMouse(Handled, self)
end

function SkillAbleBtnView:MainSkillButtonMouseMove(MyGeometry, MouseEvent)
	if self.CanPressSelectSkill then
		local MousePosition = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
		local SelectIndex = self.MultiChoicePanel:GetHoverButtonIndex(MousePosition, false)
		self.SkillMultiChoiceDisplay:OnHoverSkillSelect(SelectIndex)
	end

	local CancelJoyStickView = UIViewMgr:FindView(UIViewID.SkillCancelJoyStick)
	if CancelJoyStickView then
		CancelJoyStickView:RouteMouseMove(MyGeometry, MouseEvent)
	end
	return true
end

function SkillAbleBtnView:MainSkillButtonUp(MyGeometry, MouseEvent)
	local Handled = WBL.Handled()
	local _ <close> = CommonUtil.MakeProfileTag("SkillAbleBtnView:MainSkillButtonUp")
	if self.bMajor then
		EventMgr:SendEvent(EventID.SkillBtnClick, {BtnIndex = self.ButtonIndex, SkillID = self.BtnSkillID})
	end

	if not self.CanPressSelectSkill then
		return WBL.ReleaseMouseCapture(Handled)
	end
	local SelectIndex = self.SkillMultiChoiceDisplay:DoMultiChoiceCastSkill()
	self.SkillMultiChoiceDisplay:ViewHide()
	self.MultiChoicePanel:OnMultiChoiceFinish(SelectIndex)
	self.CanPressSelectSkill = false
	_G.UIAsyncTaskMgr:HideViewAsync(UIViewID.SkillCancelJoyStick, true)
	self.SkillCancelJoyStickTask = nil

	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	LogicData:SetSkillPressFlag(self.ButtonIndex, false)
	return WBL.ReleaseMouseCapture(Handled)
end

function SkillAbleBtnView:SetSkillLearnLock(SkillLearnedStatus, LockLevel)
	if self.bMajor == true then
		local bLearned = SkillLearnedStatus == SkillUtil.SkillLearnStatus.Learned
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)

		local LockIcon = nil
		if SkillLearnedStatus == SkillUtil.SkillLearnStatus.UnLockLevel then
			LockIcon = SkillCommonDefine.DefaultLockIcon
		elseif SkillLearnedStatus == SkillUtil.SkillLearnStatus.UnLockAdvancedProf then
			LockIcon = RoleInitCfg:FindRoleInitProfIconSimple4(LogicData:GetProfID())
		end

		self.BaseBtnVM.ImgLockIcon = LockIcon
		
		if LogicData ~= nil then
			LogicData:SetSkillButtonState(self.ButtonIndex, SkillBtnState.SkillLearn, bLearned)
		end
	end
end

function SkillAbleBtnView:StopSkillUnlockAnimation(IsSkillMultiChoice)
	if not self.bMajor then
		return
	end

	if IsSkillMultiChoice then
		self:StopAnimation(self.AnimSkillUnlockMulti)
	else
		self:StopAnimation(self.AnimSkillUnlock)
	end
	self.BaseBtnVM:PropertyValueChanged("bCommonMask")
	self.BaseBtnVM:PropertyValueChanged("ImgLockIcon")
end

--播放技能解锁动效
function SkillAbleBtnView:PlaySkillUnlockAnimation(Params)
	 --显示1s播放技能解锁动效
	if Params.SkillMultiChoice then
		self:RegisterTimer(function()
		self:PlayAnimation(self.AnimSkillUnlockMulti)
	 	end, 0.3)
	else
		self:RegisterTimer(function()
		self:PlayAnimation(self.AnimSkillUnlock)
	 	end, 1.0)
	end
	--动画结束判断按钮是否可用以显示遮罩
	if Params.SetCommonMaskTime then
		self:RegisterTimer(function()
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		local InValidCount = LogicData:GetButtonIndexState(self.ButtonIndex)
		--目前打开其他UI不会调用onhide方法了，动画将会在关闭其他UI后继续播放导致按钮表现错误
		if (self.bPreSelectSkill == nil or self.bPreSelectSkill == false) and InValidCount > 0 then
			self:StopAnimation(self.AnimSkillUnlock)
			self.BaseBtnVM:PropertyValueChanged("ImgLockIcon")
		end
		--动画结束表现与VM中的值不同，强制更新UI，
		self.BaseBtnVM:PropertyValueChanged("bCommonMask")
	 	end, Params.SetCommonMaskTime)
	end
end

--判断是否二级技能是否在解锁的列表中
function SkillAbleBtnView:IsMutiChoiceSelectSkillUnLock(SkillID)
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData then
		for index, value in pairs(LogicData.NotFirstSkillUnlockList) do
			if value.SkillID == SkillID then
				table.remove(LogicData.NotFirstSkillUnlockList, index)
				return true
			end
		end
	end
	return false
end

function SkillAbleBtnView:OnMultiChoiceSelectChanged(bSelect)
	if bSelect then
		self.EFF_Circle_012:SetRenderOpacity(1)
	else
		self.EFF_Circle_012:SetRenderOpacity(0)
	end
end

function SkillAbleBtnView:OnMultiChoiceCancelChanged(bCancel, Color)
	UIUtil.ImageSetColorAndOpacityHex(self.EFF_Circle_012, Color)
end

function SkillAbleBtnView:bSupportSecondJoyStick()
	return true
end

function SkillAbleBtnView:DoDragSkillStart(_, MouseEvent)
	local _ <close> = CommonUtil.MakeProfileTag("SkillAbleBtnView:DoDragSkillStart")
	local SubSkillID = SkillUtil.MainSkill2SubSkill(self.BtnSkillID)
	self.DragStartPos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	UIUtil.SetIsVisible(self.SecondJoyStick, true)
	self.SkillCancelJoyStickTask = _G.UIAsyncTaskMgr:ShowViewAsync(UIViewID.SkillCancelJoyStick, self.DragSecondCancelParams)
	if self.IsLimitSkill then
		_G.EventMgr:SendEvent(EventID.DragSkillBegin)
	end
	self.SecondJoyStick:InitSkillData(self.BtnSkillID, SubSkillID)
end

function SkillAbleBtnView:DoDragSkillMove(MyGeometry, MouseEvent)
	local CurPos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if self.bFirstMove == false then
		local DistSquared = _G.UE.FVector2D.DistSquared(self.DragStartPos, CurPos)
		if DistSquared > MinMoveDistSquared then
			self.bFirstMove = true
			self.SecondJoyStick:InitGeometryData()
			self.SecondJoyStick:OnJoyStickMove(CurPos)
		end
	else
		self.SecondJoyStick:OnJoyStickMove(CurPos)
	end
	local CancelJoyStickView = UIViewMgr:FindView(UIViewID.SkillCancelJoyStick)
	if CancelJoyStickView then
		CancelJoyStickView:RouteMouseMove(MyGeometry, MouseEvent)
	end
end

function SkillAbleBtnView:DoDragSkillEnd()
	local CancelJoyStickView = UIViewMgr:FindView(UIViewID.SkillCancelJoyStick)
	local bCancelEnter = CancelJoyStickView and CancelJoyStickView:GetCancelStatus() or false
	if bCancelEnter == false then
		local JoystickValid = self.SecondJoyStick:IsJoystickValid()
		local DecalState = self.SecondJoyStick:GetDecalState()
		if JoystickValid == true and DecalState == true then
			self:OnCastSkill({Position = self.SecondJoyStick:GetAbsolutePosition(), Angle = self.SecondJoyStick:GetAbsoluteAngle()})
		elseif JoystickValid == true then
			_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillCannotSeeTarget)--"看不见目标"
		else
			self:OnCastSkill()
		end
	else
		if self.bSwitchPanel == true then
			EventMgr:SendEvent(EventID.SkillBtnClick, {BtnIndex = self.ButtonIndex, SkillID = self.BtnSkillID})
		end
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		if LogicData then
			LogicData:SetSkillPressFlag(self.ButtonIndex, false)
		end
	end
	UIUtil.SetIsVisible(self.SecondJoyStick, false)
	_G.UIAsyncTaskMgr:HideViewAsync(UIViewID.SkillCancelJoyStick, true)
	self.SkillCancelJoyStickTask = nil
	if self.IsLimitSkill then
		_G.EventMgr:SendEvent(EventID.DragSkillEnd)
	end
end
--------------------------------蓄力表现------------------------------------------
function SkillAbleBtnView:bSupportStorageSkill()
	return true
end

function SkillAbleBtnView:StartStorageAnim(Params)
	if Params.EntityID == self.EntityID and Params.Index == self.ButtonIndex then
		local FadeAnimTime = self.AnimSkillCharge:GetEndTime() * 1000
		local PlayRate = FadeAnimTime / Params.MaxTime
		self:PlayAnimation(self.AnimSkillCharge, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlayRate, true)
		self:PlayAnimation(self.AnimSkillChargeLoop, 0, 0, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
	end
end

function SkillAbleBtnView:BreakStorageAnim()
	self:StopAnimation(self.AnimSkillCharge)
	self:StopAnimation(self.AnimSkillChargeLoop)
	self:PlayAnimation(self.AnimSkillChargeStop)
end

function SkillAbleBtnView:StopStorageAnim(Params)
	if Params.EntityID == self.EntityID and Params.Index == self.ButtonIndex then
		self:StopAnimation(self.AnimSkillCharge)
		self:StopAnimation(self.AnimSkillChargeLoop)
		if Params.EndResult == true then
			self:PlayAnimationToEndTime(self.AnimSkillChargeStopRelease)
		else
			self:PlayAnimation(self.AnimSkillChargeStop)
		end
	end
end
--------------------------------蓄力表现END-------------------------------------------------------

--------------------------------技能替换-------------------------------------------------------
------------演示技能模拟替换----------------
function SkillAbleBtnView:bSupportSimulateReplace()
	local ButtonType = SkillCommonDefine.GetButtonIndexType(self.ButtonIndex)
	local ESkillButtonIndexType = SkillCommonDefine.SkillButtonIndexType
	if not self.bMajor
		and #_G.SkillLogicMgr:GetPlayerSeriesList(self.EntityID, self.ButtonIndex) > 0
		and (ButtonType == ESkillButtonIndexType.Able) then
		return true
	end
	return false
end

local PlayerSimulateReplaceAngle = {
	[1] = 0,
	[2] = 25,
	[3] = 50,
	[4] = 75,
	[5] = 90,
	[8] = 25,
	[9] = 25,
	[11] = 25,
}

function SkillAbleBtnView:DoSimulateReplace()
	if not self.bDisplaySimulateReplace then
		return
	end
	local Angle = PlayerSimulateReplaceAngle[self.OriginalButtonIndex] or 0
	self.QueueSkill:SetRenderTransformAngle(Angle)
	self.IconSkillReplace:SetRenderTransformAngle(-Angle)
	self.IconSkillReplaceBtn:SetRenderTransformAngle(-Angle)
	self:PlayAnimationToEndTime(self.AnimChangeIn)
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData then
		local NextSkillID = LogicData:GetPlayerSeriesNext(self.BtnSkillID, self.ButtonIndex)
		SkillUtil.ChangeSkillIcon(NextSkillID, self.IconSkillReplace)
	end
	EventMgr:SendEvent(EventID.SkillSystemReplaceChange, {
		OriginalButtonIndex = self.OriginalButtonIndex,
		ButtonIndex = self.ButtonIndex,
		bShow = true
	})
end

function SkillAbleBtnView:IconSkillReplaceClicked()
	if _G.SkillSystemMgr.PressedButtonIndex then
		return
	end

	if self.SimulateReplaceTimer > 0 then
		self:StopAnimation(self.AnimChange)
		self:UnRegisterTimer(self.SimulateReplaceTimer)
		self:OnAnimChangeAnimationFinished()
	end
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	self:PlayAnimation(self.AnimChange, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
	local Step = 2
	local NextSkillID = LogicData:GetPlayerSeriesNext(self.BtnSkillID, self.ButtonIndex, Step)
	local IconPath = SkillMainCfg:FindValue(NextSkillID, "Icon")
	UIUtil.ButtonSetBrushSync(self.IconSkillReplaceBtn, IconPath)
	--UIUtil.ButtonSetBrushSync(self.IconSkillReplaceBtn, IconPath, "Pressed")
	self.SimulateReplaceTimer = self:RegisterTimer(self.OnAnimChangeAnimationFinished, 0.3, 1, 1)

end

--AnimChange播放0.3s后处理，而非播放完成
function SkillAbleBtnView:OnAnimChangeAnimationFinished()
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	LogicData:SkillMoveNext(self.BtnSkillID, self.ButtonIndex)
	local NextSkillID = LogicData:GetPlayerSeriesNext(self.BtnSkillID, self.ButtonIndex)
	SkillUtil.ChangeSkillIcon(NextSkillID, self.IconSkillReplace)
	EventMgr:SendEvent(EventID.PlayerPrepareCastSkill, {EntityID = self.EntityID, Index = self.ButtonIndex, SkillID = self.BtnSkillID})
	self.SimulateReplaceTimer = 0
end
------------演示技能模拟替换END----------------

function SkillAbleBtnView:OnSkillReplaceLogic(Params)
	self.Super:OnSkillReplaceLogic(Params)
	local SkillID = Params.SkillID

	self:CancelPressStatus()

	self.MultiChoiceCount = 0
	local SelectIdList = SkillMainCfg:FindValue(SkillID, "SelectIdList")
	if SelectIdList ~= nil and #SelectIdList > 1 then
		for _, value in ipairs(SelectIdList) do
			if value.ID ~= 0 then
				self.MultiChoiceCount = self.MultiChoiceCount + 1
			end
		end
		if self.MultiChoiceCount > 1 then
			self.SelectIdList = SelectIdList
			self.bCurSelectSkill = true
		else
			self.SelectIdList = nil
			self.bCurSelectSkill = false
		end
	else
		self.SelectIdList = nil
		self.bCurSelectSkill = false
	end

	self.BaseBtnVM:SetMultiSkillFlag(self.bCurSelectSkill)

	if self.HasReChargeConfig then
		local SkillCDMgr = _G.SkillCDMgr

		local _, MaxChargeCount = SkillCDMgr:GetSkillChargeCount(SkillID)
		self.bChargeSkill = MaxChargeCount > 1

		self.ReChargeCD = MaxChargeCount == 0 and SkillCDMgr:GetReChargeCD(SkillID) or 0
	end

	if self.bCurSelectSkill == false and self.bPreSelectSkill == true then
		self.MultiChoiceSlot:ClearChildren()
		if self.MultiChoicePanel then
			UIViewMgr:RecycleView(self.MultiChoicePanel)
			self.MultiChoicePanel = nil
		end
	elseif self.bCurSelectSkill == true and self.bPreSelectSkill == true then
		if self.MultiChoicePanel then
			self.MultiChoicePanel:UpdateView({IDList = SelectIdList, MultiChoiceCount = self.MultiChoiceCount, ButtonIndex = self.ButtonIndex, bMajor = self.bMajor})
		end
	elseif self.bCurSelectSkill == true and self.bPreSelectSkill == false then
		local View = UIViewMgr:CreateViewByName(SkillCommonDefine.MultiChoicePanelBPName, ObjectGCType.Hold)
		if View then
			self.MultiChoiceSlot:AddChild(View)
			if self.MultiChoicePanel then
				UIViewMgr:RecycleView(self.MultiChoicePanel)
			end
			self.MultiChoicePanel = View
			View:InitView()
			View:ShowView({IDList = SelectIdList, MultiChoiceCount = self.MultiChoiceCount, ButtonIndex = self.ButtonIndex, bMajor = self.bMajor})
		end
	end
	self.bPreSelectSkill = self.bCurSelectSkill

	--二级轮盘技能解锁
	self:UnRegisterTimer(self.PreSelectSkillUnlockTimer)
	if self.bPreSelectSkill then
		self.PreSelectSkillUnlockTimer = self:RegisterTimer(function()
		for index, value in ipairs(self.SelectIdList) do
			if self:IsMutiChoiceSelectSkillUnLock(value.ID) then
				self.SelectIdList[index].NewUnLockSkill = true
			else
				self.SelectIdList[index].NewUnLockSkill = nil
			end
		end
	 	end, 0.5, 1, 1)
	end
end

local AttrType2ButtonStatus = 
{
    [ProtoCommon.attr_type.attr_mp] = SkillBtnState.SkillMP,
    [ProtoCommon.attr_type.attr_gp] = SkillBtnState.SkillGP
}

function SkillAbleBtnView:OnSkillReplaceDisplay(Params)
	local SkillID = Params.SkillID
	self:InitRechargeInfo(SkillID)
	self.Super:OnSkillReplaceDisplay(Params)

	local SkillVM = self.BaseBtnVM

	self.EFF_ADD_Inst_25:SetRenderOpacity(0)

	if self.bMajor then
		self:UnRegisterTimer(self.ReplaceCDTimer)
		self.ReplaceCDTimer = 0

		self.ReplaceCD = self:IsSupportReplaceCD(Params)
		if self.ReplaceCD > 0 then
			SkillVM.bTextRechargeTimes = false
			self.RecordReplaceStartTime = TimeUtil.GetServerTimeMS()
			self.ReplaceCDTimer = self:RegisterTimer(self.OnReplaceCDInvoke, 0, 0.1, 0)
			SkillVM.bAnimSkillLimitLoop = true
			SkillVM.bChargeProcessVisible = true
		else
			if not self.bChargeSkill then
				SkillVM.bChargeProcessVisible = false
				SkillVM.ChargeCDPercent = 0
			end
			SkillVM.bAnimSkillLimitLoop = false
		end

		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		local SkillLearnedStatus = LogicData:IsSkillLearned(SkillID)
		local LockIcon = nil
		if SkillLearnedStatus == SkillUtil.SkillLearnStatus.UnLockLevel then
			LockIcon = SkillCommonDefine.DefaultLockIcon
		elseif SkillLearnedStatus == SkillUtil.SkillLearnStatus.UnLockAdvancedProf then
			LockIcon = RoleInitCfg:FindRoleInitProfIconSimple4(LogicData:GetProfID())
		end
		SkillVM.ImgLockIcon = LockIcon
	else
		SkillVM.ImgLockIcon = nil
	end

end

function SkillAbleBtnView:IsSupportReplaceCD(Params)
	local SkillID = Params.SkillID
	--复用充能UI，以充能表现为优先
	--TODO[chaooren] 嵌入的多选一也不支持替换CD表现
	local bSupportReplaceCD = not self.bChargeSkill
	if bSupportReplaceCD then
		local BuffID = SkillMainCfg:FindValue(SkillID, "ReplaceBuffID") or 0
		if BuffID > 0 then
			local BuffInfo = _G.SkillBuffMgr:GetBuffInfo(BuffID)
			if BuffInfo then
				local ExpdTime = BuffInfo.ExpdTime
				local Time = (ExpdTime - TimeUtil.GetServerTimeMS())
				return Time
			end
		end
	end
	return 0
end

function SkillAbleBtnView:OnReplaceCDInvoke()
	--ms
	local ReplaceCDPercent = (TimeUtil.GetServerTimeMS() - self.RecordReplaceStartTime) / self.ReplaceCD
	if ReplaceCDPercent >= 1 then
		self:UnRegisterTimer(self.ReplaceCDTimer)
		self.ReplaceCDTimer = 0
	end
	self.BaseBtnVM.ChargeCDPercent = 1 - ReplaceCDPercent
end
--------------------------------技能替换END-------------------------------------------------------
-------------------------------------------充能------------------------------------------------------

local ChargeColorZero = _G.UE.FLinearColor(1, 0, 0, 1)
local ChargeColorOther = _G.UE.FLinearColor(1, 1, 1, 1)
function SkillAbleBtnView:OnSkillChargeUpdate(Params)
	local SkillID = Params.SkillID
	if SkillID ~= self.BtnSkillID then
		return
	end

	self.ReChargeCD = 0

	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData == nil then
		--数据异常
		return
	end

	if not LogicData:GetButtonState(self.ButtonIndex, SkillBtnState.SkillLearn) then
		return
	end

	local SkillVM = self.BaseBtnVM
	local CurChargeCount = Params.ChargeData.CurChargeCount
	self.ReChargeCD = Params.ChargeData.ReChargeCD
	--最大充能次数为1的充能技能，走普通CD表现
	if self.bChargeSkill == false then
		self:DoNormalCDUpdate(Params.MaskPercent, self.ReChargeCD)
		return
	end

	local MaskPercent = Params.MaskPercent
	local MaxChargeCount = Params.ChargeData.MaxChargeCount

	self:UpdateChargeView(CurChargeCount, MaxChargeCount)
	local bZero = CurChargeCount < 1
	self:ChargeSetCommonMask(bZero)
	SkillVM.RechargeTimesColorAndOpacity = bZero and ChargeColorZero or ChargeColorOther
	SkillVM.ChargeCDPercent = 1 - MaskPercent
	SkillVM.RechargeTimeText = tostring(CurChargeCount or "nil")
end

function SkillAbleBtnView:OnSkillMaxChargeCountChange(Params)
	if Params.SkillID == self.BtnSkillID then
		self:InitRechargeInfo(Params.SkillID)
	end
end

function SkillAbleBtnView:InitRechargeInfo(SkillID)
	local _ <close> = CommonUtil.MakeProfileTag("SkillAbleBtnView:InitRechargeInfo")
	if self.HasReChargeConfig then
		local CurChargeCount, MaxChargeCount = _G.SkillCDMgr:GetSkillChargeCount(SkillID)
		self.bChargeSkill = MaxChargeCount > 1
		local SkillVM = self.BaseBtnVM
		SkillVM.bTextRechargeTimes = self.bChargeSkill and self.bMajor  -- 技能系统不显示充能
		if self.bChargeSkill then
			SkillVM.SkillCDText = ""
			SkillVM.RechargeTimeText = tostring(CurChargeCount or "nil")
			if CurChargeCount > 0 then
				SkillVM.RechargeTimesColorAndOpacity = _G.UE.FLinearColor(1, 1, 1, 1)
			else
				SkillVM.RechargeTimesColorAndOpacity = _G.UE.FLinearColor(1, 0, 0, 1)
			end
			self:UpdateChargeView(CurChargeCount, MaxChargeCount)
		else
			SkillVM.bChargeProcessVisible = false
			self.ChargeMaskFlag = false
		end
	end
end

function SkillAbleBtnView:UpdateChargeView(CurChargeCount, MaxChargeCount)
	local SkillVM = self.BaseBtnVM
	SkillVM.bChargeProcessVisible = CurChargeCount ~= MaxChargeCount
	self.ChargeMaskFlag = CurChargeCount < 1
end

function SkillAbleBtnView:OnLongClick()
	--如果有其他类型技能复用该蓝图，可以考虑在初始化时配置好技能类型，并在这里选择调用Tips接口
	self.SkillTipsHandle = _G.SkillTipsMgr:ShowMajorSkillTips(self.BtnSkillID, self)
end

function SkillAbleBtnView:OnLongClickReleased()
	if self.SkillTipsHandle then
		_G.SkillTipsMgr:HideTipsByHandleID(self.SkillTipsHandle)
		self.SkillTipsHandle = nil
	end
end

function SkillAbleBtnView:ChargeSetCommonMask(bVisible)
	self.ChargeMaskFlag = bVisible
	self.Super:SetCommonMask(self.CommonMaskFlag or bVisible)
end

function SkillAbleBtnView:SetCommonMask(bVisible)
	self.CommonMaskFlag = bVisible
	self.Super:SetCommonMask(self.ChargeMaskFlag or bVisible)
end

function SkillAbleBtnView:OnPlaySkillUnLockEffect(SkillID)
	if self.ButtonIndex <= SkillCommonDefine.SkillButtonIndexRange.Fight and self.BtnSkillID == SkillID then
		_G.EventMgr:SendEvent(EventID.SkillUnLockView)
        --显示1s播放技能解锁动效
        self:PlaySkillUnlockAnimation({SetCommonMaskTime = 2.0})
	end
end


function SkillAbleBtnView:OnSkillAssetAttrUpdate(Params)
	local SkillVM = self.BaseBtnVM
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData and SkillVM:CanUpdateSkillCost() then
		local State, Cost = LogicData:GetButtonState(self.ButtonIndex, Params.Key)
		SkillVM:SetSkillCost(State, Cost)
	end
end

function SkillAbleBtnView:OnImgLockIconChange(NewValue, OldValue)

	if NewValue ~= OldValue then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgLock, NewValue, true, true, true)
	end

	--TODO[chaooren]2501分帧之间存在修正或属性变更可能有问题，待测试，用LogicData:PlayerAttrCheck不会存在分帧问题
	--local bValid, RequireCost = LogicData:PlayerAttrCheck(self.ButtonIndex, self.BtnSkillID, Params.ResType)
	local SkillVM = self.BaseBtnVM
	local bValid = SkillVM:CanUpdateSkillCost()
	SkillVM:SetSkillCostFlag(bValid)
	if bValid then
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		local State, Cost = LogicData:GetButtonState(self.ButtonIndex, AttrType2ButtonStatus[SkillVM:GetCostAttr()])
		SkillVM:SetSkillCost(State or not self.bMajor, Cost)
	end
end

function SkillAbleBtnView:OnGameEventMajorDead()
	if self.MouseDown then
		self:CancelPressStatus()
	end
end

return SkillAbleBtnView