---
--- Author: moodliu
--- DateTime: 2023-11-24 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MusicPerformanceMemberItemVM = require("Game/Performance/VM/MusicPerformanceMemberItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceMemberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBgNormal UFImage
---@field ImgBgNormalConfirm UFImage
---@field ImgBgSelf UFImage
---@field ImgBgSelfConfirm UFImage
---@field ImgCancel UFImage
---@field ImgLeader UFImage
---@field ImgReady UFImage
---@field JobSlot CommPlayerSimpleJobSlotView
---@field PanelReady UFCanvasPanel
---@field PanelState UFCanvasPanel
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimReadyIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceMemberItemView = LuaClass(UIView, true)

function PerformanceMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBgNormal = nil
	--self.ImgBgNormalConfirm = nil
	--self.ImgBgSelf = nil
	--self.ImgBgSelfConfirm = nil
	--self.ImgCancel = nil
	--self.ImgLeader = nil
	--self.ImgReady = nil
	--self.JobSlot = nil
	--self.PanelReady = nil
	--self.PanelState = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--self.AnimReadyIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceMemberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.JobSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceMemberItemView:OnInit()
	self.VM = MusicPerformanceMemberItemVM.New()
	self.JobSlot:SetParams({ ProfID = ProtoCommon.prof_type.PROF_TYPE_BARD })
end

function PerformanceMemberItemView:OnDestroy()

end

function PerformanceMemberItemView:OnShow()
	if _G.TeamMgr:IsCaptainByRoleID(self.Params.Data.RoleID) then
		self.VM.ConfirmStatus = MPDefines.ConfirmStatus.ConfirmStatusConfirm
	else
		self.VM.ConfirmStatus = _G.MusicPerformanceVM.EnsembleConfirmStatus[self.Params.Data.RoleID] or MPDefines.ConfirmStatus.ConfirmStatusNone
	end
end

function PerformanceMemberItemView:OnHide()

end

function PerformanceMemberItemView:OnRegisterUIEvent()
	
end

function PerformanceMemberItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MusicPerformanceEnsembleConfirm, self.OnMusicPerformanceEnsembleConfirm)
end

function PerformanceMemberItemView:OnMusicPerformanceEnsembleConfirm(Params)
	if Params.RoleID == self.Params.Data.RoleID then
		self.VM.ConfirmStatus = Params.ConfirmStatus
	end
end

function PerformanceMemberItemView:OnRegisterBinder()

	local Binders = {
		{ "ImgBgNormalVisible", UIBinderSetIsVisible.New(self, self.ImgBgNormal)},
		{ "ImgBgSelfVisible", UIBinderSetIsVisible.New(self, self.ImgBgSelf)},
		
		{ "ImgBgNormalConfirmVisible", UIBinderSetIsVisible.New(self, self.ImgBgNormalConfirm)},
		{ "ImgBgSelfConfirmVisible", UIBinderSetIsVisible.New(self, self.ImgBgSelfConfirm)},

		{ "ImgLeaderVisible", UIBinderSetIsVisible.New(self, self.ImgLeader)},
		{ "ImgReadyVisible", UIBinderSetIsVisible.New(self, self.ImgReady, false, true)},
		{ "ImgCancelVisible", UIBinderSetIsVisible.New(self, self.ImgCancel, false, true)},
		{ "ConfirmStatus", UIBinderValueChangedCallback.New(self, nil, self.OnConfirmStatusChanged) },
	}

	self:RegisterBinders(self.VM, Binders)

	local RoleBinders = {
		{ "Name", UIBinderSetText.New(self, self.TextName)},
		{ "Level", UIBinderSetText.New(self, self.TextLevel)},
		{ "RoleID", UIBinderValueChangedCallback.New(self, nil, self.OnRoleIDValueChanged)},
	}

	self:RegisterBinders(self.Params.Data, RoleBinders)
end

function PerformanceMemberItemView:OnConfirmStatusChanged(ConfirmStatus)
	local IsMajor = self.Params.Data.IsMajor
	local IsConfirmed = ConfirmStatus == MPDefines.ConfirmStatus.ConfirmStatusConfirm
	local IsCancel = ConfirmStatus == MPDefines.ConfirmStatus.ConfirmStatusCancel

	--ImgBgSelfConfirm、ImgBgNormalConfirm 自己或队员，在确认准备和未准备都显示
	--ImgBgSelf、ImgBgNormal 自己和队员，在拒绝和掉线(无此功能)情况下显示
	self.VM.ImgBgNormalConfirmVisible = not IsCancel and not IsMajor
	self.VM.ImgBgSelfConfirmVisible = not IsCancel and IsMajor
	self.VM.ImgBgNormalVisible = IsCancel and not IsMajor
	self.VM.ImgBgSelfVisible = IsCancel and IsMajor

	-- 更新确认状态
	self.VM.ImgReadyVisible = IsConfirmed
	self.VM.ImgCancelVisible = IsCancel

	--字体颜色
	local TextColor = IsCancel and "d5d5d5ff" or "ffeebbff"
	UIUtil.SetColorAndOpacityHex(self.TextName, TextColor)
	UIUtil.SetColorAndOpacityHex(self.TextLevel, TextColor)

	if IsConfirmed then
		self:PlayAnimation(self.AnimReadyIn)
	end
end

function PerformanceMemberItemView:OnRoleIDValueChanged(RoleID)
	self.VM.ImgLeaderVisible = _G.TeamMgr:IsCaptainByRoleID(RoleID)
end

return PerformanceMemberItemView