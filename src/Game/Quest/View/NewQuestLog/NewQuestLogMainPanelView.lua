---
--- Author: lydianwang
--- DateTime: 2023-05-25 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")

local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local QuestCategoryVM = require("Game/Quest/VM/DataItemVM/QuestCategoryVM")
local QuestCategorySubGenreVM = require("Game/Quest/VM/DataItemVM/QuestCategorySubGenreVM")
local QuestCategorySearchVM = require("Game/Quest/VM/DataItemVM/QuestCategorySearchVM")
local CommScreenerBarVM = require("Game/Common/View/Screener/CommScreenerBarVM")
local AdventureDefine = require("Game/Adventure/AdventureDefine")

local DataReportUtil = require("Utils/DataReportUtil")

local MapCfg = require("TableCfg/MapCfg")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local QUEST_TYPE = ProtoRes.QUEST_TYPE
local FilterTypeDefine = QuestDefine.FilterType
local ModuleID = ProtoCommon.ModuleID

local LSTR = _G.LSTR
local QuestLogVM = nil
local UIViewMgr = _G.UIViewMgr

---@class NewQuestLogMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnGoRecommendTask UFButton
---@field BtnScreener UFButton
---@field BtnScreenerHighlight UFButton
---@field BtnSearcher UFButton
---@field BtnTaskCompleted UFButton
---@field ImgPen UFImage
---@field PanelRibbon UFCanvasPanel
---@field PanelScreener UFCanvasPanel
---@field PanelTaskCompleted UFCanvasPanel
---@field PaneldRecommendBtn UFCanvasPanel
---@field QuestList UTableView
---@field QuestTypeTabs CommVerIconTabsView
---@field RichTextTips URichTextBox
---@field ScreenerBar CommScreenerBarView
---@field SearchBar CommSearchBarView
---@field SearchResultEmpty CommEmptyView
---@field TaskDetailsPanel NewQuestLogTaskDetailsPanelView
---@field TaskList UFCanvasPanel
---@field TextGoTask UFTextBlock
---@field TextNo UFTextBlock
---@field TextPageName UFTextBlock
---@field TextTaskTitle UFTextBlock
---@field TextTitleName UFTextBlock
---@field ToggleBtnSorting UToggleButton
---@field WidgetSwitcher UFWidgetSwitcher
---@field AnimIn UWidgetAnimation
---@field AnimQuestListSelectionChanged UWidgetAnimation
---@field AnimSwitcherChange UWidgetAnimation
---@field AnimUpdateTitle UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewQuestLogMainPanelView = LuaClass(UIView, true)

function NewQuestLogMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnGoRecommendTask = nil
	--self.BtnScreener = nil
	--self.BtnScreenerHighlight = nil
	--self.BtnSearcher = nil
	--self.BtnTaskCompleted = nil
	--self.ImgPen = nil
	--self.PanelRibbon = nil
	--self.PanelScreener = nil
	--self.PanelTaskCompleted = nil
	--self.PaneldRecommendBtn = nil
	--self.QuestList = nil
	--self.QuestTypeTabs = nil
	--self.RichTextTips = nil
	--self.ScreenerBar = nil
	--self.SearchBar = nil
	--self.SearchResultEmpty = nil
	--self.TaskDetailsPanel = nil
	--self.TaskList = nil
	--self.TextGoTask = nil
	--self.TextNo = nil
	--self.TextPageName = nil
	--self.TextTaskTitle = nil
	--self.TextTitleName = nil
	--self.ToggleBtnSorting = nil
	--self.WidgetSwitcher = nil
	--self.AnimIn = nil
	--self.AnimQuestListSelectionChanged = nil
	--self.AnimSwitcherChange = nil
	--self.AnimUpdateTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewQuestLogMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.QuestTypeTabs)
	self:AddSubView(self.ScreenerBar)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SearchResultEmpty)
	self:AddSubView(self.TaskDetailsPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewQuestLogMainPanelView:OnInit()
	QuestLogVM = QuestMainVM.QuestLogVM

	self.QuestListAdapter = UIAdapterTableView.CreateAdapter(self, self.QuestList)--, self.OnQuestListSelectChanged)
	self.QuestListAdapter:InitCategoryInfo(QuestCategoryVM)

	self.ScreenerBar:SetParams({Data = CommScreenerBarVM.New()})
end

function NewQuestLogMainPanelView:OnDestroy()

end

