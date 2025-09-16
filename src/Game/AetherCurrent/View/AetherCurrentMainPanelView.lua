---
--- Author: Alex
--- DateTime: 2023-09-04 10:07
--- Description:风脉泉主界面UI
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AetherCurrentsVM = require("Game/AetherCurrent/AetherCurrentsVM")
local AetherCurrentsMgr = require("Game/AetherCurrent/AetherCurrentsMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MapDefine = require("Game/Map/MapDefine")
local MapVM = require("Game/Map/VM/MapVM")
local ModuleMapContentVM = require("Game/Map/VM/ModuleMapContentVM")
local MapUtil = require("Game/Map/MapUtil")
local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local EventID = require("Define/EventID")
local MapAllPointActivateState = AetherCurrentDefine.MapAllPointActivateState
local NpcDialogMgr = _G.NpcDialogMgr
local MapContentType = MapDefine.MapContentType
local MapMarkerType = MapDefine.MapMarkerType
local MapProviderConfigs = MapDefine.MapProviderConfigs
local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

local ScaleMin = MapDefine.MapConstant.MAP_SCALE_MIN
local ScaleMax = MapDefine.MapConstant.MAP_SCALE_MAX


---@class AetherCurrentMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BtnBack CommBackBtnView
---@field CommonTitle_UIBP CommonTitleView
---@field DropDownList CommDropDownListView
---@field FHorizontalCoordinate UFHorizontalBox
---@field ImgBG UImage
---@field ImgFrame UImage
---@field MapScale WorldMapScaleItemView
---@field PanelDropDown UFCanvasPanel
---@field TableViewDetail UTableView
---@field Tabs CommVerIconTabsView
---@field TextCoordinate UFTextBlock
---@field TextCoordinate_1 UFTextBlock
---@field mapContent AetherCurrentMapPanelView
---@field AnimIn UWidgetAnimation
---@field AnimMapRefresh UWidgetAnimation
---@field AnimUpdateDetail UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentMainPanelView = LuaClass(UIView, true)

function AetherCurrentMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BtnBack = nil
	--self.CommonTitle_UIBP = nil
	--self.DropDownList = nil
	--self.FHorizontalCoordinate = nil
	--self.ImgBG = nil
	--self.ImgFrame = nil
	--self.MapScale = nil
	--self.PanelDropDown = nil
	--self.TableViewDetail = nil
	--self.Tabs = nil
	--self.TextCoordinate = nil
	--self.TextCoordinate_1 = nil
	--self.mapContent = nil
	--self.AnimIn = nil
	--self.AnimMapRefresh = nil
	--self.AnimUpdateDetail = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommonTitle_UIBP)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.MapScale)
	self:AddSubView(self.Tabs)
	self:AddSubView(self.mapContent)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentMainPanelView:InitConstStringInfo()
	self.CommonTitle_UIBP:SetTextTitleName(LSTR(310027))
	self.CommonTitle_UIBP:SetSubTitleIsVisible(true)
end

function AetherCurrentMainPanelView:OnInit()
	self.ScaleTimer = nil
	self.bReceiveSliderChangeByMouse = nil -- 是否由鼠标/触屏控制滑动条导致地图缩放改变
	self.CurSelectedMapID = nil -- 当前界面选中的地图Item 防止重复点击造成的多余刷新操作

	self.TableViewDetailAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDetail,
		self.OnTableViewDetailSelectChanged, true, false, true) -- 不能一刀切，需要允许同数值的Map更新


	self.MultiBinders = {
		{
			ViewModel = ModuleMapContentVM,
			Binders = {
				{ "MapName", UIBinderSetText.New(self, self.TextCoordinate_1) },
				{ "MapScale", UIBinderSetSlider.New(self, self.MapScale.Slider) },
				{ "MapScale", UIBinderValueChangedCallback.New(self, nil, self.SetProgressBar) },
			}
		},
		{
			ViewModel = AetherCurrentsVM,
			Binders = {
				{ "MapItems", UIBinderUpdateBindableList.New(self, self.TableViewDetailAdapter) },
				{ "bShowDropDownList", UIBinderSetIsVisible.New(self, self.DropDownList) },
				{ "bShowMajorCoordinate", UIBinderSetIsVisible.New(self, self.FHorizontalCoordinate) },
			}
		},
	}
	self:InitConstStringInfo()
end

function AetherCurrentMainPanelView:OnDestroy()
	
