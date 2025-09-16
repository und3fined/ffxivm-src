---
--- Author: ZhengJanChuan
--- DateTime: 2023-05-31 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TutorialGuidePanelVM = require("Game/Tutorial/VM/TutorialGuidePanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local GuideTypeCfg = require("TableCfg/GuideTypeCfg")
local UIDefine = require("Define/UIDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local CommBtnColorType = UIDefine.CommBtnColorType

---@class TutorialGuidePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Banner TutorialGuideShowBannerItemView
---@field BtnClose CommonCloseBtnView
---@field BtnPgDn CommBtnLView
---@field BtnPgUp CommBtnLView
---@field CommTabsModule CommVerIconTabsView
---@field CommonBkg CommonBkg01View
---@field Details UFCanvasPanel
---@field DetailsPanel UFCanvasPanel
---@field FTreeViewSearch UFTreeView
---@field Img2 UFImage
---@field ImgBanner UFImage
---@field ImgFrame2 UFImage
---@field List UFCanvasPanel
---@field NotNoviceGuide CommBackpackEmptyView
---@field NotSearched CommEmptyView
---@field RichTextContent URichTextBox
---@field RichTextTitle URichTextBox
---@field SearchBar CommSearchBarView
---@field TableViewDrop UTableView
---@field TableViewList UTableView
---@field TextModuleName UFTextBlock
---@field TextTitleName UFTextBlock
---@field AnimChapterTurn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGuidePanelView = LuaClass(UIView, true)

function TutorialGuidePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Banner = nil
	--self.BtnClose = nil
	--self.BtnPgDn = nil
	--self.BtnPgUp = nil
	--self.CommTabsModule = nil
	--self.CommonBkg = nil
	--self.Details = nil
	--self.DetailsPanel = nil
	--self.FTreeViewSearch = nil
	--self.Img2 = nil
	--self.ImgBanner = nil
	--self.ImgFrame2 = nil
	--self.List = nil
	--self.NotNoviceGuide = nil
	--self.NotSearched = nil
	--self.RichTextContent = nil
	--self.RichTextTitle = nil
	--self.SearchBar = nil
	--self.TableViewDrop = nil
	--self.TableViewList = nil
	--self.TextModuleName = nil
	--self.TextTitleName = nil
	--self.AnimChapterTurn = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGuidePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Banner)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnPgDn)
	self:AddSubView(self.BtnPgUp)
	self:AddSubView(self.CommTabsModule)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.NotNoviceGuide)
	self:AddSubView(self.NotSearched)
	self:AddSubView(self.SearchBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGuidePanelView:OnInit()
	-- self.TutorialGuidePanelVM = TutorialGuidePanelVM.New()
	self.TutorialGuidePanelVM = TutorialGuidePanelVM
	self.TableViewDropAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDrop, nil, true)
	self.TreeViewSearchAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSearchListSelectedChanged, true)
	self.GroupTableListAdapter = UIAdapterTreeView.CreateAdapter(self, self.FTreeViewSearch, self.OnGroupTableSelectedChanged, true)
end

function TutorialGuidePanelView:OnDestroy()
end

function TutorialGuidePanelView:OnShow()

	self.SecondTabListData = {}
	self.GuideID = nil -- 指南id
	self.SecondTabIndex = 1 -- 二级界面Index
	self.GuideIndex = 1  -- 指南在当前组的Index
	self.ContentIndex = 1	--- 页面内容Index
	self.InitSelect = false
	self.SearchingGuideIndex = 1 --- 搜索GuideIndex
	self.SearchingGuideContentIndex = 1 --搜索页面内容Index

	UIUtil.SetIsVisible(self.NotNoviceGuide.PanelBtn, false)
	self.NotNoviceGuide:SetTipsContent(_G.LSTR(890001))
	self.NotSearched.Text_SearchAgain:SetText(_G.LSTR(890002))
	self.SearchBar:SetHintText(_G.LSTR(890003))
	self.TextTitleName:SetText(_G.LSTR(890007))
	self.BtnPgUp:SetText(_G.LSTR(890008))
	self.BtnPgDn:SetText(_G.LSTR(890009))
	self:InitTab()
