--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-17 09:52:15
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-20 11:06:55
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishNotesWindowVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
---@author Lucas
---DateTime: 2023-04-18 14:21:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local WeatherBallVM = require("Game/Weather/VM/WeatherBallVM")

---@class FishNotesWindowVM: UIViewModel
---@field StartDate string 开始日期
---@field StartTime string 开始时间
---@field Duration string 持续时间
---@field EndDate string 结束日期
---@field EndTime string 结束时间
local FishNotesWindowVM = LuaClass(UIViewModel)

function FishNotesWindowVM:Ctor()
    self.Index = 0
    self.ID = 0
    self.ParentKey = 0
    self.StartTime = ""
    self.Duration = ""
    self.TextWeather = ""
    self.bWeatherVisible = false
    self.bPreWeatherVisible = false

    self.WeatherVM = WeatherBallVM.New()
    self.PreWeatherVM = WeatherBallVM.New()
end

function FishNotesWindowVM:IsEqualVM(Value)
    return Value.Key == self.Key
end

function FishNotesWindowVM:UpdateVM(Value)
    self.ParentKey = Value.ParentKey
    self.Key = Value.Key

    local StartTime = Value.StartTime
    local EndTime = Value.EndTime
    local Duration = math.floor((EndTime - StartTime) / FishNotesDefine.TimeValue.Minute)
    self.StartTime = os.date("%H:%M", StartTime)
    self.Duration = string.format("%dmin", Duration)

    self.bWeatherVisible = false
    self.bPreWeatherVisible = false
    self.TextWeather = ""
    if Value.MapID ~= nil then
        self.WeatherVM:UpdateVM({MapID = Value.MapID, TimeOff = Value.WeatherOffset})
        self.TextWeather = self.WeatherVM.Name
        self.bWeatherVisible = true
        if Value.bChackPre then
            self.PreWeatherVM:UpdateVM({MapID = Value.MapID, TimeOff = Value.WeatherOffset-1})
            self.TextWeather = string.format("%s转%s", self.PreWeatherVM.Name, self.TextWeather)
            self.bPreWeatherVisible = true
        end
    end
end

function FishNotesWindowVM:GetKey()
	return self.Key
end

function FishNotesWindowVM:AdapterOnGetWidgetIndex()
	return 1
end

return FishNotesWindowVM