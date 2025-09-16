local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class ShopInletListItemNewVM : UIViewModel
local ShopInletListItemNewVM = LuaClass(UIViewModel)

---Ctor
function ShopInletListItemNewVM:Ctor()
	self.Name = nil
	self.Icon = nil
	self.ShopItemData = nil
	self.ShopId = nil
end

function ShopInletListItemNewVM:OnInit()

end

---UpdateVM
---@param List table
function ShopInletListItemNewVM:UpdateVM(List)
	--FLOG_ERROR("Test Item VM = %s",table_to_string(List))
	self.Name = List.Name
	self.Icon = List.Icon
	self.ShopId = List.ID
end

function ShopInletListItemNewVM:IsEqualVM(Value)
    --return nil ~= Value and Value.ID == self.ShopItemData.ID
end


return ShopInletListItemNewVM