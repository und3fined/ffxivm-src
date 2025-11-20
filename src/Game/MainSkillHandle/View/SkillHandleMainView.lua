---
--- Author: henghaoli
--- DateTime: 2025-05-23 14:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local MainControlPanelVM = require("Game/Main/VM/MainControlPanelVM")

local MainSkillPanelBase = require("Game/MainSkillPanelBase/MainSkillPanelBase")
local SkillHandleMainVM = require("Game/MainSkillHandle/View/SkillHandleMainVM")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")

local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local HandleActionPriority = SettingsHandleDefine.HandleActionPriority
local SettingsUtils = require("Game/Settings/SettingsUtils")

local SkillUtil = require("Utils/SkillUtil")
local MountVM = require("Game/Mount/VM/MountVM")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local InputCallback = require("Game/Input/InputCallback")

local FVector2D = _G.UE.FVector2D
local SkillHandleSkillPositionMap <const> = SettingsHandleDefine.SkillHandleSkillPositionMap
local HandleSkillType = SettingsHandleDefine.HandleSkillType


---@class SkillHandleMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Able1 SkillAbleBtnView
---@field Able10 SkillAbleBtnView
---@field Able10State SkillHandleStateItemView
---@field Able12 SkillAbleBtnView
---@field Able12State SkillHandleStateItemView
---@field Able13 SkillAbleBtnView
---@field Able13State SkillHandleStateItemView
---@field Able14 SkillAbleBtnView
---@field Able14State SkillHandleStateItemView
---@field Able15 SkillAbleBtnView
---@field Able15State SkillHandleStateItemView
---@field Able1State SkillHandleStateItemView
---@field Able2 SkillAbleBtnView
---@field Able2State SkillHandleStateItemView
---@field Able3 SkillAbleBtnView
---@field Able3State SkillHandleStateItemView
---@field Able4 SkillAbleBtnView
---@field Able4State SkillHandleStateItemView
---@field Able5 SkillAbleBtnView
---@field Able5State SkillHandleStateItemView
---@field Able8 SkillAbleBtnView
---@field Able8State SkillHandleStateItemView
---@field Able9 SkillAbleBtnView
---@field Able9State SkillHandleStateItemView
---@field BackSkillGenAttackBtn SkillLimitBackGenAttackBtnView
---@field BackSkillGenAttackStateRBLB SkillHandleStateRBLBView
---@field BlackHouse UFCanvasPanel
---@field Chant SkillChantView
---@field LimitRoot UFCanvasPanel
---@field MultiChoiceDisplay SkillMultiChoiceDisplayView
---@field PanelABXY1 UFCanvasPanel
---@field PanelABXY3 UFCanvasPanel
---@field PanelBottomState UFCanvasPanel
---@field PanelMultiChoiceDisplay UFCanvasPanel
---@field PanelSkill1 UFCanvasPanel
---@field PanelSkill1State UFCanvasPanel
---@field PanelSkill2 UFCanvasPanel
---@field PanelSkill2State UFCanvasPanel
---@field PanelSkill3 UFCanvasPanel
---@field PanelSkill3State UFCanvasPanel
---@field PanelSkill4 UFCanvasPanel
---@field PanelSkill4State UFCanvasPanel
---@field PanelSkillBottom UFCanvasPanel
---@field PanelSkillBottomState UFCanvasPanel
---@field PanelSkillLimitEntrance UFCanvasPanel
---@field PanelSkillState UFCanvasPanel
---@field PanelSkillTop UFCanvasPanel
---@field PanelSkillTopState UFCanvasPanel
---@field PanelState UFCanvasPanel
---@field PanelSwitch UFCanvasPanel
---@field PanelTopState UFCanvasPanel
---@field SkillHandleJumpBtn SkillHandleJumpBtnView
---@field SkillHandleRunBtn SkillHandleRunBtnView
---@field SkillHandleState4A SkillHandleState4View
---@field SkillHandleState4B SkillHandleState4View
---@field SkillHandleStateA SkillHandleStateView
---@field SkillHandleStateA1 SkillHandleStateView
---@field SkillHandleStateB SkillHandleStateView
---@field SkillHandleStateB1 SkillHandleStateView
---@field SkillHandleStateB3 SkillHandleStateLView
---@field SkillHandleStateL SkillHandleStateLRView
---@field SkillHandleStateLT SkillHandleStateLTView
---@field SkillHandleStateR SkillHandleStateLRView
---@field SkillHandleStateRS SkillHandleStateRSView
---@field SkillHandleStateRT SkillHandleStateRTView
---@field SkillHandleStateX SkillHandleStateView
---@field SkillHandleStateX1 SkillHandleStateView
---@field SkillHandleStateY SkillHandleStateView
---@field SkillHandleStateY1 SkillHandleStateView
---@field SkillLimit SkillLimitBtnView
---@field SkillLimitEntrance SkillLimitBtnView
---@field SkillLimitEntranceState SkillHandleStateItemView
---@field SkillPVPBtn SkillPVPBtnView
---@field SkillTargetBtn_UIBP SkillTargetBtnView
---@field Trigger1 SkillTriggerBtnView
---@field Trigger1State SkillHandleStateItemView
---@field Trigger2 SkillTriggerBtnView
---@field Trigger2State SkillHandleStateItemView
---@field Trigger3 SkillTriggerBtnView
---@field Trigger3State SkillHandleStateItemView
---@field AnimHide UWidgetAnimation
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillHandleMainView = LuaClass(MainSkillPanelBase, true)

function SkillHandleMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Able1 = nil
	--self.Able10 = nil
	--self.Able10State = nil
	--self.Able12 = nil
	--self.Able12State = nil
	--self.Able13 = nil
	--self.Able13State = nil
	--self.Able14 = nil
	--self.Able14State = nil
	--self.Able15 = nil
	--self.Able15State = nil
	--self.Able1State = nil
	--self.Able2 = nil
	--self.Able2State = nil
	--self.Able3 = nil
	--self.Able3State = nil
	--self.Able4 = nil
	--self.Able4State = nil
	--self.Able5 = nil
	--self.Able5State = nil
	--self.Able8 = nil
	--self.Able8State = nil
	--self.Able9 = nil
	--self.Able9State = nil
	--self.BackSkillGenAttackBtn = nil
	--self.BackSkillGenAttackStateRBLB = nil
	--self.BlackHouse = nil
	--self.Chant = nil
	--self.LimitRoot = nil
	--self.MultiChoiceDisplay = nil
	--self.PanelABXY1 = nil
	--self.PanelABXY3 = nil
	--self.PanelBottomState = nil
	--self.PanelMultiChoiceDisplay = nil
	--self.PanelSkill1 = nil
	--self.PanelSkill1State = nil
	--self.PanelSkill2 = nil
	--self.PanelSkill2State = nil
	--self.PanelSkill3 = nil
	--self.PanelSkill3State = nil
	--self.PanelSkill4 = nil
	--self.PanelSkill4State = nil
	--self.PanelSkillBottom = nil
	--self.PanelSkillBottomState = nil
	--self.PanelSkillLimitEntrance = nil
	--self.PanelSkillState = nil
	--self.PanelSkillTop = nil
	--self.PanelSkillTopState = nil
	--self.PanelState = nil
	--self.PanelSwitch = nil
	--self.PanelTopState = nil
	--self.SkillHandleJumpBtn = nil
	--self.SkillHandleRunBtn = nil
	--self.SkillHandleState4A = nil
	--self.SkillHandleState4B = nil
	--self.SkillHandleStateA = nil
	--self.SkillHandleStateA1 = nil
	--self.SkillHandleStateB = nil
	--self.SkillHandleStateB1 = nil
	--self.SkillHandleStateB3 = nil
	--self.SkillHandleStateL = nil
	--self.SkillHandleStateLT = nil
	--self.SkillHandleStateR = nil
	--self.SkillHandleStateRS = nil
	--self.SkillHandleStateRT = nil
	--self.SkillHandleStateX = nil
	--self.SkillHandleStateX1 = nil
	--self.SkillHandleStateY = nil
	--self.SkillHandleStateY1 = nil
	--self.SkillLimit = nil
	--self.SkillLimitEntrance = nil
	--self.SkillLimitEntranceState = nil
	--self.SkillPVPBtn = nil
	--self.SkillTargetBtn_UIBP = nil
	--self.Trigger1 = nil
	--self.Trigger1State = nil
	--self.Trigger2 = nil
	--self.Trigger2State = nil
	--self.Trigger3 = nil
	--self.Trigger3State = nil
	--self.AnimHide = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillHandleMainView:OnRegisterSubView()
	self.Super:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Able1)
	self:AddSubView(self.Able10)
	self:AddSubView(self.Able10State)
	self:AddSubView(self.Able12)
	self:AddSubView(self.Able12State)
	self:AddSubView(self.Able13)
	self:AddSubView(self.Able13State)
	self:AddSubView(self.Able14)
	self:AddSubView(self.Able14State)
	self:AddSubView(self.Able15)
	self:AddSubView(self.Able15State)
	self:AddSubView(self.Able1State)
	self:AddSubView(self.Able2)
	self:AddSubView(self.Able2State)
	self:AddSubView(self.Able3)
	self:AddSubView(self.Able3State)
	self:AddSubView(self.Able4)
	self:AddSubView(self.Able4State)
	self:AddSubView(self.Able5)
	self:AddSubView(self.Able5State)
	self:AddSubView(self.Able8)
	self:AddSubView(self.Able8State)
	self:AddSubView(self.Able9)
	self:AddSubView(self.Able9State)
	self:AddSubView(self.BackSkillGenAttackBtn)
	self:AddSubView(self.BackSkillGenAttackStateRBLB)
	self:AddSubView(self.Chant)
	self:AddSubView(self.MultiChoiceDisplay)
	self:AddSubView(self.SkillHandleJumpBtn)
	self:AddSubView(self.SkillHandleRunBtn)
	self:AddSubView(self.SkillHandleState4A)
	self:AddSubView(self.SkillHandleState4B)
	self:AddSubView(self.SkillHandleStateA)
	self:AddSubView(self.SkillHandleStateA1)
	self:AddSubView(self.SkillHandleStateB)
	self:AddSubView(self.SkillHandleStateB1)
	self:AddSubView(self.SkillHandleStateB3)
	self:AddSubView(self.SkillHandleStateL)
	self:AddSubView(self.SkillHandleStateLT)
	self:AddSubView(self.SkillHandleStateR)
	self:AddSubView(self.SkillHandleStateRS)
	self:AddSubView(self.SkillHandleStateRT)
	self:AddSubView(self.SkillHandleStateX)
	self:AddSubView(self.SkillHandleStateX1)
	self:AddSubView(self.SkillHandleStateY)
	self:AddSubView(self.SkillHandleStateY1)
	self:AddSubView(self.SkillLimit)
	self:AddSubView(self.SkillLimitEntrance)
	self:AddSubView(self.SkillLimitEntranceState)
	self:AddSubView(self.SkillPVPBtn)
	self:AddSubView(self.SkillTargetBtn_UIBP)
	self:AddSubView(self.Trigger1)
	self:AddSubView(self.Trigger1State)
	self:AddSubView(self.Trigger2)
	self:AddSubView(self.Trigger2State)
	self:AddSubView(self.Trigger3)
	self:AddSubView(self.Trigger3State)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY

	self.TriggerMap[self.Trigger1.ButtonIndex] = self.Trigger1
	self.TriggerMap[self.Trigger2.ButtonIndex] = self.Trigger2
	self.TriggerMap[self.Trigger3.ButtonIndex] = self.Trigger3

	local HandleCustomActionType = SettingsHandleDefine.HandleCustomActionType
	--手柄技能索引与技能映射<const>
	local HandleIndexSkillMatchMap = {
		[HandleCustomActionType.AbleSkill1] = self.Able5,
		[HandleCustomActionType.AbleSkill2] = self.Able4,
		[HandleCustomActionType.AbleSkill3] = self.Able3,
		[HandleCustomActionType.AbleSkill4] = self.Able2,
		[HandleCustomActionType.AbleSkill5] = self.Able1,
		[HandleCustomActionType.TriggerSkill1] = self.Trigger1,
		[HandleCustomActionType.TriggerSkill2] = self.Trigger2,
		[HandleCustomActionType.GuardSkill] = self.Able9,
		[HandleCustomActionType.FightSkill] = self.Able8,
		[HandleCustomActionType.FunctionSkill] = self.Able10,
		[HandleCustomActionType.AbleExtend] = self.PanelSkillLimitEntrance,
		[HandleCustomActionType.SpectrumSkill1] = self.Able13,
		[HandleCustomActionType.SpectrumSkill3] = self.Able15,
		[HandleCustomActionType.SpectrumSkill2] = self.Able14,
		[HandleCustomActionType.PVPcommonskill] = self.Able12,
	}
	self.HandleIndexSkillMatchMap = HandleIndexSkillMatchMap

	local RawParentRelation = {}
	for _, v in pairs(HandleIndexSkillMatchMap) do
		RawParentRelation[v] = v:GetParent()
	end

	self.RawParentRelation = RawParentRelation

	--手柄按键与技能映射
	self.SkillHandleSkillMatchMap = {
		["HandleRTB"] = self.Able5,
		["HandleRTY"] = self.Able4,
		["HandleRTA"] = self.Able3,
		["HandleRTX"] = self.Able2,
		["HandleRTRight"] = self.Trigger1,
		["HandleRTUp"] = self.Trigger2,
		["HandleRTDown"] = self.PanelSkillLimitEntrance,
		["HandleRTLeft"] = nil,
		["HandleLTB"] = self.Able1,
		["HandleLTY"] = self.Able10,
		["HandleLTA"] = self.Able9,
		["HandleLTX"] = self.Able8,
		["HandleLTRight"] = self.Able12,
		["HandleLTUp"] = self.Able13,
		["HandleLTDown"] = self.Able15,
		["HandleLTLeft"] = self.Able14,
	}