function NewQuestLogMainPanelView:OnShow()
	--清理容器记录
	QuestLogVM:ClearSelectContainer()

	local bLogInProgress
	local SelectedChapterID
	local SelectedQuestType

	local Params = self.Params or {}
	local ChapterID = Params.QuestID or 0

	if ChapterID > 0 then
		bLogInProgress = (nil == _G.QuestMgr.EndChapterMap[ChapterID])
		SelectedQuestType = Params.QuestType or QuestHelper.GetQuestTypeByChapterID(ChapterID)
		SelectedChapterID = ChapterID

	else -- 从日志按钮打开时不会带参数
		bLogInProgress = QuestLogVM.bLogInProgress
		SelectedQuestType = QuestLogVM:GetSelectedType()
		if bLogInProgress then
			-- 优先选中追踪任务
			local TrackParamList = _G.QuestTrackMgr:GetTrackingQuestParam()
			if TrackParamList then
				local TrackParam = TrackParamList[1]
				if TrackParam then
					local QuestCfgItem = QuestHelper.GetQuestCfgItem(TrackParam.QuestID)
					if QuestCfgItem then
						SelectedChapterID = QuestCfgItem.ChapterID
					end
				end
			end
			if not SelectedChapterID then
				SelectedChapterID = QuestLogVM:GetSelectedQuestOnType(SelectedQuestType)
			end
		end
	end

	self.QuestTypeTabs:UpdateItems(QuestLogVM.QuestTypeVMList)

	if bLogInProgress then
		self:OnBtnBackClicked()
	else
		self:OnBtnTaskCompletedClicked()
	end

	if (SelectedChapterID or 0) > 0 then
		self:SwitchLog(bLogInProgress, SelectedChapterID, SelectedQuestType)
	else
		self:SwitchLog(bLogInProgress)
	end

	UIUtil.SetIsVisible(self.ScreenerBar, false)
	UIUtil.SetIsVisible(self.SearchBar, true)
	self.SearchBar:SetHintText(LSTR(390041))

	--UIUtil.SetIsVisible(self.BtnTaskCompleted, false)
end

function NewQuestLogMainPanelView:OnHide()
	_G.FLOG_INFO("QuestLogMainPanelView:OnHide")
	QuestLogVM:SetFilterList(nil)
	QuestLogVM:ClearSelectContainer()
end

function NewQuestLogMainPanelView:OnRegisterUIEvent()
	self.BtnBack:AddBackClick(self, self.OnBtnBackClicked)
	UIUtil.AddOnClickedEvent(self, self.QuestTypeTabs.BtnSwitch, self.OnBtnTaskCompletedClicked)
	UIUtil.AddOnSelectionChangedEvent(self, self.QuestTypeTabs, self.OnTypeTabSelectChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnScreener, self.OnClickButtonScreener)
	UIUtil.AddOnClickedEvent(self, self.BtnScreenerHighlight, self.OnClickButtonScreener)
	UIUtil.AddOnClickedEvent(self, self.BtnGoRecommendTask, self.OnClickButtonGoRecommendTask)
	self.SearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
end

function NewQuestLogMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ScreenerResult, self.OnScreenerResult)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function NewQuestLogMainPanelView:OnRegisterBinder()
	if not self.LogVMBinders then
		self.LogVMBinders = {
			{ "CurrTypeChapterVMs", UIBinderUpdateBindableList.New(self, self.QuestListAdapter) },
			{ "HighlightSelectType", UIBinderValueChangedCallback.New(self, nil, self.UpdateQuestTypeSelection) },
			{ "CheckEmpty", UIBinderValueChangedCallback.New(self, nil, self.CheckSwitchToEmpty) },
			{ "bLogInProgress", UIBinderValueChangedCallback.New(self, nil, self.UpdateQuestTitle) },
			{ "FilterType", UIBinderValueChangedCallback.New(self, nil, self.OnFilterTypeChanged) },
		}
	end
	self:RegisterBinders(QuestLogVM, self.LogVMBinders)

	if not self.CurrQuestBinders then
		self.CurrQuestBinders = {
			{ "ChapterID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectedQuestChanged) },
		}
	end
	self:RegisterBinders(QuestLogVM.CurrChapterVM, self.CurrQuestBinders)
end


function NewQuestLogMainPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	self.TaskDetailsPanel:OnParentPanelPreMouseButtonDown()
end

function NewQuestLogMainPanelView:OnTypeTabSelectChanged(Index, _, _, IsByClick)
	self.CurrentTabSelectIndex = Index

	local ItemData = QuestLogVM.QuestTypeVMList:Get(Index)
	if ItemData == nil then
		_G.FLOG_ERROR("NewQuestLogMainPanelView:OnTypeTabSelectChanged ItemData=nil")
		return
	end

	local QuestType = ItemData:GetType()
	local Name = QuestDefine.QuestTypeNames[QuestType]
	self.TextPageName:SetText(Name)
	QuestLogVM:ChangeType(QuestType, true)

	self:CheckSwitchToEmpty()

    -- 切换页签时，如果文字搜索中则重置搜索
	if IsByClick then
		if QuestLogVM.FilterList then
			self:ResetFilterAndSearch()
		end
	end
	-- self.QuestListAdapter:UpdateAll(QuestLogVM.CurrTypeChapterVMs)
	-- self.QuestListAdapter:SetSelectedByPredicate(function(v)
	-- 	return v.ChapterID == QuestLogVM.CurrChapterVM.ChapterID
	-- end)

	_G.ObjectMgr:CollectGarbage(false, true, false)
end

function NewQuestLogMainPanelView:OnBtnBackClicked()
	self:ResetFilterAndSearch()
	self:SwitchLog(true)
	UIUtil.SetIsVisible(self.BtnBack, false)
	UIUtil.SetIsVisible(self.BtnClose, true, true)
	--UIUtil.SetIsVisible(self.PanelTaskCompleted, true)
	self:PlayAnimation(self.AnimUpdateTitle)
end

function NewQuestLogMainPanelView:OnBtnTaskCompletedClicked()
	self:ResetFilterAndSearch()
	self:SwitchLog(false)
	UIUtil.SetIsVisible(self.BtnBack, true, true)
	--UIUtil.SetIsVisible(self.PanelTaskCompleted, false)
	UIUtil.SetIsVisible(self.BtnClose, false)
	self:PlayAnimation(self.AnimUpdateTitle)
	_G.QuestMgr.QuestReport:ReportTaskLog(5)
end

function NewQuestLogMainPanelView:OnClickButtonScreener()
	local SystemRelated = self.CurrentTabSelectIndex or 1
	_G.UIViewMgr:ShowView(UIViewID.ScreenerWin, {RelatedSystem = ProtoRes.ScreenerRelatedSystem.QUEST_SYSTEM, SystemRelatedValue = SystemRelated})
end

function NewQuestLogMainPanelView:OnClickButtonGoRecommendTask()
	if self.IsJumpToMap then
		local DisplayMainlineVM = QuestMainVM.DisplayMainlineVM
		if DisplayMainlineVM then
			QuestMainVM.QuestTrackVM:ShowMapQuestByLog(DisplayMainlineVM.ChapterID)
		end
	else
		DataReportUtil.ReportRecommendTaskData("ReTasksInfo", tostring(AdventureDefine.ReportAdventureRecommendTaskType.EnterMethod), UIViewID.QuestLogMainPanel)
		UIViewMgr:ShowView(UIViewID.AdventruePanel, {JumpData = {AdventureDefine.MainTabIndex.RecommendTask}})
	end
end

---@param SearchText string @回调的文本
---@param Type number @输入的类型, 1: OnEnter, 2: OnUserMovedFocus, 3: OnCleared
function NewQuestLogMainPanelView:OnSearchTextCommitted(SearchText, Type)
	if SearchText == "" then
		QuestLogVM:SetFilterList(nil)
	else
		local ScreenerList = {}
		local AllVMs = QuestLogVM:GetAllChapterVMs()
		for i = 1, AllVMs:Length() do
			---@type ChapterVM
			local VM = AllVMs:Get(i)
			if VM.Name then
				local Result = string.find(VM.Name, SearchText, 1, true)
				if Result then
					ScreenerList[VM.ChapterID] = true
				else
					if VM.QuestHistoryDesc then
                        -- 过滤任务描述中的富文本, 以防玩家搜索出富文本的内容
						local ReplacedDesc = string.gsub(VM.QuestHistoryDesc, "<(.-)>", "")
						Result = string.find(ReplacedDesc, SearchText, 1, true)
						if Result then
							ScreenerList[VM.ChapterID] = true
						end
					end
				end
			end
		end
		QuestLogVM:SetFilterList(ScreenerList, FilterTypeDefine.Search)
		QuestLogVM:SetSearchText(SearchText)
		_G.QuestMgr.QuestReport:ReportTaskLog(6, nil, nil, QuestLogVM.bLogInProgress and 1 or 2)
	end

	self:SwitchLog(QuestLogVM.bLogInProgress)
end

function NewQuestLogMainPanelView:OnClickCancelSearchBar()
	self:OnSearchTextCommitted("", 3)
end

function NewQuestLogMainPanelView:OnScreenerResult(Param)
	if not QuestLogVM then
		return
	end

	if not Param or (not Param.Result and not Param.ScreenerList) then
		UIUtil.SetIsVisible(self.ScreenerBar, false)
		UIUtil.SetIsVisible(self.SearchBar, true)

		QuestLogVM:SetFilterList(nil)
	else
		UIUtil.SetIsVisible(self.ScreenerBar, true)
		UIUtil.SetIsVisible(self.SearchBar, false)

		self.SearchBar:SetText("")
		self.ScreenerBar:OnScreenerAction(Param) --特殊处理,避免ScreenerBar注册时机晚了没处理ScreenerResult事件

		local ScreenerList = {}
		if Param.Result then
			for i = 1, #Param.Result do
				---@type c_quest_chapter_cfg
				local ScreenerResult = Param.Result[i]
				ScreenerList[ScreenerResult.id] = true
			end
		end
		QuestLogVM:SetFilterList(ScreenerList, FilterTypeDefine.Filter)
		QuestLogVM:ClearSearchText()
		_G.QuestMgr.QuestReport:ReportTaskLog(7, nil, nil, QuestLogVM.bLogInProgress and 1 or 2)
	end

	self:SwitchLog(QuestLogVM.bLogInProgress)
end

local NORMAL_EMPTY_PATH		= "Texture2D'/Game/UI/Texture/Friend/UI_Friend_Img_EmptyMoggle.UI_Friend_Img_EmptyMoggle'"
local NORMAL_EMPTY_TEXT		= LSTR(390016)
local MAINLINE_EMPTY_PATH	= "Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty.UI_Com_Img_Empty'"
local MAINLINE_EMPTY_TEXT	= LSTR(390017)
local MAINLINE_OVER_PATH	= "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_900011_png.UI_Icon_900011_png'"
local MAINLINE_OVER_TEXT	= LSTR(390018)
local SEARCH_EMPTY_PATH     = "Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty.UI_Com_Img_Empty'"
local SEARCH_EMPTY_TEXT	 	= LSTR(390002)
local SEARCH_TOO_MUCH_TEXT	 	= LSTR(390003)

---判断是否显示空界面
function NewQuestLogMainPanelView:CheckSwitchToEmpty()
	-- 1. 检索结果太多，也当作空状态处理
	if QuestLogVM.FilterList and QuestLogVM.CurrTypeChapterVMs:Length() > 50 then
		self:SetEmptyStateDisplay(SEARCH_EMPTY_PATH, SEARCH_TOO_MUCH_TEXT)
		return
	end

	-- 2. 当前类型有任务
	if QuestLogVM.CurrTypeChapterVMs:Length() > 0 then
		if self.WidgetSwitcher.ActiveWidgetIndex ~= 0 then
			self:PlayAnimation(self.AnimSwitcherChange)
		end
		self.WidgetSwitcher:SetActiveWidgetIndex(0)
		UIUtil.SetIsVisible(self.PanelScreener, true)
		UIUtil.SetIsVisible(self.QuestList, true)
		UIUtil.SetIsVisible(self.TaskDetailsPanel, true)
		UIUtil.SetIsVisible(self.SearchResultEmpty, false)
		return
	end

	-- 3. 没有任务但在过滤或搜索，则为空状态
	if QuestLogVM.FilterList then --有过滤的情况
		self:SetEmptyStateDisplay(SEARCH_EMPTY_PATH, SEARCH_EMPTY_TEXT)
	else
		-- 4. 没有任务，没有过滤或搜索，是否在主线页签
		local DataContainer = QuestLogVM:GetDataContainer()
		--[[
		if DataContainer and (DataContainer.CurrQuestType == QUEST_TYPE.QUEST_TYPE_MAIN) then
			if QuestMainVM.DisplayMainlineVM ~= nil and
			QuestMainVM.DisplayMainlineVM.bMainlineEndedTempVM then
				self.WidgetSwitcher:SetActiveWidgetIndex(1)
				return
			end
		end
		]]

		-- 5. 没有任务，没有过滤或搜索，当前类型没任务
		if self.WidgetSwitcher.ActiveWidgetIndex ~= 2 then
			self:PlayAnimation(self.AnimSwitcherChange)
		end
		self.WidgetSwitcher:SetActiveWidgetIndex(2)

		-- 6. 新规则
		UIUtil.SetIsVisible(self.PanelRibbon, false)
		UIUtil.SetIsVisible(self.PaneldRecommendBtn, true)
		self.IsJumpToMap = false
		UIUtil.TextBlockSetColorAndOpacity( self.TextTaskTitle, 0.011765, 0.007843, 0.007843, 1)
		if DataContainer then
			local CurrQuestType = DataContainer.CurrQuestType
			if CurrQuestType == -1 then
				-- 6.1 全部
				local DisplayMainlineVM = QuestMainVM.DisplayMainlineVM
				if DisplayMainlineVM then
					-- 6.1.1 完成主线显示推荐页
					if DisplayMainlineVM.bMainlineEndedTempVM then
						self.TextNo:SetText(LSTR(390034)) --390034("暂未接取任何类型任务")
						local MoudleOpen = _G.ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDAdviseTask)
						if MoudleOpen then
							self.TextTaskTitle:SetText(LSTR(390038)) --390038("请前往推荐页面看看吧！")
							self.TextGoTask:SetText(LSTR(390040)) --390040("前往推荐任务")
						else
							UIUtil.SetIsVisible(self.PaneldRecommendBtn, false)
							self.TextTaskTitle:SetText(LSTR(390039)) --390039("请自由探索吧！")
						end
					else
						-- 6.1.2 还有主线则显示下一个主线
						local MapName = ""
						if DisplayMainlineVM.MapID then
							MapName = MapCfg:FindValue(DisplayMainlineVM.MapID, "DisplayName")
						end
						self.TextNo:SetText(LSTR(390035)) --390035("下一个主线可接取")
						self.TextTaskTitle:SetText(DisplayMainlineVM:GetTitleName())
						self.TextGoTask:SetText(MapName)
						self.IsJumpToMap = true
					end
				end
			elseif CurrQuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
				-- 6.2 主线
				local DisplayMainlineVM = QuestMainVM.DisplayMainlineVM
				if DisplayMainlineVM then
					if DisplayMainlineVM.bMainlineEndedTempVM then
						UIUtil.SetIsVisible(self.PanelRibbon, true)
						-- 6.2.1 全部完成
						self.TextNo:SetText(LSTR(390036)) --390036("当前主线已全部完成")
						self.TextTaskTitle:SetText(LSTR(390037)) --390037("请期待后续旅程！")
						UIUtil.TextBlockSetColorAndOpacity( self.TextTaskTitle, 0.171441, 0.076185, 0, 1)
						self.TextGoTask:SetText(LSTR(390040)) --390040("前往推荐任务")
					else
						-- 6.2.2 下一个主线
						local MapName = ""
						if DisplayMainlineVM.MapID then
							MapName = MapCfg:FindValue(DisplayMainlineVM.MapID, "DisplayName")
						end
						self.TextNo:SetText(LSTR(390035)) --390035("下一个主线可接取")
						self.TextTaskTitle:SetText(DisplayMainlineVM:GetTitleName())
						self.TextGoTask:SetText(MapName)
						self.IsJumpToMap = true
					end
				end
			else
				-- 6.3 其他
				self.TextNo:SetText(LSTR(390033)) --390033("暂未接取该类型任务")
				local MoudleOpen = _G.ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDAdviseTask)
				if MoudleOpen then
					self.TextTaskTitle:SetText(LSTR(390038)) --390038("请前往推荐页面看看吧！")
					self.TextGoTask:SetText(LSTR(390040)) --390040("前往推荐任务")
				else
					UIUtil.SetIsVisible(self.PaneldRecommendBtn, false)
					self.TextTaskTitle:SetText(LSTR(390039)) --390039("请自由探索吧！")
				end
			end
		end
	end
