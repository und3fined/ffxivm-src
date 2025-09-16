---
--- Author: Administrator
--- DateTime: 2024-10-28 16:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local FLinearColor = _G.UE.FLinearColor

---@class CrafterGoldsmithItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBlue UFImage
---@field ImgGreen UFImage
---@field ImgPointer UFImage
---@field PanelBlue UFCanvasPanel
---@field PanelGreen UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimLeftHide UWidgetAnimation
---@field AnimLeftShowGreen UWidgetAnimation
---@field AnimLeftShowPurple UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPointer UWidgetAnimation
---@field AnimPointerControl UWidgetAnimation
---@field AnimRightHide UWidgetAnimation
---@field AnimRightShowBlue UWidgetAnimation
---@field AnimRightShowPurple UWidgetAnimation
---@field CurveAnimProgressBar CurveFloat
---@field ValueAnimPointerStart float
---@field ValueAnimPointerEnd float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterGoldsmithItemView = LuaClass(UIView, true)

-- 这里的状态数组直接使用了CrafterGoldsmithVM中的定义
-- 四个数字分别表示是否在红区, 是否在蓝区, 指针是否在左侧, 是否在眼力的效果范围内（紫色）
local BuffEffectsAnimMap = {
	["0111"] = "AnimLeftShowPurple",
	["1001"] = "AnimRightShowPurple",
	["1000"] = "AnimRightShowBlue",
	["0110"] = "AnimLeftShowGreen"
}

local StateColor = {
	Green = "61AD6BFF",
	Blue = "5BAAD3FF",
	Purple = "AE6AEFFF"
}

function CrafterGoldsmithItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBlue = nil
	--self.ImgGreen = nil
	--self.ImgPointer = nil
	--self.PanelBlue = nil
	--self.PanelGreen = nil
	--self.AnimIn = nil
	--self.AnimLeftHide = nil
	--self.AnimLeftShowGreen = nil
	--self.AnimLeftShowPurple = nil
	--self.AnimOut = nil
	--self.AnimPointer = nil
	--self.AnimPointerControl = nil
	--self.AnimRightHide = nil
	--self.AnimRightShowBlue = nil
	--self.AnimRightShowPurple = nil
	--self.CurveAnimProgressBar = nil
	--self.ValueAnimPointerStart = nil
	--self.ValueAnimPointerEnd = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterGoldsmithItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterGoldsmithItemView:OnInit()
	self.GoldsmithConfig = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_GOLDSMITH]
    local GoldsmithConfig = self.GoldsmithConfig
    self.TensionValue = GoldsmithConfig.TensionValueDefault
	self.TensionSliderPercent = self.TensionValue /GoldsmithConfig.TensionValueMax
	self.HideAnimToPlay = nil
end

function CrafterGoldsmithItemView:OnDestroy()

end

function CrafterGoldsmithItemView:OnShow()

end

local CrafterCarpenterItemView = require("Game/Crafter/View/Carpenter/CrafterCarpenterItemView")
CrafterGoldsmithItemView.PostShowView = CrafterCarpenterItemView.PostShowView

function CrafterGoldsmithItemView:OnHide()

end

function CrafterGoldsmithItemView:OnRegisterUIEvent()

end

function CrafterGoldsmithItemView:OnRegisterGameEvent()

end

function CrafterGoldsmithItemView:OnRegisterBinder()

end

function CrafterGoldsmithItemView:UpdateFeatures(Features)
	if not Features then
		return
	end

	self.TensionValue = Features[ProtoCS.FeatureType.FEATURE_TYPE_TENSION] or self.TensionValue
	local GoldsmithConfig = self.GoldsmithConfig
	self.TensionSliderPercent = self.TensionValue / GoldsmithConfig.TensionValueMax
	self.ValueAnimPointerEnd = self.TensionSliderPercent
	self:PlayAnimation(self.AnimPointerControl)
	if self.HideAnimToPlay ~= nil then
		self:PlayAnimation(self[self.HideAnimToPlay])
		self.HideAnimToPlay = nil
	end
end

function CrafterGoldsmithItemView:UpdateBuffEffects(State,bHasBuff)
	self:SetImagePurple(bHasBuff)
	local AnimToPlay = BuffEffectsAnimMap[State]
	if AnimToPlay ~= nil then
		self:PlayAnimation(self[AnimToPlay])
		if self.TensionSliderPercent < 0.5 then
			self.HideAnimToPlay = "AnimLeftHide"
		else
			self.HideAnimToPlay = "AnimRightHide"
		end
	end
	self.ValueAnimPointerStart = self.TensionSliderPercent
end

function CrafterGoldsmithItemView:SetImagePurple(bPurple)
	if bPurple then
		local LinearColor = FLinearColor.FromHex(StateColor.Purple)
		self.ImgBlue:SetColorAndOpacity(LinearColor)
		self.ImgGreen:SetColorAndOpacity(LinearColor)
	else
		local GreenLinearColor = FLinearColor.FromHex(StateColor.Green)
		local BlueLinearColor = FLinearColor.FromHex(StateColor.Blue)
		self.ImgBlue:SetColorAndOpacity(BlueLinearColor)
		self.ImgGreen:SetColorAndOpacity(GreenLinearColor)
	end
end

return CrafterGoldsmithItemView