end

function SkillHandleMainView:OnInit()
	self.Super:OnInit()
	self.SkillHandleMainVM = SkillHandleMainVM.New()
	self.RestorePressTimer = 0
    self.CanPress = true    --脱战后0.5s内不可按下
	self.LongPressTimer = 0
end

function SkillHandleMainView:OnDestroy()

end

function SkillHandleMainView:OnShow()
	self.Super:OnShow()
	self:PlayAnimationToEndTime(self.AnimShow)
	MainControlPanelVM:SetHandleSkillViewFight(MainControlPanelVM.bFightStatus)
	MountVM:SetHandleSkillViewFight(MountVM.CombatPanelState)
	self:UpdateAllSkillButtonCustom()
end

function SkillHandleMainView:OnHide()
	MainControlPanelVM:SetHandleSkillViewFight(false)
	MountVM:SetHandleSkillViewFight(false)
	self:PlayAnimationToEndTime(self.AnimHide)
	self:EndLongPressTimer()
end

function SkillHandleMainView:OnRegisterUIEvent()

end

function SkillHandleMainView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillMultiChoicePanelShowed, self.OnSkillMultiChoicePanelShowed)
	self:RegisterGameEvent(EventID.GamePadSkillHighLight, self.OnGamePadSkillHighLight)
	self:RegisterGameEvent(EventID.SimulatedTouchStartClick, self.OnSimulatedTouchStartClick)
	self:RegisterGameEvent(EventID.SimulatedTouchEndClick, self.OnSimulatedTouchEndClick)
	self:RegisterGameEvent(EventID.OnUpdateHandleCusAction, self.OnUpdateHandleCusAction)
	self:RegisterGameEvent(EventID.OnResetHandleCusAction, self.OnResetHandleCusAction)
	self:RegisterGameEvent(EventID.InputActionSkillPressed, self.OnInputActionSkillPressed)
	self:RegisterGameEvent(EventID.InputActionSkillReleased, self.OnInputActionSkillRelease)
	self:RegisterGameEvent(EventID.LimitSkillHandleBUp, self.OnLimitSkillHandleBUp)
	self:RegisterGameEvent(EventID.LimitSkillHandleBDown, self.OnLimitSkillHandleBDown)
	self:RegisterGameEvent(EventID.MajorSkillCastFailed, self.OnSkillCastFailed)
    self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)
	local IsInField = _G.PWorldMgr:CurrIsInField()
	--仅野外支持
    if IsInField then
        self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
    end
