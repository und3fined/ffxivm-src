---
--- Author: moodliu
--- DateTime: 2023-11-24 16:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MusicPerformanceSongVM = require("Game/Performance/VM/MusicPerformanceSongVM")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PerformanceSongDetailPageVM = require("Game/Performance/VM/PerformanceSongDetailPageVM")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")

---@class PerformanceSongDetailPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommBackBtnView
---@field BtnLeftArrow UFButton
---@field BtnRightArrow UFButton
---@field BtnStart CommBtnLView
---@field BtnSwitchInstrument UFButton
---@field ImgInstruIcon UFImage
---@field ImgInstruIconBg UFImage
---@field ImgMode UFImage
---@field ImgTinyIcon UFImage
---@field PanelDetail UFCanvasPanel
---@field PanelElectricGuitar UFCanvasPanel
---@field SliderSpeed CommSliderHorizontalView
---@field TableViewRewards UTableView
---@field TextBPM UFTextBlock
---@field TextBeat UFTextBlock
---@field TextInstrumentName UFTextBlock
---@field TextName UFTextBlock
---@field TextSpeed UFTextBlock
---@field TextTime UFTextBlock
---@field ToggleBtnMetronome UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceSongDetailPageView = LuaClass(UIView, true)

function PerformanceSongDetailPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnLeftArrow = nil
	--self.BtnRightArrow = nil
	--self.BtnStart = nil
	--self.BtnSwitchInstrument = nil
	--self.ImgInstruIcon = nil
	--self.ImgInstruIconBg = nil
	--self.ImgMode = nil
	--self.ImgTinyIcon = nil
	--self.PanelDetail = nil
	--self.PanelElectricGuitar = nil
	--self.SliderSpeed = nil
	--self.TableViewRewards = nil
	--self.TextBPM = nil
	--self.TextBeat = nil
	--self.TextInstrumentName = nil
	--self.TextName = nil
	--self.TextSpeed = nil
	--self.TextTime = nil
	--self.ToggleBtnMetronome = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceSongDetailPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.SliderSpeed)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceSongDetailPageView:OnInit()
	self.AdapterRewards = UIAdapterTableView.CreateAdapter(self, self.TableViewRewards)
	self.VM = PerformanceSongDetailPageVM.New()

	self.SliderSpeed.MinValue = 0.8
	self.SliderSpeed.MaxValue = 1.2

	self.SliderSpeed.ValueChangedCallback = function(Value)
		local SpeedValue = _G.UE.UMathUtil.Lerp(self.SliderSpeed.MinValue, self.SliderSpeed.MaxValue, Value)
		self.VM.Speed = SpeedValue
	end
	self.SliderSpeed:SetValue(0.5)

	self.SongBinders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "Time", UIBinderValueChangedCallback.New(self, nil, self.OnTimeChanged) },
		{ "BPM", UIBinderValueChangedCallback.New(self, nil, self.OnBPMChanged) },
		{ "Beat1", UIBinderValueChangedCallback.New(self, nil, self.OnBeatChanged) },
		{ "Beat2", UIBinderValueChangedCallback.New(self, nil, self.OnBeatChanged) },
	}

end

function PerformanceSongDetailPageView:UpdatePerformData()
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

function PerformanceSongDetailPageView:OnActive()
	self:UpdatePerformData()
end

function PerformanceSongDetailPageView:OnDestroy()

end

function PerformanceSongDetailPageView:OnShow()
	self:UpdatePerformData()
end

function PerformanceSongDetailPageView:OnHide()

end

function PerformanceSongDetailPageView:OnBtnChangeIndexClicked(Offset)
	local SongVMs = MusicPerformanceMgr:GetAssistantInst().VMs
	local SongIndex = self.VM.SongIndex + Offset
	if SongIndex < 1 then
		SongIndex = 1
	elseif SongIndex > #SongVMs then
		SongIndex = #SongVMs
	end

	self.VM.SongIndex = SongIndex
end

function PerformanceSongDetailPageView:OnRegisterUIEvent()
	if nil ~= self.BtnClose then
		self.BtnClose:AddBackClick(self, function()
		self:Hide()
		end)
	end
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMetronome, self.OnToggleBtnMetronomeClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnLeftArrow, self.OnBtnChangeIndexClicked, -1)
	UIUtil.AddOnClickedEvent(self, self.BtnRightArrow, self.OnBtnChangeIndexClicked, 1)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitchInstrument, self.OnSwitchInstrumentClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnStartClicked)
end

function PerformanceSongDetailPageView:OnSpeedChanged(NewValue)
	self.VM.TextSpeed = string.format("%.2f", NewValue) .. LSTR(830009)
end

