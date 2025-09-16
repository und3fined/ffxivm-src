---
--- Author: Alex
--- DateTime: 2023-02-21 18:26:06
--- Description: 替换这里的描述
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local ShopDefine = require("Game/Shop/ShopDefine")
--local LSTR = _G.LSTR

---@class ShopSaleTagItemVM : UIViewModel

local ShopSaleTagItemVM = LuaClass(UIViewModel)

---Ctor
function ShopSaleTagItemVM:Ctor()
    -- Main Part
    self.Content = ""
end

function ShopSaleTagItemVM:IsEqualVM(Value)
    return true
end


function ShopSaleTagItemVM:UpdateVM(Value)
    self.Content = Value.Content
end


return ShopSaleTagItemVM