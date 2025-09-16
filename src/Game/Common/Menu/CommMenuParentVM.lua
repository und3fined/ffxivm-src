--
-- Author: anypkvcai
-- Date: 2023-04-06 16:47
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CommMenuChildVM = require("Game/Common/Menu/CommMenuChildVM")
local UIBindableList = require("UI/UIBindableList")

---@class CommMenuParentVM : UIViewModel
local CommMenuParentVM = LuaClass(UIViewModel)

---Ctor
function CommMenuParentVM:Ctor()
	self.Key = nil
	self.Name = ""
	self.ModuleID = nil
	self.IsAutoExpand = false
	self.IsExpanded = false
	self.IsUnLock = false
	self.IsShowTogetherWithChildItem = false
	self.NextClickChildItem = nil
	self.BindableListChildren = UIBindableList.New(CommMenuChildVM, self)
end

function CommMenuParentVM:IsEqualVM(Value)
	return nil ~= Value and Value.Key == self.Key
end

---UpdateVM
---@param Value table
function CommMenuParentVM:UpdateVM(Value)
	self.Key = Value.Key
	self.Name = Value.Name
	self.ModuleID = Value.ModuleID
	self.IsExpanded = false
	self.IsModuleOpen = Value.IsModuleOpen
	self.RedDotName = Value.RedDotName
	self.RedDotID = Value.RedDotID
	self.RedDot2ID = Value.RedDot2ID
	self.RedDotStyle = Value.RedDotStyle
	self.RedDotText = Value.RedDotText
	self.RedDot2Text = Value.RedDot2Text
	local ValueChildren = Value.Children
	self.IsShowTogetherWithChildItem = false

	self.IsUnLock = _G.ModuleOpenMgr:CheckOpenState(self.ModuleID)
	if nil ~= ValueChildren then
		self.IsAutoExpand = #ValueChildren > 0 and self.IsUnLock
	else
		self.IsAutoExpand = false
	end

	self.BindableListChildren:UpdateByValues(ValueChildren)
end

function CommMenuParentVM:GetKey()
	return self.Key
end

function CommMenuParentVM:AdapterOnGetCanBeSelected()
	if self.ModuleID ~= nil then
		if not self.IsUnLock then
			_G.ModuleOpenMgr:ModuleState(self.ModuleID)
		end
		return self.IsUnLock
	else
		return true
	end
end

function CommMenuParentVM:AdapterOnGetWidgetIndex()
	return 0
end

function CommMenuParentVM:AdapterOnGetIsCanExpand()
	return self.IsAutoExpand
end

function CommMenuParentVM:AdapterOnGetChildren()
	return self.BindableListChildren:GetItems()
end

function CommMenuParentVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

function CommMenuParentVM:FindChild(Key)
	local Children = self.BindableListChildren:GetItems()
	if nil == Children then
		return
	end

	for i = 1, #Children do
		local Child = Children[i]
		if Child:GetKey() == Key then
			return Child
		end
	end
end

function CommMenuParentVM:SetShowTogetherWithChildItem(IsShow)
	if nil ~= self.NextClickChildItem and IsShow == false then
		return
	end

	self.IsShowTogetherWithChildItem = IsShow
end

function CommMenuParentVM:SetNextClickItem(ItemData)
	local Children = self.BindableListChildren:GetItems()
	if nil == Children then
		return
	end

	for i = 1, #Children do
		if ItemData.Key == Children[i].Key then
			self.NextClickChildItem = ItemData.Key
			return
		end
	end
	self.NextClickChildItem = nil
end

return CommMenuParentVM

