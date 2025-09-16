---
--- Author: moodliu
--- DateTime: 2024-04-30 14:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIUtil = require("Utils/UIUtil")
local PerformAssistantCfg = require("TableCfg/PerformAssistantCfg")
local PerformanceSongNewPanelVM = require("Game/Performance/VM/PerformanceSongNewPanelVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local MusicPerformanceSongNewItemVM = require("Game/Performance/VM/MusicPerformanceSongNewItemVM")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local SaveKey = require("Define/SaveKey")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local DataReportUtil = require("Utils/DataReportUtil")

---@class PerformanceSongNewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStart CommBtnLView
---@field BtnSwitchInstrument UFButton
---@field CommBack CommBackBtnView
---@field DropDownMode CommDropDownListView
---@field ImgInstruIcon UFImage
---@field ImgInstruIconBg UFImage
---@field ImgMode UFImage
---@field ImgTinyIcon UFImage
---@field PanelElectricGuitar UFCanvasPanel
---@field PanelSongList UFCanvasPanel
---@field SliderSpeed CommSliderHorizontalView
---@field TableViewSongs UTableView
---@field TextBPM UFTextBlock
---@field TextBeat UFTextBlock
---@field TextInstrumentName UFTextBlock
---@field TextMetronome UFTextBlock
---@field TextMode UFTextBlock
---@field TextName UFTextBlock
---@field TextSpeed UFTextBlock
---@field TextSpeed1 UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleBtnMetronome UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceSongNewPanelView = LuaClass(UIView, true)

function PerformanceSongNewPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStart = nil
	--self.BtnSwitchInstrument = nil
	--self.CommBack = nil
	--self.DropDownMode = nil
	--self.ImgInstruIcon = nil
	--self.ImgInstruIconBg = nil
	--self.ImgMode = nil
	--self.ImgTinyIcon = nil
	--self.PanelElectricGuitar = nil
	--self.PanelSongList = nil
	--self.SliderSpeed = nil
	--self.TableViewSongs = nil
	--self.TextBPM = nil
	--self.TextBeat = nil
	--self.TextInstrumentName = nil
	--self.TextMetronome = nil
	--self.TextMode = nil
	--self.TextName = nil
	--self.TextSpeed = nil
	--self.TextSpeed1 = nil
	--self.TextTitle = nil
	--self.ToggleBtnMetronome = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceSongNewPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.CommBack)
	self:AddSubView(self.DropDownMode)
	self:AddSubView(self.SliderSpeed)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceSongNewPanelView:OnInit()
	self:InitStaticText()
	self.AdapterTableViewSongs = UIAdapterTableView.CreateAdapter(self, self.TableViewSongs, self.OnSelectChangedTableViewSongs, true)
	self.VM = PerformanceSongNewPanelVM.New()

	self.SliderSpeed:SetValueChangedCallback(function (v)
		self.VM.SpeedValue = MusicPerformanceUtil.SliderValueToAssistantSpeed(v)
	end)
	
	local Cfgs = PerformAssistantCfg:FindAllCfg("ID > 0")
	local TableViewSongsList = {}
	local Index = 0

	for _, Cfg in pairs(Cfgs) do
		Index = Index + 1
		local VM = MusicPerformanceSongNewItemVM.New()
		table.insert(TableViewSongsList, { Index = Index, VM = VM, Cfg = Cfg })
	end

	self.VM.TableViewSongsList = TableViewSongsList
end

function PerformanceSongNewPanelView:InitStaticText()
	self.TextTitle:SetText(_G.LSTR(830074))
	self.TextSpeed1:SetText(_G.LSTR(830083))
	self.TextMode:SetText(_G.LSTR(830055))
	self.TextMetronome:SetText(_G.LSTR(830082))

	self.BtnStart:SetBtnName(_G.LSTR(830075))
end

function PerformanceSongNewPanelView:OnToggleBtnMetronomeClicked()
	self.VM.ToggleMetronome = not self.VM.ToggleMetronome
end

function PerformanceSongNewPanelView:OnSelectChangedTableViewSongs(Index, ItemData, ItemView)
	self.VM.SelectedSong = ItemData.Cfg
end

function PerformanceSongNewPanelView:OnSelectedSongChanged(NewSongVM)
	if NewSongVM == nil then
		return
	end
	self.VM.TextName = NewSongVM.Name
	self.VM.TextBPM = LSTR(830004) .. tostring(NewSongVM.Bpm)
	self.VM.TextBeat = LSTR(830003) .. string.format("%d/%d", NewSongVM.Beat1, NewSongVM.Beat2)
end

function PerformanceSongNewPanelView:OnSpeedValueChanged(NewValue)
	self.VM.TextSpeed = string.format("%.1f", NewValue) .. LSTR(830001)
end

