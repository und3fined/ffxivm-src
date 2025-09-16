local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local WeatherMapExVM = LuaClass(UIViewModel) 
local UIBindableList = require("UI/UIBindableList")

local WeatherBallVM = require("Game/Weather/VM/WeatherBallVM")

local NMBallNum = 9
local ExBallNum = 30

function WeatherMapExVM:Ctor()
    self.MapID = nil
    self.Name = ""
    self.IsSelected = false

    self.BallDataNM = {} -- 收起
    self.BallDataEx = {} -- 展开
    self.IsExp = false

    for Idx = 1, NMBallNum do
        self.BallDataNM[Idx] = {TimeOff = Idx - 2}
    end

    for Idx = 1, ExBallNum do
        self.BallDataEx[Idx] = {TimeOff = Idx - 2}
    end

    self.BallList = UIBindableList.New(WeatherBallVM)
end

function WeatherMapExVM:IsEqualVM(Value)
    return nil ~= Value and Value.MapID == self.MapID
end

function WeatherMapExVM:UpdateVM(MapInfo)
    local LastMap = self.MapID
    self.MapID = MapInfo.MapID
    self.IsLastOne= MapInfo.IsLastOne
    self.ParentAreaVM = MapInfo.ParentAreaVM
    self.Name = MapInfo.MapName
    if LastMap ~= self.MapID then
        for Idx = 1, NMBallNum do
            self.BallDataNM[Idx].MapID = self.MapID
        end

        for Idx = 1, ExBallNum do
            self.BallDataEx[Idx].MapID = self.MapID
        end
    end

    self:SetIsExp(false)
end

function WeatherMapExVM:SetIsExp(V)
    self.IsExp = V
    self:UpdBallList()
end

function WeatherMapExVM:UpdBallList()
    local Data = self.IsExp and self.BallDataEx or self.BallDataNM
    self.BallList:UpdateByValues(Data)
    local Items = self.BallList:GetItems()

    for Idx, Item in pairs(Items) do
        local ShowBorder = false
        local NameColor = "D5D5D5"
        local ShowName = false

        if Idx == 2 then
            ShowBorder = true
            NameColor = "FFF4D0"
            ShowName = true
        end

        Item:SetShowBorder(ShowBorder)
        Item:SetShowName(ShowName)
        Item:SetNameColor(NameColor)
    end
end

function WeatherMapExVM:SetIsSelected(IsSelected)
    self.IsSelected = IsSelected
end

function WeatherMapExVM:AdapterOnGetWidgetIndex()
	return 1
end

function WeatherMapExVM:AdapterOnGetCanBeSelected()
    return true
 end

return WeatherMapExVM