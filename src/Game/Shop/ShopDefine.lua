---
--- Author: Alex
--- DateTime: 2023-02-03 18:28:42
--- Description: 商店系统
---
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local LSTR = _G.LSTR

local FilterName = {
    LSTR(1200011),
    LSTR(1200018),
    LSTR(1200068),
    LSTR(1200014),
    LSTR(1200073)
}

local FilterMainType = {
    ["MainSortType"] = 1,
    ["ViceSortType"] = 2,
    ["ItemQuality"] = 3,
    ["UseLevel"] = 4,
    ["Job"] = 5
}

--商品ImgHQ
local ItemHQColor = {
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_HQWhite.UI_Shop_Img_HQWhite'",
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_HQGreen.UI_Shop_Img_HQGreen'",
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_HQBlue.UI_Shop_Img_HQBlue'",
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_HQPurple.UI_Shop_Img_HQPurple'",
}

--商品ImgColor
local ItemColor = {
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_SlotWhite.UI_Shop_Img_SlotWhite'",
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_SlotGreen.UI_Shop_Img_SlotGreen'",
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_SlotBlue.UI_Shop_Img_SlotBlue'",
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_SlotPurple.UI_Shop_Img_SlotPurple'",
}

local HQColor = {
	"Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_HQWhite.UI_Shop_Img_HQWhite'",
	"Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_HQGreen.UI_Shop_Img_HQGreen'",
	"Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_HQBlue.UI_Shop_Img_HQBlue'",
	"Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_HQPurple.UI_Shop_Img_HQPurple'",
}

local FilterMainSort = {
    {
        Type = ProtoCommon.ItemMainType.ItemMainTypeNone,
        Name = "None"
    },
    {
        Type = ProtoCommon.ItemMainType.ItemArmor,
        Name = LSTR(1200084)
    },
    {
        Type = ProtoCommon.ItemMainType.ItemAccessory,
        Name = LSTR(1200086)
    },
    {
        Type = ProtoCommon.ItemMainType.ItemArm,
        Name = LSTR(1200057)
    },
    {
        Type = ProtoCommon.ItemMainType.ItemTool,
        Name = LSTR(1200031)
    },
    {
        Type = ProtoCommon.ItemMainType.ItemConsumables,
        Name = LSTR(1200065)
    },
    {
        Type = ProtoCommon.ItemMainType.ItemCollage,
        Name = LSTR(1200042)
    },
    {
        Type = ProtoCommon.ItemMainType.ItemMaterial,
        Name = LSTR(1200072)
    },
    {
        Type = ProtoCommon.ItemMainType.ItemHousing,
        Name = LSTR(1200041)
    },
    {
        Type = ProtoCommon.ItemMainType.ItemMiscellany,
        Name = LSTR(1200055)
    }
}

local ShopTextColor = {
    Red = "861516ff",
    White = "ffffffff"
}

local ShopMainInputHintText = LSTR(1200066)

local GoodsLimitBuyType = {
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER] = LSTR(1200063),
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_DAY] = LSTR(1200059),
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_WEEK] = LSTR(1200058),
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_MONTH] = LSTR(1200060)
}

local GoodsLimitBuyRemainNum = {
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER] = LSTR(1200064),
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_DAY] = LSTR(1200013),
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_WEEK] = LSTR(1200053),
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_MONTH] = LSTR(1200054)
}

local GoodsAdvType = {
    LSTR(1200045),
    LSTR(1200067),
    LSTR(1200085)
}

---分类配置索引 Cfg EnableFilter
local ClassifyCfgIndex = 1

---主界面新筛选行数限制
local MainPanelNewFilterRowLimit = 2

---商店搜索记录最大数量
local ShopMaxSearchRecordNum = 6

local MallCounterLimitBuyType = {
	[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_DAY] = 1200092, 		--- 每日限购:%d/%d
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_WEEK] = 1200093,		--- 每周限购:%d/%d
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_MONTH] = 1200094,		--- 每月限购:%d/%d
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER] = 1200095,	--- 永久限购:%d/%d
}

local ShopDefine = {
    --MainTabs = mainTabData,
    ShopMainInputHintText = ShopMainInputHintText,
    ShopTextColor = ShopTextColor,
    ShopFilterName = FilterName,
    LimitBuyType = GoodsLimitBuyType,
    AdvType = GoodsAdvType,
    LimitBuyNumTipsTitle = GoodsLimitBuyRemainNum,
    MainSortInfo = FilterMainSort,
    ClassifyCfgIndex = ClassifyCfgIndex,
    MainPanelNewFilterRowLimit = MainPanelNewFilterRowLimit,
    FILTER_MAINTYPE = FilterMainType,
    ShopMaxSearchRecordNum = ShopMaxSearchRecordNum,
    ItemColor = ItemColor,
    HQColor = HQColor,
    ItemHQColor = ItemHQColor,
	MallCounterLimitBuyType = MallCounterLimitBuyType,
}

return ShopDefine
