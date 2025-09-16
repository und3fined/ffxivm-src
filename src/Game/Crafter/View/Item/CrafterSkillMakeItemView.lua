---
--- Author: chriswang
--- DateTime: 2023-08-31 17:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CrafterSkillItemView = require("Game/Crafter/View/Item/CrafterSkillItemView")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")



---@class CrafterSkillMakeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkill UFButton
---@field IconSkill UFImage
---@field ImgMask UFImage
---@field ImgSlot UFImage
---@field PanelNum UFCanvasPanel
---@field TextNum UFTextBlock
---@field AnimClick UWidgetAnimation
---@field Color_Enough LinearColor
---@field Color_NotEnough LinearColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterSkillMakeItemView = LuaClass(CrafterSkillItemView, true)

function CrafterSkillMakeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkill = nil
	--self.IconSkill = nil
	--self.ImgMask = nil
	--self.ImgSlot = nil
	--self.PanelNum = nil
	--self.TextNum = nil
	--self.AnimClick = nil
	--self.Color_Enough = nil
	--self.Color_NotEnough = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterSkillMakeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterSkillMakeItemView:OnInit()
	self.ButtonIndex = 0
	self.Super:OnInit()
end

function CrafterSkillMakeItemView:OnRegisterBinder()
	local Binders = {
		{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill)},
		{"bCommonMask", UIBinderSetIsVisible.New(self, self.ImgMask)},
		{ "bShowMakeCost", UIBinderSetIsVisible.New(self, self.PanelNum) },
		{ "bMKEnough", UIBinderValueChangedCallback.New(self, nil, self.OnMKEnoughChanged) },
		{ "MakeCost", UIBinderSetText.New(self, self.TextNum) },
	}

	local VM = self.BaseBtnVM
	VM.bShowMakeCost = false
	VM.bMKEnough = true
	VM.MakeCost = 0

	self:RegisterBinders(self.BaseBtnVM, Binders)
end

return CrafterSkillMakeItemView