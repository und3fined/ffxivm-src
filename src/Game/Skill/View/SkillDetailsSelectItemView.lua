---
--- Author: chaooren
--- DateTime: 2023-03-16 17:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderCanvasSlotSetSize = require("Binder/UIBinderCanvasSlotSetSize")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class SkillDetailsSelectItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot CommonRedDotView
---@field FImg_Mask UFImage
---@field FImg_Select UFImage
---@field FImg_Slot UFImage
---@field Icon_Skill UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillDetailsSelectItemView = LuaClass(UIView, true)

function SkillDetailsSelectItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot = nil
	--self.FImg_Mask = nil
	--self.FImg_Select = nil
	--self.FImg_Slot = nil
	--self.Icon_Skill = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillDetailsSelectItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillDetailsSelectItemView:OnInit()
	local Binders = {
		{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill) },
		{ "bSelected", UIBinderSetIsVisible.New(self, self.FImg_Select) },
		{ "ImgSize", UIBinderCanvasSlotSetSize.New(self, self.FImg_Slot, true)},
		{ "IconSize", UIBinderCanvasSlotSetSize.New(self, self.Icon_Skill, true)},
		{ "MaskSize", UIBinderCanvasSlotSetSize.New(self, self.FImg_Mask, true)},
		{ "RedDotNum", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotNumChanged) },
	}

	self.Binders = Binders
	self.CommonRedDot.IsCustomizeRedDot = true
end

function SkillDetailsSelectItemView:OnDestroy()

end

function SkillDetailsSelectItemView:OnShow()
	UIUtil.SetIsVisible(self.CommonRedDot, true)
end

function SkillDetailsSelectItemView:OnHide()

end

function SkillDetailsSelectItemView:OnRegisterUIEvent()

end

function SkillDetailsSelectItemView:OnRegisterGameEvent()

end

function SkillDetailsSelectItemView:OnRegisterBinder()
	self:RegisterBinders(self.Params, self.Binders)
end

function SkillDetailsSelectItemView:OnRedDotNumChanged(NewValue)
	if NewValue ~= nil then
		self.CommonRedDot:SetRedDotNumByNumber(NewValue)
	end
end

return SkillDetailsSelectItemView