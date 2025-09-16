local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local MarketDefine = require("Game/Market/MarketDefine")

local LSTR = _G.LSTR

local FLOG_WARNING = _G.FLOG_WARNING


---@class MarketStallItemVM : UIViewModel
local MarketStallItemVM = LuaClass(UIViewModel)

MarketStallItemVM.StallStatus = {Lock = 0, Idle = 1, Occupancy = 2}
---Ctor
function MarketStallItemVM:Ctor()
    self.CommodityPanelVisible = nil
    self.IdlePanelVisible = nil
	self.IdleVisible = nil
    self.LockVisible = nil
	self.IdleInfoText = nil

	self.CommodityQuality = nil
	self.Icon = nil
	self.SellAmountText = nil
	self.NameText = nil
	self.RetrieveVisible = nil
    self.MoneyValue = nil
    self.RelistingText = nil

	self.ExpiredTextVisible = nil

	self.TimePanelVisible = nil
	self.ShowTimeText = 0

    self.Status = nil
    self.SellID = nil
    self.StallItem = nil

    self.HasGetVisible = nil

    self.RedDotID = nil
end

function MarketStallItemVM:UpdateVM(Value)
    self.Status = Value.Status
    self.Index = Value.Index
    self.RedDotID = 0
    self.PlayUnlockAni = Value.PlayUnlockAni
    if Value.Status == MarketStallItemVM.StallStatus.Occupancy then
        self:SetStallStatusInfo(Value.StallItem)
    elseif Value.Status == MarketStallItemVM.StallStatus.Idle then
        self:SetStallIdle()
    elseif Value.Status == MarketStallItemVM.StallStatus.Lock then
        self:SetStallLock()
    end
end

function MarketStallItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Index == self.Index
end

function MarketStallItemVM:SetStallStatusInfo(OneStallItem)
    self.StallItem = OneStallItem
    if nil == self.StallItem then
        return
    end

    self.SellID = OneStallItem.SellID
    self.CommodityPanelVisible = true
    self.IdlePanelVisible = false
    self.TimePanelVisible = true
    self.ExpiredTextVisible = false
    --self.RetrieveVisible = true
    self.RelistingVisible = false


    self:SetStallCommodityInfo(OneStallItem)
end

function MarketStallItemVM:SetStallCommodityInfo(OneStallItem)
    self.SellAmountText = string.format(LSTR(1010010), OneStallItem.SoldNum, OneStallItem.TotalNum)
    local ResID = OneStallItem.ResID
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
        FLOG_WARNING("MarketCommodityItemVM:UpdateVM can't find item cfg, ResID =%d", ResID)
        return
    end
    self.Icon = Cfg.IconID
    self.NameText = ItemCfg:GetItemName(ResID)
    self.CommodityQuality = MarketDefine.StallItemColor[Cfg.ItemColor]

    self.ExpiredSold = false
    if OneStallItem.ExpireTick > TimeUtil:GetServerTime() then
        self.ShowTimeText = OneStallItem.ExpireTick *1000
    else
        self:SetStallExpiredSold()
    end

    local Income = _G.MarketMgr:GetStallIncome(self.StallItem)
    self.MoneyValue = Income
    self.HasGetVisible  = Income > 0
    self.RetrieveVisible = self.HasGetVisible

    if Income > 0 then
        self.RelistingText = ""
    else
        if OneStallItem.ExpireTick > TimeUtil:GetServerTime() then
            self.RelistingText = LSTR(1010095)
        end
    end


    if self.MoneyValue > 0 or self.ExpiredTextVisible then
       self.RedDotID = MarketDefine.MarketRedDotID.Stall
    end
end

function MarketStallItemVM:SetStallExpiredSold()
    self.TimePanelVisible = false
    self.ExpiredTextVisible = self.StallItem and (self.StallItem.TotalNum - self.StallItem.SoldNum) > 0 or true
    local Income = _G.MarketMgr:GetStallIncome(self.StallItem)
    if Income == 0 then
        self.RetrieveVisible = false
        self.ExpiredSold = true
        self.RelistingText = LSTR(1010093)
    end

end

function MarketStallItemVM:SetStallIdle()
    self.CommodityPanelVisible = false
    self.IdlePanelVisible = true
    self.IdleVisible = true
    self.LockVisible = false

    self.IdleInfoText = LSTR(1010011)
end

function MarketStallItemVM:SetStallLock()
    self.CommodityPanelVisible = false
    self.IdlePanelVisible = true
    self.IdleVisible = false
    self.LockVisible = true

    self.IdleInfoText = LSTR(1010012)
end

--要返回当前类
return MarketStallItemVM