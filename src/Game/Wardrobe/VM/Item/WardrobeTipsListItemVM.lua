--
-- Author: ZhengJanChuan
-- Date: 2024-03-04 16:45
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local UIBindableList = require("UI/UIBindableList")

---@class WardrobeTipsListItemVM : UIViewModel
local WardrobeTipsListItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeTipsListItemVM:Ctor()
    self.EquipmentName = ""
	self.BagNum = 0
    self.BagSlotVM = BagSlotVM.New()
	self.IsSelected = false 
    self.ResID = 0
    self.DataList = UIBindableList.New()
end

function WardrobeTipsListItemVM:OnInit()
end

function WardrobeTipsListItemVM:OnBegin()
end

function WardrobeTipsListItemVM:OnEnd()
end

function WardrobeTipsListItemVM:OnShutdown()
end

function WardrobeTipsListItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeTipsListItemVM:UpdateVM(Value)
    self.EquipmentName = Value.EquipmentName
    self.BagNum = Value.BagNum
    self.ResID = Value.ID
    self.DataList = ItemUtil.GetItemGetWayList(Value.ID)

    local Item = ItemUtil.CreateItem(Value.ID, 0)
	self.BagSlotVM:UpdateVM(Item, {IsShowNum = false, IsShowLeftCornerFlag = false})
end

function WardrobeTipsListItemVM:IsEqualVM(Value)
    return self.ResID == Value.ResID
end


--要返回当前类
return WardrobeTipsListItemVM