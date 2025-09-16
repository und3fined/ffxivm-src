---
--- Author: chaooren
--- DateTime: 2022-03-18 12:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local TimeUtil = require("Utils/TimeUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MainControlPanelVM = require("Game/Main/VM/MainControlPanelVM")
local QteSkilldisplayCfg = require("TableCfg/QteSkilldisplayCfg")

local ESlateVisibility = _G.UE.ESlateVisibility
local EMapType = SkillUtil.MapType

---@class NewMainSkillView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Able1 SkillAbleBtnView
---@field Able10 SkillAbleBtnView
---@field Able12 SkillAbleBtnView
---@field Able2 SkillAbleBtnView
---@field Able3 SkillAbleBtnView
---@field Able4 SkillAbleBtnView
---@field Able5 SkillAbleBtnView
---@field Able8 SkillAbleBtnView
---@field Able9 SkillAbleBtnView
---@field BackSkillGenAttackBtn SkillLimitBackGenAttackBtnView
---@field BtnEmpty1 UFButton
---@field BtnEmpty2 UFButton
---@field Chant SkillChantView
---@field LimitRoot UFCanvasPanel
---@field MultiChoiceDisplay SkillMultiChoiceDisplayView
---@field PanelAble UFCanvasPanel
---@field PanelAble2 UFCanvasPanel
---@field Root UFCanvasPanel
---@field SkillGenAttackBtn_UIBP SkillGenAttackBtnView
---@field SkillLimit SkillLimitBtnView
---@field SkillLimitEntrance SkillLimitBtnView
---@field SkillPVPBtn SkillPVPBtnView
---@field Trigger1 SkillTriggerBtnView
---@field Trigger2 SkillTriggerBtnView
---@field Trigger3 SkillTriggerBtnView
---@field AnimIn1 UWidgetAnimation
---@field AnimIn1PVP UWidgetAnimation
---@field AnimOut1 UWidgetAnimation
---@field AnimOut1PVP UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewMainSkillView = LuaClass(UIView, true)

function NewMainSkillView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Able1 = nil
	--self.Able10 = nil
	--self.Able12 = nil
	--self.Able2 = nil
	--self.Able3 = nil
	--self.Able4 = nil
	--self.Able5 = nil
	--self.Able8 = nil
	--self.Able9 = nil
	--self.BackSkillGenAttackBtn = nil
	--self.BtnEmpty1 = nil
	--self.BtnEmpty2 = nil
	--self.Chant = nil
	--self.LimitRoot = nil
	--self.MultiChoiceDisplay = nil
	--self.PanelAble = nil
	--self.PanelAble2 = nil
	--self.Root = nil
	--self.SkillGenAttackBtn_UIBP = nil
	--self.SkillLimit = nil
	--self.SkillLimitEntrance = nil
	--self.SkillPVPBtn = nil
	--self.Trigger1 = nil
	--self.Trigger2 = nil
	--self.Trigger3 = nil
	--self.AnimIn1 = nil
	--self.AnimIn1PVP = nil
	--self.AnimOut1 = nil
	--self.AnimOut1PVP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewMainSkillView:AddSubView(View)
	self.Super:AddSubView(View)

	if View then
		View.SkillMultiChoiceDisplay = self.MultiChoiceDisplay
		local ButtonIndex = View.ButtonIndex
		if ButtonIndex ~= nil then
			self.SkillSystemMap[ButtonIndex] = View

			if View.bAbleBtn then
				self.AbleSkillMap[ButtonIndex] = View
			end
		end
	end
end

function NewMainSkillView:OnRegisterSubView()
	self.SkillSystemMap = {}
	self.AbleSkillMap = {}
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Able1)
	self:AddSubView(self.Able10)
	self:AddSubView(self.Able12)
	self:AddSubView(self.Able2)
	self:AddSubView(self.Able3)
	self:AddSubView(self.Able4)
	self:AddSubView(self.Able5)
	self:AddSubView(self.Able8)
	self:AddSubView(self.Able9)
	self:AddSubView(self.BackSkillGenAttackBtn)
	self:AddSubView(self.Chant)
	self:AddSubView(self.MultiChoiceDisplay)
	self:AddSubView(self.SkillGenAttackBtn_UIBP)
	self:AddSubView(self.SkillLimit)
	self:AddSubView(self.SkillLimitEntrance)
	self:AddSubView(self.SkillPVPBtn)
	self:AddSubView(self.Trigger1)
	self:AddSubView(self.Trigger2)
	self:AddSubView(self.Trigger3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY

	self.SkillSystemMap[0] = self.SkillGenAttackBtn_UIBP

	self.TriggerMap = {}
	self.TriggerMap[self.Trigger1.ButtonIndex] = self.Trigger1
	self.TriggerMap[self.Trigger2.ButtonIndex] = self.Trigger2
	self.TriggerMap[self.Trigger3.ButtonIndex] = self.Trigger3
end

function NewMainSkillView:OnInit()
	self.SkillLimitState = 1 --1：右上角入口状态ui  2：极限技释放状态

	self.MapTypeAnimMap = {
		[EMapType.PVE] = {
			In = self.AnimIn1,
			Out = self.AnimOut1,
		},
		[EMapType.PVP] = {
			In = self.AnimIn1PVP,
			Out = self.AnimOut1PVP,
		}
	}

	rawset(self, "bMainSkillPanel", true)
end

function NewMainSkillView:OnDestroy()
	if self.SkillExpand then
		-- UIViewMgr:RecycleView(self.SkillExpand)
		self.SkillExpand = nil
	end
end

function NewMainSkillView:OnEntityIDUpdate(EntityID, bMajor, MapType)
	self.EntityID = EntityID
	self.bMajor = bMajor
	-- 主界面需要根据PVP/PVE调整表现, 但目前技能按钮子View不需要, 就不往下传了
	self.MapType = MapType
	for _, value in ipairs(self.SubViews) do
		if value["OnEntityIDUpdate"] ~= nil then
			value:OnEntityIDUpdate(EntityID, self.bMajor)
		end
	end
end

function NewMainSkillView:OnShow()
	if self.bMajor ~= true and not self.SkillExpand then
		UIUtil.SetIsVisible(self.SkillGenAttackBtn_UIBP, true, true)
		_G.SkillSystemMgr:CreateSkillExpandWidgetAsync(self)
	end

	self:DoCustomIndexReplace()
	if self.bMajor then
		self:OnEventMajorProfSwitch()

		self:OnSkillLimitDel()
		
		--方便入口的回调
		self.SkillLimitEntrance.IsEntrance = true

		if self.SkillLimitState == 2 then
			self:SwitchToLimitSkillCastState()
		end

		self:CheckSubTriggerView()

		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		if not LogicData then
			return
		end
		for BtnIndex, AbleView in pairs(self.AbleSkillMap) do
			if LogicData:GetBtnSkillID(BtnIndex) == 0 then
				AbleView:SetVisibleEnum(ESlateVisibility.Collapsed)
			else
				AbleView:SetVisibleEnum(ESlateVisibility.Visible)
			end
		end
	else
		self:CheckSystemSkillBtnsVisible()
	end
end

function NewMainSkillView:CheckSystemSkillBtnsVisible()
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if not LogicData then return end
	
	local VaildTriggerViews = {}
	for Index, View in pairs(self.SkillSystemMap) do
		if LogicData:GetBtnSkillID(Index) > 0 then
			if View.bTriggerBtn then
				VaildTriggerViews[Index] = View
			end
			View:SetVisibleEnum(ESlateVisibility.Visible)
		else
			View:SetVisibleEnum(ESlateVisibility.Collapsed)
		end
	end
	-- PVP中触发技可能与普通技相同，在界面显示里只需要显示普通技能
	if self.MapType == EMapType.PVP and not table.is_nil_empty(VaildTriggerViews) then
		for TrigIndex, TrigView in pairs(VaildTriggerViews) do
			local TrigSkillID = LogicData:GetBtnSkillID(TrigIndex)
			for AbleIndex, AbleView in pairs(self.AbleSkillMap) do
				if TrigSkillID == LogicData:GetBtnSkillID(AbleIndex) then
					TrigView:SetVisibleEnum(ESlateVisibility.Collapsed)
					break
				end
			end
		end
	end
end

function NewMainSkillView:OnHide()

end

local Handled <const> = _G.UE.UWidgetBlueprintLibrary.Handled()
local AntiPenetratePanelNum <const> = 6
local AntiPenetrateTriggerBtnMap = {
	[7] = 5,
	[6] = 6
}

local function OnMouseButtonDown()
	return Handled
end

function NewMainSkillView:OnRegisterUIEvent()
	for i = 1, AntiPenetratePanelNum do
		local Widget = self["AntiPenetratePanel" .. tostring(i)]
		if Widget then
			Widget.OnMouseButtonDownEvent:Bind(self.Object, OnMouseButtonDown)
		end
	end
end

function NewMainSkillView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillLimitValChg, self.OnSkillLimitValChg)
	self:RegisterGameEvent(EventID.SkillLimitDel, self.OnSkillLimitDel)
	self:RegisterGameEvent(EventID.SkillLimitOff, self.OnSkillLimitOff)
	self:RegisterGameEvent(EventID.SkillLimitCancelBtnClick, self.OnSkillLimitCancelBtnClick)
	self:RegisterGameEvent(EventID.DragSkillBegin, self.OnDragSkillBegin)
	self:RegisterGameEvent(EventID.DragSkillEnd, self.OnDragSkillEnd)
	-- self:RegisterGameEvent(EventID.ThirdPlayerSkillSingBreak, self.OnOtherSingBreak)
	-- self:RegisterGameEvent(EventID.MajorBreakSing, self.OnMajorSingBreak)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)
	if self.bMajor then
		self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
		self:RegisterGameEvent(EventID.SkillCustomIndexReplace, self.OnSkillCustomIndexReplace)
		self:RegisterGameEvent(EventID.TriggerSkillUpdate, self.OnTriggerSkillUpdate)
		self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
		self:RegisterGameEvent(EventID.MajorInfoAddBuff, self.OnAddBuff)
		self:RegisterGameEvent(EventID.SimulateMajorSkillCast, self.OnSimulateMajorSkillCast)
		self:RegisterGameEvent(EventID.MajorSkillCastFailed, self.OnSkillCastFailed)
	else
		self:RegisterGameEvent(EventID.SkillSystemUnselectButton, self.OnSkillSystemUnselectButton)
		self:RegisterGameEvent(EventID.SkillSystemPostUseSkill, self.OnSkillSystemPostUseSkill)
		self:RegisterGameEvent(EventID.SkillSystemReplace, self.OnSkillSystemReplace)
		
	end
	self:RegisterGameEvent(EventID.EndUseLimitSkill, self.OnLimitSkillEnd)

	self:RegisterGameEvent(EventID.StorageStart, self.StartStorageAnim)
	self:RegisterGameEvent(EventID.StorageEnd, self.StopStorageAnim)

	self:RegisterGameEvent(EventID.SkillGuideStart, self.StartStorageAnim)
	self:RegisterGameEvent(EventID.SkillGuideEnd, self.StopStorageAnim)