function PerformanceSongDetailPageView:OnToggleBtnMetronomeClicked()
	self.VM.ToggleMetronome = not self.VM.ToggleMetronome
end

function PerformanceSongDetailPageView:OnRegisterGameEvent()
end

function PerformanceSongDetailPageView:OnSwitchInstrumentClicked()
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSelectPanelView, { IsMusicAssistant = true })
end

function PerformanceSongDetailPageView:OnBtnStartClicked()
	_G.MusicPerformanceMgr:ShowAssistantView(self.SongVM)
end

function PerformanceSongDetailPageView:OnTimeChanged(Value)
	self.VM.TextTime = TimeUtil.GetTimeFormat("%M:%S", math.ceil(Value / 1000))
end

function PerformanceSongDetailPageView:OnBPMChanged(Value)
	self.VM.TextBPM = "BPM:" .. tostring(Value)
end

function PerformanceSongDetailPageView:OnBeatChanged()
	self.VM.TextBeat = "BEAT:" .. string.format("%d/%d", self.SongVM.Beat1, self.SongVM.Beat2)
end

function PerformanceSongDetailPageView:GetSongVMByIndex(Index)
	local SongVMs = MusicPerformanceMgr:GetAssistantInst().VMs

	if SongVMs == nil then
		return nil
	end

	return SongVMs[Index]
end

function PerformanceSongDetailPageView:OnSongIndexChanged(Index)
	local SongVM = self:GetSongVMByIndex(Index)
	if SongVM == nil then
		return
	end

	if self.SongVM then
		self:UnRegisterBinders(self.SongVM, self.SongBinders)
	end
	self.SongVM = SongVM
	self:RegisterBinders(self.SongVM, self.SongBinders)

	self.AdapterRewards:UpdateAll({
		{ScoreLevel = 6, SongVM = self.SongVM},
		{ScoreLevel = 5, SongVM = self.SongVM},
		{ScoreLevel = 4, SongVM = self.SongVM},
		{ScoreLevel = 3, SongVM = self.SongVM},
		{ScoreLevel = 2, SongVM = self.SongVM},
		{ScoreLevel = 1, SongVM = self.SongVM},
	})
	---@todo 更改逻辑为默认选取Level最低的
	self.AdapterRewards:ScrollToIndex(ProtoRes.MusicAwardRank.MusicAwardRank_C - ((SongVM.ScoreLevel == nil or SongVM.ScoreLevel == 0) and (ProtoRes.MusicAwardRank.MusicAwardRank_C) or SongVM.ScoreLevel) + 1)

	local SongVMs = MusicPerformanceMgr:GetAssistantInst().VMs
	local SongCount = SongVMs and #SongVMs or 0
	self.VM.BtnRightArrowEnable = Index < SongCount and SongCount > 1
	self.VM.BtnLeftArrowEnable = Index > 1 and SongCount > 1
end

function PerformanceSongDetailPageView:OnRegisterBinder()
	local Binders = {
		{ "TextTime", UIBinderSetText.New(self, self.TextTime) },
		{ "TextBPM", UIBinderSetText.New(self, self.TextBPM) },
		{ "TextBeat", UIBinderSetText.New(self, self.TextBeat) },
		{ "TextSpeed", UIBinderSetText.New(self, self.TextSpeed) },
		{ "Speed", UIBinderValueChangedCallback.New(self, nil, self.OnSpeedChanged) },
		{ "ToggleMetronome", UIBinderSetIsChecked.New(self, self.ToggleBtnMetronome) },
		{ "SongIndex", UIBinderValueChangedCallback.New(self, nil, self.OnSongIndexChanged) },
		{ "BtnLeftArrowEnable", UIBinderSetIsEnabled.New(self, self.BtnLeftArrow) },
		{ "BtnRightArrowEnable", UIBinderSetIsEnabled.New(self, self.BtnRightArrow) },

		{ "PerformName", UIBinderSetText.New(self, self.TextInstrumentName) },
		{ "SmallIconPath", UIBinderSetImageBrush.New(self, self.ImgTinyIcon) },
		{ "BaseIconPath", UIBinderSetImageBrush.New(self, self.ImgInstruIconBg) },
		{ "BigIconPath", UIBinderSetImageBrush.New(self, self.ImgInstruIcon) },

		{ "PanelElectricGuitarVisible", UIBinderSetIsVisible.New(self, self.PanelElectricGuitar, false, false, false) },
		{ "ImgModePath", UIBinderSetImageBrush.New(self, self.ImgMode) },
	}

	self:RegisterBinders(self.VM, Binders)

	local SongIndex = self.Params.IndexMap.SongIndex
	if SongIndex then
		self.VM.SongIndex = SongIndex
	end
end

return PerformanceSongDetailPageView