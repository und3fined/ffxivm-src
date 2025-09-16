local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class ArmyJoinInfoViewJobItemVM : UIViewModel
local ArmyJoinInfoViewJobItemVM = LuaClass(UIViewModel)
---Ctor
function ArmyJoinInfoViewJobItemVM:Ctor()
    self.ID = nil
    self.Icon = nil
end

function ArmyJoinInfoViewJobItemVM:UpdateVM(Value)
    self.ID = Value.ID
	self.Icon = Value.Icon
end

function ArmyJoinInfoViewJobItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end


--要返回当前类
return ArmyJoinInfoViewJobItemVM