end

function NewMainSkillView:OnRegisterBinder()
	
end

--技能按钮事件转发
function NewMainSkillView:OnMajorUseSkill(Params)
	local Index = Params.ULongParam1
	if Index > 0 then
		local SkillBtn = self.SkillSystemMap[Index]
		if SkillBtn and SkillBtn:GetIsShowView() then
			SkillBtn:OnGameEventMajorUseSkill(Params)
		end
	end
end

function NewMainSkillView:OnSimulateMajorSkillCast(Index)
	if Index > 0 then
		local SkillBtn = self.SkillSystemMap[Index]
		if SkillBtn and SkillBtn:GetIsShowView() then
			SkillBtn:OnPrepareCastSkill()
    		SkillBtn:OnCastSkill()
		end
	end
end

function NewMainSkillView:OnSkillCastFailed(Index)

	if Index > 0 then
		local SkillBtn = self.SkillSystemMap[Index]
		if SkillBtn and SkillBtn:GetIsShowView() then
			SkillBtn:SkillCastFailed()
		end
	end
end

function NewMainSkillView:StartStorageAnim(Params)
	local SkillView = self.SkillSystemMap[Params.Index]
	if SkillView then
		SkillView:StartStorageAnim(Params)
	end
end

function NewMainSkillView:StopStorageAnim(Params)
	local SkillView = self.SkillSystemMap[Params.Index]
	if SkillView then
		SkillView:StopStorageAnim(Params)
	end
