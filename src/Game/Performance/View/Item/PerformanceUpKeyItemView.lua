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

---@class PerformanceUpKeyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAsc UFButton
---@field ImgAscDisable UFImage
---@field ImgAscNormal UFImage
---@field ImgAscPress UFImage
---@field ImgNote UFImage
---@field KeyState PerformanceKeyStateItemView
---@field PerformanceEffectKeyItem_UIBP PerformanceEffectKeyItemView
---@field AnimTipsHide UWidgetAnimation
---@field AnimTipsLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceUpKeyItemView = LuaClass(UIView, true)

function PerformanceUpKeyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAsc = nil
	--self.ImgAscDisable = nil
	--self.ImgAscNormal = nil
	--self.ImgAscPress = nil
	--self.ImgNote = nil
	--self.KeyState = nil
	--self.PerformanceEffectKeyItem_UIBP = nil
	--self.AnimTipsHide = nil
	--self.AnimTipsLoop = nil
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
	MusicPerformanceUtil.Log(string.format("PerformanceUpKeyItemView:OnLongClicked,  ToneOffset = %s", tostring(self.ToneOffset)))
	_G.EventMgr:SendEvent(EventID.MusicPerformanceToneOffset, self.ToneOffset)
end

function PerformanceUpKeyItemView:onLongClickReleased()
	MusicPerformanceUtil.Log(string.format("PerformanceUpKeyItemView:onLongClickReleased,  ToneOffset = %s", tostring(0)))
	_G.EventMgr:SendEvent(EventID.MusicPerformanceToneOffset, 0)
end


function PerformanceUpKeyItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MusicPerformanceToneOffset, self.OnMusicPerformanceToneOffset)
end

function PerformanceUpKeyItemView:OnMusicPerformanceToneOffset(Offset)
	MusicPerformanceUtil.Log(string.format("PerformanceUpKeyItemView:OnMusicPerformanceToneOffset,  ToneOffset = %s", tostring(Offset)))
	if Offset == 0 then
		self.IsPressedKey = false
		UIUtil.SetIsVisible(self.ImgAscDisable, false, false, false)
		UIUtil.SetIsVisible(self.ImgAscNormal, true, false, false)
		UIUtil.SetIsVisible(self.ImgAscPress, false, false, false)
		UIUtil.SetIsVisible(self.ImgNote, true, false, false)
		self.BtnAsc:SetIsEnabled(true)
	elseif Offset == self.ToneOffset then
		self.IsPressedKey = true
		UIUtil.SetIsVisible(self.ImgAscDisable, false, false, false)
		UIUtil.SetIsVisible(self.ImgAscNormal, false, false, false)
		UIUtil.SetIsVisible(self.ImgAscPress, true, false, false)
		UIUtil.SetIsVisible(self.ImgNote, true, false, false)
	else
		self.IsPressedKey = false
		UIUtil.SetIsVisible(self.ImgAscDisable, true, false, false)
		UIUtil.SetIsVisible(self.ImgAscNormal, false, false, false)
		UIUtil.SetIsVisible(self.ImgAscPress, false, false, false)
		UIUtil.SetIsVisible(self.ImgNote, false, false, false)
		self.BtnAsc:SetIsEnabled(false)
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

	if self.AnimTipsLoop then
		if not self:IsAnimationPlaying(self.AnimTipsLoop) then
			self:PlayAnimation(self.AnimTipsLoop,0,0)
		end
	end
end

--结束按键提示
function PerformanceUpKeyItemView:StopPromptKeyState()
	if self.AnimTipsLoop then
		if self:IsAnimationPlaying(self.AnimTipsLoop) then
			self:StopAnimation(self.AnimTipsLoop)
		end
	end

	if self.AnimTipsHide then
		self:PlayAnimation(self.AnimTipsHide)
	end
end

return PerformanceUpKeyItemView