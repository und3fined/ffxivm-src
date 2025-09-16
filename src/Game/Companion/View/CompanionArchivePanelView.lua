---
--- Author: Administrator
--- DateTime: 2023-11-09 16:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BoardType = require("Define/BoardType")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local CompanionCfg = require ("TableCfg/CompanionCfg")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local LightDefine = require("Game/Light/LightDefine")
local TipsUtil = require("Utils/TipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local CompanionGlobalCfg = require("TableCfg/CompanionGlobalCfg")
local CompanionActionUnlockCfg = require("TableCfg/CompanionActionUnlockCfg")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local DataReportUtil = require("Utils/DataReportUtil")

local CompanionArchiveVM = require ("Game/Companion/VM/CompanionArchiveVM")
local CompanionVM = require ("Game/Companion/VM/CompanionVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

-- local CompanionActorPath = "Class'/Game/BluePrint/Character/CompanionBlueprint.CompanionBlueprint_C'"
local SceneActorPath = "Class'/Game/UI/Render2D/Companion/BP_Render2DCompanionArchive.BP_Render2DCompanionArchive_C'"
local LightPreset = "LightPreset'/Game/UI/Render2D/LightPresets/Login/UniversalLightingPreset/UniversalLightingPreset01.UniversalLightingPreset01'"
local CompanionLightLevelID = LightDefine.LightLevelID.LIGHT_LEVEL_ID_COMPANION_ARCHIVE
local SCS_FinalColorLDRHasAlpha = _G.UE.ESceneCaptureSource.SCS_FinalColorLDRHasAlpha or 3

local UIViewMgr = _G.UIViewMgr
local LSTR = _G.LSTR
local EventMgr = _G.EventMgr
local CompanionMgr = _G.CompanionMgr
local AnimMgr = _G.AnimMgr
local FLOG_INFO = _G.FLOG_INFO
local UE = _G.UE
local BuoyMgr = _G.BuoyMgr

local ActorZLocation = 100000
local IdleTimelineLabel = "IDLE"
local Interact1TimelineLabel = "IDLE_INACTIVE1"
local Interact2TimelineLabel = "IDLE_INACTIVE2"
local Interact3TimelineLabel = "IDLE_INACTIVE3"
local AttackTimelineLabel = "MINION_BATTLE_LOOP"
local MoveTimelineLable = "RUN"

local EmptyType = {
	Search = 1,
	Filter = 2,
	Toggle = 3,
}

local EmptyText = {
	[EmptyType.Search] = LSTR(120008),
	[EmptyType.Filter] = LSTR(120009),
	[EmptyType.Toggle] = LSTR(120010),
}

---@class CompanionArchivePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAttack UFButton
---@field BtnAttackCancel UFButton
---@field BtnBack CommBackBtnView
---@field BtnDescription UFButton
---@field BtnGetWay UFButton
---@field BtnMessageBoard UFButton
---@field BtnMove UFButton
---@field BtnMoveCancel UFButton
---@field BtnSearch CommSearchBtnView
---@field BtnShow UFButton
---@field BtnShowCancel UFButton
---@field BtnSwitch UFButton
---@field CommonTitle CommonTitleView
---@field CompanionRenderer CompanionRender2DView
---@field DropDownListGetWay CommDropDownListView
---@field FCanvasPanel UFCanvasPanel
---@field HorizontalAction UHorizontalBox
---@field ImgFootprint UFImage
---@field InputBoxMeshZ CommInputBoxView
---@field PanelBasicInfo UFCanvasPanel
---@field PanelDebug UFCanvasPanel
---@field PanelDescription UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelFunction UFCanvasPanel
---@field PanelFunctionBtn UFVerticalBox
---@field PanelGetWay UFCanvasPanel
---@field PanelInforBar UFCanvasPanel
---@field PanelInteract UFCanvasPanel
---@field PanelNotEmpty UFCanvasPanel
---@field PanelNotProtect UFCanvasPanel
---@field PanelOwnInfo UFCanvasPanel
---@field PanelProtect UFCanvasPanel
---@field PopUpBGHideDescription CommonPopUpBGView
---@field RichTextNone URichTextBox
---@field SearchBar CommSearchBarView
---@field SingleBoxNotOwn CommSingleBoxView
---@field TableViewCompanion UTableView
---@field TextCompanionName UFTextBlock
---@field TextCry UFTextBlock
---@field TextDescriptionTitle UFTextBlock
---@field TextEmpty UFTextBlock
---@field TextExpository UFTextBlock
---@field TextGetWay UFTextBlock
---@field TextMoveType UFTextBlock
---@field TextMoveTypeTitle UFTextBlock
---@field ToggleButtonAttack UToggleButton
---@field ToggleButtonMove UToggleButton
---@field ToggleButtonShow UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimTableViewCompanionSelectionChanged UWidgetAnimation
---@field AnimUpdateTableViewArmors UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanionArchivePanelView = LuaClass(UIView, true)

function CompanionArchivePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAttack = nil
	--self.BtnAttackCancel = nil
	--self.BtnBack = nil
	--self.BtnDescription = nil
	--self.BtnGetWay = nil
	--self.BtnMessageBoard = nil
	--self.BtnMove = nil
	--self.BtnMoveCancel = nil
	--self.BtnSearch = nil
	--self.BtnShow = nil
	--self.BtnShowCancel = nil
	--self.BtnSwitch = nil
	--self.CommonTitle = nil
	--self.CompanionRenderer = nil
	--self.DropDownListGetWay = nil
	--self.FCanvasPanel = nil
	--self.HorizontalAction = nil
	--self.ImgFootprint = nil
	--self.InputBoxMeshZ = nil
	--self.PanelBasicInfo = nil
	--self.PanelDebug = nil
	--self.PanelDescription = nil
	--self.PanelEmpty = nil
	--self.PanelFunction = nil
	--self.PanelFunctionBtn = nil
	--self.PanelGetWay = nil
	--self.PanelInforBar = nil
	--self.PanelInteract = nil
	--self.PanelNotEmpty = nil
	--self.PanelNotProtect = nil
	--self.PanelOwnInfo = nil
	--self.PanelProtect = nil
	--self.PopUpBGHideDescription = nil
	--self.RichTextNone = nil
	--self.SearchBar = nil
	--self.SingleBoxNotOwn = nil
	--self.TableViewCompanion = nil
	--self.TextCompanionName = nil
	--self.TextCry = nil
	--self.TextDescriptionTitle = nil
	--self.TextEmpty = nil
	--self.TextExpository = nil
	--self.TextGetWay = nil
	--self.TextMoveType = nil
	--self.TextMoveTypeTitle = nil
	--self.ToggleButtonAttack = nil
	--self.ToggleButtonMove = nil
	--self.ToggleButtonShow = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimTableViewCompanionSelectionChanged = nil
	--self.AnimUpdateTableViewArmors = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanionArchivePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnSearch)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.CompanionRenderer)
	self:AddSubView(self.DropDownListGetWay)
	self:AddSubView(self.InputBoxMeshZ)
	self:AddSubView(self.PopUpBGHideDescription)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SingleBoxNotOwn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanionArchivePanelView:OnInit()
	self.ViewModel = CompanionArchiveVM.New()
	self.CompanionAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewCompanion, self.OnCompanionTableViewSelectChange)
	self.SearchBar:SetCallback(self, nil, self.OnSearchCommit, self.OnCancelSearchClicked)
    self.InputBoxMeshZ:SetCallback(self, nil, self.OnMeshZCommitted)
	self.BtnBack:AddBackClick(self, self.Hide)
	
	self.Binders = {
		{ "AllCompanionCount", UIBinderValueChangedCallback.New(self, nil, self.OnAllCompanionCountChange) },
		{ "IsEmpty", UIBinderValueChangedCallback.New(self, nil, self.OnIsEmptyChange) },
		{ "CompanionVMList", UIBinderValueChangedCallback.New(self, nil, self.OnCompanionVMListChanged) },
		{ "GetWayFilterTypes", UIBinderValueChangedCallback.New(self, nil, self.OnGetWayFilterTypesChanged) },
		{ "GetWayFilterValue", UIBinderValueChangedCallback.New(self, nil, self.OnGetWayFilterValueChanged) },
		{ "CurrentShowList", UIBinderValueChangedCallback.New(self, nil, self.OnCurrentShowListChanged) },
		{ "CompanionName", UIBinderSetText.New(self, self.TextCompanionName) },
		{ "CompanionMoveType", UIBinderValueChangedCallback.New(self, nil, self.OnCompanionMoveTypeChanged) },
		{ "CompanionFootprint", UIBinderSetBrushFromAssetPath.New(self, self.ImgFootprint, false, false, true) },
		{ "IsOwnCompanion", UIBinderValueChangedCallback.New(self, nil, self.OnIsOwnCompanionChanged) },
		{ "IsNotProtect", UIBinderValueChangedCallback.New(self, nil, self.OnIsNotProtectChanged) },
		{ "CompanionName", UIBinderValueChangedCallback.New(self, nil, self.OnDescriptionTitleChanged) },
		{ "CompanionExpository", UIBinderSetText.New(self, self.TextExpository) },
		{ "CompanionCry", UIBinderSetText.New(self, self.TextCry) },
		{ "IsSearching", UIBinderValueChangedCallback.New(self, nil, self.OnIsSearchingChange) },
		{ "IsShowDescription", UIBinderSetIsVisible.New(self, self.PanelDescription) },
		{ "IsShowDescription", UIBinderSetIsVisible.New(self, self.PopUpBGHideDescription) },
		{ "IsShowNotOwn", UIBinderSetIsChecked.New(self, self.SingleBoxNotOwn) },
		{ "IsMergeCompanion", UIBinderSetIsVisible.New(self, self.BtnSwitch, false, true) },
		{ "LastEmptyType", UIBinderValueChangedCallback.New(self, nil, self.OnLastEmptyTypeChanged) },
		{ "CanBattle", UIBinderSetIsVisible.New(self, self.BtnAttack, false, true) },
		{ "HasShow", UIBinderSetIsVisible.New(self, self.ToggleButtonShow) },
		{ "IsShowing", UIBinderSetIsChecked.New(self, self.ToggleButtonShow) },
		{ "IsAttacking", UIBinderSetIsChecked.New(self, self.ToggleButtonAttack) },
		{ "IsMoving", UIBinderSetIsChecked.New(self, self.ToggleButtonMove) },
	}
