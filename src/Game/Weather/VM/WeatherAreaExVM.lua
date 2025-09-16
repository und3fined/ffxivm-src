local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WeatherMapExVM = require("Game/Weather/VM/WeatherMapExVM")
local WeatherBarTimeItemVM = require("Game/Weather/VM/WeatherBarTimeItemVM")

local WeatherAreaCfg = require("TableCfg/WeatherAreaCfg")

local UIBindableList = require("UI/UIBindableList")
local WeatherAreaVMEx = LuaClass(UIViewModel) 

local WeatherUIUtil = require("Game/Weather/WeatherUIUtil")

function WeatherAreaVMEx:Ctor()
    self.Name = ""
    self.Maps = UIBindableList.New(WeatherMapExVM)
    self.IsSelected = false
    self.Times = UIBindableList.New(WeatherBarTimeItemVM)
    self.TimeData = {}
    self.IsShowTime = true
end

function WeatherAreaVMEx:IsEqualVM(Value)
    return nil ~= Value and Value.AreaID == self.AreaID
end

function WeatherAreaVMEx:UpdateVM(AreaInfo)

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

function WeatherAreaVMEx:UpdTimeShow()
    local TimeShowList = WeatherUIUtil.GetTimeShow(9)
    for Idx = 1, 9 do
        self.TimeData[Idx] = {}
        self.TimeData[Idx].Time = TimeShowList[Idx]
    end

    self.Times:UpdateByValues(self.TimeData)
end

function WeatherAreaVMEx:SetIsSelected(IsSelected)
    self.IsSelected = IsSelected
end

function WeatherAreaVMEx:AdapterOnGetWidgetIndex()
    return 0
end

function WeatherAreaVMEx:AdapterOnGetChildren()
	return self.Maps:GetItems()
end

function WeatherAreaVMEx:AdapterOnGetCanBeSelected()
	return false  -- 不可选中，但受子节点选中影响
end

function WeatherAreaVMEx:AdapterOnGetIsCanExpand()
    return false  -- 不可收起
 end

function WeatherAreaVMEx:GetFirstMapVM()
    return self.Maps:Get(1)
end

return WeatherAreaVMEx