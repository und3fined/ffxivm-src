local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapUtil = require("Game/Map/MapUtil")
local RideSpeedCfg = require("TableCfg/RideSpeedCfg")

local MountSpeedWinVM = LuaClass(UIViewModel)

function MountSpeedWinVM:Ctor()
    self.TextCity = ""
    self.CurSpeedLevel = 0
    self.TextGear1 = ""
    self.TextGear2 = ""
    self.ImgGearFocus1Visible = false
    self.ImgGearFocus2Visible = false
    self.ImgGearFocus4Visible = false
    self.ImgGearFocus5Visible = false
    self.ImgGearFocus6Visible = false
    --self.EFF_Focus1Visible = false
    --self.EFF_Focus2Visible = false
    self.EFF_Focus4Visible = false
    self.EFF_Focus5Visible = false
    self.EFF_Focus6Visible = false

    self.PanelGear2Visible = false
    self.PanelGear3Visible = false
    self.PanelGear5Visible = false
    self.PanelGear6Visible = false
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
    local CityNameString = Value.TextCityList[1]
    local MapID = Value.ShowMapID
    _G.FLOG_INFO("MountSpeedWinVM:UpdateContent, MapID:%d", MapID)
    local MaxSpeedLevel = 0
    local MountSpeedCfg = RideSpeedCfg:FindCfgByKey(MapID)
    if MountSpeedCfg then
        MaxSpeedLevel = MountSpeedCfg.MaxSpeedLevel or 0
    end
    if self.CurSpeedLevel == 3 then
        local RegionID = Value.RegionID
        local RegionName = MapUtil.GetRegionName(RegionID)
        CityNameString = string.format(LSTR(200020),RegionName)
    end
    
    self.TextCity = CityNameString
    self:SetSpeedLevelState(MaxSpeedLevel)
end

function MountSpeedWinVM:SetSpeedLevelState(MaxSpeedLevel)
    if MaxSpeedLevel == 1 then
        self.PanelGear2Visible = false
        self.PanelGear3Visible = false
        self.PanelGear5Visible = false
        self.PanelGear6Visible = false
    elseif MaxSpeedLevel == 2 then
        self.PanelGear2Visible = true
        self.PanelGear3Visible = false
        self.PanelGear5Visible = true
        self.PanelGear6Visible = false
    elseif MaxSpeedLevel == 3 then
        self.PanelGear2Visible = true
        self.PanelGear3Visible = true
        self.PanelGear5Visible = true
        self.PanelGear6Visible = true
    end
    if self.CurSpeedLevel == 1 then
        self.TextGear1 = LSTR(200004)
        self.TextGear2 = LSTR(200005)
        self.ImgGearFocus1Visible = false
        self.ImgGearFocus2Visible = false
        self.ImgGearFocus4Visible = true
        self.ImgGearFocus5Visible = false
        self.ImgGearFocus6Visible = false
        --self.EFF_Focus1Visible = false
        --self.EFF_Focus2Visible = false
        self.EFF_Focus4Visible = true
        self.EFF_Focus5Visible = false
        self.EFF_Focus6Visible = false
    elseif self.CurSpeedLevel == 2 then
        self.TextGear1 = LSTR(200005)
        self.TextGear2 = LSTR(200006)
        self.ImgGearFocus1Visible = true
        self.ImgGearFocus2Visible = false
        self.ImgGearFocus4Visible = true
        self.ImgGearFocus5Visible = true
        self.ImgGearFocus6Visible = false
        --self.EFF_Focus1Visible = true
        --self.EFF_Focus2Visible = false
        self.EFF_Focus4Visible = true
        self.EFF_Focus5Visible = true
        self.EFF_Focus6Visible = false
    elseif self.CurSpeedLevel == 3 then
        self.TextGear1 = LSTR(200006)
        self.TextGear2 = LSTR(200017)
        self.ImgGearFocus1Visible = true
        self.ImgGearFocus2Visible = true
        self.ImgGearFocus4Visible = true
        self.ImgGearFocus5Visible = true
        self.ImgGearFocus6Visible = true
        --self.EFF_Focus1Visible = true
        --self.EFF_Focus2Visible = true
        self.EFF_Focus4Visible = true
        self.EFF_Focus5Visible = true
        self.EFF_Focus6Visible = true
    end
end

return MountSpeedWinVM