---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:07
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIViewMgr = require("UI/UIViewMgr")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
local FishCfg = require("TableCfg/FishCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local FishNotesMgr = require("Game/FishNotes/FishNotesMgr")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")
local DataReportUtil = require("Utils/DataReportUtil")
local TextCommitOnEnter = _G.UE.ETextCommit.OnEnter
local LSTR = _G.LSTR

---@class FishIngholePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AreaTitle FishIngholeAreaTitleItemView
---@field AreaTitle2 FishIngholeAreaTitleItemView
---@field BtnClose CommonCloseBtnView
---@field BtnFishNotes UFButton
---@field ClockEmpty CommBackpackEmptyView
---@field ClockNotActive FishIngholeClockNotActiveWinView
---@field CommonBkg CommonBkg01View
---@field CommonBookBkg CommonBookBkgView
---@field FTreeViewPlace UFTreeView
---@field FishClockNum FishClockNumItemView
---@field FishDetails FishIngholeDetailsPanel2View
---@field FishSearchEmpty CommBackpackEmptyView
---@field Fishlist UFCanvasPanel
---@field MapContent FishMapContentView
---@field MapScalePanel WorldMapScaleItemView
---@field PanelClockWin UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelMap UFCanvasPanel
---@field Place UFCanvasPanel
---@field SearchBar CommSearchBarView
---@field SearchPlace UFCanvasPanel
---@field TableViewClockFish UTableView
---@field TableViewLocationFish UTableView
---@field TextLevel UFTextBlock
---@field TextNumber UFTextBlock
---@field TextPlace UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitleName CommonTitleView
---@field VerIconTabs CommVerIconTabsView
---@field AnimChangeTab UWidgetAnimation
---@field AnimDetailsToMap UWidgetAnimation
---@field AnimFTreeViewaAreaSelectionChanged UWidgetAnimation
---@field AnimFTreeViewPlaceSelectionChanged UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMapToDetails UWidgetAnimation
---@field AnimSearch UWidgetAnimation
---@field AnimTableViewClockFishSelectionChanged UWidgetAnimation
---@field AnimToggleBtnSwitchChecked UWidgetAnimation
---@field AnimToggleBtnSwitchUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholePanelView = LuaClass(UIView, true)
--region Inherited
function FishIngholePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AreaTitle = nil
	--self.AreaTitle2 = nil
	--self.BtnClose = nil
	--self.BtnFishNotes = nil
	--self.ClockEmpty = nil
	--self.ClockNotActive = nil
	--self.CommonBkg = nil
	--self.CommonBookBkg = nil
	--self.FTreeViewPlace = nil
	--self.FishClockNum = nil
	--self.FishDetails = nil
	--self.FishSearchEmpty = nil
	--self.Fishlist = nil
	--self.MapContent = nil
	--self.MapScalePanel = nil
	--self.PanelClockWin = nil
	--self.PanelList = nil
	--self.PanelMap = nil
	--self.Place = nil
	--self.SearchBar = nil
	--self.SearchPlace = nil
	--self.TableViewClockFish = nil
	--self.TableViewLocationFish = nil
	--self.TextLevel = nil
	--self.TextNumber = nil
	--self.TextPlace = nil
	--self.TextTips = nil
	--self.TextTitleName = nil
	--self.VerIconTabs = nil
	--self.AnimChangeTab = nil
	--self.AnimDetailsToMap = nil
	--self.AnimFTreeViewaAreaSelectionChanged = nil
	--self.AnimFTreeViewPlaceSelectionChanged = nil
	--self.AnimIn = nil
	--self.AnimMapToDetails = nil
	--self.AnimSearch = nil
	--self.AnimTableViewClockFishSelectionChanged = nil
	--self.AnimToggleBtnSwitchChecked = nil
	--self.AnimToggleBtnSwitchUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AreaTitle)
	self:AddSubView(self.AreaTitle2)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.ClockEmpty)
	self:AddSubView(self.ClockNotActive)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonBookBkg)
	self:AddSubView(self.FishClockNum)
	self:AddSubView(self.FishDetails)
	self:AddSubView(self.FishSearchEmpty)
	self:AddSubView(self.MapContent)
	self:AddSubView(self.MapScalePanel)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.TextTitleName)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholePanelView:OnInit()
	self.TextTitleName:SetTextTitleName(LSTR(180065))--"钓鱼笔记"
	self.SearchBar:SetHintText(LSTR(180062)) --搜索钓场或鱼类
	self.FishSearchEmpty:SetTipsContent(LSTR(FishNotesDefine.SearchEmptyText))
	self.ClockEmpty:SetTipsContent(LSTR(FishNotesDefine.ClockEmptyTipsText))
	self.ClockEmpty:SetBtnText(LSTR(180083)) --前往设置
	--列表
	self.LocationTreeAdapter = UIAdapterTreeView.CreateAdapter(self, self.FTreeViewPlace, self.OnLocationSelectChanged)
	self.LocationFishListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewLocationFish, self.OnLocationFishSelectChanged, true, false)
	self.ClockListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewClockFish, self.OnClockFishSelectChanged, false, false)
	self.Binders = {
		--钓场，鱼，闹钟列表
		{"FishIngholeLocationList", UIBinderUpdateBindableList.New(self, self.LocationTreeAdapter)},
		{"FishIngholeLocationFishList", UIBinderUpdateBindableList.New(self, self.LocationFishListAdapter)},
		{"FishingholeClockList", UIBinderUpdateBindableList.New(self, self.ClockListAdapter)},
		--切换按钮状态
		{"ToggleSwitchState", UIBinderSetCheckedState.New(self, self.VerIconTabs.BtnSwitch)},
		--可见性 
		{"bClockFishListVisible", UIBinderSetIsVisible.New(self, self.SearchPlace, true)}, --钓场列表
		{"bClockFishListVisible", UIBinderSetIsVisible.New(self, self.PanelClockWin)}, --闹钟列表
		{"bClockFishListVisible", UIBinderSetIsVisible.New(self, self.ClockPanelTab)}, --闹钟页签
		{"bPanelMapVisible", UIBinderSetIsVisible.New(self, self.PanelMap)},--地图(在搜索列表/闹钟列表空时不显示，鱼类详情信息显示时也不显示)
		{"bPanelMapVisible", UIBinderSetIsVisible.New(self, self.TextPlace)},--地图下方钓场名
		{"bFishDetailsVisible", UIBinderSetIsVisible.New(self, self.FishDetails)},--鱼类详情信息
		{"bFishlistVisible", UIBinderSetIsVisible.New(self, self.Fishlist)},--鱼类详情信息
		{"bFishSearchEmptyVisible", UIBinderSetIsVisible.New(self, self.FishSearchEmpty)},
		{"bClockEmptyVisible", UIBinderSetIsVisible.New(self, self.ClockEmpty)},
		{"bClockNotActiveVisible", UIBinderSetIsVisible.New(self, self.ClockNotActive)},
		{"bFishDetailsVisible", UIBinderValueChangedCallback.New(self, nil, self.OnbFishFDetailsVisibleChanged)},
		--选中势力、钓场
		{"SelectedFactionName", UIBinderSetText.New(self, self.TextTitleName.TextSubtitle)},
		{"SelectedFactionName", UIBinderSetText.New(self, self.AreaTitle.TextTitle)},
		{"ClockTitleName", UIBinderSetText.New(self, self.AreaTitle2.TextTitle)},
		{"SelectedLocationName", UIBinderSetText.New(self, self.TextPlace)},--钓场名和类型
		{"UnlockFishProgress", UIBinderSetText.New(self, self.TextNumber)},--钓场中鱼解锁进度
		--地图缩放条
		{ "MapScale", UIBinderSetSlider.New(self, self.MapScalePanel.Slider) },
		{ "MapScale", UIBinderValueChangedCallback.New(self, nil, self.SetProgressBar) },
	}
