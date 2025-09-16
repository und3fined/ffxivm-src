---
--- Author: Alex
--- DateTime: 2023-02-14 11:47:52
--- Description: 商店购买子界面数据结构
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ShopCostItemVM = require("Game/Shop/ItemVM/ShopCostItemVM")
local ItemVM = require("Game/Item/ItemVM")
--local ItemUtil = require("Utils/ItemUtil")
--local ItemTipsVM = require("Game/Item/ItemTipsVM")
local LSTR = _G.LSTR

---@class ShopExchangeWinVM : UIViewModel
---@field ShopItemId number@商店商品ID
---@field ItemName string@商品名称
---@field ShopBuyTypeName string@商店购买类型名称 （交换 or 购买）
---@field OriginCostList UIBindableList@单个商品消耗列表
---@field CostList UIBindableList@批量消耗列表
---@field ItemTypeName string@物品类型名称
---@field CommItemSlotVM ItemVM@通用物品槽数据
---@field IsNeedLongClick boolean@是否需要长按
---@field IsLimited boolean@是否有限购
---@field ToExchangeNum number@交换数量
---@field ToExchangeTips string@交换数量提示
---@field LimitMaxTips string@限购最大提示
---@field MaxValue number@最大交换数量
---@field MinValue number@最小交换数量
---@field ExchangePercent number@交换滑动条百分比
---@field BtnConfirmName string@确认按钮名称
---@field bNotAdd boolean@是否不可增加
---@field bNotSub boolean@是否不可减少
local ShopExchangeWinVM = LuaClass(UIViewModel)

---Ctor
function ShopExchangeWinVM:Ctor()
    -- Main Part
    --[[self.ShopItemId = 0
    self.ItemName = ""
    self.ShopBuyTypeName = ""
    self.ItemTypeName = ""
    self.IsNeedLongClick = false
    self.IsLimited = false
    self.ToExchangeNum = 0
    self.ToExchangeTips = ""
    self.LimitMaxTips = ""
    self.MaxValue = 1
    self.MinValue = 0
    self.ExchangePercent = 0
    self.BtnConfirmName = ""
    self.IsCanNotAdd = false
    self.IsCanAdd = not self.IsCanNotAdd
    self.IsCanNotSub = true
    self.IsCanSub = not self.IsCanNotSub
    self.IsBuyBtnEnable = true--]]
end

function ShopExchangeWinVM:IsEqualVM(Value)
    return self.CurrencyIsItem == Value.CurrencyIsItem and self.CurrencyIdShow == Value.CurrencyIdShow
end

function ShopExchangeWinVM:InitData()
    self.ShopItemId = 0
    self.ItemName = ""
    self.ShopBuyTypeName = ""
    self.OriginCostList = UIBindableList.New(ShopCostItemVM)
    self.CostList = UIBindableList.New(ShopCostItemVM)
    self.ItemTypeName = ""
    self.CommItemSlotVM = ItemVM.New()
    self.IsNeedLongClick = false
    self.IsLimited = false
    self.ToExchangeNum = 0
    self.ToExchangeTips = ""
    self.LimitMaxTips = ""
    self.MaxValue = 1
    self.MinValue = 0
    self.ExchangePercent = 0
    self.BtnConfirmName = ""
    self.bNotAdd = false
    self.bNotSub = true
    self.TextTipsContent = ""
end

