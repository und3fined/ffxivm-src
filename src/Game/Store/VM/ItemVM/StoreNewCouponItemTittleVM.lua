
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class StoreNewCouponItemTittleVM : UIViewModel
local StoreNewCouponItemTittleVM = LuaClass(UIViewModel)

function StoreNewCouponItemTittleVM:Ctor()
	self.TittleText = ""
end

function StoreNewCouponItemTittleVM:UpdateVM(Value)
	self.TittleText = Value.TittleText
end

function StoreNewCouponItemTittleVM:AdapterOnGetWidgetIndex()
	return 0
end

return StoreNewCouponItemTittleVM