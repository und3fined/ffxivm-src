---
--- Author: sammrli
--- DateTime: 2024-02-02 16:52
--- Description:旅行笔记
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local EventID = require("Define/EventID")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require ("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local TravelLogMainPanelVMClass = require("Game/TravelLog/VM/TravelLogMainPanelVM")
local TravelLogTaskTitleItemVM = require("Game/TravelLog/VM/TravelLogTaskTitleItemVM")
local TravelLogTypeVM = require("Game/TravelLog/VM/TravelLogTypeVM")

---页签屏蔽列表
local IGNORE_TAB_LIST = {4}

local TYPE_ICON_PATH = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_TravelLog_00%d.UI_Icon_Tab_TravelLog_00%d'"
local MAX_TAB_NUM = 7

local LSTR = _G.LSTR

---@class TravelLogMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field CommBtnL_UIBP CommBtnLView
---@field CommVerIconTab CommVerIconTabsView
---@field CommonTitle CommonTitleView
---@field DropDownList CommDropDownListView
---@field FTreeView_86 UFTreeView
---@field IconTask UFImage
---@field PanelNull UFCanvasPanel
---@field PanelRightContent UFCanvasPanel
---@field ScrollBox_0 UScrollBox
---@field SearchBar CommSearchBarView
---@field SearchBtn CommSearchBtnView
---@field Spine_TravelLog_Pen USpineWidget
---@field TextContent URichTextBox
---@field TextNull UFTextBlock
---@field TextTaskTitle UFTextBlock
---@field TravelLogFilmItem_UIBP TravelLogFilmItemView
---@field AnimChangeMission UWidgetAnimation
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimIn0 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field TravelLogMainPanelVM TravelLogMainPanelVM
local TravelLogMainPanelView = LuaClass(UIView, true)

function TravelLogMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.CommBtnL_UIBP = nil
	--self.CommVerIconTab = nil
	--self.CommonTitle = nil
	--self.DropDownList = nil
	--self.FTreeView_86 = nil
	--self.IconTask = nil
	--self.PanelNull = nil
	--self.PanelRightContent = nil
	--self.ScrollBox_0 = nil
	--self.SearchBar = nil
	--self.SearchBtn = nil
	--self.Spine_TravelLog_Pen = nil
	--self.TextContent = nil
	--self.TextNull = nil
	--self.TextTaskTitle = nil
	--self.TravelLogFilmItem_UIBP = nil
	--self.AnimChangeMission = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--self.AnimIn0 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.TravelLogMainPanelVM = TravelLogMainPanelVMClass.New()
	self.CurrentTabIndex = -1 --从0开始
	self.CurrentSubGenreIndex = -1 --从1开始
	self.CurrentLogID = 0
end

function TravelLogMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommBtnL_UIBP)
	self:AddSubView(self.CommVerIconTab)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SearchBtn)
	self:AddSubView(self.TravelLogFilmItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TravelLogMainPanelView:OnInit()
	self.TaskLogListAdapter = UIAdapterTreeView.CreateAdapter(self, self.FTreeView_86)
	self.TaskLogListAdapter:InitCategoryInfo(TravelLogTaskTitleItemVM)
	self.TaskLogListAdapter.bClearCache = true

	self.SearchBar.BtnCancelAlwaysVisible = true
end

function TravelLogMainPanelView:OnDestroy()

end

function TravelLogMainPanelView:OnShow()
	local TabDataList = {}
	for i=1, MAX_TAB_NUM do
		local VM = TravelLogTypeVM.New(i)
		VM.IconPath = string.format(TYPE_ICON_PATH, i, i)
		VM.RedDotData = { RedDotName = _G.TravelLogMgr:GetMainGenreRedDotName(i)}
		table.insert(TabDataList, VM)
	end
	local Params = self.Params
	if Params and Params.TabIndex then
		self.CommVerIconTab:UpdateItems(TabDataList, Params.TabIndex)
		self:OnTypeTabSelectChanged(Params.TabIndex)
		if Params.SubGenreIndex then
			self.DropDownList:SetDropDownIndex(Params.SubGenreIndex)
		end
		self:RegisterTimer(self.OnTimeRecoverLastStatus, 0.1)
	else
		self.CommVerIconTab:UpdateItems(TabDataList, 1)
		self:OnTypeTabSelectChanged(1)
	end
	self.CommonTitle:SetSubTitleIsVisible(true)
	self.CommonTitle:SetCommInforBtnIsVisible(false)

	UIUtil.SetIsVisible(self.SearchBar, false)
	UIUtil.SetIsVisible(self.SearchBtn, true)
	UIUtil.SetIsVisible(self.DropDownList, true)
	self.TravelLogMainPanelVM:SetFilterText("")
	UIUtil.SetIsVisible(self.CommonTitle.TextSubTitle, true)
	self.SearchBar:SetHintText(LSTR(530006)) --530006("搜索笔录")
	self.SearchBar:SetIllegalTipsText(LSTR(10057)) --10057("当前文本不可使用，请重新输入")
	--self.TextTitle:SetText(LSTR(530007)) --530007("旅行笔录")
	self.CommonTitle:SetTextTitleName(LSTR(530007)) --530007("旅行笔录")
	self.CommBtnL_UIBP:SetBtnName(LSTR(530009)) --530009("播放")
end

function TravelLogMainPanelView:OnHide()
	self.CurrentTabIndex = -1
	self:ClearLastPageTaskRedDot()
end

function TravelLogMainPanelView:OnRegisterUIEvent()
	--UIUtil.AddOnStateChangedEvent(self, self.PanelTab, self.OnToggleGroupPanelTab)
	UIUtil.AddOnClickedEvent(self, self.CommBtnL_UIBP, self.OnClickedPlayHandle)
	self.SearchBar:SetCallback(self, nil, self.OnCommittedCallback, self.OnClickCancelBtnCallback)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnDropDownListSelectionChanged)
	UIUtil.AddOnClickedEvent(self,  self.SearchBtn.BtnSearch, self.OnClickedSearchHandle)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommVerIconTab, self.OnTypeTabSelectChanged)
	UIUtil.AddOnItemShowEvent(self, self.CommVerIconTab.AdapterTabs, self.OnTabItemShow)
