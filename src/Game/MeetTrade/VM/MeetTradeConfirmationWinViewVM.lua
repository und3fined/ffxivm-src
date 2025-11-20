local LuaClass = require("Core/LuaClass")
local MeetTradeItemVM = require("Game/MeetTrade/VM/MeetTradeItemVM")
local UIViewModel = require("UI/UIViewModel")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local MeetTradeVM = require("Game/MeetTrade/VM/MeetTradeVM")
local FLOG_ERROR = _G.FLOG_ERROR
---@class MeetTradeConfirmationWinViewVM : UIViewModel
local MeetTradeConfirmationWinViewVM = LuaClass(UIViewModel)

---Ctor
function MeetTradeConfirmationWinViewVM:Ctor()
    self.EmptyItemCache = {}
    self.RoleGoldForTradeText = nil
    self.MajorGoldForTradeText = nil
    self.MajorGoldTaxText = nil
    self.MajorGoldTaxRateText = nil
    ---我方交易列表
    self.MajorTradeItemVMList = UIBindableBagSlotList.New(MeetTradeItemVM, {OtherInfomation = true})
    ---对方交易列表
    self.RoleTradeItemVMList = UIBindableBagSlotList.New(MeetTradeItemVM, {OtherInfomation = true})
end

function MeetTradeConfirmationWinViewVM:OnInit()
end

function MeetTradeConfirmationWinViewVM:OnBegin()
end

function MeetTradeConfirmationWinViewVM:OnEnd()

end

function MeetTradeConfirmationWinViewVM:Update()
    self:UpdateMajorTradeItemListInfo(MeetTradeVM.MajorTradeItemListParams)
    self:UpdateRoleTradeItemListInfo(MeetTradeVM.RoleTradeItemListParams)
    self.RoleGoldForTradeText = MeetTradeVM.RoleGoldForTradeText
    self.MajorGoldForTradeText = MeetTradeVM.MajorGoldForTradeText
    self.MajorGoldTaxText = MeetTradeVM.MajorGoldTaxText
    self.MajorGoldTaxRateText = MeetTradeVM.MajorGoldTaxRateText
end

function MeetTradeConfirmationWinViewVM:UpdateMajorTradeItemListInfo(Items)
    local Capacity = self:GetItemCapacity()
    if(nil ~= Items and #Items > Capacity) then
        FLOG_ERROR("MeetTradeVM:MajorTradeItemVMList capacity is %d, but Items count is %d", Capacity, #Items)
        return
    end
    local ItemList = Items or {}
    --- 在第一个空ItemList后添加设置“+”显示
    -- if(#ItemList < Capacity) then
    --     local Index = #ItemList + 1
    --     ItemList[Index] = {ImgAddOpacity = 1}
    -- end
	ItemList = self:FillCapacityByEmptyItem(ItemList)
    for i, v in ipairs(ItemList) do
        v.BtnAddVisible = true
        v.Index = i
    end
	self.MajorTradeItemVMList:UpdateByValues(ItemList)
end

function MeetTradeConfirmationWinViewVM:UpdateRoleTradeItemListInfo(Items)
    local Capacity = self:GetItemCapacity()
    if(nil ~= Items and #Items > Capacity) then
        FLOG_ERROR("MeetTradeVM:RoleTradeItemVMList capacity is %d, but Items count is %d", Capacity, #Items)
        return
    end
    local ItemList = Items or {}
    ItemList = self:FillCapacityByEmptyItem(ItemList)
    for _, v in ipairs(ItemList) do
        v.BtnAddVisible = false
    end
    self.RoleTradeItemVMList:UpdateByValues(ItemList)
end

function MeetTradeConfirmationWinViewVM:FillCapacityByEmptyItem(ItemList)
    local Capacity = self:GetItemCapacity()
	local ResultList = ItemList or {}
	local ItemLen = #ResultList
	for i = 1, Capacity - ItemLen do
		ResultList[ItemLen + i] = self.EmptyItemCache
	end
	return ResultList
end
function MeetTradeConfirmationWinViewVM:GetItemCapacity()
	return _G.MeetTradeMgr.SelectListCapacity
end
return MeetTradeConfirmationWinViewVM