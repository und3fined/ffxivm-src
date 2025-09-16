local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class AttributeSummaryItemVM : UIViewModel
local AttributeSummaryItemVM = LuaClass(UIViewModel)

function AttributeSummaryItemVM:Ctor()
    self.AttrKey = nil
    self.AttrValue = nil
end

function AttributeSummaryItemVM:UpdateVM(Value)
	self.AttrKey = Value.AttrKey
	self.AttrValue = Value.AttrValue
end

return AttributeSummaryItemVM