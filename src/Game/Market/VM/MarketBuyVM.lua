local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MarketSubTabItemVM = require("Game/Market/VM/MarketSubTabItemVM")
local MarketCommodityItemVM = require("Game/Market/VM/MarketCommodityItemVM")
local MarketMgr = require("Game/Market/MarketMgr")
local MarketMainVM = require("Game/Market/VM/MarketMainVM")
local ProtoRes = require("Protocol/ProtoRes")
local ScreenerInfoCfg = require("TableCfg/ScreenerInfoCfg")
local CommScreenerVM = require("Game/Common/Screener/CommScreenerVM")


local LSTR = _G.LSTR
---@class MarketBuyVM : UIViewModel
local MarketBuyVM = LuaClass(UIViewModel)

---Ctor
function MarketBuyVM:Ctor()
	self.SubTabVMList = UIBindableList.New(MarketSubTabItemVM)
	self.GoodsItemListVMList = UIBindableList.New(MarketCommodityItemVM)

    self.MarketEmptyVisible = nil
    self.FavorText = nil

    self.PageSwitchVisible = nil
    self.PageText = nil
    self.PageLastVisible = nil
	self.PageLastDisableVisible = nil
    self.PageNextVisible = nil
	self.PageNextDisableVisible = nil
   

    self.SearchHistoryVisible = nil
	self.NewScreenerVisible = nil
	self.CommDropDownVisible = nil
	self.SearchBarVisible = nil

    self.DropDown1Date = nil
    self.DropDown2Date = nil
end

function MarketBuyVM:UpdateSubTab(SubTypeList)
    if nil == SubTypeList then
        return
    end

    self.DropDown1Index = 1
    self.DropDown2Index = 1
    self.SubTabVMList:UpdateByValues(SubTypeList)

    MarketMainVM.ImgBgLineVisible = self.SubTabVMList:Length() > 0
end

function MarketBuyVM:SetSubTabIndex(ShowID)
    for i = 1, self.SubTabVMList:Length() do
		local SubTabVM = self.SubTabVMList:Get(i)
		SubTabVM:UpdateSelectedState(ShowID)	
	end
end

function MarketBuyVM:UpdatePageInfo(Page, PageMax, LastBtnEnabled, NextBtnEnabled)
    self.PageText = string.format("%d/%d", Page, PageMax)
    self.PageLastVisible = LastBtnEnabled
	self.PageLastDisableVisible = not LastBtnEnabled
    self.PageNextVisible = NextBtnEnabled
	self.PageNextDisableVisible = not NextBtnEnabled
end


function MarketBuyVM:SetConcernInfo()
    local Num = MarketMgr:GetConcernGoodsNum()
    if Num < 1 then
        self.FavorText = ""
    else
        self.FavorText = string.format(LSTR(1010024), Num, MarketMgr.ConcernNum)
    end

end

function MarketBuyVM:SetSubPanelInfo(MainType, SubTabData)
    if MainType == ProtoRes.TradeMainType.TRADE_CONCERN_TYPE then
        self:SetConcernInfo()
    else
        self.FavorText = ""
    end

    self:UpdateScreenerInfo(SubTabData)
end

function MarketBuyVM:UpdateScreenerInfo(SubTabData)
    self.SubTabData = SubTabData
    self.DropDown1Date = nil
    self.DropDown2Date = nil
    
    if SubTabData == nil or SubTabData.Screener == nil then
        self.NewScreenerVisible = false
        self.SearchBarVisible = true
        return
    end

    local Num = #SubTabData.Screener
    if SubTabData.Screener ~= nil and Num > 0 then
        self.SearchBarVisible = false
        self.DropDown1Date = self:GetScreenListByScreenerID(SubTabData.Screener[1])
        self.NewScreenerVisible = #self.DropDown1Date > 0
        if Num > 1 then
            self.DropDown2Date = self:GetScreenListByScreenerID(SubTabData.Screener[2])
            self.CommDropDownVisible = #self.DropDown2Date > 0
        else
            self.CommDropDownVisible = false
        end
    else
        self.NewScreenerVisible = false
        self.SearchBarVisible = true
    end
end

function MarketBuyVM:GetScreenListByScreenerID(ScreenerID)
    local CfgSearchCond = string.format("ScreenerID == %d", ScreenerID)
    return ScreenerInfoCfg:FindAllCfg(CfgSearchCond)
end

function MarketBuyVM:SearchCondAndScreenerList()
    local SearchCond = {}
    if self.DropDown1Date ~= nil and self.DropDown1Index ~= nil then
        local DropDownSearchCond = CommScreenerVM:GetScreenerSearchCond(self.DropDown1Date[self.DropDown1Index])
        if DropDownSearchCond ~= nil then
            table.insert(SearchCond, DropDownSearchCond)	
        end
    end
    
    if self.DropDown2Date ~= nil and self.DropDown2Index ~= nil then
        local DropDownSearchCond = CommScreenerVM:GetScreenerSearchCond(self.DropDown2Date[self.DropDown2Index])
        if DropDownSearchCond ~= nil then
            table.insert(SearchCond, DropDownSearchCond)	
        end
    end

    return SearchCond
end

function MarketBuyVM:UpdateGoodsList(GoodsList)
    local ShowList = {}
    for i = 1, #GoodsList do
        if GoodsList[i].ResID > 0 then
            table.insert(ShowList, GoodsList[i])
        end
    end
    self.GoodsItemListVMList:UpdateByValues(ShowList)
end

function MarketBuyVM:EnterSearch()
    self.NewScreenerVisible = false
    self.SearchBarVisible = true
end


--要返回当前类
return MarketBuyVM