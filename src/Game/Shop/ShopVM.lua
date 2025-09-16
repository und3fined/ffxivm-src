---
--- Author: Alex
--- DateTime: 2023-02-03 18:28:17
--- Description: 商店系统
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIBindableList = require("UI/UIBindableList")
local ShopTabItemVM = require("Game/Shop/ItemVM/ShopTabItemVM")
--local ShopSubTabItemVM = require("Game/Shop/ItemVM/ShopSubTabItemVM")
local ShopFilterSortVM = require("Game/Shop/ShopFilterSortVM")
--local ShopFilterItemVM = require("Game/shop/ItemVM/ShopFilterItemVM")
local ShopStuffItemVM = require("Game/Shop/ItemVM/ShopStuffItemVM")
local ShopCurrencyPageVM = require("Game/Shop/ShopCurrencyPageVM")
local ShopCurrencyTipsVM = require("Game/Shop/ShopCurrencyTipsVM")
local ShopExchangeWinVM = require("Game/Shop/ShopExchangeWinVM")
local ShopSearchPageVM = require("Game/Shop/ShopSearchPageVM")
local ShopSearchResultPanelVM = require("Game/Shop/ShopSearchResultPanelVM")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsVM = require("Game/Item/ItemTipsVM")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local EToggleButtonState = _G.UE.EToggleButtonState
local ShopDefine = require("Game/Shop/ShopDefine")
local ShopMgr = require("Game/Shop/ShopMgr")
local BagMgr = require("Game/Bag/BagMgr")
--local SCORE_TYPE = ProtoRes.SCORE_TYPE
local GoodsCfg = require("TableCfg/GoodsCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local MallCfg = require("TableCfg/MallCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local FILTER_MAINTYPE = ShopDefine.FILTER_MAINTYPE
local GoodsPriceType = ProtoRes.GoodsPriceType
local GoodsAdvType = ProtoRes.GoodsAdvType
local MainSortInfo = ShopDefine.MainSortInfo
---@class ShopVM : UIViewModel
---@field ShopId number @商店id
---@field ShopName string @商店名称
---@field AllShopTabVMList table @商店页签数据
---@field CurShopItemVMList table @当前商店展示商品列表数据
---@field CurShowShopItemId number @当前商店选中商品id
---@field SecondSelectedBtnIsShow boolean @第二行筛选器开关按钮是否显示
---@field IsCurrencyPageShow boolean @货币兑换栏是否显示
---@field CurrencyPageVM ShopCurrencyPageVM @货币兑换栏数据
---@field bBuy boolean @是否可购买
---@field CanNotContent string @不可购买原因
---@field EnableSearch boolean @是否开启搜索
---@field SearchBtnSize UE.FVector2D @唤起搜索界面按钮大小
local ShopVM = LuaClass(UIViewModel)

---Ctor
function ShopVM:Ctor()
    -- Main Part
    self.IsValid = false
    self.ShopId = 0
    self.CurShowShopItemId = 0
    self.ShopName = ""
    self.BuyBtnName = ""
    self.SearchInputLastRecord = ""
    self.AllShopTabVMList = UIBindableList.New(ShopTabItemVM)
    self.CurShopItemVMList = UIBindableList.New(ShopStuffItemVM)

    self.IsCurrencyPageShow = false
    self.CurrencyPageVM = ShopCurrencyPageVM.New()

    self.ShopCurrencyTipsVM = ShopCurrencyTipsVM.New()
    self.ShopExchangeWinVM = ShopExchangeWinVM.New()
    self.ShopSearchPageVM = ShopSearchPageVM.New()
    self.ShopSearchResultPanelVM = ShopSearchResultPanelVM.New()

    self.IsRightItemTipsPanelShow = false
    self.RightItemTipsPanelVM = ItemTipsVM.New()

    self.bBuy = false
    self.CanNotContent = ""

    self.ToggleBtnMSIsChecked = false
    self.ToggleBtnMSSortVM = ShopFilterSortVM.New()
    self.TextMainSort = ""

    self.ToggleBtnVSIsChecked = false
    self.ToggleBtnVSSortVM = ShopFilterSortVM.New()
    self.TextViceSort = ""

    self.ToggleBtnMFIsChecked = false
    self.SecondSelectedBtnIsShow = false
    self.BtnQSIsChecked = false
    self.BtnQSSortVM = ShopFilterSortVM.New()
    self.TextQuality = ""

    self.BtnLSIsChecked = false
    self.BtnLSSortVM = ShopFilterSortVM.New()
    self.TextLevel = ""

    self.BtnRSIsChecked = false
    self.BtnRSSortVM = ShopFilterSortVM.New()
    self.TextRole = ""

    self.EnableSearch = true
    self.SearchBtnSize = _G.UE.FVector2D(450, 72)
end

--- 更新商店基本信息
---@param Value table @商店基本信息
function ShopVM:UpdateMallBaseData(Value)
    local IsValid = nil ~= Value
    self.IsValid = IsValid

    if not IsValid then
        return
    end

    local ShopId = Value.ShopId
    self.ShopId = ShopId
    local mCfg = MallCfg:FindCfgByKey(ShopId)
    if mCfg == nil then
        return
    end
    self.EnableSearch = mCfg.EnableSearch
    self.ShopName = Value.ShopName
    self.BuyBtnName = ShopMgr:IsNeedShowBuyOrExchange(ShopId, true)
end

--- end

--- 主分类筛选器变化时刷新副分类筛选器列表
---@param detailFilterName string@筛选项名称
---@param MainFilterIndex number@筛选项索引
function ShopVM:RefreshVSFilterListItems(detailFilterName, MainFilterIndex)
    ---不是主分类筛选器选中项变化时，不需要刷新副分类
    if MainFilterIndex ~= FILTER_MAINTYPE.MainSortType then
        return
    end

    local ToggleBtnVSSortVM = self.ToggleBtnVSSortVM
    if ToggleBtnVSSortVM then
        ---主分类选中项为全部，副分类选项列表只有“全部”选择项
        self.ToggleBtnVSIsChecked = false
        local ParentIndex = FILTER_MAINTYPE.ViceSortType
        local ParentName = ShopDefine.ShopFilterName[ParentIndex]
        if detailFilterName == LSTR(1200015) then
            self.TextViceSort = LSTR(1200015)
            ToggleBtnVSSortVM:CreateFilterList(
                {
                    {
                        ParentName = ParentName,
                        ParentIndex = ParentIndex,
                        TabName = LSTR(1200015),
                        IsSelected = false
                    }
                }
            )
        else
            --- 主分类选中项不为全部，副分类选项列表为主分类选中项的副分类列表
            local CurSubTabFilterData = ShopMgr:FindCurSubTabsFilterData()
            local ViceSortFilterData = CurSubTabFilterData[ParentIndex]
            local ShopFilterItemVMs = {}
            for j = 1, #ViceSortFilterData do
                local FilterData = ViceSortFilterData[j]
                local ItemMainType = FilterData.ItemMainTypeEnum
                local TmpMainSortInfo =
                    table.find_by_predicate(
                    MainSortInfo,
                    function(v)
                        return v.Type == ItemMainType
                    end
                )
                if TmpMainSortInfo then
                    local MainTypeName = TmpMainSortInfo.Name or ""
                    if MainTypeName == detailFilterName then
                        table.insert(
                            ShopFilterItemVMs,
                            {
                                ParentName = ParentName,
                                ParentIndex = ParentIndex,
                                TabName = FilterData.Content,
                                IsSelected = false
                            }
                        )
                    end
                end
            end
            ToggleBtnVSSortVM:CreateFilterList(ShopFilterItemVMs)
        end
    end
end
--- func 筛选器筛选回调
---@param MainFilterName string @所属大类
---@param detailFilterName string @s筛选项名称
---@param MainFilterIndex number @所属大类索引
function ShopVM:UpdateShopItemListAfterFiltered(MainFilterName, detailFilterName, MainFilterIndex)
    if MainFilterIndex == FILTER_MAINTYPE.MainSortType then
        self.ToggleBtnMSIsChecked = false
        self.TextMainSort = detailFilterName
    elseif MainFilterIndex == FILTER_MAINTYPE.ViceSortType then
        self.ToggleBtnVSIsChecked = false
        self.TextViceSort = detailFilterName
    elseif MainFilterIndex == FILTER_MAINTYPE.ItemQuality then
        self.BtnQSIsChecked = false
        self.TextQuality = detailFilterName
    elseif MainFilterIndex == FILTER_MAINTYPE.UseLevel then
        self.BtnLSIsChecked = false
        self.TextLevel = detailFilterName
    elseif MainFilterIndex == FILTER_MAINTYPE.Job then
        self.BtnRSIsChecked = false
        self.TextRole = detailFilterName
    end
    self:RefreshVSFilterListItems(detailFilterName, MainFilterIndex)
    ShopMgr:RecordCurFilterChange(MainFilterName, detailFilterName)
end

--- 查找当前商品列表选中项的具体信息
function ShopVM:FindCurShowShopItemDetails()
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

--- 更新商店二级页签
---@param MainTabVM table @一级页签VM
---@param ChildList table @二级页签列表
function ShopVM:UpdateChildTabs(MainTabVM, ChildList)
    local MainTabList = MainTabVM.MemList
    local MainTabName = MainTabVM.TabName
    MainTabList:Clear()

    local bIsAllNotSelected = true
    for _, cv in ipairs(ChildList) do
        local ChildElem = cv
        local SubTabName = ChildElem.TabName
        local ChildCtorData = {
            ParentName = MainTabName,
            TabName = SubTabName
        } --ShopSubTabItemVM.New()
        --ChildCtorData.ParentName = MainTabName
        --ChildCtorData.TabName = SubTabName
        local IsSelected = ChildElem.IsSelected
        if IsSelected == nil then
            ChildCtorData.IsSelected = false
        else
            ChildCtorData.IsSelected = IsSelected
            if IsSelected == true then
                bIsAllNotSelected = false
            end
        end
        --ChildCtorData:UpdateTabColor()
        MainTabList:AddByValue(ChildCtorData, nil, false)
    end

    --如果全未选中，则默认选中第一项
    if bIsAllNotSelected == true then
        local FirstChildTab = MainTabList:Get(1)
        FirstChildTab.IsSelected = true
        FirstChildTab:UpdateTabColor()
    end
end

--- 更新商店页签
---@param ShopTabVMLists table @页签列表
function ShopVM:UpdateAllLeftTabs(ShopTabVMLists)
    local AllShopTabVMList = self.AllShopTabVMList
    AllShopTabVMList:Clear(false)
    local ScrollToIndex
    local MainTabIndex = 0
    local SubTabIndex = 0
    for Index, v in ipairs(ShopTabVMLists) do
        local Elem = v
        local TabName = Elem.TabName
        local IsSelected = Elem.IsSelected
        local IsAutoExpand = Elem.IsAutoExpand
        local CtorData = ShopTabItemVM.New()
        CtorData.TabName = TabName
        CtorData.IsSelected = IsSelected
        CtorData.bShowSelectedState = IsSelected
        CtorData.IsAutoExpand = IsAutoExpand
        CtorData:UpdateTabColor()
        --CtorData.NameColorText = CtorData.IsSelected and "e7ca85ff" or "2b2b2bff"
        if IsSelected then
            MainTabIndex = Index
        end
        if IsAutoExpand then
            self:UpdateChildTabs(CtorData, Elem.ChildList)
            local ChildTabVMs = CtorData.MemList
            if ChildTabVMs ~= nil then
                local ChildLen = ChildTabVMs:Length()
                if ChildLen > 0 then
                    for i = 1, ChildLen do
                        local ChildTabVM = ChildTabVMs:Get(i)
                        if ChildTabVM ~= nil then
                            if ChildTabVM.IsSelected then
                                SubTabIndex = i
                                break
                            end
                        end
                    end
                end
            end--]]
        else
            CtorData.MemList:Clear()
        end
        AllShopTabVMList:Add(CtorData)
    end

    if SubTabIndex == 1 then
        ScrollToIndex = MainTabIndex
    else
        ScrollToIndex = MainTabIndex + SubTabIndex
    end

    if ScrollToIndex ~= 0 then
        EventMgr:SendEvent(EventID.ScrollToSelectedTab, ScrollToIndex)
    end
