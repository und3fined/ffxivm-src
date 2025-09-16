---
--- Author: Administrator
--- DateTime: 2024-01-02 19:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local UIUtil = require("Utils/UIUtil")

---@class EntourageConfirmItem : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgAlready UFImage
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
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EntourageConfirmItem = LuaClass(UIView, true)

function EntourageConfirmItem:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgAlready = nil
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
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EntourageConfirmItem:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.JobSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EntourageConfirmItem:OnInit()
	self.Binders = {
		{ "HasReady",	UIBinderValueChangedCallback.New(self, nil, self.OnHasReadyChanged)},
		-- { "IsTeamMateOrMajor",	UIBinderValueChangedCallback.New(self, nil, self.OnIsTeamMateOrMajorChanged)},
		{ "ShowCapIcon", 	   UIBinderSetIsVisible.New(self, self.ImgLeader) },
		{ "Name", 		UIBinderSetText.New(self, self.TextAlready) },
		{ "Name", 		UIBinderSetText.New(self, self.TextWaiting) },
	}

	self.RoleBinders = {
		{ "Name", 		UIBinderSetText.New(self, self.TextPlayerName) },
		{ "Level", 		UIBinderSetText.New(self, self.JobSlot.TextLevel) },
		{ "Prof", 		UIBinderSetProfIcon.New(self, self.JobSlot.ImgJob) },
	}

	self.NonMjRoleBinders = {
		{ "Name", 			UIBinderSetText.New(self, self.TextPlayerName) },
		{ "Level", 			UIBinderSetText.New(self, self.JobSlot.TextLevel) },
		{ "ProfIcon", 		UIBinderSetBrushFromAssetPath.New(self, self.JobSlot.ImgJob) },
	}
end

function EntourageConfirmItem:OnRegisterBinder()
	if not (self.Params and self.Params.Data) then
		return
	end

	self.VM = self.Params.Data
	if self.VM.IsMajor then
		if self.VM.RoleVM then
			self:RegisterBinders(self.VM.RoleVM, self.RoleBinders)
		end
	else
		self:RegisterBinders(self.VM, self.NonMjRoleBinders)
	end

	self:RegisterBinders(self.VM, self.Binders)
end

function EntourageConfirmItem:OnHasReadyChanged(NewValue)
	UIUtil.SetIsVisible(self.ImgAlready, NewValue)
	UIUtil.SetIsVisible(self.ImgReadyBar, NewValue)
	UIUtil.SetIsVisible(self.TextAlready, NewValue)
	UIUtil.SetIsVisible(self.TextWaiting, not NewValue)
end

-- function EntourageConfirmItem:OnIsTeamMateOrMajorChanged(NewValue)
-- 	-- UIUtil.SetIsVisible(self.OtherPanel, not NewValue)
-- 	-- UIUtil.SetIsVisible(self.TextPlayerName, NewValue)
-- end

function EntourageConfirmItem:OnShow()
	UIUtil.SetIsVisible(self.ImgUnknow, false)
	UIUtil.SetIsVisible(self.JobSlot, true)
	UIUtil.SetIsVisible(self.OtherPanel, false)
	UIUtil.SetIsVisible(self.TextPlayerName, true)
end

return EntourageConfirmItem