local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WeatherMapVM = require("Game/Weather/VM/WeatherMapVM")
local WeatherAreaCfg = require("TableCfg/WeatherAreaCfg")

local UIBindableList = require("UI/UIBindableList")
local WeatherAreaVM = LuaClass(UIViewModel) 

local WeatherUIUtil = require("Game/Weather/WeatherUIUtil")

function WeatherAreaVM:Ctor()
    self.Name = ""
    self.Maps = UIBindableList.New(WeatherMapVM)
    self.IsSelected = false

    self.TimeShow1 = "00"
    self.TimeShow2 = "08"
    self.TimeShow3 = "16"
end

function WeatherAreaVM:IsEqualVM(Value)
    return nil ~= Value and Value.AreaID == self.AreaID
end

function WeatherAreaVM:UpdateVM(AreaInfo)
    self.AreaData = AreaInfo
    self.AreaID = AreaInfo.AreaID

    local Cfg = WeatherAreaCfg:FindCfgByKey(self.AreaID)
    if Cfg then
        self.Name = Cfg.Name
    end

    -- 将自己作为父节点传递给WeatherMapVM
    local Maps = self.AreaData.Maps
    for Idx, MapInfo in pairs(Maps) do
        MapInfo["IsLastOne"] = Idx == #Maps
        MapInfo["ParentAreaVM"] = self
    end

    self.Maps:UpdateByValues(Maps)
    self:UpdTimeShow()
end

function WeatherAreaVM:UpdTimeShow()
    local TimeShowList = WeatherUIUtil.GetTimeShow(3)
    for Idx = 1, 3 do
        self["TimeShow" .. Idx] = TimeShowList[Idx]
    end
end

function WeatherAreaVM:SetIsSelected(IsSelected)
    self.IsSelected = IsSelected
end

function WeatherAreaVM:AdapterOnGetWidgetIndex()
    return 0
end

function WeatherAreaVM:AdapterOnGetChildren()
	return self.Maps:GetItems()
end

function WeatherAreaVM:AdapterOnGetCanBeSelected()
	return false  -- 不可选中，但受子节点选中影响
end

function WeatherAreaVM:AdapterOnGetIsCanExpand()
    return false  -- 不可收起
 end

function WeatherAreaVM:GetFirstMapVM()
    return self.Maps:Get(1)
end

return WeatherAreaVM