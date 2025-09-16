---
--- Author: moodliu
--- DateTime: 2023-11-24 15:58
--- Description:发起合奏确认界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local UIUtil = require("Utils/UIUtil")
local MusicPerformanceMetronomeSettingVM = require("Game/Performance/VM/MusicPerformanceMetronomeSettingVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local ProtoCS = require ("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local SaveKey = require("Define/SaveKey")

local CS_CMD = ProtoCS.CS_CMD
local PERFORM_CMD = ProtoCS.PerformCmd

---@class PerformanceMetronomeEnsembleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnAssistantHelp CommHelpBtnView
---@field BtnBPMHelp CommHelpBtnView
---@field BtnBeatHelp CommHelpBtnView
---@field BtnCancel CommBtnLView
---@field BtnDefault CommBtnLView
---@field BtnInitiate CommBtnLView
---@field DropDownAssistant CommDropDownListView
---@field DropDownCountDown CommDropDownListView
---@field Metronome PerformanceMetronomeItemView
---@field PanelAssistantIntro UFCanvasPanel
---@field PanelBPMIntro UFCanvasPanel
---@field PanelBPMSlider UFCanvasPanel
---@field PanelBeatIntro UFCanvasPanel
---@field PanelBeatSlider UFCanvasPanel
---@field SliderBPM CommSliderHorizontalView
---@field SliderBeat CommSliderHorizontalView
---@field TextAssistantIntro UFTextBlock
---@field TextBPMIntro UFTextBlock
---@field TextBPMValue UFTextBlock
---@field TextBeatIntro UFTextBlock
---@field TextBeatValue UFTextBlock
---@field TextTempo UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceMetronomeEnsembleWinView = LuaClass(UIView, true)

function PerformanceMetronomeEnsembleWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnAssistantHelp = nil
	--self.BtnBPMHelp = nil
	--self.BtnBeatHelp = nil
	--self.BtnCancel = nil
	--self.BtnDefault = nil
	--self.BtnInitiate = nil
	--self.DropDownAssistant = nil
	--self.DropDownCountDown = nil
	--self.Metronome = nil
	--self.PanelAssistantIntro = nil
	--self.PanelBPMIntro = nil
	--self.PanelBPMSlider = nil
	--self.PanelBeatIntro = nil
	--self.PanelBeatSlider = nil
	--self.SliderBPM = nil
	--self.SliderBeat = nil
	--self.TextAssistantIntro = nil
	--self.TextBPMIntro = nil
	--self.TextBPMValue = nil
	--self.TextBeatIntro = nil
	--self.TextBeatValue = nil
	--self.TextTempo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceMetronomeEnsembleWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnAssistantHelp)
	self:AddSubView(self.BtnBPMHelp)
	self:AddSubView(self.BtnBeatHelp)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnDefault)
	self:AddSubView(self.BtnInitiate)
	self:AddSubView(self.DropDownAssistant)
	self:AddSubView(self.DropDownCountDown)
	self:AddSubView(self.Metronome)
	self:AddSubView(self.SliderBPM)
	self:AddSubView(self.SliderBeat)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceMetronomeEnsembleWinView:OnInit()
	self:InitStaticText()
	self.MetronomeSettingVM = MusicPerformanceMetronomeSettingVM.New()
	self.Metronome:SetParentVM(self.MetronomeSettingVM)

	self.SliderBPM.ValueChangedCallback = function(Value)
		self.Metronome.VM.EnsembleBPM = math.floor(MPDefines.MetronomeSettings.BPMEnsembleMin + 
			(MPDefines.MetronomeSettings.BPMMax - MPDefines.MetronomeSettings.BPMEnsembleMin) * Value) 
		self.Metronome.VM:ChangeDataFromEnsemble()

		self:UpdatePanelMetronome()
		self:CheckSettingsDefault()
		self.MetronomeSettingVM.BPMValue = tostring(self.Metronome.VM.EnsembleBPM)
	end

	self.SliderBeat.ValueChangedCallback = function(Value)
		self.Metronome.VM.EnsembleBeat = math.floor(MPDefines.MetronomeSettings.BeatMin + 
			(MPDefines.MetronomeSettings.BeatMax - MPDefines.MetronomeSettings.BeatMin) * Value)
		self.Metronome.VM:ChangeDataFromEnsemble()
		
		self:UpdatePanelMetronome()
		self:CheckSettingsDefault()
		self.MetronomeSettingVM.BeatValue = tostring(self.Metronome.VM.EnsembleBeat)
		if self.Metronome:IsWorking() then
			self.Metronome:Play(0)
			if self.Metronome.AnimRefresh then
				self.Metronome:PlayAnimation(self.Metronome.AnimRefresh)
			end
		end
	end
