---
--- Author: moodliu
--- DateTime: 2023-11-24 15:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local PerformancePauseWinVM = require("Game/Performance/VM/PerformancePauseWinVM")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class PerformancePauseWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnContinue CommBtnMView
---@field BtnQuit CommBtnMView
---@field BtnRestart CommBtnMView
---@field SliderSpeed CommSliderHorizontalView
---@field TextBPM UFTextBlock
---@field TextBeat UFTextBlock
---@field TextMetronome UFTextBlock
---@field TextName UFTextBlock
---@field TextSpeed UFTextBlock
---@field TextSpeed2 UFTextBlock
---@field TextSpeed_1 UFTextBlock
---@field ToggleBtnMetronome UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformancePauseWinView = LuaClass(UIView, true)

function PerformancePauseWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnContinue = nil
	--self.BtnQuit = nil
	--self.BtnRestart = nil
	--self.SliderSpeed = nil
	--self.TextBPM = nil
	--self.TextBeat = nil
	--self.TextMetronome = nil
	--self.TextName = nil
	--self.TextSpeed = nil
	--self.TextSpeed2 = nil
	--self.TextSpeed_1 = nil
	--self.ToggleBtnMetronome = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformancePauseWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnContinue)
	self:AddSubView(self.BtnQuit)
	self:AddSubView(self.BtnRestart)
	self:AddSubView(self.SliderSpeed)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformancePauseWinView:OnInit()
	self:InitStaticText()
	self.VM = PerformancePauseWinVM.New()

	self.SliderSpeed:SetValueChangedCallback(function (v)
		self.VM.SpeedValue = MusicPerformanceUtil.SliderValueToAssistantSpeed(v)
	end)
end

function PerformancePauseWinView:InitStaticText()
	self.BG:SetTitleText(_G.LSTR(830077))
	self.TextSpeed2:SetText(_G.LSTR(830083))
	self.TextMetronome:SetText(_G.LSTR(830082))
	self.TextSpeed_1:SetText(_G.LSTR(830081))
	
	self.BtnQuit:SetButtonText(_G.LSTR(830078))
	self.BtnRestart:SetButtonText(_G.LSTR(830079))
	self.BtnContinue:SetButtonText(_G.LSTR(830080))
end

function PerformancePauseWinView:OnDestroy()

end

function PerformancePauseWinView:OnShow()
	local Assistant = _G.MusicPerformanceMgr:GetAssistantInst()
	Assistant:Pause()
	local Data = self.Params.Data
	if Data then
		self.VM.TextName = Data.Name
		self.VM.TextBPM = LSTR(830004) .. tostring(Data.Bpm)
		self.VM.TextBeat = LSTR(830003) .. string.format("%d/%d", Data.Beat1, Data.Beat2)
		self.SliderSpeed:SetValue(MusicPerformanceUtil.AssistantSpeedToSliderValue(Assistant.Rate))
		self.VM.SpeedValue = Assistant.Rate
		self.VM.ToggleMetronome = nil
		self.VM.ToggleMetronome = self.Params.ToggleMetronome
	end
end

function PerformancePauseWinView:OnToggleBtnMetronomeClicked()
	self.VM.ToggleMetronome = not self.VM.ToggleMetronome
end

function PerformancePauseWinView:ResumeAssistant()
	local AssistantPanel = _G.UIViewMgr:FindVisibleView(_G.UIViewID.PerformanceAssistantPanelView)
	if AssistantPanel then
		AssistantPanel:ResumeAssistant()
	end
end

function PerformancePauseWinView:OnHide()
	self:ResumeAssistant()
end

function PerformancePauseWinView:OnBtnQuitClicked()
	local Assistant = _G.MusicPerformanceMgr:GetAssistantInst()
	Assistant:Stop()
	_G.UIViewMgr:HideView(_G.UIViewID.PerformanceAssistantPanelView)
	_G.UIViewMgr:HideView(_G.UIViewID.PerformanceAssistantPauseWinView, true)
	
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPefromanceSongPanelView)
end

function PerformancePauseWinView:OnBtnContinueClicked()
	_G.UIViewMgr:HideView(_G.UIViewID.PerformanceAssistantPauseWinView)
end

function PerformancePauseWinView:OnBtnRestartClicked()
	local Assistant = _G.MusicPerformanceMgr:GetAssistantInst()
	Assistant:Stop()
	_G.UIViewMgr:HideView(_G.UIViewID.PerformanceAssistantPauseWinView)
	local AssistantPanel = _G.UIViewMgr:FindVisibleView(_G.UIViewID.PerformanceAssistantPanelView)
	if AssistantPanel then
		AssistantPanel:RestartAssistant(self.VM.SpeedValue, self.VM.ToggleMetronome)
	end
end

function PerformancePauseWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnQuit, self.OnBtnQuitClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnContinue, self.OnBtnContinueClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRestart, self.OnBtnRestartClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMetronome, self.OnToggleBtnMetronomeClicked)
end

function PerformancePauseWinView:OnRegisterGameEvent()

end

function PerformancePauseWinView:OnSpeedValueChanged(NewValue)
	self.VM.TextSpeed = string.format(LSTR(830002), NewValue or 1.0)
end

function PerformancePauseWinView:OnRegisterBinder()
	local Binders = {
		{ "TextBPM", UIBinderSetText.New(self, self.TextBPM )},
		{ "TextBeat", UIBinderSetText.New(self, self.TextBeat )},
		{ "TextName", UIBinderSetText.New(self, self.TextName )},
		{ "TextSpeed", UIBinderSetText.New(self, self.TextSpeed )},
		{ "SpeedValue", UIBinderValueChangedCallback.New(self, nil, self.OnSpeedValueChanged) },
		{ "ToggleMetronome", UIBinderSetIsChecked.New(self, self.ToggleBtnMetronome) },
	}

	self:RegisterBinders(self.VM, Binders)
end

return PerformancePauseWinView