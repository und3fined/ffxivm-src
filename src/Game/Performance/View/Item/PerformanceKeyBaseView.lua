---
--- Author: moodliu
--- DateTime: 2023-11-24 15:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceKeyBaseView : UIView
local PerformanceKeyBaseView = LuaClass(UIView, true)

function PerformanceKeyBaseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgNormal = nil
	--self.ImgPress = nil
	--self.TextKey = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.Key = nil
	self.IsKeyi = false
	self.RequestKey = nil	-- 记录实际发送的Key值
end

function PerformanceKeyBaseView:OnPressed()
	-- 长按时不处理逻辑
	if self.Key == nil or self.Btn.IsAllowLongClick then
		return
	end

	local ToneOffset = _G.MusicPerformanceMgr:GetToneOffset()
	self.RequestKey = self.Key + ToneOffset
	if _G.MusicPerformanceMgr:IsAssistantMode() then
		local Assistant = _G.MusicPerformanceMgr:GetAssistantInst()
		-- 发送至演奏助手积分
		Assistant:AddInputEvent(self.RequestKey, MPDefines.UIEventType.ShortClick)
	end
	_G.MusicPerformanceMgr:Request(self.RequestKey)
	self:StopAllAnimations()
	-- -- 动效
	-- local EffItem = self.PerformanceEffectKeyItem_UIBP
	-- if EffItem then
	-- 	local Eff = EffItem.AnimComChick
	-- 	Eff = self.RequestKey > self.Key and EffItem.AnimHighChick or Eff
	-- 	Eff = self.RequestKey < self.Key and EffItem.AnimLowChick or Eff
	-- 	EffItem:PlayAnimation(Eff)
	-- end


end

function PerformanceKeyBaseView:OnReleased()
	
end

function PerformanceKeyBaseView:UpdateUI()
	if self.Key then
		if self.Key == MPDefines.KeyEnd or self.IsKeyi then
			self.TextKey:SetText("i")
		else
			local KeyName = MPDefines.KeyName[self.Key % MPDefines.KeyDefines.KEY_MAX]
			self.TextKey:SetText(KeyName or "")
		end
	else
		self.TextKey:SetText("")
	end

	local PerformData = _G.MusicPerformanceMgr:GetSelectedPerformData()
	if PerformData then
		self.Btn.IsAllowLongClick = PerformData.Loop == 1
	end
end

function PerformanceKeyBaseView:OnLongClicked()
	if self.Key == nil then
		return
	end

	local ToneOffset = _G.MusicPerformanceMgr:GetToneOffset()
	self.RequestKey = self.Key + ToneOffset
	if _G.MusicPerformanceMgr:IsAssistantMode() then
		local Assistant = _G.MusicPerformanceMgr:GetAssistantInst()
		-- local Index, MatchedNoteEvent = Assistant:FindMatchedNoteEvent(InputEvent, true)
		--self.RequestKey = MatchedNoteEvent and MatchedNoteEvent.Tone or self.Key
		-- 发送至演奏助手积分
		Assistant:AddInputEvent(self.RequestKey, MPDefines.UIEventType.LongClick)
	end

	_G.MusicPerformanceMgr:RequestLongPress(self.RequestKey, true)

	-- local EffItem = self.PerformanceEffectKeyItem_UIBP
	-- self:StopAllAnimations()
	-- if EffItem then
	-- 	local LoopEff = EffItem.AnimComLoop
	-- 	local Eff = EffItem.AnimComChick
	-- 	LoopEff = self.RequestKey > self.Key and EffItem.AnimHighLoop or LoopEff
	-- 	LoopEff = self.RequestKey < self.Key and EffItem.AnimLowLoop or LoopEff

	-- 	-- Eff = self.RequestKey > self.Key and EffItem.AnimHighChick or Eff
	-- 	-- Eff = self.RequestKey < self.Key and EffItem.AnimLowChick or Eff
	-- 	--EffItem:PlayAnimation(Eff)
	-- 	EffItem:PlayAnimation(LoopEff)
	-- end

	self:ChangeKeyImage(self:GetPressImagePath())
end

function PerformanceKeyBaseView:GetPressImagePath()
	return ""
end

function PerformanceKeyBaseView:GetPressDownImagePath()
	return ""
end

function PerformanceKeyBaseView:GetPressUpImagePath()
	return ""
end

function PerformanceKeyBaseView:GetNormalImagePath()
	return ""
end

function PerformanceKeyBaseView:OnLongRelease()
	if self.Key then
		_G.MusicPerformanceMgr:RequestLongPress(self.RequestKey, false)
		
		if _G.MusicPerformanceMgr:IsAssistantMode() then
			local Assistant = _G.MusicPerformanceMgr:GetAssistantInst()
			-- 发送至演奏助手积分
			Assistant:AddInputEvent(self.RequestKey, MPDefines.UIEventType.LongRelease)
		end
		self.RequestKey = nil

		-- local EffItem = self.PerformanceEffectKeyItem_UIBP
		-- self:StopAllAnimations()
		-- if EffItem and EffItem.AnimUnChick then
		-- 	EffItem:PlayAnimation(EffItem.AnimUnChick)
		-- end
		self:ChangeKeyImage(self:GetNormalImagePath())
	end
end

-- function PerformanceKeyBaseView:StopAllAnimations()
-- 	local EffItem = self.PerformanceEffectKeyItem_UIBP
-- 	if EffItem then
-- 		EffItem:StopAnimation(EffItem.AnimComChick)
-- 		EffItem:StopAnimation(EffItem.AnimLowChick)
-- 		EffItem:StopAnimation(EffItem.AnimHighChick)

-- 		EffItem:StopAnimation(EffItem.AnimComLoop)
-- 		EffItem:StopAnimation(EffItem.AnimLowLoop)
-- 		EffItem:StopAnimation(EffItem.AnimHighLoop)
-- 	end
-- end


function PerformanceKeyBaseView:ChangeKeyImage(ImagePath)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgKey, ImagePath)
end

function PerformanceKeyBaseView:OnPerformDataChanged(PerformData)
	local LastIsAllowLongClick = self.Btn.IsAllowLongClick
	self.Btn.IsAllowLongClick = PerformData.Loop == 1
	if LastIsAllowLongClick == false and self.Btn.IsAllowLongClick == true then
		self.Btn:SetIsAllowLongClick(true)
	end
end

function PerformanceKeyBaseView:RegisterEvents()
	self:RegisterGameEvent(_G.EventID.MusicPerformancePerformDataChanged, self.OnPerformDataChanged)
end

return PerformanceKeyBaseView