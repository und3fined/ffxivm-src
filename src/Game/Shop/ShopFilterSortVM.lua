---
--- Author: Alex
--- DateTime: 2023-02-09 11:25:57
--- Description: 商店系统筛选器
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ShopFilterItemVM = require("Game/Shop/ItemVM/ShopFilterItemVM")
--local LSTR = _G.LSTR

---@class ShopFilterSortVM : UIViewModel
---@field PageName string@筛选器分类
---@field Index number@筛选器分类索引
---@field ShopFilterListVMs UIBindableList@筛选器列表数据
local ShopFilterSortVM = LuaClass(UIViewModel)

---Ctor
function ShopFilterSortVM:Ctor()
    -- Main Part
    self.PageName = ""
    self.Index = 0
    self.ShopFilterListVMs = UIBindableList.New(ShopFilterItemVM)
end

function ShopFilterSortVM:IsEqualVM(Value)
    return self.PageName == Value.PageName
end

--- 创建筛选器列表
---@param ShopFilterItemVMs table@筛选器列表
function ShopFilterSortVM:CreateFilterList(ShopFilterItemVMs)
    if nil ~= self.ShopFilterListVMs and self.ShopFilterListVMs:Length() > 0 then
        self.ShopFilterListVMs:Clear()
    end
    for _, v in pairs(ShopFilterItemVMs) do
        local FilterItemVM = ShopFilterItemVM.New()
        FilterItemVM.ParentName = v.ParentName
        FilterItemVM.ParentIndex = v.ParentIndex
        local TabNameContent = v.TabName
        FilterItemVM.TabName = TabNameContent
        FilterItemVM.IsSelected = v.IsSelected

        self.ShopFilterListVMs:Add(FilterItemVM)
    end
end

return ShopFilterSortVM
