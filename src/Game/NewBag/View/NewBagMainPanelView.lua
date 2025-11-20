---
--- Author: Administrator
--- DateTime: 2023-08-22 03:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BagDefine = require("Game/Bag/BagDefine")
local BagMainVM = require("Game/NewBag/VM/BagMainVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local DepotMgr = require("Game/Depot/DepotMgr")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local DepotVM = require("Game/Depot/DepotVM")
local BagEnlargeCfg = require("TableCfg/BagEnlargeCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ScoreMgr = require("Game/Score/ScoreMgr")
local MsgTipsID = require("Define/MsgTipsID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local EToggleButtonState = _G.UE.EToggleButtonState
local FMath = _G.UE.UKismetMathLibrary
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventID = _G.EventID
local BagMgr = _G.BagMgr
local AetherCurrentsMgr = _G.AetherCurrentsMgr
local LSTR = _G.LSTR
local UKismetInputLibrary = UE.UKismetInputLibrary
local USlateBlueprintLibrary = UE.USlateBlueprintLibrary
local UUIUtil = _G.UE.UUIUtil

---@class NewBagMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagDepotPage NewBagDepotPageView
---@field BtnBag UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnRecovery UFCanvasPanel
---@field BtnRecoveryOK CommBtnSView
---@field BtnRecoveryOff UFCanvasPanel
---@field BtnRetract UFButton
---@field BtnTidy UFButton
---@field CommMoneySlot CommMoneySlotView
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonRedDot CommonRedDotView
---@field FBtn_Drugs UFButton
---@field IconBlank USpacer
---@field ImgBagEmpty UFImage
---@field ImgBagFull UFImage
---@field ImgBagNotFull URadialImage
---@field ImgGold2 UFImage
---@field ImgRecoveryRed UFImage
---@field NewBagItemTips NewBagItemTipsView
---@field NoneTips CommBackpackEmptyView
---@field RecoveryBtn UFButton
---@field RecoveryListPanel UFCanvasPanel
---@field RecoveryOffBtn UFButton
---@field RecoveryPanel UFCanvasPanel
---@field RichTextNumber URichTextBox
---@field TableViewBagItem UTableView
---@field TableViewRecovery UTableView
---@field TextGoldNumber2 UFTextBlock
---@field TextNumber UFTextBlock
---@field TextObtain UFTextBlock
---@field TextSelect UFTextBlock
---@field TextSelectTips UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTidy UFTextBlock
---@field TextTitleName UFTextBlock
---@field TextWarehouseClose UFTextBlock
---@field TextWarehouseOpen UFTextBlock
---@field ToggleBtnWarehouse UToggleButton
---@field ToggleButtonExpand UToggleButton
---@field VerIconTabs CommVerIconTabsView
---@field AnimBagCapacityIncrease UWidgetAnimation
---@field AnimCloseBag UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOpenBag UWidgetAnimation
---@field AnimRecoveryIn UWidgetAnimation
---@field AnimRecoveryListIn UWidgetAnimation
---@field AnimRecoveryListOut UWidgetAnimation
---@field AnimRecoveryOut UWidgetAnimation
---@field AnimSwitchTab UWidgetAnimation
---@field AnimTrim UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagMainPanelView = LuaClass(UIView, true)

function NewBagMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagDepotPage = nil
	--self.BtnBag = nil
	--self.BtnClose = nil
	--self.BtnRecovery = nil
	--self.BtnRecoveryOK = nil
	--self.BtnRecoveryOff = nil
	--self.BtnRetract = nil
	--self.BtnTidy = nil
	--self.CommMoneySlot = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonRedDot = nil
	--self.FBtn_Drugs = nil
	--self.IconBlank = nil
	--self.ImgBagEmpty = nil
	--self.ImgBagFull = nil
	--self.ImgBagNotFull = nil
	--self.ImgGold2 = nil
	--self.ImgRecoveryRed = nil
	--self.NewBagItemTips = nil
	--self.NoneTips = nil
	--self.RecoveryBtn = nil
	--self.RecoveryListPanel = nil
	--self.RecoveryOffBtn = nil
	--self.RecoveryPanel = nil
	--self.RichTextNumber = nil
	--self.TableViewBagItem = nil
	--self.TableViewRecovery = nil
	--self.TextGoldNumber2 = nil
	--self.TextNumber = nil
	--self.TextObtain = nil
	--self.TextSelect = nil
	--self.TextSelectTips = nil
	--self.TextSubtitle = nil
	--self.TextTidy = nil
	--self.TextTitleName = nil
	--self.TextWarehouseClose = nil
	--self.TextWarehouseOpen = nil
	--self.ToggleBtnWarehouse = nil
	--self.ToggleButtonExpand = nil
	--self.VerIconTabs = nil
	--self.AnimBagCapacityIncrease = nil
	--self.AnimCloseBag = nil
	--self.AnimIn = nil
	--self.AnimOpenBag = nil
	--self.AnimRecoveryIn = nil
	--self.AnimRecoveryListIn = nil
	--self.AnimRecoveryListOut = nil
	--self.AnimRecoveryOut = nil
	--self.AnimSwitchTab = nil
	--self.AnimTrim = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagDepotPage)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnRecoveryOK)
	self:AddSubView(self.CommMoneySlot)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.NewBagItemTips)
	self:AddSubView(self.NoneTips)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagMainPanelView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBagItem)

	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)
	self.TableViewAdapter:SetOnDoubleClickedCallback(self.OnItemDoubleClicked)

	self.TableViewAdapter:SetOnTouchCallback(self.OnTouchTableStarted, self.OnTouchTableMoved, self.OnTouchTableEnded)

	self.RecoveryTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRecovery)
	self.RecoveryTableViewAdapter:SetOnClickedCallback(self.OnRecoveryItemClicked)

	self.BagDepotPage.BtnBack:AddBackClick(self, self.OnClickedCallback)

	self.Binders = {
		{"TitleNameText", UIBinderSetText.New(self, self.TextTitleName)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextSubtitle)},
		{"CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{"NoneTipsVisible", UIBinderSetIsVisible.New(self, self.NoneTips) },
		{"PanelDetailVisible", UIBinderSetIsVisible.New(self, self.NewBagItemTips) },

		--{"IsEquipPage", UIBinderSetIsVisible.New(self, self.BtnSwitchGoods, false, true)},
		--{"IsBagPage", UIBinderSetIsVisible.New(self, self.ButtonTrim, false, true)},

		{"OpenDepotBtnVisible", UIBinderSetIsVisible.New(self, self.BtnClose) },

		{"DepotPageVisible", UIBinderSetIsVisible.New(self, self.BagDepotPage) },
		{"BagNotFullVisible", UIBinderSetIsVisible.New(self, self.ImgBagNotFull) },
		{"ImgBagNotFullPercent", UIBinderSetPercent.New(self, self.ImgBagNotFull) },
		{"BagFullVisible", UIBinderSetIsVisible.New(self, self.ImgBagFull) },
		{"CapacityText", UIBinderSetText.New(self, self.TextNumber)},
		{"CapacityTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNumber)},

		--批量回收
		{"RecoveryPanelVisible", UIBinderSetIsVisible.New(self, self.RecoveryPanel) },
		{"RecoveryPanelVisible", UIBinderSetIsVisible.New(self, self.CommMoneySlot) },
        {"BtnRecoveryOffVisible", UIBinderSetIsVisible.New(self, self.BtnRecoveryOff) },
        {"BtnRecoveryVisible", UIBinderSetIsVisible.New(self, self.BtnRecovery) },
		{"RecoveryListPanelVisible", UIBinderSetIsVisible.New(self, self.RecoveryListPanel) },
		{"BtnRecoveryOKEnabled", UIBinderSetIsEnabled.New(self, self.BtnRecoveryOK) },

		{"RecoveryItemVMList", UIBinderUpdateBindableList.New(self, self.RecoveryTableViewAdapter) },
		{"RecoveryNumText", UIBinderSetText.New(self, self.RichTextNumber) },
		{"RecoveryScoreIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgGold2) },
		{"RecoveryGoldText", UIBinderSetTextFormatForMoney.New(self, self.TextGoldNumber2) },
	}
end


function NewBagMainPanelView:OnClickedCallback()
	if UIViewMgr:IsViewVisible(UIViewID.BagItemTips) then
		UIViewMgr:HideView(UIViewID.BagItemTips)
	end

	BagMainVM:SetIsBag(true)
	self.ToggleBtnWarehouse:SetIsChecked(BagMainVM.OpenDepotBtnVisible)
	

	BagMainVM:SetCurItem(1)
	self:SetCurItemInfo(BagMainVM:GetCurItem())
end

function NewBagMainPanelView:OnDestroy()

end

function NewBagMainPanelView:OnShow()
	table.sort(BagMgr.ItemList, BagMgr.SortBagItemPredicate)
	--隐藏批量回收界面
	BagMainVM.IsShowCanRecovery = false
	BagMainVM:SetRecoveryPanelVisible(false)

	BagMainVM.TabIndex = 1
	BagMainVM:SetIsBag(true)
	self.ToggleBtnWarehouse:SetIsChecked(BagMainVM.OpenDepotBtnVisible)
	--_G.UE.FProfileTag.StaticBegin(string.format("ShowView_SetTab"))

	--显示背包物品
	BagMainVM:InitShowTabIndex()
	self.VerIconTabs:UpdateItems(self:GetTabMenuList(), BagMainVM.TabIndex)
	self.VerIconTabs:ScrollIndexIntoView(BagMainVM.TabIndex)
	self.NoneTips:SetTipsContent(LSTR(990040))
	BagMainVM:UpdateBagCapacity()

	--_G.UE.FProfileTag.StaticEnd()

	BagMgr:SendMsgBagInfoReq()
	BagMgr:SendMsgBagItemCDInfo(0) --同步物品Cd
	AetherCurrentsMgr:SyncBagItemCDWhenOpenPanel() -- 打开界面同步风脉仪CD

	self.CommMoneySlot:UpdateView(BagMgr.RecoveryScoreID, false, UIViewID.BagMain, true)

	-- 魔晶石预加载
	_G.EquipmentMgr:PreLoadMagicspar()
	_G.SettingsHandleMgr:SwitchOpenCloseVirtualCursor(true)
end

function NewBagMainPanelView:GetTabMenuList()
	local ItemTabs = {}
	if BagMainVM:IsItemTab()  then
		return BagDefine.ItemTabs
	elseif BagMainVM:IsEquipTab() then
		return BagDefine.EquipTabs
	end

	return ItemTabs
end


function NewBagMainPanelView:OnHide()
	self:OnClickedCallback()
	_G.ObjectMgr:CollectGarbage(false)
	_G.SettingsHandleMgr:SwitchOpenCloseVirtualCursor(false)
end

function NewBagMainPanelView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.ButtonTrim, self.OnClickedTrimButton)
	--UIUtil.AddOnClickedEvent(self, self.BtnSwitchGoods, self.OnClickedTrimButton)


	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnSelectionChangedVerIconTabs)

	UIUtil.AddOnClickedEvent(self, self.ToggleBtnWarehouse, self.OnClickedClickDepot)

	UIUtil.AddOnClickedEvent(self, self.BtnBag, self.OnBtnExpand) --扩容
	UIUtil.AddOnClickedEvent(self, self.FBtn_Drugs, self.OnDrugsClicked) --药品设置
	UIUtil.AddOnClickedEvent(self, self.RecoveryBtn, self.OnRecoveryClicked) --批量删除
    UIUtil.AddOnClickedEvent(self, self.RecoveryOffBtn, self.OnRecoveryOffClicked) --批量删除不可用
	UIUtil.AddOnClickedEvent(self, self.BtnRetract, self.OnBtnRetractClicked)

	UIUtil.AddOnClickedEvent(self, self.ToggleButtonExpand, self.OnClickedButtonExpand)

	UIUtil.AddOnClickedEvent(self, self.BtnRecoveryOK.Button, self.OnBtnRecoveryOKClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnTidy, self.OnBtnTydyClicked)

	self.VerIconTabs:SetClickButtonSwitchCallback(self, self.OnClickedTrimButton)
