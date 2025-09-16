local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local WeatherAreaVM = require("Game/Weather/VM/WeatherAreaVM")
local WeatherRegionCfg = require("TableCfg/WeatherRegionCfg")

local WeatherRegionVM = LuaClass(UIViewModel) --单件

function WeatherRegionVM:Ctor()
    self.Name = ""
    self.Icon = ""
    self.BG = ""
    self.Areas = UIBindableList.New(WeatherAreaVM)

    -- self.IsAutoExpand = false
	-- self.IsExpanded = false
    self.RegionData = nil
    self.RegionID = nil
end

function WeatherRegionVM:IsEqualVM(Value)
    return nil ~= Value and Value.RegionID == self.RegionID
end

function WeatherRegionVM:UpdateVM(RegionInfo)
    -- self.IsAutoExpand = RegionInfo.IsAutoExpand
	-- self.IsExpanded = false

    self.RegionData = RegionInfo
    self.RegionID = RegionInfo.RegionID
    local Cfg = WeatherRegionCfg:FindCfgByKey(self.RegionID)
    if Cfg then
        self.Name = Cfg.Name
        self.Icon = Cfg.Icon
        self.BG = Cfg.BG or ""
    else
        _G.FLOG_ERROR("zhg WeatherRegionVM:UpdateVM cfg = nil")
    end
    self.Areas:UpdateByValues(self.RegionData.Areas, nil, false)
end

function WeatherRegionVM:GetFirstMapVM()
    local FirstArea = self.Areas:Get(1)
    if nil ~= FirstArea then
        return FirstArea:GetFirstMapVM()
    end
end

function WeatherRegionVM:Clear()
    self.RegionData = nil
    self.Areas:Clear() -- =  UIBindableList.New(WeatherAreaVM)
end

return WeatherRegionVM