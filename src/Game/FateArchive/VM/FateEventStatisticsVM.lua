local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local FateArchiveWorldEventTabItemVM = require("Game/FateArchive/VM/FateArchiveWorldEventTabItemVM")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR

local FateEventStatisticsVM = LuaClass(UIViewModel)

function FateEventStatisticsVM:Ctor()
    print("FateEventStatisticsVM:Ctor")
    self.bShowPanelWorldEvent = false
    self.bShowPanelMyEvent = false
    self.FateEventTypeList = UIBindableList.New(FateArchiveWorldEventTabItemVM)
    self.SelectedType = ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS
end

function FateEventStatisticsVM:OnBegin()
end

function FateEventStatisticsVM:OnShow()
    self:SelectType(ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS)
    local EventTypeList = {
        {Type = ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS},
        {Type = ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER},
        {Type = ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE}
    }
    if (self.FateEventTypeList == nil) then
        self.FateEventTypeList = UIBindableList.New(FateArchiveWorldEventTabItemVM)
    end
    self.FateEventTypeList:UpdateByValues(EventTypeList)
end

function FateEventStatisticsVM:RefreshWorldEvent()
    self.bShowPanelWorldEvent = true
    self.bShowPanelMyEvent = false
end

function FateEventStatisticsVM:RefreshMyEvent()
    self.bShowPanelMyEvent = true
    self.bShowPanelWorldEvent = false
end

function FateEventStatisticsVM:SelectType(Type)
    self.SelectedType = Type
    -- 开始初始化右边面板
end

return FateEventStatisticsVM
