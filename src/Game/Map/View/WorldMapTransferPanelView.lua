---
--- Author: anypkvcai
--- DateTime: 2023-01-09 11:03
--- Description: 水晶传送列表
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIViewMgr = require("UI/UIViewMgr")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local CommVerIconTabItemVM = require("Game/Common/Tab/CommVerIconTabItemVM")


---@class WorldMapTransferPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field CommEmpty CommEmptyView
---@field FButton_99 UFButton
---@field FTreeViewList UFTreeView
---@field ImgBkg UFImage
---@field ImgPattern UFImage
---@field Sidebar UFCanvasPanel
---@field TableViewTab UTableView
---@field TextDelivery UFTextBlock
---@field TextSmallTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapTransferPanelView = LuaClass(UIView, true)

function WorldMapTransferPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.CommEmpty = nil
	--self.FButton_99 = nil
	--self.FTreeViewList = nil
	--self.ImgBkg = nil
	--self.ImgPattern = nil
	--self.Sidebar = nil
	--self.TableViewTab = nil
	--self.TextDelivery = nil
	--self.TextSmallTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapTransferPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapTransferPanelView:OnInit()
	self.TextDelivery:SetText(_G.LSTR(700035))

	self.AdapterTransfer = UIAdapterTreeView.CreateAdapter(self, self.FTreeViewList, self.OnSelectChangedTransfer)
	self.AdapteTab = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnSelectChangedTab)

	self.Binder =
	{
		{ "RegionName", UIBinderSetText.New(self, self.TextSmallTitle) },
		{ "AreaList", UIBinderUpdateBindableList.New(self, self.AdapterTransfer) },
	}
end

function WorldMapTransferPanelView:OnDestroy()

end

function WorldMapTransferPanelView:OnShow()
	local RegionTabData = WorldMapVM:GetRegionTabList()
	self.RegionTabData = RegionTabData

	local SelectedIndex = 1
	if MapUtil.IsAreaMap(_G.WorldMapMgr:GetUIMapID()) then
		local MapID = MapUtil.GetMapID(_G.WorldMapMgr:GetUIMapID())
		local RegionID = MapUtil.GetMapRegionID(MapID)
		for Idx, RegionInfo in ipairs(RegionTabData) do
			if RegionInfo.RegionID == RegionID then
				SelectedIndex = Idx
			end
		end
	end

	local MenuItems = {}
	for i = 1, #RegionTabData do
		-- 水晶传送列表的tab界面在通用tab界面上包装了一层，这里用相同的数据结构
		local ViewModel = CommVerIconTabItemVM.New()
		ViewModel:UpdateVM(RegionTabData[i])
		table.insert(MenuItems, ViewModel)
	end

	self.AdapteTab:UpdateAll(MenuItems)
	self.AdapteTab:SetSelectedIndex(SelectedIndex)
end

function WorldMapTransferPanelView:OnHide()
	WorldMapVM:ShowWorldMapTransferPanel(false)
end

function WorldMapTransferPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton_99, self.OnClickedBtnTransferTicket)
end

function WorldMapTransferPanelView:OnRegisterGameEvent()

end

function WorldMapTransferPanelView:OnRegisterBinder()
	self:RegisterBinders(WorldMapVM, self.Binder)
end

function WorldMapTransferPanelView:OnSelectChangedTab(Index, ItemData, ItemView, IsByClick)
	local RegionInfo = self.RegionTabData[Index]
	WorldMapVM:UpdateAreaList(RegionInfo.RegionID)

	local AreaList = WorldMapVM.AreaList
	local HasActiveCrystalMap = false -- 根据数据源判断是否有激活的水晶地图
	for AreaIndex = 1, AreaList:Length() do
		local WorldMapTransferAreaVM = AreaList:Get(AreaIndex)
		if WorldMapTransferAreaVM and WorldMapTransferAreaVM.MapList:Length() > 0 then
			HasActiveCrystalMap = true
		end
	end

	if not HasActiveCrystalMap then
		if RegionInfo.RegionID == WorldMapVM.FavorRegionID then
			self.CommEmpty:UpdateText(_G.LSTR(700015)) -- "暂无收藏"
		else
			self.CommEmpty:UpdateText(_G.LSTR(700016)) -- "当前暂无共鸣的以太之光"
		end
		UIUtil.SetIsVisible(self.CommEmpty, true)
		UIUtil.SetIsVisible(self.FTreeViewList, false)
	else
		UIUtil.SetIsVisible(self.CommEmpty, false)
		UIUtil.SetIsVisible(self.FTreeViewList, true, true)
	end
end

function WorldMapTransferPanelView:OnSelectChangedTransfer(Index, ItemData, ItemView, IsByClick)
	if IsByClick then
		if ItemData.IsActive then
			UIViewMgr:HideAllUIByLayer()
			self:Hide()
		end
		local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
		CrystalMgr:TransferByMap(ItemData.CrystalID)
		_G.WorldMapMgr:ReportData(MapDefine.MapReportType.CrystalTransfer, MapDefine.CrystalTransferSource.TransferList, ItemData.CrystalID)
	end
end

function WorldMapTransferPanelView:OnClickedBtnTransferTicket()
	_G.AetheryteticketMgr:OpenAetheryteticketPanel()
end

return WorldMapTransferPanelView