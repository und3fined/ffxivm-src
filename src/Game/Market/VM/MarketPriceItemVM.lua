local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ShoWMaxNum = 999
---@class MarketPriceItemVM : UIViewModel
local MarketPriceItemVM = LuaClass(UIViewModel)

---Ctor
function MarketPriceItemVM:Ctor()
    self.SellPriceText = nil
    self.SellNumText = nil
    self.Price = nil
end

function MarketPriceItemVM:UpdateVM(Value)
	if nil == Value then
		return
	end
    self.Price = Value.Price
    self.SellPriceText = Value.Price or 0
	
    if Value.SellNum > ShoWMaxNum then
        self.SellNumText = "999+"
    else
        self.SellNumText = string.format("%d", Value.SellNum)
    end
end


function MarketPriceItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Price == self.Price
end

--要返回当前类
return MarketPriceItemVM