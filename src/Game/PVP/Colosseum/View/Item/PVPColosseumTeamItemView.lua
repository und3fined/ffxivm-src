---
--- Author: peterxie
--- DateTime:
--- Description: 我方队伍成员 参考MainTeamItemView
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableViewEx = require("Game/Buff/UIAdapterTableViewEx")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local LocalHpBarAnimProxy = require("Game/Team/LocalHpBarAnimProxy")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")


---@class PVPColosseumTeamItemView : UIView
---@field ViewModel TeamMemberVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonTeam UFButton
---@field EFF_ProBarLight UFImage
---@field EffectProBarLBFull UFCanvasPanel
---@field ImgDie UFImage
---@field ImgJob UFImage
---@field ImgJobSelected UFImage
---@field ImgProBarLBUnder URadialImage
---@field ImgProbar UFImage
---@field ImgTag UFImage
---@field LowBroodEffect UFImage
---@field PanelDie UFCanvasPanel
---@field PanelProBar UFCanvasPanel
---@field PanelProBarLB UFCanvasPanel
---@field PanelSelected UFCanvasPanel
---@field PanelTeamItem UFCanvasPanel
---@field ProBarBlood UProgressBar
---@field ProBarBloodLimitIncrease UProgressBar
---@field ProBarBloodLimitReduce UProgressBar
---@field ProBarShied UProgressBar
---@field TableViewBuffer UTableView
---@field TextPlayerName UFTextBlock
---@field TextTime UFTextBlock
---@field AnimMicLoop UWidgetAnimation
---@field AnimProBarLBFull UWidgetAnimation
---@field AnimProBarLightAdd UWidgetAnimation
---@field AnimProBarLightSubtract UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumTeamItemView = LuaClass(UIView, true)

function PVPColosseumTeamItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonTeam = nil
	--self.EFF_ProBarLight = nil
	--self.EffectProBarLBFull = nil
	--self.ImgDie = nil
	--self.ImgJob = nil
	--self.ImgJobSelected = nil
	--self.ImgProBarLBUnder = nil
	--self.ImgProbar = nil
	--self.ImgTag = nil
	--self.LowBroodEffect = nil
	--self.PanelDie = nil
	--self.PanelProBar = nil
	--self.PanelProBarLB = nil
	--self.PanelSelected = nil
	--self.PanelTeamItem = nil
	--self.ProBarBlood = nil
	--self.ProBarBloodLimitIncrease = nil
	--self.ProBarBloodLimitReduce = nil
	--self.ProBarShied = nil
	--self.TableViewBuffer = nil
	--self.TextPlayerName = nil
	--self.TextTime = nil
	--self.AnimMicLoop = nil
	--self.AnimProBarLBFull = nil
	--self.AnimProBarLightAdd = nil
	--self.AnimProBarLightSubtract = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamItemView:OnInit()
	self.AdapterBuffer = UIAdapterTableViewEx.CreateAdapter(self, self.TableViewBuffer)
	self.AdapterBuffer:UpdateSettings(8, nil, false, false, false, true)

	self.HpBarAnimProxy = LocalHpBarAnimProxy.New(self, self.ProBarBlood, self.AnimProBarLightAdd, self.AnimProBarLightSubtract,  self.EFF_ProBarLight, self.EFF_ProBarLight)

	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)

	self.MemBinders = {
		{ "ProfID", 			UIBinderSetProfIcon.New(self, self.ImgJob) },
		{ "BGColor", 			UIBinderSetBrushTintColorHex.New(self, self.ImgProbar) },
		{ "IsSelected", 		UIBinderSetIsVisible.New(self, self.PanelSelected) },

		{ "HPPercent", 			UIBinderSetPercent.New(self, self.ProBarBlood) },
		{ "ShiedPercent", 		UIBinderSetPercent.New(self, self.ProBarShied) },
		{ "IsShiedVisible", 	UIBinderSetIsVisible.New(self, self.ProBarShied) },
		{ "IncreasedPercent",	UIBinderSetPercent.New(self, self.ProBarBloodLimitIncrease) },
		{ "IsMaxHPIncrease", 	UIBinderSetIsVisible.New(self, self.ProBarBloodLimitIncrease) },
		{ "ReducedPercent", 	UIBinderSetPercent.New(self, self.ProBarBloodLimitReduce) },
		{ "IsMaxHPReduce", 		UIBinderSetIsVisible.New(self, self.ProBarBloodLimitReduce) },

		{ "RenderOpacity", 		UIBinderSetRenderOpacity.New(self, self.PanelTeamItem) },
		{ "NameColor", 			UIBinderSetColorAndOpacityHex.New(self, self.TextPlayerName) },
		{ "BuffVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterBuffer) },
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName) },

		-- 血条动效相关
		{ "HPPercent", UIBinderValueChangedCallback.New(self, nil, function(View)
			View:UpdateHpAnim()
		end) },
		{ "ShiedPercent", UIBinderValueChangedCallback.New(self, nil, function(View)
			View:UpdateHpAnim()
		end) },

		-- PVP新增
		{ "LBPercent", 			UIBinderSetPercent.New(self, self.ImgProBarLBUnder) },
		{ "IsLBFull", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedLBPercent) },
		{ "RespawnTime", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRespawnTime) },
		{ "bDead", 				UIBinderSetIsVisible.New(self, self.PanelDie) },
		{ "bDead", 				UIBinderSetIsVisible.New(self, self.TableViewBuffer, true) },
	}
