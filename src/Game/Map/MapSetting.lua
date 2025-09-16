--
-- Author: anypkvcai
-- Date: 2022-12-20 15:07
-- Description: 地图设置
--

local USaveMgr
local SaveKey = require("Define/SaveKey")
local MapVM = require("Game/Map/VM/MapVM")
local MapDefine = require("Game/Map/MapDefine")

local LSTR = _G.LSTR

local SettingType = {
	ShowIcon = 1,
	ShowText = 2,
	ShowWeather = 3,
	ShowTime = 4,
	ShowCrystalIcon = 5,
	WeatherType = 6,
	QuestType = 7,
	ShowWildBox = 8,
	ShowAetherCurrent = 9,
	ShowDiscoverNote = 10,
}

--local WeatherShowType = {
--	Default = 0,
--	Always = 1,
--	Never = 2,
--}

local QuestShowType = {
	All = 0, -- 默认全部任务
	Main = 1, -- 主线任务
}

local Settings = {
	[SettingType.ShowIcon] = {
		Value = 1,
		PropertyName = "MarkerIconVisible",
		Key = SaveKey.MapShowIcon,
		TipsText = LSTR(700001) -- "全部图标"
	},

	[SettingType.ShowText] = {
		Value = 1,
		PropertyName = "MarkerTextVisible",
		Key = SaveKey.MapShowText,
		TipsText = LSTR(700002) -- "地标文字"
	},

	[SettingType.ShowWeather] = {
		Value = 0,
		PropertyName = "MapWeatherVisible",
		Key = SaveKey.MapShowWeather,
		TipsText = LSTR(700003) -- "显示天气"
	},

	[SettingType.ShowTime] = {
		Value = 1,
		PropertyName = "MapTimeVisible",
		Key = SaveKey.MapShowTime,
		TipsText = LSTR(700004) --"显示时间"
	},

	[SettingType.ShowCrystalIcon] = {
		Value = 1,
		PropertyName = "MapCrystalIconVisible",
		Key = SaveKey.MapShowCrystalIcon,
		TipsText = LSTR(700005) -- "以太之光"
	},

	[SettingType.WeatherType] = {
		Value = 0,
		PropertyName = "WeatherShowType",
		Key = SaveKey.MapWeatherType,
		TipsText = LSTR(700006) -- "天气类型"
	},

	[SettingType.QuestType] = {
		Value = 0,
		PropertyName = "MapQuestShowType",
		Key = SaveKey.MapQuestShowType,
		TipsText = LSTR(700007) -- "任务类型"
	},

	[SettingType.ShowWildBox] = {
		Value = 0,
		PropertyName = "MapWildBoxVisible",
		Key = SaveKey.MapShowWildBox,
		TipsText = LSTR(700046)
	},

	[SettingType.ShowAetherCurrent] = {
		Value = 0,
		PropertyName = "MapAetherCurrentVisible",
		Key = SaveKey.MapShowAetherCurrent,
		TipsText = LSTR(700047)
	},

	[SettingType.ShowDiscoverNote] = {
		Value = 0,
		PropertyName = "MapDiscoverNoteVisible",
		Key = SaveKey.MapShowDiscoverNote,
		TipsText = LSTR(700048)
	},
}


local MapSetting = {
	SettingType = SettingType,
	--WeatherShowType = WeatherShowType,
	QuestShowType = QuestShowType,
}

function MapSetting.InitSetting()
	USaveMgr = _G.UE.USaveMgr

	for i = 1, #Settings do
		local Setting = Settings[i]
		local Value = USaveMgr.GetInt(Setting.Key, Setting.Value, true)
		Setting.Value = Value
		MapVM:SetPropertyValue(Setting.PropertyName, Value)
	end
end

function MapSetting.GetSettingValue(Type)
	local Setting = Settings[Type]
	if nil == Setting then
		return
	end

	return Setting.Value
end

function MapSetting.SetSettingValue(Type, Value)
	local Setting = Settings[Type]
	if nil == Setting then
		return
	end

	Setting.Value = Value
	USaveMgr.SetInt(Setting.Key, Value, true)
	MapVM:SetPropertyValue(Setting.PropertyName, Value)

	--[[
	if Value == 0 and Type == SettingType.ShowIcon then
		-- 取消“全部图标”时，也取消玩法标记的选项
		MapSetting.SetSettingValue(SettingType.ShowWildBox, 0)
		MapSetting.SetSettingValue(SettingType.ShowAetherCurrent, 0)
		MapSetting.SetSettingValue(SettingType.ShowDiscoverNote, 0)
	end
	--]]

	-- 切换为显示标记时，对应地图标记高亮效果
	if Value == 1 then
		if Type == SettingType.ShowWildBox then
			local Params = {}
			Params.MarkerPredicate = function(Marker)
				return Marker:GetType() == MapDefine.MapMarkerType.Gameplay and Marker:GetSubType() == MapDefine.MapGameplayType.WildBox
			end
			_G.EventMgr:SendEvent(_G.EventID.MapMarkerHighlight, Params)

		elseif Type == SettingType.ShowAetherCurrent then
			local Params = {}
			Params.MarkerPredicate = function(Marker)
				return Marker:GetType() == MapDefine.MapMarkerType.Gameplay and Marker:GetSubType() == MapDefine.MapGameplayType.AetherCurrent
			end
			_G.EventMgr:SendEvent(_G.EventID.MapMarkerHighlight, Params)

		elseif Type == SettingType.ShowDiscoverNote then
			local Params = {}
			Params.MarkerPredicate = function(Marker)
				return Marker:GetType() == MapDefine.MapMarkerType.Gameplay and Marker:GetSubType() == MapDefine.MapGameplayType.DiscoverNote
			end
			_G.EventMgr:SendEvent(_G.EventID.MapMarkerHighlight, Params)
		end
	end

end

---UpdateVM @一般可以等设置界面关闭后才更新
function MapSetting.UpdateVM()
	for i = 1, #Settings do
		local Setting = Settings[i]
		MapVM:SetPropertyValue(Setting.PropertyName, Setting.Value)
	end
end

function MapSetting.GetTipsText(Type)
	local Setting = Settings[Type]
	if nil == Setting then
		return
	end

	return Setting.TipsText
end


return MapSetting