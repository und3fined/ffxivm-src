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

---@class PerformanceWhiteKeyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgKey UFImage
---@field KeyState PerformanceKeyStateItemView
---@field TextKey UFTextBlock
---@field AnimPressBlue UWidgetAnimation
---@field AnimPressRed UWidgetAnimation
---@field AnimPressWhite UWidgetAnimation
---@field AnimReleaseBlue UWidgetAnimation
---@field AnimReleaseRed UWidgetAnimation
---@field AnimReleaseWhite UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceWhiteKeyItemView = LuaClass(PerformanceKeyBaseView, true)

function PerformanceWhiteKeyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgKey = nil
	--self.KeyState = nil
	--self.TextKey = nil
	--self.AnimPressBlue = nil
	--self.AnimPressRed = nil
	--self.AnimPressWhite = nil
	--self.AnimReleaseBlue = nil
	--self.AnimReleaseRed = nil
	--self.AnimReleaseWhite = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.KeyOffset = 0
end

function PerformanceWhiteKeyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.KeyState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceWhiteKeyItemView:OnInit()

end

function PerformanceWhiteKeyItemView:OnDestroy()

end

function PerformanceWhiteKeyItemView:OnShow()
	self:UpdateUI()
end

function PerformanceWhiteKeyItemView:OnHide()

end

function PerformanceWhiteKeyItemView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn, self.OnPressedSubClass)
	UIUtil.AddOnReleasedEvent(self, self.Btn, self.OnReleasedSubClass)
	UIUtil.AddOnLongClickedEvent(self, self.Btn, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.Btn, self.OnLongReleaseSubClass)
end

function PerformanceWhiteKeyItemView:OnRegisterGameEvent()
	self:RegisterEvents()
	self:RegisterGameEvent(EventID.MusicPerformanceToneOffset, self.OnMusicPerformanceToneOffset)
end

function PerformanceWhiteKeyItemView:OnRegisterBinder()

end


function PerformanceWhiteKeyItemView:GetPressImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Large_NoBlack_Press_png.UI_Performance_Btn_Large_NoBlack_Press_png'"
end

function PerformanceWhiteKeyItemView:GetPressDownImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Large_NoBlack_Down_Press_png.UI_Performance_Btn_Large_NoBlack_Down_Press_png'"
end

function PerformanceWhiteKeyItemView:GetPressUpImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Large_NoBlack_Up_Press_png.UI_Performance_Btn_Large_NoBlack_Up_Press_png'"
end

function PerformanceWhiteKeyItemView:GetNormalImagePath()
	return "PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Btn_Large_NoBlack_Normal_png.UI_Performance_Btn_Large_NoBlack_Normal_png'"
end

function PerformanceWhiteKeyItemView:OnMusicPerformanceToneOffset(Offset)
	self.KeyOffset = Offset
end

function PerformanceWhiteKeyItemView:OnPressedSubClass()
	self:OnPressed()

	if self.KeyOffset == 0 then
		self:ChangeKeyImage(self:GetPressImagePath())

		if self:IsAnimationPlaying(self.AnimReleaseWhite) then
			self:StopAnimation(self.AnimReleaseWhite)
		end
		self:PlayAnimation(self.AnimPressWhite)
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

function PerformanceWhiteKeyItemView:OnReleasedSubClass()
	self:OnReleased()
	self:RestoreNormalPressed()
	self:PlayReleaseAnim()
end

function PerformanceWhiteKeyItemView:OnLongReleaseSubClass()
	self:OnLongRelease()
	self:RestoreNormalPressed()
end

function PerformanceWhiteKeyItemView:RestoreNormalPressed()
	self:ChangeKeyImage(self:GetNormalImagePath())
end

--播放松开键强化特效
function PerformanceWhiteKeyItemView:PlayReleaseAnim()
	if self.KeyOffset == 0 then
		if self:IsAnimationPlaying(self.AnimPressWhite) then
			self:StopAnimation(self.AnimPressWhite)
		end
		self:PlayAnimation(self.AnimReleaseWhite)
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

return PerformanceWhiteKeyItemView