end

function PVPColosseumTeamItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonTeam, self.OnClickButtonTeam)
end

function PVPColosseumTeamItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.MemBinders)
	end
end

function PVPColosseumTeamItemView:GetRoleID()
	return self.ViewModel and self.ViewModel.RoleID or nil
end

local TargetLockType <const> = _G.UE.ETargetLockType.Hard

function PVPColosseumTeamItemView:OnSelectChanged(bSelected)
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	ViewModel:SetIsSelected(bSelected)

	if bSelected and ViewModel.IsSelectSyncScene then
		local EventParams = EventMgr:GetEventParams()
		EventParams.ULongParam1 = ViewModel.EntityID or ActorUtil.GetEntityIDByRoleID(self:GetRoleID())
		EventParams.IntParam2 = TargetLockType
		EventMgr:SendCppEvent(EventID.ManualSelectTarget, EventParams)
	end
end

function PVPColosseumTeamItemView:OnClickButtonTeam()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	if not ViewModel.IsSelected then
		self.Params.Adapter:SetSelectedIndex(self.Params.Index)
		return
	end
end

function PVPColosseumTeamItemView:UpdateHpAnim()
	if self.ViewModel then
		self.HpBarAnimProxy:Upd(self.ViewModel.HPPercent, self.ViewModel.ShiedPercent)

		local HPPercent = self.ViewModel.HPPercent
		local ShowLowHPEffect = HPPercent <= 0.2 and HPPercent > 0
		UIUtil.SetIsVisible(self.LowBroodEffect, ShowLowHPEffect)
	end
end

function PVPColosseumTeamItemView:OnValueChangedLBPercent(Value)
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	local IsLBFull = ViewModel.IsLBFull

	local ShowLBFullEffect = IsLBFull
	UIUtil.SetIsVisible(self.EffectProBarLBFull, ShowLBFullEffect)

	if ShowLBFullEffect then
		self:PlayAnimation(self.AnimProBarLBFull)
	else
		self:StopAnimation(self.AnimProBarLBFull)
	end
end

function PVPColosseumTeamItemView:OnValueChangedRespawnTime(Value)
	local RespawnEndTime = Value
	if RespawnEndTime > 0 then
		self.AdapterCountDownTime:Start(RespawnEndTime, 1, true, true)
	end
end

function PVPColosseumTeamItemView:TimeOutCallback()
	self.TextTime:SetText("")
end

function PVPColosseumTeamItemView:TimeUpdateCallback(LeftTime)
    return tostring(math.ceil(LeftTime))
end

return PVPColosseumTeamItemView