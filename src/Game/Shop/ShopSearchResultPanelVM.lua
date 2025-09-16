---
--- Author: Alex
--- DateTime: 2023-02-16 10:20:09
--- Description: 商店搜索结果界面数据结构
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIBindableList = require("UI/UIBindableList")
local ShopStuffItemVM = require("Game/Shop/ItemVM/ShopStuffItemVM")
local ShopCurrencyPageVM = require("Game/Shop/ShopCurrencyPageVM")
local ShopCurrencyTipsVM = require("Game/Shop/ShopCurrencyTipsVM")
local ShopExchangeWinVM = require("Game/Shop/ShopExchangeWinVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local GoodsCfg = require("TableCfg/GoodsCfg")
local ShopMgr = require("Game/Shop/ShopMgr")
local ItemTipsVM = require("Game/Item/ItemTipsVM")
local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState
local ScoreCfg = require("TableCfg/ScoreCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ShopDefine = require("Game/Shop/ShopDefine")
local BagMgr = require("Game/Bag/BagMgr")
local FLOG_ERROR = _G.FLOG_ERROR

---@class ShopSearchResultPanelVM : UIViewModel
---@field ShopId number@商店ID
---@field ShopName string@商店名称
---@field SearchInputLastRecord string@搜索输入框上次记录
---@field CurShowShopItemId number@当前选中的商店物品ID
---@field CurShopItemVMList UIBindableList@当前商店商品列表
---@field IsCurrencyPageShow boolean@货币兑换栏是否显示
---@field CurrencyPageVM ShopCurrencyPageVM@货币兑换栏数据结构
---@field ShopCurrencyTipsVM ShopCurrencyTipsVM@货币Tips界面数据结构
---@field ShopExchangeWinVM ShopExchangeWinVM@商店购买子界面数据结构
---@field IsRightItemTipsPanelShow boolean@右侧物品Tips界面是否显示
---@field RightItemTipsPanelVM ItemTipsVM@右侧物品Tips界面数据结构
---@field bBuy boolean@是否可购买
---@field CanNotContent string@不可购买原因
---@field SearchBtnSize FVector2D@搜索按钮大小
local ShopSearchResultPanelVM = LuaClass(UIViewModel)

---Ctor
function ShopSearchResultPanelVM:Ctor()
    -- Main Part
    self.ShopId = 0
    self.ShopName = ""
    self.SearchInputLastRecord = ""
    self.CurShowShopItemId = 0
    self.CurShopItemVMList = UIBindableList.New(ShopStuffItemVM)

    self.IsCurrencyPageShow = false
    self.CurrencyPageVM = ShopCurrencyPageVM.New()

    self.ShopCurrencyTipsVM = ShopCurrencyTipsVM.New()
    self.ShopExchangeWinVM = ShopExchangeWinVM.New()

    self.IsRightItemTipsPanelShow = false
    self.RightItemTipsPanelVM = ItemTipsVM.New()

    self.bBuy = false
    self.CanNotContent = ""
    self.SearchBtnSize = _G.UE.FVector2D(450, 72)
end

function ShopSearchResultPanelVM:IsEqualVM(Value)
    return self.ShopId == Value.ShopId
end

--- 刷新商店搜索结果界面基本数据
---@param Value table@商店搜索结果界面基本数据
function ShopSearchResultPanelVM:UpdateShopSearchPageVM(Value)
    self.ShopId = Value.ShopId
    self.ShopName = Value.ShopName
    self.BuyBtnName = ShopMgr:IsNeedShowBuyOrExchange(self.ShopId, true)
    --self.SearchInputLastRecord = Value.SearchInputLastRecord
end

--- 刷新搜索结果界面商品列表
---@param ShopStuffItemVMs table@商店商品列表数据
function ShopSearchResultPanelVM:UpdateCurShopItemList(ShopStuffItemVMs)
    local CurShopItemVMList = self.CurShopItemVMList
    if nil ~= CurShopItemVMList and CurShopItemVMList:Length() > 0 then
        CurShopItemVMList:Clear()
    end

    local bListDataValid = ShopStuffItemVMs ~= nil and #ShopStuffItemVMs > 0
    self.IsRightItemTipsPanelShow = bListDataValid
    self.IsCurrencyPageShow = bListDataValid

    local SortFunc = ShopMgr.SortShopGoodsPredicate
    for _, v in pairs(ShopStuffItemVMs) do
        local CtorData = v --ShopStuffItemVM.New()
        CurShopItemVMList:AddByValue(CtorData)
    end
    local FirstItem = CurShopItemVMList:Get(1)
    if nil ~= FirstItem then
        FirstItem.IsSelected = true
    end
    CurShopItemVMList:Sort(SortFunc)

    --DefaultSelect
    if self.IsRightItemTipsPanelShow then
        if nil ~= FirstItem then
            self:ShopItemListSelected(FirstItem.ShopItemId, false)
        end
    end
end

--- 选中商品列表的某个商品
---@param ShopItemId number @商品表商品id
function ShopSearchResultPanelVM:ShopItemListSelected(ShopItemId, ByClicked)
    local List = self.CurShopItemVMList
    if nil ~= List and List:Length() > 0 then
        for i = 1, List:Length() do
            local TmpShopItemVM = List:Get(i)
            if nil ~= TmpShopItemVM then
                local IsSelected = TmpShopItemVM.ShopItemId == ShopItemId
                if IsSelected then
                    local TmpCommonItem = ItemUtil.CreateItem(TmpShopItemVM.ItemId, 0)
                    self.RightItemTipsPanelVM:UpdateVM(TmpCommonItem)
                    local ForceBind = TmpShopItemVM.bForceBind
                    self.RightItemTipsPanelVM.IsBind = ForceBind
                    self.RightItemTipsPanelVM.StatusButtonVisible = ForceBind
                    self.CurShowShopItemId = ShopItemId
                    local IsCan, CanNotReason = ShopMgr:IsCanBuy(self.CurShowShopItemId)
                    self.bBuy = IsCan
                    self.CanNotContent = CanNotReason
                    local CostItemList = TmpShopItemVM.CostList
                    local CostItemPlayerHave = {}
                    for j = 1, CostItemList:Length() do
                        local TmpShopCostItemVM = CostItemList:Get(j)
                        if nil ~= TmpShopCostItemVM then
                            table.insert(
                                CostItemPlayerHave,
                                {
                                    CostId = TmpShopCostItemVM.CostId,
                                    IsItem = TmpShopCostItemVM.IsItem,
                                    bShowOnTop = TmpShopCostItemVM.bShowOnTop,
                                    bClick = true,
                                    bActiveByView = false,
                                    OnClickShowTips = function(ParamsData)
                                        self:ShowCurrencyTipsPanel(ParamsData)
                                    end
                                }
                            )
                        end
                    end
                    --FLOG_ERROR("ShopCurrencyPageVM:UpdateCostItemList From ShopSearchResultPanelVM")
                    self.CurrencyPageVM:UpdateCostItemList(CostItemPlayerHave)
                    if UIViewMgr:IsViewVisible(UIViewID.ItemTipsStatus) then
                        UIViewMgr:HideView(UIViewID.ItemTipsStatus)
                    end
                end
                if ByClicked then
                    if TmpShopItemVM.IsSelected ~= IsSelected then
                        TmpShopItemVM.IsSelected = not TmpShopItemVM.IsSelected
                    end
                end
                if TmpShopItemVM.IsSelected then
                    TmpShopItemVM.CheckState = EToggleButtonState.Checked
                else
                    if TmpShopItemVM.bBuy == false then
                        TmpShopItemVM.CheckState = EToggleButtonState.Locked
                    else
                        TmpShopItemVM.CheckState = EToggleButtonState.Unchecked
                    end
                end
            end
        end
    end
end

--- 打开货币tips界面
---@param PanelsParams table @ {IsItem, CostId}
function ShopSearchResultPanelVM:ShowCurrencyTipsPanel(PanelsParams)
    self.ShopCurrencyTipsVM:UpdateShopCurrencyTipsVM(PanelsParams)
    local ParamsSend = {Data = self.ShopCurrencyTipsVM}
    if UIViewMgr:IsViewVisible(UIViewID.ShopCurrencyTipsView) == false then
        UIViewMgr:ShowView(UIViewID.ShopCurrencyTipsView, ParamsSend)
    else
        local CurrencyTipsView = UIViewMgr:FindVisibleView(UIViewID.ShopCurrencyTipsView)
        if nil ~= CurrencyTipsView then
            CurrencyTipsView:SetParams(ParamsSend)
        end
    end
end

--- 找到当前选中的商品具体数据
function ShopSearchResultPanelVM:FindCurShowShopItemDetails()
    local List = self.CurShopItemVMList
    if nil ~= List and List:Length() > 0 then
        for i = 1, List:Length() do
            local TmpShopItemVM = List:Get(i)
            if nil ~= TmpShopItemVM then
                if TmpShopItemVM.ShopItemId == self.CurShowShopItemId then
                    return TmpShopItemVM
                end
            end
        end
    end
end

--- 打开商店购买子界面
function ShopSearchResultPanelVM:ShowExchangeWinPanel()
    local TmpShopStuffItemVM = self:FindCurShowShopItemDetails()
    if TmpShopStuffItemVM == nil then
        return
    end

    local CurOpenMallId = ShopMgr.CurOpenMallId
    local CurGoodsID = TmpShopStuffItemVM.ShopItemId
    local CurGoodsItemID = TmpShopStuffItemVM.ItemId
    local Cfg = ItemCfg:FindCfgByKey(CurGoodsItemID)
    local ShopItemCfg = GoodsCfg:FindCfgByKey(CurGoodsID)
    if nil == Cfg or nil == ShopItemCfg then
        return
    end

    local ExchangeName = ShopMgr:IsNeedShowBuyOrExchange(CurOpenMallId)
    local ExchangeNameWithSpace = ShopMgr:IsNeedShowBuyOrExchange(CurOpenMallId, true)
    local CostEnoughMax, IsItem, NeedId = ShopMgr:GoodsMaxNumCanBuy(CurGoodsID)
    if CostEnoughMax <= 0 then
        local CostCfg = IsItem and ItemCfg:FindCfgByKey(NeedId) or ScoreCfg:FindCfgByKey(NeedId)
        if CostCfg then
            local CostName = CostCfg.ItemName or ""
            local TipsToShow = string.format(LSTR(1200003), CostName, ExchangeName)
            MsgTipsUtil.ShowTips(TipsToShow)
        else
            FLOG_ERROR("ShopSearchResultPanelVM:ShowExchangeWinPanel CostCfg is nil")
        end
        return
    end

    local LeftBagNum = BagMgr:GetBagLeftNum()
    if LeftBagNum <= 0 then
        local TipsToShow = string.format(LSTR(1200074), ExchangeName)
        MsgTipsUtil.ShowTips(TipsToShow)
        return
    end

    local LimitNum = ShopMgr:GoodsRemainNumCanBuy(CurGoodsID)
    local bCanUse, ExchangeTips = ShopMgr:IsCanUse(CurGoodsID)
    local TmpCommonItem = ItemUtil.CreateItem(CurGoodsItemID, 0)
    local TableShopExchangeWinVM = {
        ShopItemId = CurGoodsID,
        ItemName = ItemCfg:GetItemName(CurGoodsItemID),
        CommonItem = TmpCommonItem,
        ItemTypeName = ItemTypeCfg:GetTypeName(Cfg.ItemType),
        CostList = TmpShopStuffItemVM.CostList,
        IsDiscount = ShopMgr:GoodsIsDiscount(CurOpenMallId, CurGoodsID),
        DiscountCount = ShopItemCfg.Discount,
        ShopBuyTypeName = ExchangeName,
        ShopBuyTypeNameWithSpace = ExchangeNameWithSpace,
        IsNeedLongClick = not bCanUse,
        MaxValue = LimitNum ~= -1 and math.min(CostEnoughMax, LimitNum) or CostEnoughMax,
        IsLimited = TmpShopStuffItemVM.IsBuyLimit,
        TextTipsContent = ExchangeTips or "",
    }
    if TableShopExchangeWinVM.IsLimited then
        TableShopExchangeWinVM.LimitMaxTips = ShopDefine.LimitBuyNumTipsTitle[ShopItemCfg.RestrictionType] .. LimitNum
    end
    TableShopExchangeWinVM.ToExchangeNum = TableShopExchangeWinVM.MaxValue > 0 and 1 or 0
    self.ShopExchangeWinVM:InitData()
    self.ShopExchangeWinVM:UpdateShopExchangeWinVM(TableShopExchangeWinVM)
    self.CurrencyPageVM:ChangeCanSelectState(false)
    if UIViewMgr:IsViewVisible(UIViewID.ShopExchangeWinView) == false then
        UIViewMgr:ShowView(UIViewID.ShopExchangeWinView, {Data = self.ShopExchangeWinVM})
    end
end

--- 刷新限时道具的时间显示
function ShopSearchResultPanelVM:UpdateShopItemListTimeLimitShow()
    local CurGoodsList = self.CurShopItemVMList
    for i = 1, CurGoodsList:Length() do
        local VM = CurGoodsList:Get(i)
        VM:UpdateLimitTimeShow()
    end
end

return ShopSearchResultPanelVM
