--
-- Author: ZhengJianChuan
-- Date: 2025-09-02 15:55
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local WardrobeConsumeItemVM = require("Game/Wardrobe/VM/Item/WardrobeConsumeItemVM")
local WardrobePreviewColorItemVM = require("Game/Wardrobe/VM/Item/WardrobePreviewColorItemVM")
local DyeColorCfg = require("TableCfg/DyeColorCfg")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local LSTR

---@class WardrobePreviewColorWinVM : UIViewModel
local WardrobePreviewColorWinVM = LuaClass(UIViewModel)

---Ctor
function WardrobePreviewColorWinVM:Ctor()
    self.ColorAreaList = UIBindableList.New(WardrobePreviewColorItemVM)
    self.StainList1 = UIBindableList.New(WardrobeConsumeItemVM)
    self.StainList2 = UIBindableList.New(WardrobeConsumeItemVM)
    self.StainDataList = {}
    self.IsDiff = nil
    self.IsComsume = nil
    self.IsMore4 = nil
    self.IsLessStain = nil
end

function WardrobePreviewColorWinVM:OnInit()
end

function WardrobePreviewColorWinVM:OnBegin()
	LSTR = _G.LSTR
end

function WardrobePreviewColorWinVM:OnEnd()
end

function WardrobePreviewColorWinVM:OnShutdown()
end

function WardrobePreviewColorWinVM:UpdateColorAreaList(AppID, StainColorList, PreviewColorList)
    local ItemList = {}
    self.ColorAreaList:Clear()
    local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)
    if not IsAppRegionDye then
        if StainColorList.Color ~= PreviewColorList.Color then
        local Item = {}
        Item.SectionID = -1
        Item.SectionName = _G.LSTR(1080037) --全部
        Item.ColorID = StainColorList.Color
        Item.PreColorID = PreviewColorList.Color
        Item.AppID = AppID
        table.insert(ItemList, Item)
        end
        self.ColorAreaList:UpdateByValues(ItemList)
        self.IsDiff = #ItemList > 0
        return
    end

    local AllColor = nil 
    local AllPreviewColor = nil

    local IsAll = false
    local IsAllPreview = false

    for _, v in ipairs(StainColorList.RegionDye or {}) do
        if AllColor == nil then
            AllColor = v.ColorID
        end
        IsAll = v.ColorID == AllColor
        if not IsAll then
            break
        end
    end


    for _, v in ipairs(PreviewColorList.RegionDye or {}) do
        if AllPreviewColor == nil then
            AllPreviewColor = v.ColorID
        end
        IsAllPreview = v.ColorID == AllPreviewColor
        if not IsAllPreview then
            break
        end
    end

    -- 如果实际染色都一致，预览染色都一致，并且染色逻辑
    if IsAll and IsAllPreview and AllColor ~= AllPreviewColor then
        local Item = {}
        Item.AppID = AppID
        Item.SectionID = -1
        Item.SectionName = _G.LSTR(1080037) --全部
        Item.ColorID = StainColorList.RegionDye[1].ColorID
        Item.PreColorID = PreviewColorList.RegionDye[1].ColorID
        table.insert(ItemList, Item)
    else
        local StainLen = 0
        local PreviewLen = 0
        for _, v in pairs(StainColorList.RegionDye or {}) do
            StainLen = StainLen + 1
        end
        for _, v in pairs(PreviewColorList.RegionDye or {}) do
            PreviewLen = PreviewLen + 1
        end
        local StainRegionDye = StainColorList.RegionDye or {}
        local PreviewRegionDye = PreviewColorList.RegionDye or {}
        if StainLen ==  PreviewLen then
            for index, v in ipairs(StainRegionDye) do
                local PreviewColor =  PreviewRegionDye[index]
                if PreviewColor ~= nil then
                    if v.ColorID ~= PreviewColor.ColorID then
                        local Item = {}
                        Item.SectionID = v.ID
                        Item.AppID = AppID
                        Item.SectionName = _G.WardrobeMgr:GetUnlockedAppearanceRegionName(AppID, v.ID)
                        Item.ColorID = v.ColorID
                        Item.PreColorID = PreviewRegionDye[index].ColorID
                        table.insert(ItemList, Item)
                    end
                end
            end
        end
    end

    self.ColorAreaList:UpdateByValues(ItemList)
    self.IsDiff = #ItemList > 0
end

-- 更新消耗List
function WardrobePreviewColorWinVM:UpdateConsumeList(AppID)
    local ColorList = {}
    for i = 1, self.ColorAreaList:Length(), 1 do
        local ItemData = self.ColorAreaList:Get(i)
        if ItemData ~= nil then
            local ColorID = ItemData.PreColorVM.ID
            if not _G.WardrobeMgr:IsActiveColor(AppID, ColorID) then
                if not table.contain(ColorList, ColorID) then
                    table.insert(ColorList, ColorID)
                end
            end
        end
    end

    local StainListHash = {} -- 染色道具列表
    local StainListOrder = {} -- 保持顺序的列表
    for _, id in ipairs(ColorList) do
        local Cfg = DyeColorCfg:FindCfgByKey(id)
        if Cfg ~= nil then
            for _, v in ipairs(Cfg.StainAgentRes) do
                if v.ID ~= 0 then
                    if StainListHash[v.ID] == nil then
                        table.insert(StainListOrder, {ID = v.ID, Num = v.Num})
                        StainListHash[v.ID] = #StainListOrder
                    else
                        local index = StainListHash[v.ID]
                        StainListOrder[index].Num = StainListOrder[index].Num + v.Num
                    end
                end
            end
        end
    end

    local function  StainTypeConvertIndex(ItemID)
        local TypeList = WardrobeDefine.StainColorList
	    for index, v in ipairs(TypeList) do
            if v == ItemID then
                return index
            end
	    end
	    return  1
    end

    table.sort(StainListOrder, function(a, b)
        if a.ID ~= nil and b.ID ~= nil then
            local AIndex = StainTypeConvertIndex(a.ID)
            local BIndex = StainTypeConvertIndex(b.ID)
            return AIndex < BIndex
        end
        return false
    end)

    local ItemList1 = {}
    local ItemList2 = {}
    local Index = 0

    local IsEnough = true
    self.StainDataList = {}
    for _, item1 in ipairs(StainListOrder) do
        local id = item1.ID
        local num = item1.Num
        local Items = {}
        local BagNum =_G.BagMgr:GetItemNum(id)
        local ItemLacked = BagNum < num
        local ColorNum = RichTextUtil.GetText(string.format("%d", BagNum), ItemLacked and WardrobeDefine.TxtColor.WarningColor or "#D5D5D5FF")
        Items.Item = id
        Items.Num = string.format("%s/%d", ColorNum, num)
        table.insert(not (Index > 3) and ItemList1 or ItemList2, Items)
        Index = Index + 1
        table.insert(self.StainDataList, {ResID = id, Num = num})
        if ItemLacked then
            IsEnough = false
        end
    end

    self.StainList1:UpdateByValues(ItemList1)
    self.StainList2:UpdateByValues(ItemList2)
    self.IsComsume = #StainListOrder > 0
    self.IsMore4  =  #ItemList2 > 0
    self.IsLessStain = not IsEnough
end

function WardrobePreviewColorWinVM:GetStainDataList()
    return self.StainDataList
end

--要返回当前类
return WardrobePreviewColorWinVM