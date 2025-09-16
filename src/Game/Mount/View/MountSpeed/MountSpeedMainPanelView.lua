---
--- Author: janezli
--- DateTime: 2024-10-11 14:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MountSpeedPanelVM = require("Game/Mount/VM/MountSpeedPanelVM")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local MountMgr = _G.MountMgr
local LSTR = _G.LSTR

---@class MountSpeedMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field CommTab CommVerIconTabsView
---@field CommonTitle CommonTitleView
---@field ImgBG UFImage
---@field ImgMount UFImage
---@field SwitcherIcon1 UFWidgetSwitcher
---@field SwitcherIcon2 UFWidgetSwitcher
---@field TableViewInfo UTableView
---@field TableView_20 UTableView
---@field TextCity UFTextBlock
---@field TextGear1 UFTextBlock
---@field TextGear2 UFTextBlock
---@field TextGear3 UFTextBlock
---@field TextMainCity UFTextBlock
---@field TextSpeed UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimMountSpeedLevel0 UWidgetAnimation
---@field AnimMountSpeedLevel1 UWidgetAnimation
---@field AnimMountSpeedLevel1Loop UWidgetAnimation
---@field AnimMountSpeedLevel2 UWidgetAnimation
---@field AnimMountSpeedLevel2Loop UWidgetAnimation
---@field AnimTableView_20SelectionChanged UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSpeedMainPanelView = LuaClass(UIView, true)

function MountSpeedMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.CommTab = nil
	--self.CommonTitle = nil
	--self.ImgBG = nil
	--self.ImgMount = nil
	--self.SwitcherIcon1 = nil
	--self.SwitcherIcon2 = nil
	--self.TableViewInfo = nil
	--self.TableView_20 = nil
	--self.TextCity = nil
	--self.TextGear1 = nil
	--self.TextGear2 = nil
	--self.TextGear3 = nil
	--self.TextMainCity = nil
	--self.TextSpeed = nil
	--self.AnimIn = nil
	--self.AnimMountSpeedLevel0 = nil
	--self.AnimMountSpeedLevel1 = nil
	--self.AnimMountSpeedLevel1Loop = nil
	--self.AnimMountSpeedLevel2 = nil
	--self.AnimMountSpeedLevel2Loop = nil
	--self.AnimTableView_20SelectionChanged = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.CurSelectRegionID = 0
	self.CurSelectMapID = 0 
	self.CurMapSpeedLevel = 0
end

function MountSpeedMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommTab)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSpeedMainPanelView:OnInit()
	self.ViewModel = MountSpeedPanelVM.New()
	self.AdapterTableViewList = UIAdapterTableView.CreateAdapter(self, self.TableView_20,self.OnTableViewSelectChanged,false)
	self.AdapterTableViewInfoList = UIAdapterTableView.CreateAdapter(self, self.TableViewInfo,nil,false)
	self.AdapterTableViewInfoList:SetAlwaysNotifySelectChanged(true)
end

function MountSpeedMainPanelView:OnDestroy()
	self.CurSelectRegionID = 0
	self.CurSelectMapID = 0 
	self.CurMapSpeedLevel = 0
end

function MountSpeedMainPanelView:OnShow()
	self.CommonTitle.TextTitleName:SetText(LSTR(200001))
	self.TextSpeed:SetText(LSTR(200002))
	self.TextGear1:SetText(LSTR(200004))
	self.TextGear2:SetText(LSTR(200005))
	self.TextGear3:SetText(LSTR(200006))
	MountMgr:SendMountListQuery()
	self:SelectedMapItem()
end

function MountSpeedMainPanelView:OnHide()

end

function MountSpeedMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommTab, self.OnCommTabChg)
end

function MountSpeedMainPanelView:OnRegisterGameEvent()

end

function MountSpeedMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "TextMainCity", UIBinderSetText.New(self, self.TextMainCity) },
		{ "TextCity", UIBinderSetText.New(self, self.TextCity) },
        { "MapList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewList) },
		{ "QuestInfoList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewInfoList) },
		{ "SpeedLevelOne", UIBinderSetActiveWidgetIndex.New(self, self.SwitcherIcon1) },
		{ "SpeedLevelTwo", UIBinderSetActiveWidgetIndex.New(self, self.SwitcherIcon2) },
		{ "ImgBG", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg)}
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function MountSpeedMainPanelView:OnCommTabChg(_, ItemData, _, bByClick)
	self.ViewModel:UpdateMapListData(ItemData.ID)
	local RegionName = MapUtil.GetRegionName(ItemData.ID)
	self.CommonTitle.TextSubtitle:SetText(RegionName)
	self.CurSelectRegionID = ItemData.ID
	if bByClick then
		if self.AdapterTableViewList then
			self.AdapterTableViewList:ClearSelectedItem()
			self.AdapterTableViewList:SetSelectedIndex(1)
			self.AdapterTableViewList:ScrollToIndex(1)
		end
	end
end

function MountSpeedMainPanelView:SelectedMapItem()
	local CurMapId = _G.PWorldMgr:GetCurrMapResID()
	local RegionID = MapUtil.GetMapRegionID(CurMapId)
	self:CreateRegionList(RegionID)
	self:SelectedMapItemByMapID(RegionID,CurMapId)
end

function MountSpeedMainPanelView:CreateRegionList(SelectRegionID)
	local ListData, SelectedIndex = self:MakeTheRegionData(SelectRegionID)
	if not ListData then
		return
	end
	self.CommTab:UpdateItems(ListData, SelectedIndex)
end

function MountSpeedMainPanelView:SelectedMapItemByMapID(RegionID, MapID)
	local SelectedMapIndex = 1
	if self.CurSelectRegionID == RegionID then
		local MapList = self.ViewModel.MapList
		if not MapList then
			return 
		end
		if not self.AdapterTableViewList then
			return
		end
		SelectedMapIndex = MapList:GetItemIndexByPredicate(function(e)
			return e.MapID == MapID
		end) or 1
	end
	self.AdapterTableViewList:SetSelectedIndex(SelectedMapIndex)
	self.AdapterTableViewList:ScrollToIndex(SelectedMapIndex)
end

function MountSpeedMainPanelView:MakeTheRegionData(SelectRegionID)
	local MountSpeedCfg = MountMgr.MountSpeedCfg
	if not MountSpeedCfg then
		return
	end

	local ListData = {}
	local RegionList = table.indices(MountSpeedCfg)
	if RegionList then
		table.sort(RegionList, function(A,B)
			return  A < B
		end)
		SelectedIndex = RegionList[1]
		for Index,RegionID in ipairs(RegionList) do
			if RegionID == SelectRegionID then
				SelectedIndex = Index
			end
			local RegionIconCfg = MapRegionIconCfg:FindCfgByKey(RegionID)
			if RegionIconCfg then
				local Data = {}
				Data.ID = RegionID
				Data.Name = RegionIconCfg.Name
				Data.IconPath = RegionIconCfg.Icon--Circle
				table.insert(ListData, Data)
			end
		end
	end

	return ListData, SelectedIndex
end

function MountSpeedMainPanelView:OnTableViewSelectChanged(_, ItemData, _, IsByClick)
	local MapID = ItemData.MapID
	if not MapID then
		return
	end
	self.CurMapSpeedLevel = ItemData.MapSpeedLevel
	if IsByClick then 
		if self.CurSelectMapID and self.CurSelectMapID == MapID then
			return
		end
	end
	self.CurSelectMapID = ItemData.MapID
	self.ViewModel:SetSelectMapContent(ItemData)
	self:SetAnimation()
end

function MountSpeedMainPanelView:OnQuestInfoItemOnClick(_, ItemData, _, IsByClick)
	local ItemID = ItemData.ItemID
	if ItemID and ItemID > 0 then
		if IsByClick then 
			ItemTipsUtil.ShowTipsByResID(ItemID, self.TableViewInfo)
		end
	end
end

function MountSpeedMainPanelView:SetAnimation()
	if self.CurMapSpeedLevel == 0 then
		self:PlayAnimation(self.AnimMountSpeedLevel0)
	elseif self.CurMapSpeedLevel == 1 then
		self:PlayAnimation(self.AnimMountSpeedLevel1)
		self:PlayAnimation(self.AnimMountSpeedLevel1Loop, 0, 0)
	elseif self.CurMapSpeedLevel == 2 then
		self:PlayAnimation(self.AnimMountSpeedLevel2)
		self:PlayAnimation(self.AnimMountSpeedLevel2Loop, 0, 0)
	end	-- body
end

return MountSpeedMainPanelView