end

function SkillHandleMainView:OnRegisterBinder()
	local HandleMainBinders = {
        { "IsSwitchPanelVisible", UIBinderSetIsVisible.New(self, self.PanelState)},
		{ "IsTopHighLight", UIBinderSetIsVisible.New(self, self.SkillHandleState4A)},
		{ "IsTopHighLight", UIBinderSetIsVisible.New(self, self.PanelABXY3)},
		{ "IsTopHighLight", UIBinderValueChangedCallback.New(self, nil, self.UpdateSkillTopState)},
		{ "IsTopHighLight", UIBinderSetIsVisible.New(self, self.SkillHandleStateLT.ImgSelect)},
		{ "IsBottomHighLight", UIBinderSetIsVisible.New(self, self.PanelABXY1)},
		{ "IsBottomHighLight", UIBinderSetIsVisible.New(self, self.SkillHandleState4B)},
		{ "IsBottomHighLight", UIBinderValueChangedCallback.New(self, nil, self.UpdateSkillBottomState)},
		{ "IsBottomHighLight", UIBinderSetIsVisible.New(self, self.SkillHandleStateRT.ImgSelect)},
    }
    self:RegisterBinders(self.SkillHandleMainVM, HandleMainBinders)

	local Binders = {
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.BackSkillGenAttackBtn)},
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.SkillLimit, false, true)},
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.LimitRoot)},
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.PanelSkillTop, true)},
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.PanelSkillBottom, true)},
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.PanelSkillState, true)},
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.PanelSwitch, true)},
		{ "IsLimitEntranceVisible",  UIBinderSetIsVisible.New(self, self.SkillLimitEntrance)},
		{ "IsLimitCastVisible", UIBinderValueChangedCallback.New(self, nil, self.OnLimitCastVisibleChanged) },
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.SkillHandleJumpBtn, true)},
		{ "IsLimitCastVisible",  UIBinderSetIsVisible.New(self, self.SkillHandleRunBtn, true)},
    }

	self:RegisterBinders(self.MainSkillPanelBaseVM, Binders)
