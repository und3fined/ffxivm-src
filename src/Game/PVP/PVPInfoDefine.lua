---
--- Author: HugoWong
--- DateTime: 2024-06-04 17:06
--- Description:
---
---
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local GameType = ProtoCS.Game.PvPColosseum.PvPColosseumGameType
local GameMode = ProtoCS.Game.PvPColosseum.PvPColosseumMode
local TimeType = ProtoCS.Game.PvPColosseum.PvpColosseumBtlResultClass
local RankType = ProtoRes.Game.pvp_rank_type

local LSTR = _G.LSTR

local PVPInfoDefine = {}

PVPInfoDefine.TabType = {
    -- FrontlinePerformance = n, -- 目前还没开始纷争前线的开发
    Overview = 1,
    CrystallineConflitPerformance = 2,
    CrystallineLeaderBoard = 3,
    CrystallineRankReward = 4,
    CrystallineRankRecord = 5,
}

--- 对战资料背景
PVPInfoDefine.TabBGType = {
    Default = 1,
    CrystallineRank = 2,
}

PVPInfoDefine.RedDotID = {
    Overview = 18002,
    SeriesMalmstone = 18003,
    SeriesMalmstoneReward = 18004,
    SeriesMalmstoneBreakThrough = 18005,
}

--- 页签自定义检查函数 Start ---
local function CheckCrystallineRankActivate()
    local ActivateVersion = "2.3.0"
    return _G.UE.UVersionMgr.IsBelowOrEqualGameVersion(ActivateVersion)
end

local function CheckParticipatedCrystallineRank()
    return _G.PVPInfoMgr:GetParticipatedCrystallineRank()
end
--- 页签自定义检查函数 End ---

--- 对战资料页签配置
PVPInfoDefine.Tabs = {
    [PVPInfoDefine.TabType.Overview] = {
        ID = PVPInfoDefine.TabType.Overview,
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Overview_Normal.UI_Icon_Tab_Personal_Overview_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Personal_Overview_Select.UI_Icon_Tab_Personal_Overview_Select'",
        ModuleID = ProtoCommon.ModuleID.ModuleIDBattle,
        Name = LSTR(130001),
        HelpInfoID = 11160,
        IsShowFunctionBtn = true,
        BGType = PVPInfoDefine.TabBGType.Default,
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
        HelpInfoID = 11160,
        IsShowFunctionBtn = true,
        BGType = PVPInfoDefine.TabBGType.Default,
    },
    [PVPInfoDefine.TabType.CrystallineLeaderBoard] = {
        ID = PVPInfoDefine.TabType.CrystallineLeaderBoard,
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_PVP_List_Normal.UI_Icon_Tab_PVP_List_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_PVP_List_Select.UI_Icon_Tab_PVP_List_Select'",
        ModuleID = ProtoCommon.ModuleID.ModuleIDBattle,
        Name = LSTR(130076),
        HelpInfoID = 11216,
        IsShowFunctionBtn = false,
        BGType = PVPInfoDefine.TabBGType.CrystallineRank,
        CheckTabValidFunc = CheckCrystallineRankActivate,
    },
    [PVPInfoDefine.TabType.CrystallineRankReward] = {
        ID = PVPInfoDefine.TabType.CrystallineRankReward,
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_PVP_Reward_Normal.UI_Icon_Tab_PVP_Reward_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_PVP_Reward_Select.UI_Icon_Tab_PVP_Reward_Select'",
        ModuleID = ProtoCommon.ModuleID.ModuleIDBattle,
        Name = LSTR(130088),
        HelpInfoID = 11217,
        IsShowFunctionBtn = false,
        BGType = PVPInfoDefine.TabBGType.CrystallineRank,
        CheckTabValidFunc = CheckCrystallineRankActivate,
    },
    [PVPInfoDefine.TabType.CrystallineRankRecord] = {
        ID = PVPInfoDefine.TabType.CrystallineRankRecord,
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_PVP_Job_Normal.UI_Icon_Tab_PVP_Job_Normal'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_PVP_Job_Select.UI_Icon_Tab_PVP_Job_Select'",
        ModuleID = ProtoCommon.ModuleID.ModuleIDPvPColosseumCrystal,
        Name = LSTR(130089),
        HelpInfoID = 11218,
        IsShowFunctionBtn = false,
        BGType = PVPInfoDefine.TabBGType.CrystallineRank,
        CheckTabValidFunc = CheckParticipatedCrystallineRank,
    },
}