end

function NewBagMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BagBuyCapacity, self.OnUpdateBagMainByCapacityIncrease)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateBagMain)
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
	self:RegisterGameEvent(EventID.MagicsparInlaySucc, self.OnInlaySucc)
	self:RegisterGameEvent(EventID.MagicsparUnInlaySucc, self.OnInlaySucc)
	self:RegisterGameEvent(EventID.BagInit, self.OnUpdateBagMain)
end

function NewBagMainPanelView:OnRegisterBinder()
	
	self:RegisterBinders(BagMainVM, self.Binders)
	self.TextTitleName:SetText(LSTR(990052))
	self.TextWarehouseClose:SetText(LSTR(990082))
	self.TextWarehouseOpen:SetText(LSTR(990083))
	self.NoneTips:SetTipsContent(LSTR(990040))
	self.TextSelectTips:SetText(LSTR(990084))
	self.TextObtain:SetText(LSTR(990086))
	self.TextSelect:SetText(LSTR(990085))
	self.BtnRecoveryOK:SetBtnName(LSTR(990047))
	self.TextTidy:SetText(LSTR(990133))
end

function NewBagMainPanelView:OnClickedTrimButton()
	table.sort(BagMgr.ItemList, BagMgr.SortBagItemPredicate)
	--self:PlayAnimation(self.AnimTrim)
	if BagMainVM:IsItemTab()  then
		BagMainVM:SetTabToEquip()
		self.VerIconTabs:SetBtnSwitchCheckedState(EToggleButtonState.Checked)
		self.NoneTips:SetTipsContent(LSTR(990041))
	elseif BagMainVM:IsEquipTab() then
		BagMainVM:SetTabToItem()
		self.VerIconTabs:SetBtnSwitchCheckedState(EToggleButtonState.Unchecked)
		self.NoneTips:SetTipsContent(LSTR(990040))
	end
	self.VerIconTabs:UpdateItems(self:GetTabMenuList(), BagMainVM.TabIndex)
	self.VerIconTabs:ScrollIndexIntoView(BagMainVM.TabIndex)

	_G.ObjectMgr:CollectGarbage(false, true, false)
