---
--- Author: HugoWong
--- DateTime: 2024-06-04 17:06
--- Description:
---
---
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local GameType = ProtoCS.Game.PvPColosseum.PvPColosseumGameType
local GameMode = ProtoCS.Game.PvPColosseum.PvPColosseumMode
local TimeType = ProtoCS.Game.PvPColosseum.PvpColosseumBtlResultClass

local LSTR = _G.LSTR

local PVPInfoDefine = {}

PVPInfoDefine.TabType = {
    Overview = 1,
    CrystallineConflitPerformance = 2,
    FrontlinePerformance = 3,
}

PVPInfoDefine.RedDotID = {
    Overview = 18002,
    SeriesMalmstone = 18003,
    SeriesMalmstoneReward = 18004,
    SeriesMalmstoneBreakThrough = 18005,
}

-- 对战资料页签配置
PVPInfoDefine.Tabs = {
    [PVPInfoDefine.TabType.Overview] = {
        ID = PVPInfoDefine.TabType.Overview,
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Overview_Normal.UI_Icon_Tab_Personal_Overview_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Overview_Select.UI_Icon_Tab_Personal_Overview_Select'",
        ModuleID = ProtoCommon.ModuleID.ModuleIDBattle,
        Name = LSTR(130001),
        RedDotData = {
            RedDotName = "Root/Menu/PVPInfo/Overview",
            IsStrongReminder = true,
        },
    },
    [PVPInfoDefine.TabType.CrystallineConflitPerformance] = {
        ID = PVPInfoDefine.TabType.CrystallineConflitPerformance,
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Crystal_record_Normal.UI_Icon_Tab_Crystal_record_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Crystal_record_Select.UI_Icon_Tab_Crystal_record_Select'",
        ModuleID = ProtoCommon.ModuleID.ModuleIDPvPColosseumCrystal,
        Name = LSTR(130070),
    },
}

-- 对战资料默认打开页
PVPInfoDefine.DefaultTab = PVPInfoDefine.TabType.Overview

-- 对战玩法类型
PVPInfoDefine.GameTypeNameMap = {
    [GameType.Crystal] = LSTR(130002),
    [GameType.FrontLine] = LSTR(130027),
}

-- 对战玩法模式
PVPInfoDefine.GameModeNameMap = {
    [GameMode.Exercise] = LSTR(130009),
    [GameMode.Rank] = LSTR(130010),
    [GameMode.Custom] = LSTR(130011),
}

-- 对战战绩时间类型
PVPInfoDefine.TimeTypeNameMap = {
    [TimeType.CurSeason] = LSTR(130012),
    [TimeType.LastSeason] = LSTR(130013),
    [TimeType.CurWeek] = LSTR(130014),
}

-- 荣耀徽章展示颜色
PVPInfoDefine.HonorColorMap = {
    OwnIconColor = "FFFFFF",
    OwnNameColor = "D5D5D5",
    OwnDateColor = "D5D5D5",
    NotOwnIconColor = "A7A7A7",
    NotOwnNameColor = "828282",
    NotOwnDateColor = "828282"
}

-- 对战数据每周更新时间，周一5点
PVPInfoDefine.SeriesMalmstoneDataWeeklyUpdateTime = {
    WeekDay = 2,    -- Weekday由周日为1开始算
    Hour = 5,
}

-- 战利水晶商店ID
PVPInfoDefine.TrophyCrystalShopID = 3011

return PVPInfoDefine