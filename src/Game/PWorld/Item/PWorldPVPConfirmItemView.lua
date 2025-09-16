---
--- Author: Administrator
--- DateTime: 2024-11-27 11:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require ("Protocol/ProtoCS")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")

---@class PWorldPVPConfirmItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgAlready UFImage
---@field ImgItemBar UFImage
---@field ImgLeader UFImage
---@field ImgReadyBar UFImage
---@field ImgUnknow UFImage
---@field JobSlot CommPlayerSimpleJobSlotView
---@field OtherPanel UFCanvasPanel
---@field PanelReady UFCanvasPanel
---@field TextAlready UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextWaiting UFTextBlock
---@field AnimChangeJob UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimReadyIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldPVPConfirmItemView = LuaClass(UIView, true)

function PWorldPVPConfirmItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgAlready = nil
	--self.ImgItemBar = nil
	--self.ImgLeader = nil
	--self.ImgReadyBar = nil
	--self.ImgUnknow = nil
	--self.JobSlot = nil
	--self.OtherPanel = nil
	--self.PanelReady = nil
	--self.TextAlready = nil
	--self.TextPlayerName = nil
	--self.TextWaiting = nil
	--self.AnimChangeJob = nil
	--self.AnimIn = nil
	--self.AnimReadyIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldPVPConfirmItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.JobSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldPVPConfirmItemView:OnInit()
	self.TextWaiting:SetText(_G.LSTR(1320153))
	self.TextAlready:SetText(_G.LSTR(1320154))

	self.Binders = {
		{ "HasReady", 	UIBinderSetIsVisible.New(self, self.PanelReady) },
		{ "HasReady", 	UIBinderSetIsVisible.New(self, self.TextAlready) },
		{ "HasReady", 	UIBinderSetIsVisible.New(self, self.TextWaiting, true) },
		{ "HasReady", 	UIBinderValueChangedCallback.New(self, nil, function (_, V)
			if V then
				self:PlayAnimation(self.AnimReadyIn)
			end
		end) },

		{ "IsTeamMateOrMajor", UIBinderSetIsVisible.New(self, self.ImgUnknow, true) },
		{ "IsTeamMateOrMajor", UIBinderSetIsVisible.New(self, self.OtherPanel, true) },
		{ "IsTeamMateOrMajor", UIBinderSetIsVisible.New(self, self.TextPlayerName) },
		{ "IsShowJobSlot", UIBinderSetIsVisible.New(self, self.JobSlot) },
		
		{ "ShowCapIcon", 	   UIBinderSetIsVisible.New(self, self.ImgLeader) },
		{ "PollType", 	UIBinderValueChangedCallback.New(self, nil, self.OnPollTypeChange)}
	}

	self.RoleBinders = {
		{ "Name", 		UIBinderSetText.New(self, self.TextPlayerName) },
		{ "Level", 		UIBinderSetText.New(self, self.JobSlot.TextLevel) },
		{ "Prof", 		UIBinderSetProfIcon.New(self, self.JobSlot.ImgJob) },
		{ "Prof", 		UIBinderValueChangedCallback.New(self, nil, function(_, Prof)
			self:PlayAnimation(self.AnimChangeJob)
		end) },
	}
end

function PWorldPVPConfirmItemView:OnDestroy()

end

function PWorldPVPConfirmItemView:OnShow()

end

function PWorldPVPConfirmItemView:OnHide()

end

function PWorldPVPConfirmItemView:OnRegisterUIEvent()

end

function PWorldPVPConfirmItemView:OnRegisterGameEvent()

end

function PWorldPVPConfirmItemView:OnRegisterBinder()
	if self.Params == nil or self.Params.Data == nil then return end

	self.ViewModel = self.Params.Data
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function PWorldPVPConfirmItemView:OnPollTypeChange(NewValue, OldValue)
	if NewValue == ProtoCS.PollType.PoolType_CrystalConflict then
		if self.ViewModel.RoleVM and self.ViewModel.IsTeamMateOrMajor then
			self:RegisterBinders(self.ViewModel.RoleVM, self.RoleBinders)
		end
	end
end

return PWorldPVPConfirmItemView