end

function NewBagMainPanelView:OnItemClicked(Index, ItemData, ItemView)
	self.StarTouchPos = nil
	if ItemData == nil then
		return
	end 

	--处理物品回收
	if BagMainVM.IsRecovery == true then
		if ItemData.IsMask == false then
			if BagMainVM.RecoveryList[ItemData.GID] == nil then
				if BagMainVM:IsRecoveryNumExceedLimit() then
					MsgTipsUtil.ShowTips(LSTR(990042))
					return
				end

				BagMainVM:AddItemToRecoveryList(ItemData.GID, ItemData.Item)
			else
				BagMainVM:RemoveItemFromRecoveryList(ItemData.GID)
			end
		else
			if _G.EquipmentMgr:IsEquipHasMagicspar(ItemData.GID) then
				MsgTipsUtil.ShowTipsByID(MsgTipsID.EquipmentWithMagicsparDropOrRecycle)
			end
			return
		end
	end

	if UIViewMgr:IsViewVisible(UIViewID.BagItemTips) then
		UIViewMgr:HideView(UIViewID.BagItemTips)
	end

	BagMainVM:SetCurItem(Index)
	local CurItem = BagMainVM:GetCurItem()
	self:SetCurItemInfo(CurItem)
	if CurItem then
		if BagMainVM.IsBag == false then

			local function Callback()
				BagMainVM:SetCurItem(0)
			end

			local Params = {ItemData = CurItem, SlotView = ItemView, HideCallback = Callback}
			UIViewMgr:ShowView(UIViewID.BagItemTips, Params)
		end
	end
