local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class ShopDropDownListItemNewVM : UIViewModel
local ShopDropDownListItemNewVM = LuaClass(UIViewModel)

---Ctor
function ShopDropDownListItemNewVM:Ctor()
	self.DropDownListVisible1 = nil
	self.DropDownListVisible2 = nil
end

function ShopDropDownListItemNewVM:OnInit()

end

---UpdateVM
---@param List table
function ShopDropDownListItemNewVM:UpdateVM()
	self.DropDownListVisible1 = false
	self.DropDownListVisible2 = false
	FLOG_ERROR("ShopDropDownListItemNewVM TEST")
end

function ShopDropDownListItemNewVM:UpdateScreenerList()
	self.DropDownListVisible1 = false
	self.DropDownListVisible2 = false
	FLOG_ERROR("ShopDropDownListItemNewVM TEST")
end


return ShopDropDownListItemNewVM