end

function NewQuestLogMainPanelView:SetEmptyStateDisplay(ImgPath, Text)
	self.SearchResultEmpty:UpdateImg(ImgPath)
	self.SearchResultEmpty:UpdateText(Text)

	UIUtil.SetIsVisible(self.QuestList, false)
	UIUtil.SetIsVisible(self.TaskDetailsPanel, false)
	UIUtil.SetIsVisible(self.SearchResultEmpty, true)
	if self.WidgetSwitcher.ActiveWidgetIndex ~= 0 then
		self:PlayAnimation(self.AnimSwitcherChange)
	end
	self.WidgetSwitcher:SetActiveWidgetIndex(0)
end

function NewQuestLogMainPanelView:UpdateQuestTitle(NewValue, OldValue)
	local TitleText = ""
	if QuestLogVM.bLogInProgress then
		TitleText = LSTR(390004)
	else
		TitleText = LSTR(390005)
	end

	self.TextTitleName:SetText(TitleText)
end

function NewQuestLogMainPanelView:OnFilterTypeChanged(NewValue, OldValue)
	local IsInFilter = NewValue == FilterTypeDefine.Filter
	UIUtil.SetIsVisible(self.BtnScreener, not IsInFilter, true)
	UIUtil.SetIsVisible(self.BtnScreenerHighlight, IsInFilter, true)
