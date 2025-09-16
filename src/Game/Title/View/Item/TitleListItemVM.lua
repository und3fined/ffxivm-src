local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local EToggleButtonState = _G.UE.EToggleButtonState

---@class TitleListItemVM : UIViewModel
local TitleListItemVM = LuaClass(UIViewModel)

---Ctor
function TitleListItemVM:Ctor()
	self.ID = 0
	self.IsNew = false
	self.IsUsed = false
	self.IsFavorite = false
	self.TitleText = ""
	self.IsUnLock = false
	self.ToggleBtnState = EToggleButtonState.Unchecked
end

function TitleListItemVM:OnInit()

end

function TitleListItemVM:OnBegin()

end

function TitleListItemVM:IsEqualVM(Value)
	return false
end

function TitleListItemVM:OnEnd()

end

function TitleListItemVM:OnShutdown()

end

function TitleListItemVM:AdapterOnGetCanBeSelected()
	return self.ID ~= 0
end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function TitleListItemVM:UpdateVM(Value, Params)
	self.ID = Value.ID
	self.IsUsed = Value.IsUsed
	self.IsFavorite = Value.IsFavorite
	self.TitleText = Value.TitleText
	self.IsUnLock = Value.IsUnLock
	self.ToggleBtnState = EToggleButtonState.Unchecked
end

return TitleListItemVM