end

function TravelLogMainPanelView:OnCommittedCallback(SearchText)
	self.TravelLogMainPanelVM:SetFilterText(SearchText)
	UIUtil.SetIsVisible(self.CommonTitle.TextSubTitle, false)
	--默认选第一个
	self:SetSelectFirstItem()
end

function TravelLogMainPanelView:OnClickCancelBtnCallback()
	UIUtil.SetIsVisible(self.SearchBar, false)
	UIUtil.SetIsVisible(self.SearchBtn, true)
	UIUtil.SetIsVisible(self.DropDownList, true)
	self.TravelLogMainPanelVM:SetFilterText("")
	UIUtil.SetIsVisible(self.CommonTitle.TextSubTitle, true)
	--默认选第一个
	self:SetSelectFirstItem()
end

function TravelLogMainPanelView:OnDropDownListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	if self.CurrentSubGenreIndex == Index then
		return
	end
	self:ClearLastPageTaskRedDot()
	self.CurrentSubGenreIndex = Index
	local GenreData = self.GenreDropDownListData[Index]
	if GenreData then
		local GenreID = GenreData.Type
		self.TravelLogMainPanelVM:ChangeGenre(GenreID)
		--默认选中第一个
		self:SetSelectFirstItem()
		_G.TravelLogMgr:DeleteSubGenreRedDot(GenreID)
		self.FTreeView_86:ScrollToTop()
	end
end

function TravelLogMainPanelView:SetSelectFirstItem()
	local LogVM = self.TravelLogMainPanelVM.LogVMList:Get(1)
	if LogVM then
		local LogID = LogVM.ItemVM1.LogID
		self.CurrentLogID = LogID
		self:UpdateSelectedItem(LogID)
	end
end

function TravelLogMainPanelView:OnClickedSearchHandle()
	UIUtil.SetIsVisible(self.SearchBar, true)
	UIUtil.SetIsVisible(self.SearchBtn, false)
	UIUtil.SetIsVisible(self.DropDownList, false)

	self.SearchBar:SetFocus()
	self.SearchBar:SetText('')
end

function TravelLogMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SelectTravelLogItem, self.OnClickSelectTravelLogItem)
end

function TravelLogMainPanelView:OnRegisterBinder()
	local Binders = {
		{"LogVMList", UIBinderUpdateBindableList.New(self, self.TaskLogListAdapter)},
		{"TaskTitle", UIBinderSetText.New(self, self.TextTaskTitle)},
		{"Content", UIBinderSetText.New(self, self.TextContent)},
		{"GenreTitle", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle)},
		{"IsRightContentVisible", UIBinderSetIsVisible.New(self, self.PanelRightContent)},
		{"IsEmptyVisible", UIBinderSetIsVisible.New(self, self.PanelNull)},
		{"IconTaskPath", UIBinderSetBrushFromAssetPath.New(self, self.IconTask)},
		{"TextNull", UIBinderSetText.New(self, self.TextNull)},
	}
	self:RegisterBinders(self.TravelLogMainPanelVM, Binders)
