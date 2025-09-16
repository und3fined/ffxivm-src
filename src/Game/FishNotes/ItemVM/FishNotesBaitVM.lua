--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-12-17 10:48:29
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-15 14:58:16
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishNotesBaitVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local FishSlotItemVM = require("Game/FishNotes/ItemVM/FishSlotItemVM")

---@class FishNotesBaitVM: UIViewModel
---@field FishSlot FishNotesSlotItemView @鱼饵槽位
---@field SkillIcon string @技能图标
---@field PointIcon string @点数图标
---@field ItemID number @鱼饵ID
local FishNotesBaitVM = LuaClass(UIViewModel)

function FishNotesBaitVM:Ctor()
    self.FishSlot = FishSlotItemVM.New()
end

function FishNotesBaitVM:IsEqualVM(Value)
    return Value ~= nil
end

function FishNotesBaitVM:UpdateVM(Value)
    self.FishSlot:UpdateVM(Value)
    self.PointIcon = FishNotesDefine.FishBaitPointIcon[Value.RodType]
    self.SkillIcon = FishNotesDefine.FishBaitSkillIcon[Value.SpecialLift]
end

return FishNotesBaitVM