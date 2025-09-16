---
--- Author: skysong
--- DateTime: 2023-08-03 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GMMgr = require("Game/GM/GMMgr")
local GMVM2 = require("Game/GM/GMVM2")
local WeatherCfgTable = require("TableCfg/WeatherCfg")
local CEnvMgr = _G.UE.UEnvMgr

---@class GMWeatherView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GMButtonCloseGM GMButtonView
---@field GMButtonDefaultWeather GMSwitchView
---@field GMButtonPause GMSwitchView
---@field GMButtonPlay GMButtonView
---@field GMButtonShowWeatherTime GMSwitchView
---@field GMSpeed UGMInputTextBox_C
---@field GMWeatherIDs UComboBoxString
---@field WeatherTime GMSliderView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMWeatherView = LuaClass(UIView, true)

function GMWeatherView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GMButtonCloseGM = nil
	--self.GMButtonDefaultWeather = nil
	--self.GMButtonPause = nil
	--self.GMButtonPlay = nil
	--self.GMButtonShowWeatherTime = nil
	--self.GMSpeed = nil
	--self.GMWeatherIDs = nil
	--self.WeatherTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMWeatherView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GMButtonCloseGM)
	self:AddSubView(self.GMButtonDefaultWeather)
	self:AddSubView(self.GMButtonPause)
	self:AddSubView(self.GMButtonPlay)
	self:AddSubView(self.GMButtonShowWeatherTime)
	self:AddSubView(self.WeatherTime)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMWeatherView:OnInit()
	self.views = {self.GMButtonPlay,self.GMButtonPause,self.GMButtonShowWeatherTime,self.WeatherTime,self.GMButtonCloseGM,self.GMButtonDefaultWeather}
	self.IDNameMappingTable = {}
	self.WeatherCfgInfo = _G.UE.TMap(_G.UE.int32, _G.UE.FString)
	self.WeatherTime.IsWeatherSlider = true
	self.PlayRate = math.floor(CEnvMgr:Get():GetPlayRate())
	self.GMSpeed:SetText(tostring(self.PlayRate))
	self:InitWeatherCfgInfo()
end

function GMWeatherView:OnDestroy()
	self:ClearTimer()
end

function GMWeatherView:UpdateWeatherTimeSlider(Params)
	local Percent = CEnvMgr:Get():GetAysoTimePrecent()
	local nextValuef = 24 * Percent
	_G.GMMgr:SetCacheValue(self.WeatherTime.ViewModel.Params.ID, nextValuef)
	self.WeatherTime:UpdateView(true)
end

function GMWeatherView:OnShow()
	self.WeatherTimeTimerID = _G.TimerMgr:AddTimer(self, self.UpdateWeatherTimeSlider, 0, 0, 0)
end

function GMWeatherView:OnHide()
	self:ClearTimer()
end

function GMWeatherView:OnRegisterUIEvent()

end

function GMWeatherView:OnRegisterGameEvent()
	local EventID = require("Define/EventID")
	self:RegisterGameEvent(EventID.GMButtonClick, self.OnGMButtonClick)
	self:RegisterGameEvent(EventID.GMChangeWeatherTime, self.GMChangeWeatherTime)
end

function GMWeatherView:OnCloseWeatherGM()
	CEnvMgr:Get():CloseWeatherGM()
	self.PlayRate = 1.0
	self.GMSpeed:SetText(tostring(self.PlayRate))
	local WeatherID = _G.WeatherMgr:GetServerWeather()
	CEnvMgr:Get():SetWeather(WeatherID,2.0)
	self:SetComboBoxOptions(self.GMWeatherIDs, self.IDNameMappingTable)
end

function GMWeatherView:GMChangeWeatherTime()
	local TimeValue = _G.GMMgr:GetCacheValue(self.WeatherTime.ViewModel.Params.ID)
	local secs1 = math.modf(tonumber(TimeValue) * 3600)
	--secs1 = secs1 + hour * 3600

	CEnvMgr:Get():SetDesireAsyoTime(secs1,false)
end

