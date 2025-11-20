---
--- Author: peterxie
--- DateTime: 2025-05-30
--- Description: 独立房屋地图，可以切换住宅区街区
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local WorldMapMgr = _G.WorldMapMgr


---@class HouseMapPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSecondary UFButton
---@field BtnThreeLevel UFButton
---@field BtnViewLand UFButton
---@field BtnWorld UFButton
---@field PanelViewLand UFCanvasPanel
---@field SecondaryDropDown WorldMapTabDropDownListView
---@field SecondaryPanel UFCanvasPanel
---@field TextSecondary UFTextBlock
---@field TextThreeLevel UFTextBlock
---@field TextViewLand UFTextBlock
---@field TextWorld UFTextBlock
---@field ThreeLevelDropDown WorldMapTabDropDownListView
---@field ThreeLevelPanel UFCanvasPanel
---@field ToggleButtonSecondary UToggleButton
---@field ToggleButtonThreeLevel UToggleButton
---@field WorldTitlePanel UFCanvasPanel
---@field WorldTitlePanel01 UFCanvasPanel
---@field AnimIn1 UWidgetAnimation
---@field AnimMap1In UWidgetAnimation
---@field AnimMap1To2 UWidgetAnimation
---@field AnimMap2To3 UWidgetAnimation
---@field AnimMap3To2 UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field CurveScale CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseMapPanelView = LuaClass(UIView, true)

function HouseMapPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSecondary = nil
	--self.BtnThreeLevel = nil
	--self.BtnViewLand = nil
	--self.BtnWorld = nil
	--self.PanelViewLand = nil
	--self.SecondaryDropDown = nil
	--self.SecondaryPanel = nil
	--self.TextSecondary = nil
	--self.TextThreeLevel = nil
	--self.TextViewLand = nil
	--self.TextWorld = nil
	--self.ThreeLevelDropDown = nil
	--self.ThreeLevelPanel = nil
	--self.ToggleButtonSecondary = nil
	--self.ToggleButtonThreeLevel = nil
	--self.WorldTitlePanel = nil
	--self.WorldTitlePanel01 = nil
	--self.AnimIn1 = nil
	--self.AnimMap1In = nil
	--self.AnimMap1To2 = nil
	--self.AnimMap2To3 = nil
	--self.AnimMap3To2 = nil
	--self.AnimOut = nil
	--self.CurveScale = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseMapPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SecondaryDropDown)
	self:AddSubView(self.ThreeLevelDropDown)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseMapPanelView:OnInit()
	self.AdapterThreeLevelDropDown = UIAdapterTableView.CreateAdapter(self, self.ThreeLevelDropDown.TableViewItemList, self.OnSelectChangedArea)
	self.AdapterSecondaryDropDown = UIAdapterTableView.CreateAdapter(self, self.SecondaryDropDown.TableViewItemList, self.OnSelectChangedStreet)

	self.Binders = {
		{ "HouseMapName", UIBinderSetText.New(self, self.TextWorld) },
		{ "HouseStreetName", UIBinderSetText.New(self, self.TextSecondary) },
		{ "HouseAreaName", UIBinderSetText.New(self, self.TextThreeLevel) },

		{ "HouseStreetVMList", UIBinderUpdateBindableList.New(self, self.AdapterSecondaryDropDown) },
		{ "HouseAreaVMList", UIBinderUpdateBindableList.New(self, self.AdapterThreeLevelDropDown) },
		{ "HouseAreaListVisible", UIBinderSetIsVisible.New(self, self.ThreeLevelDropDown) },
		{ "HouseStreetListVisible", UIBinderSetIsVisible.New(self, self.SecondaryDropDown) },
		{ "HouseAreaListVisible", UIBinderSetIsChecked.New(self, self.ToggleButtonThreeLevel) },
		{ "HouseStreetListVisible", UIBinderSetIsChecked.New(self, self.ToggleButtonSecondary) },
	}
end

function HouseMapPanelView:OnDestroy()

end

function HouseMapPanelView:OnShow()
	self.TextViewLand:SetText(_G.LSTR(700053))
end

function HouseMapPanelView:OnHide()

end

function HouseMapPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonSecondary, self.OnStateChangedToggleSecondary)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonThreeLevel, self.OnStateChangedToggleThreeLevel)

	UIUtil.AddOnClickedEvent(self, self.BtnViewLand, self.OnClickedBtnViewLand)
end

function HouseMapPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HouseLandMapDataUpdate, self.OnHouseLandListUpdate)
end

function HouseMapPanelView:OnHouseLandListUpdate()
	local MapID = WorldMapMgr:GetMapID()
	WorldMapVM:SetHouseStreetList(MapID)

	local UIMapID = WorldMapMgr:GetUIMapID()
	WorldMapVM:SetHouseAreaList(UIMapID)
end

function HouseMapPanelView:OnRegisterBinder()
	self:RegisterBinders(WorldMapVM, self.Binders)
end


-- 切换住宅区街区ID，UIMap的房屋土地标记数据跟着变化
function HouseMapPanelView:OnSelectChangedStreet(Index, ItemData, ItemView)
	local StreetID = ItemData.ID
	WorldMapMgr:ChangeHouseMap(WorldMapMgr:GetUIMapID(), WorldMapMgr:GetMapID(), StreetID)
end

-- 切换初始区/扩建区，即切换UIMap
function HouseMapPanelView:OnSelectChangedArea(Index, ItemData, ItemView)
	local UIMapID = ItemData.ID
	WorldMapMgr:ChangeHouseMap(UIMapID, WorldMapMgr:GetMapID(), WorldMapMgr:GetStreetID())
end

function HouseMapPanelView:OnStateChangedToggleSecondary(ToggleButton, ButtonState)
	WorldMapVM:SetHouseStreetListVisible()
end

function HouseMapPanelView:OnStateChangedToggleThreeLevel(ToggleButton, ButtonState)
	WorldMapVM:SetHouseAreaListVisible()
end

function HouseMapPanelView:OnClickedBtnViewLand()
	WorldMapVM:SetHouseLandListPanelVisible(true)
end


return HouseMapPanelView