---
--- Author: Administrator
--- DateTime: 2024-08-23 19:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")

local SoundPath = "/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Unlock.Play_Zingle_Unlock"

---@class InfoTipsSystemUnlockTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconSystem UFImage
---@field PopUpBG CommonPopUpBGView
---@field RichText URichTextBox
---@field TextHint UFTextBlock
---@field TextJob UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoTipsSystemUnlockTipsView = LuaClass(UIView, true)

function InfoTipsSystemUnlockTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconSystem = nil
	--self.PopUpBG = nil
	--self.RichText = nil
	--self.TextHint = nil
	--self.TextJob = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoTipsSystemUnlockTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoTipsSystemUnlockTipsView:OnInit()
	self.IsCanSkip = false
	self.PopUpBG:SetCallback(self, function()
		self:UnRegisterAllTimer()
		_G.ModuleOpenMgr:SkipCurrentExp()
		self:Hide()
	end)
	self.PopUpBG:SetHideOnClick(true)
end

function InfoTipsSystemUnlockTipsView:OnDestroy()

end

function InfoTipsSystemUnlockTipsView:OnShow()
	if self.Params == nil then
		return
	end
	self.TextHint:SetText(LSTR(1070001))		--- 点击空白处关闭
	_G.HUDMgr:SetIsDrawHUD(false)
	_G.InteractiveMgr:HideMainPanel()
	local Params = self.Params
	UIUtil.SetIsVisible(self.TextHint, false)
	UIUtil.SetIsVisible(self.PopUpBG, true)
	AudioUtil.LoadAndPlayUISound(SoundPath)
	_G.ModuleOpenMgr:SetMainPanelFadeInOrOut(false)
	if not string.isnilorempty(Params.Icon)	then
		UIUtil.ImageSetBrushFromAssetPath(self.IconSystem, Params.Icon)
	end
	self.TextJob:SetText(Params.SysNotice)
	self.RichText:SetText(Params.SubSysNotice)
	self:RegisterTimer(function()
		UIUtil.SetIsVisible(self.TextHint, true)
	end, 0.8)
	--显示3.2s消失
	self:RegisterTimer(function()
		if Params == nil then
			return
		end
		_G.ModuleOpenMgr:OnAllMotionOver()
		self:Hide()
	end, 3.2)
end

function InfoTipsSystemUnlockTipsView:OnHide()
	_G.HUDMgr:SetIsDrawHUD(true)
	_G.InteractiveMgr:ShowMainPanel()
	UIUtil.SetIsVisible(self.TextHint, false)
	UIUtil.SetIsVisible(self.PopUpBG, false)
	local DelayTime = self.AnimOut:GetEndTime()
	_G.ModuleOpenMgr:SetMainPanelFadeInOrOut(true, DelayTime)
end

function InfoTipsSystemUnlockTipsView:OnRegisterUIEvent()

end

function InfoTipsSystemUnlockTipsView:OnRegisterGameEvent()

end

function InfoTipsSystemUnlockTipsView:OnRegisterBinder()

end

return InfoTipsSystemUnlockTipsView