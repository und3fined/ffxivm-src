---
--- Author: usakizhang
--- DateTime: 2024-12-26 20:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BagDefine = require("Game/Bag/BagDefine")
local MeetTradeBagMainVM = require("Game/MeetTrade/VM/MeetTradeBagMainVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CommonUtil = require("Utils/CommonUtil")
local TipsUtil = require("Utils/TipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
---TODO 使用MeetTradeMgr替换
local BagMgr = _G.BagMgr
local EventID = _G.EventID
local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState
---@class MeetTradeExchangeChoosePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field CommBtnL_UIBP CommBtnLView
---@field CommonBkg CommonBkg01View
---@field CommonTitle CommonTitleView
---@field EditQuantity CommEditQuantityItemView
---@field FTextBlock UFTextBlock
---@field FTextBlock_123 UFTextBlock
---@field FTextBlock_203 UFTextBlock
---@field FTextBlock_36 UFTextBlock
---@field FTextBlock_94 UFTextBlock
---@field PanelEmpty UFCanvasPanel
---@field PanelSlotInfo UFCanvasPanel
---@field Slot126 CommBackpack126SlotView
---@field TableViewBagItem UTableView
---@field TableView_103 UTableView
---@field TextSubtitle UFTextBlock
---@field TextTitleName UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MeetTradeExchangeChoosePanelView = LuaClass(UIView, true)

function MeetTradeExchangeChoosePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.CommBtnL_UIBP = nil
	--self.CommonBkg = nil
	--self.CommonTitle = nil
	--self.EditQuantity = nil
	--self.FTextBlock = nil
	--self.FTextBlock_123 = nil
	--self.FTextBlock_203 = nil
	--self.FTextBlock_36 = nil
	--self.FTextBlock_94 = nil
	--self.PanelEmpty = nil
	--self.PanelSlotInfo = nil
	--self.Slot126 = nil
	--self.TableViewBagItem = nil
	--self.TableView_103 = nil
	--self.TextSubtitle = nil
	--self.TextTitleName = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MeetTradeExchangeChoosePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommBtnL_UIBP)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.EditQuantity)
	self:AddSubView(self.Slot126)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MeetTradeExchangeChoosePanelView:OnInit()
	--- 设置文字
	self.CommBtnL_UIBP.TextContent:SetText(LSTR(1490010))
	
	---创建TableView的适配器
	self.TableViewBagItemList = UIAdapterTableView.CreateAdapter(self, self.TableViewBagItem)
	self.TableViewBagItemList:SetOnClickedCallback(self.OnItemClicked)

	self.TableViewChosenItemList = UIAdapterTableView.CreateAdapter(self, self.TableView_103)

	self.Binders = {
		{"TitleNameText", UIBinderSetText.New(self, self.TextTitleName)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextSubtitle)},
		{"CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewBagItemList) },
		{"CurrentSlectItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewChosenItemList) },
		{"TipsPanelEmptyVisible", UIBinderSetIsVisible.New(self, self.PanelEmpty)},
		{"TipsPanelInfoVisible", UIBinderSetIsVisible.New(self, self.PanelSlotInfo)},
		--RichTextQuantity
		{"TipsPanelItemNumVisible", UIBinderSetIsVisible.New(self, self.Slot126.RichTextQuantity)},
		{"TipsPanelItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.Slot126.Icon)},
		{"TipsPanelItemIconChooseVisible", UIBinderSetIsVisible.New(self, self.Slot126.IconChoose)},
		{"TipsPanelItemName", UIBinderSetText.New(self, self.FTextBlock_36)},
		{"TipsPanelItemQuantity", UIBinderSetText.New(self, self.FTextBlock_94)},
		{"TipsPanelItemNumberText", UIBinderSetText.New(self, self.FTextBlock)},
		{"ExchangeSettingNumber", UIBinderSetText.New(self, self.TextNumber3)},
		{"HasSelectItemNumTips", UIBinderSetText.New(self, self.FTextBlock_203)},
		{"EditQuantityVisible", UIBinderSetIsVisible.New(self, self.EditQuantity)},
	}
end

function MeetTradeExchangeChoosePanelView:OnClickedCallback()
	--- 关闭Tips
	if UIViewMgr:IsViewVisible(UIViewID.BagItemTips) then
		UIViewMgr:HideView(UIViewID.BagItemTips)
	end

	--- 重置背包状态
	MeetTradeBagMainVM:SetIsBag(true)

end

function MeetTradeExchangeChoosePanelView:OnDestroy()

end

function MeetTradeExchangeChoosePanelView:OnShow()
	--- 设置文字内容
	self.FTextBlock_123:SetText(LSTR(1490009))
	table.sort(BagMgr.ItemList, BagMgr.SortBagItemPredicate)
	MeetTradeBagMainVM.TabIndex = 1
	MeetTradeBagMainVM:SetIsBag(true)

	--显示背包物品
	MeetTradeBagMainVM:InitShowTabIndex()
	self.VerIconTabs:UpdateItems(self:GetTabMenuList(), MeetTradeBagMainVM.TabIndex)
	self.VerIconTabs:ScrollIndexIntoView(MeetTradeBagMainVM.TabIndex)
	--初始化TableViewChosenItemList
	MeetTradeBagMainVM:UpdateTableViewSelectItemList()
	-- 物品表显示部分魔晶石可交易，因此魔晶石需要预加载
	_G.EquipmentMgr:PreLoadMagicspar()
	---设置数量编辑器
	self.EditQuantity:SetModifyValueCallback(function (Value)
		if CommonUtil.IsObjectValid(self) then
			MeetTradeBagMainVM:SetSelectItemNumForTrade(Value)
		end
	end)
	-- 设置选中状态
	if nil ~= self.Params then
		MeetTradeBagMainVM:SetCurItemByGID(self.Params.ItemGID,self.EditQuantity)
	end
	self.VerIconTabs:SetClickButtonSwitchCallback(self, self.OnClickedTrimButton)
end

function MeetTradeExchangeChoosePanelView:GetTabMenuList()
	local ItemTabs = {}
	if MeetTradeBagMainVM:IsItemTab()  then
		return BagDefine.ItemTabs
	elseif MeetTradeBagMainVM:IsEquipTab() then
		return BagDefine.EquipTabs
	end

	return ItemTabs
end

function MeetTradeExchangeChoosePanelView:OnHide()
	self:OnClickedCallback()
end

function MeetTradeExchangeChoosePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnClickedBackButton)
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnSelectionChangedVerIconTabs)
	UIUtil.AddOnClickedEvent(self, self.CommBtnL_UIBP, self.OnClickedSubmitButton)
	UIUtil.AddOnClickedEvent(self, self.Slot126.Btn, self.OnClickedTipsInfoSlot)