end

function NewQuestLogMainPanelView:SwitchLog(bLogInProgress, ChapterID, QuestType)
	self.TaskDetailsPanel:OnSwitchLog(bLogInProgress)

	self:UpdateCategoryInfo(bLogInProgress)
	QuestLogVM:SwitchLogData(bLogInProgress, ChapterID, QuestType)

	local SelectedType = QuestLogVM:GetSelectedType(bLogInProgress)
	self:UpdateQuestTypeSelection(SelectedType)

	self:CheckSwitchToEmpty()

	if ChapterID then
		self:SelectTargetQuest(ChapterID)
	else
		self:SelectFirstQuest()
	end

	self.QuestTypeTabs:SetIsSwitchPanelVisible(bLogInProgress)
end

function NewQuestLogMainPanelView:UpdateCategoryInfo(bLogInProgress)
	local CategoryVM = nil
	if QuestLogVM.FilterType == FilterTypeDefine.Search then
		CategoryVM = QuestCategorySearchVM
	elseif bLogInProgress then
		CategoryVM = QuestCategoryVM
	else
		CategoryVM = QuestCategorySubGenreVM
	end
	self.QuestListAdapter:InitCategoryInfo(CategoryVM)
end

function NewQuestLogMainPanelView:SelectFirstQuest()
	self.QuestListAdapter:UpdateAll(QuestLogVM.CurrTypeChapterVMs)
	if QuestLogVM.CurrTypeChapterVMs and QuestLogVM.CurrTypeChapterVMs:Length() > 0 then
		self.QuestListAdapter:SetSelectedIndex(1)
		self.QuestListAdapter:ScrollToIndex(1)
	else
		self.QuestListAdapter:CancelSelected()
	end