end

function FishIngholePanelView:OnDestroy()
end

function FishIngholePanelView:OnShow()
	--初始化界面
	FishIngholeVM.TabsComp = self.VerIconTabs
	FishIngholeVM:InitLocationView()
	if self.Params == nil then
		return
	end

	if type(self.Params) == "table" and self.Params.SkipLocationInfo then
		FishIngholeVM.SkipLocationInfo = self.Params.SkipLocationInfo
	end

	if type(self.Params) == "table" and self.Params.TabIndex then
		FishIngholeVM:OnClickSwitch(_G.UE.EToggleButtonState.Checked)
	end
end

function FishIngholePanelView:OnHide(Params)
	FLOG_INFO("FishIngholePanelView:OnHide")
	FishIngholeVM.IsOpenView = false
	FishNotesMgr:RemoveRedDotsOnHide()
	if Params and Params.CrystalID then
		local CrystalPortalCfgItem = CrystalPortalCfg:FindCfgByKey(Params.CrystalID)
		DataReportUtil.ReportSystemFlowData("FishingNotesInfo", 4, CrystalPortalCfgItem.MapID)
	end
	if FishIngholeVM.SearchState then
		--未点击关闭选搜索之前的
		FishIngholeVM.SearchHoleData = nil
		self:OnClickCancelSearchBar()
		self.SearchBar:SetText(" ")
	end