end

function NewBagMainPanelView:OnRecoveryItemClicked(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end
	BagMainVM:RemoveItemFromRecoveryList(ItemData.GID)
end

function NewBagMainPanelView:OnItemDoubleClicked(Index, ItemData, ItemView)
	self.StarTouchPos = nil
	if ItemData == nil then
		return
	end
	if BagMainVM.IsBag == false then
		BagMgr:SendMsgBagTransDepot(ItemData.GID, DepotVM:GetCurDepotIndex(), 0)
	end
end


function NewBagMainPanelView:OnTouchTableStarted(TableName, InGeometry, InTouchEvent)
	if not self:CapCondFunc(TableName) then
		return 
	end

	local PointerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	if not self:CheckPointIdx(PointerIndex) then
		return 
	end

	local ScreenSpacePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)

	self.StarTouchPos = LocalPosition
	--_G.FLOG_INFO('NewBagMainPanelView:OnTouchTableStarted X  = ' .. tostring(self.StarTouchPos.X) .. " Y = " .. tostring(self.StarTouchPos.Y))
	
	
end

function NewBagMainPanelView:CapCondFunc(TableName)
	if BagMainVM.RecoveryPanelVisible == false then
		return false
	end
	if self.TableViewAdapter == nil then
		return false
	end

	return self.TableViewAdapter.WidgetName == TableName
