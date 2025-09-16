---
--- Author: moodliu
--- DateTime: 2024-05-11 15:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PerformanceKeyStateItemVM = require("Game/Performance/VM/PerformanceKeyStateItemVM")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceKeyStateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgDiamond UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceKeyStateItemView = LuaClass(UIView, true)

function PerformanceKeyStateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgDiamond = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceKeyStateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceKeyStateItemView:OnInit()
	self.VM = PerformanceKeyStateItemVM.New()
end

function PerformanceKeyStateItemView:OnDestroy()

end

function PerformanceKeyStateItemView:OnShow()

end

function PerformanceKeyStateItemView:OnHide()

end

function PerformanceKeyStateItemView:OnRegisterUIEvent()

end

function PerformanceKeyStateItemView:OnRegisterGameEvent()

end

function PerformanceKeyStateItemView:SetKeyState(KeyState)
	self.VM.KeyState = KeyState
end

function PerformanceKeyStateItemView:OnKeyStateChanged(NewValue)
	local KeyStates = MPDefines.AssistantFallingDownConfig.KeyStates
	if NewValue == KeyStates.Red then
		self.VM.ImgDiamondPath = "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Img_Diamond3_png.UI_Performance_Img_Diamond3_png'"
	elseif NewValue == KeyStates.Grey then
		self.VM.ImgDiamondPath = "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Img_Diamond2_png.UI_Performance_Img_Diamond2_png'"
	elseif NewValue == KeyStates.Blue then
		self.VM.ImgDiamondPath = "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Img_Diamond4_png.UI_Performance_Img_Diamond4_png'"
	end
end

function PerformanceKeyStateItemView:OnRegisterBinder()
	local Binders = {
		{"ImgDiamondPath",UIBinderSetImageBrush.New(self, self.ImgDiamond)},
		{"KeyState", UIBinderValueChangedCallback.New(self, nil, self.OnKeyStateChanged)}
	}

	self:RegisterBinders(self.VM, Binders)
end

return PerformanceKeyStateItemView