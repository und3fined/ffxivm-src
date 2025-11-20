local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoEditSubTabItemVM = LuaClass(UIViewModel)

function PhotoEditSubTabItemVM:Ctor()
    self.Name = ""
	self.Index = -1
    self.IsSelected = false
end

function PhotoEditSubTabItemVM:UpdateVM(Data)
	self.CfgIdx = Data.CfgIdx
	self.Name = Data.Name
	self.IsSelected = false
end

function PhotoEditSubTabItemVM:IsEqualVM(Data)
	return Data.CfgIdx == self.CfgIdx
end

return PhotoEditSubTabItemVM