end

function TutorialGuidePanelView:InitTab()
	local GuideTypeCfgs = GuideTypeCfg:FindAllCfg()
	self.SecondTabListData = {}
	self.InitSelect = true

	for _, v in ipairs(GuideTypeCfgs) do
		local Data = {}
		Data.GuideTypeID = v.GuideTypeID
		Data.IconPath = v.Icon
		Data.SelectIcon = v.SelectIcon
		Data.Priority = v.Priority
		Data.GuideName = v.GuideName
		table.insert(self.SecondTabListData, Data)
	end

	table.sort(self.SecondTabListData, function (a, b) return a.Priority < b.Priority end)

	self.CommTabsModule:UpdateItems(self.SecondTabListData, 1)

	self.TutorialGuidePanelVM.TabSelectIndex = 1
end

function TutorialGuidePanelView:OnHide()
	self:OnClickCancelSearchBar()
	-- 发送所有界面的红点移除
	_G.TutorialGuideMgr:SendAllGuideSchedule()
end

function TutorialGuidePanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommTabsModule, self.OnSelectionChangedTabs)
	UIUtil.AddOnClickedEvent(self, self.BtnPgUp, self.OnClickedPrePage)
	UIUtil.AddOnClickedEvent(self, self.BtnPgDn, self.OnClickedNextPage)
	self.SearchBar:SetCallback(self, nil, self.OnSearchTextChange,  self.OnClickCancelSearchBar)
end


function TutorialGuidePanelView:OnRegisterGameEvent()
	--self:RegisterGameEvent(_G.EventID.TutorialGuideIdChanged, self.OnTutorialGuideIdChanged)
end 

function TutorialGuidePanelView:OnRegisterBinder()
	local Binders = {
		{"DropList", UIBinderUpdateBindableList.New(self, self.TableViewDropAdapter)},
		{"TreeViewSearchList", UIBinderUpdateBindableList.New(self, self.TreeViewSearchAdapter)},
		{"GroupTableList", UIBinderUpdateBindableList.New(self, self.GroupTableListAdapter)},
		{"RichTextContent", UIBinderSetText.New(self, self.RichTextContent)},
		{"TextTitle", UIBinderSetText.New(self, self.RichTextTitle)},
		{"GuidePic", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)},
		{"NotTutorialGuideVisble", UIBinderSetIsVisible.New(self, self.NotNoviceGuide)},
		{"NotSearchedVisible", UIBinderSetIsVisible.New(self, self.NotSearched)},
		{"ContentVisible", UIBinderSetIsVisible.New(self, self.Details)},
		{"DropListSelectIndex", UIBinderSetSelectedIndex.New(self, self.TableViewDropAdapter)},
		{"GroupTableListVisible", UIBinderSetIsVisible.New(self, self.FTreeViewSearch)},
		{"SearchListVisible", UIBinderSetIsVisible.New(self, self.TableViewList)},
		{"IsSearching", UIBinderValueChangedCallback.New(self, nil, self.OnSearchingChanged)},
		{"SpecShowPic", UIBinderSetBrushFromAssetPath.New(self, self.Img2,true)},
		{"SpecShowPicShow", UIBinderSetIsVisible.New(self, self.Img2, false, true)},
	}
	
	self:RegisterBinders(self.TutorialGuidePanelVM, Binders)
end

function TutorialGuidePanelView:OnSearchingChanged()
	if not self.TutorialGuidePanelVM.IsSearching then
		self.TutorialGuidePanelVM.GroupTableListVisible = true
		self.TutorialGuidePanelVM.SearchListVisible = false
		self.TutorialGuidePanelVM.NotSearchedVisible = false
		self.TutorialGuidePanelVM.ContentVisible = true 
		self.SearchBar:SetText('')
	else
		self.TutorialGuidePanelVM.GroupTableListVisible = false
		self.TutorialGuidePanelVM.SearchListVisible = true
	end
