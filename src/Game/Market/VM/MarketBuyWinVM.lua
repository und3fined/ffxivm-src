local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MarketBuyListItemVM = require("Game/Market/VM/MarketBuyListItemVM")
local MarketPurchaseWindowItemVM = require("Game/Market/VM/MarketPurchaseWindowItemVM")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local CommonUtil = require("Utils/CommonUtil")
local DepotVM = require("Game/Depot/DepotVM")

local ScoreMgr = _G.ScoreMgr


---@class MarketBuyWinVM : UIViewModel
local MarketBuyWinVM = LuaClass(UIViewModel)

---Ctor
function MarketBuyWinVM:Ctor()
    self.ItemTypeText = nil
	self.ItemNameText = nil
	self.ItemDescriptionText = nil
		
    self.ShopAmount = nil
	self.SalePriceText = nil
	self.SalePriceColor = nil
	self.SaleStallVMList = UIBindableList.New(MarketBuyListItemVM)
    self.SellItemMV = MarketPurchaseWindowItemVM.New()
    self.StallBrief = nil
end

function MarketBuyWinVM:SetBuyItemInfo(ResID)
    local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		return
	end

    self.ItemTypeText = _G.MarketMgr:GetMarketItemLevelInfo(Cfg)
	self.ItemNameText = CommonUtil.GetTextFromStringWithSpecialCharacter(Cfg.ItemName) 
	self.ItemDescriptionText = _G.MarketMgr:GetMarketItemDesc(Cfg)
    self.SellItemMV:UpdateVM(ResID, string.format(_G.LSTR(1010023), _G.BagMgr:GetItemNum(ResID) + DepotVM:GetDepotItemNum(ResID)))
    self.SellItemMV:SetCollectStatus()
end

function MarketBuyWinVM:SetSelectedStallBrief(StallBrief)
    self.StallBrief = StallBrief
    for i = 1, self.SaleStallVMList:Length() do
        local SaleStallVM = self.SaleStallVMList:Get(i)
        SaleStallVM:UpdateSelectedStatus(StallBrief.SellID)
    end
end

function MarketBuyWinVM:SetAmount(Amount)
    self.ShopAmount = Amount
    if self.StallBrief == nil then
        self.SalePriceText = 0
        self.SalePriceColor = "d1ba8e"
        return
    end
    
    self.SalePriceText = Amount * self.StallBrief.SinglePrice

    if self.SalePriceText > ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE) then
        self.SalePriceColor = "dc5868"
    else
        self.SalePriceColor = "d1ba8e"
    end
end

function MarketBuyWinVM:UpdateStallBriefList(StallBriefInfo)
    local Begin = StallBriefInfo.Begin > StallBriefInfo.End and StallBriefInfo.End or StallBriefInfo.Begin
    local End = StallBriefInfo.End > StallBriefInfo.Begin and StallBriefInfo.End or StallBriefInfo.Begin
    local Stalls = StallBriefInfo.Stalls or {}
    if self.StallBriefBegin == nil and self.StallBriefEnd == nil then
        self.StallBriefBegin = Begin
        self.StallBriefEnd = End
        self.SaleStallVMList:UpdateByValues(Stalls)
    else
        if Begin == self.StallBriefEnd + 1 then
            for i = 1, #Stalls do
                local Stall = Stalls[i]
                self.SaleStallVMList:RemoveAt(1)
                self.SaleStallVMList:AddByValue(Stall)
            end
            self.StallBriefBegin = self.StallBriefBegin + #Stalls
            self.StallBriefEnd = End
        elseif End == self.StallBriefBegin - 1 then
            for i = #Stalls, 1, -1 do
                local Stall = Stalls[i]
                self.SaleStallVMList:RemoveAt(self.SaleStallVMList:Length())
                self.SaleStallVMList:InsertByValue(Stall, 1)
            end
            self.StallBriefEnd = self.StallBriefEnd - #Stalls
            self.StallBriefBegin = Begin
        end
    end

end



--要返回当前类
return MarketBuyWinVM