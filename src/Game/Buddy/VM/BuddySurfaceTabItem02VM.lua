local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class BuddySurfaceTabItem02VM : UIViewModel
local BuddySurfaceTabItem02VM = LuaClass(UIViewModel)

---Ctor
function BuddySurfaceTabItem02VM:Ctor()
	self.TabText = nil
	self.Index = nil
	self.SelectedVisible = nil
	self.SelectedAni = nil
end

function BuddySurfaceTabItem02VM:UpdateVM(Value)
	self.TabText = Value.Text
	self.Index = Value.Index
end

function BuddySurfaceTabItem02VM:UpdateIconState(Index)
	self.SelectedVisible = Index  == self.Index
	self.SelectedAni  = Index  == self.Index
end

function BuddySurfaceTabItem02VM:IsEqualVM(Value)
	return nil ~= Value and Value.Index == self.Index
end


--要返回当前类
return BuddySurfaceTabItem02VM