---
--- Author: Alex
--- DateTime: 2023-02-15 17:17:17
--- Description: 商店搜索列表结构
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local ShopDefine = require("Game/Shop/ShopDefine")
--local LSTR = _G.LSTR

---@class ShopSearchItemVM : UIViewModel

local ShopSearchItemVM = LuaClass(UIViewModel)

---Ctor
function ShopSearchItemVM:Ctor()
    -- Main Part
    self.Content = ""
end

function ShopSearchItemVM:IsEqualVM(Value)
    return self.Content == Value.Content
end


function ShopSearchItemVM:UpdateVM(Value)
    self.Content = Value.Content
end


return ShopSearchItemVM