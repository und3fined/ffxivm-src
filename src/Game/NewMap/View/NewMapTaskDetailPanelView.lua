---
--- Author: Administrator
--- DateTime: 2024-02-26 10:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local ColorUtil = require("Utils/ColorUtil")
local MapUtil = require("Game/Map/MapUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local LSTR = _G.LSTR
local QuestMgr = _G.QuestMgr
local UIViewMgr = _G.UIViewMgr
local RDType = QuestDefine.RestrictedDialogType

local EntryMode = {
	FromMarker = 1,
	FromList = 2
}

---@class NewMapTaskDetailPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BtnStopTrack CommBtnMView
---@field BtnTrack CommBtnMView
---@field CloseBtn CommonCloseBtnView
---@field ImgLine UFImage
---@field ImgTaskWay UFImage
---@field PanelBlockMapGesture CommonPopUpBGView
---@field PanelRightList UFCanvasPanel
---@field PanelRuleTips UFCanvasPanel
---@field PopUpHideRuleTips CommonPopUpBGView
---@field RichTextDesc URichTextBox
---@field RichTextTips URichTextBox
---@field TableViewProps UTableView
---@field TableViewTaskTarget UTableView
---@field TaskRule NewQuestLogTaskRuleItemView
---@field TextRuleTitle UFTextBlock
---@field TextTaskLv UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleButtonTrack UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewMapTaskDetailPanelView = LuaClass(UIView, true)

function NewMapTaskDetailPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BtnStopTrack = nil
	--self.BtnTrack = nil
	--self.CloseBtn = nil
	--self.ImgLine = nil
	--self.ImgTaskWay = nil
	--self.PanelBlockMapGesture = nil
	--self.PanelRightList = nil
	--self.PanelRuleTips = nil
	--self.PopUpHideRuleTips = nil
	--self.RichTextDesc = nil
	--self.RichTextTips = nil
	--self.TableViewProps = nil
	--self.TableViewTaskTarget = nil
	--self.TaskRule = nil
	--self.TextRuleTitle = nil
	--self.TextTaskLv = nil
	--self.TextTitle = nil
	--self.ToggleButtonTrack = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewMapTaskDetailPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BtnStopTrack)
	self:AddSubView(self.BtnTrack)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.PanelBlockMapGesture)
	self:AddSubView(self.PopUpHideRuleTips)
	self:AddSubView(self.TaskRule)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewMapTaskDetailPanelView:OnInit()
	self.QuestTrackVM = QuestMainVM.QuestTrackVM

	self.TargetList = UIAdapterTableView.CreateAdapter(self, self.TableViewTaskTarget)
	self.RewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewProps)
	self.BackBtn:AddBackClick(self, self.HideAllView)
	self.CloseBtn:SetCallback(self, self.HideAllView)
	self.PopUpHideRuleTips:SetCallback(self, self.OnClickPopUpHideRuleTips)

	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgTaskWay) },
		{ "Name", UIBinderSetText.New(self, self.TextTitle) },
		{ "MinLevel", UIBinderSetTextFormat.New(self, self.TextTaskLv, LSTR(400001)) },
		{ "LogImage", UIBinderSetIsVisible.New(self, self.ImgLine, true) },
		{ "SpecialRule", UIBinderValueChangedCallback.New(self, nil, self.OnSpecialRuleChanged) },
		{ "QuestHistoryDesc", UIBinderValueChangedCallback.New(self, nil, self.OnQuestHistoryDescChanged) },
		{ "RewardItemVMList", UIBinderUpdateBindableList.New(self, self.RewardList) },
		{ "TargetVMList", UIBinderValueChangedCallback.New(self, nil, self.OnTargetVMListChanged) },
		{ "bTracking", UIBinderSetIsChecked.New(self, self.ToggleButtonTrack, true) },
	}
end

function NewMapTaskDetailPanelView:OnDestroy()

end

function NewMapTaskDetailPanelView:OnShow()
	self:SetFixText()

	local Params = self.Params or {}
	local Mode = Params.EntryMode
	self:UpdateBackCloseBtn(Mode)

	local TargetID = Params.TargetID
	if TargetID then
		self:FocusTarget(TargetID)
	else
		self:ClearFocusTarget()
	end

	if not self.Params.WaitChangeMap then
		if self:CheckCanFocusMarker(Params.QuestID, Params.TargetID) then
			UIViewMgr:ShowView(UIViewID.NewMapTaskTrackingTips, { QuestID = Params.QuestID, TargetID = Params.TargetID })
		end
	end

	UIUtil.SetIsVisible(self.PopUpHideRuleTips, true, true)
end

function NewMapTaskDetailPanelView:OnHide()

end

function NewMapTaskDetailPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.TaskRule.BtnTips, self.OnClickButtonSpecialRule)
	UIUtil.AddOnClickedEvent(self, self.BtnTrack.Button, self.OnClickButtonTrack)
	UIUtil.AddOnClickedEvent(self, self.BtnStopTrack.Button, self.OnClickButtonStopTrack)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonTrack, self.OnStateChangedToggleButtonTrack)
end

function NewMapTaskDetailPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WorldMapFinishChanged, self.OnWorldMapFinishChanged)
end

function NewMapTaskDetailPanelView:OnRegisterBinder()
	local ChapterVM = self.Params.ChapterVM
	if ChapterVM ~= nil then
		self.ViewModel = ChapterVM
		self:RegisterBinders(self.ViewModel, self.Binders)
	end
end

function NewMapTaskDetailPanelView:OnSpecialRuleChanged(NewValue)
	local bShowSpecialRuleProfFixed = false
	if NewValue ~= nil and NewValue.bProfFixed then
		bShowSpecialRuleProfFixed = true
	end
	-- 临时处理
	UIUtil.SetIsVisible(self.TaskRule, bShowSpecialRuleProfFixed)
	self.TaskRule:SetProfFixed()