function PerformanceSongNewPanelView:OnDestroy()

end

function PerformanceSongNewPanelView:OnShow()

	self.AdapterTableViewSongs:CancelSelected()
	self.AdapterTableViewSongs:SetSelectedIndex(1)
	self.SliderSpeed:SetValue(MusicPerformanceUtil.AssistantSpeedToSliderValue(1.0))
	self.VM.SpeedValue = 1.0

	self:UpdatePerformData()

	local ModeDropDownList = { {Name = LSTR(830013)}, {Name = LSTR(830010)} }
	self.DropDownMode:UpdateItems(ModeDropDownList, MusicPerformanceUtil.GetKeybordMode())
end

function PerformanceSongNewPanelView:OnActive()
	self:UpdatePerformData()
end


function PerformanceSongNewPanelView:OnHide()
	self:DelDotData()
end

function PerformanceSongNewPanelView:UpdatePerformData()
	local PerformData = _G.MusicPerformanceMgr:GetSelectedPerformData()
	if PerformData then
		self.VM.PerformName = PerformData.Name
		self.VM.SmallIconPath = PerformData.SmallIcon
		self.VM.BaseIconPath = PerformData.BaseIcon
		self.VM.BigIconPath = PerformData.BigIcon
	end

	local GroupID = _G.MusicPerformanceMgr:GetGroupID(PerformData)
	self.VM.PanelElectricGuitarVisible = GroupID ~= nil
	if GroupID then
		self.VM.ImgModePath = string.format("PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Icon_%d_png.UI_Performance_Icon_%d_png'", GroupID, GroupID)
	end
end

function PerformanceSongNewPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBack.Button, self.OnCommBackClick)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMetronome, self.OnToggleBtnMetronomeClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitchInstrument, self.OnSwitchInstrumentClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnStartClicked)

	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownMode, function(_, Value) 
		_G.UE.USaveMgr.SetInt(SaveKey.PerformanceKeyboardMode, Value, true)
	end)
end

function PerformanceSongNewPanelView:OnCommBackClick()
	self:Hide()
end

function PerformanceSongNewPanelView:OnRegisterGameEvent()

end

function PerformanceSongNewPanelView:OnSwitchInstrumentClicked()
	_G.MusicPerformanceMgr:ReqAbortPerform(true)
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSelectPanelView, { IsMusicAssistant = true })
end

function PerformanceSongNewPanelView:OnBtnStartClicked()
	if self.VM.SelectedSong then
		_G.MusicPerformanceMgr:ShowAssistantView(self.VM.SelectedSong, self.VM.SpeedValue, self.VM.ToggleMetronome)
		self:Hide()
        --演奏埋点(开始演奏)
		DataReportUtil.ReportSystemFlowData("PerformanceAssistant", tostring(1), tostring(MusicPerformanceUtil.GetKeybordMode()), tostring(self.VM.TextName))
	end
end

function PerformanceSongNewPanelView:OnRegisterBinder()
	local Binders = {
		{ "TableViewSongsList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewSongs) },
		{ "TextName", UIBinderSetText.New(self, self.TextName) },
		{ "TextBPM", UIBinderSetText.New(self, self.TextBPM) },
		{ "TextBeat", UIBinderSetText.New(self, self.TextBeat) },
		{ "TextSpeed", UIBinderSetText.New(self, self.TextSpeed) },
		{ "SpeedValue", UIBinderValueChangedCallback.New(self, nil, self.OnSpeedValueChanged) },
		{ "SelectedSong", UIBinderValueChangedCallback.New(self, nil, self.OnSelectedSongChanged) },
		{ "ToggleMetronome", UIBinderSetIsChecked.New(self, self.ToggleBtnMetronome) },

		{ "PerformName", UIBinderSetText.New(self, self.TextInstrumentName) },
		{ "SmallIconPath", UIBinderSetImageBrush.New(self, self.ImgTinyIcon) },
		{ "BaseIconPath", UIBinderSetImageBrush.New(self, self.ImgInstruIconBg) },
		{ "BigIconPath", UIBinderSetImageBrush.New(self, self.ImgInstruIcon) },

		{ "PanelElectricGuitarVisible", UIBinderSetIsVisible.New(self, self.PanelElectricGuitar, false, false, false) },
		{ "ImgModePath", UIBinderSetImageBrush.New(self, self.ImgMode) },
	}

	self:RegisterBinders(self.VM, Binders)
end

function PerformanceSongNewPanelView:DelDotData()
	local Cfgs = PerformAssistantCfg:FindAllCfg("ID > 0")
	for _, Cfg in pairs(Cfgs) do
		local DotName = string.format("Root/Performance/%s", Cfg.Name)
		RedDotMgr:DelRedDotByName(DotName)
	end
end

return PerformanceSongNewPanelView