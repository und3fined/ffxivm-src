local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local EToggleButtonState = _G.UE.EToggleButtonState
---@class BuddyMainPageItemVM : UIViewModel
local BuddyMainPageItemVM = LuaClass(UIViewModel)

---Ctor
function BuddyMainPageItemVM:Ctor()
	self.OffIcon = nil
	self.OnIcon = nil
	self.Index = nil
	self.IconState = nil
end

function BuddyMainPageItemVM:UpdateVM(Value)
	self.OffIcon = Value.OffIcon
	self.OnIcon = Value.OnIcon
	self.Index = Value.Index
end

function BuddyMainPageItemVM:UpdateIconState(Index)
	if Index == self.Index then
		self.IconState = EToggleButtonState.Checked
	else
		self.IconState = EToggleButtonState.Unchecked
	end
end

function BuddyMainPageItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.Index == self.Index
end


--要返回当前类
return BuddyMainPageItemVM