end

--- 刷新商店商品列表
---@param ShopStuffItemVMs table @商品列表
function ShopVM:UpdateCurShopItemList(ShopStuffItemVMs)
    local CurShopItemVMList = self.CurShopItemVMList
    if nil ~= CurShopItemVMList and CurShopItemVMList:Length() > 0 then
        CurShopItemVMList:Clear()
    end
    local SelectedShopItemId = 0
    local SortFunc = ShopMgr.SortShopGoodsPredicate
    for _, v in pairs(ShopStuffItemVMs) do
        local Elem = v
        local CtorData = v --ShopStuffItemVM.New()
        --CtorData:UpdateItemShow(Elem)
        CurShopItemVMList:AddByValue(CtorData, SortFunc, false)
        if Elem.IsSelected == true then
            SelectedShopItemId = Elem.ShopItemId
        end
    end

    -- 排序逻辑从数据层移到了VM层，所以选中状态也要在VM层处理
    if SelectedShopItemId == 0 then
        local FirstShopItemVM = CurShopItemVMList:Get(1)
        if FirstShopItemVM then
            -- body
            FirstShopItemVM.IsSelected = true
            SelectedShopItemId = FirstShopItemVM.ShopItemId or 0
        end
    end

    self.IsRightItemTipsPanelShow = CurShopItemVMList ~= nil and CurShopItemVMList:Length() > 0
    --self.IsCurrencyPageShow = CurShopItemVMList ~= nil and CurShopItemVMList:Length() > 0
    --DefaultSelect
    if self.IsRightItemTipsPanelShow then
        self:ShopItemListSelected(SelectedShopItemId, false)
    end
    --]]
