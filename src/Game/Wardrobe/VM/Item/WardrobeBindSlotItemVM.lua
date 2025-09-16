--
-- Author: ZhengJanChuan
-- Date: 2024-02-28 16:38
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")

---@class WardrobeBindSlotItemVM : UIViewModel
local WardrobeBindSlotItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeBindSlotItemVM:Ctor()
    self.BagSlotVM = BagSlotVM.New()
    self.IsSwitch = false
    self.IsSelected = false
    self.ID = 0
    self.GID = 0
end

function WardrobeBindSlotItemVM:OnInit()
end

function WardrobeBindSlotItemVM:OnBegin()
end

function WardrobeBindSlotItemVM:OnEnd()
end

function WardrobeBindSlotItemVM:OnShutdown()
end

function WardrobeBindSlotItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeBindSlotItemVM:UpdateVM(Value)
    -- self.BagSlotVM = Value.BagSlotVM
    -- self.BagSlotVM.PanelBagVisible = true
    local Item = ItemUtil.CreateItem(Value.ID, 1)
    self.BagSlotVM:UpdateVM(Item, {PanelBagVisible = true, IsShowLeftCornerFlag = false})
    self.IsSwitch = Value.IsSwitch
    self.ID  = Value.ID
    self.GID = Value.GID
end

function WardrobeBindSlotItemVM:UpdateBindItemGID(GID)
    self.GID = GID
end


--要返回当前类
return WardrobeBindSlotItemVM