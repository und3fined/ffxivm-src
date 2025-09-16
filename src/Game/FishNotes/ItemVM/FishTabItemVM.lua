--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-08 12:15:26
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-08 14:58:57
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishTabItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FishTabItemVM: UIViewModel
---@field IoreIcon string 鱼识图标
---@field IoreNum string 鱼识数量
---@field IoreName string 鱼识名字
---@field ItemID number 物品表ID
local FishTabItemVM = LuaClass(UIViewModel)

function FishTabItemVM:Ctor()
    self.Index = 0
    self.NormalIcon = ""
    self.SelectIcon = ""
    self.ClockTabIcon = ""
    self.bSelect = false
end

function FishTabItemVM:IsEqualVM(Value)
    return self.Index == Value.Index
end

function FishTabItemVM:UpdateVM(Value)
    self.Index = Value.Index
    self.NormalIcon = Value.Normal
    self.SelectIcon = Value.Select
    self.ClockTabIcon = Value.Normal
    self.bSelect = false
end

function FishTabItemVM:SetSelect(bSelect)
    self.bSelect = bSelect
    if bSelect then
        self.ClockTabIcon = self.SelectIcon
    else
        self.ClockTabIcon = self.NormalIcon
    end
end

return FishTabItemVM