---
--- Author: skysong
--- DateTime: 2025-05-06 14:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local HouseMainPanelVM = require("Game/House/VM/HouseMainPanelVM")
local HouseCommon = require("Game/House/HouseCommon")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local TipsUtil = require("Utils/TipsUtil")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local HouseUtil = require("Game/House/HouseUtil")
local ProtoRes = require("Protocol/ProtoRes")

local UE = _G.UE
local UHousingMgr = _G.UE.UHousingMgr

---@class HouseMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnDecorate UFButton
---@field BtnMore UFButton
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommBackpackEmptyS CommBackpackEmptyView
---@field CommonTitle CommonTitleView
---@field ControlPanel MainControlPanelView
---@field FHorizontalText UFHorizontalBox
---@field HouseCommMenu HouseCommMenuView
---@field HouseDecoratePanel HouseDecoratePanelView
---@field HouseMovePanel HouseMovePanelView
---@field HouseSlotItemTips HouseSlotItemTipsView
---@field PanelDecorate UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PanelMore UFCanvasPanel
---@field RichTextBoxWarehouse URichTextBox
---@field RichTextBoxlayout URichTextBox
---@field Spacer2 USpacer
---@field TableViewSlotL UTableView
---@field ToggleBtnArrow UToggleButton
---@field ToggleBtnGrid UToggleButton
---@field ToggleBtnTable UToggleButton
---@field ToggleBtnUI UToggleButton
---@field AnimControlIn UWidgetAnimation
---@field AnimDecorate UWidgetAnimation
---@field AnimDecorateHide UWidgetAnimation
---@field AnimDecorateOut UWidgetAnimation
---@field AnimDecorateShow UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMainIn UWidgetAnimation
---@field AnimMainOut UWidgetAnimation
---@field AnimMainSwitch UWidgetAnimation
---@field Expand UWidgetAnimation
---@field Shrink UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseMainPanelView = LuaClass(UIView, true)

function HouseMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnDecorate = nil
	--self.BtnMore = nil
	--self.CommBackpackEmpty = nil
	--self.CommBackpackEmptyS = nil
	--self.CommonTitle = nil
	--self.ControlPanel = nil
	--self.FHorizontalText = nil
	--self.HouseCommMenu = nil
	--self.HouseDecoratePanel = nil
	--self.HouseMovePanel = nil
	--self.HouseSlotItemTips = nil
	--self.PanelDecorate = nil
	--self.PanelMain = nil
	--self.PanelMore = nil
	--self.RichTextBoxWarehouse = nil
	--self.RichTextBoxlayout = nil
	--self.Spacer2 = nil
	--self.TableViewSlotL = nil
	--self.ToggleBtnArrow = nil
	--self.ToggleBtnGrid = nil
	--self.ToggleBtnTable = nil
	--self.ToggleBtnUI = nil
	--self.AnimControlIn = nil
	--self.AnimDecorate = nil
	--self.AnimDecorateHide = nil
	--self.AnimDecorateOut = nil
	--self.AnimDecorateShow = nil
	--self.AnimIn = nil
	--self.AnimMainIn = nil
	--self.AnimMainOut = nil
	--self.AnimMainSwitch = nil
	--self.Expand = nil
	--self.Shrink = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommBackpackEmptyS)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.ControlPanel)
	self:AddSubView(self.HouseCommMenu)
	self:AddSubView(self.HouseDecoratePanel)
	self:AddSubView(self.HouseMovePanel)
	self:AddSubView(self.HouseSlotItemTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseMainPanelView:OnInit()
	self.RightBarExpend = true
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlotL,self.OnPropsListSelectChanged, true, false)

	self.Binders = {
		{"CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{"CommBackpackEmptyVisible", UIBinderSetIsVisible.New(self, self.CommBackpackEmpty) },
		{"CommBackpackEmptySVisible", UIBinderSetIsVisible.New(self, self.CommBackpackEmptyS) },
		{"TitleText", UIBinderSetText.New(self, self.CommonTitle.TextTitleName) },
		{"ShowTitleEntity",UIBinderSetIsVisible.New(self, self.CommonTitle)},
		{"RichTextBoxlayoutText",UIBinderSetText.New(self, self.RichTextBoxlayout)},
		{"RichTextBoxWarehouseText",UIBinderSetText.New(self, self.RichTextBoxWarehouse)},
		{"HouseDecoratePanelVisible",UIBinderSetIsVisible.New(self, self.HouseDecoratePanel)},
		{"HouseMovePanelVisible",UIBinderSetIsVisible.New(self, self.HouseMovePanel)},
		{"PanelDecorateVisible",UIBinderSetIsVisible.New(self, self.PanelDecorate)},
		{"ToggleBtnGridlVisible",UIBinderSetIsVisible.New(self, self.ToggleBtnGrid,false,true)},
		{"ToggleBtnTableVisible",UIBinderSetIsVisible.New(self, self.ToggleBtnTable,false,true)},
		{"TableViewSlotLVisible",UIBinderSetIsVisible.New(self, self.TableViewSlotL)},
		{"ToggleBtnArrowVisible",UIBinderSetIsVisible.New(self, self.ToggleBtnArrow)},
		{"BtnBackVisible",UIBinderSetIsVisible.New(self,self.BtnBack)},
		{"IsToggleChecked", UIBinderSetIsChecked.New(self, self.ToggleBtnArrow,true)},
		{"BtnCloseVisible",UIBinderSetIsVisible.New(self, self.BtnClose)},
		{"BtnBackVisible",UIBinderSetIsVisible.New(self, self.BtnBack)},
		{"PanelMainVisible",UIBinderSetIsVisible.New(self, self.PanelMain)},
	}

	HouseMainPanelVM:UpdateDepotInfo()
	HouseMainPanelVM:UpdatePlacedInfo()
end

function HouseMainPanelView:OnDestroy()

end

function HouseMainPanelView:OnShow()
	--更新一下仓库最大值
	_G.HousingMgr:SetDepotCapacity()
	self:UpdateView(false)
	self.HouseDecoratePanel.Parent = self
	self.CommBackpackEmptyS.RichTextNone:SetText(LSTR(1640145))
	self.CommBackpackEmpty.RichTextNone:SetText(LSTR(1640145))

	UIUtil.SetIsVisible(self.ToggleBtnArrow, true, true)
	UIUtil.SetIsVisible(self.PanelMore, true, true)

	self.ToggleBtnTable:SetChecked(true, false)
end

function HouseMainPanelView:OnHide()
	HouseMainPanelVM:SetHouseDecoratePanelVisible(false)
	HouseMainPanelVM.HouseMovePanelVisible = false
	_G.HousingMgr.TemporaryHosingObjectGID = 0
	_G.HousingMgr.TemporaryHosingObjectResID = 0
	HouseMainPanelVM.OpenTableState = true
	local HousingMgrInstance = UHousingMgr:Get()
	if HousingMgrInstance ~= nil then
		HousingMgrInstance:EndPreviewMode()
		HousingMgrInstance:SetMountMode(false)
		_G.HousingMgr:SendHouseFinishEditReq()
	end
end

function HouseMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnArrow, self.OnToggleStateChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.HouseCommMenu, self.OnMenuTreeViewTabsSelectChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnDecorate, self.OnClickDecorate)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnGrid, self.OnToggleBtnGridStateChanged)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnTable, self.OnToggleBtnTableStateChanged)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnUI, self.OnToggleBtnUIStateChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickMore)
	UIUtil.AddOnClickedEvent(self, self.BtnClose.Btn_Close,self.OnClose)
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button,self.OnBack)
end

function HouseMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ShowHouseItemTips, self.ShowHouseItemTips)
	self:RegisterGameEvent(EventID.HideHouseItemTips, self.HideHouseItemTips)
	self:RegisterGameEvent(EventID.BagUpdateForHouse,self.BagUpdate)
	self:RegisterGameEvent(EventID.UpdateHouseItems,self.UpdateHouseItems)
	self:RegisterGameEvent(EventID.DepotUpdate,self.DepotUpdate)
	self:RegisterGameEvent(EventID.DecorateSlotUpdate,self.DecorateSlotUpdate)
	self:RegisterGameEvent(EventID.EnterHouseFurniturePreview,self.EnterHouseFurniturePreview)
	self:RegisterGameEvent(EventID.ExitHouseFurniturePreview,self.ExitHouseFurniturePreview)
	self:RegisterGameEvent(EventID.ExitHouseRange,self.OnExitHouseRange)
	self:RegisterGameEvent(EventID.ChangeHouseEditRole,self.OnExitHouseRange)
	self:RegisterGameEvent(EventID.PutFurnitureSucc,self.OnPutFurnitureSucc)
	self:RegisterGameEvent(EventID.RemoveFurniture,self.OnPutFurnitureSucc)
	self:RegisterGameEvent(EventID.MoveFurnitureSucc,self.MoveFurnitureSucc)
end

function HouseMainPanelView:OnRegisterBinder()
	self:RegisterBinders(HouseMainPanelVM, self.Binders)
end

function HouseMainPanelView:OnToggleStateChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	_G.HousingMgr:SetRightBarExpend(IsChecked)

	--63 102 0 48
	--471 102 0 48471387

	-- -15 -35
	-- 387 -35

	if IsChecked then
		self:PlayAnimation(self.Expand, 0, 1)

		if HouseMainPanelVM.CurrentItemVMList:Length() == 0 then
			HouseMainPanelVM.CommBackpackEmptySVisible = false
			HouseMainPanelVM.CommBackpackEmptyVisible = true
		end
	else
		self:PlayAnimation(self.Shrink, 0, 1)

		if HouseMainPanelVM.CurrentItemVMList:Length() == 0 then
			HouseMainPanelVM.CommBackpackEmptySVisible = true
			HouseMainPanelVM.CommBackpackEmptyVisible = false
		end
	end
end

function HouseMainPanelView:UpdateView(bDelay)
	local HouseModel = _G.HousingMgr:GetHouseModel()

	if HouseModel ~= HouseCommon.HouseModel.None then
		if bDelay then
			self:RegisterTimer(function()
				HouseMainPanelVM:UpdateTabList()
				self.HouseCommMenu:UpdateItems(HouseMainPanelVM.TabList,false)
			end, 0.3)

			self:RegisterTimer(function()
				--默认选中背包中的全部
				local MenuKey = HouseMainPanelVM:GetDefaultMenuKey()
				self.HouseCommMenu:SetSelectedKey(MenuKey, true)
			end, 0.4)
		else
			HouseMainPanelVM:UpdateTabList()
			self.HouseCommMenu:UpdateItems(HouseMainPanelVM.TabList,false)

			self:RegisterTimer(function()
				--默认选中背包中的全部
				local MenuKey = HouseMainPanelVM:GetDefaultMenuKey()
				self.HouseCommMenu:SetSelectedKey(MenuKey, true)
			end, 0.1)
		end
		
		if HouseModel == HouseCommon.HouseModel.IndoorTerritoryModel or HouseModel == HouseCommon.HouseModel.HouseTerritoryModel then
			if bDelay and not HouseMainPanelVM.OpenHideUI then
				HouseMainPanelVM:SetHouseDecoratePanelVisible(true)
				self:PlayAnimation(self.AnimDecorate)
				self:PlayAnimation(self.AnimMainSwitch)
			else
				HouseMainPanelVM:SetHouseDecoratePanelVisible(true)
			end

			if HouseModel == HouseCommon.HouseModel.HouseTerritoryModel then
				local Slot = UIUtil.SlotAsCanvasSlot(self.HouseDecoratePanel)
				if nil == Slot then
					return
				end

				local Offset = _G.UE.FMargin()
				Offset.Left = -160
				Offset.Top = 0
				Offset.Right = 0
				Offset.Bottom = 0

				Slot:SetOffsets(Offset)
			end
		else
			if self.HouseDecoratePanel.ViewModel ~= nil then
				self.HouseDecoratePanel.ViewModel:SetCurItemIndex(nil)
			end

			if bDelay and not HouseMainPanelVM.OpenHideUI then
				self:PlayAnimation(self.AnimDecorateOut)
				self:PlayAnimation(self.AnimMainSwitch)
			else
				HouseMainPanelVM:SetHouseDecoratePanelVisible(false)
			end
		end
	end