end

function CompanionArchivePanelView:OnDestroy()

end

function CompanionArchivePanelView:OnShow()
	BuoyMgr:ShowAllBuoys(false)

	-- 策划要求屏蔽留言板
	UIUtil.SetIsVisible(self.BtnMessageBoard, false)
	
	-- 如果打开了宠物列表则关上
	if UIViewMgr:IsViewVisible(UIViewID.CompanionListPanel) then
		UIViewMgr:HideView(UIViewID.CompanionListPanel)
	end
	
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_COMPANION_PREVIEW, true) then 
		UIUtil.SetIsVisible(self.FCanvasPanel, false)
		return
	end
	
	-- Debug面板显隐
	UIUtil.SetIsVisible(self.PanelDebug, CommonUtil.IsWithEditor())

	self:HandlePageSourceTLOG()
	self:SetFixText()
	self.ViewModel:GetAllData()
	self.ViewModel:InitGetWayFilterData()
	self:UpdateSelectedCompanion()
end

function CompanionArchivePanelView:OnHide()
	BuoyMgr:ShowAllBuoys(true)
	self:RestoreRefelctionCubemap()
	self.ViewModel:ClearData()
	self.SelectedCompanionID = nil
	self.CompanionAdapterTableView:ClearSelectedItem()
	self.CompanionActor = nil
	self.CompanionEntityID = nil
	self.WaitSwitchModelID = nil
