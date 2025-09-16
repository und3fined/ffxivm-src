local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")

local FLOG_WARNING = _G.FLOG_WARNING

---@class MarketSalesRecordItemVM : UIViewModel
local MarketSalesRecordItemVM = LuaClass(UIViewModel)

---Ctor
function MarketSalesRecordItemVM:Ctor()
    self.CommItemSlotVM = ItemVM.New()
    self.ResID = nil
    self.NameText = nil
    self.PriceText = nil
    self.ItemNum = nil
    self.RecordTime = nil
    self.PurchaserName = nil
    self.TaxRateText = nil

end

function MarketSalesRecordItemVM:UpdateVM(Value)
    local ResID = Value.ResID
    self.ResID = ResID
    local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
        FLOG_WARNING("MarketCommodityItemVM:UpdateVM can't find item cfg, ResID =%d", ResID)
        return
    end
	self.NameText = ItemCfg:GetItemName(ResID)

    local item = ItemUtil.CreateItem(ResID, 0)
    self.CommItemSlotVM:UpdateVM(item, {IsShowNum = false})

    self.PriceText = math.floor(Value.Price * Value.Num * (1- Value.TaxRate))
    self.ItemNum = Value.Num

    self.RecordTime = TimeUtil.GetTimeFormat("%Y-%m-%d %H:%M:%S", Value.Tick)

    self.BuyerID = Value.BuyerID
    self:RefreshRoleName()
    self.TaxRateText = string.format("%d%s", Value.TaxRate*100, "%")
end

function MarketSalesRecordItemVM:RefreshRoleName()
    local RoleVM, IsValid = _G.RoleInfoMgr:FindRoleVM(self.BuyerID, true)
    if IsValid then
        self.PurchaserName = RoleVM.Name
    else
        self.PurchaserName = _G.LSTR(1010014)..self.BuyerID
    end
end

function MarketSalesRecordItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.TradeID == self.TradeID
end

--要返回当前类
return MarketSalesRecordItemVM