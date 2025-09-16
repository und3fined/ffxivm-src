---
--- Author: henghaoli
--- DateTime: 2024-12-05 10:25
--- Description:
---

---@class CraftingDetailUtil
local CraftingDetailUtil = {
}

local LSTR = _G.LSTR

local EDetailProf = {
    Carpenter = 1,
    Goldsmith = 2,
    Armorer = 3,
    Blacksmith = 4,
    Weaver = 5,
    Leather = 6,
}

local CarpenterGoldsmithWidgetMap = {
    LocalStr_IDList         = {  150038,      150033,       150034,       150036,         150035,       150037 },
    [EDetailProf.Carpenter] = { "TextTitle", "RichText02", "RichText03", "RichText04_1", "RichText04", "RichText05" },
    [EDetailProf.Goldsmith] = { "TextTitle", "RichText01", "TextSkill2", "RichText04",   "RichText02", "RichText03" },
}

local function InitBPLocalStrInternal(View, WidgetList, IDList)
    if not WidgetList or not IDList then
        return
    end

    for Index, ID in ipairs(IDList) do
        View[WidgetList[Index]]:SetText(LSTR(ID))
    end
end

function CraftingDetailUtil.InitBPLocalStr_CarpenterGoldsmith(View, DetailProf)
    local WidgetList = CarpenterGoldsmithWidgetMap[DetailProf]
    local IDList = CarpenterGoldsmithWidgetMap.LocalStr_IDList
    InitBPLocalStrInternal(View, WidgetList, IDList)
end

local ArmorerBlacksmithWidgetMap = {
    LocalStr_IDList          = {  150032,      150021,          150025,       150026,       150024,          150030,          150031,          150023,          150027,       150028 },
    [EDetailProf.Armorer]    = { "TextTitle", "TextExplain01", "RichText01", "RichText02", "TextExplain02", "TextExplain03", "TextExplain04", "TextExplain05", "RichText03", "RichText04" },
    [EDetailProf.Blacksmith] = { "TextTitle", "TextExplain01", "RichText01", "RichText02", "TextExplain02", "TextExplain03", "TextExplain04", "TextExplain05", "RichText03", "RichText04" },
}

function CraftingDetailUtil.InitBPLocalStr_ArmorerBlacksmith(View, DetailProf)
    local WidgetList = ArmorerBlacksmithWidgetMap[DetailProf]
    local IDList = ArmorerBlacksmithWidgetMap.LocalStr_IDList
    InitBPLocalStrInternal(View, WidgetList, IDList)
end

local WeaverLeatherWidgetMap = {
    LocalStr_IDList       = {  150055,      150053,      150054,   150041,   150040,   150039 },
    [EDetailProf.Weaver]  = { "TextTitle", "RichText01", "Text01", "Text04", "Text03", "Text02" },
    [EDetailProf.Leather] = { "TextTitle", "RichText01", "Text01", "Text04", "Text03", "Text02" },
}

function CraftingDetailUtil.InitBPLocalStr_WeaverLeather(View, DetailProf)
    local WidgetList = WeaverLeatherWidgetMap[DetailProf]
    local IDList = WeaverLeatherWidgetMap.LocalStr_IDList
    InitBPLocalStrInternal(View, WidgetList, IDList)
end

CraftingDetailUtil.EDetailProf = EDetailProf

return CraftingDetailUtil