end

function CompanionArchivePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSearch.BtnSearch, self.OnBtnSearchClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnDescription, self.OnBtnDescriptionClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMessageBoard, self.OnBtnMessageBoardClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnBtnSwitchClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnGetWay, self.OnBtnGetWayClicked)

	UIUtil.AddOnClickedEvent(self, self.BtnShow, self.OnBtnShowClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnShowCancel, self.OnBtnShowCancelClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnAttack, self.OnBtnAttackClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnAttackCancel, self.OnBtnAttackCancelClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMove, self.OnBtnMoveClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMoveCancel, self.OnBtnMoveCancelClicked)

	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxNotOwn, self.OnSingleBoxNotOwnStateChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownListGetWay, self.OnSelectionChangedGetWayFilter)

	self.PopUpBGHideDescription:SetCallback(self, self.OnPopUpBGHideDescriptionClicked)
	self.CompanionRenderer:SetSingleClickCallback(self, self.OnClickRenderer)
end

function CompanionArchivePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CompanionArchiveModelStartRotate, self.OnCompanionArchiveModelStartRotate)
	self:RegisterGameEvent(EventID.CompanionArchiveModelEndRotate, self.OnCompanionArchiveModelEndRotate)
    -- self:RegisterGameEvent(EventID.LevelPostLoad, self.OnGameEventLevelPostLoad)
	self:RegisterGameEvent(EventID.CompanionArchiveNewListUpdate, self.OnCompanionArchiveNewListUpdate)
end

function CompanionArchivePanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CompanionArchivePanelView:OnCompanionTableViewSelectChange(Index, ItemData, ItemView)
	local CompanionID = self:GetSelectedCompanionID()
	local IsMerge = self:IsSelectedMergeCompanion()

	-- 因为列表变化时有尝试保留原本选中宠物的逻辑，所以为了防止切换筛选时，选择的宠物没变但模型却刷新一遍而做判断
	local HasChangeSelection = (self.SelectedCompanionID ~= CompanionID)
	if IsMerge then
		HasChangeSelection = not table.contain(ItemData.Cfg.CompanionID, self.SelectedCompanionID)
	end

	if HasChangeSelection then
		self:ResetAnimationState()
		self.SelectedCompanionID = CompanionID
		if IsMerge then
			self.MergeCompanionIndex = math.random(#ItemData.Cfg.CompanionID)
			self.SelectedCompanionID = ItemData.Cfg.CompanionID[self.MergeCompanionIndex]
		end

		self:ShowModel(self.SelectedCompanionID)
		self:UpdateInteractList(self.SelectedCompanionID)
		self:ReportTLOG(3, CompanionID)
	end

	self.ViewModel:ShowCompanionInfo(ItemData)

	local IsOwnCompanion = CompanionVM:IsOwnCompanion(CompanionID)
	local IsShowMessageBoard = UIViewMgr:IsViewVisible(UIViewID.MessageBoardPanel)
	if IsShowMessageBoard then
		if IsOwnCompanion or not ItemData.IsStoryProtect then
			EventMgr:SendEvent(EventID.BoardObjectChange, self:GetSelectedCompanionID())
		else
			UIViewMgr:HideView(UIViewID.MessageBoardPanel)
		end
	end

	if IsOwnCompanion then
		CompanionMgr:SendReadArchiveNewCompanionMsg(CompanionID)
	end
end

function CompanionArchivePanelView:OnCompanionVMListChanged(NewValue, OldValue)
	if NewValue == nil then return end

	self.CompanionAdapterTableView:UpdateAll(NewValue)
	self:PlayAnimation(self.AnimUpdateTableViewArmors)
end

function CompanionArchivePanelView:OnGetWayFilterTypesChanged(NewValue, OldValue)
	if NewValue == nil then return end

	self.DropDownListGetWay:UpdateItems(self.ViewModel.GetWayFilterTypes)
end

function CompanionArchivePanelView:OnGetWayFilterValueChanged(NewValue, OldValue)
	if self.ViewModel.CurrentShowList == nil or NewValue == 0 then return end

	self.ViewModel:ShowCompanion(nil)
	self:TryKeepSelectedCompanion(self.SelectedCompanionID)
end

function CompanionArchivePanelView:OnCurrentShowListChanged(NewValue, OldValue)
	if NewValue == nil then return end

	self.ViewModel:ShowCompanion(nil)
	self:TryKeepSelectedCompanion(self.SelectedCompanionID)
end

function CompanionArchivePanelView:OnCompanionMoveTypeChanged(NewValue, OldValue)
	if NewValue == nil then return end

    local MoveTypeText = ProtoEnumAlias.GetAlias(ProtoRes.CompanionMoveType, NewValue)
	self.TextMoveType:SetText(MoveTypeText)

	local CanCompanionMove = NewValue ~= ProtoRes.CompanionMoveType.Immobile
	UIUtil.SetIsVisible(self.BtnMove, CanCompanionMove, true)
end

function CompanionArchivePanelView:UpdateSelectedCompanion()
	if CompanionVM:HasOwnCompanion() and self.ViewModel.CompanionVMList ~= nil then
		for Index, CompanionItemVM in ipairs(self.ViewModel.CompanionVMList) do
			local CompanionID = CompanionItemVM.IsMerge and CompanionItemVM.Cfg.CompanionID[1] or CompanionItemVM.CompanionID
			if CompanionVM:IsOwnCompanion(CompanionID) then
				self.CompanionAdapterTableView:SetSelectedIndex(Index)
				return
			end
		end
	elseif self.ViewModel.CompanionVMList ~= nil and #self.ViewModel.CompanionVMList > 0 then
		self.CompanionAdapterTableView:SetSelectedIndex(1)
	else
		self.CompanionAdapterTableView:ClearSelectedItem()
	end
end

function CompanionArchivePanelView:OnIsOwnCompanionChanged(NewValue, OldValue)
	UIUtil.SetIsVisible(self.PanelOwnInfo, self.ViewModel.IsOwnCompanion)
	UIUtil.SetIsVisible(self.BtnDescription, self.ViewModel.IsOwnCompanion, true)
	-- UIUtil.SetIsVisible(self.BtnMessageBoard, self.ViewModel.IsOwnCompanion, true) -- 留言板技钮目前屏蔽
end

function CompanionArchivePanelView:OnIsNotProtectChanged(NewValue, OldValue)
	UIUtil.SetIsVisible(self.PanelNotProtect, self.ViewModel.IsNotProtect)
	UIUtil.SetIsVisible(self.PanelProtect, not self.ViewModel.IsNotProtect)
	UIUtil.SetIsVisible(self.HorizontalAction, self.ViewModel.IsNotProtect)
end

function CompanionArchivePanelView:OnIsShowDescriptionChanged(NewValue, OldValue)
	local IsVisible = self.ViewModel.IsShowDescription
	UIUtil.SetIsVisible(self.PanelDescription, IsVisible)
	UIUtil.SetIsVisible(self.PopUpBGHideDescription, IsVisible, true)
end

function CompanionArchivePanelView:OnDescriptionTitleChanged(NewValue, OldValue)
	local Title = string.format(LSTR(120011), self.ViewModel.CompanionName)
	self.TextDescriptionTitle:SetText(Title)
end

function CompanionArchivePanelView:OnUnlockItemIDChange(NewValue, OldValue)
	local GetWayList = ItemUtil.GetItemGetWayList(NewValue)
	self.GetWayAdapterTableView:UpdateAll(GetWayList)
end

function CompanionArchivePanelView:OnIsSearchingChange(NewValue, OldValue)
	UIUtil.SetIsVisible(self.PanelFunction, not NewValue)
	UIUtil.SetIsVisible(self.SearchBar, NewValue)
end

function CompanionArchivePanelView:OnIsEmptyChange(NewValue, OldValue)
	UIUtil.SetIsVisible(self.PanelEmpty, NewValue)
	UIUtil.SetIsVisible(self.PanelNotEmpty, not NewValue)
	self.CompanionRenderer:SetActorVisible(not NewValue)
end

function CompanionArchivePanelView:OnLastEmptyTypeChanged(NewValue, OldValue)
	if NewValue == nil then return end

	local EmptyText = EmptyText[NewValue]
	self.TextEmpty:SetText(EmptyText)
end

function CompanionArchivePanelView:OnAllCompanionCountChange(NewValue, OldValue)
	local OwnCount = CompanionVM:GetOwnCompanionCount()
	local MaxCount = NewValue
	local SubTitleText = string.format(LSTR(120035), OwnCount, MaxCount)
	self.CommonTitle:SetTextSubtitle(SubTitleText)
end

function CompanionArchivePanelView:OnSearchCommit(Text)
	self.ViewModel.LastEmptyType = EmptyType.Search
	self.ViewModel:ShowCompanion(Text)
	self:TryKeepSelectedCompanion()
end

function CompanionArchivePanelView:OnCancelSearchClicked()
	self.ViewModel.IsSearching = false
	self.ViewModel:ShowAllCompanion()
	self:TryKeepSelectedCompanion(self.SelectedCompanionID)
end

function CompanionArchivePanelView:OnBtnSearchClicked()
	self.ViewModel.IsSearching = true
	self.DropDownListGetWay:SetSelectedIndex(1)
end

function CompanionArchivePanelView:OnBtnCancelSearchClicked()
	
end

function CompanionArchivePanelView:OnBtnDescriptionClicked()
	self.ViewModel:SetDescriptionVisible(true)
	self:ReportTLOG(7, self:GetSelectedCompanionID())
end

function CompanionArchivePanelView:OnBtnMessageBoardClicked()
	local Params = {
		BoardTypeID = BoardType.Companion, -- 留言板类型ID
		SelectObjectID = self:GetSelectedCompanionID() -- 图鉴中的物品ID
	}
	UIViewMgr:ShowView(UIViewID.MessageBoardPanel, Params)
end

function CompanionArchivePanelView:OnBtnSwitchClicked()
	local VMData = self:GetSelectedCompanionVM()
	local CompanionList = VMData.Cfg.CompanionID
	if self.MergeCompanionIndex == #CompanionList then
		self.MergeCompanionIndex = 1
	else
		self.MergeCompanionIndex = self.MergeCompanionIndex + 1
	end

	self.SelectedCompanionID = CompanionList[self.MergeCompanionIndex]
	self:ResetAnimationState()
	self.CompanionRenderer:SwitchModel(self.SelectedCompanionID)
end

function CompanionArchivePanelView:OnBtnGetWayClicked()
	local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnGetWay)
	TipsUtil.ShowGetWayTips(self.ViewModel, nil, self.BtnGetWay, UE.FVector2D(BtnSize.X, -15), UE.FVector2D(1, 1), false)
	self:ReportTLOG(5, self:GetSelectedCompanionID())
