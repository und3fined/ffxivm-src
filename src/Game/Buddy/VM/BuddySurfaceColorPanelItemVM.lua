local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class BuddySurfaceColorPanelItemVM : UIViewModel
local BuddySurfaceColorPanelItemVM = LuaClass(UIViewModel)

---Ctor
function BuddySurfaceColorPanelItemVM:Ctor()
	self.Type = nil
	self.IconImg = nil
	self.NormalVisible = nil
	self.SelectedVisible = nil
	self.Color = nil
end

function BuddySurfaceColorPanelItemVM:UpdateVM(Value)
	self.Type = Value.Type
	self.Color = Value.Color
	self.IconImg = Value.IconPath
end

function BuddySurfaceColorPanelItemVM:UpdateIconState(Type)
	self.NormalVisible = Type ~= self.Type
	self.SelectedVisible = Type == self.Type
end

function BuddySurfaceColorPanelItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.Type == self.Type
end


--要返回当前类
return BuddySurfaceColorPanelItemVM