end

--- 更新商店商品列表数据
---@param ServerGoodsInfo table @商品服务器数据
function ShopVM:UpdateShopItemListData(ServerGoodsInfo)
    local CurSelectedItemId = ShopMgr.LastSelectState[ShopMgr.CurOpenMallId].GoodsId
    local ShopStuffItemVMs = {}
    if nil ~= next(ServerGoodsInfo) then
        for i = 1, #ServerGoodsInfo do
            local GoodsInfo = ServerGoodsInfo[i]
            local GoodsID = GoodsInfo.GoodsId
            local Cfg = GoodsCfg:FindCfgByKey(GoodsID)
            if nil ~= Cfg then
                local ShopStuffItemUpdateVal = {}
                ShopStuffItemUpdateVal.ShopItemId = GoodsID
                local ItemID = ShopMgr:GetGoodsItemID(GoodsID)
                ShopStuffItemUpdateVal.ItemId = ItemID
                local IsSilverCoinValid, SilverCostList = ShopMgr:GetGoodsCostBySilverCoin(GoodsID)
                local CfgPrice = IsSilverCoinValid and SilverCostList or Cfg.Price
                ShopStuffItemUpdateVal.CostList = {}
                for j = 1, #CfgPrice do
                    local TmpPrice = CfgPrice[j]
                    local bShow = TmpPrice.Show
                    local PriceType = TmpPrice.Type
                    if PriceType ~= GoodsPriceType.GOODS_PRICE_TYPE_Invalid then
                        local CostItemVM = {}
                        CostItemVM.CostId = TmpPrice.ID
                        CostItemVM.CostNum = TmpPrice.Count
                        CostItemVM.IsItem = PriceType == GoodsPriceType.GOODS_PRICE_TYPE_ITEM --GoodsPriceType.GOODS_PRICE_TYPE_ITEM
                        CostItemVM.bShowOnTop = bShow
                        table.insert(ShopStuffItemUpdateVal.CostList, CostItemVM)
                    end
                end
                ShopStuffItemUpdateVal.IsDiscount = ShopMgr:GoodsIsDiscount(Cfg.MallID, GoodsID)
                ShopStuffItemUpdateVal.IsShowDiscount = Cfg.ShowDiscount and ShopStuffItemUpdateVal.IsDiscount
                ShopStuffItemUpdateVal.DiscountCount = GoodsInfo.Discount
                local RestrictionType = Cfg.RestrictionType
                ShopStuffItemUpdateVal.IsBuyLimit = RestrictionType ~= ProtoRes.COUNTER_TYPE.COUNTER_TYPE_NONE
                ShopStuffItemUpdateVal.BuyLimitType = RestrictionType
                ShopStuffItemUpdateVal.MaxCanBuy = Cfg.RestrictionCount
                ShopStuffItemUpdateVal.CountHaveBuy = GoodsInfo.BoughtCount
                ShopStuffItemUpdateVal.StartTime = GoodsInfo.DiscountDurationStart
                ShopStuffItemUpdateVal.EndTime = GoodsInfo.DiscountDurationEnd
                local AdvType = Cfg.AdvType
                ShopStuffItemUpdateVal.IsHotSaleTagShow = AdvType ~= GoodsAdvType.GOODS_ADV_TYPE_None --GoodsAdvType.GOODS_ADV_TYPE_None
                ShopStuffItemUpdateVal.HotSaleTagText = ShopDefine.AdvType[AdvType]
                local IsCan, CanNotReason = ShopMgr:IsCanBuy(GoodsID)
                ShopStuffItemUpdateVal.bBuy = IsCan
                ShopStuffItemUpdateVal.bUse = ShopMgr:IsCanUse(GoodsID)
                ShopStuffItemUpdateVal.CanNotBuyReason = CanNotReason
                if CurSelectedItemId ~= nil and CurSelectedItemId > 0 then
                    ShopStuffItemUpdateVal.IsSelected = CurSelectedItemId == ShopStuffItemUpdateVal.ShopItemId
                else
                    ShopStuffItemUpdateVal.IsSelected = false
                end
                table.insert(ShopStuffItemVMs, ShopStuffItemUpdateVal)
            end
        end
    end
    self:UpdateCurShopItemList(ShopStuffItemVMs)
