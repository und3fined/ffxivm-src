---
--- Author: moodliu
--- DateTime: 2023-11-24 15:58
--- Description:节拍器设置主界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MusicPerformanceMetronomeSettingVM = require("Game/Performance/VM/MusicPerformanceMetronomeSettingVM")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local SaveKey = require("Define/SaveKey")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local MusicPerformanceMetronomeVM = require("Game/Performance/VM/MusicPerformanceMetronomeVM")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local MsgBoxUtil = require("Utils/MsgBoxUtil")

---@class PerformanceMetronomeSettingWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnBPMHelp CommInforBtnView
---@field BtnBeatHelp CommInforBtnView
---@field BtnCancel CommBtnLView
---@field BtnDefault CommBtnLView
---@field BtnSave CommBtnLView
---@field DropDownAddReady CommDropDownListView
---@field DropDownORR CommDropDownListView
---@field DropDownRing CommDropDownListView
---@field Metronome PerformanceMetronomeItemView
---@field PanelBPMSlider UFCanvasPanel
---@field PanelBeatSlider UFCanvasPanel
---@field PanelOnlyReadyRing UFCanvasPanel
---@field PanelVolumeSlider UFCanvasPanel
---@field SliderBPM CommSliderHorizontalView
---@field SliderBeat CommSliderHorizontalView
---@field SliderVolume CommSliderHorizontalView
---@field TextAddReady UFTextBlock
---@field TextBPM UFTextBlock
---@field TextBPMSetting UFTextBlock
---@field TextBPMValue UFTextBlock
---@field TextBeat UFTextBlock
---@field TextBeatSetting UFTextBlock
---@field TextBeatValue UFTextBlock
---@field TextMetroSetting UFTextBlock
---@field TextMode UFTextBlock
---@field TextORR UFTextBlock
---@field TextPreview UFTextBlock
---@field TextRingSetting UFTextBlock
---@field TextTempo UFTextBlock
---@field TextVolumeValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceMetronomeSettingWinView = LuaClass(UIView, true)

function PerformanceMetronomeSettingWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnBPMHelp = nil
	--self.BtnBeatHelp = nil
	--self.BtnCancel = nil
	--self.BtnDefault = nil
	--self.BtnSave = nil
	--self.DropDownAddReady = nil
	--self.DropDownORR = nil
	--self.DropDownRing = nil
	--self.Metronome = nil
	--self.PanelBPMSlider = nil
	--self.PanelBeatSlider = nil
	--self.PanelOnlyReadyRing = nil
	--self.PanelVolumeSlider = nil
	--self.SliderBPM = nil
	--self.SliderBeat = nil
	--self.SliderVolume = nil
	--self.TextAddReady = nil
	--self.TextBPM = nil
	--self.TextBPMSetting = nil
	--self.TextBPMValue = nil
	--self.TextBeat = nil
	--self.TextBeatSetting = nil
	--self.TextBeatValue = nil
	--self.TextMetroSetting = nil
	--self.TextMode = nil
	--self.TextORR = nil
	--self.TextPreview = nil
	--self.TextRingSetting = nil
	--self.TextTempo = nil
	--self.TextVolumeValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceMetronomeSettingWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBPMHelp)
	self:AddSubView(self.BtnBeatHelp)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnDefault)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.DropDownAddReady)
	self:AddSubView(self.DropDownORR)
	self:AddSubView(self.DropDownRing)
	self:AddSubView(self.Metronome)
	self:AddSubView(self.SliderBPM)
	self:AddSubView(self.SliderBeat)
	self:AddSubView(self.SliderVolume)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceMetronomeSettingWinView:OnInit()
	self:InitStaticText()
	self.VM = MusicPerformanceMetronomeSettingVM.New()
	self.Metronome:SetParentVM(self.VM)

	self.SliderBPM.ValueChangedCallback = function(Value)
		self.Metronome.VM.BPM = math.floor(MPDefines.MetronomeSettings.BPMMin + 
			(MPDefines.MetronomeSettings.BPMMax - MPDefines.MetronomeSettings.BPMMin) * Value) 
		self.VM.BPMValue = tostring(self.Metronome.VM.BPM)
		self:UpdatePanelMetronome()
		self:CheckSettingsUIState()
	end

	self.SliderBeat.ValueChangedCallback = function(Value)
		self.Metronome.VM.BeatPerBar = math.floor(MPDefines.MetronomeSettings.BeatMin + 
			(MPDefines.MetronomeSettings.BeatMax - MPDefines.MetronomeSettings.BeatMin) * Value)
		
		self:UpdatePanelMetronome()
		self.VM.BeatValue = tostring(self.Metronome.VM.BeatPerBar)
		if self.Metronome:IsWorking() then
			self.Metronome:Play(0)
			if self.Metronome.AnimRefresh then
				self.Metronome:PlayAnimation(self.Metronome.AnimRefresh)
			end
		end
		self:CheckSettingsUIState()
	end
	
	self.SliderVolume.ValueChangedCallback = function(Value)
		self.Metronome.VM.Volume = math.floor(MPDefines.MetronomeSettings.VolumeMax * Value) 
		self.VM.VolumeValue = tostring(self.Metronome.VM.Volume)
		
		_G.UE.UAudioMgr:Get():SetAudioVolume(_G.UE.EWWiseAudioType.UI_Menu_Sound, self.Metronome.VM.Volume)
		self:CheckSettingsUIState()
	end
