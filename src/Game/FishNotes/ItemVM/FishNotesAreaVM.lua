---
---@author Lucas
---DateTime: 2023-03-30 15:16:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local FishNotesAreaChildVM = require("Game/FishNotes/ItemVM/FishNotesAreaChildVM")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local EToggleButtonState = _G.UE.EToggleButtonState

---@class FishNotesAreaVM: UIViewModel
---@field AreaName string 地区名字
---@field bAreaChanged boolean 是否选中该区域
---@field ToggleState EToggleButtonState 选中状态
---
---@field bPlaceItemSelected boolean 是否选中
---@field PlaceItemName string 地点名字
---@field PlaceItemLevel string 地点等级
---@field bPlaceUnlocked boolean 是否解锁全部鱼
---
---@field Index number 索引
---@field bLock boolean 是否锁定
---
---@field SavePlaceName string 保存的地点名字
local FishNotesAreaVM = LuaClass(UIViewModel)

function FishNotesAreaVM:Ctor()
    self.WidgetIndex = FishNotesDefine.FishLocationTreeType.Area
    self.AreaChildrenList = UIBindableList.New(FishNotesAreaChildVM)
    self.Index = 1
    self.bLock = false
    self.AreaName = ""
    self.bAreaChanged = false
    self.bPlaceItemSelected = false
    self.PlaceItemName = ""
    self.PlaceItemLevel = ""
    self.bPlaceUnlocked = false
    self.SavePlaceName = ""
end

function FishNotesAreaVM:IsEqualVM(Value)
    return Value.Key == self.Key
end

function FishNotesAreaChildVM:GetKey()
	return self.Key
end

function FishNotesAreaVM:UpdateVM(Value)
    self.WidgetIndex = Value.WidgetIndex
    self.Index = Value.Index
    self.Key = Value.Key
    self.bLock = Value.bLock
    self.bAreaChanged = Value.bChanged
    local ValueChildren = Value.Children
    self.AreaName = Value.Name
    --self.ToggleState = self.bAreaChanged and EToggleButtonState.Checked or EToggleButtonState.Unchecked
    self:UpdateColor()
    self.AreaChildrenList:Clear()
    self.AreaChildrenList:UpdateByValues(ValueChildren, nil)
    self.IconArrow = nil
end

function FishNotesAreaVM:SetSelected()
    self.bAreaChanged = not self.bAreaChanged
    self:UpdateColor()
end

function FishNotesAreaVM:UpdateColor()
    if self.bAreaChanged then
        self.AreaNameColor = FishNotesDefine.Color.PlaceNameSelect
    else 
        self.AreaNameColor = FishNotesDefine.Color.AreaNameNormal
    end
end

function FishNotesAreaVM:AdapterOnGetChildren()
	return self.AreaChildrenList:GetItems()
end

function FishNotesAreaVM:AdapterOnGetWidgetIndex()
	return 0
end

--  function FishNotesAreaVM:AdapterOnGetIsCanExpand()
--     return self.ToggleState ~= EToggleButtonState.Checked
--  end

 function FishNotesAreaVM:AdapterOnExpansionChanged(IsExpanded)
    if IsExpanded then
		self.IconArrow = FishNotesDefine.IconArrow.Select
	else
		self.IconArrow = FishNotesDefine.IconArrow.Normal
    end
 end

function FishNotesAreaVM:GetIsLock()
    return self.bLock
end

function FishNotesAreaVM:UpdateChildVM(ChildIndex, Value)
    if ChildIndex == nil or Value == nil then
        return
    end

    if self.AreaChildrenList == nil then
        return
    end
    
    local ChildVM = self.AreaChildrenList.Items[ChildIndex]
    if ChildVM == nil then
        return
    end
    ChildVM:UpdateVM(Value)
end

return FishNotesAreaVM