---
--- Author: anypkvcai
--- DateTime: 2022-10-24 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local AudioUtil = require("Utils/AudioUtil")
local MajorUtil = require("Utils/MajorUtil")
local MapVM = require("Game/Map/VM/MapVM")
local AetherCurrentsVM = require("Game/AetherCurrent/AetherCurrentsVM")
local AetherCurrentsMgr = require("Game/AetherCurrent/AetherCurrentsMgr")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
--local MapSetting = require("Game/Map/MapSetting")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MapDefine = require("Game/Map/MapDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MachineDetectDef = AetherCurrentDefine.MachineDetectDef
local RangeAlarmState = AetherCurrentDefine.RangeAlarmState
local MachineDetectRange = AetherCurrentDefine.MachineDetectRange
local SearchMachineStartAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Play_UI_AetherCompass.Play_UI_AetherCompass'"
local SearchMachineStopAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Stop_UI_AetherCompass.Stop_UI_AetherCompass'"
local FLOG_INFO = _G.FLOG_INFO

local MapContentType = MapDefine.MapContentType

---@class MiniMapPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoldSauser UFButton
---@field BtnMap UFButton
---@field BtnSkill UFButton
---@field ImgAetherCurrentIcon01 UFImage
---@field ImgAetherCurrentIcon02 UFImage
---@field ImgAetherCurrentIcon03 UFImage
---@field MapMarkerChocoboAnim MapMarkerChocoboAnimView
---@field MapMarkerMajor MapMarkerMajorView
---@field MaskBoxMap UMaskBox
---@field MiniMap UFCanvasPanel
---@field NaviMapContent NaviMapContentView
---@field PanelAetherCurrent UFCanvasPanel
---@field PanelCD UFCanvasPanel
---@field PanelGoldSauser UFCanvasPanel
---@field PanelMap UFCanvasPanel
---@field PanelSkillBtn UFCanvasPanel
---@field TextCD UTextBlock
---@field TextFar UFTextBlock
---@field WeatherBox MapWeatherBoxItemView
---@field Anim1 UWidgetAnimation
---@field Anim2 UWidgetAnimation
---@field Anim3 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMapMToS UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MiniMapPanelView = LuaClass(UIView, true)

--local MapScaleList = { 0.5, 1, 2 }

function MiniMapPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoldSauser = nil
	--self.BtnMap = nil
	--self.BtnSkill = nil
	--self.ImgAetherCurrentIcon01 = nil
	--self.ImgAetherCurrentIcon02 = nil
	--self.ImgAetherCurrentIcon03 = nil
	--self.MapMarkerChocoboAnim = nil
	--self.MapMarkerMajor = nil
	--self.MaskBoxMap = nil
	--self.MiniMap = nil
	--self.NaviMapContent = nil
	--self.PanelAetherCurrent = nil
	--self.PanelCD = nil
	--self.PanelGoldSauser = nil
	--self.PanelMap = nil
	--self.PanelSkillBtn = nil
	--self.TextCD = nil
	--self.TextFar = nil
	--self.WeatherBox = nil
	--self.Anim1 = nil
	--self.Anim2 = nil
	--self.Anim3 = nil
	--self.AnimIn = nil
	--self.AnimMapMToS = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MiniMapPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MapMarkerChocoboAnim)
	self:AddSubView(self.MapMarkerMajor)
	self:AddSubView(self.NaviMapContent)
	self:AddSubView(self.WeatherBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MiniMapPanelView:OnInit()
	self.MapImgPosition = _G.UE.FVector2D(0, 0)

	--self.Binders = {
	--	{ "WeatherID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedWeatherID) },
	--	{ "WeatherShowType", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedWeatherShowType) },
	--}

	self.Binders = {
		{"TextCD", UIBinderSetText.New(self, self.TextCD)},
		{"bShowCDPanel", UIBinderSetIsVisible.New(self, self.PanelCD)},
		{"bShowPanelSkillBtn", UIBinderSetIsVisible.New(self, self.PanelSkillBtn)},
		{"bShowGoldSauserMainBtn", UIBinderSetIsVisible.New(self, self.BtnGoldSauser, nil, true)},
		{"bShowSkillPanelDisContent", UIBinderSetIsVisible.New(self, self.TextFar)},
		{"ClosestPointDis", UIBinderSetText.New(self, self.TextFar)},
		{"RangeIndex", UIBinderValueChangedCallback.New(self, nil, self.OnRangeIndexChange)},
	}
	self.NaviMapContent:SetContentType(MapContentType.MiniMap)
	self.NaviMapContent:SetParent(self.PanelMap)
end

function MiniMapPanelView:OnDestroy()

end

function MiniMapPanelView:OnShow()
	if nil ~= self.MaskBoxMap then
		self.MaskBoxMap:RequestRender()
	end
end

function MiniMapPanelView:OnHide()

end

function MiniMapPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMap, self.OnClickedBtnMap)
	UIUtil.AddOnClickedEvent(self, self.BtnSkill, self.OnBtnSkillClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnGoldSauser, self.OnBtnGoldSauserMainEntranceClicked)
