---
--- Author: Leo
--- DateTime: 2023-08-29 15:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapCfg = require("TableCfg/MapCfg")

---@class WorldExploraPlaceItemVM : UIViewModel

local WorldExploraPlaceItemVM = LuaClass(UIViewModel)

function WorldExploraPlaceItemVM:Ctor()
    self.PlaceName = ""
    self.MapID = 0
end

function WorldExploraPlaceItemVM:IsEqualVM()
    return true
end

function WorldExploraPlaceItemVM:UpdateVM(Value)
    local ActivedTips = ""
    if (type(Value) == "table") then
        --风脉泉显示数量
        self.MapID = Value[1]
        local ActivedNum = Value[2]
        local TotalNum = Value[3]

        ActivedTips = "("..ActivedNum.."/"..TotalNum..")"
    else
        self.MapID = Value
    end

    local Cfg = MapCfg:FindCfgByKey(self.MapID)
    if Cfg == nil then
        return
    end
    local DisplayName = Cfg.DisplayName or ""
    
    self.PlaceName = DisplayName..ActivedTips
end

return WorldExploraPlaceItemVM