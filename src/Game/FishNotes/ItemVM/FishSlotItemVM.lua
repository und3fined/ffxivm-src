---
---@author Lucas
---DateTime: 2023-03-28 10:24:30
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local FishNotesMgr = require("Game/FishNotes/FishNotesMgr")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local ItemVM = require("Game/Item/ItemVM")

---@class FishSlotItemVM: UIViewModel
---@field FishIcon string 鱼图标
---@field UnknowIcon string 未知鱼类图标
---@field bIconVisible boolean 是否显示图标
---@field bQualityVisible boolean 是否显示品质图标
---@field bClockVisible boolean 是否显示闹钟图标
---@field bUnknowVisible boolean 是否显示未知鱼类
---@field bSelectXVisible boolean 是否显示叉状选中图标
---@field bSelectEnabled boolean 普通选中框是否启用
---@field Type number 所属Type:{1=钓场中鱼类列表, 2=闹钟列表, 3=鱼饵列表 }
---
---@field ItemID number 鱼类ID
local FishSlotItemVM = LuaClass(UIViewModel)

function FishSlotItemVM:Ctor()
    self.UnknowIcon = ""
    self.bUnknowVisible = false
    self.FishIcon = ""
    self.bIconVisible = false
    self.ItemQualityIcon = ""
    self.bQualityVisible = false
    self.bClockVisible = false
    self.bClockActiveVisible = false
    self.bSelectXVisible = false
    self.bNumTextVisible = false
    self.NumText = ""

    self.ID = 0
    self.ItemID = 0
    self.LocationID = 0
    self.IsLocationFish = false
end

function FishSlotItemVM:IsEqualVM(Value)
    return self.ID == Value.ID and self.LocationID == Value.LocationID
end

---@type 设置图标状态
---@param Data table | string 鱼类信息
function FishSlotItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.LocationID = Value.LocationID
    self.IsLocationFish = Value.IsLocationFish or false

    self.bClockActiveVisible = Value.bClockActiveVisible
    self.bClockVisible = Value.bClockVisible

    self.bSelectXVisible = false
    if Value.bCommonSelectShow ~= nil then
        self.bSelectEnabled = Value.bCommonSelectShow
    else
        self.bSelectEnabled = true
    end

    local bLockState = FishNotesMgr:CheckFishUnlockInFround(Value.ID, Value.LocationID)
    self.bIconVisible = bLockState
    self.bQualityVisible = bLockState
    self.bUnknowVisible = not bLockState

    local FishData = FishNotesMgr:GetFishCfg(Value.ID)
    if FishData == nil then
        return
    end
    if FishData.CanPrint and FishData.CanPrint ~= 0 then
        self.UnknowIcon = FishNotesDefine.FishSlotCanPink
    else
        self.UnknowIcon = FishNotesDefine.FishSlotNotCanPink
    end

    self.ItemID = FishData.ItemID
    local ItemData = ItemCfg:FindCfgByKey(FishData.ItemID)
    if ItemData then
        self.FishIcon = UIUtil.GetIconPath(ItemData.IconID)
        self.IsHQ = (1 == ItemData.IsHQ)
        if self.IsHQ then
            self.ItemQualityIcon = ItemVM.ItemHQColorType[ItemData.ItemColor]
        else
            self.ItemQualityIcon = ItemVM.ItemColorType[ItemData.ItemColor]
        end
    end
end

---@type 更新图标显示状态
function FishSlotItemVM:UpdateIconState(Flag)
    self.FishIcon = Flag
end

---@type 更新闹钟显示状态
function FishSlotItemVM:UpdateClockState(Flag)
    --闹钟激活情况下才会执行到这 (钓场鱼列表更新，其他默认false)
    if self.IsLocationFish == true then
        if self.bClockActiveVisible == true then
            self.bClockVisible = false
        else
            self.bClockVisible = Flag
        end
    end
end

function FishSlotItemVM:RefreshWindowState()
    if self.IsLocationFish == true then
        local bClockActiveVisible = FishNotesMgr:GetIsFishInWindowInLocation(self.LocationID, self.ID)
        self.bClockActiveVisible = bClockActiveVisible
        self.bClockVisible = self.bClockActiveVisible == true and false or self.bClockVisible
    end
end

---@type 更新未知鱼类显示状态
function FishSlotItemVM:UpdateUnKnowState(Flag)
    self.bUnknowVisible = Flag
    self.bIconVisible = not Flag
    self.bQualityVisible = not Flag
end

---@type 更新x选中状态
function FishSlotItemVM:UpdateSelectXState(Flag)
    self.bSelectXVisible = Flag
end

function FishSlotItemVM:GetIsUnkonw()
    return self.bUnknowVisible
end

return FishSlotItemVM