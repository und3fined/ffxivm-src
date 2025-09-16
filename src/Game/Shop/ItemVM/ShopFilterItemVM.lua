---
--- Author: Alex
--- DateTime: 2023-02-09 11:08:08
--- Description: 商店系统筛选器列表
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local LSTR = _G.LSTR

---@class ShopFilterItemVM : UIViewModel

local ShopFilterItemVM = LuaClass(UIViewModel)

---Ctor
function ShopFilterItemVM:Ctor()
    -- Main Part
    self.ParentName = ""
    self.ParentIndex = 0
    self.TabName = ""
    self.IsSelected = false
end

function ShopFilterItemVM:IsEqualVM(Value)
    return true
end


function ShopFilterItemVM:UpdateVM(Value)
    local ParentNameContent = Value.ParentName
    self.ParentName = ParentNameContent
    self.ParentIndex = Value.ParentIndex
    local TabNameContent = Value.TabName
    self.TabName = TabNameContent
    self.IsSelected = Value.IsSelected
end


return ShopFilterItemVM