function GMWeatherView:OnGMButtonClick(params)
	local Desc = params.Desc

	FLOG_WARNING("Enable OnGMButtonClick is %s",tostring(Desc))

	if Desc == "播放预览天气效果" then
		self.PlayRate = tonumber(self.GMSpeed:GetText())
		local WeatherType = 0
		local WeatherIdx = self.GMWeatherIDs:GetSelectedIndex()

		for k,v in pairs(self.IDNameMappingTable) do
			if WeatherIdx == 0 then
				WeatherType = k
				break
			else
				WeatherIdx = WeatherIdx - 1
			end
		end

		CEnvMgr:Get():SetWeather(WeatherType,2.0)
		CEnvMgr:Get():SetPlayRate(self.PlayRate)
		self:GMChangeWeatherTime()
	elseif Desc == "暂停时间流逝" then
		self.GMButtonPause:OnIDValueChangedCallback()
		local SwitchValue = GMMgr:GetCacheValue(params.ID)
		local bLockTime = SwitchValue == 1 and true or false
		CEnvMgr:Get():LockTime(bLockTime)
	elseif Desc == "显示天气信息面板" then
		local SwitchValue = GMMgr:GetCacheValue(params.ID)
		local bShow = SwitchValue == 1 and true or false
		_G.EventMgr:SendEvent(_G.EventID.GMShowWeatherInfoPanel,bShow)
	elseif Desc == "关闭预览天气效果" then
		self:OnCloseWeatherGM()
		_G.EventMgr:SendEvent(_G.EventID.GMShowWeatherInfoPanel,false)
	end
end

function GMWeatherView:ClearTimer()
	if self.WeatherTimeTimerID then
		_G.TimerMgr:CancelTimer(self.WeatherTimeTimerID)
		self.WeatherTimeTimerID = nil
	end
end

WeatherCmdList =
{
	{ Desc = "播放预览天气效果", ShowType = "按钮", CmdList = "client Weather set wetherID {}",IsServerCmd = 0, IsAutoSend = 1},
	{ Desc = "暂停时间流逝", ShowType = "开关", DefaultValue = 0, IsServerCmd = 0, IsAutoSend = 1},
	{ Desc = "显示天气信息面板", ShowType = "开关", DefaultValue = 0, IsServerCmd = 0, IsAutoSend = 1},
	{ Desc = "天气时间", ShowType = "进度条", CmdList = "client weather set time {}", IsServerCmd = 0, DefaultValue = 12,IsAutoSend = 1, Minimum = 0, Maximum = 24},
	{ Desc = "关闭预览天气效果", ShowType = "按钮", IsServerCmd = 0, IsAutoSend = 1},
}

function GMWeatherView:SetComboBoxOptions(CB, OptionTable)
	CB:ClearOptions()
	local WeatherID = CEnvMgr:Get():GetCurrentWeather()
	local idx = 0
	for Key, Value in pairs(OptionTable) do
		local Option = Value
		CB:AddOption(Option)

		if Key == WeatherID then
			CB:SetSelectedIndex(idx)
		else
			idx = idx + 1
		end
	end
end

function GMWeatherView:InitWeatherCfgInfo()
	local Cfgs = WeatherCfgTable:FindAllCfg()

	if Cfgs then
		for _,V in pairs(Cfgs) do
			if V.ID > 0 then
				self.WeatherCfgInfo:Add(V.ID,V.Name)
			end
		end
	end
end

function GMWeatherView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.IDNameMappingTable = CEnvMgr:Get():GetCurrentTodsystemActorWeathers(self.WeatherCfgInfo)
	self:SetComboBoxOptions(self.GMWeatherIDs, self.IDNameMappingTable)

	for i=1, #self.views do
		local idx = #GMMgr.GMCmdList + 1

		if GMMgr.GMCmdList[idx] == nil then
			table.insert(GMMgr.GMCmdList,{})
		end

		GMMgr.GMCmdList[idx].ID = idx
		GMMgr.GMCmdList[idx].Data = WeatherCmdList[i]
		GMMgr.GMCmdList[idx].Desc = WeatherCmdList[i].Desc

		local VM = GMVM2.New()
		VM.Params = GMMgr.GMCmdList[idx].Data
		VM.Desc  = GMMgr.GMCmdList[idx].Desc
		VM.ID = idx
		VM.Params.ID = idx

		if WeatherCmdList[i].ShowType == "进度条" then
			GMMgr:SetCacheValue(idx, WeatherCmdList[i].DefaultValue)
		end

		self.views[i]:ShowView({ Data = VM})
	end
end

return GMWeatherView