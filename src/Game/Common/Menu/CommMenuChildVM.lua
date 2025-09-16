--
-- Author: anypkvcai
-- Date: 2023-04-06 16:47
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CommMenuChildVM : UIViewModel
local CommMenuChildVM = LuaClass(UIViewModel)

---Ctor
function CommMenuChildVM:Ctor()
	self.Key = nil
	self.Name = ""
	self.ModuleID = nil
	self.IsUnLock = false
	self.ParentVM = nil
	self.AlwaysSelect = false
end

function CommMenuChildVM:IsEqualVM(Value)
	return nil ~= Value and Value.Key == self.Key
end

---UpdateVM
---@param Value table
function CommMenuChildVM:UpdateVM(Value, Parent)
	self.Key = Value.Key
	self.Name = Value.Name
	self.ModuleID = Value.ModuleID
	self.IsUnLock = _G.ModuleOpenMgr:CheckOpenState(self.ModuleID)
	if Value.IsUnLock ~= nil then
		self.IsUnLock = Value.IsUnLock
	end
	self.RedDotName = Value.RedDotName
	self.RedDotID = Value.RedDotID
	self.RedDotStyle = Value.RedDotStyle
	self.RedDotText = Value.RedDotText
	self.RedDot2ID = Value.RedDot2ID
	self.RedDot2Text = Value.RedDot2Text
	self.ParentVM = Parent
	self.IconVisible = false
	if Value.Icon then
		self.Icon = Value.Icon
		self.IconVisible = true
	end
	
	self.AlwaysSelect = Value.AlwaysSelect
end

function CommMenuChildVM:GetKey()
	return self.Key
end

function CommMenuChildVM:AdapterOnGetCanBeSelected()
	return true
end

function CommMenuChildVM:AdapterOnGetWidgetIndex()
	return 1
end

function CommMenuChildVM:AdapterOnGetIsCanExpand()
	return true
end

function CommMenuChildVM:AdapterOnGetChildren()

end

function CommMenuChildVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

function CommMenuChildVM:SetShowTogetherWithChildItem(IsShow)
	self.ParentVM:SetShowTogetherWithChildItem(IsShow)
end

function CommMenuChildVM:SetNextClickItem(ItemData)
	self.ParentVM:SetNextClickItem(ItemData)
end

return CommMenuChildVM