end

function HouseMainPanelView:OnAnimationFinished(Animation)
	if Animation == self.AnimDecorateOut then
		HouseMainPanelVM:SetHouseDecoratePanelVisible(false)
	elseif Animation == self.AnimMainOut then
		HouseMainPanelVM.PanelMainVisible = false
	end
end

--- 切换菜单
function HouseMainPanelView:OnMenuTreeViewTabsSelectChanged(Index, ItemData, ItemView, MainKey, SubKey, bIsByClick)
	HouseMainPanelVM:ChangeTab(_G.HousingMgr:GetHouseModel(), MainKey, SubKey)
end

--- 道具点击
function HouseMainPanelView:OnPropsListSelectChanged(Index, ItemData, ItemView, bIsByClick)
	if ItemData == nil then
		return
	end

	UIUtil.SetIsVisible(self.HouseSlotItemTips,false,false)

	--if UIViewMgr:IsViewVisible(UIViewID.HouseItemTips) then
		--UIViewMgr:HideView(UIViewID.HouseItemTips)
	--end

	HouseMainPanelVM:SetCurItem(Index)
	local CurItem = HouseMainPanelVM:GetCurItem()

	--tips的变化操作
	if CurItem then
		local function Callback()
			HouseMainPanelVM:SetCurItem(0)
		end

		local Params = {ItemData = CurItem, SlotView = ItemView, HideCallback = Callback, Side = 1,Index = -1, RightBarExpend = self.RightBarExpend,IsPreviewItem = false}
		UIUtil.SetIsVisible(self.HouseSlotItemTips,true,true)
		self.HouseSlotItemTips:UpdateView(Params)
		self:AdjustHouseItemTipsPosition(Params)
	end
end

function HouseMainPanelView:AdjustHouseItemTipsPosition(Params)
	--右方ITEM栏中ITEM或者打开3行情况下
	if Params.Side == 1 then
		local TipsSize = UIUtil.GetWidgetSize(self.HouseSlotItemTips.ItemTipsFrameInterface)
		local BtnSize = UIUtil.GetWidgetSize(self.ToggleBtnArrow)
		local InOffste = _G.UE.FVector2D(-TipsSize.X -BtnSize.X -20 , 0)
		TipsUtil.AdjustTipsPosition(self.HouseSlotItemTips, self.ToggleBtnArrow, InOffste, _G.UE.FVector2D(0, 0))
	else
		--装潢时下方ITEM栏
		--local TipsSize = UIUtil.GetWidgetSize(self.HouseSlotItemTips.ItemTipsFrameInterface)
		--local BtnSize = UIUtil.GetWidgetSize(Params.SlotView)

		local InOffste = _G.UE.FVector2D(-10 , 0)
		TipsUtil.AdjustTipsPosition(self.HouseSlotItemTips, Params.SlotView, InOffste, _G.UE.FVector2D(0, 0.84))
	end
end

--进入装潢模式
function HouseMainPanelView:OnClickDecorate()
	if not HouseMainPanelVM.HouseMovePanelVisible then
		HouseMainPanelVM:ResetPreviewModelData()
		_G.HousingMgr:EnterDecorate()
		self:UpdateView(true)

		-- local HousingMgrInstance = UHousingMgr:Get()
		-- if HousingMgrInstance ~= nil then
		-- 	--内外装界面不能放家具
		-- 	HousingMgrInstance:SetLayoutEditMode(HouseCommon.eLayoutEditMode.LAYOUTEDIT_MODE_INVALID)
		-- end
	else
		MsgTipsUtil.ShowTips(LSTR(1640042))
	end
end

