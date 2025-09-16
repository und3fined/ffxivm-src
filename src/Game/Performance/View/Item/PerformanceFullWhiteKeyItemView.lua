---
--- Author: moodliu
--- DateTime: 2023-11-24 15:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PerformanceKeyBaseView = require("Game/Performance/View/Item/PerformanceKeyBaseView")

---@class PerformanceFullWhiteKeyItemView : PerformanceKeyBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgKey UFImage
---@field KeyState PerformanceKeyStateItemView
---@field TextKey UFTextBlock
---@field AnimPressWhite UWidgetAnimation
---@field AnimReleaseWhite UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceFullWhiteKeyItemView = LuaClass(PerformanceKeyBaseView, true)

function PerformanceFullWhiteKeyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgKey = nil
	--self.KeyState = nil
	--self.TextKey = nil
	--self.AnimPressWhite = nil
	--self.AnimReleaseWhite = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceFullWhiteKeyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.KeyState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceFullWhiteKeyItemView:OnInit()

end

function PerformanceFullWhiteKeyItemView:OnDestroy()

end

function PerformanceFullWhiteKeyItemView:OnShow()
	self:UpdateUI()
end

function PerformanceFullWhiteKeyItemView:OnHide()

end


function PerformanceFullWhiteKeyItemView:GetPressImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Diatonic_Large_Press_png.UI_Performance_Btn_Diatonic_Large_Press_png'"
end

function PerformanceFullWhiteKeyItemView:GetNormalImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Diatonic_Large_Normal_png.UI_Performance_Btn_Diatonic_Large_Normal_png'"
end

function PerformanceFullWhiteKeyItemView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn, self.OnPressedSubClass)
	UIUtil.AddOnReleasedEvent(self, self.Btn, self.OnReleasedSubClass)
	UIUtil.AddOnLongClickedEvent(self, self.Btn, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.Btn, self.OnLongReleaseSubClass)
end

function PerformanceFullWhiteKeyItemView:OnRegisterGameEvent()
	self:RegisterEvents()
end

function PerformanceFullWhiteKeyItemView:OnRegisterBinder()

end

function PerformanceFullWhiteKeyItemView:OnPressedSubClass()
	self:OnPressed()
	self:ChangeKeyImage(self:GetPressImagePath())

	if self:IsAnimationPlaying(self.AnimReleaseWhite) then
		self:StopAnimation(self.AnimReleaseWhite)
	end
	self:PlayAnimation(self.AnimPressWhite)
end

function PerformanceFullWhiteKeyItemView:OnReleasedSubClass()
	self:OnReleased()
	self:RestoreNormalPressed()

	if self:IsAnimationPlaying(self.AnimPressWhite) then
		self:StopAnimation(self.AnimPressWhite)
	end
	self:PlayAnimation(self.AnimReleaseWhite)
end

function PerformanceFullWhiteKeyItemView:OnLongReleaseSubClass()
	self:OnLongRelease()
	self:RestoreNormalPressed()
end

function PerformanceFullWhiteKeyItemView:RestoreNormalPressed()
	self:ChangeKeyImage(self:GetNormalImagePath())
end

return PerformanceFullWhiteKeyItemView