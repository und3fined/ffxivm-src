--
-- Author: alex
-- Date: 2024-02-28 15:21
-- Description:足迹系统
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local FootPrintParentTypeVM = require("Game/FootPrint/ItemVM/FootPrintParentTypeVM")
local FootPrintTypeItemVM = require("Game/FootPrint/ItemVM/FootPrintTypeItemVM")
local FootPrintDefine = require("Game/FootPrint/FootPrintDefine")
local FootPrintRegionCfg = require("TableCfg/FootMarkRegionCfg")
local FootPrintItemCfg = require("TableCfg/FootMarkRecordCfg")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")
local FootPrint_Filter_Type = ProtoRes.FootMarkType
local ItemUnlockPercent = FootPrintDefine.ItemUnlockPercent
local FLOG_ERROR = _G.FLOG_ERROR

---@class FootPrintRegionVM : UIViewModel
local FootPrintRegionVM = LuaClass(UIViewModel)

---Ctor
function FootPrintRegionVM:Ctor()
    self.RegionID = 0
    self.BottleVM = nil
    self.SchedulePercent = 0
    self.bCanLight = false
    self.ScheduleText = ""
    self.CompleteScheduleText = ""
    self.ParentTypeActualScoreList = nil
    self.bLighted = false
    self.ParentTypeListItems = UIBindableList.New(FootPrintParentTypeVM)
    self.TypeItemList = UIBindableList.New(FootPrintTypeItemVM)

    self.ParentTypeToSelected = FootPrint_Filter_Type.FootMarkType_Invalide

    self.LastSelectedTypeID = 0
end

--- 刷新地图主界面数据
function FootPrintRegionVM:UpdateMainPanelData(Value, BottleVM)
    if not Value then
        return
    end
    local RegionID = Value.RegionID
    if not RegionID then
        return
    end

    self.RegionID = RegionID
    BottleVM.bShowPanelSchedule = false
    self.BottleVM = BottleVM
    local bLighted = BottleVM.bLighted
    self.bLighted = bLighted

    local RegionCfg = FootPrintRegionCfg:FindCfgByKey(RegionID)
    if not RegionCfg then
        return
    end
    local CfgScore = RegionCfg.TargetScore or 0
    local ActualScore = Value.ActualScore or 0
    local Percent = ActualScore / CfgScore
    self.SchedulePercent = Percent <= 1 and Percent or 1
    self.bCanLight = not bLighted and Percent >= 1
    self.ScheduleText = string.format("%d/%d", ActualScore, CfgScore)
    self.CompleteScheduleText = tostring(CfgScore)
    self.ParentTypeActualScoreList = Value.ParentTypeActualScoreList
    self:UpdateParentTypeList(RegionID)
end

--- 更新地图界面父类筛选列表
function FootPrintRegionVM:UpdateParentTypeList(RegionID)
    if not RegionID or type(RegionID) ~= "number" then
        return
    end

    local ParentTypeListItems = self.ParentTypeListItems
    if not ParentTypeListItems then
        return
    end
    ParentTypeListItems:Clear()
    local ListData = {}
    for index = FootPrint_Filter_Type.FootMarkType_Normal, FootPrint_Filter_Type.FootMarkType_Explore do
        local ItemData = {
            RegionID = RegionID,
            ParentType = index,
            ActualScore = 0,
            ScoreAdded = 0,
        }
        local ActualScoreList = self.ParentTypeActualScoreList
        if ActualScoreList then
            local ParentTypeScoreInfo = ActualScoreList[index]
            if ParentTypeScoreInfo then
                ItemData.ActualScore = ParentTypeScoreInfo.ActualScore or 0
                ItemData.ScoreAdded = ParentTypeScoreInfo.ScoreAdded or 0
            end
        end
        table.insert(ListData, ItemData)
    end
    ParentTypeListItems:UpdateByValues(ListData, nil)
end

function FootPrintRegionVM:SelectTheParentType(ParentType)
    --self.ParentTypeToSelected = ParentType
    
    local ParentTypeListItems = self.ParentTypeListItems
    if not ParentTypeListItems then
        return
    end

    for index = 1, ParentTypeListItems:Length() do
        local Item = ParentTypeListItems:Get(index)
        if Item then
            Item:SetTheSelectedState(Item.ParentType == ParentType)
        end
    end
end

--- 根据筛选大类枚举刷新对应足迹条目
function FootPrintRegionVM:UpdateMapItemsDetailContent(TypeItemsSevInfo)
    if not TypeItemsSevInfo then
        return
    end

    local TypeItemList = self.TypeItemList
    if not TypeItemList then
        return
    end

    TypeItemList:Clear()
    local TypeItemListData = {}
    for _, value in ipairs(TypeItemsSevInfo) do
        local TypeID = value.TypeID
        local TypeData = {
            Key = TypeID,
            TypeID = TypeID,
            IsUnLock = false,
            NumComplete = 0,
            Children = value.ItemSevInfos,
        }

        --- 判断种类条目是否解锁
        local FirstItemData = TypeData.Children[1]
        if FirstItemData then
            local ItemId = FirstItemData.ItemID
            local NumComplete = FirstItemData.NumComplete
            TypeData.NumComplete = NumComplete
            local ItemCfg = FootPrintItemCfg:FindCfgByKey(ItemId)
            if ItemCfg then
                local FootPrintNum = NumComplete
                local CompleteNeedNum = FirstItemData.TargetNum
                local CompletePercent = FootPrintNum / CompleteNeedNum
                local StringList = string.split(FirstItemData.StrKey, "C")
                local Index = tonumber(StringList[#StringList])
                if Index then
                    TypeData.IsUnLock = CompletePercent * 100 >= (ItemCfg.UnlockPercents[Index] or 0)
                end
            end
        end
        table.insert(TypeItemListData, TypeData)
    end

    local function SortTypeItemRule(A, B)
        if A.IsUnLock ~= B.IsUnLock then
            return A.IsUnLock
        else
            return A.TypeID < B.TypeID
        end
    end
    table.sort(TypeItemListData, SortTypeItemRule)
    TypeItemList:UpdateByValues(TypeItemListData, nil)
end

function FootPrintRegionVM:ResumeBottleVMScheduleVisible()
    local BottleVM = self.BottleVM
    if not BottleVM then
        return
    end
    BottleVM.bShowPanelSchedule = true
end

return FootPrintRegionVM