end

--- 根据当前选中页签及筛选器初始化商店商品列表
function ShopVM:UpdateShopItemListByTab()
    local CurTabGoodsInfo = ShopMgr:GetGoodsInfoByTabNameAndFilterData()
    self:UpdateShopItemListData(CurTabGoodsInfo)
end

--- 刷新限时道具的时间显示
function ShopVM:UpdateShopItemListTimeLimitShow()
    local CurGoodsList = self.CurShopItemVMList
    for i = 1, CurGoodsList:Length() do
        local VM = CurGoodsList:Get(i)
        VM:UpdateLimitTimeShow()
    end
end

function ShopVM:UpdateSubTabView(bSelctedTab, MainTabVM)
    local TabsDatas = ShopMgr:FindShopTabVMs(self.ShopId)
    if TabsDatas == nil or next(TabsDatas) == nil then
        FLOG_ERROR("ShopVM:UpdateSubTabView", "ShopTabDatas is nil")
        return
    end

    if MainTabVM == nil then
        FLOG_ERROR("ShopVM:UpdateSubTabView", "MainTabVM is nil")
        return
    end

    if bSelctedTab == true then
        local SelectedMainTabName = MainTabVM.TabName
        local MainTabData = table.find_by_predicate(
            TabsDatas, function (e)
                return e.TabName == SelectedMainTabName
            end
        )
        if MainTabData then
            local ChildList = MainTabData.ChildList
            if ChildList then
                self:UpdateChildTabs(MainTabVM, ChildList)
                local ChildTabListVM = MainTabVM.MemList
                for j = 1, ChildTabListVM:Length() do
                    local ChildTabVM = ChildTabListVM:Get(j)
                    if ChildTabVM then
                        -- 将VM中的选中状态同步到数据中
                        local SubTabData = table.find_by_predicate(
                            ChildList, function (e)
                                return e.TabName == ChildTabVM.TabName
                            end
                        )
                        if SubTabData then
                            SubTabData.IsSelected = ChildTabVM.IsSelected
                        end
                        -- 刷新商品列表数据
                        if ChildTabVM.IsSelected then
                            local CurMallID = ShopMgr.CurOpenMallId
                            ShopMgr:StoreLastSelectedGoodsIdBase(CurMallID, 0, SelectedMainTabName, ChildTabVM.TabName)
                            --[[local LastSelectRecord = ShopMgr.LastSelectState
                            if LastSelectRecord ~= nil then
                                local LastSelectState = LastSelectRecord[CurMallID] or {}
                                LastSelectState.GoodsId = 0
                                LastSelectState.MainTab = SelectedMainTabName
                                LastSelectState.SubTab = ChildTabVM.TabName
                                LastSelectRecord[CurMallID] = LastSelectState
                            end--]]
                            local MainShopPanel = UIViewMgr:FindVisibleView(UIViewID.ShopMainPanelView)
                            if MainShopPanel ~= nil then
                                MainShopPanel:ControlTheFilterShow(MainShopPanel.Data.FilterShow)
                            end
                            self:UpdateShopItemListByTab()
                            break
                        end
                    end
                end
            end
        end
    else
        MainTabVM.MemList:Clear()
    end
