---
---@author Lucas
---DateTime: 2023-03-30 15:16:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local FishNotesWindowVM = require("Game/FishNotes/ItemVM/FishNotesWindowVM")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")

---@class FishNotesWindowsTimeVM: UIViewModel
local FishNotesWindowsTimeVM = LuaClass(UIViewModel)

function FishNotesWindowsTimeVM:Ctor()
    self.WindowChildrenList = UIBindableList.New(FishNotesWindowVM)
    self.Index = 1
    self.StartDate = ""
    self.Key = 0
end

function FishNotesWindowsTimeVM:IsEqualVM(Value)
    return Value.Key == self.Key
end

function FishNotesWindowsTimeVM:GetKey()
	return self.Key
end

function FishNotesWindowsTimeVM:UpdateVM(Value)
    self.Key = Value.Key
    self.StartDate = Value.StartDate -- %m月%d日
    local ValueChildren = Value.Children
    self.WindowChildrenList:Clear()
    self.WindowChildrenList:UpdateByValues(ValueChildren, nil)
end

function FishNotesWindowsTimeVM:SetSelected()
    self.bAreaChanged = not self.bAreaChanged
    self:UpdateColor()
end

function FishNotesWindowsTimeVM:AdapterOnGetChildren()
	return self.WindowChildrenList:GetItems()
end

function FishNotesWindowsTimeVM:AdapterOnGetWidgetIndex()
	return FishNotesDefine.FishWindowTimeTreeType.Time
end

function FishNotesWindowsTimeVM:UpdateChildVM(ChildIndex, Value)
    if ChildIndex == nil or Value == nil then
        return
    end

    if self.WindowChildrenList == nil then
        return
    end

    local ChildVM = self.WindowChildrenList.Items[ChildIndex]
    if ChildVM == nil then
        return
    end
    ChildVM:UpdateVM(Value)
end

return FishNotesWindowsTimeVM