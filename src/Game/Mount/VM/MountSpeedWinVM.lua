local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local MountSpeedWinVM = LuaClass(UIViewModel)

function MountSpeedWinVM:Ctor()
    self.TextCity = ""
    self.CurSpeedLevel = 0
    self.TextGear1 = ""
    self.TextGear2 = ""
    self.ImgGearFocus1Visible = false
    self.ImgGearFocus4Visible = false
    self.EFF_Focus4Visible = false
end

function MountSpeedWinVM:OnShutdown()
    self.TextCity = ""
    self.CurSpeedLevel = 0
end

function MountSpeedWinVM:UpdateContent(Value)
    if not Value then
        return 
    end
    self.CurSpeedLevel = Value.SpeedLevel
    if #Value.TextCityList == 0 or self.CurSpeedLevel == 0 then
        return
    end
    local Len = #Value.TextCityList
    local CityNameString = Value.TextCityList[1]
    for i = 2, Len do
        CityNameString = CityNameString .."、"..Value.TextCityList[i]
    end
    self.TextCity = CityNameString
    self:SetSpeedLevelState()
end

function MountSpeedWinVM:SetSpeedLevelState()
    if self.CurSpeedLevel == 1 then
        self.TextGear1 = LSTR(200004)
        self.TextGear2 = LSTR(200005)
        self.ImgGearFocus1Visible = false
        self.ImgGearFocus4Visible = false
        self.EFF_Focus4Visible = false
    elseif self.CurSpeedLevel == 2 then
        self.TextGear1 = LSTR(200005)
        self.TextGear2 = LSTR(200006)
        self.ImgGearFocus1Visible = true
        self.ImgGearFocus4Visible = true
        self.EFF_Focus4Visible = true
    end
end

return MountSpeedWinVM