end

function AetherCurrentMainPanelView:OnShow()
	--- 为确保子View刷新时数据正确，初始化数据放在父蓝图内
	local AetherCurrentType = MapContentType.AetherCurrent
	self.mapContent:SetContentType(AetherCurrentType)
	_G.MapMarkerMgr:CreateProviders(AetherCurrentType)

	self:UpdateCoordinate()
	self:SelectedMapItemByRule()
end

function AetherCurrentMainPanelView:OnHide()
	self.CurSelectedMapID = nil
end

function AetherCurrentMainPanelView:OnRegisterUIEvent()
	self.BtnBack:AddBackClick(self, function(e) e:Hide() end)
	UIUtil.AddOnValueChangedEvent(self, self.MapScale.Slider, self.OnValueChangedScale)
	UIUtil.AddOnMouseCaptureBeginEvent(self, self.MapScale.Slider, self.OnSliderMouseCaptureBegin)
    UIUtil.AddOnMouseCaptureEndEvent(self, self.MapScale.Slider, self.OnSliderMouseCaptureEnd)
	UIUtil.AddOnClickedEvent(self, self.MapScale.BtnAdd, self.OnClickedBtnScaleAdd)
	UIUtil.AddOnClickedEvent(self, self.MapScale.BtnSub, self.OnClickedBtnScaleSub)
	UIUtil.AddOnSelectionChangedEvent(self, self.Tabs, self.OnTabsChg)
end

function AetherCurrentMainPanelView:OnRegisterGameEvent()
	
end

function AetherCurrentMainPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end

--- MapItem切换事件
function AetherCurrentMainPanelView:OnTableViewDetailSelectChanged(_, ItemData, _, IsByClick)
	local MapID = ItemData.MapID
	if not MapID then
		return
	end

	-- 针对点击同Map的操作进行屏蔽
	if IsByClick then
		local CurSelectedMap = self.CurSelectedMapID
		if CurSelectedMap and CurSelectedMap == MapID then
			return
		end
	end

	self.CurSelectedMapID = MapID

	self:ChangeSelectedMap(MapID)
end

function AetherCurrentMainPanelView:ChangeSelectedMap(MapID)
	local MapContentPanel = self.mapContent
	if not MapContentPanel then
		return
	end
	
	local bHavePointToPlay = _G.AetherCurrentsMgr:IsNeedShowActivePointChangeCurMap(MapID) 
	MapContentPanel:ShowMapContent(MapID, nil, bHavePointToPlay)
	local RegionID = MapUtil.GetMapRegionID(MapID)
	_G.AetherCurrentsMgr:ShowTheActivePointChangeWhenOpenPanelByRegionID(RegionID)
	self:PlayAnimation(self.AnimMapRefresh)
	_G.ObjectMgr:CollectGarbage(false)
end

function AetherCurrentMainPanelView:OnValueChangedScale(_, Value)
	if self.bReceiveSliderChangeByMouse == true then
		ModuleMapContentVM:SetMapScale(Value)
    else
        self.MapScale.Slider:SetValue(ModuleMapContentVM.MapScale)
    end
end

function AetherCurrentMainPanelView:OnSliderMouseCaptureBegin()
    self.bReceiveSliderChangeByMouse = true
end

function AetherCurrentMainPanelView:OnSliderMouseCaptureEnd()
    self.bReceiveSliderChangeByMouse = false
end

function AetherCurrentMainPanelView:OnClickedBtnScaleAdd()
	local Value = self.MapScale.Slider:GetValue()
	local NewValue = Value + 0.2
	NewValue = math.clamp(NewValue, ScaleMin, ScaleMax)
	ModuleMapContentVM:SetMapScale(NewValue)
end

function AetherCurrentMainPanelView:OnClickedBtnScaleSub()
	local Value = self.MapScale.Slider:GetValue()
	local NewValue = Value - 0.2
	NewValue = math.clamp(NewValue, ScaleMin, ScaleMax)
	ModuleMapContentVM:SetMapScale(NewValue)
end

function AetherCurrentMainPanelView:UpdateCoordinate()
	local Position = MapVM:GetMajorLeftTopPosition()
	self.TextCoordinate:SetText(MapUtil.GetCoordinateText(Position))
end

function AetherCurrentMainPanelView:SetProgressBar(Value)
	self.MapScale.ProgressBar:SetPercent((Value - ScaleMin) / (ScaleMax - ScaleMin))
