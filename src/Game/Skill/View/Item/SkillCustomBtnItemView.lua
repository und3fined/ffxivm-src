---
--- Author: henghaoli
--- DateTime: 2025-03-15 11:25
--- Description:
---

local LuaClass = require("Core/LuaClass")
local SkillCustomBtnBaseView = require("Game/Skill/View/Item/SkillCustomBtnBaseView")
local UIUtil = require("Utils/UIUtil")
local SkillCustomMgr = require("Game/Skill/SkillCustomMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local WidgetButtonStateVisibleMap = {
                     -- Unavailable  Available  Selected  Dragging  Dragged  ReadyToChange
    ImgSelectHandle = { false,       true,      false,    false,    false,   true,         },
    ImgMask         = { true,        false,     false,    false,    false,   false,        },
    EffectSelect    = { false,       false,     true,     true,     false,   false,        },
    ImgSwitch       = { false,       true,      true,     false,    true,    false,        },
}

local VMPropButtonStateMap = {
                 -- Unavailable  Available  Selected  Dragging  Dragged  ReadyToChange
    Opacity     = { 1,           1,         1,        1,        0.5,     1,            },
    Scale       = { 1,           1,         1,        1,        1,       1.2           },
    ImgSwitchOn = { false,       false,     true,     false,    true,    false,        },
	bAbsorbLoop = { false,       false,     false,    false,    false,   true,         },
}

local SwitchOnImgPath  <const> = "PaperSprite'/Game/UI/Atlas/Skill/Frames/UI_Skill_Icon_Switch_Select_png.UI_Skill_Icon_Switch_Select_png'"
local SwitchOffImgPath <const> = "PaperSprite'/Game/UI/Atlas/Skill/Frames/UI_Skill_Icon_Switch_png.UI_Skill_Icon_Switch_png'"



---@class SkillCustomBtnItemView : SkillCustomBtnBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EffectAbsorb UFCanvasPanel
---@field EffectSelect UFCanvasPanel
---@field FCanvasPanel_59 UFCanvasPanel
---@field IconSkill UFImage
---@field ImgMask UFImage
---@field ImgSelect UFImage
---@field ImgSelectHandle UFImage
---@field ImgSwitch UFImage
---@field AnimEffectAbsorbLoop UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillCustomBtnItemView = LuaClass(SkillCustomBtnBaseView, true)

function SkillCustomBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EffectAbsorb = nil
	--self.EffectSelect = nil
	--self.FCanvasPanel_59 = nil
	--self.IconSkill = nil
	--self.ImgMask = nil
	--self.ImgSelect = nil
	--self.ImgSelectHandle = nil
	--self.ImgSwitch = nil
	--self.AnimEffectAbsorbLoop = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillCustomBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCustomBtnItemView:OnInit()
	self.Super:OnInit()
	self.OriginalButtonIndex = self.ButtonIndex
	self.Binders = {
		{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill) },
		{ "Opacity", UIBinderSetRenderOpacity.New(self, self) },
		{ "Scale", UIBinderValueChangedCallback.New(self, nil, self.OnScaleChanged) },
		{ "ImgSwitchOn", UIBinderValueChangedCallback.New(self, nil, self.OnImgSwitchStateChanged) },
		{ "ButtonState", UIBinderValueChangedCallback.New(self, nil, self.OnButtonStateChanged) },
		{ "bAbsorbLoop", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimEffectAbsorbLoop) },
		{ "bAbsorbLoop", UIBinderSetIsVisible.New(self, self.EffectAbsorb) },
	}

	UIUtil.SetIsVisible(self.ImgSelect, false)
end

function SkillCustomBtnItemView:OnDestroy()
	rawset(self, "ButtonIndex", nil)
end

function SkillCustomBtnItemView:OnShow()
	-- self.Super:OnShow()
end

function SkillCustomBtnItemView:OnHide()

end

function SkillCustomBtnItemView:OnRegisterUIEvent()

end

function SkillCustomBtnItemView:OnRegisterGameEvent()

end

function SkillCustomBtnItemView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function SkillCustomBtnItemView:InitButtonIndex()
	local OriginalButtonIndex = self.OriginalButtonIndex
	if OriginalButtonIndex <= 0 then
		return
	end

	local ReplacedButtonIndex = SkillCustomMgr:GetCustomIndex(OriginalButtonIndex, false)
	rawset(self, "ButtonIndex", ReplacedButtonIndex)
end

function SkillCustomBtnItemView:OnImgSwitchStateChanged(bOn)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgSwitch, bOn and SwitchOnImgPath or SwitchOffImgPath)
end

function SkillCustomBtnItemView:OnButtonStateChanged(ButtonState)
	for WidgetName, VisibleMap in pairs(WidgetButtonStateVisibleMap) do
		local Widget = self[WidgetName]
		local bVisible = VisibleMap[ButtonState]
		if Widget and bVisible ~= nil then
			UIUtil.SetIsVisible(Widget, bVisible)
		end
	end

	local VM = self.VM
	for PropName, PropValueMap in pairs(VMPropButtonStateMap) do
		local Value = PropValueMap[ButtonState]
		if Value ~= nil then
			VM[PropName] = Value
		end
	end
end

return SkillCustomBtnItemView