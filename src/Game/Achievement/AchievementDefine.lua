---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---

local RedDotName = "Root/Achievement"
local RedDotID = 15
local AchieveGroupRedDotName = "Root/AchieveGroup"

local LSTR = _G.LSTR

local TypeIconDefaultPath =
    "Texture2D'/Game/UI/Texture/Achievement/UI_Achievement_Icon_NewEntry_Style01.UI_Achievement_Icon_NewEntry_Style01'"
local TagetAchievementTotalNum = 30
local NewAchievementShowNum = 5


local OverviewTypeDataTable = {
    TypeID = 9999,
    Sort = 0,
    TypeName = LSTR(720004)
}

local OverviewCategoryDataTable = {
    {TypeID = 9999, CategoryID = 99991, Category = LSTR(720011), Sort = 2, ShowComplete = 0},
    {TypeID = 9999, CategoryID = 99992, Category = LSTR(720009), Sort = 1, ShowComplete = 0}
}

local AchievePointIconMap = {
    [0] = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Image_Level_0_png.UI_Achievement_Image_Level_0_png'",
    [5] = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Image_Level_1_png.UI_Achievement_Image_Level_1_png'",
    [10] = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Image_Level_2_png.UI_Achievement_Image_Level_2_png'",
    [20] = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Image_Level_2_png.UI_Achievement_Image_Level_2_png'",
    [30] = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Image_Level_3_png.UI_Achievement_Image_Level_3_png'",
    [40] = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Image_Level_3_png.UI_Achievement_Image_Level_3_png'",
}

---@class AchievementDefine
local AchievementDefine = {
    TypeIconDefaultPath = TypeIconDefaultPath,
    OverviewTypeDataTable = OverviewTypeDataTable,
    OverviewCategoryDataTable = OverviewCategoryDataTable,
    TagetAchievementTotalNum = TagetAchievementTotalNum,
    NewAchievementShowNum = NewAchievementShowNum,
    RedDotID = RedDotID,
    RedDotName = RedDotName,
    AchieveGroupRedDotName = AchieveGroupRedDotName,
    AchievePointIconMap = AchievePointIconMap,
}

return AchievementDefine

--[[       成就多语言id 内容注释
    720001,    --%s成就等级
    720002,    --%s达成了
    720003,    --“%s”的成就!
    720004,    --总览
    720005,    --暂无成就符合筛选条件
    720006,    --暂无成就，敬请期待
    720007,    --暂无最新解锁成就
    720008,    --暂无目标成就， 目标列表最多可加入%d个成就
    720009,    --最新解锁
    720010,    --未解锁
    720011,    --目标列表
    720012,    --目标列表: 
    720013,    --称号：%s
    720014,    --获得了称号%s
    720015,    --获得称号%s
    720016,    --进行中
    720017,    --成就等级
    720018,    --成就总览
    720019,    --成就
    720020,    --进度一览
    720021,    --已达成
    720022,    --成 就
    720023,    --达成
    720024,    --解锁成就
    720025,    --获得物品
    720026,    --成就点：%s
]]--
