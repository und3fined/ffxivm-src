local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local MarketPriceItemVM = require("Game/Market/VM/MarketPriceItemVM")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local MarketPurchaseWindowItemVM = require("Game/Market/VM/MarketPurchaseWindowItemVM")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local CommonUtil = require("Utils/CommonUtil")


---@class MarketRemoveWinVM : UIViewModel
local MarketRemoveWinVM = LuaClass(UIViewModel)

---Ctor
function MarketRemoveWinVM:Ctor()
    self.ReferencePriceVMList = UIBindableList.New(MarketPriceItemVM)
    self.SellItemMV = MarketPurchaseWindowItemVM.New()

    self.ItemTypeText = nil
    self.ItemNameText = nil
    self.ItemDescriptionText = nil
    
    self.IncomeText = nil
    self.AmountText = nil
    self.UnitPriceText = nil

	self.EmptyTipsVisible = nil
    self.MarketPriceVisible = nil
	
end

function MarketRemoveWinVM:UpdateVM(Value) 
    self.EmptyTipsVisible = false
    self.MarketPriceVisible = false

    if Value.Stall == nil then
        return
    end

    local ItemResID = Value.Stall.ResID

    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end

    self.ItemTypeText = _G.MarketMgr:GetMarketItemLevelInfo(Cfg)
	self.ItemNameText = CommonUtil.GetTextFromStringWithSpecialCharacter(Cfg.ItemName) 
	self.ItemDescriptionText = _G.MarketMgr:GetMarketItemDesc(Cfg)
    self.SellItemMV:UpdateVM(ItemResID, "")

    self.IncomeText = math.floor((Value.Stall.TotalNum - Value.Stall.SoldNum) * Value.Stall.SinglePrice*(1 - Value.Stall.TaxRate)) 
    self.AmountText = Value.Stall.TotalNum - Value.Stall.SoldNum
    self.UnitPriceText = Value.Stall.SinglePrice
end

function MarketRemoveWinVM:UpdateReferencePrice(ReferencePrice)
    local PriceList = ReferencePrice.PriceList or {}

	self.ReferencePriceVMList:UpdateByValues(PriceList)
    self.EmptyTipsVisible = #PriceList == 0
    self.MarketPriceVisible = #PriceList > 0
end

--要返回当前类
return MarketRemoveWinVM