end

function FishIngholePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFishNotes, self.OnClickButtonFishGuide)
	self.VerIconTabs:SetClickButtonSwitchCallback(self, self.OnClickSwitch)
	UIUtil.AddOnClickedEvent(self, self.ClockEmpty.Btn, self.OnClickSwitch)
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnTabSelectChanged)
	self.SearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
	--UIUtil.AddOnFocusReceivedEvent(self, self.SearchBar.TextInput, self.OnBtnSearchClick)

	UIUtil.AddOnValueChangedEvent(self, self.MapScalePanel.Slider, self.OnValueChangedScale)
	UIUtil.AddOnClickedEvent(self, self.MapScalePanel.BtnAdd, self.OnClickedBtnScaleAdd)
	UIUtil.AddOnClickedEvent(self, self.MapScalePanel.BtnSub, self.OnClickedBtnScaleSub)
	self.TextTitleName.CommInforBtn:SetCallback(nil, self.OnHelpBtnClick)
end

function FishIngholePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FishNotesScrollLocationList, self.OnScrollTreeList)
	self:RegisterGameEvent(EventID.FishNotesScrollClockFishList, self.OnScrollClockFishList)
	self:RegisterGameEvent(EventID.FishNoteRefreshLocationList, self.OnRefreshLocationList)
	self:RegisterGameEvent(EventID.FishNoteRefreshGuideList, self.OnRefreshFishData)
	self:RegisterGameEvent(EventID.FishNoteSearchFinished, self.OnFishSearchFinished)
	self:RegisterGameEvent(EventID.FishNoteSearchFishLocation, self.OnSearchFishLocation)
end

function FishIngholePanelView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

function FishIngholePanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

---@type 每秒刷新的计时器
function FishIngholePanelView:OnTimer()
	FishIngholeVM:RefreshSecond()
end
--endregion

--region==============================切换==================================
---@type 切换到鱼类图鉴界面
function FishIngholePanelView:OnClickButtonFishGuide()
	DataReportUtil.ReportSystemFlowData("FishingNotesInfo", 2)
	local Params = nil
	if FishIngholeVM.bFishDetailsVisible == true then
		local Fish = FishIngholeVM.SelectFishData.Cfg
		local LocationID = FishIngholeVM.SelectLocationID
		if Fish ~= nil and _G.FishNotesMgr:CheckFishUnlockInFround(Fish.ID, LocationID) then
			Params = {FishData = Fish}
		end
	end
	UIViewMgr:ShowView(UIViewID.FishGuide, Params)
end

---@type 切换钓场和闹钟列表
function FishIngholePanelView:OnClickSwitch()
	if FishIngholeVM.SearchState then
		self:CancelSearchBar()
	end
    FishIngholeVM:OnClickSwitch(nil, self.BeforSearchSelectData)
	_G.ObjectMgr:CollectGarbage(false, true, false)
end

--region钓场信息----------------------------------------------------------------------------
---@type 切换势力
function FishIngholePanelView:OnTabSelectChanged(Index, ItemData, ItemView)
	if FishIngholeVM:IsClockView() then
		self:OnClockTabSelectChanged(Index)
		return
	end
	if FishIngholeVM.SearchState then
		self:CancelSearchBar()
	end
	if FishIngholeVM.SearchHoleData == nil then
		self:PlayAnimation(self.AnimChangeTab)
	end
	self.SearchBar:SetText('')
	FishIngholeVM:SelectedTabIndex(Index)
	self.LocationTreeAdapter:CancelSelected()
	_G.ObjectMgr:CollectGarbage(false, true, false)
end

---@type 切换选中的区域或钓场
function FishIngholePanelView:OnLocationSelectChanged(Index, ItemData, ItemView)
	FishIngholeVM:OnTreeViewPlaceSelected(ItemData)
	--切换鱼、钓场时计三次数GC
	self.Conunt = (self.Conunt or 0) + 1
	if self.Conunt >= 3 then
		_G.ObjectMgr:CollectGarbage(false, true, false)
		self.Conunt = 0
	end
end

