local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class OpsCeremonyPartiesItemVM : UIViewModel
local OpsCeremonyPartiesItemVM = LuaClass(UIViewModel)
---Ctor
function OpsCeremonyPartiesItemVM:Ctor()
    self.TitleText = nil
    self.DescribeText = nil
    self.Icon = nil
end

function OpsCeremonyPartiesItemVM:IsEqualVM(Value)
	return nil ~= Value and self.Icon == Value.Icon
end

function OpsCeremonyPartiesItemVM:UpdateVM(Value, Params)
    self.TitleText = Value.TitleText
    self.DescribeText = Value.DescribeText
    self.Icon = Value.Icon
end

return OpsCeremonyPartiesItemVM