end

function PerformanceMetronomeEnsembleWinView:InitStaticText()
	self.BG:SetTitleText(_G.LSTR(830095))
	self.TextTips:SetText(_G.LSTR(830096))

	self.TextPreview:SetText(_G.LSTR(830065))
	self.TextMetroSetting:SetText(_G.LSTR(830064))
	self.TextBPMSetting:SetText(_G.LSTR(830097))
	self.TextBeatSetting:SetText(_G.LSTR(830069))
	self.TextAssistSetting:SetText(_G.LSTR(830098))
	
	self.TextAssistant:SetText(_G.LSTR(830099))
	self.TextCountDown:SetText(_G.LSTR(830100))
	self.TextCountDownValue:SetText(_G.LSTR(830101))
	
	self.BtnCancel:SetBtnName(_G.LSTR(830060))
	self.BtnDefault:SetBtnName(_G.LSTR(830061))
	self.BtnInitiate:SetBtnName(_G.LSTR(830102))
end

function PerformanceMetronomeEnsembleWinView:CheckSettingsDefault()
	self.MetronomeSettingVM.BtnDefaultVisible = not MusicPerformanceUtil.IsDefaultEnsembleSettings(self.Metronome.VM)
		or MPDefines.Ensemble.DefaultSettings.OpenAssistant ~= self.OpenAssistant
		or MPDefines.Ensemble.DefaultSettings.OpenCountDown ~= self.OpenCountDown
end

function PerformanceMetronomeEnsembleWinView:UpdatePanelMetronome()
	self.MetronomeSettingVM.BPMTip = "BPM:" .. tostring(self.Metronome.VM.EnsembleBPM)
	self.MetronomeSettingVM.BeatTip = "BEAT:" .. tostring(self.Metronome.VM.EnsembleBeat)
end

function PerformanceMetronomeEnsembleWinView:OnDestroy()

end

function PerformanceMetronomeEnsembleWinView:OnShow()
	self.Metronome:SetVMSettingsSaved()
	self.Metronome:ResetMetronome()
	self:UpdatePanelMetronome()
	self:UpdateSlider()

	self.MetronomeSettingVM.BPMValue = tostring(self.Metronome.VM.EnsembleBPM)
	self.MetronomeSettingVM.BeatValue = tostring(self.Metronome.VM.EnsembleBeat)
	self.OpenAssistant = MusicPerformanceUtil.GetOpenAssistant()
	self.OpenCountDown = MusicPerformanceUtil.GetOpenCountDown()
	self:SetDropDownDefault()

	self:CheckSettingsDefault()
	self.Metronome.VM:ChangeDataFromEnsemble()
end

function PerformanceMetronomeEnsembleWinView:UpdateSlider()
	self.SliderBPM:SetValue((self.Metronome.VM.EnsembleBPM - MPDefines.MetronomeSettings.BPMEnsembleMin) 
		/ (MPDefines.MetronomeSettings.BPMMax - MPDefines.MetronomeSettings.BPMEnsembleMin))
	self.SliderBeat:SetValue((self.Metronome.VM.EnsembleBeat - MPDefines.MetronomeSettings.BeatMin)
		/ (MPDefines.MetronomeSettings.BeatMax - MPDefines.MetronomeSettings.BeatMin))
end

