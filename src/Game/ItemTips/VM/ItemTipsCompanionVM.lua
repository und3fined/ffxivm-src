local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local CompanionCfg = require ("TableCfg/CompanionCfg")

local ItemTipsCompanionVM = LuaClass(UIViewModel)

function ItemTipsCompanionVM:Ctor()
    self.IntroText = nil
	self.BuyPriceText = nil
	self.SellPriceText = nil
	self.BuyPriceIconVisible = nil
	self.SellPriceIconVisible = nil
    self.OwnText = nil
end

---UpdateVM
function ItemTipsCompanionVM:UpdateVM(Value)
    local ItemResID = Value.ResID
    local ItemFindCfg = ItemCfg:FindCfgByKey(ItemResID)

    self.IntroText = ItemCfg:GetItemDesc(ItemResID)
    self.BuyPriceText, self.BuyPriceIconVisible = ItemTipsUtil.GetItemCfgBuyPrice(ItemFindCfg)
    self.SellPriceText, self.SellPriceIconVisible  = ItemTipsUtil.GetItemCfgSellPrice(ItemFindCfg)

    if _G.BagMgr:IsItemUsed(ItemFindCfg) then
		self.OwnText = _G.LSTR(1020013)
    else
        self.OwnText = _G.LSTR(1020014)
	end
end

return ItemTipsCompanionVM