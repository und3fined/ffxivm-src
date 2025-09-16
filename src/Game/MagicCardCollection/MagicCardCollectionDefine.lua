---
--- Author: Carl
--- DateTime: 2023-09-12 11:36
--- Description:

local LSTR = _G.LSTR
local LockNameText = "？？？"
local LockDescText = LSTR(1140011)--1140011("详细信息将在收录该幻卡后显示")
local SearchEmptyText = LSTR(1140006)--1140006("没有符合要求的幻卡")
local CollectPercentText = LSTR(1140001)--1140001(""%s%%玩家收录")
local MajorCollectNumText = LSTR(1140016)--1140016("收录：%s/%s")
local CardNumText = LSTR(1140009)--1140009("编号：%03d")
local CardNumSpecialText = LSTR(1140008)--1140008("编号外：%03d")
local SearchTipText = LSTR(1140003)--1140003("搜索名称或编号")
local CardCollectPlayerNumText = LSTR(1140007)--1140007("累计数量：%s")
local LockGetWayName = LSTR(1140005)--1140005("未解锁")
local LockGetWayTips = LSTR(1140010)--1140010("该途径暂未解锁")
local CardFilterText = LSTR(1140002)--1140002("幻卡筛选")
local LockGetWayIconPath = "PaperSprite'/Game/UI/Atlas/MagicCardCollection/Frames/UI_MagicCard_book_Icon_Unkn_png.UI_MagicCard_book_Icon_Unkn_png'" 
local MaxGetWayShow = 3
local CardRedDotID = 6002

local CardUnlockFilter = {
    All = 1,
    Lock = 2,
    Unlock = 3,
}

local CardStarFilter = {
    All = 0,
    Star1 = 1,
    Star2 = 2,
    Star3 = 3,
    Star4 = 4,
    Star5 = 5,
}

local CardRaceFilter = {
    All = 0,
    Race1 = 1,
    Race2 = 2,
    Race3 = 3,
    Race4 = 4,
    Race5 = 5,
}


local MagicCardCollectionDefine = {
    LockNameText = LockNameText,
    SearchEmptyText = SearchEmptyText,
    CardUnlockFilter = CardUnlockFilter,
    CardStarFilter = CardStarFilter,
    CardRaceFilter = CardRaceFilter,
    CollectPercentText = CollectPercentText,
    CardNumText = CardNumText,
    CardCollectPlayerNumText = CardCollectPlayerNumText,
    MajorCollectNumText = MajorCollectNumText,
    LockDescText = LockDescText,
    CardNumSpecialText = CardNumSpecialText,
    LockGetWayName = LockGetWayName,
    LockGetWayTips = LockGetWayTips,
    LockGetWayIconPath = LockGetWayIconPath,
    MaxGetWayShow = MaxGetWayShow,
    SearchTipText = SearchTipText,
    CardRedDotID = CardRedDotID,
    CardFilterText = CardFilterText,
}

return MagicCardCollectionDefine