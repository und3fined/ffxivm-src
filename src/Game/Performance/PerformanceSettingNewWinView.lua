---
--- Author: moodliu
--- DateTime: 2024-04-28 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MusicPerformanceSettingWinVM = require("Game/Performance/VM/MusicPerformanceSettingWinVM")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local SaveKey = require("Define/SaveKey")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local DataReportUtil = require("Utils/DataReportUtil")

---@class PerformanceSettingNewWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnCancel CommBtnLView
---@field BtnDefault CommBtnLView
---@field BtnOK CommBtnLView
---@field BtnScale1 UFButton
---@field BtnScale2 UFButton
---@field DropDownKeyBoard CommDropDownListView
---@field ImgSelect1 UFImage
---@field ImgSelect2 UFImage
---@field PanelSlider UFCanvasPanel
---@field PanelSlider2 UFCanvasPanel
---@field SliderBar CommSliderHorizontalView
---@field SliderBar2 CommSliderHorizontalView
---@field TextKeyBoard UFTextBlock
---@field TextMode UFTextBlock
---@field TextScale1 UFTextBlock
---@field TextScale2 UFTextBlock
---@field TextSliderValue UFTextBlock
---@field TextSliderValue2 UFTextBlock
---@field TextVolume UFTextBlock
---@field TextVolume2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceSettingNewWinView = LuaClass(UIView, true)

function PerformanceSettingNewWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnDefault = nil
	--self.BtnOK = nil
	--self.BtnScale1 = nil
	--self.BtnScale2 = nil
	--self.DropDownKeyBoard = nil
	--self.ImgSelect1 = nil
	--self.ImgSelect2 = nil
	--self.PanelSlider = nil
	--self.PanelSlider2 = nil
	--self.SliderBar = nil
	--self.SliderBar2 = nil
	--self.TextKeyBoard = nil
	--self.TextMode = nil
	--self.TextScale1 = nil
	--self.TextScale2 = nil
	--self.TextSliderValue = nil
	--self.TextSliderValue2 = nil
	--self.TextVolume = nil
	--self.TextVolume2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceSettingNewWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnDefault)
	self:AddSubView(self.BtnOK)
	self:AddSubView(self.DropDownKeyBoard)
	self:AddSubView(self.SliderBar)
	self:AddSubView(self.SliderBar2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceSettingNewWinView:OnInit()
	self:InitStaticText()
	self.VM = MusicPerformanceSettingWinVM.New()
	self.SliderBar.ValueChangedCallback = function(Value)
		self.VM.Volume = math.floor(MPDefines.MetronomeSettings.VolumeMax * Value)
		self.VM.VolumeValue = tostring(self.VM.Volume)
		self:CheckBtnState()
	end

	self.SliderBar2.ValueChangedCallback = function(Value)
		self.VM.Volume2 = math.floor(MPDefines.MetronomeSettings.VolumeMax * Value)
		self.VM.VolumeValue2 = tostring(self.VM.Volume2)
		self:CheckBtnState()
	end
end

function PerformanceSettingNewWinView:InitStaticText()
	self.BG:SetTitleText(_G.LSTR(830054))
	self.TextMode:SetText(_G.LSTR(830055))
	self.TextKeyBoard:SetText(_G.LSTR(830056))
	-- self.TextShield:SetText(_G.LSTR(830057))
	self.TextVolume:SetText(_G.LSTR(830094))
	self.TextVolume2:SetText(_G.LSTR(830126))
	self.TextScale1:SetText(_G.LSTR(830058))
	self.TextScale2:SetText(_G.LSTR(830059))
	
	self.BtnCancel:SetBtnName(_G.LSTR(830060))
	self.BtnDefault:SetBtnName(_G.LSTR(830061))
	self.BtnOK:SetBtnName(_G.LSTR(830062))
end

function PerformanceSettingNewWinView:UpdateSlider()
	self.SliderBar:SetValue(self.VM.Volume / MPDefines.MetronomeSettings.VolumeMax)
	self.VM.VolumeValue = tostring(self.VM.Volume)

	self.SliderBar2:SetValue(self.VM.Volume2 / MPDefines.MetronomeSettings.VolumeMax)
	self.VM.VolumeValue2 = tostring(self.VM.Volume2)
end

function PerformanceSettingNewWinView:UpdateDropDown()
	local SizeDropDownList = { {Name = LSTR(830023)}, {Name = LSTR(830022)} }
	self.DropDownKeyBoard:UpdateItems(SizeDropDownList, self.VM.KeySize)
	-- local SwitchDropDownList = { {Name = LSTR(830024)}, {Name = LSTR(830008)} }
	-- self.DropDownShield:UpdateItems(SwitchDropDownList, self.VM.OtherMuted and 1 or 2)
end

function PerformanceSettingNewWinView:CheckBtnState()
	self.VM.BtnDefaultVisible = not MusicPerformanceUtil.IsDefaultCommonSettings(self.VM)
		or _G.SettingsMgr:GetDefaultValueBySaveKey(MPDefines.InstrumentValSaveKey) ~= self.VM.Volume
		or _G.SettingsMgr:GetDefaultValueBySaveKey(MPDefines.InstrumentValSaveKey2) ~= self.VM.Volume2
	local SavedSetting = {}
	MusicPerformanceSettingWinVM.SetSaved(SavedSetting)
	self.VM.BtnOKEnable = not MusicPerformanceUtil.IsSameSettings(self.VM, SavedSetting)
end

function PerformanceSettingNewWinView:OnDestroy()

end

function PerformanceSettingNewWinView:OnShow()
	self.VM:SetSaved()
	self:UpdateSlider()
	self:UpdateDropDown()

	self:CheckBtnState()
end

function PerformanceSettingNewWinView:OnHide()

end

function PerformanceSettingNewWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownKeyBoard, function(_, Value) 
		self.VM.KeySize = Value
		self:CheckBtnState()
	end)
	-- UIUtil.AddOnSelectionChangedEvent(self, self.DropDownShield, function(_, Value) 
	-- 	self.VM.OtherMuted = Value == 1
	-- 	self:CheckBtnState()
	-- end)

	UIUtil.AddOnClickedEvent(self, self.BtnOK.Button, self.OnClickBtnOK)
	UIUtil.AddOnClickedEvent(self, self.BtnDefault.Button, self.OnClickBtnDefault)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.Hide)
	UIUtil.AddOnClickedEvent(self, self.BtnScale1, self.OnSelectKeyboardMode, 1)
	UIUtil.AddOnClickedEvent(self, self.BtnScale2, self.OnSelectKeyboardMode, 2)
