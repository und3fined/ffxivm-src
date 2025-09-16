---
--- Author: Alex
--- DateTime: 2023-02-13 11:05:41
--- Description: 商店系统货币tips界面数据结构
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local UIBindableList = require("UI/UIBindableList")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsVM = require("Game/Item/ItemTipsVM")
--local LSTR = _G.LSTR
---@class ShopCurrencyTipsVM : UIViewModel

local ShopCurrencyTipsVM = LuaClass(UIViewModel)

---Ctor
function ShopCurrencyTipsVM:Ctor()
    -- Main Part
    self.CurrencyIsItem = false
    self.CurrencyIdShow = 0
    self.ItemTipsVM = ItemTipsVM.New()
end

function ShopCurrencyTipsVM:IsEqualVM(Value)
    return self.CurrencyIsItem == Value.CurrencyIsItem and self.CurrencyIdShow == Value.CurrencyIdShow
end

function ShopCurrencyTipsVM:UpdateShopCurrencyTipsVM(Value)
    self.CurrencyIsItem = Value.CurrencyIsItem
    self.CurrencyIdShow = Value.CurrencyIdShow
    local TmpCommonItem = ItemUtil.CreateItem(self.CurrencyIdShow, 0)
    self.ItemTipsVM:UpdateVM(TmpCommonItem)
end

return ShopCurrencyTipsVM
