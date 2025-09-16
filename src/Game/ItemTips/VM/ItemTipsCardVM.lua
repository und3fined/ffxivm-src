local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local FantasyCardCfg = require("TableCfg/FantasyCardCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local LSTR = _G.LSTR
local ItemTipsCardVM = LuaClass(UIViewModel)

function ItemTipsCardVM:Ctor()
    self.IntroText = nil

    self.StarNumMax = 5
    self.StarImg1 = nil
    self.StarImg2 = nil
	self.StarImg3 = nil
	self.StarImg4 = nil
	self.StarImg5 = nil

	self.IncludeText = nil

	self.BuyPriceText = nil
	self.SellPriceText = nil
	self.BuyPriceIconVisible = nil
	self.SellPriceIconVisible = nil
end

---UpdateVM
function ItemTipsCardVM:UpdateVM(Value)
    local ItemResID = Value.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end

	self.IntroText = ItemCfg:GetItemDesc(ItemResID)

    local CardCfg = FantasyCardCfg:FindCfgByKey(ItemResID)
    if nil == CardCfg then
        return
    end
    local StarNum = self.StarNumMax
    local Star = CardCfg.Star
    for i = 1, StarNum do
        local StarName = string.format("StarImg%d", i)
        if i > Star then
            self[StarName] = false
        else
            self[StarName] = true
        end
    end

    if _G.BagMgr:IsItemUsed(Cfg) then
		self.IncludeText = LSTR(1020013)
    else
        self.IncludeText = LSTR(1020014)
	end

    self.BuyPriceText, self.BuyPriceIconVisible = ItemTipsUtil.GetItemCfgBuyPrice(Cfg)
    self.SellPriceText, self.SellPriceIconVisible  = ItemTipsUtil.GetItemCfgSellPrice(Cfg)
end

return ItemTipsCardVM