end

function SkillHandleMainView:ViewSwitchFight()
	MainControlPanelVM:SetHandleSkillViewFight(true)
	MountVM:SetHandleSkillViewFight(true)
	self:PlayAnimationToEndTime(self.AnimShow)
end

function SkillHandleMainView:ViewSwitchPeace()
	MainControlPanelVM:SetHandleSkillViewFight(false)
	MountVM:SetHandleSkillViewFight(false)
	self:PlayAnimationToEndTime(self.AnimHide)
end

function SkillHandleMainView:OnSkillMultiChoicePanelShowed(Params)
	if Params.bMajor then
		self.SkillHandleMainVM.IsSwitchPanelVisible = Params.IsDisplayed
	end
end

function SkillHandleMainView:OnGamePadSkillHighLight(HandleType, EventType)
	self.SkillHandleMainVM:SetHighLight(HandleType, EventType)
end


local function CanTakeoverGenAttackSkill()
	return MainControlPanelVM.bFightStatus
end

function SkillHandleMainView:OnInputActionSkillPressed(Index)
	if Index == 0 and CanTakeoverGenAttackSkill() then
		SkillUtil.PreCastGenAttackSkillCondition(Index)
	end
end

function SkillHandleMainView:OnInputActionSkillRelease(Index)
	if Index == 0 and CanTakeoverGenAttackSkill() and
	InputCallback.InputActionSkillReleasedNum and InputCallback.InputActionSkillReleasedNum <= 0 then
		InputCallback.InputActionSkillReleasedNum = InputCallback.InputActionSkillReleasedNum + 1
		SkillUtil.PostCastGenAttackSkillCondition(Index, true, nil, nil, self.CanPress, self)
	end
end

function SkillHandleMainView:GetSkillLimitBtn(Params)
	if self.MapType == SkillUtil.MapType.PVP then
		Params.Index = self.SkillPVPBtn.ButtonIndex
		return self.SkillPVPBtn
	else
		return self.SkillLimitEntrance
	end
end

function SkillHandleMainView:OnSimulatedTouchStartClick(Params)
	local BtnName = Params.BtnName
	local SkillBtn = self.SkillHandleSkillMatchMap[BtnName]
	if SkillBtn == self.PanelSkillLimitEntrance then
		SkillBtn = self:GetSkillLimitBtn(Params)
	end

	if SkillBtn and SkillBtn:GetIsShowView() then
		SkillBtn:OnSimulatedTouchStartClick(Params)
	end
end