end

function MiniMapPanelView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldEnter)
end

function MiniMapPanelView:OnRegisterBinder()
	--self:RegisterBinders(MapVM, self.Binders)
	self:RegisterBinders(AetherCurrentsVM.SkillPanelVM, self.Binders)
end

function MiniMapPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimerUpdateMap, 0, 0.2, 0)
end
--
--function MiniMapPanelView:OnValueChangedWeatherID(Value)
--	self:ShoWeatherBox()
--end
--
--function MiniMapPanelView:OnValueChangedWeatherShowType(Value)
--	self:UpdateWeatherBox(Value)
--end
--
--function MiniMapPanelView:OnGameEventPWorldEnter(Params)
--	self:ShoWeatherBox()
--end

--function MiniMapPanelView:UpdateWeatherBox(ShowType)
--	if MapSetting.WeatherShowType.Always == ShowType then
--		UIUtil.SetIsVisible(self.WeatherBox, true)
--	elseif MapSetting.WeatherShowType.Never == ShowType then
--		UIUtil.SetIsVisible(self.WeatherBox, false)
--	else
--		self:ShoWeatherBox()
--	end
--end
--
--function MiniMapPanelView:ShoWeatherBox()
--	if MapSetting.GetSettingValue(MapSetting.SettingType.ShowWeather) ~= MapSetting.WeatherShowType.Default then
--		return
--	end
--
--	if nil ~= self.HideWeatherTimerID then
--		self:UnRegisterTimer(self.HideWeatherTimerID)
--	end
--
--	self.HideWeatherTimerID = self:RegisterTimer(self.OnTimerHideWeather, 10)
--
--	UIUtil.SetIsVisible(self.WeatherBox, true)
--end

--function MiniMapPanelView:PlayShowAnimation()
--	self:PlayAnimation(self.AnimMapMToS)
--end

--function MiniMapPanelView:OnTimerHideWeather()
--	UIUtil.SetIsVisible(self.WeatherBox, false)
--end

function MiniMapPanelView:OnTimerUpdateMap()
	self:UpdateImagePosition()
end

function MiniMapPanelView:UpdateImagePosition()
	local Position = MapVM:GetMajorPosition()

	local selfMapImgPosition = self.MapImgPosition
	selfMapImgPosition.X = -Position.X
	selfMapImgPosition.Y = -Position.Y

	self.NaviMapContent:SetContentPosition(selfMapImgPosition)
end

function MiniMapPanelView:OnClickedBtnMap()
	_G.WorldMapMgr:ShowCurrWorldMap()
end

function MiniMapPanelView:OnRangeIndexChange(RangeIndex)
	if not RangeIndex then
		return
	end
   
	local FeedBackDef = MachineDetectDef[RangeIndex]
	if not FeedBackDef then
		return
	end

	local RangeIconKey = FeedBackDef.RangeAlarmState
	UIUtil.SetIsVisible(self.ImgAetherCurrentIcon01,  RangeIconKey == RangeAlarmState.More100)
	UIUtil.SetIsVisible(self.ImgAetherCurrentIcon02,  RangeIconKey == RangeAlarmState.Less100)
	UIUtil.SetIsVisible(self.ImgAetherCurrentIcon03,  RangeIconKey == RangeAlarmState.Less30)
	self:StopAnimation(self.Anim1)
	self:StopAnimation(self.Anim2)
	self:StopAnimation(self.Anim3)
	local StopAnimRangeIndex = #MachineDetectRange + 1
	if RangeIndex ~= StopAnimRangeIndex then
		if RangeIndex == 1 then
			self:PlayAnimation(self.Anim3, 0, 0, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
		elseif RangeIndex == 2 then
			self:PlayAnimation(self.Anim2, 0, 0, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
		elseif RangeIndex == 3 then
			self:PlayAnimation(self.Anim1, 0, 0, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
		end
	end
end

function MiniMapPanelView:OnBtnSkillClicked()
	AetherCurrentsMgr:UseSearchMachine()
end

function MiniMapPanelView:OnBtnGoldSauserMainEntranceClicked()
	GoldSauserMainPanelMgr:OpenGoldSauserMainPanel()
end

-- 动画播放音效事件
function MiniMapPanelView:SequenceEvent_PlayNotice()
	if _G.UIViewMgr:IsViewVisible(UIViewID.TreasureHuntSkillPanel) then
		return
	end
	local MajorEntityID = MajorUtil.GetMajorEntityID()
    if not MajorEntityID then
        return
    end
	AudioUtil.LoadAndPlaySoundEvent(MajorEntityID, SearchMachineStartAudioPath, true)
	self:RegisterTimer(function()
		AudioUtil.LoadAndPlaySoundEvent(MajorEntityID, SearchMachineStopAudioPath, true)
	end, 1)
end

return MiniMapPanelView