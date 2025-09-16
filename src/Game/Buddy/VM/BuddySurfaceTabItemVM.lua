local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class BuddySurfaceTabItemVM : UIViewModel
local BuddySurfaceTabItemVM = LuaClass(UIViewModel)

---Ctor
function BuddySurfaceTabItemVM:Ctor()
	self.ImgIcon = nil
	self.SelectedIcon = nil
	self.Index = nil
	self.SelectedVisible = nil
	self.SelectedAni = nil
end

function BuddySurfaceTabItemVM:UpdateVM(Value)
	self.ImgIcon = Value.ImgIcon
	self.SelectedIcon = Value.SelectedIcon
	self.Index = Value.Index
end

function BuddySurfaceTabItemVM:UpdateIconState(Index)
	self.SelectedVisible = Index  == self.Index
	self.SelectedAni  = Index  == self.Index
end

function BuddySurfaceTabItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.Index == self.Index
end


--要返回当前类
return BuddySurfaceTabItemVM