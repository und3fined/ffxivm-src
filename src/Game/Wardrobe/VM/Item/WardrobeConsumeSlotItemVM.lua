--
-- Author: ZhengJanChuan
-- Date: 2024-02-23 16:35
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class WardrobeConsumeSlotItemVM : UIViewModel
local WardrobeConsumeSlotItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeConsumeSlotItemVM:Ctor()
    self.Num = ""
    self.BagSlotVM = BagSlotVM.New()
    self.IsSelected = false
end

function WardrobeConsumeSlotItemVM:OnInit()
end

function WardrobeConsumeSlotItemVM:OnBegin()
end

function WardrobeConsumeSlotItemVM:OnEnd()
end

function WardrobeConsumeSlotItemVM:OnShutdown()
end

function WardrobeConsumeSlotItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeConsumeSlotItemVM:UpdateVM(Value)
    self.Num = Value.Num
    local Item = ItemUtil.CreateItem(Value.Item, 0)
    self.BagSlotVM:UpdateVM(Item, {PanelBagVisible = true, IsShowNum = false})
end



--要返回当前类
return WardrobeConsumeSlotItemVM