end
----技能按钮事件转发END


function NewMainSkillView:OnTriggerSkillUpdate(Index)
	local TriggerView = self.TriggerMap[Index]
	if not TriggerView then
		return
	end
	local TriggerVisible = TriggerView:GetCanUse()
	local TriggerData = _G.MajorTriggerSkillMgr:GetTriggerDataByIndex(Index)
	local ShouldVisible = (TriggerData.IsTrigger and TriggerData.IsShow) or false
	local IsForbidPerdueSkill = _G.MajorTriggerSkillMgr.IsForbidPerdueSkill
	if IsForbidPerdueSkill then
		ShouldVisible = false
	end
	if ShouldVisible and TriggerVisible then
		TriggerView:UpdateTriggerData(TriggerData)
	elseif ShouldVisible ~= TriggerVisible then
		self:TriggerBtnVisibleChanged(TriggerView, ShouldVisible, Index)
	end
end

function NewMainSkillView:TriggerBtnVisibleChanged(TriggerView, bVisible, Index)
	TriggerView:UpdateCanUse(bVisible)
	self:OnTriggerBtnVisibleChanged(bVisible, Index)
end

function NewMainSkillView:CheckSubTriggerView()
	for Index, TriggerView in pairs(self.TriggerMap) do
		local TriggerData = _G.MajorTriggerSkillMgr:GetTriggerDataByIndex(Index)
		local ShouldVisible = (TriggerData.IsTrigger and TriggerData.IsShow) or false
		local IsForbidPerdueSkill = _G.MajorTriggerSkillMgr.IsForbidPerdueSkill
		if IsForbidPerdueSkill then
			ShouldVisible = false
		end
		local Visibility = ShouldVisible and ESlateVisibility.Visible or ESlateVisibility.Collapsed
		TriggerView:SetVisibleEnum(Visibility)
	end
