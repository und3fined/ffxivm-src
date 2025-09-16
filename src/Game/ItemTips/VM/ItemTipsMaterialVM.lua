local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local ItemTipsMaterialVM = LuaClass(UIViewModel)

function ItemTipsMaterialVM:Ctor()
    self.IntroText = nil

    self.MakerNameText = nil
	self.BuyPriceText = nil
	self.SellPriceText = nil

    self.MakerNameText = nil
	self.MakerNameVisible = nil
    self.ResID = 0
end

---UpdateVM
function ItemTipsMaterialVM:UpdateVM(Value)
    local ItemResID = Value.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end
    self.ResID = Value.ResID
    self.IntroText = ItemCfg:GetItemDesc(ItemResID)
    self.BuyPriceText, self.BuyPriceIconVisible = ItemTipsUtil.GetItemCfgBuyPrice(Cfg)
    self.SellPriceText, self.SellPriceIconVisible  = ItemTipsUtil.GetItemCfgSellPrice(Cfg)

    if Value.Maker == nil or Value.Maker.Name == nil then
	    self.MakerNameVisible = false
    else 
        self.MakerNameText = Value.Maker.Name
	    self.MakerNameVisible = true
    end
end

return ItemTipsMaterialVM