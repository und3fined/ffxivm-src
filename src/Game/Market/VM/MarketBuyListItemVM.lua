local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

local LSTR = _G.LSTR
local ShoWMaxNum = 999
---@class MarketBuyListItemVM : UIViewModel
local MarketBuyListItemVM = LuaClass(UIViewModel)

---Ctor
function MarketBuyListItemVM:Ctor()
    self.PanelFocusVisible = nil
	self.AmountText = nil
	self.QuantitySoldText = nil
	self.ServerNameText = nil
	self.PlayerNameText = nil
end

function MarketBuyListItemVM:UpdateVM(Value)
	if nil == Value then
		return
	end
    self.Value = Value
	
    self.AmountText = Value.SinglePrice
    if Value.Num > ShoWMaxNum then
        self.QuantitySoldText = "999+"
    else
        self.QuantitySoldText = string.format("%d", Value.Num)
    end

    --for test 
    --self.QuantitySoldText = string.format("%d", Value.Index)

    local RoleIDs = {Value.SellerID}
    RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
        local RoleVM, IsValid = RoleInfoMgr:FindRoleVM(Value.SellerID, true)
        if IsValid then
            self.PlayerNameText = RoleVM.Name
            self.ServerNameText = _G.LoginMgr:GetMapleNodeName(RoleVM.WorldID)
        else
            self.PlayerNameText = LSTR(1010014)..Value.SellerID
            self.ServerNameText = LSTR(1010025)..RoleVM.WorldID
        end
    end, nil, false)


end

function MarketBuyListItemVM:UpdateSelectedStatus(SellID)
    self.PanelFocusVisible = SellID == self.Value.SellID
end


function MarketBuyListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.SellID == self.Value.SellID
end

--要返回当前类
return MarketBuyListItemVM