end

function CompanionArchivePanelView:OnBtnShowClicked()
	self.ViewModel:SetAutoPlayInteract(false)
	self.ViewModel:SetShowState(true)
	local function Callback()
		self.ViewModel:SetShowState(false)
	end

	self:PlayInteractTimelineByList(Callback)
	self:ReportTLOG(6, self:GetSelectedCompanionID(), 2)
end

function CompanionArchivePanelView:OnBtnShowCancelClicked()
	self:StopActionTimeline()
end

function CompanionArchivePanelView:OnBtnAttackClicked()
	self.ViewModel:SetAutoPlayInteract(false)
	self.ViewModel:SetAttackState(true)
	local function Callback()
		self.ViewModel:SetAttackState(false)
	end
	self:PlayActionTimeline(AttackTimelineLabel, Callback)
	self:ReportTLOG(6, self:GetSelectedCompanionID(), 3)
end

function CompanionArchivePanelView:OnBtnAttackCancelClicked()
	self:StopActionTimeline()
end

function CompanionArchivePanelView:OnBtnMoveClicked()
	self.ViewModel:SetAutoPlayInteract(false)
	self.ViewModel:SetMoveState(true)
	local function Callback()
		self.ViewModel:SetMoveState(false)
	end
	self:PlayActionTimeline(MoveTimelineLable, Callback)
	self:ReportTLOG(6, self:GetSelectedCompanionID(), 1)
end

function CompanionArchivePanelView:OnBtnMoveCancelClicked()
	self:StopActionTimeline()
end

function CompanionArchivePanelView:OnSingleBoxNotOwnStateChanged(ToggleButton, ButtonState)
	local IsChecked = UIUtil.IsToggleButtonChecked(ButtonState)
	self.ViewModel.IsShowNotOwn = IsChecked
	self.ViewModel.LastEmptyType = EmptyType.Toggle

	if not IsChecked then
		self.ViewModel.CurrentShowList = self.ViewModel.AllCompanionIDList
	else
		self.ViewModel.CurrentShowList = self.ViewModel.NotOwnCompanionIDList
	end
end

function CompanionArchivePanelView:OnSelectionChangedGetWayFilter(Index, ItemData, ItemView, IsByClick)
	self.ViewModel.LastEmptyType = EmptyType.Filter

	local Data = ItemData.ItemData
	if Data.FilterType == 0 then
		self.ViewModel:ResetGetWayFilterValue()
	else
		self.ViewModel:SetGetWayFilterValue(Data.FilterType)
	end
end

