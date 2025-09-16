--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-02-08 15:35:55
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-02-18 11:33:16
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishNotesBaitISlotVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class FishNotesBaitISlotVM: UIViewModel
---@field FishSlot FishNotesSlotItemView @鱼饵槽位
---@field SkillIcon string @技能图标
---@field PointIcon string @点数图标
---@field ItemID number @鱼饵ID
local FishNotesBaitISlotVM = LuaClass(UIViewModel)

function FishNotesBaitISlotVM:Ctor()
    self.UnknowIcon = ""
    self.bUnknowVisible = false
    self.FishIcon = ""
    self.bIconVisible = true
    self.ItemQualityIcon = ""
    self.bQualityVisible = true
    self.bClockVisible = false
    self.bClockActiveVisible = false
    self.bSelectXVisible = false
    self.bNumTextVisible = true
    self.NumText = ""

    self.ID = 0
    self.ItemID = 0
    self.IsBait = true --可以不用进行鱼解锁检测
end

function FishNotesBaitISlotVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

function FishNotesBaitISlotVM:UpdateVM(Value)
    self.ItemID = Value.ItemID
    local ItemData = ItemCfg:FindCfgByKey(Value.ItemID)
    if ItemData then
        self.FishIcon = UIUtil.GetIconPath(ItemData.IconID)
    end
    self.NumText = Value.Num or ""
end

return FishNotesBaitISlotVM