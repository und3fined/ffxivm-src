local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BuddyMgr

---@class BuddySurfaceColorItemVM : UIViewModel
local BuddySurfaceColorItemVM = LuaClass(UIViewModel)

---Ctor
function BuddySurfaceColorItemVM:Ctor()
	BuddyMgr = _G.BuddyMgr
	self.ColorValue = nil
	self.bIsSelected = nil
	self.bIsDyed = nil
	self.bIsLocked = nil
	self.IsValid = nil
end

function BuddySurfaceColorItemVM:UpdateVM(Value)
	self.IsValid = Value ~= nil and Value.ID ~= nil

	if not self.IsValid then
		return
	end

	self.ColorID = Value.ID
	self.DyeItemID = Value.DyeItemID
    self.ColorValue = string.format("#%02X%02X%02X", Value.R, Value.G, Value.B)
    self.ColorName = Value.Name
    self.bIsLocked = BuddyMgr:BLockColor(Value.ID) and Value.DyeItemID == 0 
	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor then
		self:UpdateColorDye(BuddyColor.RGB)
	end
end

function BuddySurfaceColorItemVM:UpdateColorDye(ColorID)
	self.bIsDyed = ColorID == self.ColorID
end

function BuddySurfaceColorItemVM:UpdateIconState(ColorID)
	self.bIsSelected = ColorID == self.ColorID
end

function BuddySurfaceColorItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ColorID
end


--要返回当前类
return BuddySurfaceColorItemVM