end

function NewMapTaskDetailPanelView:OnQuestHistoryDescChanged(Str)
	self.RichTextDesc:SetText(ColorUtil.ParseItemNameDarkStyle(Str))
end

function NewMapTaskDetailPanelView:OnTargetVMListChanged(NewValue)
	if NewValue == nil then return end

	local function SortFunction(Target1, Target2)
		if Target1.Status == Target2.Status then
			return Target1.TargetID < Target2.TargetID
		end
		return Target1.Status < Target2.Status
	end

	-- 已完成目标排在后面
	NewValue:Sort(SortFunction)
	self.TargetList:UpdateAll(NewValue)
end

function NewMapTaskDetailPanelView:OnClickButtonSpecialRule()
	UIUtil.SetIsVisible(self.PanelRuleTips, true)
end

function NewMapTaskDetailPanelView:OnClickPopUpHideRuleTips()
	if UIUtil.IsVisible(self.PanelRuleTips) then
		UIUtil.SetIsVisible(self.PanelRuleTips, false)
		return
	end
	self:HideAllView()
	self:Hide()
end

function NewMapTaskDetailPanelView:OnClickButtonTrack()
	local CurrChapterID = self.ViewModel.ChapterID
	local OriTrackChapterID = self.QuestTrackVM.CurrTrackChapterID
	self.QuestTrackVM:TrackQuest(CurrChapterID)

	if UIViewMgr:FindVisibleView(UIViewID.WorldMapTaskListPanel) then
		-- 如果原本有追踪的任务需要先取消追踪
		if OriTrackChapterID then
			WorldMapVM.TaskListVM:UpdateQuestByChapterID(OriTrackChapterID)
		end
		WorldMapVM.TaskListVM:UpdateQuestByChapterID(CurrChapterID)
	end
end

function NewMapTaskDetailPanelView:OnClickButtonStopTrack()
	self.QuestTrackVM:TrackQuest(nil)
	
	if UIViewMgr:FindVisibleView(UIViewID.WorldMapTaskListPanel) then
		WorldMapVM.TaskListVM:UpdateQuestByChapterID(self.ViewModel.ChapterID)
	end
end

function NewMapTaskDetailPanelView:OnStateChangedToggleButtonTrack(ToggleButton, ButtonState)
	local IsToggle = UIUtil.IsToggleButtonChecked(ButtonState)
	local TipsView = UIViewMgr:FindVisibleView(UIViewID.NewMapTaskTrackingTips)
	if TipsView then
		TipsView:RefreshTraceStateShow(IsToggle)
	end
end

function NewMapTaskDetailPanelView:FocusTarget(TargetID)
	self:ClearFocusTarget()

	local TargetVM = self.ViewModel:GetTargetVM(TargetID)
	if TargetVM then
		TargetVM.IsFocusTarget = true
	end
end

function NewMapTaskDetailPanelView:ClearFocusTarget()
	local VMList = self.ViewModel.TargetVMList:GetItems()
	if VMList then
		for _, VM in pairs(VMList) do
			VM.IsFocusTarget = false
		end
	end
end

-- 地图中的Focus任务图标也要一起关闭
function NewMapTaskDetailPanelView:HideAllView()
	WorldMapVM:ShowWorldMapTaskDetailPanel(false)
end

-- 切换地图后，等地图缩放完成再显示锁定图标，不然图标位置不正确
function NewMapTaskDetailPanelView:OnWorldMapFinishChanged()
	-- 如果选择的任务目标在同一地图，会马上收到事件，不会透过WorldMapVM的ChangeToAreaMap调用更新，所以此处判断是否需要更新
	if WorldMapVM.QuestParamAfterChangeMap then
		WorldMapVM:ShowWorldMapTaskDetailPanel(true, WorldMapVM.QuestParamAfterChangeMap)
	end

	-- 锁定图标
	if self.Params.WaitChangeMap then
		self.Params.WaitChangeMap = false
		if self:CheckCanFocusMarker(self.Params.QuestID, self.Params.TargetID) then
			UIViewMgr:ShowView(UIViewID.NewMapTaskTrackingTips, { QuestID = self.Params.QuestID, TargetID = self.Params.TargetID })
		end
	end
end

function NewMapTaskDetailPanelView:UpdateBackCloseBtn(Mode)
	if Mode == EntryMode.FromList then
		UIUtil.SetIsVisible(self.BackBtn, true, true )
		UIUtil.SetIsVisible(self.CloseBtn, false)
	else
		UIUtil.SetIsVisible(self.CloseBtn, true, true )
		UIUtil.SetIsVisible(self.BackBtn, false)
	end
end

function NewMapTaskDetailPanelView:CheckCanFocusMarker(QuestID, TargetID)
	local IsAreaMap = MapUtil.IsAreaMap(_G.WorldMapMgr:GetUIMapID())
	if not IsAreaMap then
		return false
	end
	if WorldMapVM.ChageMaping then --正在切图
		return false
	end
	local WorldMapPanel = UIViewMgr:FindView(UIViewID.WorldMapPanel)
	local MarkerView = WorldMapPanel.MapContent:GetMapMarkerQuest(QuestID, TargetID)
	return MarkerView and UIUtil.IsVisible(MarkerView)
end

function NewMapTaskDetailPanelView:SetFixText()
	self.BtnTrack:SetText(LSTR(390023))
	self.BtnStopTrack:SetText(LSTR(390024))
	self.TextRuleTitle:SetText(LSTR(390015))
	self.RichTextTips:SetText(LSTR(390025))
end

return NewMapTaskDetailPanelView