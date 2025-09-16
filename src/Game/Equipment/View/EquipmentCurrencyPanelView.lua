---
--- Author: v_zanchang
--- DateTime: 2023-04-13 17:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local EquipmentCurrencyVM = require("Game/Equipment/VM/EquipmentCurrencyVM")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreSummaryTypeCfg = require("TableCfg/ScoreSummaryTypeCfg")
local ShopMgr = require("Game/Shop/ShopMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local UIViewMgr = require("UI/UIViewMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")
local MsgTipsID = require("Define/MsgTipsID")

local RedDotIDList = {
	[ProtoRes.ScoreSummaryType.Mutual] = 8002,
	[ProtoRes.ScoreSummaryType.Combat] = 8003,
	[ProtoRes.ScoreSummaryType.Production] = 8004,
	[ProtoRes.ScoreSummaryType.FriendlyTribe] = 8005,
}

---@class EquipmentCurrencyPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field CommMenu_UIBP CommMenuView
---@field CommonBkg01 CommonBkg01View
---@field FTreeViewCurrency UFTreeView
---@field HelpBtn CommHelpBtnView
---@field HorizontalConvertTips UFHorizontalBox
---@field PanelTips UFCanvasPanel
---@field PanelTipsBgBtn UFButton
---@field TableViewCurrency UTableView
---@field TextConvert UFTextBlock
---@field TextTipsDescription UFTextBlock
---@field TextTipsTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimPanelTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentCurrencyPanelView = LuaClass(UIView, true)

function EquipmentCurrencyPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.CommMenu_UIBP = nil
	--self.CommonBkg01 = nil
	--self.FTreeViewCurrency = nil
	--self.HelpBtn = nil
	--self.HorizontalConvertTips = nil
	--self.PanelTips = nil
	--self.PanelTipsBgBtn = nil
	--self.TableViewCurrency = nil
	--self.TextConvert = nil
	--self.TextTipsDescription = nil
	--self.TextTipsTitle = nil
	--self.TextTitle = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--self.AnimPanelTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencyPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommMenu_UIBP)
	self:AddSubView(self.CommonBkg01)
	self:AddSubView(self.HelpBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencyPanelView:OnInit()
	-- self.AdapterEquipCurrencyPanel = UIAdapterTreeView.CreateAdapter(self, self.FTreeViewCurrency)
	self.AdapterEquipCurrencyPanel = UIAdapterTableView.CreateAdapter(self, self.TableViewCurrency)
	
	self.AdapterEquipCurrencyPanel:SetOnClickedCallback(self.OnItemClicked)
	--- self.AllListData 所有menuItemData数组
	self.AllListData = {}
	for _, value in pairs(ProtoRes.ScoreSummaryType) do
		if value > 0 then
			local SearchConditions = string.format("%s%s", "ScoreSumType=", tostring(value))
			local Cfg = ScoreSummaryTypeCfg:FindCfg(SearchConditions)
			if Cfg ~= nil then
				local Data = {Name = Cfg.ScoreSummaryTabShow, ScoreSumType = Cfg.ScoreSumType, RedDotID = RedDotIDList[value]}
				table.insert(self.AllListData, Data)
			end
		end
	end
	table.sort(self.AllListData, self.Comp)
end

function EquipmentCurrencyPanelView.Comp(V1, V2)
    if V1.ScoreSumType < V2.ScoreSumType then
        return true
    else
        return false
    end
end

function EquipmentCurrencyPanelView:OnDestroy()

end

function EquipmentCurrencyPanelView:OnShow()
	self.TextTitle:SetText(LSTR(490001))	--- 货币总览
	self.TextConvert:SetText(LSTR(490006))	--- 货币已发生转化
	
	UIUtil.SetIsVisible(self.HorizontalConvertTips, #ScoreMgr.IterationConvertInfos ~= 0)
	EquipmentCurrencyVM:LoadAllScore()
	--- self.OpenListData 已解锁的menuItemData数组
	self.OpenListData = self:CheckListDataItemIsExist()
	self.CommMenu_UIBP:UpdateItems(self.OpenListData)
	self:SelectCommMenuIndex(1)
	---请求有周获取上限的积分周获取量
	ScoreMgr:SendGetScoreLimitInfo()
end

function EquipmentCurrencyPanelView:OnHide()

end

function EquipmentCurrencyPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu_UIBP, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnClickedEvent(self, self.PanelTipsBgBtn, self.OnPanelTipsBgBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.HelpBtn.InforBtn, self.OnHelpBtnBtnClicked)
end

function EquipmentCurrencyPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.EquipmentCurrencyConvertViewHide, self.OnConvertViewHide)
end

function EquipmentCurrencyPanelView:OnRegisterBinder()
	local Binders = {
		{ "CurrentCurrencyItemBindableParentVMList", UIBinderUpdateBindableList.New(self, self.AdapterEquipCurrencyPanel) },
		{ "CurrencyItemBindableSelcetChildVM", UIBinderSetSelectedItem.New(self, self.AdapterEquipCurrencyPanel) },
	 }

	 self:RegisterBinders(EquipmentCurrencyVM, Binders)
end

function EquipmentCurrencyPanelView:SelectCommMenuIndex(Index)
	self.CommMenu_UIBP:SetSelectedIndex(Index)
	self:OnSelectionChangedCommMenu(Index)
end

function EquipmentCurrencyPanelView:OnSelectionChangedCommMenu(Index)
	local ItemData = self.OpenListData[Index]
	EquipmentCurrencyVM:SelectTabType(ItemData.ScoreSumType)
	self:PlayAnimation(self.AnimChangeTab)
end

function EquipmentCurrencyPanelView:OnItemClicked(Index, ItemData, ItemView)
	local ViewModel = ItemView.Params.Data
	if nil == ViewModel then
		return
	end
	if ItemView.BtnShopClicked then
		if ViewModel.ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS then
			if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL, true) then
				UIViewMgr:ShowView(_G.UIViewID.StoreNewMainPanel)
			end
		elseif ViewModel.ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
			local ProtoCommon = require("Protocol/ProtoCommon")
			if _G.MarketMgr:CanUnLockMarket() == false then
				_G.MsgTipsUtil.ShowTipsByID(358001)
				return
			end
			UIViewMgr:ShowView(_G.UIViewID.MarketMainPanel)
		else
			if ViewModel.ShopID == nil then
				_G.FLOG_ERROR("ScoreID = %d,ShopID Is Null", ViewModel.ScoreID)
			elseif ViewModel.ShopID == 0 then
				_G.MsgTipsUtil.ShowTipsByID(10031)
			else
				if _G.ShopMgr:ShopIsUnLock(ViewModel.ShopID) then
					ShopMgr:OpenShop(ViewModel.ShopID)
				else
					_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.ShopUnlockTipsID)
				end
			end
		end
	end
	self.LastClicked = ItemView
end

function EquipmentCurrencyPanelView:OnHelpBtnBtnClicked()
	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.EquipmentCurrencyDetail), "0")
	UIViewMgr:ShowView(_G.UIViewID.CurrencyConvertWin)
end

function EquipmentCurrencyPanelView:OnPanelTipsBgBtnClicked()
	UIUtil.SetIsVisible(self.PanelTipsBgBtn, false)
	UIUtil.SetIsVisible(self.PanelTips, false)
end

---@return table   左侧TABItemData
function EquipmentCurrencyPanelView:CheckListDataItemIsExist()
	local TempListData = {}
	for i = 1, #self.AllListData do
		if EquipmentCurrencyVM:CheckCurrencyTypeIsExist(self.AllListData[i].ScoreSumType) then
			table.insert(TempListData, self.AllListData[i])
		end
	end
	return #TempListData == #self.AllListData and self.AllListData or TempListData
end

-- 关闭转化详情界面时隐藏上方Tips
function EquipmentCurrencyPanelView:OnConvertViewHide()
	UIUtil.SetIsVisible(self.HorizontalConvertTips, false)
end

return EquipmentCurrencyPanelView