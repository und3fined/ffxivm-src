---
--- Author: Alex
--- DateTime: 2023-02-09 19:01:57
--- Description: 商品详情数据结构
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ShopCostItemVM = require("Game/Shop/ItemVM/ShopCostItemVM")
local ShopSaleTagItemVM = require("Game/Shop/ItemVM/ShopSaleTagItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local ItemCfg = require("TableCfg/ItemCfg")
--local ScoreCfg = require("TableCfg/ScoreCfg")
local BagMgr = require("Game/Bag/BagMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ShopDefine = require("Game/Shop/ShopDefine")
local TimeUtil = require("Utils/TimeUtil")
--local ProtoRes = require("Protocol/ProtoRes")
--local SCORE_TYPE = ProtoRes.SCORE_TYPE
local GoodsCfg = require("TableCfg/GoodsCfg")
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState

---@class ShopStuffItemVM : UIViewModel
---@field ShopItemId number @商品ID
---@field ItemId number @物品表ID
---@field ShopItemName string @商品名称
---@field CostList UIBindableList @消耗列表
---@field BuyDiscountInfoList UIBindableList @购买折扣信息列表
---@field bShowDiscount boolean @是否显示折扣
---@field bDiscount boolean @是否折扣
---@field DiscountCount number @折扣数
---@field OriginCostNum number @原价
---@field CommItemSlotVM ItemVM @物品槽
---@field IsSelected boolean @是否选中
---@field CheckState EToggleButtonState @选中状态
---@field IsBuyLimit boolean @是否有购买限制
---@field BuyLimitText string @购买限制文本
---@field IsHotSaleTagShow boolean @是否显示热卖标签
---@field HotSaleTagText string @热卖标签文本
---@field IsSoldOut boolean @是否售罄
---@field bBuy boolean @是否可购买
---@field CanNotBuyReason string @不能购买原因
---@field StartTime number @限时折扣开始时间
---@field EndTime number @限时折扣结束时间
---@field UpdateTimeLimitSwitch boolean @是否更新限时折扣
local ShopStuffItemVM = LuaClass(UIViewModel)

---Ctor
function ShopStuffItemVM:Ctor()
    -- Main Part
    self.ShopItemId = 0
    self.ItemId = 0
    self.ShopItemName = ""
    self.CostList = UIBindableList.New(ShopCostItemVM)
    self.BuyDiscountInfoList = UIBindableList.New(ShopSaleTagItemVM)
    self.bShowDiscount = false
    self.bDiscount = false
    self.DiscountCount = 100
    self.OriginCostNum = 0
    self.CommItemSlotVM = ItemVM.New()
    self.IsSelected = false
    self.CheckState = EToggleButtonState.Unchecked
    self.IsBuyLimit = false
    self.BuyLimitText = ""
    self.IsHotSaleTagShow = false
    self.HotSaleTagText = ""
    self.IsSoldOut = false
    self.bBuy = true
    self.bUse = true
    self.CanNotBuyReason = ""
    self.StartTime = 0
    self.EndTime = 0
    self.UpdateTimeLimitSwitch = false

    self.bForceBind = false --是否强制绑定
end

function ShopStuffItemVM:IsEqualVM(Value)
    return self.ShopItemId == Value.ShopItemId
end

function ShopStuffItemVM:UpdateVM(Value)
    self:UpdateItemShow(Value)
end

function ShopStuffItemVM:UpdateItemShow(Value)
    local ShopItemId = Value.ShopItemId
    self.ShopItemId = ShopItemId
    local ItemID = Value.ItemId
    self.ItemId = ItemID 
    local Cfg = ItemCfg:FindCfgByKey(ItemID)
    if nil == Cfg then
        FLOG_ERROR("ItemVM:UpdateVM can't find item cfg, ResID =%d", ItemID)
        return
    end

    local ShopItemNameContent = ItemCfg:GetItemName(ItemID)
    self.ShopItemName = ShopItemNameContent
    self.bDiscount = Value.IsDiscount
    self.bShowDiscount = Value.IsShowDiscount
    self.DiscountCount = Value.DiscountCount
    local StartTime = Value.StartTime
    local EndTime = Value.EndTime
    self.StartTime = StartTime
    self.EndTime = EndTime
    if StartTime and StartTime > 0 and EndTime and EndTime > 0 then
        self.UpdateTimeLimitSwitch = true
    end

    local CostList = Value.CostList
    if nil ~= CostList then
        local FirstCostItem = CostList[1]
        if FirstCostItem then
            self.OriginCostNum = FirstCostItem.CostNum --折扣商品只会使用单一货币
        end
    end

    self.IsHotSaleTagShow = Value.IsHotSaleTagShow
    self.HotSaleTagText = Value.HotSaleTagText
    self:CreateBuyDiscountInfoList(EndTime)
    self:CreateCostList(CostList)
    self.bBuy = Value.bBuy
    self.bUse = Value.bUse

    local CanNotBuyReason = Value.CanNotBuyReason
    self.CanNotBuyReason = CanNotBuyReason

    local IsBuyLimit = Value.IsBuyLimit
    self.IsBuyLimit = IsBuyLimit
    if IsBuyLimit then
        local TypeText = ShopDefine.LimitBuyType[Value.BuyLimitType]
        local MaxCanBuy = Value.MaxCanBuy
        local RemainNum = MaxCanBuy - Value.CountHaveBuy
        self.IsSoldOut = RemainNum <= 0
        if RemainNum > 0 then
            self.BuyLimitText = string.format("%s：%d/%d", TypeText, RemainNum, MaxCanBuy)
        else
            self.BuyLimitText = LSTR(1200032)
        end
    else
        self.BuyLimitText = ""
    end
    local item = ItemUtil.CreateItem(ItemID, 0)
    self.CommItemSlotVM:UpdateVM(item, {IsCanBeSelected = false, IsShowNum = false})
    self.IsSelected = Value.IsSelected

    --是否强制绑定
    local GCfg = GoodsCfg:FindCfgByKey(ShopItemId)
    if GCfg == nil then
        return
    end
    self.bForceBind = GCfg.DefaultBinding ~= 0
end

function ShopStuffItemVM:CreateCostList(CostList)
    local CostListVMs = self.CostList
    if nil ~= CostListVMs and CostListVMs:Length() > 0 then
        CostListVMs:Clear()
    end

    if CostList == nil or next(CostList) == nil then
        return
    end

    for i = 1, #CostList do
        local v = CostList[i]
        local CostId = v.CostId
        local CostNum = v.CostNum
        local CostItemVM = {}
        CostItemVM.CostId = CostId
        local ActualCostNum = math.ceil(self.bDiscount and CostNum * self.DiscountCount / 100 or CostNum)
        CostItemVM.CostNum = ActualCostNum

        local IsItem = v.IsItem
        CostItemVM.IsItem = IsItem
        if IsItem then
            local HaveItemNum = BagMgr:GetItemNum(CostId) or 0
            CostItemVM.IsEnough = HaveItemNum >= ActualCostNum
        else
            local HaveScoreNum = ScoreMgr:GetScoreValueByID(CostId) or 0
            CostItemVM.IsEnough = HaveScoreNum >= ActualCostNum
        end
        CostItemVM.bShowOnTop = v.bShowOnTop
        CostListVMs:AddByValue(CostItemVM)
    end
end

function ShopStuffItemVM:CreateBuyDiscountInfoList(EndTime)
    if nil ~= self.BuyDiscountInfoList and self.BuyDiscountInfoList:Length() > 0 then
        self.BuyDiscountInfoList:Clear()
    end

    if EndTime > 0 then
        local ServerTime = TimeUtil.GetServerTime() --秒
        local RemainSeconds = EndTime - ServerTime
        local DayCostSec = 24 * 60 * 60
        local RemainDay = math.ceil(RemainSeconds / DayCostSec)
        if RemainDay > 0 then
            local SaleTagItemVMLimitTime = ShopSaleTagItemVM.New()
            SaleTagItemVMLimitTime.Content = string.format(LSTR(1200017), RemainDay)
            self.BuyDiscountInfoList:Add(SaleTagItemVMLimitTime)
        end
    end

    if self.bDiscount then
        local SaleTagItemVMDiscount = ShopSaleTagItemVM.New()
        SaleTagItemVMDiscount.Content = string.format(LSTR(1200002), math.floor(self.DiscountCount / 10))
        self.BuyDiscountInfoList:Add(SaleTagItemVMDiscount)
    end
end

function ShopStuffItemVM:UpdateLimitTimeShow()
    if self.UpdateTimeLimitSwitch == false then --更新开关关闭（非限时，或已脱离限时结束时间）
        return
    end

    local Cfg = GoodsCfg:FindCfgByKey(self.ShopItemId)
    if Cfg == nil then
        return
    end

    local ServerTime = TimeUtil.GetServerTime()
    local StartTime = self.StartTime
    local EndTime = self.EndTime

    if ServerTime < StartTime then --限时未开始，不更新
        return
    end

    local CostList = self.CostList
    local CfgDiscount = Cfg.Discount

    if ServerTime > EndTime then --限时已结束，更新为非限时
        self.UpdateTimeLimitSwitch = false
        self.bDiscount = false
        self.bShowDiscount = false
        self.BuyDiscountInfoList:Clear(true)
        for i = 1, CostList:Length() do
            local CostVM = CostList:Get(i)
            if CostVM ~= nil then
                local CostId = CostVM.CostId
                local CostNum = CostVM.CostNum or 0
                local ActualCostNum = CostNum * 100 / CfgDiscount
                CostVM.CostNum = ActualCostNum
                if CostVM.IsItem then
                    local HaveItemNum = BagMgr:GetItemNum(CostId) or 0
                    CostVM.IsEnough = HaveItemNum >= ActualCostNum
                else
                    local HaveScoreNum = ScoreMgr:GetScoreValueByID(CostId) or 0
                    CostVM.IsEnough = HaveScoreNum >= ActualCostNum
                end
            end
        end
        return
    end

    --时间变化，更新剩余时间
    local RemainSeconds = EndTime - ServerTime
    local DayCostSec = 24 * 60 * 60
    local RemainDay = math.ceil(RemainSeconds / DayCostSec)
    local ContentShow = string.format(LSTR(1200017), RemainDay)
    if RemainDay > 0 then
        local TimeSaleTagItemVM = self.BuyDiscountInfoList:Get(1)
        if TimeSaleTagItemVM ~= nil and TimeSaleTagItemVM.Content ~= ContentShow then
            TimeSaleTagItemVM.Content = ContentShow
        end
    end

    --折扣变化，更新折扣
    local bCfgIsDiscount = CfgDiscount > 0 and CfgDiscount < 100
    local DiscountChange = self.bDiscount ~= bCfgIsDiscount
    if DiscountChange then
        for i = 1, CostList:Length() do
            local CostVM = CostList:Get(i)
            if CostVM ~= nil then
                local CostId = CostVM.CostId
                local CostNum = CostVM.CostNum or 0
                local ActualCostNum = CostNum * CfgDiscount / 100
                CostVM.CostNum = ActualCostNum
                if CostVM.IsItem then
                    local HaveItemNum = BagMgr:GetItemNum(CostId) or 0
                    CostVM.IsEnough = HaveItemNum >= ActualCostNum
                else
                    local HaveScoreNum = ScoreMgr:GetScoreValueByID(CostId) or 0
                    CostVM.IsEnough = HaveScoreNum >= ActualCostNum
                end
            end
        end
        self.bDiscount = true
    end
end

return ShopStuffItemVM
