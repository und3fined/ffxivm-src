local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")

local FLOG_WARNING = _G.FLOG_WARNING

---@class MarketRecordItemVM : UIViewModel
local MarketRecordItemVM = LuaClass(UIViewModel)

---Ctor
function MarketRecordItemVM:Ctor()
    self.CommItemSlotVM = ItemVM.New()
    self.ResID = nil
    self.NameText = nil
    self.PriceText = nil
    self.ItemNum = nil
    self.RecordTime = nil

end

function MarketRecordItemVM:UpdateVM(Value)
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

    self.PriceText = Value.Price
    self.ItemNum = Value.Num

    self.RecordTime = TimeUtil.GetTimeFormat("%Y-%m-%d %H:%M:%S", Value.Tick)
end

function MarketRecordItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.TradeID == self.TradeID
end

--要返回当前类
return MarketRecordItemVM