end

function TutorialGuidePanelView:OnSearchListSelectedChanged(Index, ItemData, ItemView)
	self.TutorialGuidePanelVM:UpdateCurContent(ItemData.GuideID, 1)
	self.SearchingGuideContentIndex = 1
	self.SearchingGuideIndex = Index
	self:OnSearchingPaUpAndDnState(Index, self.SearchingGuideContentIndex)
end


function TutorialGuidePanelView:OnGroupTableSelectedChanged(Index, ItemData, ItemView)
	if ItemData.WidgetIndex ~= nil then
		if not self.InitSelect then
			DataReportUtil.ReportTutorialGuideData(tostring(ItemData.GuideID))
		end
	end

	self.ContentIndex = 1
	self.GuideIndex = ItemData.Index
	ItemView:ChangedNewStatus()
	self.TutorialGuidePanelVM:UpdateCurContent(ItemData.GuideID, 1)
	self:OnPaUpAndDnState(self.GuideIndex, self.ContentIndex)
	self.InitSelect = false
end

-- 点击分类栏
function TutorialGuidePanelView:OnSelectionChangedTabs(TabIndex)
	self.GuideIndex = 1
	self.ContentIndex = 1
	self.SecondTabIndex = TabIndex
	self.TextModuleName:SetText(self.SecondTabListData[TabIndex].GuideName)

	-- if self.TutorialGuidePanelVM.IsSearching then
	self.TutorialGuidePanelVM.IsSearching = false
	-- 	return
	-- end

	self.TutorialGuidePanelVM:UpdateTabGroup(self.SecondTabListData[TabIndex].GuideTypeID)
	self.TutorialGuidePanelVM:UpdateGroupVisible()

	self.GuideID = self.TutorialGuidePanelVM:GetGuideID(self.GuideIndex)
	if self.TutorialGuidePanelVM.SearchGuideID ~= nil then
		local ScrollIndex = self.TutorialGuidePanelVM:GetItemRealIndex(self.TutorialGuidePanelVM.SearchGuideID)
		if ScrollIndex ~= nil then
			self.GuideID = self.TutorialGuidePanelVM.SearchGuideID
			self.GuideIndex = self.TutorialGuidePanelVM:GetGuideIndex(self.GuideID)
		end
	end

	-- 数据可能没刷新，用的老数据
	self:RegisterTimer(function () 
		local ScrollIndex = self.TutorialGuidePanelVM:GetItemRealIndex(self.GuideID)
		self.GroupTableListAdapter:CancelSelected()
		self.GroupTableListAdapter:SetSelectedKey(self.GuideID)
		self.GroupTableListAdapter:ScrollToIndex(ScrollIndex)
	end, 0.03)


end

function TutorialGuidePanelView:OnTutorialGuideIdChanged(Param)
	if Param == nil then
		return
	end
	
	if Param.GuideIndex == nil then	
		return
	end

	self.GuideIndex = Param.GuideIndex
	self.ContentIndex = Param.ContentIndex
	self:OnPaUpAndDnState(self.GuideIndex, self.ContentIndex)
end