end

function NewQuestLogMainPanelView:SelectTargetQuest(ChapterID)
	self.QuestListAdapter:UpdateAll(QuestLogVM.CurrTypeChapterVMs)
	if QuestLogVM.CurrTypeChapterVMs and QuestLogVM.CurrTypeChapterVMs:Length() > 0 then
		local Items = QuestLogVM.CurrTypeChapterVMs:GetItems()
		for i=1, #Items do
			local Item = Items[i]
			if Item.ChapterID == ChapterID then
				self.QuestListAdapter:SetSelectedIndex(i)
				self.QuestListAdapter:ScrollToIndex(i)
				break
			end
		end
	else
		self.QuestListAdapter:CancelSelected()
	end
end

function NewQuestLogMainPanelView:UpdateQuestTypeSelection(QuestType)
	local _, Index = QuestLogVM.QuestTypeVMList:Find(function(v)
		return v:GetType() == QuestType
	end)
	local Name = QuestDefine.QuestTypeNames[QuestType]
	self.TextPageName:SetText(Name)

	self.QuestTypeTabs:SetSelectedIndex(Index or 1)

	-- 初始化之前会从OnLogGroupStateChanged调用一次，需要判空保护
	-- if self.QuestListAdapter.BindableList then
	-- 	self.QuestListAdapter:SetSelectedByPredicate(function(v)
	-- 		return v.ChapterID == QuestLogVM.CurrChapterVM.ChapterID
	-- 	end)
	-- end
end

function NewQuestLogMainPanelView:OnSelectedQuestChanged(_)
	self.QuestListAdapter:UpdateAll(QuestLogVM.CurrTypeChapterVMs)
	self.QuestListAdapter:SetSelectedByPredicate(function(v)
		return v.ChapterID == QuestLogVM.CurrChapterVM.ChapterID
	end)
end

function NewQuestLogMainPanelView:ResetFilterAndSearch()
	self:OnScreenerResult(nil)
	self.SearchBar:OnClickButtonCancel()
end

return NewQuestLogMainPanelView