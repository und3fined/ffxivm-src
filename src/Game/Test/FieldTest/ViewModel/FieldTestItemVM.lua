---
--- Author: sammrli
--- DateTime: 2023-05-22 15:46
--- Description:野外测试工具列表item ViewModel
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FieldTestItemVM : UIViewModel
local FieldTestItemVM = LuaClass(UIViewModel)

function FieldTestItemVM:Ctor()
    self.Text = ""
    self.BgColor = "00000001"
    self.ID = 0
    self.StartQuestID = 0
    self.Point = nil
    self.Name = ""
    self.Num = 0
    self.IsAutoExpand = false
    self.IsExpanded = false
    self.ChildrenVM = nil
    self.EntityID = nil
    self.NormalAI = nil
    self.Box = nil
    self.Cylinder = nil
    -- self.Behavior = 0
    -- self.IdleTimelinePath = ""

    -- self.MinRange = 0
	-- self.MaxRange = 0
	-- self.Volume = 0
	-- self.RangeVolume = 0
	-- self.SoundSubType = ""
	-- self.SoundType = ""
	-- self.SoundPath = ""
    -- self.SoundName = ""
end

---@param Value FieldTestItemData
function FieldTestItemVM:UpdateVM(Value)
    if Value.Index then
        self.Text = tostring(Value.Index)
    elseif Value.SoundName then
        self.Text = tostring(Value.Name)
    elseif Value.Type == 6 then
        self.Text = string.format("%d%s:%s", Value.ID, Value.Name, Value.WeatherEnv)
    elseif Value.Type == 7 then
        self.Text = string.format("%d_%s", Value.ID, Value.Name)
    elseif Value.Type == 8 then
        self.Text = string.format("id:Area%d", Value.ID)
    elseif Value.Type == 10 then
        self.Text = string.format("id:%d", Value.ID)
    else
        self.Text = string.format("id:%d %s", Value.ID, Value.Name)
    end

    self.ID = Value.ID
    self.StartQuestID = Value.StartQuestID
    self.Point = Value.Point
    self.Name = Value.Name
    self.Num = Value.Num
    self.EntityID = Value.EntityID
    self.Type = Value.Type
    self.Behavior = Value.Behavior
    self.IdleTimelinePath = Value.IdleTimelinePath
    
	self.MinRange = Value.MinRange
	self.MaxRange = Value.MaxRange
	self.Volume = Value.Volume
	self.RangeVolume = Value.RangeVolume
	self.SoundSubType = Value.SoundSubType
	self.SoundType = Value.SoundType
	self.SoundPath = Value.SoundPath
    self.SoundName = Value.SoundName

    self.WeatherType = Value.WeatherType
    self.WeatherEnv = Value.WeatherEnv
    self.WeatherRes = Value.WeatherRes

    self.NormalAI = Value.NormalAI

    self.Box = Value.Box
    self.Cylinder = Value.Cylinder

    self.AreaID = Value.AreaID
    self.FishLocationTye = Value.FishLocationTye
    
    self.ChildrenVM = {}
    if Value.Children and #Value.Children > 1 then
        for i=1, #Value.Children do
            local ChildVM = FieldTestItemVM.New()
            ChildVM:UpdateVM(Value.Children[i])
            table.insert(self.ChildrenVM, ChildVM)
        end
        self.IsAutoExpand = true
    end
end

function FieldTestItemVM:IsEqualVM(Value)
    return Value and Value.ID == self.ID
end

function FieldTestItemVM:AdapterOnGetCanBeSelected()
	return true
end

function FieldTestItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function FieldTestItemVM:AdapterOnGetIsCanExpand()
	return self.IsAutoExpand
end

function FieldTestItemVM:AdapterOnGetChildren()
	return self.ChildrenVM
end

function FieldTestItemVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

return FieldTestItemVM