end

function PerformanceMetronomeSettingWinView:InitStaticText()
	self.BG:SetTitleText(_G.LSTR(830064))
	self.TextPreview:SetText(_G.LSTR(830065))

	self.TextMetroSetting:SetText(_G.LSTR(830064))
	self.TextMode:SetText(_G.LSTR(830067))
	self.TextBPMSetting:SetText(_G.LSTR(830068))
	self.TextBeatSetting:SetText(_G.LSTR(830069))
	self.TextRingSetting:SetText(_G.LSTR(830070))
	
	self.TextAddReady:SetText(_G.LSTR(830071))
	self.TextORR:SetText(_G.LSTR(830072))
	
	self.BtnCancel:SetBtnName(_G.LSTR(830060))
	self.BtnDefault:SetBtnName(_G.LSTR(830061))
	self.BtnSave:SetBtnName(_G.LSTR(830073))
end

function PerformanceMetronomeSettingWinView:OnDestroy()

end

function PerformanceMetronomeSettingWinView:UpdatePanelMetronome()
	self.VM.BPMTip = "BPM:" .. tostring(self.Metronome.VM.BPM)
	self.VM.BeatTip = "BEAT:" .. tostring(self.Metronome.VM.BeatPerBar)
end

function PerformanceMetronomeSettingWinView:OnShow()
	self.Metronome:SetVMSettingsSaved()
	self:UpdatePanelMetronome()
	self:UpdateSlider()
	self:UpdateDropDown()

	self.VM.BPMValue = tostring(self.Metronome.VM.BPM)
	self.VM.BeatValue = tostring(self.Metronome.VM.BeatPerBar)
	self.VM.VolumeValue = tostring(self.Metronome.VM.Volume)
	_G.UE.UAudioMgr:Get():SetAudioVolume(_G.UE.EWWiseAudioType.UI_Menu_Sound, self.Metronome.VM.Volume)
	self.VM.PanelOnlyReadyRingVisible = self.Metronome.VM.Prepare == 1

	self:CheckSettingsUIState()
end

function PerformanceMetronomeSettingWinView:UpdateDropDown()
	local DropDownList = { {Name = LSTR(830011)}, {Name = LSTR(830027)} }
	self.DropDownRing:UpdateItems(DropDownList, self.Metronome.VM.Effect + 1)
	self.DropDownAddReady:UpdateItems(DropDownList, self.Metronome.VM.Prepare + 1)
	self.DropDownORR:UpdateItems(DropDownList, self.Metronome.VM.EffectPrepareOnly + 1)
end

function PerformanceMetronomeSettingWinView:OnHide()
	-- 还原
	_G.UE.UAudioMgr:Get():SetAudioVolume(_G.UE.EWWiseAudioType.UI_Menu_Sound, _G.SettingsMgr:GetValueBySaveKey(MPDefines.UI_MenuSaveKey))
end

function PerformanceMetronomeSettingWinView:UpdateSlider()
	self.SliderBPM:SetValue((self.Metronome.VM.BPM - MPDefines.MetronomeSettings.BPMMin) 
		/ (MPDefines.MetronomeSettings.BPMMax - MPDefines.MetronomeSettings.BPMMin))
	self.SliderBeat:SetValue((self.Metronome.VM.BeatPerBar - MPDefines.MetronomeSettings.BeatMin)
		/ (MPDefines.MetronomeSettings.BeatMax - MPDefines.MetronomeSettings.BeatMin))
	self.SliderVolume:SetValue(self.Metronome.VM.Volume / MPDefines.MetronomeSettings.VolumeMax)
end

function PerformanceMetronomeSettingWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownRing, function(_, Value) 
		self.Metronome.VM.Effect = Value - 1
		self:CheckSettingsUIState()
	end)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownAddReady, function(_, Value)
		self.Metronome.VM.Prepare = Value - 1
		self.VM.PanelOnlyReadyRingVisible = self.Metronome.VM.Prepare == 1
		if self.Metronome:IsWorking() == false then
			self.Metronome:ResetMetronome()
		end
		
		self:CheckSettingsUIState()
	end)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownORR, function(_, Value)
		self.Metronome.VM.EffectPrepareOnly = Value - 1 
		self:CheckSettingsUIState()
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickBtnSave)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
	-- UIUtil.AddOnClickedEvent(self, self.BtnBeatHelp.InforBtn, self.OnClickedBtnBeatHelp)
	-- UIUtil.AddOnClickedEvent(self, self.BtnBPMHelp.InforBtn, self.OnClickedBtnBPMHelp)
	UIUtil.AddOnClickedEvent(self, self.BtnDefault.Button, self.OnClickBtnDefault)
end

function PerformanceMetronomeSettingWinView:OnClickedBtnBeatHelp()
	self.VM.PanelBeatIntroVisible = not self.VM.PanelBeatIntroVisible
