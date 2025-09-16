---
--- Author: Administrator
--- DateTime: 2023-12-05 10:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
-- local WeatherUtil = require("Game/Weather/WeatherUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

local TimeUtil = require("Utils/TimeUtil")

local TimeDefine = require("Define/TimeDefine")
local AozyTimeDefine = TimeDefine.AozyTimeDefine

---@class NewWeatherDetailsTimeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgTime UFImage
---@field TextDate UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherDetailsTimeItemView = LuaClass(UIView, true)

function NewWeatherDetailsTimeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgTime = nil
	--self.TextDate = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherDetailsTimeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherDetailsTimeItemView:OnInit()
	
end

function NewWeatherDetailsTimeItemView:OnDestroy()

end

function NewWeatherDetailsTimeItemView:OnShow()

end

function NewWeatherDetailsTimeItemView:OnHide()

end

function NewWeatherDetailsTimeItemView:OnRegisterUIEvent()

end

function NewWeatherDetailsTimeItemView:OnRegisterGameEvent()

end

function NewWeatherDetailsTimeItemView:OnRegisterBinder()

end

local function GetWeatherStartDate(TimeOff)
	ServerTime = TimeUtil.GetServerTime()
	local Hour = ServerTime / AozyTimeDefine.AozyHour2RealSec + TimeOff * 8
	local ExHour = Hour % 8
	local StartHour = (Hour - ExHour) % 24 

	local Day = (Hour // 24) % 32 + 1
	local Moon = (Hour // (24 * 32) ) % 12 + 1
	local Year = (Hour // (24 * 32 * 12) ) + 1

	return StartHour, Day, Moon, Year
end

-- check weather date website = https://asvel.github.io/ffxiv-weather/#weth
function NewWeatherDetailsTimeItemView:SetTime(TimeOff, IsAozyTime)
	self.TimeOff = TimeOff
	
	local TimeStr1 = ""
	local TimeStr2 = ""

	if IsAozyTime then
		local StartHour, Day, Moon, Year = GetWeatherStartDate(self.TimeOff)
		local MoonTypeText = TimeUtil.GetMoonTypeText(TimeUtil.GetMoonTypeInfoByMoon(Moon))
		TimeStr1 = string.format("%s%d" .. _G.LSTR(610004), MoonTypeText, Day)
		TimeStr2 = string.format("%02d:%s", StartHour, "00")
	else
		local ST = TimeUtil.GetServerTime()
		local AdST = ST - (ST % (8 * TimeDefine.AozyTimeDefine.AozyHour2RealSec ) ) -- start time
						+ TimeOff * TimeDefine.AozyTimeDefine.AozyHour2RealSec * 8

		--LocalizationUtil				
		TimeStr1 = LocalizationUtil.GetTimeForFixedFormat(TimeUtil.GetTimeFormat("%Y/%m/%d %H:%M", AdST))	
		TimeStr2 = '' --LocalizationUtil.GetTimeForFixedFormat(TimeUtil.GetTimeFormat("%H:%M", AdST))
	end

	local TimeName = ""
	if IsAozyTime then
		TimeName = TimeDefine.TimeNameConfig[TimeDefine.TimeType.Aozy]
	else
		TimeName = TimeDefine.TimeNameConfig[TimeDefine.TimeType.Local]
	end

	self.TextServer:SetText(TimeName)
	-- UIUtil.ImageSetBrushFromAssetPath(self.ImgTime, IconRes)
	self.TextDate:SetText(TimeStr1)
	self.TextTime:SetText(TimeStr2)
end


return NewWeatherDetailsTimeItemView