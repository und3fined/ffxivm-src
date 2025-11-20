---
--- Author: chaooren
--- DateTime: 2022-03-18 12:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local MainControlPanelVM = require("Game/Main/VM/MainControlPanelVM")
local MajorUtil = require("Utils/MajorUtil")
local MainSkillPanelBaseVM = require("Game/MainSkillPanelBase/MainSkillPanelBaseVM")

local ESlateVisibility = _G.UE.ESlateVisibility

---@class MainSkillPanelBase : UIView
local MainSkillPanelBase = LuaClass(UIView, true)

function MainSkillPanelBase:Ctor()
	
end

function MainSkillPanelBase:OnRegisterSubView()
    self.SkillSystemMap = {}
	self.AbleSkillMap = {}
    self.TriggerMap = {}
end
function MainSkillPanelBase:AddSubView(View)
	self.Super:AddSubView(View)

	if View then
		local ButtonIndex = View.ButtonIndex
		if ButtonIndex ~= nil then
			self.SkillSystemMap[ButtonIndex] = View

			if View.bAbleBtn then
				self.AbleSkillMap[ButtonIndex] = View
			end
		end
	end
end

local SkillLimitState = {
	NoLimit = 0,		--不显示极限技
	LimitVisible = 1,	--显示极限技入口
	LimitCast = 2,		--显示极限技释放界面
}

function MainSkillPanelBase:OnInit()
	rawset(self, "bMainSkillPanel", true)

	self.MainSkillPanelBaseVM = MainSkillPanelBaseVM.New()
end

function MainSkillPanelBase:OnEntityIDUpdate(EntityID, bMajor, MapType)
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

function MainSkillPanelBase:OnShow()
    if self.bMajor then

		self:OnEventMajorProfSwitch()

		self:OnSkillLimitDel()

		self:InitSkillLimitVisible()

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
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		for Index, View in pairs(self.SkillSystemMap) do
			if LogicData:GetBtnSkillID(Index) > 0 then
				View:SetVisibleEnum(ESlateVisibility.Visible)
			else
				View:SetVisibleEnum(ESlateVisibility.Collapsed)
			end
		end
	end
end

function MainSkillPanelBase:OnHide()

end

function MainSkillPanelBase:OnDestroy()

end

local AntiPenetrateTriggerBtnMap = {
	[7] = 5,
	[6] = 6
}

function MainSkillPanelBase:OnRegisterUIEvent()
	
end

function MainSkillPanelBase:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillLimitValChg, self.OnSkillLimitValChg)
	self:RegisterGameEvent(EventID.SkillLimitDel, self.OnSkillLimitDel)
	self:RegisterGameEvent(EventID.SkillLimitOff, self.OnSkillLimitOff)
	self:RegisterGameEvent(EventID.SkillLimitCancelBtnClick, self.OnSkillLimitCancelBtnClick)

	self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)

	if self.bMajor then
		self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
		self:RegisterGameEvent(EventID.TriggerSkillUpdate, self.OnTriggerSkillUpdate)
		self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
		self:RegisterGameEvent(EventID.SimulateMajorSkillCast, self.OnSimulateMajorSkillCast)
		self:RegisterGameEvent(EventID.MajorSkillCastFailed, self.OnSkillCastFailed)
	end

	self:RegisterGameEvent(EventID.StorageStart, self.StartStorageAnim)
	self:RegisterGameEvent(EventID.StorageEnd, self.StopStorageAnim)

	self:RegisterGameEvent(EventID.SkillGuideStart, self.StartStorageAnim)
	self:RegisterGameEvent(EventID.SkillGuideEnd, self.StopStorageAnim)
end

function MainSkillPanelBase:OnRegisterBinder()
	
end

--技能按钮事件转发
function MainSkillPanelBase:OnMajorUseSkill(Params)
	local Index = Params.ULongParam1
	if Index > 0 then
		local SkillBtn = self.SkillSystemMap[Index]
		if SkillBtn and SkillBtn:GetIsShowView() then
			SkillBtn:OnGameEventMajorUseSkill(Params)
		end
	end
end

function MainSkillPanelBase:OnSimulateMajorSkillCast(Index)
	if Index > 0 then
		local SkillBtn = self.SkillSystemMap[Index]
		if SkillBtn and SkillBtn:GetIsShowView() then
			SkillBtn:OnPrepareCastSkill()
    		SkillBtn:OnCastSkill()
		end
	end
end

function MainSkillPanelBase:OnSkillCastFailed(Index)

	if Index > 0 then
		local SkillBtn = self.SkillSystemMap[Index]
		if SkillBtn and SkillBtn:GetIsShowView() then
			SkillBtn:SkillCastFailed()
		end
	end
end

function MainSkillPanelBase:StartStorageAnim(Params)
	local SkillView = self.SkillSystemMap[Params.Index]
	if SkillView then
		SkillView:StartStorageAnim(Params)
	end
end

function MainSkillPanelBase:StopStorageAnim(Params)
	local SkillView = self.SkillSystemMap[Params.Index]
	if SkillView then
		SkillView:StopStorageAnim(Params)
	end