end

function PerformanceMetronomeSettingWinView:OnClickedBtnBPMHelp()
	self.VM.PanelBPMIntroVisible = not self.VM.PanelBPMIntroVisible
end

function PerformanceMetronomeSettingWinView:OnClickBtnDefault()
	local Select = _G.UE.USaveMgr.GetInt(SaveKey.MetronomeSettingRestoreDefaultTipSelect, 0, true)
	if Select == 0 then
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(830031), LSTR(830041), function(_, Params)
			local IsNeverAgain = Params.IsNeverAgain
			if IsNeverAgain then
				--不再提醒
				_G.UE.USaveMgr.SetInt(SaveKey.MetronomeSettingRestoreDefaultTipSelect, 1, true)
			end
			self:RestoreDefaultSettingData()
		end, nil, LSTR(830014), LSTR(830038), {bUseNever = true, NeverMindText = LSTR(830006)})
	elseif Select == 1 then
		self:RestoreDefaultSettingData()
	end
end

--恢复默认设置
function PerformanceMetronomeSettingWinView:RestoreDefaultSettingData()
	MusicPerformanceUtil.ResetMetronomeSettings(self.Metronome.VM)
	self.VM.BPMValue = tostring(self.Metronome.VM.BPM)
	self.VM.BeatValue = tostring(self.Metronome.VM.BeatPerBar)
	self.VM.VolumeValue = tostring(self.Metronome.VM.Volume)
	_G.UE.UAudioMgr:Get():SetAudioVolume(_G.UE.EWWiseAudioType.UI_Menu_Sound, self.Metronome.VM.Volume)

	self.Metronome:ResetMetronome()
	self:UpdatePanelMetronome()
	self:UpdateSlider()
	self:UpdateDropDown()
	self:CheckSettingsUIState()
end

function PerformanceMetronomeSettingWinView:CheckSettingsUIState()
	-- 是否显示恢复默认设置按钮
	self.VM.BtnDefaultVisible = not MusicPerformanceUtil.IsDefaultMetronomeSettings(self.Metronome.VM)
	-- 使用SetSaved函数来获取保存的参数
	local SavedSettings = {}
	MusicPerformanceMetronomeVM.SetSaved(SavedSettings)
	-- 是否能进行保存
	self.VM.CanSave = not MusicPerformanceUtil.IsSameSettings(self.Metronome.VM, SavedSettings)
end

function PerformanceMetronomeSettingWinView:OnClickBtnSave()
	_G.UE.USaveMgr.SetInt(SaveKey.MetronomeEffectPrepareOnly, self.Metronome.VM.EffectPrepareOnly, true)
	_G.UE.USaveMgr.SetInt(SaveKey.MetronomeEffect, self.Metronome.VM.Effect, true)
	_G.UE.USaveMgr.SetInt(SaveKey.MetronomePrepare, self.Metronome.VM.Prepare, true)
	_G.UE.USaveMgr.SetInt(SaveKey.MetronomeBeatPerBarCount, self.Metronome.VM.BeatPerBar, true)
	_G.UE.USaveMgr.SetInt(SaveKey.MetronomeBPM, self.Metronome.VM.BPM, true)

	_G.SettingsMgr:SetValueBySaveKey(MPDefines.UI_MenuSaveKey, self.Metronome.VM.Volume)
	_G.UE.UAudioMgr:Get():SetAudioVolume(_G.UE.EWWiseAudioType.UI_Menu_Sound, self.Metronome.VM.Volume)
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceMetronomeSettingUpdate)
	self:CheckSettingsUIState()
	self:Hide()
end

function PerformanceMetronomeSettingWinView:OnClickBtnCancel()
	_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceMetronomeSettingView)
end

function PerformanceMetronomeSettingWinView:OnRegisterGameEvent()

end

function PerformanceMetronomeSettingWinView:OnRegisterBinder()
	local Binders = {
		{ "BPMTip", UIBinderSetText.New(self, self.TextBPM) },
		{ "BeatTip", UIBinderSetText.New(self, self.TextBeat) },
		{ "TempoTip", UIBinderSetText.New(self, self.TextTempo) },
		{ "VolumeValue", UIBinderSetText.New(self, self.TextVolumeValue) },
		{ "BeatValue", UIBinderSetText.New(self, self.TextBeatValue) },
		{ "BPMValue", UIBinderSetText.New(self, self.TextBPMValue) },
		{ "PanelBeatIntroVisible", UIBinderSetIsVisible.New(self, self.PanelBeatIntro, false, false) },
		{ "PanelBPMIntroVisible", UIBinderSetIsVisible.New(self, self.PanelBPMIntro, false, false) },
		{ "BtnDefaultVisible", UIBinderSetIsVisible.New(self, self.BtnDefault, false, false) },
		{ "PanelOnlyReadyRingVisible", UIBinderSetIsVisible.New(self, self.PanelOnlyReadyRing, false, false) },
		{ "CanSave",       		UIBinderSetIsEnabled.New(self, self.BtnSave) },
	}

	self:RegisterBinders(self.VM, Binders)
end

return PerformanceMetronomeSettingWinView