end

--(6.12修改页签切换逻辑)
--- 一级页签切换
---@param TabName string @一级页签名称
function ShopVM:LeftTabsMainTabExpandChange(TabName)
    local TabsDatas = ShopMgr:FindShopTabVMs(self.ShopId)
    if TabsDatas == nil or next(TabsDatas) == nil then
        return
    end

    local AllShopTabVMList = self.AllShopTabVMList
    if AllShopTabVMList == nil or AllShopTabVMList:Length() <= 0 then
        return
    end

    for i = 1, AllShopTabVMList:Length() do
        local TabVM = AllShopTabVMList:Get(i)
        if TabVM then
            local bSelctedTab = TabVM.TabName == TabName
            if TabVM.IsSelected ~= bSelctedTab then
                -- tab原本的选中状态与当前选中状态不一致时，更新选中状态
                TabVM.IsSelected = bSelctedTab
                TabVM.bShowSelectedState = bSelctedTab
                TabVM:UpdateTabColor()
                self:UpdateSubTabView(bSelctedTab, TabVM)
            else
                -- tab原本的选中状态与当前选中状态一致时，如果为已选中状态，则刷新子页签列表
                if bSelctedTab == true then
                    TabVM.bShowSelectedState = true
                    TabVM.IsSelected = not TabVM.IsSelected
                    TabVM:UpdateTabColor()
                    local SelectState = TabVM.IsSelected
                    self:UpdateSubTabView(SelectState, TabVM)
                else
                    if TabVM.bShowSelectedState == true then
                        TabVM.bShowSelectedState = false
                        TabVM:UpdateTabColor()
                    end
                end
            end
        end
    end
