local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local ItemTipsCollectionVM = LuaClass(UIViewModel)

function ItemTipsCollectionVM:Ctor()
    self.CollectionValueText = nil
	self.IntroText = nil

	self.BuyPriceText = nil
	self.SellPriceText = nil
	self.BuyPriceIconVisible = nil
	self.SellPriceIconVisible = nil

	self.MakerNameText = nil
	self.MakerNameVisible = nil
end

---UpdateVM
function ItemTipsCollectionVM:UpdateVM(Value)
    local ItemResID = Value.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end

    local Item = Value
	if Item and Item.Attr and Item.Attr.Collection then
		local CollectionValue  = Item.Attr.Collection.CollectionValue or 0
        self.CollectionValueText = string.format("%d", CollectionValue)
	end


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

return ItemTipsCollectionVM