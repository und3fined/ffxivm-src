---
--- Author: Alex
--- DateTime: 2023-02-13 09:56:56
--- Description: 商店货币系统Item
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ShopDefine = require("Game/Shop/ShopDefine")
--local FLOG_ERROR = _G.FLOG_ERROR
--local UIBindableList = require("UI/UIBindableList")
--local LSTR = _G.LSTR

---@class ShopCostItemVM : UIViewModel
---@field bActiveByView boolean@是否由UI直接激活
---@field OnClick function@点击事件
local ShopCostItemVM = LuaClass(UIViewModel)

---Ctor
function ShopCostItemVM:Ctor()
    -- Main Part
    self.bActiveByView = false
    self.CostId = 0
    self.CostNum = 0
    self.IsItem = false
    self.IsEnough = true
    self.bShowOnTop = true
    self.TextColor = ""
    self.bClick = true
    self.OnClickShowTips = nil
    self.bShowExchange = false
    self.LinkToViewID = 0
end

function ShopCostItemVM:IsEqualVM(Value)
    return true
end


function ShopCostItemVM:UpdateVM(Value)
    local bActiveByView = Value.bActiveByView
    self.bActiveByView = bActiveByView or false
    if bActiveByView == true then
        return
    end
    self.CostId = Value.CostId
    self.CostNum = Value.CostNum
    self.IsItem = Value.IsItem
    local IsEnough = Value.IsEnough
    self.IsEnough = IsEnough
    if IsEnough then
        self.TextColor = ShopDefine.ShopTextColor.White
    else
        self.TextColor = ShopDefine.ShopTextColor.Red
    end
    if Value.bClick == false then
        self.bClick = false
    end
    self.bShowOnTop = Value.bShowOnTop
    self.OnClickShowTips = Value.OnClickShowTips
    self.bShowExchange = Value.bShowExchange
    --FLOG_ERROR("ShopCostItemVM:UpdateVM Value.bShowExchange = %s", tostring(Value.bShowExchange))
    self.LinkToViewID = Value.LinkToViewID
end


return ShopCostItemVM