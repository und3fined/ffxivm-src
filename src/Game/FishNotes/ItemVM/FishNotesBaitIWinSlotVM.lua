--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-06-10 11:57:53
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-06-10 11:58:45
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishNotesBaitIWinSlotVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class FishNotesBaitIWinSlotVM: UIViewModel
---@field FishSlot FishNotesSlotItemView @鱼饵槽位
---@field SkillIcon string @技能图标
---@field PointIcon string @点数图标
---@field ItemID number @鱼饵ID
local FishNotesBaitIWinSlotVM = LuaClass(UIViewModel)

function FishNotesBaitIWinSlotVM:Ctor()
    self.ItemQualityIcon = ""
    self.IsQualityVisible = true
    self.Icon = ""
    self.Num = ""
    self.NumVisible = true
    self.IsValid = true
    self.IsMask = false
    self.IsSelect = false
    self.ItemLevelVisible = false
    self.IconChooseVisible = false
    self.IconReceivedVisible = false

    self.ID = 0
    self.ItemID = 0
end

function FishNotesBaitIWinSlotVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

function FishNotesBaitIWinSlotVM:UpdateVM(Value)
    self.IsValid = Value.ItemID ~= nil and Value.ItemID ~= 0
    self.ItemID = Value.ItemID
    local ItemData = ItemCfg:FindCfgByKey(Value.ItemID)
    if ItemData then
        self.Icon = UIUtil.GetIconPath(ItemData.IconID)
    end
    self.Num = Value.Num or ""
    self.IsMask = Value.Num == 0
end

return FishNotesBaitIWinSlotVM