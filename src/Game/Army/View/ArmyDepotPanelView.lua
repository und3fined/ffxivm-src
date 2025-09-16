---
--- Author: Administrator
--- DateTime: 2023-12-01 16:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ItemCfg = require("TableCfg/ItemCfg")
local BagDefine = require("Game/Bag/BagDefine")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMgr = nil
local ProtoCommon = require("Protocol/ProtoCommon")
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local EToggleButtonState = _G.UE.EToggleButtonState

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventID = _G.EventID
local BagMgr = _G.BagMgr
local LSTR = _G.LSTR
local ArmyDepotPanelVM = nil

---@class ArmyDepotPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyDepotPageNew ArmyDepotPageNewView
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field NoneTips CommBackpackEmptyView
---@field RichTextRemainder URichTextBox
---@field TableViewBagItem UTableView
---@field TextRemainder UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---@field AnimNoneTipsIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSwitchTab UWidgetAnimation
---@field AnimTrim UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyDepotPanelView = LuaClass(UIView, true)

function ArmyDepotPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyDepotPageNew = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.NoneTips = nil
	--self.RichTextRemainder = nil
	--self.TableViewBagItem = nil
	--self.TextRemainder = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--self.AnimNoneTipsIn = nil
	--self.AnimOut = nil
	--self.AnimSwitchTab = nil
	--self.AnimTrim = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyDepotPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyDepotPageNew)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.NoneTips)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyDepotPanelView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBagItem)

	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)
	self.TableViewAdapter:SetOnDoubleClickedCallback(self.OnItemDoubleClicked)
	ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
	--- 缓存的已点击表，防止快速点击带来的重复发送
	self.DoubleClickedItemList = {}
	--ArmyDepotPanelVM:InitBagItemCache(BagMgr.Capacity)
	self.Binders = {
		{"TitleNameText", UIBinderValueChangedCallback.New(self, nil, self.OnTextTitleNameChanged)},
		{"CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{"NoneTipsVisible", UIBinderSetIsVisible.New(self, self.NoneTips) },
	}
	
end

function ArmyDepotPanelView:OnDestroy()

end

function ArmyDepotPanelView:OnShow()
	if self.Params and self.Params.IsOuterOpen then
		--self.IsOuterOpen = true
		self.ArmyDepotPageNew.IsOuterOpen = true
	else
		self.ArmyDepotPageNew.IsOuterOpen = false
	end
	-- LSTR string:没有可显示的道具
	self.NoneTips:SetTipsContent(LSTR(910282))

	UIUtil.SetIsVisible(self.CommonTitle, true)
	self.CommonTitle:SetSubTitleIsVisible(true)
	-- LSTR string:双击道具快捷取出或存放
	self.CommonTitle:SetTextSubtitle(LSTR(910419))

	self.VerIconTabs:SetIsSwitchPanelVisible(true)
	--ArmyDepotPanelVM:SetBagAllItem(BagMgr.Capacity)
	--显示背包物品
	ArmyDepotPanelVM:SetTabToItem()
	self.VerIconTabs:UpdateItems(self:GetTabMenuList(), ArmyDepotPanelVM.TabIndex)
	self.VerIconTabs:SetClickButtonSwitchCallback(self, self.OnClickedTrimButton)
	ArmyDepotPanelVM:SetTextTitle()
	--ArmyDepotPanelVM:SetCountPrice()
	ArmyDepotPanelVM:UpdateDepotPermissionsStatus()
	---屏蔽掉不需要显示的UI
	if self.ArmyItemTips then
		UIUtil.SetIsVisible(self.ArmyItemTips, false)
	end
end

-- function ArmyDepotPanelView:SetRichTextRemainder()
-- 	self.RichTextRemainder:SetText(ArmyDepotPanelVM:GetCounterGetItemsAllPrice(.."/"..ArmyDepotPanelVM:GetMaxGetItemsAllPrice()))
-- end

function ArmyDepotPanelView:GetTabMenuList()
	local ItemTabs = {}
	if ArmyDepotPanelVM:IsItemTab()  then
		return ArmyDefine.ItemTabs
	elseif ArmyDepotPanelVM:IsEquipTab() then
		return ArmyDefine.EquipTabs
	end

	return ItemTabs
end

function ArmyDepotPanelView:OnSelectionChangedVerIconTabs(MenuIndex)

	ArmyDepotPanelVM:SetCurTabIndex(MenuIndex)

	ArmyDepotPanelVM:SetCurItemIndex(0)
	ArmyDepotPanelVM:SetTextTitle()

	self:PlayAnimation(self.AnimSwitchTab)
end


function ArmyDepotPanelView:OnItemDoubleClicked(Index, ItemData, ItemView)
	local ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
	if ArmyDepotPageVM then
		local ItemResID = ItemData.ResID
		local Cfg = ItemCfg:FindCfgByKey(ItemResID)
		if Cfg == nil then
			return
		end
		---限时物品判断
		local IsTimeLimitItem =  BagMgr:IsTimeLimitItem(ItemData.Item)
		if ArmyDepotPageVM:GetDepotNumState() == ArmyDefine.DepotNumState.Full then
			---todo 后续提示看要不要都走配表
			-- LSTR string:仓库空间不足
			MsgTipsUtil.ShowTips(LSTR(910036))
		elseif not ArmyDepotPanelVM:IsAvailableCurDepot() then
			---暂无权限，请联系管理者
			MsgTipsUtil.ShowTipsByID(145010)
		elseif Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY and not ItemData.IsBind and not IsTimeLimitItem then
			for _, GID in ipairs(self.DoubleClickedItemList) do
				if ItemData.GID == GID then
					return
				end
			end
			table.insert(self.DoubleClickedItemList, ItemData.GID)
			self:RegisterTimer(function() 
				if #self.DoubleClickedItemList > 0  then 
					table.remove(self.DoubleClickedItemList, 1) 
				end 
			end, 0.6)
			ArmyMgr:SendGroupStoreDepositItemAndCheck(ArmyDepotPageVM:GetCurDepotIndex(), ItemData.GID, ItemData.Num, ItemData.ResID)
		else
			---该物品不可存入
			MsgTipsUtil.ShowTipsByID(145083)
		end
	end
end

function ArmyDepotPanelView:OnItemClicked(Index, ItemData, ItemView)
	
	if UIViewMgr:IsViewVisible(UIViewID.ArmyItemTips) then
		UIViewMgr:HideView(UIViewID.ArmyItemTips)
	end

	ArmyDepotPanelVM:SetCurItemIndex(Index)
	local CurItem = ArmyDepotPanelVM:GetCurItem()
	
	if CurItem then
		local function Callback()
			ArmyDepotPanelVM:SetCurItemIndex(0)
		end

		local Params = {ItemData = CurItem, SlotView = ItemView, HideCallback = Callback, IsBag = true}
		-- for _, GID in ipairs(self.DoubleClickedItemList) do
		-- 	if CurItem.GID == GID then
		-- 		ArmyDepotPanelVM:SetCurItemIndex(0)
		-- 		return
		-- 	end
		-- end
		UIViewMgr:ShowView(UIViewID.ArmyItemTips, Params)
	end
end

function ArmyDepotPanelView:OnClickedTrimButton()
	self:PlayAnimation(self.AnimTrim)
	if ArmyDepotPanelVM:IsItemTab()  then
		ArmyDepotPanelVM:SetTabToEquip()
		self.VerIconTabs:SetBtnSwitchCheckedState(EToggleButtonState.Checked)
	elseif ArmyDepotPanelVM:IsEquipTab() then
		ArmyDepotPanelVM:SetTabToItem()
		self.VerIconTabs:SetBtnSwitchCheckedState(EToggleButtonState.Unchecked)
	end
	self.VerIconTabs:UpdateItems(self:GetTabMenuList(), ArmyDepotPanelVM.TabIndex)
end

function ArmyDepotPanelView:OnUpdateBag()
	ArmyDepotPanelVM:SetCurTabIndex(ArmyDepotPanelVM.TabIndex)
	if UIViewMgr:IsViewVisible(UIViewID.ArmyItemTips) then
		UIViewMgr:HideView(UIViewID.ArmyItemTips)
	end
end
function ArmyDepotPanelView:OnTextTitleNameChanged(TitleNameText)
	self.CommonTitle:SetTextTitleName(TitleNameText)
end

function ArmyDepotPanelView:OnHide()
	---防止快速点击导致的错误显示
	UIViewMgr:HideView(UIViewID.ArmyItemTips)
	self:UnRegisterAllTimer()
	self.DoubleClickedItemList = {}
end

function ArmyDepotPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnSelectionChangedVerIconTabs)
end

function ArmyDepotPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateBag)
end

function ArmyDepotPanelView:OnRegisterBinder()
	self:RegisterBinders(ArmyDepotPanelVM, self.Binders)
end

return ArmyDepotPanelView