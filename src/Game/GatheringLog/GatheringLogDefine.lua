---
--- Author: Leo
--- DateTime: 2023-03-30 18:28:42
--- Description: 采集笔记系统
---

local LSTR = _G.LSTR

local GatheringLogNoteType = 3
local TextListEmpty = 70001--暂未设置闹钟
local TextListEmptyCollection = 70002--暂无已收藏的采集物
local SpecialListEmpty = 70003--暂无特殊采集物
local GetNoSearchResult = 70004--未搜索到该物品

local DefauleSearchText = 70005--请输入采集物名
local SidebarCountDown = 180
local OneHourMin = 60
local Professionindex = {
    MinerJobIndex = 1,
    BotanistJobIndex = 2,
}

local ProfID = {
    MinerJobID = 36,
    BotanistJobID = 37,
}

local GatheringLogSliderType = {
    [ProfID.MinerJobID] = 6,
    [ProfID.BotanistJobID] = 5
}

local HorBarIndex = {
    NormalIndex = 1,
    SpecialIndex = 2,
    CollectionIndex = 3,
    ClockIndex = 4,
}

local GatherCondition = {
    RequireNormal = 70006,--获得力：
    TimeCondition = 70007,--刷新时间：
    Null = 70008,--无
}

local TimeFormat = {
    Start = 70009,--%s后开始
    End = 70010,--%s后结束
}

local DropDownConditions = {
    NoCondition = 70011,--全部
    Lineage = 70012,--传承录
    CommerceCollectibles = 70013,--收藏品交易
    OldPatronTrading = 70014,--老主顾交易
    RebuildIshgard = 70015,--重建伊修加德
    Appearing = 70016,--出现中
    AppearsWithinAnHour = 70017,--一小时内出现
    AppearsOneHourAway = 70018,--一小时外出现
    CareerStories = 70019,--职业任务
    Normal = 70020,--常规
    Special = 70021,--特殊
}

local LevelText = LSTR(70022)
local DropFilterTabData = {
    {
        {  Name = "1 ~ 5"..LevelText, LevelMin = 1, LevelMax = 5 }, --70022 级
        {  Name = "6 ~ 10"..LevelText, LevelMin = 6, LevelMax = 10 },
        {  Name = "11 ~ 15"..LevelText, LevelMin = 11, LevelMax = 15 },
        {  Name = "16 ~ 20"..LevelText, LevelMin = 16, LevelMax = 20 },
        {  Name = "21 ~ 25"..LevelText, LevelMin = 21, LevelMax = 25 },
        {  Name = "26 ~ 30"..LevelText, LevelMin = 26, LevelMax = 30 },
        {  Name = "31 ~ 35"..LevelText, LevelMin = 31, LevelMax = 35 },
        {  Name = "36 ~ 40"..LevelText, LevelMin = 36, LevelMax = 40 },
        {  Name = "41 ~ 45"..LevelText, LevelMin = 41, LevelMax = 45 },
        {  Name = "46 ~ 50"..LevelText, LevelMin = 46, LevelMax = 50 },
        {  Name = "51 ~ 55"..LevelText, LevelMin = 51, LevelMax = 55 },
        {  Name = "56 ~ 60"..LevelText, LevelMin = 56, LevelMax = 60 },
        {  Name = "61 ~ 65"..LevelText, LevelMin = 61, LevelMax = 65 },
        {  Name = "66 ~ 70"..LevelText, LevelMin = 66, LevelMax = 70 },
        {  Name = "70 ~ 75"..LevelText, LevelMin = 71, LevelMax = 75 },
        {  Name = "79 ~ 80"..LevelText, LevelMin = 76, LevelMax = 80 },
        {  Name = "81 ~ 85"..LevelText, LevelMin = 81, LevelMax = 85 },
        {  Name = "86 ~ 90"..LevelText, LevelMin = 86, LevelMax = 90 },

    },
    {
        { Name = LSTR(70012), },
        { Name = LSTR(70013), },
        { Name = LSTR(70014),  },
        { Name = LSTR(70019),  },
        { Name = LSTR(70015),  },
    },
    {
        { Name = LSTR(70011), },--全部
        { Name = "1 ~ 10"..LevelText, LevelMin = 1, LevelMax = 10 },
        { Name = "11 ~ 20"..LevelText, LevelMin = 11, LevelMax = 20 },
        { Name = "21 ~ 30"..LevelText, LevelMin = 21, LevelMax = 30 },
        { Name = "31 ~ 40"..LevelText, LevelMin = 31, LevelMax = 40 },
        { Name = "41 ~ 50"..LevelText, LevelMin = 41, LevelMax = 50 },
        { Name = "51 ~ 60"..LevelText, LevelMin = 51, LevelMax = 60 },
        { Name = "61 ~ 70"..LevelText, LevelMin = 61, LevelMax = 70 },
        { Name = "71 ~ 80"..LevelText, LevelMin = 71, LevelMax = 80 },
        { Name = "81 ~ 90"..LevelText, LevelMin = 81, LevelMax = 90 },
    },
    {
        { Name = LSTR(70011), },--全部
        { Name = LSTR(70016), },--出现中
        { Name = LSTR(70023), },--即将出现（一小时内）
        --{ Name = LSTR("一小时外出现"), },
    }
}

