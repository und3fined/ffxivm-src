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
---@field ImgUnknown UFImage
---@field JobSlot CommPlayerSimpleJobSlotView
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
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
	--self.ImgUnknown = nil
	--self.JobSlot = nil
	--self.TextLevel = nil
	--self.TextName = nil
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
		{ "ImgBgNormalConfirmVisible", UIBinderSetIsVisible.New(self, self.ImgBgNormalConfirm)},
		{ "ImgBgSelfConfirmVisible", UIBinderSetIsVisible.New(self, self.ImgBgSelfConfirm)},
		{ "ImgBgSelfVisible", UIBinderSetIsVisible.New(self, self.ImgBgSelf)},
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

	-- 更新选中图片显隐
	self.VM.ImgBgNormalConfirmVisible = IsConfirmed and not IsMajor
	self.VM.ImgBgSelfConfirmVisible = IsConfirmed and IsMajor
	self.VM.ImgBgNormalVisible = not IsConfirmed and not IsMajor
	self.VM.ImgBgSelfVisible = not IsConfirmed and IsMajor

	-- 更新确认状态
	self.VM.ImgReadyVisible = IsConfirmed
	self.VM.ImgCancelVisible = IsCancel
end

function PerformanceMemberItemView:OnRoleIDValueChanged(RoleID)
	self.VM.ImgBgSelfVisible = RoleID == MajorUtil.GetMajorRoleID()
	self.VM.ImgLeaderVisible = _G.TeamMgr:IsCaptainByRoleID(RoleID)
end

return PerformanceMemberItemView