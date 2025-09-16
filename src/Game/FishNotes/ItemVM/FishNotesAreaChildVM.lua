--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-10-09 17:25:32
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-12-03 15:16:05
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishNotesAreaChildVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
---@author Carl
---DateTime: 2023-08-31 16:42:00
---Description:钓鱼区域下的子地点VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")

---@class FishNotesAreaChildVM: UIViewModel
---@field Index number @地点下标
---@field bPlaceSelected boolean 是否选中
---@field PlaceName string 地点名字
---@field PlaceLevel string 地点等级
---@field bActive boolean 是否有鱼在窗口期
---@field IsUnlockedAllFish boolean 是否解锁全部鱼
local FishNotesAreaChildVM = LuaClass(UIViewModel)

function FishNotesAreaChildVM:Ctor()
    self.Index = 0
    self.PlaceName = ""
    self.bPlaceSelected = false
    self.PlaceLevel = ""
    self.bPlaceLevelJiText = false
    self.bActive = false
    self.IsUnlockedAllFish = false
    self.PlaceNameColor = FishNotesDefine.Color.PlaceNameNormal
end

function FishNotesAreaChildVM:IsEqualVM(Value)
    return Value.Key == self.Key
end

function FishNotesAreaChildVM:UpdateVM(Value)
    self.Index = Value.Index
    self.ID = Value.ID
    self.ParentKey = Value.ParentKey
    self.Key = Value.Key
    self.PlaceLevel = Value.bLock and "" or Value.Level
    self.bPlaceLevelJiText = not Value.bLock
    self.bPlaceSelected = Value.bChanged
    self.bActive = Value.bActive
    self.IsUnlockedAllFish = self.bActive == false and Value.IsUnlockedAllFish
    self.PlaceName = Value.bLock and FishNotesDefine.FishLockPlaceName or Value.Name
    if self.bPlaceSelected then
        self.PlaceNameColor = FishNotesDefine.Color.PlaceNameSelect
    else
        self.PlaceNameColor = FishNotesDefine.Color.PlaceNameNormal
    end
end

function FishNotesAreaChildVM:RefreshWindowState()
	self.bActive = _G.FishNotesMgr:GetIsHaveFishInWindowInLocation(self.ID)
    self.IsUnlockedAllFish = self.bActive == false and self.IsUnlockedAllFish
end

function FishNotesAreaChildVM:GetKey()
	return self.Key
end

function FishNotesAreaChildVM:AdapterOnGetCanBeSelected()
	return true
end

function FishNotesAreaChildVM:AdapterOnGetWidgetIndex()
	return 1
end

function FishNotesAreaChildVM:AdapterOnGetIsCanExpand()
	return true
end

function FishNotesAreaChildVM:AdapterOnGetChildren()

end

function FishNotesAreaChildVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

return FishNotesAreaChildVM