function CompanionArchivePanelView:OnPopUpBGHideDescriptionClicked()
	self.ViewModel:SetDescriptionVisible(false)
end

function CompanionArchivePanelView:OnCompanionArchiveModelStartRotate()
	self:ResetAnimationState()
end

function CompanionArchivePanelView:OnCompanionArchiveModelEndRotate()
	
end

function CompanionArchivePanelView:OnGameEventLevelPostLoad(Params)
    local LightLevelName = Params.StringParam1
	if LightLevelName ~= LightDefine.LightLevelPath[CompanionLightLevelID] then return end
	
	local UWorldMgr = UE.UWorldMgr.Get()
	local LightLevel = UE.UGameplayStatics.GetStreamingLevel(FWORLD(), LightLevelName)
    if LightLevel then
        if LightLevel:IsLevelLoaded() then
            local Level = LightLevel:GetLoadedLevel()
            if Level then
                local Actors = UWorldMgr:GetActorsInLevel(Level)
                for i=1, Actors:Length() do
                    local Actor = Actors:GetRef(i)
                    if Actor then
                        local Name = Actor:GetName()
                        if Name == "SphereReflectionCapture_1" then
                            self.LightLevelRef = Actor
                            break
                        end
                    end
                end
            end
        end
    end

	local World = GameplayStaticsUtil:GetWorld()
	local AllReflections = UE.TArray(UE.AActor)
	UE.UGameplayStatics.GetAllActorsOfClass(World, UE.ASphereReflectionCapture.StaticClass(), AllReflections)
	for Index = 1, AllReflections:Length() do
		local Reflection = AllReflections:GetRef(Index)
		if Reflection then
			if Reflection ~= self.LightLevelRef then
				self.CurWorldRef = Reflection
			end
		end
	end

	local NewCubemap = self.LightLevelRef.CaptureComponent.Cubemap
	if NewCubemap then
		self.OriginCubeMap = self.CurWorldRef.CaptureComponent.Cubemap
		self.CurWorldRef.CaptureComponent.Cubemap = NewCubemap
	end
end

function CompanionArchivePanelView:OnCompanionArchiveNewListUpdate()
	self.ViewModel:UpdateVMData()
end

function CompanionArchivePanelView:InitCompanionModel(CompanionID)
	self.HasInitCompanion = true
	local function RenderSceneCallBack(IsSuccess)
        if (IsSuccess) then
			-- self.CompanionRenderer:SwitchSceneLights(false)
			self.CompanionRenderer:SetFOVY(25, false)
        end
    end

	local function RenderActorCallBack(EntityID, CompanionActor)
		self.CompanionEntityID = EntityID
		self.CompanionActor = CompanionActor

		if self.WaitSwitchModelID then
			self.CompanionRenderer:SwitchModel(self.WaitSwitchModelID)
			self.WaitSwitchModelID = nil
		else
			local ID = CompanionActor:GetAttributeComponent().ResID
			
			self:SetSpringArmToDefault(false)
			self.ModelLocation = self.CompanionActor:FGetLocation(UE.EXLocationType.ServerLoc)
			self:SetModelScale(ID)
			self:SetModelLocation(ID)
			self:SetModelRotation(ID)

			self.CompanionRenderer:SetActorVisible(self.ViewModel.IsNotProtect)
			self.CompanionRenderer:SetInteractionActive(true)
			self:TryPlayInteractWhenSelect()
		end
	end

	local CreateParam = {
		Location = UE.FVector(0, 0, ActorZLocation),
		Rotation = UE.FRotator(0, 0, 0),
	}
	self.CompanionRenderer:ShowCompanion(SceneActorPath, CompanionID, RenderSceneCallBack, RenderActorCallBack, CreateParam)
end

function CompanionArchivePanelView:SetSpringArmToDefault(bInterp)
	self:SetSpringArmLocationToDefault(bInterp)
	self:SetSpringArmRotationToDefault(bInterp)
	self:SetSpringArmDistanceToDefault(bInterp)
	--self:SetSpringArmCenterOffsetYoDefault(bInterp)
end

function CompanionArchivePanelView:SetSpringArmLocationToDefault(bInterp)
	self.CompanionRenderer:SetSpringArmLocation(0, 80, 95, bInterp)
end

function CompanionArchivePanelView:SetSpringArmRotationToDefault(bInterp)
	self.CompanionRenderer:SetSpringArmRotation(0, 180, 0, bInterp)
end

function CompanionArchivePanelView:SetSpringArmDistanceToDefault(bInterp)
	self.CompanionRenderer:SetSpringArmDistance(600, bInterp)
end

function CompanionArchivePanelView:SetSpringArmCenterOffsetYoDefault(bInterp)
	self.CompanionRenderer:SetSpringArmCenterOffsetY(90)
end