-- 点击上一页
function TutorialGuidePanelView:OnClickedPrePage()

	if  not self.TutorialGuidePanelVM.IsSearching then
		local GuideIndex = self.GuideIndex 
		local ContentIndex = self.ContentIndex

		if ContentIndex <= 1 and GuideIndex <= 1 then
			return
		end

		if ContentIndex == 1 then
			-- 向上
			local LastGuideID = self.TutorialGuidePanelVM:GetGuideID(GuideIndex - 1)
			GuideIndex = self.TutorialGuidePanelVM:GetGuideIndex(LastGuideID)
			local ScrollIndex = self.TutorialGuidePanelVM:GetItemRealIndex(LastGuideID)
			self.GroupTableListAdapter:SetSelectedKey(LastGuideID)
			self.GroupTableListAdapter:ScrollToIndex(ScrollIndex)
		else
			ContentIndex = ContentIndex - 1
			self.TutorialGuidePanelVM.DropListSelectIndex = ContentIndex
			local GuideID = self.TutorialGuidePanelVM:GetGuideID(GuideIndex)
			self.TutorialGuidePanelVM:UpdateCurContent(GuideID, ContentIndex)
			self:OnPaUpAndDnState(GuideIndex, ContentIndex)
			self.ContentIndex = ContentIndex
			self.GuideIndex = GuideIndex
		end
		return
	end

	local GuideIndex = self.SearchingGuideIndex
	local ContentIndex = self.SearchingGuideContentIndex

	if ContentIndex <= 1 and GuideIndex <= 1 then
		return
	end

	if ContentIndex == 1 then
		ContentIndex = 1
		local LastGuideIndex = GuideIndex - 1
		self.TreeViewSearchAdapter:SetSelectedIndex(LastGuideIndex)
		self.TreeViewSearchAdapter:ScrollToIndex(LastGuideIndex)
	else
		ContentIndex = ContentIndex - 1
		local GuideID = self.TutorialGuidePanelVM:GetSearchingGuideID(GuideIndex)
		self.TutorialGuidePanelVM.DropListSelectIndex = ContentIndex
		self:OnSearchingPaUpAndDnState(GuideIndex, ContentIndex)
		self.TutorialGuidePanelVM:UpdateCurContent(GuideID, ContentIndex)
		self.SearchingGuideContentIndex = ContentIndex
		self.SearchingGuideIndex = GuideIndex
	end

end

-- 点击下一页
function TutorialGuidePanelView:OnClickedNextPage()
	if not self.TutorialGuidePanelVM.IsSearching then
		local GuideIndex = self.GuideIndex
		local ContentIndex = self.ContentIndex
		local SecondTabLen =  self.SecondTabIndex == 1 and self.GroupTableListAdapter:GetNum() or self.TutorialGuidePanelVM:GetGroupTabListChildrenNum()
		local ContentTabLen = self.TableViewDropAdapter:GetNum()

		if ContentIndex >= ContentTabLen and GuideIndex >= SecondTabLen then
			return 
		end

		if ContentIndex == ContentTabLen then
			ContentIndex = 1
			local NextGuideID = self.TutorialGuidePanelVM:GetGuideID(GuideIndex + 1)
			GuideIndex = self.TutorialGuidePanelVM:GetGuideIndex(NextGuideID)
			self.GroupTableListAdapter:SetSelectedKey(NextGuideID)
			local ScrollIndex = self.TutorialGuidePanelVM:GetItemRealIndex(NextGuideID)
			self.GroupTableListAdapter:ScrollToIndex(ScrollIndex)
		else
			ContentIndex = ContentIndex + 1
			local GuideID = self.TutorialGuidePanelVM:GetGuideID(GuideIndex)
			self.TutorialGuidePanelVM.DropListSelectIndex = ContentIndex
			self.TutorialGuidePanelVM:UpdateCurContent(GuideID, ContentIndex)
			self:OnPaUpAndDnState(GuideIndex, ContentIndex)
			self.ContentIndex = ContentIndex
			self.GuideIndex = GuideIndex
		end
		return
	end

	-- 搜索状态下的next
	local GuideIndex = self.SearchingGuideIndex
	local ContentIndex = self.SearchingGuideContentIndex

	local SecondTabLen =  self.TreeViewSearchAdapter:GetNum()
	local ContentTabLen = self.TableViewDropAdapter:GetNum()

	if ContentIndex >= ContentTabLen and GuideIndex >= SecondTabLen then
		return 
	end

	if ContentIndex == ContentTabLen then
		ContentIndex = 1
		local NextGuideIndex = GuideIndex + 1
		-- local NextGuideID = self.TutorialGuidePanelVM:GetSearchingGuideID(NextGuideIndex)
		self.TreeViewSearchAdapter:SetSelectedIndex(NextGuideIndex)
		self.TreeViewSearchAdapter:ScrollToIndex(NextGuideIndex)
	else
		ContentIndex = ContentIndex + 1
		local GuideID = self.TutorialGuidePanelVM:GetSearchingGuideID(GuideIndex)
		self.TutorialGuidePanelVM.DropListSelectIndex = ContentIndex
		self.TutorialGuidePanelVM:UpdateCurContent(GuideID, ContentIndex)
		self:OnSearchingPaUpAndDnState(GuideIndex, ContentIndex)
		self.SearchingGuideContentIndex = ContentIndex
		self.SearchingGuideIndex = GuideIndex
	end
