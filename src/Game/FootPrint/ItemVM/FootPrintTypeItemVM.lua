--
-- Author: alex
-- Date: 2024-03-14 16:14
-- Description:足迹系统条目类型ItemVM
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local FootPrintItemDetailVM = require("Game/FootPrint/ItemVM/FootPrintItemDetailVM")
local FootPrintTypeCfg = require("TableCfg/FootPrintTypeCfg")
local FootPrintItemCfg = require("TableCfg/FootMarkRecordCfg")
---@class FootPrintTypeItemVM : UIViewModel
local FootPrintTypeItemVM = LuaClass(UIViewModel)

---Ctor
function FootPrintTypeItemVM:Ctor()
	self.Key = nil -- 使用number，否则Hash时会保持原类型，TableView的通用逻辑仍会使用number去寻找而无法找到
    self.TypeID = 0
	self.TypeName = ""
	self.NumComplete = ""
	self.IsAutoExpand = false
	self.IsExpanded = false
	self.UpArrowVisible = false
	self.DownArrowVisible = false
	self.TextDistanceVisible = false
	self.ChildrenList = {} --UIBindableList.New(FootPrintItemDetailVM)
	self.IsUnLock = false
    self.bAllItemComplete = false
end

function FootPrintTypeItemVM:IsEqualVM(Value)
	return false
end

---UpdateVM
---@param Value table
function FootPrintTypeItemVM:UpdateVM(Value)
	self.Key = Value.Key
    local TypeID = Value.TypeID
	self.TypeID = TypeID

	local IsUnLock = Value.IsUnLock
	self.IsUnLock = IsUnLock
	if not IsUnLock then
		self.TypeName = "? ? ?"--..tostring(TypeID)
		self.UpArrowVisible = false
		self.DownArrowVisible = false
		self.TextDistanceVisible = false
		self.bAllItemComplete = false
		self.IsAutoExpand = false
		self.IsExpanded = false
		return
	end
	
	local ItemCfg = FootPrintItemCfg:FindCfgByKey(TypeID)
	if not ItemCfg then
		return
	end
    self.TypeName = ItemCfg.ShowText
	self.IsExpanded = false
    
	local TextCompleteValue = string.format(ItemCfg.CountName, Value.NumComplete)

	self.NumComplete = TextCompleteValue
	self.TextDistanceVisible = true

	self.ChildrenList = {}
    local ChildrenList = self.ChildrenList
	local ValueChildren = Value.Children
	if nil ~= ValueChildren then
        -- 规则：条目全部刷新，未达到解锁百分比的不显示条目描述
		local bAllItemComplete = true
        for _, SubValue in ipairs(ValueChildren) do
            local CompleteNum = SubValue.NumComplete
            local TargetNum = SubValue.TargetNum
			if bAllItemComplete and CompleteNum < TargetNum then
				bAllItemComplete = false
			end
			local ChildVM = FootPrintItemDetailVM.New()
			ChildVM:UpdateVM(SubValue)
			table.insert(ChildrenList, ChildVM)
        end
		self.IsAutoExpand = #ChildrenList > 0 and IsUnLock
        self.bAllItemComplete = bAllItemComplete
	end
	self:UpdateArrowVisible()
end

function FootPrintTypeItemVM:GetKey()
	return self.Key
end

function FootPrintTypeItemVM:AdapterOnGetCanBeSelected()
	return self.IsUnLock
end

function FootPrintTypeItemVM:AdapterOnGetWidgetIndex()
	return 0
end

function FootPrintTypeItemVM:AdapterOnGetIsCanExpand()
	return self.IsUnLock
end

function FootPrintTypeItemVM:AdapterOnGetChildren()
	return self.ChildrenList
end

function FootPrintTypeItemVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
	self:UpdateArrowVisible()
end

function FootPrintTypeItemVM:UpdateArrowVisible()
	local IsAutoExpand = self.IsAutoExpand
	local IsExpanded = self.IsExpanded

	self.UpArrowVisible = IsAutoExpand and IsExpanded
	self.DownArrowVisible = IsAutoExpand and not IsExpanded
end

function FootPrintTypeItemVM:FindChild(Key)
	local Children = self.ChildrenList
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

return FootPrintTypeItemVM

