local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
-- local ProfUtil = require("Game/Profession/ProfUtil")
-- local UIUtil = require("Utils/UIUtil")
-- local ItemUtil = require("Utils/ItemUtil")
local WeatherCfg = require("TableCfg/WeatherCfg")

local PhotoSubTabItemVM = LuaClass(UIViewModel)

function PhotoSubTabItemVM:Ctor()
    self.WeatherID = 0
    self.Icon = ""
    self.IsSelt = false
    self.Name = ""
end

function PhotoSubTabItemVM:UpdateVM(WeatherID)
	self.WeatherID = WeatherID
    -- self.IsSelt = false

    local Cfg = WeatherCfg:FindCfgByKey(self.WeatherID)

    if Cfg then
        self.Icon = Cfg.Icon
        self.Name = Cfg.Name
    end
end

function PhotoSubTabItemVM:IsEqualVM(WeatherID)
	return WeatherID == self.WeatherID
end



return PhotoSubTabItemVM