end

-- 如果当前处于该组第一个第一页 up 置灰
-- 如果当前处于该组最后一个最后一页 Dn 置灰
function TutorialGuidePanelView:OnPaUpAndDnState(GuideIndex, ContentIndex)
	if GuideIndex == nil or ContentIndex == nil then
		return
	end

	local SecondTabLen =  self.SecondTabIndex == 1 and self.GroupTableListAdapter:GetNum() or self.TutorialGuidePanelVM:GetGroupTabListChildrenNum()
	local ContentTabLen = self.TableViewDropAdapter:GetNum()

	if GuideIndex <= 1 and ContentIndex <= 1 then
		-- self.BtnPgUp:UpdateImage(CommBtnColorType.Normal)
		self.BtnPgUp:SetIsDisabledState(true, true)
	else
		-- self.BtnPgUp:UpdateImage(CommBtnColorType.Recommend)
		self.BtnPgUp:SetIsNormalState(true)
	end

	if GuideIndex >= SecondTabLen and ContentIndex >= ContentTabLen then
		--self.BtnPgDn:UpdateImage(CommBtnColorType.Normal)
		self.BtnPgDn:SetIsDisabledState(true, true)
	else
		-- self.BtnPgDn:UpdateImage(CommBtnColorType.Recommend)
		self.BtnPgDn:SetIsNormalState(true)
	end
end

function TutorialGuidePanelView:OnSearchingPaUpAndDnState(GuideIndex, ContentIndex)
	if GuideIndex == nil or ContentIndex == nil then
		return
	end
	local SecondTabLen = self.TreeViewSearchAdapter:GetNum()
	local ContentTabLen = self.TableViewDropAdapter:GetNum()

	if GuideIndex <= 1 and ContentIndex <= 1 then
		-- self.BtnPgUp:UpdateImage(CommBtnColorType.Normal)
		self.BtnPgUp:SetIsDisabledState(true, true)
	else
		-- self.BtnPgUp:UpdateImage(CommBtnColorType.Recommend)
		self.BtnPgUp:SetIsNormalState(true)
	end

	if GuideIndex >= SecondTabLen and ContentIndex >= ContentTabLen then
		-- self.BtnPgDn:UpdateImage(CommBtnColorType.Normal)
		self.BtnPgDn:SetIsDisabledState(true, true)
	else
		-- self.BtnPgDn:UpdateImage(CommBtnColorType.Recommend)
		self.BtnPgDn:SetIsNormalState(true)
	end
end

function TutorialGuidePanelView:OnSearchTextChange(SearchText, Length)
	self.TutorialGuidePanelVM.IsSearching = true
	self.TutorialGuidePanelVM:Search(SearchText, Length)
	self.TreeViewSearchAdapter:SetSelectedIndex(1)

	if  Length > 0 then
		self.TutorialGuidePanelVM.TabSelectIndex = 1
		self.CommTabsModule:SetSelectedIndex(self.TutorialGuidePanelVM.TabSelectIndex)
	end
end

function TutorialGuidePanelView:OnClickCancelSearchBar()
	self.TutorialGuidePanelVM.IsSearching = false
	self:InitTab()
	self.TutorialGuidePanelVM.SearchGuideID  = nil
	self.TutorialGuidePanelVM.NotSearchedVisible = false
end

return TutorialGuidePanelView