end

--- 二级页签切换
---@param TabName string @二级页签名称
---@param MainTabName string @一级页签名称
function ShopVM:LeftTabsSubTabSelectChange(TabName, MainTabName)
    local TabsDatas = ShopMgr:FindShopTabVMs(self.ShopId)
    --local LastSelectState = ShopMgr.LastSelectState[ShopMgr.CurOpenMallId]
    local MainTabList = self.AllShopTabVMList
    if MainTabList == nil or MainTabList:Length() <= 0 then
        return
    end

    for i = 1, MainTabList:Length() do
        local MainTabVM = MainTabList:Get(i)
        local MainTabNameT = MainTabVM.TabName
        local MainTabData = table.find_by_predicate(
            TabsDatas, function (e)
                return e.TabName == MainTabVM.TabName
            end
        )
        if MainTabData and MainTabNameT then
            local IsSelected = MainTabNameT == MainTabName
            if IsSelected == true then
                local ChildList = MainTabVM.MemList
                local ChildListData = MainTabData.ChildList
                if ChildList ~= nil and ChildList:Length() > 0 then
                    for j = 1, ChildList:Length() do
                        local ChildTabVM = ChildList:Get(j)
                        local IsNowSelectSub = ChildTabVM.TabName == TabName
                        if ChildTabVM.IsSelected ~= IsNowSelectSub then
                            ChildTabVM.IsSelected = IsNowSelectSub
                            ChildTabVM:UpdateTabColor()
                             -- 将VM中的选中状态同步到数据中
                            if ChildListData ~= nil then
                                local SubTabData = table.find_by_predicate(
                                    ChildListData, function (e)
                                        return e.TabName == ChildTabVM.TabName
                                    end
                                )
                                if SubTabData then
                                    SubTabData.IsSelected = ChildTabVM.IsSelected
                                end
                            end
                            if IsNowSelectSub == true then
                                local CurMallID = ShopMgr.CurOpenMallId
                                ShopMgr:StoreLastSelectedGoodsIdBase(CurMallID, 0, MainTabName, TabName)
                                --[[LastSelectState.GoodsId = 0
                                LastSelectState.MainTab = MainTabName
                                LastSelectState.SubTab = TabName--]]
                                local MainShopPanel = UIViewMgr:FindVisibleView(UIViewID.ShopMainPanelView)
                                if MainShopPanel ~= nil then
                                    MainShopPanel:ControlTheFilterShow(MainShopPanel.Data.FilterShow)
                                end
                                self:UpdateShopItemListByTab()
                            end
                        end
                    end
                end
                break
            end
        end
    end
end
--end (6.12修改页签切换逻辑)

--- 打开货币tips界面
---@param PanelsParams table @ {IsItem, CostId}
function ShopVM:ShowCurrencyTipsPanel(PanelsParams)
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

--- 选中商品列表的某个商品
---@param ShopItemId number @商品表商品id
---@param ByClicked boolean @是否由点击而来
function ShopVM:ShopItemListSelected(ShopItemId, ByClicked)
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
                    --FLOG_ERROR("ShopCurrencyPageVM:UpdateCostItemList From ShopVM")
                    self.CurrencyPageVM:UpdateCostItemList(CostItemPlayerHave)
                    ShopMgr:StoreLastSelectedGoodsId(ShopItemId)
                    if UIViewMgr:IsViewVisible(UIViewID.ItemTipsStatus) then
                        UIViewMgr:HideView(UIViewID.ItemTipsStatus)
                    end
                    if ByClicked == false then
                        EventMgr:SendEvent(EventID.ScrollToSelectedGoods, i)
                    end
                end
                if ByClicked then
                    if TmpShopItemVM.IsSelected ~= IsSelected then
                        TmpShopItemVM.IsSelected = not TmpShopItemVM.IsSelected
                    end
                end
                --- 选中状态显示，选中时选中框表现为选中图片，未选中时不可操作商品选中框表现为锁定图片
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