--打开更多
function HouseMainPanelView:OnClickMore()
	HouseMainPanelVM:SetTableViewSlotLVisible(false)
	HouseMainPanelVM:SetToggleBtnArrowVisible(false)

	local Params = {Parent = self}
	UIViewMgr:ShowView(UIViewID.HouseWinPanelView,Params)
end

function HouseMainPanelView:OnCloseMoreView()
	--关闭更多按扭
	UIViewMgr:HideView(UIViewID.HouseWinPanelView)

	--如果不是显示UI状态
	if _G.HousingMgr:IsShowUI() then
		HouseMainPanelVM:SetTableViewSlotLVisible(true)
	end
end

function HouseMainPanelView:OnClose()
	if HouseMainPanelVM.HouseMovePanelVisible then
		self.HouseMovePanel:OnClickedCancel()
		self:ExitHouseFurniturePreview()
	end

	local HousingMgrInstance = UHousingMgr:Get()
	if HousingMgrInstance ~= nil then
        HousingMgrInstance:EndLayoutMode() -- LAYOUTEDIT_MODE_INVALID
	end

	--如果打开了二级家具移动界面，则需要恢复
	if HouseMainPanelVM.HouseMovePanelVisible then
		_G.HousingMgr:CancelPickObject()
	end

	HouseMainPanelVM.OpenGrid = false
	HouseMainPanelVM.OpenHideUI = false
	HouseMainPanelVM.OpenTableState = false
	HouseMainPanelVM.PanelMainVisible = true
	UIViewMgr:HideView(UIViewID.HouseMainPanelView)
	UIViewMgr:ShowView(UIViewID.MainPanel)
end

function HouseMainPanelView:OnBack()
	_G.HousingMgr:ExitDecorate()

	if HouseMainPanelVM:CheckInterOrExterDataChange() then
		--恢复之前的设置
		_G.EventMgr:SendEvent(EventID.RefreshDecorateEffect,{HouseID = _G.HousingMgr.HouseID ,Region = _G.HousingMgr.Region})
	end

	HouseMainPanelVM:ResetPreviewModelData()
	self:UpdateView(true)
end

--网格
function HouseMainPanelView:OnToggleBtnGridStateChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	_G.HousingMgr:EnableGridModel(not IsChecked)
	HouseMainPanelVM.OpenGrid = not IsChecked
	if IsChecked then
		MsgTipsUtil.ShowTips(LSTR(1640073))
	else
		MsgTipsUtil.ShowTips(LSTR(1640072))
	end
end

--吸附
function HouseMainPanelView:OnToggleBtnTableStateChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local HousingMgrInstance = UHousingMgr:Get()
	if IsChecked then
		if HousingMgrInstance ~= nil then
			HousingMgrInstance:SetMountMode(false)
		end

		HouseMainPanelVM.OpenTableState = false
		MsgTipsUtil.ShowTips(LSTR(1640049))
	else
		if HousingMgrInstance ~= nil then
			HousingMgrInstance:SetMountMode(true)
		end

		HouseMainPanelVM.OpenTableState = true
		MsgTipsUtil.ShowTips(LSTR(1640048))
	end
end

--显隐UI
function HouseMainPanelView:OnToggleBtnUIStateChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		HouseMainPanelVM.OpenHideUI = true
		--HouseMainPanelVM.PanelMainVisible = false
		self:PlayAnimation(self.AnimMainOut)

		if HouseMainPanelVM.HouseDecoratePanelVisible then
			self:PlayAnimation(self.AnimDecorateHide)
		end
	else
		HouseMainPanelVM.OpenHideUI = false

		if HouseMainPanelVM.HouseDecoratePanelVisible then
			self:PlayAnimation(self.AnimDecorateShow)
		end
		
		if not UIUtil.IsVisible(self.HouseMovePanel) then
			HouseMainPanelVM.PanelMainVisible = true
			self:PlayAnimation(self.AnimMainIn)
		end
	end
end

function HouseMainPanelView:ShowHouseItemTips(Params)
	if Params ~= nil then
		UIUtil.SetIsVisible(self.HouseSlotItemTips,true,true)
		self.HouseSlotItemTips:UpdateView(Params)
		self:AdjustHouseItemTipsPosition(Params)
	end
