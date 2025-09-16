---
--- Author: moodliu
--- DateTime: 2023-12-07 11:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local EventID = require("Define/EventID")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class PerformanceDownKeyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDes UFButton
---@field ImgDesDisable UFImage
---@field ImgDesNormal UFImage
---@field ImgDesPress UFImage
---@field KeyState PerformanceKeyStateItemView
---@field AnimTips UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceDownKeyItemView = LuaClass(UIView, true)

function PerformanceDownKeyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDes = nil
	--self.ImgDesDisable = nil
	--self.ImgDesNormal = nil
	--self.ImgDesPress = nil
	--self.KeyState = nil
	--self.AnimTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceDownKeyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.KeyState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceDownKeyItemView:OnInit()
	self.ToneOffset = -MPDefines.KeyDefines.KEY_MAX
	self.IsPressedKey = false
end

function PerformanceDownKeyItemView:OnDestroy()

end

function PerformanceDownKeyItemView:OnShow()

end

function PerformanceDownKeyItemView:OnHide()

end

function PerformanceDownKeyItemView:OnRegisterUIEvent()
	UIUtil.AddOnLongClickedEvent(self, self.BtnDes, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.BtnDes, self.onLongClickReleased)
end

function PerformanceDownKeyItemView:OnLongClicked()
	-- self.CurToneOffset = self.CurToneOffset ~= self.ToneOffset and self.ToneOffset or 0
	-- _G.EventMgr:SendEvent(EventID.MusicPerformanceToneOffset, self.CurToneOffset)
	MusicPerformanceUtil.Log(string.format("PerformanceDownKeyItemView:OnLongClicked,  ToneOffset = %s", tostring(self.ToneOffset)))
	_G.EventMgr:SendEvent(EventID.MusicPerformanceToneOffset, self.ToneOffset)
end

function PerformanceDownKeyItemView:onLongClickReleased()
	MusicPerformanceUtil.Log(string.format("PerformanceDownKeyItemView:onLongClickReleased,  ToneOffset = %s", tostring(0)))
	_G.EventMgr:SendEvent(EventID.MusicPerformanceToneOffset, 0)
end

function PerformanceDownKeyItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MusicPerformanceToneOffset, self.OnMusicPerformanceToneOffset)
end

function PerformanceDownKeyItemView:OnMusicPerformanceToneOffset(Offset)
	MusicPerformanceUtil.Log(string.format("PerformanceDownKeyItemView:OnMusicPerformanceToneOffset,  ToneOffset = %s", tostring(Offset)))
	if Offset == 0 then
		self.IsPressedKey = false
		UIUtil.SetIsVisible(self.BtnDes, true, true, false)
		UIUtil.SetIsVisible(self.ImgDesDisable, false, false, false)
		UIUtil.SetIsVisible(self.ImgDesNormal, true, false, false)
		UIUtil.SetIsVisible(self.ImgDesPress, false, false, false)
	elseif Offset == self.ToneOffset then
		self.IsPressedKey = true
		UIUtil.SetIsVisible(self.ImgDesDisable, false, false, false)
		UIUtil.SetIsVisible(self.ImgDesNormal, false, false, false)
		UIUtil.SetIsVisible(self.ImgDesPress, true, false, false)
	else
		self.IsPressedKey = false
		UIUtil.SetIsVisible(self.BtnDes, true, false)
		UIUtil.SetIsVisible(self.ImgDesDisable, true, false, false)
		UIUtil.SetIsVisible(self.ImgDesNormal, false, false, false)
		UIUtil.SetIsVisible(self.ImgDesPress, false, false, false)
	end
end

function PerformanceDownKeyItemView:OnRegisterBinder()

end

--开始按键提示
function PerformanceDownKeyItemView:StartPromptKeyState()
	if self.IsPressedKey then
		self:StopPromptKeyState()
		return
	end
	
	if self.AnimTips then
		if not self:IsAnimationPlaying(self.AnimTips) then
			self:PlayAnimation(self.AnimTips,0,0)
		end
	end
end

--结束按键提示
function PerformanceDownKeyItemView:StopPromptKeyState()
	if self.AnimTips then
		if self:IsAnimationPlaying(self.AnimTips) then
			self:StopAnimation(self.AnimTips)
		end
	end
end

return PerformanceDownKeyItemView