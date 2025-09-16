local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class ArmyJoinInfoActivityItemVM : UIViewModel
local ArmyJoinInfoActivityItemVM = LuaClass(UIViewModel)
---Ctor
function ArmyJoinInfoActivityItemVM:Ctor()
    self.ID = nil
    self.Icon = nil
end

function ArmyJoinInfoActivityItemVM:UpdateVM(Value)
    self.ID = Value.ID
	self.Icon = Value.Icon
end

function ArmyJoinInfoActivityItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end


--要返回当前类
return ArmyJoinInfoActivityItemVM