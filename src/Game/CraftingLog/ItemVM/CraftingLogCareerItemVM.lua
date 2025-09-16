--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-01-08 16:25:41
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-11-21 14:35:17
FilePath: \Client\Source\Script\Game\CraftingLog\ItemVM\CraftingLogCareerItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class CraftingLogCareerItemVM : UIViewModel
---@field TabName string

local CraftingLogCareerItemVM = LuaClass(UIViewModel)

---Ctor
---@field TypeTabName string @分类名称
function CraftingLogCareerItemVM:Ctor()
	self:Reset()
end

function CraftingLogCareerItemVM:Reset()
    self.TypeTabName = ""
end

function CraftingLogCareerItemVM:OnShutdown()
	self:Reset()
end

function CraftingLogCareerItemVM:IsEqualVM()
    return true
end

function CraftingLogCareerItemVM:UpdateVM(Value)
    self.TypeTabName = Value.ItemCategoryName
end

function CraftingLogCareerItemVM:AdapterOnGetIsCanExpand()
    return true
end

--- 设置返回的索引：0
function CraftingLogCareerItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function CraftingLogCareerItemVM:AdapterOnGetCanBeSelected()
    return false
end

--- 返回子节点列表
function CraftingLogCareerItemVM:AdapterOnGetChildren()
    return self.MemList:GetItems()
end

function CraftingLogCareerItemVM:AdapterSetCategory(ItemCategory)
    self:UpdateVM({ItemCategoryName = ItemCategory})
end

return CraftingLogCareerItemVM