--- 打开商店购买子界面
function ShopVM:ShowExchangeWinPanel()
    local TmpShopStuffItemVM = self:FindCurShowShopItemDetails()
    if TmpShopStuffItemVM == nil then
        return
    end

    local ItemId = TmpShopStuffItemVM.ItemId
    local ShopItemId = TmpShopStuffItemVM.ShopItemId
    local Cfg = ItemCfg:FindCfgByKey(ItemId)
    local ShopItemCfg = GoodsCfg:FindCfgByKey(ShopItemId)
    if nil == Cfg or nil == ShopItemCfg then
        return
    end

    local ExchangeName = ShopMgr:IsNeedShowBuyOrExchange(ShopMgr.CurOpenMallId)
    local CostEnoughMax, IsItem, NeedId = ShopMgr:GoodsMaxNumCanBuy(ShopItemId)
    if CostEnoughMax <= 0 then
        local CostName = ""
        if IsItem then
            local iCfg = ItemCfg:FindCfgByKey(NeedId)
            if iCfg ~= nil then
                CostName = ItemCfg:GetItemName(NeedId)
            end
        else
            local sCfg = ScoreCfg:FindCfgByKey(NeedId)
            if sCfg ~= nil then
                CostName = sCfg.NameText
            end
        end
        local TipsToShow = string.format(LSTR(1200004), CostName, ExchangeName)
        MsgTipsUtil.ShowTips(TipsToShow)
        return
    end

    local LeftSlotCount = BagMgr:GetBagLeftNum(ItemId)
    if LeftSlotCount <= 0 then
        local TipsToShow = string.format(LSTR(1200074), ExchangeName)
        MsgTipsUtil.ShowTips(TipsToShow)
        return
    end

    local LimitNum = ShopMgr:GoodsRemainNumCanBuy(ShopItemId)
    local bCanUse, ExchangeTips = ShopMgr:IsCanUse(ShopItemId)
    local TmpCommonItem = ItemUtil.CreateItem(ItemId, 0)
    local TableShopExchangeWinVM = {
        ShopItemId = ShopItemId,
        ItemName = ItemCfg:GetItemName(ItemId),
        CommonItem = TmpCommonItem,
        ItemTypeName = ItemTypeCfg:GetTypeName(Cfg.ItemType),
        CostList = TmpShopStuffItemVM.CostList,
        IsDiscount = ShopMgr:GoodsIsDiscount(ShopItemCfg.MallID, ShopItemId),
        DiscountCount = ShopItemCfg.Discount,
        ShopBuyTypeName = ShopMgr:IsNeedShowBuyOrExchange(self.ShopId, false),
        ShopBuyTypeNameWithSpace = ShopMgr:IsNeedShowBuyOrExchange(self.ShopId, true),
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
    --]]
end

--- 打开商店搜索子界面
function ShopVM:ShowShopSearchPagePanel()
    local TmpShopSearchPageVM = {
        ShopId = self.ShopId,
        ShopName = self.ShopName
    }
    self.ShopSearchPageVM:UpdateShopSearchPageVM(TmpShopSearchPageVM)

    if UIViewMgr:IsViewVisible(UIViewID.ShopSearchPageView) == false then
        UIViewMgr:ShowView(UIViewID.ShopSearchPageView, {Data = self.ShopSearchPageVM})
    end
end