function SkillHandleMainView:OnSimulatedTouchEndClick(Params)
	local BtnName = Params.BtnName
	local SkillBtn = self.SkillHandleSkillMatchMap[BtnName]
	if SkillBtn == self.PanelSkillLimitEntrance then
		SkillBtn = self:GetSkillLimitBtn(Params)
	end
	if SkillBtn and SkillBtn:GetIsShowView() then
		SkillBtn:OnSimulatedTouchEndClick(Params)
	end
end

function SkillHandleMainView:UpdateAllSkillButtonCustom()
	local HandleCustomActionMap = SettingsUtils["SettingsTabHandle"]:GetHandleCustomActionMap()
	if not HandleCustomActionMap then return end
	local HandleIndexSkillMatchMap = self.HandleIndexSkillMatchMap
	local SkillButtonCustomMap = self.SkillHandleSkillMatchMap

	local PendingHiddenButtons = {}
	local PendingModifyButtons = {}

	for k, v in pairs(HandleCustomActionMap) do
		local AfterButton = HandleIndexSkillMatchMap[v]
		local BeforeButton = SkillButtonCustomMap[k]
		if AfterButton ~= BeforeButton then
			if BeforeButton and not PendingModifyButtons[BeforeButton] then
				table.insert(PendingHiddenButtons, BeforeButton)
			end
			self.SkillHandleSkillMatchMap[k] = AfterButton
			if AfterButton then
				PendingModifyButtons[AfterButton] = true
				table.remove_item(PendingHiddenButtons, AfterButton)
				self:PopToBlackHouse(AfterButton)
				self:SetSkillButtonPosition(AfterButton, k)
			end
		end
	end

	if #PendingHiddenButtons > 0 then
		for i = 1, #PendingHiddenButtons do
			self:PushToBlackHouse(PendingHiddenButtons[i])
		end
	end
end

local function GetSkillButtonPosition(Key)
	return SkillHandleSkillPositionMap[Key] or FVector2D(0, 0)
end

function SkillHandleMainView:SetSkillButtonPosition(SkillBtn, Key)
	if SkillBtn == nil then return end
	
	local Pos = GetSkillButtonPosition(Key)
	UIUtil.CanvasSlotSetPosition(SkillBtn, Pos)
end

function SkillHandleMainView:PushToBlackHouse(PendingHiddenButton)
	if not PendingHiddenButton then
		return
	end

	self.BlackHouse:AddChildToCanvas(PendingHiddenButton)
end

local Anchor = UE.FAnchors()
Anchor.Minimum = UE.FVector2D(1, 1)
Anchor.Maximum = UE.FVector2D(1, 1)

local Size = _G.UE.FVector2D(116, 116)
function SkillHandleMainView:PopToBlackHouse(Button)
	if not Button then
		return
	end

	local Parent = self.RawParentRelation[Button]
	if Parent ~= Button:GetParent() then
		Parent:AddChildToCanvas(Button)
		UIUtil.CanvasSlotSetAnchors(Button, Anchor)
		UIUtil.CanvasSlotSetSize(Button, Size)
	end
end

function SkillHandleMainView:OnResetHandleCusAction(Type)
	if Type ~= SettingsHandleDefine.HandleMainType.SkillType then
		return
	end
	self:UpdateAllSkillButtonCustom()
end

function SkillHandleMainView:OnUpdateHandleCusAction(Params)
	local HandleIndexSkillMatchMap = self.HandleIndexSkillMatchMap
	local SkillButtonCustomMap = self.SkillHandleSkillMatchMap
	local Key = Params.SaveKey

	local AfterButton = HandleIndexSkillMatchMap[Params.CusActionIndex]
	local BeforeButton = SkillButtonCustomMap[Key]
	if AfterButton ~= BeforeButton then
		self:PushToBlackHouse(BeforeButton)
		self.SkillHandleSkillMatchMap[Key] = AfterButton
		if AfterButton then
			self:PopToBlackHouse(AfterButton)
			self:SetSkillButtonPosition(AfterButton, Key)
		end
	end
end