---@type 切换选中钓场鱼类列表的鱼
function FishIngholePanelView:OnLocationFishSelectChanged(Index, ItemData, ItemView)
	FishIngholeVM:SelectedLocationFish(Index)
	self.FishDetails:OnShow()
end
--endregion

--region闹钟列表-----------------------------------------------------------------------------
---@type 切换闹钟页签
function FishIngholePanelView:OnClockTabSelectChanged(Index, ItemData, ItemView)
	self.ClockListAdapter:CancelSelected()
	FishIngholeVM:SelectedClockTabItem(Index)
	if Index == 1 then
		self.ClockEmpty:SetTipsContent(LSTR(FishNotesDefine.ClockEmptyTipsText))
		self.ClockEmpty:SetBtnText(LSTR(180083)) --前往设置
	else
		self.ClockEmpty:SetTipsContent(LSTR("已解锁钓场中暂无活跃中鱼类"))--FishNotesDefine.ClockActiveEmptyTipsText
		self.ClockEmpty:SetBtnText(LSTR("前往解锁")) --180104前往解锁
	end
end

---@type 切换选中闹钟列表中的闹钟
function FishIngholePanelView:OnClockFishSelectChanged(Index, ItemData, ItemView)
	FishIngholeVM:SelectedClockItem(Index)
	self.FishDetails:OnClickedBtnTop()
end
--endregion

--endregion

--region================================滚动==================================
---@type 滚动地区列表到指定下标未知
---@param Index number @下标
function FishIngholePanelView:OnScrollTreeList(Index)
	self.LocationTreeAdapter:ScrollToIndex(Index)
end

function FishIngholePanelView:OnScrollClockFishList(Index)
	self.TableViewClockFish:ScrollIndexIntoView(Index)
end
--endregion

--region================================刷新=================================
function FishIngholePanelView:OnbFishFDetailsVisibleChanged(bVisible)
	if bVisible then
		self:StopAnimation(self.AnimDetailsToMap)
		self:PlayAnimation(self.AnimMapToDetails)
		self.TextTips:SetText(LSTR(180078))--"再次点击返回地图"
	else
		if FishIngholeVM.bPanelMapVisible == true then
			self:StopAnimation(self.AnimMapToDetails)
			self:PlayAnimation(self.AnimDetailsToMap)
			self.TextTips:SetText(LSTR(180079))--"点击查看鱼类详情"
		end
	end
end


function FishIngholePanelView:OnRefreshLocationList()
	FishIngholeVM:InitLocationView()
end

function FishIngholePanelView:OnRefreshFishData()
	FishIngholeVM:InitLocationView()
end
--endregion

--region================================搜索==================================
---@type 非搜索框搜索跳转
function FishIngholePanelView:OnSearchFishLocation(FishItemID)
	self.SearchFishID = FishItemID
	self:AutoSearchFishLocation(FishItemID)
end

function FishIngholePanelView:AutoSearchFishLocation(ItemID)
	if ItemID == nil then
		return
	end

	local FishCfg = FishCfg:FindCfg(string.format("ItemID = %d", ItemID)) or FishCfg:FindCfg(string.format("CollectItemID = %d", ItemID))
	--local ItemCfg = ItemCfg:FindCfgByKey(ItemID)
	if FishCfg then
		local FishName = FishCfg.Name
		self.SearchBar:SetText(FishName)
		self.SearchBar:OnTextCommitted(nil, FishName, TextCommitOnEnter)

		if UIViewMgr:IsViewVisible(UIViewID.FishNotesOtherBait) then
			UIViewMgr:HideView(UIViewID.FishNotesOtherBait)
		end
	end
end

function FishIngholePanelView:SearchLocation(LocationID, FishID)
	local LocationData = FishNotesMgr:GetFishingholeData(LocationID)
	if LocationData then
		self.SearchBar:SetText(LocationData.Name)
		self.SearchBar:OnTextCommitted(nil, LocationData.Name, TextCommitOnEnter)
	end
end

function FishIngholePanelView:OnBtnSearchClick()
	self.LastSearchText = ""
end