--- 刷新商店搜索结果界面数据
---@param ServerGoodsData table@服务器返回的商品数据
function ShopVM:UpdateShopSearchResultData(ServerGoodsData)
    local TmpShopSearchResultPageVM = {
        ShopId = self.ShopId,
        ShopName = self.ShopName
    }
    local TmpShopSearchResultPanelVM = self.ShopSearchResultPanelVM
    TmpShopSearchResultPanelVM:UpdateShopSearchPageVM(TmpShopSearchResultPageVM)
    local ShopStuffItemVMs = {}
    if ServerGoodsData ~= nil and nil ~= next(ServerGoodsData) then
        for i = 1, #ServerGoodsData do
            local GoodsInfo = ServerGoodsData[i]
            local GoodsID = GoodsInfo.GoodsId
            local Cfg = GoodsCfg:FindCfgByKey(GoodsID)
            if nil ~= ItemCfg then
                local ShopStuffItemUpdateVal = {}
                ShopStuffItemUpdateVal.ShopItemId = GoodsID
                local ItemID = ShopMgr:GetGoodsItemID(GoodsID)
                ShopStuffItemUpdateVal.ItemId = ItemID
                ShopStuffItemUpdateVal.CostList = {}
                local IsSilverCoinValid, SilverCostList = ShopMgr:GetGoodsCostBySilverCoin(GoodsID)
                local CfgPrice = IsSilverCoinValid and SilverCostList or Cfg.Price
                for j = 1, #CfgPrice do
                    local TmpPrice = CfgPrice[j]
                    local bShow = TmpPrice.Show
                    local PriceType = TmpPrice.Type
                    if PriceType ~= GoodsPriceType.GOODS_PRICE_TYPE_Invalid then
                        local CostItemVM = {}
                        CostItemVM.CostId = TmpPrice.ID
                        CostItemVM.CostNum = TmpPrice.Count
                        CostItemVM.IsItem = PriceType == GoodsPriceType.GOODS_PRICE_TYPE_ITEM --GoodsPriceType.GOODS_PRICE_TYPE_ITEM
                        CostItemVM.bShowOnTop = bShow
                        table.insert(ShopStuffItemUpdateVal.CostList, CostItemVM)
                    end
                end
                ShopStuffItemUpdateVal.IsDiscount = ShopMgr:GoodsIsDiscount(Cfg.MallID, GoodsID)
                ShopStuffItemUpdateVal.IsShowDiscount = Cfg.ShowDiscount and ShopStuffItemUpdateVal.IsDiscount
                ShopStuffItemUpdateVal.DiscountCount = GoodsInfo.Discount
                local IsCan, CanNotReason = ShopMgr:IsCanBuy(GoodsID)
                ShopStuffItemUpdateVal.bBuy = IsCan
                ShopStuffItemUpdateVal.CanNotBuyReason = CanNotReason
                ShopStuffItemUpdateVal.bUse = ShopMgr:IsCanUse(GoodsID)
                local RestrictionType = Cfg.RestrictionType
                ShopStuffItemUpdateVal.IsBuyLimit = RestrictionType ~= ProtoRes.COUNTER_TYPE.COUNTER_TYPE_NONE
                ShopStuffItemUpdateVal.BuyLimitType = RestrictionType
                ShopStuffItemUpdateVal.MaxCanBuy = Cfg.RestrictionCount
                ShopStuffItemUpdateVal.CountHaveBuy = GoodsInfo.BoughtCount
                ShopStuffItemUpdateVal.StartTime = GoodsInfo.DiscountDurationStart
                ShopStuffItemUpdateVal.EndTime = GoodsInfo.DiscountDurationEnd
                local AdvType = Cfg.AdvType
                ShopStuffItemUpdateVal.IsHotSaleTagShow = AdvType ~= GoodsAdvType.GOODS_ADV_TYPE_None --GoodsAdvType.GOODS_ADV_TYPE_None
                ShopStuffItemUpdateVal.HotSaleTagText = ShopDefine.AdvType[AdvType]
                ShopStuffItemUpdateVal.IsSelected = false
                table.insert(ShopStuffItemVMs, ShopStuffItemUpdateVal)
            end
        end
    end
    TmpShopSearchResultPanelVM:UpdateCurShopItemList(ShopStuffItemVMs)
end

--- 打开商店搜索结果子界面
---@param NewContent string@搜索内容
function ShopVM:ShowShopSearchResultPanel(NewContent)
    if NewContent == nil or NewContent == "" then
        return
    end
    local CurResultGoodsInfo = ShopMgr:FindAllItemsInSpecificShopByKeyWord(NewContent)
    self:UpdateShopSearchResultData(CurResultGoodsInfo)
    if UIViewMgr:IsViewVisible(UIViewID.ShopSearchResultPanelView) == false then
        UIViewMgr:ShowView(UIViewID.ShopSearchResultPanelView, {Data = self.ShopSearchResultPanelVM})
    end
end

--- 记录最后一次的搜索结果
---@param NewContent string@搜索内容
function ShopVM:SetSearchInputLastRecord(NewContent)
    self.SearchInputLastRecord = NewContent
    self.ShopSearchPageVM.SearchInputLastRecord = NewContent
    self.ShopSearchResultPanelVM.SearchInputLastRecord = NewContent
    self:SetSearchInputBtnSize(NewContent)
end

--- 根据内容设置搜索按钮的大小(搜索按钮的大小会根据是否有内容而变化，保证搜索框的取消按钮可以点击)
---@param NewContent string@搜索内容
function ShopVM:SetSearchInputBtnSize(NewContent)
    local SizeX = NewContent == "" and 450 or 360
    self.SearchBtnSize = _G.UE.FVector2D(SizeX, 72)
    self.ShopSearchResultPanelVM.SearchBtnSize = _G.UE.FVector2D(SizeX, 72)
end

--要返回当前类
return ShopVM
