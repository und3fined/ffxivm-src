--
-- Author: ZhengJanChuan
-- Date: 2024-02-27 19:26
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")

---@class WardrobeBagSlotItemVM : UIViewModel
local WardrobeBagSlotItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeBagSlotItemVM:Ctor()
    self.Name = ""
    self.Num = 0
    self.BagSlotVM = BagSlotVM.New()
    self.BagSlotVM.PanelBagVisible = true
end

function WardrobeBagSlotItemVM:OnInit()
end

function WardrobeBagSlotItemVM:OnBegin()
end

function WardrobeBagSlotItemVM:OnEnd()
end

function WardrobeBagSlotItemVM:OnShutdown()
end

function WardrobeBagSlotItemVM:UpdateVM(Value)
    self.Name = Value.Name
    self.Num = Value.Num
    local Item = ItemUtil.CreateItem(Value.Item, 0)
    self.BagSlotVM:UpdateVM(Item, {PanelBagVisible = true, IsShowNum = false, IsShowLeftCornerFlag = false})
end


--要返回当前类
return WardrobeBagSlotItemVM