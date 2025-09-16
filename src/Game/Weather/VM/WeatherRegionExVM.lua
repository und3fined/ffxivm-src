local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WeatherAreaExVM = require("Game/Weather/VM/WeatherAreaExVM")
local WeatherAreaCfg = require("TableCfg/WeatherAreaCfg")
local WeatherRegionCfg = require("TableCfg/WeatherRegionCfg")

local UIBindableList = require("UI/UIBindableList")
local WeatherRegionExVM = LuaClass(UIViewModel) 

local WeatherUIUtil = require("Game/Weather/WeatherUIUtil")

function WeatherRegionExVM:Ctor()
    self.Areas = UIBindableList.New(WeatherAreaExVM)
end

function WeatherRegionExVM:IsEqualVM(Value)
    return nil ~= Value and Value.RegionID == self.RegionID
end

function WeatherRegionExVM:UpdateVM(RegionInfo)
    self.RegionData = RegionInfo
    self.RegionID = RegionInfo.RegionID
    -- local Cfg = WeatherRegionCfg:FindCfgByKey(self.RegionID)
    -- if Cfg then
    --     self.Name = Cfg.Name
    --     self.Icon = Cfg.Icon
    -- else
    --     _G.FLOG_ERROR("zhg WeatherRegionVM:UpdateVM cfg = nil")
    -- end
    self.Areas:UpdateByValues(self.RegionData.Areas)
end

function WeatherRegionExVM:GetFirstMapVM()
    local FirstArea = self.Areas:Get(1)
    if nil ~= FirstArea then
        return FirstArea:GetFirstMapVM()
    end
end

function WeatherRegionExVM:Clear()
    self.RegionData = nil
    self.Areas:Clear() -- = UIBindableList.New(WeatherAreaExVM)
end

return WeatherRegionExVM