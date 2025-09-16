--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-10-23 16:59:51
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-12-09 14:56:43
FilePath: \Client\Source\Script\Game\CraftingLog\ItemVM\CraftingLogTextItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class CraftingSearchRescordVM : UIViewModel
---@field Name string

local CraftingLogTextItemVM = LuaClass(UIViewModel)

---Ctor
function CraftingLogTextItemVM:Ctor()
    self.TextTips = ""
    self.Category = ""
    self.CategoryItemID = ""
    self.CategoryNum = 0
    self.Craftjob = 0
end

function CraftingLogTextItemVM:IsEqualVM(Value)
    return true
end


function CraftingLogTextItemVM:UpdateVM(Value)
    self.TextTips = Value.TextTips
    self.Category = Value.Category
    self.CategoryItemID = Value.CategoryItemID
    self.CategoryNum = Value.CategoryNum
    self.Craftjob = Value.Craftjob
end

---@type 是否可以展开树形控件子节点
function CraftingLogTextItemVM:AdapterOnGetIsCanExpand()
    return true
end

--- 设置返回的索引：0
function CraftingLogTextItemVM:AdapterOnGetWidgetIndex()
    return 2
end

function CraftingLogTextItemVM:AdapterOnGetCanBeSelected()
    return false
end

--- 返回子节点列表
function CraftingLogTextItemVM:AdapterOnGetChildren()
    return {}
end

--- @type 返回种类
function CraftingLogTextItemVM:AdapterGetCategory()
    
    return self.Category

end

return CraftingLogTextItemVM