function PerformanceMetronomeEnsembleWinView:SetDropDownDefault()
	local DropDownList = { {Name = LSTR(830011)}, {Name = LSTR(830027)} }
	self.DropDownAssistant:UpdateItems(DropDownList, self.OpenAssistant and 2 or 1)
	self.DropDownCountDown:UpdateItems(DropDownList, self.OpenCountDown and 2 or 1)
end

function PerformanceMetronomeEnsembleWinView:OnHide()

end

function PerformanceMetronomeEnsembleWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDefault.Button, self.OnClickedBtnDefault)
	UIUtil.AddOnClickedEvent(self, self.BtnInitiate.Button, self.OnClickedBtnInitiate)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedBtnCancel)
	
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownAssistant, function(_, Value)
		self.OpenAssistant = Value == 2
		self:CheckSettingsDefault()
	end)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownCountDown, function(_, Value)
		self.OpenCountDown = Value == 2 
		self:CheckSettingsDefault()
	end)
end

function PerformanceMetronomeEnsembleWinView:OnClickedBtnInitiate()
	-- 设置好了合奏设置后，点击确定按钮 向后台发送确认请求
	local MsgID = CS_CMD.CS_CMD_PERFORM
	local SubID = PERFORM_CMD.EnsembleCmdAskConfirm
	local MsgBody = {
		Cmd = SubID,
		AskConfirm = {
			Metronome = {
				BPM = self.Metronome.VM.EnsembleBPM,
				Beat = self.Metronome.VM.EnsembleBeat,
				Assistant = self.OpenAssistant,
				Ready = self.OpenCountDown
			}
		}
	}

	MusicPerformanceUtil.Log(table.tostring(MsgBody))
	
	GameNetworkMgr:SendMsg(MsgID, SubID, MsgBody)
	
	MusicPerformanceUtil.SaveEnsembleBPM(self.Metronome.VM.EnsembleBPM)
	MusicPerformanceUtil.SaveEnsembleBEAT(self.Metronome.VM.EnsembleBeat)
	MusicPerformanceUtil.SaveOpenAssitant(self.OpenAssistant)
	MusicPerformanceUtil.SaveOpenCountDown(self.OpenCountDown);
end

function PerformanceMetronomeEnsembleWinView:OnClickedBtnDefault()
	MusicPerformanceUtil.ResetEnsembleSettings(self.Metronome.VM)
	self.OpenAssistant = MPDefines.Ensemble.DefaultSettings.OpenCountDown
	self.OpenCountDown =MPDefines.Ensemble.DefaultSettings.OpenCountDown
	self:SetDropDownDefault()
	
	self:UpdateSlider()
	self:UpdatePanelMetronome()
	self.MetronomeSettingVM.BPMValue = tostring(self.Metronome.VM.EnsembleBPM)
	self.MetronomeSettingVM.BeatValue = tostring(self.Metronome.VM.EnsembleBeat)

	self.Metronome:ResetMetronome()
	self:CheckSettingsDefault()
end

function PerformanceMetronomeEnsembleWinView:OnClickedBtnCancel()
	_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceEnsembleMetronmeView)
end

function PerformanceMetronomeEnsembleWinView:OnRegisterGameEvent()

end

function PerformanceMetronomeEnsembleWinView:OnRegisterBinder()
	local Binders = {
		{ "TempoTip", UIBinderSetText.New(self, self.TextTempo) },
		{ "BeatValue", UIBinderSetText.New(self, self.TextBeatValue) },
		{ "BPMValue", UIBinderSetText.New(self, self.TextBPMValue) },
		{ "PanelBeatIntroVisible", UIBinderSetIsVisible.New(self, self.PanelBeatIntro, false, false) },
		{ "PanelBPMIntroVisible", UIBinderSetIsVisible.New(self, self.PanelBPMIntro, false, false) },
		{ "PanelAssistantIntroVisible", UIBinderSetIsVisible.New(self, self.PanelAssistantIntro, false, false) },
		{ "BtnDefaultVisible", UIBinderSetIsVisible.New(self, self.BtnDefault, false, false) },
	}

	self:RegisterBinders(self.MetronomeSettingVM, Binders)
end

return PerformanceMetronomeEnsembleWinView