-- local ChildTypeFilter = {
--     OldPatron1st = LSTR("熙洛·阿里亚珀"),
--     OldPatron2nd = LSTR("梅·娜格"),
--     OldPatron3rd = LSTR("红"),
--     OldPatron4th = LSTR("亚德基拉"),
--     OldPatron5th = LSTR("凯·希尔"),
--     OldPatron6th = LSTR("艾尔·图"),
--     OldPatron7th = LSTR("狄兰达尔伯爵"),
--     OldPatron8th = LSTR("阿梅莉安丝"),

--     CommerceCollectibles5th = "81~90级",
--     CommerceCollectibles4th = "71~80级",
--     CommerceCollectibles3rd = "61~70级",
--     CommerceCollectibles2nd = "51~60级",
--     CommerceCollectibles1st = "41~50级",

--     CareerStories1st = LSTR("职业任务"),
--     CareerStories2nd = LSTR("中庸工艺馆交易"),
--     CareerStories3rd = LSTR("魔法大学交易"),

--     RebuildIshgard1st = LSTR("重建伊修加德"),
--     RebuildIshgard2nd = LSTR("天钢工具"),
-- }

local SaturateTipText = {
    CollectTip = 70024,--无法收藏，收藏列表已满
    ClockTip = 70025,--无法加入闹钟列表，闹钟列表已满
}

local RedDotID = {
    GarherLog = 7, --二级界面笔记
    GarherLogProf = 8
}

local SpecialType = {
    SpecialTypeNone = 0,
    SpecialTypeSecret = 1, -- 秘籍
    SpecialTypeInherit = 2, --传承录
    SpecialTypeCollection = 3 -- 收藏品
  }

  local SearchState = {
    BeforSearch = 1,
    InSearching = 2
  }

  local CategoryItemIDMap = {
    [36] = {[1] = 60810001, [2] = 60810002},
    [37] = {[1] = 60810003, [2] = 60810004},
}

local VerIconTabIcons = {
    [30] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_CRP_Select.UI_Icon_Tab_Job_CRP_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_CRP_Normal.UI_Icon_Tab_Job_CRP_Normal'" },  -- "刻木匠"
    [28] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_BSM_Select.UI_Icon_Tab_Job_BSM_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_BSM_Normal.UI_Icon_Tab_Job_BSM_Normal'" },  -- "锻铁匠"
    [29] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_ARM_Select.UI_Icon_Tab_Job_ARM_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_ARM_Normal.UI_Icon_Tab_Job_ARM_Normal'" },   -- "铸甲匠"
    [31] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_GSM_Select.UI_Icon_Tab_Job_GSM_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_GSM_Normal.UI_Icon_Tab_Job_GSM_Normal'" },  -- "雕金匠"
    [33] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_LTW_Select.UI_Icon_Tab_Job_LTW_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_LTW_Normal.UI_Icon_Tab_Job_LTW_Normal'" },   -- "制革匠"
    [32] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_WVR_Select.UI_Icon_Tab_Job_WVR_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_WVR_Normal.UI_Icon_Tab_Job_WVR_Normal'" },  -- "裁衣匠"
    [34] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_ALC_Select.UI_Icon_Tab_Job_ALC_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_ALC_Normal.UI_Icon_Tab_Job_ALC_Normal'" },   -- "炼金术士"
    [35] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_CUL_Select.UI_Icon_Tab_Job_CUL_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_CUL_Normal.UI_Icon_Tab_Job_CUL_Normal'" },   -- "烹调师"
    [36] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_MIN_Select.UI_Icon_Tab_Job_MIN_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_MIN_Normal.UI_Icon_Tab_Job_MIN_Normal'" },   -- "采矿工"
    [37] = { SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_BTN_Select.UI_Icon_Tab_Job_BTN_Select'", IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_BTN_Normal.UI_Icon_Tab_Job_BTN_Normal'" },  -- "园艺工"
} 

local GatheringLogDefine = {
    VerIconTabIcons = VerIconTabIcons,
    CategoryItemIDMap = CategoryItemIDMap,
    DefauleSearchText = DefauleSearchText,
    TextListEmpty = TextListEmpty,
    GetNoSearchResult = GetNoSearchResult,
    TextListEmptyCollection = TextListEmptyCollection,
    SpecialListEmpty = SpecialListEmpty,
    HorBarIndex = HorBarIndex,
    Professionindex = Professionindex,
    ProfID = ProfID,
    DropFilterTabData = DropFilterTabData,
    DropDownConditions = DropDownConditions,
    --ChildTypeFilter = ChildTypeFilter,
    GatherCondition = GatherCondition,
    TimeFormat = TimeFormat,
    OneHourMin = OneHourMin,
    GatheringLogNoteType = GatheringLogNoteType,
    SaturateTipText = SaturateTipText,
    GatheringLogSliderType = GatheringLogSliderType,
    SidebarCountDown = SidebarCountDown,
    SearchState = SearchState,
    NormalGatherLevel = 5,
    RedDotID = RedDotID,
    SpecialType = SpecialType,
    CollectionUnLockLevel = 40,
    UnUsedInheritText = LSTR(70026),--暂无传承录，请前往%s购买
    CollectionQuestID = 200184, --采集笔记和制作笔记的收藏品交易解锁都是这个任务
    ClockSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_AlarmClockSounds.Play_FM_AlarmClockSounds'",
    SkillAttackBtnSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_Magic_card_atlas_opened.Play_UI_Magic_card_atlas_opened'",
    LockIcon = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Img_Lock2_png.UI_Comm_Img_Lock2_png'",
    DefaultGameVersionNum = 200,
    MaxLevel = 50,
}

return GatheringLogDefine