end

---Index从1开始
function TravelLogMainPanelView:OnTypeTabSelectChanged(Index)
	local IsClearSearch = false
	if not string.isnilorempty(self.TravelLogMainPanelVM.FilterText) then
		-- 如果点击标签还有搜索数据，清理搜索及显示正常界面
		UIUtil.SetIsVisible(self.SearchBar, false)
		UIUtil.SetIsVisible(self.SearchBtn, true)
		UIUtil.SetIsVisible(self.DropDownList, true)
		self.TravelLogMainPanelVM:SetFilterText("")
		UIUtil.SetIsVisible(self.CommonTitle.TextSubTitle, true)
		IsClearSearch = true
	end

	if not IsClearSearch and self.CurrentTabIndex == Index then
		return
	end
	if self.CurrentTabIndex > -1 then
		self:ClearLastPageTaskRedDot()
	end

	self.CurrentTabIndex = Index
	self.CurrentSubGenreIndex = 1
	--二级分类页签
	local GenreDropDownListData = self.TravelLogMainPanelVM:GetDropDownListData(Index)
	self.GenreDropDownListData = GenreDropDownListData
	if not GenreDropDownListData or #GenreDropDownListData == 0 then
		return
	end
	local GenreID = GenreDropDownListData[1].Type
	self.DropDownList:UpdateItems(GenreDropDownListData, 1)
	self.TravelLogMainPanelVM:ChangeGenre(GenreID)
    --默认选中第一个
	self:SetSelectFirstItem()
	self:PlayAnimation(self.AnimChangeTab)

	self.FTreeView_86:ScrollToTop()

	--去掉红点
	_G.TravelLogMgr:DeleteMainGenreRedDot(Index)
	_G.TravelLogMgr:DeleteSubGenreRedDot(GenreID)
end

function TravelLogMainPanelView:OnTabItemShow(ItemView, Item)
	--obt隐藏好友部族页签,tableview没有创建全部item完成的回调,暂时在这里处理
	local AdapterTabs = self.CommVerIconTab.AdapterTabs
	if AdapterTabs then
		local EntryWidgeIndex = AdapterTabs:GetItemIndex(Item)
		if EntryWidgeIndex == MAX_TAB_NUM then --创建完毕
			for _, Index in ipairs(IGNORE_TAB_LIST) do
				local EntryWidge = AdapterTabs:GetChildWidget(Index)
				if EntryWidge then
					UIUtil.SetIsVisible(EntryWidge, false)
				end
			end
		end
	end
end

function TravelLogMainPanelView:OnClickedPlayHandle()
	self.TravelLogFilmItem_UIBP:Play(self.CurrentTabIndex, self.FTreeView_86:GetScrollOffset(), self.CurrentSubGenreIndex)
end

function TravelLogMainPanelView:OnClickSelectTravelLogItem(LogID)
	if self.CurrentLogID == LogID then
		return
	end
	self.CurrentLogID = LogID
	self:UpdateSelectedItem(LogID)
	self:PlayAnimation(self.AnimChangeMission)
end

function TravelLogMainPanelView:OnTimeRecoverLastStatus()
	if not self.IsShowView then
		return
	end
	local Params = self.Params
	if Params then
		if Params.ScrollOffset then
			self.FTreeView_86:SetScrollOffset(Params.ScrollOffset)
		end
		if Params.SelectedLogID then
			self.CurrentLogID = Params.SelectedLogID
			self:UpdateSelectedItem(Params.SelectedLogID)
		end
	end
end

function TravelLogMainPanelView:UpdateSelectedItem(LogID)
	self.TravelLogMainPanelVM:UpdateTaskContent(LogID)
	self.TravelLogMainPanelVM:SetSelectedTaskItne(LogID)
	self.TravelLogFilmItem_UIBP:Show(LogID)
	self.ScrollBox_0:EndInertialScrolling()
	self.ScrollBox_0:ScrollToStart()
	_G.ObjectMgr:CollectGarbage(false, false, false)
end

---清除当前页所有红点
function TravelLogMainPanelView:ClearLastPageTaskRedDot()
	self.TravelLogMainPanelVM:ClearPageTaskRedDot()
end

return TravelLogMainPanelView