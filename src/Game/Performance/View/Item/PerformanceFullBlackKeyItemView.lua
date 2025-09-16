---
--- Author: moodliu
--- DateTime: 2023-11-24 15:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PerformanceKeyBaseView = require("Game/Performance/View/Item/PerformanceKeyBaseView")

---@class PerformanceFullBlackKeyItemView : PerformanceKeyBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgKey UFImage
---@field KeyState PerformanceKeyStateItemView
---@field TextKey UFTextBlock
---@field AnimPressBlack UWidgetAnimation
---@field AnimReleaseBlack UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceFullBlackKeyItemView = LuaClass(PerformanceKeyBaseView, true)

function PerformanceFullBlackKeyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgKey = nil
	--self.KeyState = nil
	--self.TextKey = nil
	--self.AnimPressBlack = nil
	--self.AnimReleaseBlack = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceFullBlackKeyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.KeyState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceFullBlackKeyItemView:OnInit()

end

function PerformanceFullBlackKeyItemView:OnDestroy()

end

function PerformanceFullBlackKeyItemView:OnShow()
	self:UpdateUI()
end

function PerformanceFullBlackKeyItemView:OnHide()

end


function PerformanceFullBlackKeyItemView:GetPressImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Black_Press_png.UI_Performance_Btn_Black_Press_png'"
end

function PerformanceFullBlackKeyItemView:GetNormalImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Black_Normal_png.UI_Performance_Btn_Black_Normal_png'"
end

function PerformanceFullBlackKeyItemView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn, self.OnPressedSubClass)
	UIUtil.AddOnReleasedEvent(self, self.Btn, self.OnReleasedSubClass)
	UIUtil.AddOnLongClickedEvent(self, self.Btn, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.Btn, self.OnLongReleaseSubClass)
end

function PerformanceFullBlackKeyItemView:OnRegisterGameEvent()
	self:RegisterEvents()
end

function PerformanceFullBlackKeyItemView:OnRegisterBinder()

end

function PerformanceFullBlackKeyItemView:OnPressedSubClass()
	self:OnPressed()
	self:ChangeKeyImage(self:GetPressImagePath())
	
	if self:IsAnimationPlaying(self.AnimReleaseBlack) then
		self:StopAnimation(self.AnimReleaseBlack)
	end
	self:PlayAnimation(self.AnimPressBlack)
end

function PerformanceFullBlackKeyItemView:OnReleasedSubClass()
	self:OnReleased()
	self:RestoreNormalPressed()

	if self:IsAnimationPlaying(self.AnimPressBlack) then
		self:StopAnimation(self.AnimPressBlack)
	end
	self:PlayAnimation(self.AnimReleaseBlack)
end

function PerformanceFullBlackKeyItemView:OnLongReleaseSubClass()
	self:OnLongRelease()
	self:RestoreNormalPressed()
end

function PerformanceFullBlackKeyItemView:RestoreNormalPressed()
	self:ChangeKeyImage(self:GetNormalImagePath())
end

return PerformanceFullBlackKeyItemView