local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR
local FateArchiveWorldEventTabItemVM = LuaClass(UIViewModel)

FateArchiveWorldEventTabItemVM.TypeTitleText = {
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS] = LSTR(190107),
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER] = LSTR(190108),
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE] = LSTR(190109)
}

FateArchiveWorldEventTabItemVM.TypeTitleIcon = {
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Icon_Map.UI_FateArchive_Icon_Map'",
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Icon_Monster.UI_FateArchive_Icon_Monster'",
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Icon_HardEvent.UI_FateArchive_Icon_HardEvent'"
}

FateArchiveWorldEventTabItemVM.NewTypeTitleIconNormal = {
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_IncidentCount_List03.UI_FateArchive_Img_IncidentCount_List03'",
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_IncidentCount_List01.UI_FateArchive_Img_IncidentCount_List01'",
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_IncidentCount_List02.UI_FateArchive_Img_IncidentCount_List02'"
}

FateArchiveWorldEventTabItemVM.NewTypeTitleIconSelect = {
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_MAP_PROGRESS] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_IncidentCount_ListSelect03.UI_FateArchive_Img_IncidentCount_ListSelect03'",
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_IncidentCount_ListSelect01.UI_FateArchive_Img_IncidentCount_ListSelect01'",
    [ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE] = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_IncidentCount_ListSelect02.UI_FateArchive_Img_IncidentCount_ListSelect02'"
}

function FateArchiveWorldEventTabItemVM:Ctor()
    self.TitleText = ""
    self.TitleIcon = self.TypeTitleIcon[1]
    self.NewTitleIconSelect = self.NewTypeTitleIconSelect[1]
    self.NewTitleIconNormal = self.NewTypeTitleIconNormal[1]
    -- self.TextColor = "313131FF"
    -- self.NodeStatus = 0
end

function FateArchiveWorldEventTabItemVM:OnBegin()
end

function FateArchiveWorldEventTabItemVM:IsEqualVM(Value)
    return false
end

function FateArchiveWorldEventTabItemVM:UpdateVM(Value)
    -- print(Value)
    self.Value = Value
    self.Type = Value.Type
    self.TitleText = self.TypeTitleText[Value.Type]
    self.TitleIcon = self.TypeTitleIcon[Value.Type]
    self.NewTitleIconSelect = self.NewTypeTitleIconSelect[Value.Type]
    self.NewTitleIconNormal = self.NewTypeTitleIconNormal[Value.Type]
end

function FateArchiveWorldEventTabItemVM:ClickedItemVM()
    print("FateArchiveWorldEventTabItemVM:ClickedItemVM", self.TitleText)
    _G.EventMgr:SendEvent(EventID.FateWorldEventItemClick, self.Type)
end

return FateArchiveWorldEventTabItemVM
