--
-- Author: ZhengJanChuan
-- Date: 2024-02-27 19:26
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")

---@class WardrobeConsumeItemVM : UIViewModel
local WardrobeConsumeItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeConsumeItemVM:Ctor()
    self.BagSlotVM = BagSlotVM.New()
    self.Num = ""
    self.ItemNum = 0
end

function WardrobeConsumeItemVM:OnInit()
end

function WardrobeConsumeItemVM:OnBegin()
end

function WardrobeConsumeItemVM:OnEnd()
end

function WardrobeConsumeItemVM:OnShutdown()
end

function WardrobeConsumeItemVM:UpdateVM(Value)
    self.Num = Value.Num
    local Item = ItemUtil.CreateItem(Value.Item, 0)
    self.BagSlotVM:UpdateVM(Item, {PanelBagVisible = true})
end

function WardrobeConsumeItemVM:UpdateItemNum(Num)
    self.ItemNum = Num
end


--要返回当前类
return WardrobeConsumeItemVM