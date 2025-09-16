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

---@class PerformanceUpKeyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAsc UFButton
---@field ImgAscDisable UFImage
---@field ImgAscNormal UFImage
---@field ImgAscPress UFImage
---@field KeyState PerformanceKeyStateItemView
---@field PerformanceEffectKeyItem_UIBP PerformanceEffectKeyItemView
---@field AnimTips UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceUpKeyItemView = LuaClass(UIView, true)

function PerformanceUpKeyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAsc = nil
	--self.ImgAscDisable = nil
	--self.ImgAscNormal = nil
	--self.ImgAscPress = nil
	--self.KeyState = nil
	--self.PerformanceEffectKeyItem_UIBP = nil
	--self.AnimTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceUpKeyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.KeyState)
	self:AddSubView(self.PerformanceEffectKeyItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceUpKeyItemView:OnInit()
	self.ToneOffset = MPDefines.KeyDefines.KEY_MAX
	self.IsPressedKey = false
end

function PerformanceUpKeyItemView:OnDestroy()

end

function PerformanceUpKeyItemView:OnShow()

end

function PerformanceUpKeyItemView:OnHide()

end

function PerformanceUpKeyItemView:OnRegisterUIEvent()
	UIUtil.AddOnLongClickedEvent(self, self.BtnAsc, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.BtnAsc, self.onLongClickReleased)
end


function PerformanceUpKeyItemView:OnLongClicked()
	-- self.CurToneOffset = self.CurToneOffset ~= self.ToneOffset and self.ToneOffset or 0
	-- _G.EventMgr:SendEvent(EventID.MusicPerformanceToneOffset, self.CurToneOffset)
	_G.EventMgr:SendEvent(EventID.MusicPerformanceToneOffset, self.ToneOffset)
end

function PerformanceUpKeyItemView:onLongClickReleased()
	_G.EventMgr:SendEvent(EventID.MusicPerformanceToneOffset, 0)
end


function PerformanceUpKeyItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MusicPerformanceToneOffset, self.OnMusicPerformanceToneOffset)
end

function PerformanceUpKeyItemView:OnMusicPerformanceToneOffset(Offset)
	if Offset == 0 then
		self.IsPressedKey = false
		UIUtil.SetIsVisible(self.BtnAsc, true, true, false)
		UIUtil.SetIsVisible(self.ImgAscDisable, false, false, false)
		UIUtil.SetIsVisible(self.ImgAscNormal, true, false, false)
		UIUtil.SetIsVisible(self.ImgAscPress, false, false, false)
	elseif Offset == self.ToneOffset then
		self.IsPressedKey = true
		UIUtil.SetIsVisible(self.ImgAscDisable, false, false, false)
		UIUtil.SetIsVisible(self.ImgAscNormal, false, false, false)
		UIUtil.SetIsVisible(self.ImgAscPress, true, false, false)
	else
		self.IsPressedKey = false
		UIUtil.SetIsVisible(self.BtnAsc, true, false)
		UIUtil.SetIsVisible(self.ImgAscDisable, true, false, false)
		UIUtil.SetIsVisible(self.ImgAscNormal, false, false, false)
		UIUtil.SetIsVisible(self.ImgAscPress, false, false, false)
	end
end

function PerformanceUpKeyItemView:OnRegisterBinder()

end

--开始按键提示
function PerformanceUpKeyItemView:StartPromptKeyState()
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
function PerformanceUpKeyItemView:StopPromptKeyState()
	if self.AnimTips then
		if self:IsAnimationPlaying(self.AnimTips) then
			self:StopAnimation(self.AnimTips)
		end
	end
end

return PerformanceUpKeyItemView