--- 刷新购买子界面数据
---@param Value ShopExchangeWinVM
function ShopExchangeWinVM:UpdateShopExchangeWinVM(Value)
    self.ShopItemId = Value.ShopItemId
    local ItemNameContent = Value.ItemName
    self.ItemName = ItemNameContent
    local ShopBuyTypeName = Value.ShopBuyTypeName
    local ShopBuyTypeNameContent = string.format(LSTR(1200006), ShopBuyTypeName)
    self.ShopBuyTypeName = ShopBuyTypeNameContent
    self.CommItemSlotVM:UpdateVM(Value.CommonItem, {IsCanBeSelected = false, IsShowNum = false})
    local ItemTypeNameContent = Value.ItemTypeName
    self.ItemTypeName = ItemTypeNameContent
    local OriginCostList = self.OriginCostList
    local CostList = Value.CostList
    for i = 1, CostList:Length() do
        local CostItem = CostList:Get(i)
        local CostId = CostItem.CostId
        local IsItem = CostItem.IsItem
        local CostNum = CostItem.CostNum
        local AddElm = ShopCostItemVM.New()
        AddElm.CostId = CostId
        AddElm.IsItem = IsItem
        AddElm.CostNum = CostNum
        AddElm.bClick = false
        OriginCostList:Add(AddElm)
    end

    local ToExchangeNum = Value.ToExchangeNum or 0
    self.ToExchangeNum = ToExchangeNum
    self.bNotSub = ToExchangeNum <= 0

    self:ShowActualCostList()
    self.IsNeedLongClick = Value.IsNeedLongClick

    local MaxValue = Value.MaxValue
    self.MaxValue = MaxValue
    self.ExchangePercent = ToExchangeNum / MaxValue

    local IsLimited = Value.IsLimited
    self.IsLimited = IsLimited
    if IsLimited then
        self.LimitMaxTips = Value.LimitMaxTips
    end

    local ToExchangeTipsContent = string.format(LSTR(1200005), ShopBuyTypeName, ToExchangeNum)
    self.ToExchangeTips = ToExchangeTipsContent
    local BtnConfirmNameContent = Value.ShopBuyTypeNameWithSpace
    self.BtnConfirmName = BtnConfirmNameContent
    self.IsBuyBtnEnable = ToExchangeNum ~= 0
    self.TextTipsContent = Value.TextTipsContent
end

--- 刷新实际显示消耗列表
function ShopExchangeWinVM:ShowActualCostList()
    local List = self.OriginCostList
    if List == nil or List:Length() <= 0 then
        return
    end

    self.CostList:Clear()

    for i = 1, List:Length() do
        local TmpOringinShopCostItemVM = List:Get(i)
        local TmpShopCostItemVM = ShopCostItemVM.New()
        TmpShopCostItemVM:UpdateVM(TmpOringinShopCostItemVM)
        if self.ToExchangeNum ~= 0 then
            TmpShopCostItemVM.CostNum = TmpShopCostItemVM.CostNum * self.ToExchangeNum
        end
        self.CostList:Add(TmpShopCostItemVM)
    end
end

--- 通过滑动条改变交换数量
---@param SliderValueFloat number@滑动条值
function ShopExchangeWinVM:ChangeExchangeNumBySlider(SliderValueFloat)
    self.ExchangePercent = SliderValueFloat
    local NewExchangeNum = math.floor(self.MaxValue * SliderValueFloat)
    self:ChangeExchangeNum(NewExchangeNum)
end

--- 通过增加按钮改变交换数量
function ShopExchangeWinVM:AddExchangeNum()
    local NewExchangeNum = self.ToExchangeNum + 1
    self:ChangeExchangeNum(NewExchangeNum)
    self.ExchangePercent = self.ToExchangeNum / self.MaxValue
end

--- 通过减少按钮改变交换数量
function ShopExchangeWinVM:SubExchangeNum()
    local NewExchangeNum = self.ToExchangeNum - 1
    self:ChangeExchangeNum(NewExchangeNum)
    self.ExchangePercent = self.ToExchangeNum / self.MaxValue
end

--- 改变交换数量
---@param ToExchangeNumParam number@交换数量
function ShopExchangeWinVM:ChangeExchangeNum(ToExchangeNumParam)
    if ToExchangeNumParam < self.MinValue or ToExchangeNumParam > self.MaxValue then
        return
    end

    if ToExchangeNumParam == self.ToExchangeNum then
        return
    end

    self.bNotAdd = ToExchangeNumParam == self.MaxValue
    self.bNotSub = ToExchangeNumParam == self.MinValue

    self.ToExchangeNum = ToExchangeNumParam
    local ToExchangeTipsContent = string.format(LSTR(1200005), self.ShopBuyTypeName, self.ToExchangeNum)
    self.ToExchangeTips = ToExchangeTipsContent
    self.IsBuyBtnEnable = self.ToExchangeNum > 0
    self:ShowActualCostList()
end

return ShopExchangeWinVM
