local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local WeatherMapVM = LuaClass(UIViewModel) 

local WeatherBallVM = require("Game/Weather/VM/WeatherBallVM")

function WeatherMapVM:Ctor()
    self.MapID = nil
    self.Name = ""
    self.IsSelected = false

    self.WeatherBallDict = {
        WeatherBallVM.New(),
        WeatherBallVM.New(),
        WeatherBallVM.New(),
    }

    -- 地图三个天气球的数据
    self.WeatherBallDataDict = {
        {TimeOff = -1, --[[MapID = 0]]},
        {TimeOff = 0,},
        {TimeOff = 1}
    }
end

function WeatherMapVM:IsEqualVM(Value)
    return nil ~= Value and Value.MapID == self.MapID
end

function WeatherMapVM:UpdateVM(MapInfo)
    self.MapID = MapInfo.MapID
    self.ParentAreaVM = MapInfo.ParentAreaVM
    self.Name = MapInfo.MapName
    self.IsLastOne= MapInfo.IsLastOne

    for Idx = 1, 3 do
        self.WeatherBallDataDict[Idx].MapID = self.MapID
    end

    for Idx, Ball in pairs(self.WeatherBallDict) do
        Ball:UpdateVM(self.WeatherBallDataDict[Idx])

        local Alpha = 1
        local ShowBorder = false
        local NameColor = "D5D5D5"
        local ShowName = false

        -- if Idx == 1 then
        --     Alpha = 0.4
        -- end

        if Idx == 2 then
            ShowBorder = true
            NameColor = "FFF4D0"
            ShowName = true
        end

        Ball:SetAlpha(Alpha)
        Ball:SetShowBorder(ShowBorder)
        Ball:SetShowName(ShowName)
        Ball:SetNameColor(NameColor)
        Ball:SetIsUnExpBall(true)
    end
end

function WeatherMapVM:SetIsSelected(IsSelected)
    self.IsSelected = IsSelected
end

function WeatherMapVM:AdapterOnGetWidgetIndex()
	return 1
end

function WeatherMapVM:AdapterOnGetCanBeSelected()
    return true
 end

return WeatherMapVM