end
----技能按钮事件转发END


function MainSkillPanelBase:OnTriggerSkillUpdate(Index)
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

function MainSkillPanelBase:TriggerBtnVisibleChanged(TriggerView, bVisible, Index)
	TriggerView:UpdateCanUse(bVisible)
	self:OnTriggerBtnVisibleChanged(bVisible, Index)
end

function MainSkillPanelBase:CheckSubTriggerView()
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

function MainSkillPanelBase:OnSkillReplace(Params)
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

function MainSkillPanelBase:ShowView(Params, IsInheritedParams)
	self.Super:ShowView(Params, IsInheritedParams)
	_G.EventMgr:SendEvent(EventID.SkillMainPanelShow, {EntityID = self.EntityID})
end

function MainSkillPanelBase:OnTriggerBtnVisibleChanged(bVisible, ButtonIndex)
	
end

function MainSkillPanelBase:ViewSwitchFight()

end

function MainSkillPanelBase:ViewSwitchPeace()

end

function MainSkillPanelBase:OnActive()
	if self.MainSkillPanelBaseVM:GetLimitState() == SkillLimitState.LimitCast then
		MainControlPanelVM.bLimitCastState = false
	end
end

function MainSkillPanelBase:OnEventMajorProfSwitch(Params)
	local bProfLevelBase = MajorUtil.IsProfBase()--不确定和LimitMgr的Event哪个先响应。。。
	local CanUseLimitSkill = _G.SkillLimitMgr.CanUseLimitSkill
	local bLimitVisible = not bProfLevelBase and CanUseLimitSkill and CanUseLimitSkill ~= 0
	local LimitData = _G.SkillLimitMgr.LimitData
	local MaxValue = _G.SkillLimitMgr:GetLimitMaxValue()
	bLimitVisible = bLimitVisible and LimitData and LimitData.IsOpen and MaxValue > 0
	self.MainSkillPanelBaseVM:SetLimitState(bLimitVisible and SkillLimitState.LimitVisible or SkillLimitState.NoLimit)
end

function MainSkillPanelBase:OnSkillLimitValChg(CurPhaseVal, CurPhase, CurSkillID)
	if _G.SkillLimitMgr.CanUseLimitSkill ~= 1 then	--不能使用极限技
		return
	end

	local VM = self.MainSkillPanelBaseVM
	-- if VM:GetLimitState() == SkillLimitState.NoLimit then
	-- 	VM:SetLimitState(SkillLimitState.LimitVisible)
	-- end
	if not self.ShowLimitUI then
		self:OnSkillLimitOff(CurPhaseVal, CurPhase, CurSkillID)
	end
	local IsPlayPhaseBarEff = self:NeedPlayPhaseBarEff(CurPhase)

	local LimitSkillID = _G.SkillLimitMgr:GetLimitSkillID()
	local LimitSkillIndex = _G.SkillLimitMgr:GetLimitSkillIndex()
	if VM:GetLimitState() == 2 and self.SkillLimit:IsVisible() then
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

function MainSkillPanelBase:NeedPlayPhaseBarEff(CurPhase)
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

--切换到右上角的极限技入口
function MainSkillPanelBase:OnSkillLimitCancelBtnClick()
	if self.MainSkillPanelBaseVM:GetLimitState() == SkillLimitState.LimitCast then
		self.MainSkillPanelBaseVM:SetLimitState(SkillLimitState.LimitVisible)
		MainControlPanelVM.bLimitCastState = true
	end
end

--切换到右下角的极限技释放状态
function MainSkillPanelBase:SwitchToLimitSkillCastState()
	self.MainSkillPanelBaseVM:SetLimitState(SkillLimitState.LimitCast)
	MainControlPanelVM.bLimitCastState = false
end

--没有极限技的ui
function MainSkillPanelBase:OnSkillLimitDel()
	self.ShowLimitUI = nil
	self.MainSkillPanelBaseVM:SetLimitState(SkillLimitState.NoLimit)
	MainControlPanelVM.bLimitCastState = true
end

--In LimitState
function MainSkillPanelBase:OnSkillLimitOff(CurPhaseVal, CurPhase, CurSkillID)
	self.ShowLimitUI = true
	local MaxValue = _G.SkillLimitMgr:GetLimitMaxValue()
	if MaxValue > 0 and self.bMajor then
		self.MainSkillPanelBaseVM:SetLimitState(SkillLimitState.LimitVisible)
		MainControlPanelVM.bLimitCastState = true
	else
		self:OnSkillLimitDel()
	end
end

function MainSkillPanelBase:InitSkillLimitVisible()
	local bProfLevelBase = MajorUtil.IsProfBase()--不确定和LimitMgr的Event哪个先响应。。。
	local CanUseLimitSkill = _G.SkillLimitMgr.CanUseLimitSkill
	local bLimitVisible = not bProfLevelBase and CanUseLimitSkill and CanUseLimitSkill ~= 0
	local LimitData = _G.SkillLimitMgr.LimitData
	if bLimitVisible and LimitData and LimitData.IsOpen then
		self:OnSkillLimitOff()
	end
end

return MainSkillPanelBase