end


function NewBagMainPanelView:OnTouchTableMoved(TableName, InGeometry, InTouchEvent)
	if not self:CapCondFunc(TableName) then
		return 
	end

	local PointerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	if not self:CheckPointIdx(PointerIndex) then
		return
	end

	local ScreenSpacePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)
	if self.StarTouchPos == nil then
		self.StarTouchPos = LocalPosition
	else
		self:SelectItemsByTouchMoved(self.StarTouchPos, LocalPosition)
	end
	--_G.FLOG_INFO('NewBagMainPanelView:OnTouchTableMoved X = ' .. tostring(LocalPosition.X) .. " Y = " .. tostring(LocalPosition.Y))

end

function NewBagMainPanelView:OnTouchTableEnded(TableName, InGeometry, InTouchEvent)
	self.StarTouchPos = nil
	if not self:CapCondFunc(TableName) then
		return 
	end

	if BagMainVM:IsRecoveryNumExceedLimit() then
		MsgTipsUtil.ShowTips(LSTR(990042))
		return
	end
end

function NewBagMainPanelView:CheckPointIdx(PointIdx)
	if PointIdx == -99 then
		return false
	end
	return true
end

function NewBagMainPanelView:SelectItemsByTouchMoved(StarTouchPos, CurTouchPos)
	if BagMainVM:IsRecoveryNumExceedLimit() then
		return
	end

	if self.TableViewAdapter ~= nil then
		local ItemViewList = self.TableViewAdapter.ItemViewList
		if nil ~= ItemViewList then
			for _, Widget in ipairs(ItemViewList) do
				if Widget.Params and Widget.Params.Data then
					local ItemVM = Widget.Params.Data
					local TargetWidgetSize = UUIUtil.GetLocalSize(Widget)
					if math.abs(StarTouchPos.X - CurTouchPos.X) < TargetWidgetSize.X then
						return
					end
					if ItemVM.IsMask == false and BagMainVM.RecoveryList[ItemVM.GID] == nil then
						--local TargetWidgetSize = UUIUtil.GetLocalSize(Widget)
						local TargetWidgetPosition = UIUtil.GetWidgetPosition(Widget)
						local MinX = math.max(TargetWidgetPosition.X - TargetWidgetSize.X, math.min(StarTouchPos.X, CurTouchPos.X))
						local MinY = math.max(TargetWidgetPosition.Y - TargetWidgetSize.Y, math.min(StarTouchPos.Y, CurTouchPos.Y))
		
						local MaxX = math.min(TargetWidgetPosition.X, math.max(StarTouchPos.X, CurTouchPos.X))
						local MaxY = math.min(TargetWidgetPosition.Y, math.max(StarTouchPos.Y, CurTouchPos.Y))
		
						if MinX <= MaxX and MinY <= MaxY then
							if BagMainVM:IsRecoveryNumExceedLimit() then
								return
							end
							BagMainVM:AddItemToRecoveryList(ItemVM.GID, ItemVM.Item)
						end
					end
				end

			end
		end
	end
end

function NewBagMainPanelView:OnSelectionChangedVerIconTabs(MenuIndex)
	BagMainVM:SetCurTabIndex(MenuIndex)
	self:SetCurItemInfo(BagMainVM:GetCurItem())

	if BagMainVM.IsBag == false then
		BagMainVM:SetCurItem(0)
	end
	self:PlayAnimation(self.AnimSwitchTab)
	self.TableViewAdapter:ScrollToTop()

	_G.ObjectMgr:CollectGarbage(false, true, false)
