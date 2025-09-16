---
--- Author: AlexChen
--- DateTime: 2025-03-11 10:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local UIBindableList = require("UI/UIBindableList")
local GoldSauserMainPanelAwardTabItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelAwardTabItemVM")
local GoldSauserMainPanelAwardThingItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelAwardThingItemVM")
local GoldSauserMainPanelAwardGetWayItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelAwardGetWayItemVM")
local GoldSaucerAwardTypeCfg = require("TableCfg/GoldSaucerAwardTypeCfg")
local GoldSaucerAwardShowCfg = require("TableCfg/GoldSaucerAwardShowCfg")
local GoldSauserAwardBelongType = ProtoRes.GoldSauserAwardBelongType
local GoldSauserAwardSourceType = ProtoRes.GoldSauserAwardSourceType
--local RichTextUtil = require("Utils/RichTextUtil")
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR


---@class GoldSauserMainPanelAwardWinVM : UIViewModel

local GoldSauserMainPanelAwardWinVM = LuaClass(UIViewModel)

---Ctor
function GoldSauserMainPanelAwardWinVM:Ctor()
    self.Title = "" -- 面板标题
    self.TabItemVMs = UIBindableList.New(GoldSauserMainPanelAwardTabItemVM)
    self.TabTitle = "" -- 导航页签标题

    self.AwardType = nil
    self.BelongType = nil -- 当前选中分类
    self.bShowHaveGot = false -- 是否仅显示已拥有

    self.ContentItemVMs = UIBindableList.New(GoldSauserMainPanelAwardThingItemVM)
    self.bShowEmptyView = false

    -- 右侧详情栏
    --- ItemSlot Use
    self.SelectedItemID = nil
    self.ItemQualityIcon = nil
    self.IsQualityVisible = false
    self.Icon = nil
    self.NumVisible = false -- default hide
    self.ItemLevelVisible = false -- default hide
    self.IconChooseVisible = false -- default hide
    self.IconReceivedVisible = false -- default hide
    self.IsMask = false -- default hide
    self.BtnCheckVisible = false -- default hide 
    self.DetailPanelItemName = nil
    self.bShowPreviewBtn = false
    self.DetailPanelDesc = nil
    self.bIconHaveShow = false
    self.CondText = nil -- 进度条件文本
    self.bShowChildCondList = false
    self.BtnGotoName = nil
    self.GetWayVMs = UIBindableList.New(GoldSauserMainPanelAwardGetWayItemVM)
end

--- 设定主界面标题
function GoldSauserMainPanelAwardWinVM:SetTheMainPanelTitle(Title)
    self.Title = Title
end

--- 创建导航页签
function GoldSauserMainPanelAwardWinVM:CreateTabItemList(CfgList)
    local TabItemVMs = self.TabItemVMs
    if not TabItemVMs then
        return
    end
    TabItemVMs:Clear()
    if not CfgList or not next(CfgList) then
        return
    end
    for _, Cfg in ipairs(CfgList) do
        local ItemValue = {
            AwardType = Cfg.AwardType,
            bChecked = false,
        }
        TabItemVMs:AddByValue(ItemValue)
    end
end

--- 修改页签标题
function GoldSauserMainPanelAwardWinVM:ChangeTabTitle(AwardType)
    local Cfg = GoldSaucerAwardTypeCfg:FindCfgByKey(AwardType)
    if not Cfg then
        return
    end
    self.TabTitle = Cfg.TypeTitle or ""
    self.AwardType = AwardType
end

function GoldSauserMainPanelAwardWinVM.ContentSortPredicate(A, B)
    if A.IconReceivedVisible ~= B.IconReceivedVisible then
        return not A.IconReceivedVisible
    else
        if A.bMarked ~= B.bMarked then
            return A.bMarked
        else
            return A.ID < B.ID
        end
    end
end

--- 根据页面导航选项刷新主列表奖励的显示
function GoldSauserMainPanelAwardWinVM:UpdateTabMainContentByTab(ContentDatas)
    -- 切换导航页签重置状态
    self.BelongType = GoldSauserAwardBelongType.AwardBelongTypeAll
    self.bShowHaveGot = false
    local ContentVMs = self.ContentItemVMs
    if not ContentVMs then
        return
    end
    self.bShowEmptyView = not ContentDatas or not next(ContentDatas)
    ContentVMs:Clear()
    ContentVMs:UpdateByValues(ContentDatas, self.ContentSortPredicate)
