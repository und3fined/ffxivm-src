local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class BuddyDetailAttriItemVM : UIViewModel
local BuddyDetailAttriItemVM = LuaClass(UIViewModel)

---Ctor
function BuddyDetailAttriItemVM:Ctor()
	self.AttriText = nil
	self.ValueText = nil
end

function BuddyDetailAttriItemVM:UpdateVM(Value)
	self.AttriText = Value.Attri
	self.ValueText = Value.Value
end

function BuddyDetailAttriItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.Attri == self.AttriText and  Value.Value == self.ValueText
end




--要返回当前类
return BuddyDetailAttriItemVM