end


function NewBagMainPanelView:OnClickedClickDepot()
	if BagMainVM.IsShowCanRecovery == false then
		if BagMainVM.OpenDepotBtnVisible == true then
			self:OnClickedOpenDepot()
		else
			self:OnClickedCloseDepot()
		end
	end
	
end

function NewBagMainPanelView:OnClickedOpenDepot()
	if DepotMgr:CheckCanOpDepot(true) then
		BagMainVM:SetIsBag(false)
		BagMainVM:SetCurItem(0)
		self.ToggleBtnWarehouse:SetIsChecked(false)
	end
	BagMainVM:UpdateTabInfo()
	self:PlayAnimation(self.AnimOpenBag)

end

function NewBagMainPanelView:OnClickedCloseDepot()
	if UIViewMgr:IsViewVisible(UIViewID.BagItemTips) then
		UIViewMgr:HideView(UIViewID.BagItemTips)
	end
	self.ToggleBtnWarehouse:SetIsChecked(true)

	BagMainVM:SetIsBag(true)
	BagMainVM:UpdateTabInfo()

	BagMainVM:SetCurItem(1)
	self:SetCurItemInfo(BagMainVM:GetCurItem())
	self:PlayAnimation(self.AnimCloseBag)

end

function NewBagMainPanelView:SetCurItemInfo(CurItem)
	if CurItem then
		self.NewBagItemTips:UpdateItem(CurItem)
	end
end

function NewBagMainPanelView:OnUpdateBagMainByCapacityIncrease()
	self:PlayAnimation(self.AnimBagCapacityIncrease)
	self:OnUpdateBagMain()
end

function NewBagMainPanelView:OnUpdateBagMain()
	BagMainVM:UpdateTabInfo()
	BagMainVM:UpdateBagCapacity()

	local LastItemIndex = BagMainVM.ItemIndex or 0
	if BagMainVM.IsBag == false then
		BagMainVM:SetCurItem(0)
	else
		local CurItem = BagMainVM:GetCurItem()
		--当前物品为空则默认选中第一个物品
		if CurItem == nil then
			if LastItemIndex  > BagMgr:CalcBagUseCapacity()  and LastItemIndex > 1 then
				BagMainVM:SetCurItem(LastItemIndex - 1)
			else
				BagMainVM:SetCurItem(LastItemIndex)
			end
	
			self:SetCurItemInfo(BagMainVM:GetCurItem())
		else
			BagMainVM:SetCurItem(BagMainVM.ItemIndex)
			self:SetCurItemInfo(CurItem)
		end
	end

end

function NewBagMainPanelView:SetCurItemActionMenu()
	BagMainVM:SwitchItemMore(false)
end

function NewBagMainPanelView:OnBtnExpand()
	local EnlargeCfg = BagEnlargeCfg:FindCfgByKey(BagMgr.Enlarge)
	-- 背包扩容已达到上限
	if EnlargeCfg == nil then
		MsgTipsUtil.ShowErrorTips(LSTR(990043), 1)
		return
	end

	UIViewMgr:ShowView(UIViewID.BagExpandWin)
end

--药品设置
function NewBagMainPanelView:OnDrugsClicked()
	UIViewMgr:ShowView(UIViewID.BagDrugsSetPanel)
end



---批量回收
function NewBagMainPanelView:OnRecoveryClicked()
	if BagMainVM.IsBag == true then
		self.ToggleButtonExpand:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
		BagMainVM:SetRecoveryPanelVisible(true)
		BagMainVM.RecoveryListPanelVisible = false
		BagMainVM.IsShowCanRecovery = true
		BagMainVM:UpdateTabInfo()
		BagMainVM:SetCurItem(BagMainVM.ItemIndex or 1)

		self:PlayAnimation(self.AnimRecoveryIn)
	end
end

function NewBagMainPanelView:OnMoneyUpdate()
	self.CommMoneySlot:UpdateView(BagMgr.RecoveryScoreID, false, UIViewID.BagMain, true)
