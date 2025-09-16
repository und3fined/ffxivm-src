local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")
local PWorldEntEntityVM = require("Game/PWorld/Entrance/PWorldEntEntityVM")
local PWorldEntranceParentItemVM = LuaClass(UIViewModel)

function PWorldEntranceParentItemVM:Ctor()
    self.PWorldTabName = ""
    
    self.ChildernVMs = UIBindableList.New(PWorldEntEntityVM)

    self.IsAutoExpand = false
	self.IsExpanded = false
end

function PWorldEntranceParentItemVM:MakeChildData()
	local Data = {}
	local IDs = self.Data.IDs
	for _, ID in ipairs(IDs) do
		table.insert(Data, {ID = ID, Type = self.Data.Type})
	end

	return Data
end

function PWorldEntranceParentItemVM:UpdateVM(Data)
    self.Data = Data
	self.Type = Data.Type
	local ChildData = self:MakeChildData()
    self.ChildernVMs:UpdateByValues(ChildData)
end

function PWorldEntranceParentItemVM:AdapterOnGetCanBeSelected()
	--return false
	return true
end

function PWorldEntranceParentItemVM:AdapterOnGetWidgetIndex()
	return 0
end

function PWorldEntranceParentItemVM:AdapterOnGetIsCanExpand()
	-- return self.IsAutoExpand
	return true
end

function PWorldEntranceParentItemVM:AdapterOnGetChildren()
	return self.ChildernVMs:GetItems()
end

function PWorldEntranceParentItemVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

function PWorldEntranceParentItemVM:IsEqualVM(Value)
	return self.ID == Value
end

function PWorldEntranceParentItemVM:FindChildVMByIdx(Idx)
	return self.ChildernVMs:Get(Idx)
end

function PWorldEntranceParentItemVM:FindChildVMByID(ID)
	return self.ChildernVMs:Find(function(VM)
		return ID == VM.ID
	end)
end

function PWorldEntranceParentItemVM:GetChildVMIdx(VM)
	return self.ChildernVMs:GetItemIndex(VM)
end

function PWorldEntranceParentItemVM:UpdMatch()
	local Items = self.ChildernVMs:GetItems()

    for _, Item in pairs(Items) do
        Item:UpdMatch()
    end
end

return PWorldEntranceParentItemVM