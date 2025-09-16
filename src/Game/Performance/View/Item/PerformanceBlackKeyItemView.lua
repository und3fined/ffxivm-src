---
--- Author: moodliu
--- DateTime: 2023-12-07 14:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PerformanceKeyBaseView = require("Game/Performance/View/Item/PerformanceKeyBaseView")
local EventID = require("Define/EventID")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceBlackKeyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgKey UFImage
---@field KeyState PerformanceKeyStateItemView
---@field TextKey UFTextBlock
---@field AnimPressBlack UWidgetAnimation
---@field AnimPressBlue UWidgetAnimation
---@field AnimPressRed UWidgetAnimation
---@field AnimReleaseBlack UWidgetAnimation
---@field AnimReleaseBlue UWidgetAnimation
---@field AnimReleaseRed UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceBlackKeyItemView = LuaClass(PerformanceKeyBaseView, true)

function PerformanceBlackKeyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgKey = nil
	--self.KeyState = nil
	--self.TextKey = nil
	--self.AnimPressBlack = nil
	--self.AnimPressBlue = nil
	--self.AnimPressRed = nil
	--self.AnimReleaseBlack = nil
	--self.AnimReleaseBlue = nil
	--self.AnimReleaseRed = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.KeyOffset = 0
end

function PerformanceBlackKeyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.KeyState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceBlackKeyItemView:OnInit()

end

function PerformanceBlackKeyItemView:OnDestroy()

end

function PerformanceBlackKeyItemView:OnShow()
	self:UpdateUI()
end

function PerformanceBlackKeyItemView:OnHide()

end

function PerformanceBlackKeyItemView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn, self.OnPressedSubClass)
	UIUtil.AddOnReleasedEvent(self, self.Btn, self.OnReleasedSubClass)
	UIUtil.AddOnLongClickedEvent(self, self.Btn, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.Btn, self.OnLongReleaseSubClass)
end

function PerformanceBlackKeyItemView:OnRegisterGameEvent()
	self:RegisterEvents()
	self:RegisterGameEvent(EventID.MusicPerformanceToneOffset, self.OnMusicPerformanceToneOffset)
end

function PerformanceBlackKeyItemView:OnRegisterBinder()

end

function PerformanceBlackKeyItemView:GetPressImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Large_Black_Press_png.UI_Performance_Btn_Large_Black_Press_png'"
end

function PerformanceBlackKeyItemView:GetPressDownImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Large_Black_Down_Press_png.UI_Performance_Btn_Large_Black_Down_Press_png'"
end

function PerformanceBlackKeyItemView:GetPressUpImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Large_Black_Up_Press_png.UI_Performance_Btn_Large_Black_Up_Press_png'"
end

function PerformanceBlackKeyItemView:GetNormalImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Large_Black_Normal_png.UI_Performance_Btn_Large_Black_Normal_png'"
end

function PerformanceBlackKeyItemView:OnMusicPerformanceToneOffset(Offset)
	self.KeyOffset = Offset
end

function PerformanceBlackKeyItemView:OnPressedSubClass()
	self:OnPressed()

	if self.KeyOffset == 0 then
		self:ChangeKeyImage(self:GetPressImagePath())

		if self:IsAnimationPlaying(self.AnimReleaseBlack) then
			self:StopAnimation(self.AnimReleaseBlack)
		end
		self:PlayAnimation(self.AnimPressBlack)
	elseif self.KeyOffset == -MPDefines.KeyDefines.KEY_MAX then
		self:ChangeKeyImage(self:GetPressDownImagePath())

		if self:IsAnimationPlaying(self.AnimReleaseBlue) then
			self:StopAnimation(self.AnimReleaseBlue)
		end
		self:PlayAnimation(self.AnimPressBlue)
	else
		self:ChangeKeyImage(self:GetPressUpImagePath())

		if self:IsAnimationPlaying(self.AnimReleaseRed) then
			self:StopAnimation(self.AnimReleaseRed)
		end
		self:PlayAnimation(self.AnimPressRed)
	end
end

function PerformanceBlackKeyItemView:OnReleasedSubClass()
	self:OnReleased()
	self:RestoreNormalPressed()
	self:PlayReleaseAnim()
end

function PerformanceBlackKeyItemView:OnLongReleaseSubClass()
	self:OnLongRelease()
	self:RestoreNormalPressed()
	-- self:PlayReleaseAnim()
end

function PerformanceBlackKeyItemView:RestoreNormalPressed()
	self:ChangeKeyImage(self:GetNormalImagePath())
end

--播放松开键强化特效
function PerformanceBlackKeyItemView:PlayReleaseAnim()
	if self.KeyOffset == 0 then
		if self:IsAnimationPlaying(self.AnimPressBlack) then
			self:StopAnimation(self.AnimPressBlack)
		end
		self:PlayAnimation(self.AnimReleaseBlack)
	elseif self.KeyOffset == -MPDefines.KeyDefines.KEY_MAX then
		if self:IsAnimationPlaying(self.AnimPressBlue) then
			self:StopAnimation(self.AnimPressBlue)
		end
		self:PlayAnimation(self.AnimReleaseBlue)
	else
		if self:IsAnimationPlaying(self.AnimPressRed) then
			self:StopAnimation(self.AnimPressRed)
		end
		self:PlayAnimation(self.AnimReleaseRed)
	end
end

return PerformanceBlackKeyItemView