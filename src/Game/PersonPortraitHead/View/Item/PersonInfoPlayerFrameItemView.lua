---
--- Author: Administrator
--- DateTime: 2024-08-06 09:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")


---@class PersonInfoPlayerFrameItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPlayer UFButton
---@field IconClock UFImage
---@field ImgBkg UFImage
---@field ImgFrame UFImage
---@field ImgSelect UFImage
---@field ImgTime UFImage
---@field ImgUse UFImage
---@field TextClock UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoPlayerFrameItemView = LuaClass(UIView, true)

function PersonInfoPlayerFrameItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPlayer = nil
	--self.IconClock = nil
	--self.ImgBkg = nil
	--self.ImgFrame = nil
	--self.ImgSelect = nil
	--self.ImgTime = nil
	--self.ImgUse = nil
	--self.TextClock = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerFrameItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerFrameItemView:OnInit()
	self.Binders = {
		{ "CanUnlock", 	UIBinderSetIsVisible.New(self, self.TextClock) },
		{ "IsInUse", 	UIBinderSetIsVisible.New(self, self.ImgUse) },
		{ "IsSelt", 	UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsShowLockIcon", 	UIBinderSetIsVisible.New(self, self.IconClock) },
		{ "FrameIcon", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgFrame) },
		{ "IsLimitedTime", 		UIBinderSetIsVisible.New(self, self.ImgTime) },

	}

	self.TextClock:SetText(LSTR(960046))
end

function PersonInfoPlayerFrameItemView:OnDestroy()

end

function PersonInfoPlayerFrameItemView:OnShow()

end

function PersonInfoPlayerFrameItemView:OnHide()

end

function PersonInfoPlayerFrameItemView:OnRegisterUIEvent()
    self:RegisterGameEvent(_G.EventID.PersonHeadFrameUnlock, self.OnUnlckFrame)
end

function PersonInfoPlayerFrameItemView:OnRegisterGameEvent()

end

function PersonInfoPlayerFrameItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.VM = Params.Data
	self:RegisterBinders(self.VM, self.Binders)
end

function PersonInfoPlayerFrameItemView:OnUnlckFrame(ResID)
	if ResID == self.VM.FrameResID then
		self:PlayAnimation(self.AnimUnlock)
	end
end

function PersonInfoPlayerFrameItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then
		return
	end

	local VM = Params.Data
	if nil == VM then
		return
	end

	VM.IsSelt = IsSelected
end


return PersonInfoPlayerFrameItemView