end

function MeetTradeExchangeChoosePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateBagMain)
	self:RegisterGameEvent(EventID.BagInit, self.OnUpdateBagMain)
end

function MeetTradeExchangeChoosePanelView:OnRegisterBinder()
	self:RegisterBinders(MeetTradeBagMainVM, self.Binders)
end

function MeetTradeExchangeChoosePanelView:OnClickedTrimButton()
	table.sort(BagMgr.ItemList, BagMgr.SortBagItemPredicate)
	--self:PlayAnimation(self.AnimTrim)
	if MeetTradeBagMainVM:IsItemTab()  then
		MeetTradeBagMainVM:SetTabToEquip()
		self.VerIconTabs:SetBtnSwitchCheckedState(EToggleButtonState.Checked)
	elseif MeetTradeBagMainVM:IsEquipTab() then
		MeetTradeBagMainVM:SetTabToItem()
		self.VerIconTabs:SetBtnSwitchCheckedState(EToggleButtonState.Unchecked)
	end
	self.VerIconTabs:UpdateItems(self:GetTabMenuList(), MeetTradeBagMainVM.TabIndex)
	self.VerIconTabs:ScrollIndexIntoView(MeetTradeBagMainVM.TabIndex)
end

function MeetTradeExchangeChoosePanelView:OnItemClicked(Index, ItemData, ItemView)
	if nil == ItemData or nil == ItemData.IsSelectedForTrade then
		return
	end 
	MeetTradeBagMainVM:SetCurItem(Index)
	MeetTradeBagMainVM:UpdateTipsInfo()
	if ItemData.IsSelectedForTrade == false then
		MeetTradeBagMainVM:AddItemVMToSelectedList(ItemData)
	end
	---必须在最后更新，参数的设置依赖之前操作带来的更新
	MeetTradeBagMainVM:UpdateCurrentEditQuantitySetting(self.EditQuantity)
end

function MeetTradeExchangeChoosePanelView:OnSelectionChangedVerIconTabs(MenuIndex)
	MeetTradeBagMainVM:SetCurTabIndex(MenuIndex)
	-- self:PlayAnimation(self.AnimSwitchTab)
	self.TableViewBagItemList:ScrollToTop()
end

function MeetTradeExchangeChoosePanelView:OnUpdateBagMain()
	MeetTradeBagMainVM:UpdateTabInfo()
end

function MeetTradeExchangeChoosePanelView:OnClickedBackButton()
	MeetTradeBagMainVM:Reset()
	UIViewMgr:HideView(self.ViewID)
end

function MeetTradeExchangeChoosePanelView:OnClickedSubmitButton()
	MeetTradeBagMainVM:SubmitSelectItemInfo()
	MeetTradeBagMainVM:Reset()
	UIViewMgr:HideView(self.ViewID)
end


function MeetTradeExchangeChoosePanelView:OnClickedTipsInfoSlot()
	local ItemResID = MeetTradeBagMainVM:GetTipsPanelItemResID()
	if ItemResID and ItemResID > 0 then
		ItemTipsUtil.ShowTipsByResID(ItemResID, self.Slot126, nil, nil, nil, self.OnClickedToGetBtnCallback)
	end
end

function MeetTradeExchangeChoosePanelView:OnClickedToGetBtnCallback()
	MsgTipsUtil.ShowTips(LSTR(1490034)) --"对方正处于战斗状态，请稍后再试试吧"
end
return MeetTradeExchangeChoosePanelView