end

function HouseMainPanelView:HideHouseItemTips(Params)
	UIUtil.SetIsVisible(self.HouseSlotItemTips,false,false)
end

function HouseMainPanelView:UpdateHouseItems(Params)
	--背包变化当前左侧栏选择的也是背包
	if HouseMainPanelVM.TabSelectIndex == HouseCommon.SelectHouseLeftBarType.Placed then
		HouseMainPanelVM:UpdateItemList()
	elseif Params.BagType == ProtoCS.HouseUseBagType.HouseUseBagType_RoleBag and 
			HouseMainPanelVM.TabSelectIndex == HouseCommon.SelectHouseLeftBarType.Bag then
			HouseMainPanelVM:UpdateItemList()
	elseif Params.BagType == ProtoCS.HouseUseBagType.HouseUseBagType_HouseDepot and 
			HouseMainPanelVM.TabSelectIndex == HouseCommon.SelectHouseLeftBarType.StoreHouse then
			HouseMainPanelVM:UpdateItemList()
	end
end

--背包变化时要更新右边道具栏如果当前选定的是背包
function HouseMainPanelView:BagUpdate(Params)
	local HouseModel = _G.HousingMgr:GetHouseModel()

	if HouseModel == HouseCommon.HouseModel.IndoorTerritoryModel or HouseModel == HouseCommon.HouseModel.HouseTerritoryModel then
		HouseMainPanelVM:UpdatePreviewBagData(Params)
	else
		self:UpdateHouseItems({BagType = ProtoCS.HouseUseBagType.HouseUseBagType_RoleBag})
	end
end

--仓库变化后如果在预览模式，右边ITEM条要变化
function HouseMainPanelView:DepotUpdate(Params)
	--更新预览相关界面只在内外装情况下
	if _G.HousingMgr:GetHouseModel() == HouseCommon.HouseModel.IndoorTerritoryModel 
			or _G.HousingMgr:GetHouseModel() == HouseCommon.HouseModel.HouseTerritoryModel then
		HouseMainPanelVM:UpdatePreviewDepotData(Params)
	else
		self:UpdateHouseItems({ BagType = ProtoCS.HouseUseBagType.HouseUseBagType_HouseDepot })
	end
end

--装修slot变化时要更新预览数据
function HouseMainPanelView:DecorateSlotUpdate(Params)
	HouseMainPanelVM:UpdatePreviewInterExterData(Params)
end

--放置成功进入二级界面
function HouseMainPanelView:EnterHouseFurniturePreview(Params)
	if HouseMainPanelVM.HouseMovePanelVisible == false then
		HouseMainPanelVM.HouseMovePanelVisible = true
		HouseMainPanelVM.PanelMainVisible = false

		self:HideHouseItemTips()
		self.HouseMovePanel:UpdateView(Params)
	end
end

function HouseMainPanelView:ExitHouseFurniturePreview(Params)
	HouseMainPanelVM.HouseMovePanelVisible = false
	HouseMainPanelVM.PanelMainVisible = true


	local HousingMgrInstance = UHousingMgr:Get()
	if HousingMgrInstance ~= nil then
		HousingMgrInstance:EndPreviewMode()
	end
end

function HouseMainPanelView:OnExitHouseRange(Params)
	self:OnClose()

	local HousingMgrInstance = UHousingMgr:Get()
	if HousingMgrInstance ~= nil then
		HousingMgrInstance:EndEditorModel()
	end
end

function HouseMainPanelView:OnPutFurnitureSucc(Params)
	HouseMainPanelVM:UpdateItemList()
end

function HouseMainPanelView:MoveFurnitureSucc(Params)
    self:ExitHouseFurniturePreview()
    _G.HousingMgr:CancelPickObject()

    local HousingMgrInstance = UHousingMgr:Get()
    if HousingMgrInstance ~= nil then
        HousingMgrInstance:SetMouseCancelReleased()
        HousingMgrInstance:EndLayoutMode() -- LAYOUTEDIT_MODE_INVALID
    end
end

return HouseMainPanelView