--- 尝试保持之前选中的宠物
---@param SelectedCompanionID uint32 需要选中的宠物ID，如果不传则默认选中列表第一个宠物
function CompanionArchivePanelView:TryKeepSelectedCompanion(SelectedCompanionID)
	local VMList = self.ViewModel.CompanionVMList
	if VMList == nil or #VMList == 0 then
		self.CompanionAdapterTableView:CancelSelected() 
		return
	end

	local SelectIndex = 1
	if SelectedCompanionID then
		for Index, VM in ipairs(VMList) do
			if not VM.IsMerge then
				if VM.CompanionID == SelectedCompanionID then
					SelectIndex = Index
					break
				end
			else
				if table.contain(VM.Cfg.CompanionID, SelectedCompanionID) then
					SelectIndex = Index
					break
				end
			end
		end
	end

	self.CompanionAdapterTableView:SetSelectedIndex(SelectIndex)
end

function CompanionArchivePanelView:SetModelScale(CompanionID)
	if self.CompanionActor == nil then return end

	local ScaleBase = 100
	local Cfg = CompanionMgr:GetCompanionExternalCfg(CompanionID)
	
	if Cfg ~= nil and Cfg.ArchiveModelScale > 0 then
		ScaleBase = Cfg.ArchiveModelScale
	end

	local ScaleFactor = ScaleBase / 100
	local CompanionCharacter = self.CompanionActor:Cast(UE.ACompanionCharacter)
	CompanionCharacter:SetScaleFactor(ScaleFactor, true)
end

function CompanionArchivePanelView:SetModelRotation(CompanionID)
	if self.CompanionActor == nil then return end

	local RotationAngle = 0
	local Cfg = CompanionMgr:GetCompanionExternalCfg(CompanionID)

	local Threshold = 0.001
	if Cfg ~= nil and math.abs(Cfg.ArchiveModelRotation) > Threshold then
		RotationAngle = Cfg.ArchiveModelRotation
	end
	
	local Rotation = UE.FRotator(0, 0, 0)
	self.CompanionActor:K2_SetActorRotation(Rotation, false)
	self.CompanionRenderer:SetModelRotation(0, RotationAngle, 0, false)
end

function CompanionArchivePanelView:SetModelLocation(CompanionID)
	if self.CompanionActor == nil then return end

	local MeshComponent = self.CompanionRenderer:GetSkeletalMeshComponent(self.CompanionActor)
	local MeshOriginPosition =  MeshComponent:GetRelativeLocation()

	local Cfg = CompanionMgr:GetCompanionExternalCfg(CompanionID)

	-- 配置了才调整位置，没配置则使用模型的默认位置
	if Cfg and Cfg.ArchiveModelLocation then
		local CfgX = Cfg.ArchiveModelLocation.X
		local CfgY = Cfg.ArchiveModelLocation.Y
		local CfgZ = Cfg.ArchiveModelLocation.Z
		local ModelX = CfgX or MeshOriginPosition.X
		local ModelY = CfgY or MeshOriginPosition.Y
		-- 模型XY直接设置Mesh
		self.CompanionRenderer:SetModelLocation(ModelX, ModelY, MeshOriginPosition.Z, false)
		-- 模型Z需要透过接口另外设置
		local CompanionCharacter = self.CompanionActor:Cast(UE.ACompanionCharacter)
		CompanionCharacter:SetModelFloatHeight(CfgZ, true)

		-- 背景位置需要根据模型位置调整
		local MeshLocationForBG = UE.FVector(ModelX, ModelY, 0)
		local ActorTransform = self.CompanionActor:GetTransform()
		local BGLocation = _G.UE.UKismetMathLibrary.TransformLocation(ActorTransform, MeshLocationForBG)
		BGLocation.Z = ActorZLocation
		self.CompanionRenderer:SetBackgroundLocation(BGLocation)
	end
end

function CompanionArchivePanelView:GetCompanionName(CompanionID)
	local Cfg = CompanionCfg:FindCfgByKey(CompanionID)
	return Cfg and Cfg.Name or ""
end

function CompanionArchivePanelView:PlayActionTimeline(TimelineLabel, Callback)
	local SearchCondition = string.format("Label = \"%s\"", TimelineLabel)
	local ActiontimelineCfg = ActiontimelinePathCfg:FindCfg(SearchCondition)

	AnimMgr:PlayActionTimeLine(self.CompanionEntityID, ActiontimelineCfg.Filename, Callback)
end

function CompanionArchivePanelView:StopActionTimeline()
	if not self.CompanionActor then return end

	local AnimationComponent = self.CompanionActor:GetAnimationComponent()
	local AnimationInstance = AnimationComponent:GetAnimInstance()
	local BlendOutTime = 0.25
	AnimationInstance:Montage_Stop(BlendOutTime)
end

function CompanionArchivePanelView:IsSelectedMergeCompanion()
	local CompanionVM = self.CompanionAdapterTableView:GetSelectedItemData()
	return CompanionVM and CompanionVM.IsMerge or false
end

function CompanionArchivePanelView:GetSelectedCompanionID()
	local Index = self.CompanionAdapterTableView:GetSelectedIndex()
	if Index == nil then return 0 end

	local CompanionVM = self.CompanionAdapterTableView:GetSelectedItemData()
	return CompanionVM.IsMerge and CompanionVM.Cfg.CompanionID[1] or CompanionVM.CompanionID
end

function CompanionArchivePanelView:GetSelectedCompanionVM()
	return self.CompanionAdapterTableView:GetSelectedItemData()
