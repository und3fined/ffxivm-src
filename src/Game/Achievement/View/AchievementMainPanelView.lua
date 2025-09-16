---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")
local AchievementDefine = require("Game/Achievement/AchievementDefine")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local AchievementAwardTypeCfg = require("TableCfg/AchievementAwardTypeCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")

local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local AchievementMainPanelVM = require("Game/Achievement/VM/AchievementMainPanelVM")

local LogMgr = require("Log/LogMgr")
local FLOG_WARNING = LogMgr.Warning
local EToggleButtonState = _G.UE.EToggleButtonState
local LSTR = _G.LSTR
local AchievementMgr = _G.AchievementMgr
local UIViewMgr = _G.UIViewMgr

---@class AchievementMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnGetAll UFButton
---@field BtnReward UFButton
---@field BtnShop UFButton
---@field Btn_Bg UFButton
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonGuideBG CommonGuideBkgView
---@field DropDownList CommDropDownListView
---@field EFF_1 UFCanvasPanel
---@field Empty CommBackpackEmptyView
---@field PanelGetAll UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelReward UFCanvasPanel
---@field PanelTarget UFCanvasPanel
---@field RedDot_1 CommonRedDotView
---@field RichTextProcess URichTextBox
---@field SingleBoxReach1 CommSingleBoxView
---@field Spacer4ListOnly USpacer
---@field TableViewAchievement UTableView
---@field TextAchieve1 UFTextBlock
---@field TextGetAll UFTextBlock
---@field TextTarget UFTextBlock
---@field TextTitle UFTextBlock
---@field TreeViewTabs UFTreeView
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AchievementMainPanelView = LuaClass(UIView, true)

function AchievementMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnGetAll = nil
	--self.BtnReward = nil
	--self.BtnShop = nil
	--self.Btn_Bg = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonGuideBG = nil
	--self.DropDownList = nil
	--self.EFF_1 = nil
	--self.Empty = nil
	--self.PanelGetAll = nil
	--self.PanelList = nil
	--self.PanelReward = nil
	--self.PanelTarget = nil
	--self.RedDot_1 = nil
	--self.RichTextProcess = nil
	--self.SingleBoxReach1 = nil
	--self.Spacer4ListOnly = nil
	--self.TableViewAchievement = nil
	--self.TextAchieve1 = nil
	--self.TextGetAll = nil
	--self.TextTarget = nil
	--self.TextTitle = nil
	--self.TreeViewTabs = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AchievementMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonGuideBG)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.Empty)
	self:AddSubView(self.RedDot_1)
	self:AddSubView(self.SingleBoxReach1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AchievementMainPanelView:OnInit()
	self.AdapterTreeViewTabs = UIAdapterTreeView.CreateAdapter(self, self.TreeViewTabs, self.OnTreeViewTabsSelectChanged, true)
	self.AdapterTableViewAchievement = UIAdapterTableView.CreateAdapter(self, self.TableViewAchievement, self.OnTableViewAchievementSelectChanged, false, false, true)
	local AwardTypeAllCfg = AchievementAwardTypeCfg:FindAllCfg() or {}
	self.DropDownListData = {}
	table.sort(AwardTypeAllCfg, function(A, B) return A.Sort < B.Sort end )

	for i = 1, #AwardTypeAllCfg do
		table.insert(self.DropDownListData, { Type = AwardTypeAllCfg[i].ID , Name = AwardTypeAllCfg[i].AwardType } )
	end

	self.Binders = {
		{ "TableViewTabsList", UIBinderUpdateBindableList.New(self, self.AdapterTreeViewTabs) },
		{ "PanelTopVisible", UIBinderSetIsVisible.New(self, self.PanelTarget) },
		{ "TextTargetVisible", UIBinderSetIsVisible.New(self, self.TextTarget) },
		{ "TargetAchievementNum", UIBinderSetTextFormat.New(self, self.TextTarget, (LSTR(720012) .. "%d/" .. tostring( AchievementDefine.TagetAchievementTotalNum )))},
		{ "EmptyPanelVisible", UIBinderSetIsVisible.New(self, self.Empty) },
		{ "EmptyPanelText", UIBinderValueChangedCallback.New(self, nil, self.OnEmptyPanelTextChange) },
		{ "PanelListVisible", UIBinderSetIsVisible.New(self, self.PanelList) },
		{ "PanelGetAllVisible", UIBinderSetIsVisible.New(self, self.PanelGetAll) },
		{ "Spacer4ListOnlyVisible", UIBinderSetIsVisible.New(self, self.Spacer4ListOnly) },
		{ "TableViewAchievementList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewAchievement) },
		{ "TotalAchievePointText", UIBinderSetText.New(self, self.RichTextProcess) },
		{ "FinishToggleButtonState", UIBinderSetCheckedState.New(self, self.SingleBoxReach1.ToggleButton) },
		{ "SelectAchievementID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectAchievementIDChange) },
		{ "CategoryID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectCategoryIDChange) },
		{ "SelectTypeID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectTypeIDChange) },
		{ "LevelRewardEFFVisible", UIBinderSetIsVisible.New(self, self.EFF_1) },
		{ "TrackedBgVisible", UIBinderSetIsVisible.New(self, self.Btn_Bg, false, true ) },
		{ "DropDownListVisible", UIBinderValueChangedCallback.New(self, nil, self.OnDropDownListVisibleChange) },
	}
	UIUtil.SetIsVisible(self.Empty.PanelBtn, false )
	self.RedDot_1:SetRedDotNameByString(AchievementDefine.RedDotName .. '/0/level')
	self.AdapterTreeViewTabs:SetAutoExpandAll(false)
end

function AchievementMainPanelView:OnDestroy()

end

function AchievementMainPanelView:TranslatedText()
	self.TextTitle:SetText(LSTR(720019))
	self.TextAchieve1:SetText(LSTR(720021))
	self.TextGetAll:SetText(LSTR(10023))
end

function AchievementMainPanelView:OnShow()
	self:TranslatedText()
	self.AdapterTreeViewTabs:CancelSelected()
	self.AdapterTreeViewTabs:CollapseAll()
	self.DropDownList:UpdateItems(self.DropDownListData, 1)

	local Params = self.Params
	local AchievemwntID = nil
	local TypeID = nil
	local CategoryID = 0 
	if Params and ( Params.AchievemwntID or Params.TypeID or Params.CategoryID ) then
		AchievemwntID = Params.AchievemwntID or 0
		TypeID = Params.TypeID
		CategoryID = Params.CategoryID
	
		if AchievemwntID ~= nil and AchievemwntID ~= 0 then
			local AchievemwntInfo = AchievementMgr:GetAchievementInfo(AchievemwntID)
			if AchievemwntInfo ~= nil then
				TypeID = AchievemwntInfo.TypeID
				CategoryID = AchievemwntInfo.CategoryID or 0
			else
				FLOG_WARNING(string.format(" No found achievement from id: %d ! ", AchievemwntID))
				AchievemwntID = 0
			end
		elseif CategoryID ~= nil and CategoryID ~= 0 then
			TypeID = AchievementUtil.GetTypeIDFromCategoryID(CategoryID)
		elseif TypeID ~= nil and TypeID ~= 0 then
			CategoryID = 0
		end
	end

	if (TypeID or 0) == 0 then
		TypeID = AchievementDefine.OverviewCategoryDataTable[1].TypeID
	else
		self:RegisterTimer(
			function()
				local _, Index = AchievementMainPanelVM.TableViewTabsList:FindByKey(TypeID)
				self:TreeViewTabsScrollToSelected(Index)
			end, 0.03)
	end

	AchievementMainPanelVM:SetSelectType(TypeID)
	AchievementMainPanelVM:SetSelectCategoryID(CategoryID)
	self.NeedGoToTargetAchieveID = AchievemwntID ~= 0
	AchievementMainPanelVM:SetSelectAchievemwntID(AchievemwntID)
	AchievementMainPanelVM:SetTrackedBgVisible(AchievemwntID ~= 0)
	AchievementMainPanelVM:SetLevelRewardEFFVisible(0)
end

function AchievementMainPanelView:OnHide()
	AchievementMgr:ClearCollectionReqCache()
	AchievementMainPanelVM:ResetData()
	AchievementMainPanelVM:SetExendView(nil)
end

function AchievementMainPanelView:OnRegisterGameEvent()

end

function AchievementMainPanelView:OnRegisterBinder()
	self:RegisterBinders(AchievementMainPanelVM, self.Binders)
end

function AchievementMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnDropDownListSelectionChanged)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxReach1.ToggleButton, self.OnFinishToggleBtnStateChange )
	UIUtil.AddOnClickedEvent(self,  self.BtnGetAll, self.OnBtnGetAllClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnReward, self.OnBtnRewardClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnShop, self.OnBtnShopClick)

	UIUtil.AddOnClickedEvent(self,  self.Btn_Bg, self.OnBtnBgClick)
end

function AchievementMainPanelView:OnSelectTypeIDChange(NewValue, OldValue)
	if (OldValue or 0) ~= 0 then
		self.AdapterTreeViewTabs:SetIsExpansion(OldValue, false)
	end
	if (NewValue or 0) ~= 0 then
		self.AdapterTreeViewTabs:SetIsExpansion(NewValue, true)
	end
end

function AchievementMainPanelView:OnSelectCategoryIDChange(NewValue, OldValue)
	self.AdapterTableViewAchievement:CancelSelected()
	self.AdapterTableViewAchievement:ScrollToTop()
end

function AchievementMainPanelView:OnTreeViewTabsSelectChanged(Index, ItemData, ItemView)
	if nil ~= ItemData.CategoryID then
		if AchievementMainPanelVM.CategoryID ~= ItemData.CategoryID then
			AchievementMainPanelVM:SetSelectCategoryID(ItemData.CategoryID )
		end
	else
		if AchievementMainPanelVM.SelectTypeID ~= ItemData.TypeID then
			AchievementMainPanelVM:SetSelectType( ItemData.TypeID )
			AchievementMainPanelVM:SetSelectCategoryID(0)
		end
		self:TreeViewTabsScrollToSelected(Index)
	end
end

function AchievementMainPanelView:OnDropDownListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	if Index ~= nil and self.DropDownListData[Index] ~= nil then
		local Type = self.DropDownListData[Index].Type
		AchievementMainPanelVM:SetCurrentFiltrateTypeID(Type)
	end
end

function AchievementMainPanelView:OnFinishToggleBtnStateChange(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		AchievementMainPanelVM:SetFinishToggleButtonState(EToggleButtonState.Checked)
	else
		AchievementMainPanelVM:SetFinishToggleButtonState(EToggleButtonState.Unchecked)
	end
end

function AchievementMainPanelView:OnSelectAchievementIDChange(NewValue)
	if (NewValue or 0) == 0 then
		self.AdapterTableViewAchievement:SetSelectedIndex(1)
	else
		local Index = AchievementMainPanelVM.TableViewAchievementList:GetItemIndexByPredicate(
			function(Item)
				return Item.ID == NewValue
			end
		) or 1
		if self.NeedGoToTargetAchieveID then
			self.AdapterTableViewAchievement:ScrollToIndex(Index)
			self.NeedGoToTargetAchieveID = false
		else
			self.AdapterTableViewAchievement:ScrollIndexIntoView(Index)
		end
	end
end

function AchievementMainPanelView:TreeViewTabsScrollToSelected(Index)
	local MaxNUm = self.AdapterTreeViewTabs:GetMaxItemDataDisplayNum()
	if Index ~= nil then
		if MaxNUm ~= Index then
			if AchievementMainPanelVM.TrackedBgVisible then
				self.AdapterTreeViewTabs:ScrollToIndex(Index)
			else
				self.AdapterTreeViewTabs:ScrollIndexIntoView(Index)
			end
		else
			self.AdapterTreeViewTabs:ScrollToBottom()
		end
	end
end

function AchievementMainPanelView:OnEmptyPanelTextChange(NewValue)
	self.Empty:SetTipsContent(NewValue)
end

function AchievementMainPanelView:OnDropDownListVisibleChange(NewValue)
	if NewValue then 
		for i = 1, #(self.DropDownListData or {}) do
			if self.DropDownListData[i].Type == AchievementMainPanelVM.CurrentFiltrateTypeID then
				self.DropDownList:SetSelectedIndex(i)
			end
		end
	end

	UIUtil.SetIsVisible(self.DropDownList, NewValue)
end

function AchievementMainPanelView:OnBtnShopClick()
	_G.ShopMgr:OpenShop(2001)
end

function AchievementMainPanelView:OnBtnGetAllClick()
	AchievementMainPanelVM:BtnGetAllClick()
end

function AchievementMainPanelView:OnBtnRewardClick()
	AchievementMainPanelVM:SetExendView(nil)
	AchievementMgr:OpenTypeLevelRewardView(AchievementMainPanelVM.SelectTypeID)
end

function AchievementMainPanelView:OnBtnBgClick()
	AchievementMainPanelVM:SetTrackedBgVisible(false)
end

return AchievementMainPanelView