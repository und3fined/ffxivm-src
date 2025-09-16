---
--- Author: Leo
--- DateTime: 2023-03-30 12:22:34
--- Description: 采集笔记物品
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local GatheringLogMgr = require("Game/GatheringLog/GatheringLogMgr")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local StringTools = _G.StringTools

local LSTR = _G.LSTR
---@class GatheringLogStuffItemVM : UIViewModel

local GatheringLogStuffItemVM = LuaClass(UIViewModel)

---Ctor
---@string ID :ID
function GatheringLogStuffItemVM:Ctor()
    -- Main Part
    self.OrderID = 0

    self.Name = ""
    self.bSelect = false
    self.Icon = ""
    self.bShowStarOne = false
    self.bShowStarTwo = false
    self.bShowStarThree = false
    self.bUseClock = false
    self.bSetClock = false
    self.bHidden = false
    self.bGot = false
    self.bSetFavor = false

    --表中数据
    self.ID = nil
    self.ItemID = nil
    self.GatheringJob = 0
    self.GatheringGradeText = ""
    self.GatheringGrade = 0
    self.bIsCollection = false
    self.MinAcquisition = 0
    self.GatheringStar = nil
    self.TimeCondition = ""
    self.bNotUseClock = false
    self.ItemQualityImg = nil
    self.GatheringLabel = ""
    self.GatherLabel = nil
    self.ChildTypeFilter = ""
    self.AppearCondition = ""
    self.bLockGray = false
    self.bLeveQuestMarked = false

    self.RedDotName = nil

    self.TextTips = ""
    self.Category = ""
    self.CategoryItemID = nil
    self.LineageVolume = nil
end

function GatheringLogStuffItemVM:UpdateVM(Value)
    if Value.TextTips ~= nil then
        self.TextTips = Value.TextTips
        self.Category = Value.Category
        self.CategoryItemID = Value.CategoryItemID
        self.LineageVolume = Value.LineageVolume
        self.GatheringJob = Value.GatheringJob
        self.ID = nil
        return
    end
    self.TextTips = nil
    self.LineageVolume = Value.LineageVolume
    --隐藏多余的控件
    self.bHidden = false
    self.bSetFavor = Value.bSetFavor ~= nil and Value.bSetFavor or false
    --用于表示在那个上方分支之下

    self.bLeveQuestMarked = Value.bLeveQuestMarked
    self.bLockGray = Value.bLockGray ~= nil and Value.bLockGray or self:SetLockState(Value)
    self.OrderID = Value.OrderID
    self.Name = ItemCfg:GetItemName(Value.ItemID)
    self.bSelect = Value.bSelect
    self.bSetClock = Value.bSetClock ~= nil and Value.bSetClock or false

    --表中数据
    self.ID = Value.ID
    self.ItemID = Value.ItemID
    self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.ItemID))
    self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(self.ItemID, ItemDefine.ItemSlotType.Item96Slot)

    self.GatheringJob = Value.GatheringJob
    self.GatheringGradeText = string.format("%s%s", Value.GatheringGrade, LSTR(70022))
    self.GatheringGrade = Value.GatheringGrade
    self.bIsCollection = Value.IsCollection
    self.bGot = Value.bGot or GatheringLogMgr.bGotGM or false
    self.AppearCondition = Value.AppearCondition

    local MinAcquisition = Value.MinAcquisition
    if MinAcquisition ~= nil then
        self.MinAcquisition = MinAcquisition
    end

    --设置控制显示星星难度的数据
    local VGatheringStar = Value.GatheringStar
    if VGatheringStar ~= nil then
        self.GatheringStar = VGatheringStar
        local GatheringStar = self.GatheringStar
        local OneStar, TwoStar, ThreeStar = 1, 2, 3
        self.bShowStarOne = GatheringStar >= OneStar
        self.bShowStarTwo = GatheringStar >= TwoStar
        self.bShowStarThree = GatheringStar >= ThreeStar
    else
        self.bShowStarOne = false
        self.bShowStarTwo = false
        self.bShowStarThree = false
        --DropDownConditions.Normal = "常规"
    end
    local DropDownConditions = GatheringLogDefine.DropDownConditions
    self.GatheringLabel = Value.GatheringLabel
    self.GatherLabel = Value.GatherLabel
    if self.GatheringLabel ~= LSTR(DropDownConditions.Normal) then
        self.ChildTypeFilter = Value.ChildTypeFilter
    end

    self.TimeCondition = StringTools.StringSplit(Value.TimeCondition, ";")  
    self.bUseClock = #self.TimeCondition > 0 and self.bGot
    local flag = _G.GatheringLogMgr.LastFilterState.HorTabsIndex == GatheringLogDefine.HorBarIndex.ClockIndex 
    _G.GatheringLogVM.bBtnSetAlarmVisible = self.bUseClock and flag    
    _G.GatheringLogVM.bToggleBtnAlarmClockVisible = self.bUseClock

    self.RedDotName = Value.RedDotName
end

function GatheringLogStuffItemVM:SetLockState(Value)
    local ProfbLock = GatheringLogMgr:GetCurProfbLock(Value.GatheringJob)
    local MajorLevel = MajorUtil.GetMajorLevelByProf(Value.GatheringJob)
    local LevelMax
    if Value.GatheringGrade <= 5 then
        LevelMax = 5
    else
        LevelMax = (Value.GatheringGrade - 1) // 5 * 5 + 5
    end
    return ProfbLock or (MajorLevel + 10) <= LevelMax
end

function GatheringLogStuffItemVM:IsEqualVM(Value)
    return true
end

--- 设置返回的索引：0
function GatheringLogStuffItemVM:AdapterOnGetWidgetIndex()
    if self.TextTips == nil then
        return 1
    else
        return 2
    end
end

function GatheringLogStuffItemVM:AdapterOnGetCanBeSelected()
    if self.TextTips == nil then
        return true
    else
        return false
    end
end

--- 返回子节点列表
function GatheringLogStuffItemVM:AdapterOnGetChildren()
    return {}
end

function GatheringLogStuffItemVM:OnValueChanged(Value, Param)
	-- 初始化Key值，整个列表要唯一不能重复，一般是ID
    if Value.TextTips == nil then
        if GatheringLogMgr.SearchState ~= 0 then
            self.Key = Value.ID
        else
            local LastFilterState = GatheringLogMgr.LastFilterState
            local HorTabsIndex = LastFilterState.HorTabsIndex or 1
            local DropDownIndex = LastFilterState.DropDownIndex or 1
            self.Key = Value.ID + HorTabsIndex * 10000 + DropDownIndex * 1000
        end
    else
        self.Key = nil
    end
end

--- @type 返回种类
function GatheringLogStuffItemVM:AdapterGetCategory()
    if self.TextTips == nil then
        local DropDownConditions = GatheringLogDefine.DropDownConditions
        local LastFilterState = GatheringLogMgr.LastFilterState
        local HorTabsIndex = LastFilterState.HorTabsIndex
        local SpecalGatherIndex = 2
        if self.GatheringLabel ~= DropDownConditions.Normal and HorTabsIndex == SpecalGatherIndex and GatheringLogMgr.SearchState == 0 then
            if self.GatherLabel and self.GatherLabel[3] then
                return self.GatherLabel[3]
            end
        end
    else
        return self.Category
    end
end

return GatheringLogStuffItemVM