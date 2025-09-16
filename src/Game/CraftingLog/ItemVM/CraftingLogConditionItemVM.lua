--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2023-12-08 09:26:58
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-05-28 17:09:59
FilePath: \Client\Source\Script\Game\CraftingLog\ItemVM\CraftingLogConditionItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CraftingLogConditionItemVM : UIViewModel

local CraftingLogConditionItemVM = LuaClass(UIViewModel)

---Ctor
---@field TextCondition string  @条件文本
---@field bForbiddenShow boolean @是否显示禁止图标
---@field bCheckedShow boolean @是否显示对号图标
function CraftingLogConditionItemVM:Ctor()
	self:Reset()
end

function CraftingLogConditionItemVM:Reset()
    self.TextCondition = ""
    self.bForbiddenShow = false
    self.bCheckedShow = false
end

function CraftingLogConditionItemVM:OnShutdown()
	self:Reset()
end

function CraftingLogConditionItemVM:OnShow()
end

function CraftingLogConditionItemVM:IsEqualVM()
    return true
end

function CraftingLogConditionItemVM:UpdateVM(Data)
    self.TextCondition = Data.TextCondition
    self.bForbiddenShow = Data.bForbidden
    self.bCheckedShow = Data.bChecked
end

return CraftingLogConditionItemVM