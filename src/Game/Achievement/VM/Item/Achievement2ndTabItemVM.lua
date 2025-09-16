---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local EToggleButtonState = _G.UE.EToggleButtonState

---@class Achievement2ndTabItemVM : UIViewModel
local Achievement2ndTabItemVM = LuaClass(UIViewModel)

---Ctor
function Achievement2ndTabItemVM:Ctor()
	self.Key = nil
	self.TypeID = 0
	self.CategoryID = 0
	self.ShowComplete = true

	--Binders
	self.TextContent = ""
	self.ToggleBtnState = EToggleButtonState.Unchecked
end

function Achievement2ndTabItemVM:IsEqualVM(Value)
	return true
end

function Achievement2ndTabItemVM:SetToggleBtnState(State)
	self.ToggleBtnState = State
end

function Achievement2ndTabItemVM:SetSelectedState(IsSelected)
	if IsSelected then
		self:SetToggleBtnState(EToggleButtonState.Checked)
	else
		self:SetToggleBtnState(EToggleButtonState.Unchecked)
	end
end


---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function Achievement2ndTabItemVM:UpdateVM(Value, Params)
	self.TypeID = Value.TypeID
	self.CategoryID = Value.CategoryID
	self.ShowComplete = Value.ShowComplete
	self.Key = Value.CategoryID

	self.TextContent = Value.Category or ""
end

function Achievement2ndTabItemVM:GetKey()
	return self.Key
end

function Achievement2ndTabItemVM:AdapterOnGetCanBeSelected()
	return true
end

function Achievement2ndTabItemVM:AdapterOnGetWidgetIndex()
	return 1
end

function Achievement2ndTabItemVM:AdapterOnGetIsCanExpand()
	return false
end

function Achievement2ndTabItemVM:AdapterOnGetChildren()

end

function Achievement2ndTabItemVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

return Achievement2ndTabItemVM