end

function NewMainSkillView:OnSkillCustomIndexReplace(CustomIndexMap)
	if not CustomIndexMap then
		return
	end

	-- 因为DoCustomIndexReplace过程中会更改AbleSkillMap, 需要单独构造一个List进行遍历
	local ViewList = {}
	for _, View in pairs(self.AbleSkillMap) do
		ViewList[#ViewList + 1] = View
	end
	for i = 1, #ViewList do
		ViewList[i]:DoCustomIndexReplace(CustomIndexMap)
	end
end

function NewMainSkillView:OnSkillReplace(Params)
	local AbleView = self.AbleSkillMap[Params.SkillIndex]
	if AbleView then
		local ValidSkill = Params.SkillID ~= nil and Params.SkillID ~= 0
		if AbleView:GetIsShowView() then
			if not ValidSkill then
				AbleView:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			else
				AbleView:OnSkillReplace(Params)
			end
		elseif ValidSkill then
			AbleView:SetVisibility(_G.UE.ESlateVisibility.Visible)
		end
	end
end
--NewMainSkillView这里需要处理极限技和常规技能组相关的交互
------------------------------ begin ------------------------------
function NewMainSkillView:OnEventMajorProfSwitch(Params)
	local bProfLevelBase = MajorUtil.IsProfBase()--不确定和LimitMgr的Event哪个先响应。。。
	local CanUseLimitSkill = _G.SkillLimitMgr.CanUseLimitSkill
	
	FLOG_INFO("SkillLimitMgr NewMainSkillView EventProfSwitch bBaseProf:%s CanUseLimitSkill:%s"
		, tostring(bProfLevelBase), tostring(CanUseLimitSkill))
	if bProfLevelBase or not CanUseLimitSkill or CanUseLimitSkill == 0 then
		UIUtil.SetIsVisible(self.LimitRoot, false)
	else
		UIUtil.SetIsVisible(self.LimitRoot, true)
	end
end

function NewMainSkillView:OnDragSkillBegin()
	if self.SkillLimitState == 1 then
		UIUtil.SetIsVisible(self.SkillLimitEntrance, false)
	end
end

function NewMainSkillView:OnDragSkillEnd()
	if self.SkillLimitState == 1 then
		UIUtil.SetIsVisible(self.SkillLimitEntrance, true)
		UIViewMgr:HideView(UIViewID.SkillCancelJoyStick)
	elseif self.SkillLimitState == 2 then
		UIViewMgr:HideView(UIViewID.SkillCancelJoyStick)
		--self.CancelJoyStick:SetVisibility(_G.UE.ESlateVisibility.Visible)
	end
end

function NewMainSkillView:OnLimitSkillEnd(Params)
	if _G.SkillLimitMgr.EntranceLoopAniming then
		_G.SkillLimitMgr.EntranceLoopAniming = false
		self.SkillLimitEntrance:StopSingLoopAnim(true)
	end
end

function NewMainSkillView:OnAddBuff(Params)
    local RoleVM = MajorUtil.GetMajorRoleVM()
    if nil == RoleVM then
        return
    end
    local ProfID = RoleVM.Prof
	
    if ProfID then
        local Cfg = QteSkilldisplayCfg:FindCfgByProfID(ProfID)
        if Cfg and Cfg.DisplayTpye == 1 and Cfg.DisplayDuration  > 0 then
            if Params.BuffID == Cfg.BuffID then
                local TriggerView = self.Trigger1
                if not TriggerView then
                    return
                end
                local SkillID = Cfg.SkillID
                local TriggerData = {}
                TriggerData.SkillID = SkillID
                TriggerData.ExpireTime = 0
                TriggerData.ExpireTimerID = 0
                TriggerData.FullTime = 0
                TriggerData.LastCount = 1
                TriggerData.IsTrigger = true
                TriggerData.IsShow = true
                TriggerView:UpdateTriggerData(TriggerData)
                TriggerView:SimulateTriggerSkill(SkillID,Cfg.DisplayDuration)
            end
        end
    end
end



-- function NewMainSkillView:OnMajorSingBreak(Params)
-- 	if _G.SkillLimitMgr.SkillSingUILoopAniming then
-- 		_G.SkillLimitMgr.SkillSingUILoopAniming = false
-- 		self.SkillLimitEntrance:StopSingLoopAnim(true)
-- 		self.SkillLimit:StopSingLoopAnim(true)
-- 	end
-- end

-- function NewMainSkillView:OnOtherSingBreak(Params)
-- 	if _G.SkillLimitMgr.EntranceLoopAniming then
-- 		_G.SkillLimitMgr.EntranceLoopAniming = false
-- 		self.SkillLimitEntrance:StopSingLoopAnim(true)
-- 	end
-- end

--切换到右上角的极限技入口
function NewMainSkillView:OnSkillLimitCancelBtnClick()
	if self.SkillLimitState == 2 then
		self.SkillLimitState = 1
		MainControlPanelVM.bLimitCastState = true
		-- if _G.SkillLimitMgr.SkillSingUILoopAniming then
		-- 	self.SkillLimit:StopSingLoopAnim()
		-- end
		
		UIUtil.SetIsVisible(self.Root, true)

		if _G.SkillLimitMgr.CanUseLimitSkill == 1 then
			UIUtil.SetIsVisible(self.SkillLimitEntrance, true)
			self.SkillLimitEntrance:RefreshUI()
		else
			UIUtil.SetIsVisible(self.SkillLimitEntrance, false)
		end

		UIUtil.SetIsVisible(self.SkillLimit, false)
		UIUtil.SetIsVisible(self.BackSkillGenAttackBtn, false)
		-- UIViewMgr:HideView(UIViewID.SkillCancelJoyStick, true)
		--self.CancelJoyStick:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
		
		if _G.SkillLimitMgr.EntranceLoopAniming then
			self.SkillLimitEntrance:PlaySingLoopAnim()
		end
	end
end

--切换到右下角的极限技释放状态
function NewMainSkillView:SwitchToLimitSkillCastState()
	self.SkillLimitState = 2

	self:DoSwithchToLimitSkillCastState()
end

function NewMainSkillView:DoSwithchToLimitSkillCastState()
	if _G.SkillLimitMgr.EntranceLoopAniming then
		self.SkillLimitEntrance:StopSingLoopAnim()
	end
	UIUtil.SetIsVisible(self.Root, false)
	UIUtil.SetIsVisible(self.SkillLimitEntrance, false)
	UIUtil.SetIsVisible(self.SkillLimit, true, true)
	UIUtil.SetIsVisible(self.SkillLimit.FBtn_Skill, true, false)

	self.SkillLimit:RefreshUI()

	-- if _G.SkillLimitMgr.SkillSingUILoopAniming then
	-- 	self.SkillLimit:PlaySingLoopAnim()
	-- end

	--显示取消按钮 副摇杆和极限技公用
	--取消按钮
		-- 点击是取消极限技释放，回到入口ui
		-- 副摇杆不需要点击，只是需要鼠标移动到那即可
	MainControlPanelVM.bLimitCastState = false
	UIUtil.SetIsVisible(self.BackSkillGenAttackBtn, true)
	-- UIViewMgr:ShowView(UIViewID.SkillCancelJoyStick, {bCastState = true})
end

--没有极限技的ui
function NewMainSkillView:OnSkillLimitDel()
	self.ShowLimitUI = nil
	self.SkillLimitState = 1
	MainControlPanelVM.bLimitCastState = true

	UIUtil.SetIsVisible(self.SkillLimitEntrance, false)
	UIUtil.SetIsVisible(self.SkillLimit, false)
	UIUtil.SetIsVisible(self.Root, true)

	UIUtil.SetIsVisible(self.BackSkillGenAttackBtn, false)
	-- UIViewMgr:HideView(UIViewID.SkillCancelJoyStick, true)
end

function NewMainSkillView:OnSkillLimitOff(CurPhaseVal, CurPhase, CurSkillID)
	self.ShowLimitUI = true

	local MaxValue = _G.SkillLimitMgr:GetLimitMaxValue()
	if MaxValue > 0 and self.bMajor then
		--然后看当前是处于哪个状态，右上角状态还是右下角状态
		if self.SkillLimitState == 2 then	--释放状态（显示右下角的技能释放）
			self:DoSwithchToLimitSkillCastState()
		else --显示右上角入口的状态
			UIUtil.SetIsVisible(self.SkillLimitEntrance, true)
			UIUtil.SetIsVisible(self.SkillLimit, false)
			UIUtil.SetIsVisible(self.SkillLimit.FBtn_Skill, true, true)

			self.SkillLimitEntrance:RefreshUI()
		end
	else
		self:OnSkillLimitDel()
	end
end

function NewMainSkillView:NeedPlayPhaseBarEff(CurPhase)
	local IsPlayPhaseBarEff = false
	if self.LastPhase and self.LastPhase ~= CurPhase then
		IsPlayPhaseBarEff = true
		self.LastPhase = CurPhase
	end

	if not self.LastPhase or CurPhase == 0 then
		self.LastPhase = CurPhase
	end

	return IsPlayPhaseBarEff
end

function NewMainSkillView:OnSkillLimitValChg(CurPhaseVal, CurPhase, CurSkillID)	
	if _G.SkillLimitMgr.CanUseLimitSkill ~= 1 then	--不能使用极限技
		return 
	end

	if not self.ShowLimitUI then
		self:OnSkillLimitOff(CurPhaseVal, CurPhase, CurSkillID)
	end

	local IsPlayPhaseBarEff = self:NeedPlayPhaseBarEff(CurPhase)

	local LimitSkillID = _G.SkillLimitMgr:GetLimitSkillID()
	local LimitSkillIndex = _G.SkillLimitMgr:GetLimitSkillIndex()
	if self.SkillLimitState == 2 and self.SkillLimit:IsVisible() then
		if LimitSkillID > 0 then
			self.SkillLimit:SkillReplace({SkillIndex = LimitSkillIndex, SkillID = LimitSkillID})
		end
		self.SkillLimit:RefreshUI(IsPlayPhaseBarEff)
	elseif self.SkillLimitEntrance:IsVisible() then
		if LimitSkillID > 0 then
			self.SkillLimitEntrance:SkillReplace({SkillIndex = LimitSkillIndex, SkillID = LimitSkillID})
		end
		self.SkillLimitEntrance:RefreshUI(IsPlayPhaseBarEff)
	end
end

------------------------------ end ------------------------------

function NewMainSkillView:ViewSwitchFight()
	local AnimMap = self.MapTypeAnimMap[self.MapType or EMapType.PVE]
	self:StopAnimation(AnimMap.Out)
	self:PlayAnimationToEndTime(AnimMap.In)
end

function NewMainSkillView:ViewSwitchPeace()
	local AnimMap = self.MapTypeAnimMap[self.MapType or EMapType.PVE]
	self:StopAnimation(AnimMap.In)
	self:PlayAnimationToEndTime(AnimMap.Out)
end

function NewMainSkillView:ShowView(Params, IsInheritedParams)
	self.Super:ShowView(Params, IsInheritedParams)
	_G.EventMgr:SendEvent(EventID.SkillMainPanelShow, {EntityID = self.EntityID})
end

function NewMainSkillView:OnSimulateReplaceClicked(Index, Data)
	_G.EventMgr:PostEvent(_G.EventID.SkillSystemDetailsChange, {
		SeriesIndex = Index, SkillID = Data.SkillID, ButtonIndex = self.SkillExpand.ButtonIndex
	})
	local ButtonIndex = self.SkillExpand.ButtonIndex
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	LogicData:SkillMoveTo(0, ButtonIndex, Index)
	_G.EventMgr:SendEvent(EventID.PlayerPrepareCastSkill, {EntityID = self.EntityID, Index = ButtonIndex, Data.SkillID})
end

function NewMainSkillView:OnTriggerBtnVisibleChanged(bVisible, ButtonIndex)
	local Widget = self["AntiPenetratePanel" .. tostring(AntiPenetrateTriggerBtnMap[ButtonIndex])]
	if Widget then
		UIUtil.SetIsVisible(Widget, bVisible, true)
	end
end

-- SkillCancelJoyStick是共用的View, 像技能系统中, 也可能触发其显隐的改变. 因此, 从其他界面回来时, 如果极限技在状态2, 恢复一下可见性
function NewMainSkillView:OnActive()
	if self.SkillLimitState == 2 then
		MainControlPanelVM.bLimitCastState = false
		UIUtil.SetIsVisible(self.BackSkillGenAttackBtn, true)
		-- UIViewMgr:ShowView(UIViewID.SkillCancelJoyStick, {bCastState = true})
	end
end

function NewMainSkillView:OnSkillSystemUnselectButton(Index)
	local View = self.SkillSystemMap[Index]
	if View then
		View:PlayerUnselectButton()
	end
end

function NewMainSkillView:OnSkillSystemPostUseSkill(Params)
	local View = self.SkillSystemMap[Params.Index]
	if View then
		View:OnPlayerUseSkill(Params)
	end
end

function NewMainSkillView:OnSkillSystemReplace(Params)
	local View = self.SkillSystemMap[Params.SkillIndex]
	if View then
		View:OnSkillReplace(Params)
	end
end
function NewMainSkillView:OnButtonIndexChanged(LastButtonIndex, NewButtonIndex, View)
	local AbleSkillMap = self.AbleSkillMap
	if AbleSkillMap then
		AbleSkillMap[NewButtonIndex] = View
	end

	-- SkillSystemMap主界面也会用, 先注释掉
	-- if self.bMajor then
	-- 	return
	-- end
	local SkillSystemMap = self.SkillSystemMap
	if SkillSystemMap then
		SkillSystemMap[NewButtonIndex] = View
	end
end

function NewMainSkillView:DoCustomIndexReplace()
	local CustomIndexMap = SkillCustomMgr:GetCustomIndexMap(self.bMajor)
	if CustomIndexMap then
		self:OnSkillCustomIndexReplace(CustomIndexMap)
	end
end

return NewMainSkillView