function SkillHandleMainView:OnLimitCastVisibleChanged(NewValue, OldValue)
	if NewValue then
		local Params1 = _G.EventMgr:GetEventParams()
		Params1.IntParam1 = SettingsHandleDefine.HandleCustomActionType.NormalSkill
		Params1.IntParam2 = EventID.LimitSkillHandleBUp
		Params1.IntParam3 = HandleActionPriority.LimitCast
		local Params2 = _G.EventMgr:GetEventParams()
		Params2.IntParam1 = SettingsHandleDefine.HandleCustomActionType.NormalSkill
		Params2.IntParam2 = EventID.LimitSkillHandleBDown
		Params2.IntParam3 = HandleActionPriority.LimitCast
		_G.EventMgr:SendCppEvent(EventID.RegisiterKeyUpData, Params1)
		_G.EventMgr:SendCppEvent(EventID.RegisiterKeyDownData, Params2)
	else
		local Params1 = _G.EventMgr:GetEventParams()
		Params1.IntParam1 = SettingsHandleDefine.HandleCustomActionType.NormalSkill
		Params1.IntParam2 = EventID.LimitSkillHandleBUp
		Params1.IntParam3 = HandleActionPriority.LimitCast
		local Params2 = _G.EventMgr:GetEventParams()
		Params2.IntParam1 = SettingsHandleDefine.HandleCustomActionType.NormalSkill
		Params2.IntParam2 = EventID.LimitSkillHandleBDown
		Params2.IntParam3 = HandleActionPriority.LimitCast
		_G.EventMgr:SendCppEvent(EventID.UnRegisiterKeyUpData, Params1)
		_G.EventMgr:SendCppEvent(EventID.UnRegisiterKeyDownData, Params2)
	end
end

function SkillHandleMainView:OnLimitSkillHandleBUp()
	self.SkillLimit:OnSimulatedTouchEndClick({Index = self.SkillLimit.ButtonIndex})
end

function SkillHandleMainView:OnLimitSkillHandleBDown()
	self.SkillLimit:OnSimulatedTouchStartClick({Index = self.SkillLimit.ButtonIndex})
end

function SkillHandleMainView:UpdateSkillBottomState(Value)
	self.Able5State:SetIsSelect(Value)
	self.Able4State:SetIsSelect(Value)
	self.Able3State:SetIsSelect(Value)
	self.Able2State:SetIsSelect(Value)
	self.Trigger1State:SetIsSelect(Value)
	self.Trigger2State:SetIsSelect(Value)
	self.Trigger3State:SetIsSelect(Value)
	self.SkillLimitEntranceState:SetIsSelect(Value)
end

function SkillHandleMainView:UpdateSkillTopState(Value)
	self.Able1State:SetIsSelect(Value)
	self.Able8State:SetIsSelect(Value)
	self.Able9State:SetIsSelect(Value)
	self.Able10State:SetIsSelect(Value)
	self.Able12State:SetIsSelect(Value)
	self.Able13State:SetIsSelect(Value)
	self.Able14State:SetIsSelect(Value)
	self.Able15State:SetIsSelect(Value)
end

--脱战1s内不能使用普攻
local YanruConfigTime = 1
function SkillHandleMainView:OnNetStateUpdate(Params)
    local EntityID = Params.ULongParam1
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
    local StateType = Params.IntParam1
    if StateType ~= ProtoCommon.CommStatID.COMM_STAT_COMBAT then
        return
    end
    if Params.BoolParam1 == false then
        self:EndLongPressTimer()
        self.CanPress = false

        if self.RestorePressTimer > 0 then
            self:UnRegisterTimer(self.RestorePressTimer)
        end

        --脱战1s内不能使用普攻
        self.RestorePressTimer = self:RegisterTimer(self.RestorePress, YanruConfigTime, 0, 1)
    end
end

function SkillHandleMainView:RestorePress()
    self.CanPress = true
end

function SkillHandleMainView:StartLongPressTimer()
    if not self.LongPressTimer or self.LongPressTimer == 0 then
        self.LongPressTimer = self:RegisterTimer(self.LongPressStart, 0, 0.5, 0)
    end
end

function SkillHandleMainView:EndLongPressTimer()
    if self.LongPressTimer > 0 then
        self:UnRegisterTimer(self.LongPressTimer)
        self.LongPressTimer = 0
    end
end

function SkillHandleMainView:LongPressStart()
    self:OnInputActionSkillRelease(0)
end

function SkillHandleMainView:OnGameEventUnSelectTarget(Params)
    self:EndLongPressTimer()
end

function SkillHandleMainView:OnSkillCastFailed(Index)
	if Index == 0 then
        self:EndLongPressTimer()
	end
end


return SkillHandleMainView