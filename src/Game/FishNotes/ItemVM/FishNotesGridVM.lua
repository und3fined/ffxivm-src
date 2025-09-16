--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-22 16:07:49
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-22 17:07:25
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishNotesGridVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")

local ItemCfg = require("TableCfg/ItemCfg")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")

---@class FishNotesGridVM: UIViewModel
---@field Icon string 鱼图标
---@field ItemID number 鱼类ID
local FishNotesGridVM = LuaClass(UIViewModel)

function FishNotesGridVM:Ctor()
    self.Icon = ""
    self.IsSelect = false
    self.NumVisible = false
    self.ItemID = 0
    self.ItemData = nil
end

function FishNotesGridVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

---@type 设置图标状态
---@param Data table | string 鱼类信息
function FishNotesGridVM:UpdateVM(Value)
    self.ItemID = Value.ItemID
    self.ID = Value.ID
    self.CanPrint = Value.CanPrint
    self.bUnLockState = _G.FishNotesMgr:CheckFishbUnLock(Value.ID)

    local ItemData = ItemCfg:FindCfgByKey(Value.ItemID)
    if ItemData then
        self.ItemDataIconID = ItemData.IconID
        self.ItemData = ItemData
        self:UpdateUnKnowState(self.bUnLockState)
    end
    self.IsSelect = false

    if Value.bCommonSelectShow ~= nil then
        self.bSelectEnabled = Value.bCommonSelectShow
    else
        self.bSelectEnabled = true
    end
end

---@type 更新图标显示状态
function FishNotesGridVM:UpdateIconState(Flag)
    self.Icon = Flag
end

---@type 更新未知鱼类显示状态
function FishNotesGridVM:UpdateUnKnowState(bUnLockState)
    if bUnLockState then
        self.Icon = UIUtil.GetIconPath(self.ItemDataIconID)
    else
        if self.CanPrint and self.CanPrint ~= 0 then
            self.Icon = FishNotesDefine.FishSlotCanPink
        else
            self.Icon = FishNotesDefine.FishSlotNotCanPink
        end
    end
end

---@type 更新x选中状态
function FishNotesGridVM:UpdateSelectXState(Flag)
    self.IsSelect = Flag
end

function FishNotesGridVM:GetIsUnkonw()
    return self.bUnknowVisible
end

return FishNotesGridVM