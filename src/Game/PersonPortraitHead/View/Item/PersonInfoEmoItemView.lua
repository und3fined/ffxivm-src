---
--- Author: Administrator
--- DateTime: 2024-08-23 15:18
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

---@class PersonInfoEmoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPlayer UFButton
---@field IconEmo UFImage
---@field ImgBkg UFImage
---@field ImgSelect UFImage
---@field TextNot UFTextBlock
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoEmoItemView = LuaClass(UIView, true)

function PersonInfoEmoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPlayer = nil
	--self.IconEmo = nil
	--self.ImgBkg = nil
	--self.ImgSelect = nil
	--self.TextNot = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoEmoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoEmoItemView:OnInit()
	self.Binders = {
		{ "IsSelt", 	UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.TextNot) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.IconEmo, true) },
		{ "EmoIcon", 	UIBinderSetBrushFromAssetPath.New(self, self.IconEmo) },
	}

	self.TextNot:SetText(LSTR(960038))
end

function PersonInfoEmoItemView:OnDestroy()

end

function PersonInfoEmoItemView:OnShow()

end

function PersonInfoEmoItemView:OnHide()

end

function PersonInfoEmoItemView:OnRegisterUIEvent()

end

function PersonInfoEmoItemView:OnRegisterGameEvent()

end

function PersonInfoEmoItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.VM = Params.Data
	self:RegisterBinders(self.VM, self.Binders)
end

function PersonInfoEmoItemView:OnSelectChanged(IsSelected)
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

return PersonInfoEmoItemView