--- 对战资料默认打开页
PVPInfoDefine.DefaultTab = PVPInfoDefine.TabType.Overview

--- 对战玩法类型
PVPInfoDefine.GameTypeNameMap = {
    [GameType.Crystal] = LSTR(130002),
    [GameType.FrontLine] = LSTR(130027),
}

--- 对战玩法模式
PVPInfoDefine.GameModeNameMap = {
    [GameMode.Exercise] = LSTR(130009),
    [GameMode.Rank] = LSTR(130010),
    [GameMode.Custom] = LSTR(130011),
}

--- 对战战绩时间类型
PVPInfoDefine.TimeTypeNameMap = {
    [TimeType.CurSeason] = LSTR(130012),
    [TimeType.LastSeason] = LSTR(130013),
    [TimeType.CurWeek] = LSTR(130014),
}

--- 荣耀徽章展示颜色
PVPInfoDefine.HonorColorMap = {
    OwnIconColor = "FFFFFF",
    OwnNameColor = "D5D5D5",
    OwnDateColor = "D5D5D5",
    NotOwnIconColor = "A7A7A7",
    NotOwnNameColor = "828282",
    NotOwnDateColor = "828282"
}

--- 水晶冲突段位图标
PVPInfoDefine.RankIconMap = {
    [RankType.RT_BRONZE] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_Dan_Img_BronzeS.UI_PVP_Dan_Img_BronzeS'",
    [RankType.RT_SILVER] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_Dan_Img_SilverS.UI_PVP_Dan_Img_SilverS'",
    [RankType.RT_GOLD] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_Dan_Img_GoldS.UI_PVP_Dan_Img_GoldS'",
    [RankType.RT_BIRKIN] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_Dan_Img_PlatinumS.UI_PVP_Dan_Img_PlatinumS'",
    [RankType.RT_DIAMOND] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_Dan_Img_DiamondS.UI_PVP_Dan_Img_DiamondS'",
    [RankType.RT_CRYSTALE] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_Dan_Img_CrystalS.UI_PVP_Dan_Img_CrystalS'",
}

--- 水晶冲突段位蓝图
PVPInfoDefine.RankBPMap = {
    [RankType.RT_None] = "PVP/Dan/PVPDanNone_UIBP",   -- 无段位是铜牌的虚影
    [RankType.RT_BRONZE] = "PVP/Dan/PVPDanBronze_UIBP",
    [RankType.RT_SILVER] = "PVP/Dan/PVPDanSilver_UIBP",
    [RankType.RT_GOLD] = "PVP/Dan/PVPDanGold_UIBP",
    [RankType.RT_BIRKIN] = "PVP/Dan/PVPDanPlatinum_UIBP",
    [RankType.RT_DIAMOND] = "PVP/Dan/PVPDanDiamond_UIBP",
    [RankType.RT_CRYSTALE] = "PVP/Dan/PVPDanCrystal_UIBP",
}

--- 对战数据每周更新时间，周一5点
PVPInfoDefine.SeriesMalmstoneDataWeeklyUpdateTime = {
    WeekDay = 2,    -- Weekday由周日为1开始算
    Hour = 5,
}

PVPInfoDefine.CrystallineBattleStyleTextMap = {
    [ProtoRes.CRYSTALLINE_STATISTIC_TYPE.CRYSTALLINE_STATISTIC_ESCORT] = LSTR(130098),
    [ProtoRes.CRYSTALLINE_STATISTIC_TYPE.CRYSTALLINE_STATISTIC_OUTPUT] = LSTR(130099),
    [ProtoRes.CRYSTALLINE_STATISTIC_TYPE.CRYSTALLINE_STATISTIC_SURVIVAL] = LSTR(130100),
    [ProtoRes.CRYSTALLINE_STATISTIC_TYPE.CRYSTALLINE_STATISTIC_KDA] = LSTR(130101),
    [ProtoRes.CRYSTALLINE_STATISTIC_TYPE.CRYSTALLINE_STATISTIC_CURE] = LSTR(130102),
}

--- 战利水晶商店ID
PVPInfoDefine.TrophyCrystalShopID = 3011

return PVPInfoDefine