end

function CompanionArchivePanelView:GetCompanionFromRandom(List)
	if List == nil or #List == 0 then return 0 end

	local Index = math.random(#List)
	return List[Index]
end

function CompanionArchivePanelView:OnClickRenderer()
	local MouseX = self.CompanionRenderer.StartPosX
	local MouseY = self.CompanionRenderer.StartPosY
	local MousePosition = UE.FVector2D(MouseX, MouseY)
	if UIUtil.IsUnderLocation(self.PanelInteract, MousePosition) then
		self.ViewModel:SetAutoPlayInteract(not self.ViewModel:GetAutoPlayInteract())
		self:TryPlayInteractTimeline()
	end
end

function CompanionArchivePanelView:TryPlayInteractTimeline()
	local function Callback()
		if self.ViewModel:GetAutoPlayInteract() then
			self:PlayInteractTimelineByList(Callback)
		end
	end

	if self.ViewModel:GetAutoPlayInteract() then
		self:PlayInteractTimelineByList(Callback)
		self:ReportTLOG(4, self:GetSelectedCompanionID())
	else
		self:StopActionTimeline()
	end
end

function CompanionArchivePanelView:PlayInteractTimelineByList(Callback)
	local InteractCount = #self.InteractTimelineList
	if InteractCount > 0 then
		if self.InteractTimelineIndex == InteractCount then
			self.InteractTimelineIndex = 1
		else
			self.InteractTimelineIndex = self.InteractTimelineIndex + 1
		end
		local TimelineLabel = self.InteractTimelineList[self.InteractTimelineIndex]
		self:PlayActionTimeline(TimelineLabel, Callback)
	end
end

function CompanionArchivePanelView:ResetAnimationState()
	self:StopActionTimeline()
	self.ViewModel:ResetAnimaionState()
end

function CompanionArchivePanelView:RestoreRefelctionCubemap()
	if self.CurWorldRef == nil then return end
	
	self.CurWorldRef.CaptureComponent.Cubemap = self.OriginCubeMap
	self.OriginCubeMap = nil
end

function CompanionArchivePanelView:UpdateInteractList(CompanionID)
	self.InteractTimelineList = {}
	self.InteractTimelineIndex = 0
	local Cfg = CompanionMgr:GetCompanionExternalCfg(CompanionID)
	if Cfg.InactiveIdle1 > 0 then
		table.insert(self.InteractTimelineList, Interact1TimelineLabel)
	end
	if Cfg.InactiveIdle2 > 0 then
		table.insert(self.InteractTimelineList, Interact2TimelineLabel)
	end

    -- 检查是否解锁了特殊的表演动作
	local IsUnlockAction = CompanionMgr:IsActionUnlock(CompanionID, ProtoRes.CompanionUnlockActionType.Action1)
	if IsUnlockAction then
		table.insert(self.InteractTimelineList, Interact3TimelineLabel)
	end

	self.ViewModel.HasShow = self.InteractTimelineList and #self.InteractTimelineList > 0 or false
end

function CompanionArchivePanelView:ShowModel(CompanionID)
	if not self.HasInitCompanion then
		self:InitCompanionModel(CompanionID)
	elseif self.CompanionActor then
		self.CompanionRenderer:SwitchModel(CompanionID)
	else
		self.WaitSwitchModelID = CompanionID
	end
end

function CompanionArchivePanelView:HandlePageSourceTLOG()
	local FromListPanel = self.Params and self.Params.FromListPanel
	local Arg1 = FromListPanel == true and 1 or 2
	self:ReportTLOG(2, Arg1)
end

function CompanionArchivePanelView:ReportTLOG(OpType, Arg1, Arg2)
	Arg1 = Arg1 and tostring(Arg1)
	Arg2 = Arg2 and tostring(Arg2)
    DataReportUtil.ReportData("PetSystemFlow", true, false, true,
	"OpType", tostring(OpType),
	"Arg1", Arg1,
	"Arg2", Arg2)
end

function CompanionArchivePanelView:SetFixText()
	self.CommonTitle:SetTextTitleName(LSTR(120025))
	self.TextMoveTypeTitle:SetText(LSTR(120027))
	self.SearchBar:SetHintText(LSTR(120028))
	self.SingleBoxNotOwn:SetText(LSTR(120029))
	self.TextGetWay:SetText(LSTR(120030))
	self.RichTextNone:SetText(LSTR(120031))
    self.InputBoxMeshZ:SetHintText(LSTR(120034))
end

function CompanionArchivePanelView:OnMeshZCommitted(Text)
	if string.isnilorempty(Text) then return end

	local MeshZPosition = tonumber(Text)
	local CompanionCharacter = self.CompanionActor:Cast(UE.ACompanionCharacter)
	CompanionCharacter:SetModelFloatHeight(MeshZPosition, true)
end

function CompanionArchivePanelView:TryPlayInteractWhenSelect()
	if self.ViewModel.IsNotProtect then
		self:PlayActionTimeline(Interact1TimelineLabel)
	end
end

return CompanionArchivePanelView