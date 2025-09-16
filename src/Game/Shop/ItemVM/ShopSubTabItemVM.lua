---
--- Author: Alex
--- DateTime: 2023-02-07 14:22:44
--- Description: 商店系统子页签
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local LSTR = _G.LSTR
---@class ShopSubTabItemVM : UIViewModel
---@field TabName string @商店页签名称

local ShopSubTabItemVM = LuaClass(UIViewModel)

---Ctor
function ShopSubTabItemVM:Ctor()
    -- Main Part
    self.ParentName = ""
    self.TabName = ""
    self.IsSelected = false
    self.NameColorText = ""
end

function ShopSubTabItemVM:IsEqualVM(Value)
    return true
end

function ShopSubTabItemVM:UpdateVM(Value)
    local ParentNameContent = Value.ParentName
    self.ParentName = ParentNameContent
    local TabNameContent = Value.TabName
    self.TabName = TabNameContent
    self.IsSelected = Value.IsSelected
    self:UpdateTabColor()
end

function ShopSubTabItemVM:UpdateTabColor()
    self.NameColorText = self.IsSelected and "ffffffff" or "737373ff"
end


--- 设置返回的索引：0
function ShopSubTabItemVM:AdapterOnGetWidgetIndex()
    return 1
end

function ShopSubTabItemVM:AdapterOnGetCanBeSelected()
    return true
end

return ShopSubTabItemVM