end

function PerformanceSettingNewWinView:OnClickBtnOK()
	_G.UE.USaveMgr.SetInt(SaveKey.PerformanceKeyboardMode, self.VM.KeyboardMode, true)
	_G.UE.USaveMgr.SetInt(SaveKey.PerformanceKeySize, self.VM.KeySize, true)
	-- _G.UE.USaveMgr.SetInt(SaveKey.PerformanceOtherMuted, self.VM.OtherMuted and 1 or 0, true)
	
	_G.SettingsMgr:SetValueBySaveKey(MPDefines.InstrumentValSaveKey, self.VM.Volume)
	_G.SettingsMgr:SetValueByClientSetupKey("CSInstrumentsMainPlayerVol", self.VM.Volume)
	 
	_G.SettingsMgr:SetValueBySaveKey(MPDefines.InstrumentValSaveKey2, self.VM.Volume2)
	_G.SettingsMgr:SetValueByClientSetupKey("CSInstrumentsOthersVol", self.VM.Volume2)

	self:CheckBtnState()
	self:Hide()

	--演奏埋点(保存演奏设置)
	DataReportUtil.ReportPerformanceSetFlowData("PerformanceSetFlow", self.VM.KeyboardMode, self.VM.KeySize)
end

function PerformanceSettingNewWinView:OnClickBtnDefault()
	local Select = _G.UE.USaveMgr.GetInt(SaveKey.PerformanceSettingRestoreDefaultTipSelect, 0, true)
	if Select == 0 then
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(830031), LSTR(830041), function(_, Params)
			local IsNeverAgain = Params.IsNeverAgain
			if IsNeverAgain then
				--不再提醒
				_G.UE.USaveMgr.SetInt(SaveKey.PerformanceSettingRestoreDefaultTipSelect, 1, true)
			end
			self:SaveRestoreDefaultSettingData()
		end, nil, LSTR(830014), LSTR(830038), {bUseNever = true, NeverMindText = LSTR(830006)})
	elseif Select == 1 then
		self:SaveRestoreDefaultSettingData()
	end
end

--保存【恢复默认】设置时的数据
function PerformanceSettingNewWinView:SaveRestoreDefaultSettingData()
	MusicPerformanceUtil.ResetCommonSettings(self.VM)
	self.VM.Volume = _G.SettingsMgr:GetDefaultValueBySaveKey(MPDefines.InstrumentValSaveKey)
	self.VM.Volume2 = _G.SettingsMgr:GetDefaultValueBySaveKey(MPDefines.InstrumentValSaveKey2)

	self:UpdateSlider()
	self:UpdateDropDown()
	self:CheckBtnState()
end

function PerformanceSettingNewWinView:OnRegisterGameEvent()

end

function PerformanceSettingNewWinView:OnRegisterBinder()

	local Binders = {
		{ "VolumeValue", UIBinderSetText.New(self, self.TextSliderValue) },
		{ "VolumeValue2", UIBinderSetText.New(self, self.TextSliderValue2) },

		{ "BtnDefaultVisible", UIBinderSetIsVisible.New(self, self.BtnDefault, false, true) },
		{ "ImgSelect1Visible", UIBinderSetIsVisible.New(self, self.ImgSelect1, false, true) },
		{ "ImgSelect2Visible", UIBinderSetIsVisible.New(self, self.ImgSelect2, false, true) },
		{ "BtnOKEnable", UIBinderSetIsEnabled.New(self, self.BtnOK, false, false) },
		{ "KeyboardMode", UIBinderValueChangedCallback.New(self, nil, self.OnKeyboardModeChanged) },
	}

	self:RegisterBinders(self.VM, Binders)
end

function PerformanceSettingNewWinView:OnKeyboardModeChanged(NewValue)
	-- 单音阶
	self.VM.ImgSelect1Visible = NewValue == 1
	self.VM.ImgSelect2Visible = NewValue == 2
end

function PerformanceSettingNewWinView:OnSelectKeyboardMode(NewMode)
	self.VM.KeyboardMode = NewMode
	self:CheckBtnState()
end

return PerformanceSettingNewWinView