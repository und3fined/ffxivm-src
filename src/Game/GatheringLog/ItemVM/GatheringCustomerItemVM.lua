---
--- Author: Leo
--- DateTime: 2023-03-30 11:36:34
--- Description: 采集笔记
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LSTR = _G.LSTR
---@class GatheringCustomerItemVM : UIViewModel
---@field TabName string

local GatheringCustomerItemVM = LuaClass(UIViewModel)

function GatheringCustomerItemVM:Ctor()
    -- Main Part
    self.ItemCategoryName = ""
    self.TypeTabName = ""
    self.GatheringLabel = 0
end

function GatheringCustomerItemVM:IsEqualVM(Value)
    return true
end

function GatheringCustomerItemVM:UpdateVM(Value)
    self.ItemCategoryName = Value.ChildTypeFilter

    local ItemCategoryName = self.ItemCategoryName
    if ItemCategoryName ~= nil then
        self.TypeTabName = ItemCategoryName
    end
end

---@type 是否可以展开树形控件子节点
function GatheringCustomerItemVM:AdapterOnGetIsCanExpand()
    return true
end

---@type 设置返回的索引：0
function GatheringCustomerItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function GatheringCustomerItemVM:AdapterOnGetCanBeSelected()
    return false
end

---@type 返回子节点列表
function GatheringCustomerItemVM:AdapterOnGetChildren()
    return self.MemList:GetItems()
end

function GatheringCustomerItemVM:AdapterSetCategory(ChildTypeFilter)
	self:UpdateVM({ChildTypeFilter = ChildTypeFilter})
end

return GatheringCustomerItemVM