end

--- 更新是否已拥有内容
function GoldSauserMainPanelAwardWinVM:ChangeShowHaveState(bChecked, ContentDatas)
    self.bShowHaveGot = bChecked
    self:UpdatePartContent(ContentDatas)    
end

--- 更新分类选中内容
function GoldSauserMainPanelAwardWinVM:ChangeSelectBelongType(BelongType, ContentDatas)
    self.BelongType = BelongType
    self:UpdatePartContent(ContentDatas)    
end

function GoldSauserMainPanelAwardWinVM:UpdatePartContent(ContentDatas)
    local ContentVMs = self.ContentItemVMs
    if not ContentVMs then
        return
    end
    ContentVMs:Clear()
    if not ContentDatas or not next(ContentDatas) then
        return
    end
    local BelongType = self.BelongType
    local bShowHaveGot = self.bShowHaveGot

    local function IsTheVMInBelongType(Data, BelongType)
        if BelongType == GoldSauserAwardBelongType.AwardBelongTypeAll then
            return true
        end
        local ItemCfg = GoldSaucerAwardShowCfg:FindCfgByKey(Data.ID)
        if not ItemCfg then
            return
        end
        local CfgType = ItemCfg.BelongType
        return CfgType == BelongType
    end

    local function IsMatchHaveGotCond(Data, bShowHaveGot)
        if not bShowHaveGot then
            return true
        end
        return Data.IconReceivedVisible == bShowHaveGot
    end
 
    local UpdateDatas = {}
    for _, Data in ipairs(ContentDatas) do
        if IsMatchHaveGotCond(Data, bShowHaveGot) and IsTheVMInBelongType(Data, BelongType) then
            table.insert(UpdateDatas, Data)
        end
    end
    ContentVMs:UpdateByValues(UpdateDatas, self.ContentSortPredicate)
    self.bShowEmptyView = ContentVMs:Length() <= 0
end

--- 选中对应奖励Item
function GoldSauserMainPanelAwardWinVM:SelectTheContentItem(ItemVM, ExtraParams)
    local ID = ItemVM.ID
    local ItemCfg = GoldSaucerAwardShowCfg:FindCfgByKey(ID)
    if not ItemCfg then
        FLOG_ERROR("GoldSauserMainPanelAwardWinVM:SelectTheContentItem ItemVM is not In Config")
        return
    end
    self.SelectedItemID = ID
    self.ItemQualityIcon = ItemVM.ItemQualityIcon
    self.IsQualityVisible = ItemVM.IsQualityVisible
    self.Icon = ItemVM.Icon
    self.DetailPanelItemName = ItemVM.Name

    self.BtnCheckVisible = ItemCfg.PreviewEnable or 0 > 0
    
    self.DetailPanelDesc = ExtraParams.DetailPanelDesc
    local IconReceivedVisible = ItemVM.IconReceivedVisible
    self.bIconHaveShow = IconReceivedVisible
    if IconReceivedVisible then
        self.CondText = LSTR(350087)
    else
        self.CondText = ExtraParams.CondText
    end

    local AwardType = ItemCfg.AwardType
    local bShowGetWayList = AwardType == GoldSauserAwardSourceType.AwardSourceTypeAchievement
    self.bShowChildCondList = bShowGetWayList
    local GetWayVMs = self.GetWayVMs
    if GetWayVMs then
        GetWayVMs:Clear()
        if bShowGetWayList then
            local GetWayDatas = ExtraParams.GetWayDatas
            GetWayVMs:UpdateByValues(GetWayDatas, function(A, B)
                if A.bGot ~= B.bGot then
                    return not A.bGot
                else
                    return A.AchievementID < B.AchievementID
                end
            end)
        end
    end

    if AwardType == GoldSauserAwardSourceType.AwardSourceTypeAchievement then
        self.BtnGotoName = LSTR(350092)
    elseif AwardType == GoldSauserAwardSourceType.AwardSourceTypeShop then
        self.BtnGotoName = LSTR(350093)
    end
end

function GoldSauserMainPanelAwardWinVM:ChangeContentItemMarkedState()
    local SelectedItemID = self.SelectedItemID
    local ItemVM = self.ContentItemVMs:Find(function(Element)
        return Element.ID == SelectedItemID
    end)
    if ItemVM then
        local MarkedState = ItemVM.bMarked
        ItemVM.bMarked = not MarkedState
    end
end


return GoldSauserMainPanelAwardWinVM