end

function NewBagMainPanelView:OnInlaySucc()
	self:SetCurItemInfo(BagMainVM:GetCurItem())
end

function NewBagMainPanelView:OnRecoveryOffClicked()
	MsgTipsUtil.ShowTips(LSTR(990044))
end

function NewBagMainPanelView:OnBtnRetractClicked()
	BagMainVM:SetRecoveryPanelVisible(false)
	BagMainVM.IsShowCanRecovery = false
	BagMainVM:UpdateTabInfo()

	BagMainVM:SetCurItem(1)
	self:SetCurItemInfo(BagMainVM:GetCurItem())

	self:PlayAnimation(self.AnimRecoveryOut)
end

function NewBagMainPanelView:OnClickedButtonExpand()
	BagMainVM.RecoveryListPanelVisible = not BagMainVM.RecoveryListPanelVisible
	if BagMainVM.RecoveryListPanelVisible == true then
		self.ToggleButtonExpand:SetCheckedState(_G.UE.EToggleButtonState.checked)
		self:PlayAnimation(self.AnimRecoveryListIn)
	else
		self.ToggleButtonExpand:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
		self:PlayAnimation(self.AnimRecoveryListOut)
	end

end

function NewBagMainPanelView:OnBtnRecoveryOKClicked()
	local CurGoldCount = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    local MaxGoldCount = ScoreMgr:GetScoreMaxValue(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    if CurGoldCount + BagMainVM.RecoveryGoldText > MaxGoldCount then
		MsgTipsUtil.ShowTips(LSTR(990045))
        return
    end

	self:OnRecoveryConfirm()
	
end

function NewBagMainPanelView:OnRecoveryConfirm()
	local function Callback()
		self:OnRecoveryActionOk()
	end

	local HighValueItems = BagMainVM:GetRecoveryHighValueItems()
	if #HighValueItems > 0 then
		local Message = LSTR(990046)
		local RecoveryItems = BagMainVM:GetRecoveryItems()
		if #RecoveryItems > 7 then
			_G.UIViewMgr:ShowView(_G.UIViewID.BagItemListActionTips, {Title = LSTR(990047), Message = Message, MultiItemList = BagMainVM:GetRecoveryItems(), ClickedOkAction = Callback})
		else
			_G.UIViewMgr:ShowView(_G.UIViewID.BagItemListActionTips, {Title = LSTR(990047), Message = Message, SingleItemList = BagMainVM:GetRecoveryItems(), ClickedOkAction = Callback})
		end
	else
		self:OnRecoveryActionOk()
	end
end

function NewBagMainPanelView:OnRecoveryActionOk()
	BagMgr:SendMsgBatchRecoveryReq(BagMainVM:GetRecoveryListGIDs())
	self:OnBtnRetractClicked()
end

function NewBagMainPanelView:OnBtnTydyClicked()
	local RecoveryList = BagMainVM.RecoveryList
	local function RightCallBack()
		BagMainVM.RecoveryList = {}
		BagMainVM:UpdateRecoveryItemList()
		BagMainVM:UpdateTabInfo()
		BagMainVM:SetCurItem(1)
		self:SetCurItemInfo(BagMainVM:GetCurItem())
		_G.UIViewMgr:ShowView(_G.UIViewID.BagTidyWin)
    end

	if next(RecoveryList) then
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(990134), RightCallBack, nil, LSTR(10003), LSTR(10002))
	else
		_G.UIViewMgr:ShowView(_G.UIViewID.BagTidyWin)
	end
end


function NewBagMainPanelView:SequenceEvent_AnimBagCapacityIncrease()
	local BagCount = BagMgr:CalcBagUseCapacity()
	local ValueAnim = self:GetAnimBagCapacityIncreaseProgress() -- 蓝图函数，会跟随动画从0涨到1
	local Capacity = tostring(FMath.round(FMath.lerp( BagMgr.Capacity -  BagMgr.Enlarge, BagMgr.Capacity, ValueAnim))) -- OldCapacity为之前的上限
	local FinalText = string.format("%d/%d", BagCount, Capacity)
	self.TextNumber:SetText(FinalText)
end

return NewBagMainPanelView