---@param SearchText string @回调的文本
---@param Type number @输入的类型, 1: OnEnter, 2: OnUserMovedFocus, 3: OnCleared
function FishIngholePanelView:OnSearchTextCommitted(SearchText, Type)
	if string.isnilorempty(SearchText) or self.LastSearchText == SearchText then
		return
	end
	FishIngholeVM.SearchState = true
	self.LastSearchText = SearchText

	self.BeforSearchSelectData = {
		FactionIndex = FishIngholeVM.SelectFactionIndex,
		AreaIndex = FishIngholeVM.SelectAreaIndex,
		LocationIndex = FishIngholeVM.SelectAreasChildIndex[FishIngholeVM.SelectAreaIndex]}
	self.VerIconTabs.AdapterTabs:CancelSelected()
	self.LocationFishListAdapter:CancelSelected()

	UIUtil.SetIsVisible(self.AreaTitle,false)
	--UIUtil.SetIsVisible(self.TextTitleName.TextSubtitle,false)
	FishIngholeVM:FishIngholeSearch(SearchText, string.len(SearchText))
    self:PlayAnimation(self.AnimSearch)
	self.FishDetails:OnShow()
end

---@type 点击关闭按钮
function FishIngholePanelView:OnClickCancelSearchBar()
	self:CancelSearchBar()

	--搜索后选中
	if FishIngholeVM.SearchHoleData then
		--选中左侧页签
		local Faction = FishNotesMgr:GetFactionNameByAreaName(FishIngholeVM.SearchHoleData.AreaName)
		local FactionIndex = FishNotesMgr:GetFactionIndexByFactionName(Faction)
		self.VerIconTabs:SetSelectedIndex(FactionIndex)
	else
		--如果没有结果，保持搜索前的选择
		if self.BeforSearchSelectData then
			local FactionIndex = self.BeforSearchSelectData.FactionIndex or 2
			self.VerIconTabs:SetSelectedIndex(FactionIndex)
			local AreaIndex = self.BeforSearchSelectData.AreaIndex or 1
			FishIngholeVM:AreaStateChanged(FactionIndex, AreaIndex)
			local LocationIndex = self.BeforSearchSelectData.LocationIndex or 1
			FishIngholeVM:SelectedLocation(AreaIndex, LocationIndex)
        else
			self.VerIconTabs:SetSelectedIndex(2)
		end
	end
	self.FishDetails:OnShow()
end

---@type 清空搜索框
function FishIngholePanelView:CancelSearchBar()
	FishIngholeVM.SearchState = false
	FishIngholeVM.SearchFishContent = nil
	UIUtil.SetIsVisible(self.AreaTitle,true)
	--UIUtil.SetIsVisible(self.TextTitleName.TextSubtitle,true)
	self.LastSearchText = nil
	self.SearchBar:SetText('')
	FishIngholeVM:FishIngholeSearch("", 0)
end

function FishIngholePanelView:OnFishSearchFinished()
	if self.SearchFishID then
		local ItemCfg = ItemCfg:FindCfgByKey(self.SearchFishID)
		if ItemCfg then
			local IDs = FishCfg:FindAllIDsByItemID(self.SearchFishID)
			local FishID = nil
			if #IDs > 0 then
				FishID = IDs[1]
			end
			
			FishIngholeVM:SelectedLocation(1, 1, FishID)
		end
		self.SearchFishID = nil
	end
end


--endregion

--region================================地图缩放===============================
function FishIngholePanelView:SetProgressBar(Value)
	local UIMapMinScale = FishIngholeVM.UIMapMinScale
	local UIMapMaxScale = FishIngholeVM.UIMapMaxScale
	self.MapScalePanel:UpdateSlider(UIMapMinScale, UIMapMaxScale)
	self.MapScalePanel.ProgressBar:SetPercent((Value - UIMapMinScale) / (UIMapMaxScale - UIMapMinScale))
end

function FishIngholePanelView:OnValueChangedScale(_, Value)
	self:OnMapScaleChange(Value)
end

function FishIngholePanelView:OnClickedBtnScaleAdd()
	local Value = self.MapScalePanel.Slider:GetValue()
	local NewValue = Value + 0.2
	self:OnMapScaleChange(NewValue)
end

function FishIngholePanelView:OnClickedBtnScaleSub()
	local Value = self.MapScalePanel.Slider:GetValue()
	local NewValue = Value - 0.2
	self:OnMapScaleChange(NewValue)
end

function FishIngholePanelView:OnMapScaleChange(Scale)
    _G.FishIngholeVM:SetMapScale(Scale)
	_G.EventMgr:SendEvent(EventID.FishNotesMapScaleChanged, _G.FishIngholeVM.MapScale)
end
--endregion

function FishIngholePanelView:OnHelpBtnClick()
	UIViewMgr:ShowView(UIViewID.FishIngholeInfoWin)
end

return FishIngholePanelView