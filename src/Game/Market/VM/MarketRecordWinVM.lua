local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MarketRecordItemVM = require("Game/Market/VM/MarketRecordItemVM")
local MarketSalesRecordItemVM = require("Game/Market/VM/MarketSalesRecordItemVM")
local ProtoCS = require("Protocol/ProtoCS")

---@class MarketRecordWinVM : UIViewModel
local MarketRecordWinVM = LuaClass(UIViewModel)

---Ctor
function MarketRecordWinVM:Ctor()
    self.BuyRecordItemVMList = UIBindableList.New(MarketRecordItemVM)
    self.SellRecordItemVMList = UIBindableList.New(MarketSalesRecordItemVM)
    self.PurchaseRecordVisible = nil
	self.SalesRecordVisible = nil
    self.CurType = nil
end

function MarketRecordWinVM:SetType(Type)
    self.CurType = Type
    self.PurchaseRecordVisible = Type == ProtoCS.MarketRecordType.MarketRecordType_Buy
    self.SalesRecordVisible = Type == ProtoCS.MarketRecordType.MarketRecordType_Sell
end

function MarketRecordWinVM:UpdateListInfo(RecordInfo)
    local RecordList = RecordInfo.RecordList or {}

    if self.CurType == ProtoCS.MarketRecordType.MarketRecordType_Buy then
        self.BuyRecordItemVMList:UpdateByValues(RecordList)
    elseif self.CurType == ProtoCS.MarketRecordType.MarketRecordType_Sell then
        self.SellRecordItemVMList:UpdateByValues(RecordList)

        local RoleIDs = {}
        for _, Record in ipairs(RecordList) do
            table.insert(RoleIDs, Record.BuyerID)
        end

        _G.RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
            for i = 1, self.SellRecordItemVMList:Length() do
                local SellRecordVM = self.SellRecordItemVMList:Get(i)
                SellRecordVM:RefreshRoleName()	
            end
        end, nil, false)
    end

end
--要返回当前类
return MarketRecordWinVM