end

function AetherCurrentMainPanelView:OnBtnHelpClicked()
	NpcDialogMgr:PlayDialogLib(AetherCurrentDefine.HelpBtnDialoglibID)
end

--- 组织地区列表刷新数据
function AetherCurrentMainPanelView:MakeTheRegionData(SelectRegionID)
	local AllMapItems = AetherCurrentsVM.AllMapItems
	if not AllMapItems then
		return
	end

	local ListData = {}
	local SelectedIndex = 1
	local RegionList = table.indices(AllMapItems)
	if RegionList then
		table.sort(RegionList, AetherCurrentDefine.SortRegion)

		for Index, RegionID in ipairs(RegionList) do
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
				FLOG_INFO("AetherCurrentMainPanelView:MakeTheRegionData: RegionID %s", RegionID)
			end
		end
	end

	return ListData, SelectedIndex
end

--- 创建左侧地域页签
---@param InitIndex number@初始选中地域
function AetherCurrentMainPanelView:CreateRegionList(SelectRegionID)
	local ListData, SelectedIndex = self:MakeTheRegionData(SelectRegionID)
	if not ListData or not next(ListData) then
		FLOG_ERROR("AetherCurrentMainPanelView:CreateRegionList ListData is empty")
		return
	end
	self.Tabs:UpdateItems(ListData, SelectedIndex)
end

--- 根据MapID选择对应地图Item
function AetherCurrentMainPanelView:SelectedMapItemByMapID(MapID)
	local MapItems = AetherCurrentsVM.MapItems
	if MapItems == nil then
		return
	end

	local MapTableViewAdapter = self.TableViewDetailAdapter
	if MapTableViewAdapter == nil then
		return
	end

	local SelectedIndex = MapItems:GetItemIndexByPredicate(function(e)
		return e.MapID == MapID
	end) or 1
	MapTableViewAdapter:SetSelectedIndex(SelectedIndex)
	MapTableViewAdapter:ScrollToIndex(SelectedIndex)
end

--- 根据规则找出需要选中的地图 显示当前地图的优先级最高 2024.10.17
function AetherCurrentMainPanelView:FindTheMapItemToSelectByRule()
	local TargetMapID = AetherCurrentsMgr.ForceSelectMapID
	if TargetMapID then
		AetherCurrentsMgr.ForceSelectMapID = nil
		return TargetMapID, MapUtil.GetMapRegionID(TargetMapID)
	end
	local CurMapID = _G.PWorldMgr:GetCurrMapResID()
	local TargetMapID = CurMapID
	local PointActivatedState = AetherCurrentsMgr:IsMapPointsAllActived(CurMapID)
	--local bHavePointToActive = AetherCurrentsMgr:IsNeedShowActivePointChangeCurMap(CurMapID)
	local bMapHaveAetherCurrent = PointActivatedState ~= MapAllPointActivateState.InvalidMap
	if not bMapHaveAetherCurrent then
		TargetMapID = AetherCurrentsMgr:GetTheLatestActivePointMapID()
		if not TargetMapID then
			TargetMapID = AetherCurrentsMgr:GetTheFirstMapIDInRegionOrder()
		end
	end
	local RegionID = MapUtil.GetMapRegionID(TargetMapID)
	return TargetMapID, RegionID
end

--- 根据既定规则选中地图
function AetherCurrentMainPanelView:SelectedMapItemByRule()
	local MapID, RegionID = self:FindTheMapItemToSelectByRule()
	if not MapID or not RegionID then
		return
	end

	self:CreateRegionList(RegionID)
	self:SelectedMapItemByMapID(MapID)
end

function AetherCurrentMainPanelView:OnTabsChg(_, ItemData, _, bByClick)
	self.TableViewDetailAdapter:ResetDelayDisplayEffect()

	local RegionID = ItemData.ID
	self.CommonTitle_UIBP:SetTextSubtitle(MapUtil.GetRegionName(RegionID))
	AetherCurrentsVM:UpdateMainPanelData(RegionID)
	if bByClick then
		self:PlayAnimation(self.AnimUpdateDetail)
		local MapTableViewAdapter = self.TableViewDetailAdapter
		if MapTableViewAdapter then
			MapTableViewAdapter:SetSelectedIndex(1)
			MapTableViewAdapter:ScrollToIndex(1)
		end
	end
end

return AetherCurrentMainPanelView