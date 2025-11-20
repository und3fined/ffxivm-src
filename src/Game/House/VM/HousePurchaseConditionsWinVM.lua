local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local HouseLocalDef = require("Game/House/HouseLocalDef")

---@class HousePurchaseConditionsWinVM : UIViewModel
local HousePurchaseConditionsWinVM = LuaClass(UIViewModel)

---Ctor
function HousePurchaseConditionsWinVM:Ctor()
    self.BuyConditions = {}
    self.TextSubTitle = ""
end

function HousePurchaseConditionsWinVM:SetItemSelected(IsSelected)
    self.IsSelect = IsSelected
end

function HousePurchaseConditionsWinVM:IsEqualVM(Value)
    return nil ~= Value and Value.Index == self.Index
end


function HousePurchaseConditionsWinVM:UpdateVM(Value, Param)

end

function HousePurchaseConditionsWinVM:SetBuyConditons(BelongType)
    if BelongType == nil then
        BelongType = _G.HouseLandMianPanelVM.CurBuyConditionsBelongType
    end
    self.BuyConditions = _G.HouseLandMianPanelVM:GetBuyConditionByBelongType(BelongType) or {}
    local TabInfo = HouseLocalDef.BuyConditionTabs[BelongType]
    if TabInfo ~= nil then
        self.TextSubTitle = TabInfo.Name .. HouseLocalDef.LocalTxtStr.HousePurchaseConditionTitle
    end
end

return HousePurchaseConditionsWinVM
