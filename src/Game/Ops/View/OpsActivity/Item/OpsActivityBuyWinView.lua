---
--- Author: Administrator
--- DateTime: 2024-12-06 10:41
--- Description:
---
local ScoreCfg = require("TableCfg/ScoreCfg")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
local StoreMgr = require("Game/Store/StoreMgr")
local ItemVM = require("Game/Item/ItemVM")
local UIBindableList = require("UI/UIBindableList")
local StoreDefine = require("Game/Store/StoreDefine")
local ProtoRes = require("Protocol/ProtoRes")
local StoreCfg = require("TableCfg/StoreCfg")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local LSTR = _G.LSTR

---@class OpsActivityBuyWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy OpsCommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnCheck UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field ImgPoster UFImage
---@field MoneyBar CommMoneyBarView
---@field TableViewSlot UTableView
---@field TextInfo UFTextBlock
---@field TextName UFTextBlock
---@field TextWhatsIncluded UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityBuyWinView = LuaClass(UIView, true)

function OpsActivityBuyWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnCancel = nil
	--self.BtnCheck = nil
	--self.Comm2FrameM_UIBP = nil
	--self.ImgPoster = nil
	--self.MoneyBar = nil
	--self.TableViewSlot = nil
	--self.TextInfo = nil
	--self.TextName = nil
	--self.TextWhatsIncluded = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityBuyWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.MoneyBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityBuyWinView:OnInit()
	self.ContainsItemList = UIBindableList.New(ItemVM, {IsCanBeSelected = true, IsShowNum = false, IsShowSelectStatus = false})
	self.ItemTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnItemSelected, true, false)
end

function OpsActivityBuyWinView:OnItemSelected(Index, ItemData, ItemView)
	ItemData.IsSelect = false
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0, Y = 0})
end

function OpsActivityBuyWinView:OnDestroy()

end

function OpsActivityBuyWinView:SetWidgetTextIcon(GoodsData)
	local GoodCfgData = GoodsData.Cfg
	UIUtil.ImageSetBrushFromAssetPath(self.ImgGoods, GoodCfgData.Icon)
	self.TextItemName:SetText(GoodCfgData.Name)
	self.TextItemDescription:SetText(GoodCfgData.Desc)
	self.BtnBuy:SetBtnName(LSTR(100027))
	self.BtnCancel:SetBtnName(LSTR(10003))
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(100038))
	self.TextWhatsIncluded:SetText(LSTR(100039))
end

function OpsActivityBuyWinView:OnShow()
	self.Comm2FrameM_UIBP:SetClickCloseCallback(self,self.OnClickBtnCancel)
	if self.Params and self.Params.GoodsID then
		self.GoodsID = self.Params.GoodsID
		self.BtnBuy:SetBtnPriceByGoodsID(self.GoodsID)
		local GoodsData = StoreMgr:GetProductDataByID(self.GoodsID)
		self:SetWidgetTextIcon(GoodsData)

		local GoodsCfgData = StoreCfg:FindCfgByKey(self.GoodsID)
		if nil ~= GoodsCfgData then
			self:InitContainsItemList(GoodsCfgData.Items)
		end
		self:SetMoneyBar()
	end
end

function OpsActivityBuyWinView:OnHide()

end

function OpsActivityBuyWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickBuy)
end

function OpsActivityBuyWinView:OnClickBtnCancel()
	UIUtil.SetIsVisible(self.MoneyBar, false)
	self:Hide()
end

function OpsActivityBuyWinView:OnClickBuy()
	self:BuyStoreGoodsByID(self.GoodsID)
end

function OpsActivityBuyWinView:InitContainsItemList(DataList)
    if not DataList then return  end

    local ItemList = {}
    for _, Item in ipairs(DataList) do
        if Item.ID ~= 0 then
            ItemList[#ItemList + 1] = {
                ResID = Item.ID,
                Num = Item.Num
            }
        end
    end

    self.ContainsItemList:UpdateByValues(ItemList)
	self.ItemTableViewAdapter:UpdateAll(self.ContainsItemList)
end

function OpsActivityBuyWinView:BuyStoreGoodsByID(GoodsID)
	if not GoodsID then return end
		
	local GoodCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodCfgData then
		return
	end

	local PriceData = GoodCfgData.Price[StoreDefine.PriceDefaultIndex]
	if PriceData and PriceData.Count then
		local ScoreValue = _G.ScoreMgr:GetScoreValueByID(PriceData.ID)
		if ScoreValue < PriceData.Count then
			local TempScoreCfg = ScoreCfg:FindCfgByKey(PriceData.ID)
			if TempScoreCfg == nil then
				return
			end
			local ScroeName = TempScoreCfg.NameText
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(
				self,
				LSTR(950032),
				string.format(LSTR(950034), ScroeName),	--- "%s不足，是否前往充值？"
				function()
					-- 打开充值界面
					_G.RechargingMgr:ShowMainPanel()
					_G.RechargingMgr:OnChangedMainPanelCloseBtnToBack(true)
				end,
				nil,
				LSTR(950030),	--- "取消"
				LSTR(950033)	--- "确认"
			)
		else
			_G.UIViewMgr:HideView(_G.UIViewID.OpsActivityBuyWin)
			_G.LootMgr:SetDealyState(true)
			StoreMgr:SendMsgBuyGood(GoodCfgData.ID, StoreDefine.MinBuyQuantity)
		end
	end
end

function OpsActivityBuyWinView:SetMoneyBar()
	local MoneyData = self.Params.MoneyData or {}
	UIUtil.SetIsVisible(self.MoneyBar, next(MoneyData) and true or false)
	local Widget = self.MoneyBar
	UIUtil.SetIsVisible(Widget.Money1,  MoneyData.Money1 and true or false)
	UIUtil.SetIsVisible(Widget.Money2,  MoneyData.Money2 and true or false)
	UIUtil.SetIsVisible(Widget.Money3,  MoneyData.Money3 and true or false)
	if MoneyData.Money1 then
		Widget.Money1:UpdateView(MoneyData.Money1.ScoreType, true, MoneyData.Money1.UIView, true)
	end

	if MoneyData.Money2 then
		Widget.Money2:UpdateView(MoneyData.Money2.ScoreType, true, MoneyData.Money2.UIView, true)
	end

	if MoneyData.Money3 then
		Widget.Money3:UpdateView(MoneyData.Money3.ScoreType, true, MoneyData.Money3.UIView, true)
	end
end

function OpsActivityBuyWinView:OnRegisterGameEvent()

end

return OpsActivityBuyWinView