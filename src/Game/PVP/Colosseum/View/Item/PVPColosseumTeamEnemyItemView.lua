---
--- Author: peterxie
--- DateTime:
--- Description: 敌方队伍成员
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")


---@class PVPColosseumTeamEnemyItemView : UIView
---@field ViewModel TeamMemberVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EffectProBarLBFull UFCanvasPanel
---@field ImgJob UFImage
---@field ImgJobSelected UFImage
---@field ImgProBarLBUnder URadialImage
---@field ImgProbarBg1 UFImage
---@field LowBroodEffect UFImage
---@field PanelProBarHP UFCanvasPanel
---@field PanelProBarLB UFCanvasPanel
---@field PanelTeamItem UFCanvasPanel
---@field ProBarHP UProgressBar
---@field TextTime UFTextBlock
---@field AnimProBarLBFull UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumTeamEnemyItemView = LuaClass(UIView, true)

function PVPColosseumTeamEnemyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EffectProBarLBFull = nil
	--self.ImgJob = nil
	--self.ImgJobSelected = nil
	--self.ImgProBarLBUnder = nil
	--self.ImgProbarBg1 = nil
	--self.LowBroodEffect = nil
	--self.PanelProBarHP = nil
	--self.PanelProBarLB = nil
	--self.PanelTeamItem = nil
	--self.ProBarHP = nil
	--self.TextTime = nil
	--self.AnimProBarLBFull = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamEnemyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamEnemyItemView:OnInit()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)

	self.MemBinders = {
		{ "ProfID", 			UIBinderSetProfIcon.New(self, self.ImgJob) },
		{ "IsSelected", 		UIBinderSetIsVisible.New(self, self.ImgJobSelected) },
		{ "HPPercent", 			UIBinderSetPercent.New(self, self.ProBarHP) },
		{ "RenderOpacity", 		UIBinderSetRenderOpacity.New(self, self.PanelTeamItem) },

		{ "HPPercent", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHPPercent) },
		{ "IsSelectSyncScene", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsSelectSyncScene) },

		{ "LBPercent", 			UIBinderSetPercent.New(self, self.ImgProBarLBUnder) },
		{ "IsLBFull", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedLBPercent) },
		{ "RespawnTime", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRespawnTime) },
		{ "bDead", 				UIBinderSetIsVisible.New(self, self.PanelProBarLB, true) },
		{ "bDead", 				UIBinderSetIsVisible.New(self, self.PanelProBarHP, true) },
	}
end

function PVPColosseumTeamEnemyItemView:OnDestroy()

end

function PVPColosseumTeamEnemyItemView:OnShow()

end

function PVPColosseumTeamEnemyItemView:OnHide()

end

function PVPColosseumTeamEnemyItemView:OnRegisterUIEvent()

end

function PVPColosseumTeamEnemyItemView:OnRegisterGameEvent()

end

function PVPColosseumTeamEnemyItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.MemBinders)
	end
end

function PVPColosseumTeamEnemyItemView:GetRoleID()
	return self.ViewModel and self.ViewModel.RoleID or nil
end

local TargetLockType <const> = _G.UE.ETargetLockType.Hard

function PVPColosseumTeamEnemyItemView:OnSelectChanged(bSelected)
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	if bSelected and ViewModel.IsSelectSyncScene then
		-- 场景内可以选中时才UI选中
		ViewModel:SetIsSelected(bSelected)

		local EventParams = EventMgr:GetEventParams()
		EventParams.ULongParam1 = ViewModel.EntityID or ActorUtil.GetEntityIDByRoleID(self:GetRoleID())
		EventParams.IntParam2 = TargetLockType
		EventMgr:SendCppEvent(EventID.ManualSelectTarget, EventParams)
	end
end


-- 目标是否在可被选择范围，更新相关UI表现
function PVPColosseumTeamEnemyItemView:OnValueChangedIsSelectSyncScene(Value)
	self:OnValueChangedHPPercent()
	self:OnValueChangedLBPercent()
end

function PVPColosseumTeamEnemyItemView:OnValueChangedHPPercent(Value)
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	local ShowLowHPEffect = false
	if ViewModel.IsSelectSyncScene then
		-- 目标可被选择范围时，才显示低血量特效
		local HPPercent = ViewModel.HPPercent
		ShowLowHPEffect = HPPercent <= 0.2 and HPPercent > 0
	end
	UIUtil.SetIsVisible(self.LowBroodEffect, ShowLowHPEffect)
end

function PVPColosseumTeamEnemyItemView:OnValueChangedLBPercent(Value)
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	local IsLBFull = ViewModel.IsLBFull

	local ShowLBFullEffect = false
	if ViewModel.IsSelectSyncScene then
		-- 目标可被选择范围时，才显示满LB特效
		ShowLBFullEffect = IsLBFull
	end
	UIUtil.SetIsVisible(self.EffectProBarLBFull, ShowLBFullEffect)

	if ShowLBFullEffect then
		self:PlayAnimation(self.AnimProBarLBFull)
	else
		self:StopAnimation(self.AnimProBarLBFull)
	end
end

function PVPColosseumTeamEnemyItemView:OnValueChangedRespawnTime(Value)
	local RespawnEndTime = Value
	if RespawnEndTime > 0 then
		self.AdapterCountDownTime:Start(RespawnEndTime, 1, true, true)
	end
end

function PVPColosseumTeamEnemyItemView:TimeOutCallback()
	self.TextTime:SetText("")
end

function PVPColosseumTeamEnemyItemView:TimeUpdateCallback(LeftTime)
    return tostring(math.ceil(LeftTime))
end

return PVPColosseumTeamEnemyItemView