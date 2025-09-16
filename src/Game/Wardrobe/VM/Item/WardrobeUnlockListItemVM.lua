--
-- Author: ZhengJanChuan
-- Date: 2024-02-29 09:47
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeUnlockListItemVM : UIViewModel
local WardrobeUnlockListItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeUnlockListItemVM:Ctor()
    self.CheckedState = false
    self.IsSelected = false
    self.ItemName = ""
    self.ReduceCond = ""
    self.FavoriteVisible = false
    self.ReduceVisible = nil
    self.EquipmentIcon = nil
    self.ID = 0
end

function WardrobeUnlockListItemVM:OnInit()
end

function WardrobeUnlockListItemVM:OnBegin()
end

function WardrobeUnlockListItemVM:OnEnd()
end

function WardrobeUnlockListItemVM:OnShutdown()
end

function WardrobeUnlockListItemVM:UpdateVM(Value)
    self.ItemName = Value.ItemName
    self.Num = Value.Num
    self.CheckedState = Value.CheckedState
    self.FavoriteVisible = Value.FavoriteVisible
    self.EquipmentIcon = Value.EquipmentIcon
    self.ID = Value.ID
    self.ReduceCond = Value.ReduceCond
end

function WardrobeUnlockListItemVM:SetCheckedState(State)
    self.CheckedState = State
end


--要返回当前类
return WardrobeUnlockListItemVM