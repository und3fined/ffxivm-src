---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EventID = require("Define/EventID")
local FishGuideVM = require("Game/FishNotes/FishGuideVM")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

local EToggleButtonState = _G.UE.EToggleButtonState
local FLinearColor = _G.UE.FLinearColor

---@class FishGuidePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnFishInghole UFButton
---@field CommSearchBtn CommSearchBtnView
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonGuideBkg CommonGuideBkgView
---@field DropDown CommDropDownListView
---@field FishGuideSlotTips FishGuideSlotTipsPanelView
---@field FishSearchEmpty CommBackpackEmptyView
---@field SearchBar CommSearchBarView
---@field TableViewGridList UTableView
---@field TextFishKing UFTextBlock
---@field TextFishKing1 UFTextBlock
---@field TextFishKing2 UFTextBlock
---@field TextFishQueen UFTextBlock
---@field TextFishQueen1 UFTextBlock
---@field TextFishQueen2 UFTextBlock
---@field TextSlash UFTextBlock
---@field TextSlash1 UFTextBlock
---@field TextSlash2 UFTextBlock
---@field TextTitleName CommonTitleView
---@field TextTotal UFTextBlock
---@field TextTotal1 UFTextBlock
---@field TextTotal2 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimSearchIn UWidgetAnimation
---@field AnimSearchOut UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishGuidePanelView = LuaClass(UIView, true)

function FishGuidePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnFishInghole = nil
	--self.CommSearchBtn = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonGuideBkg = nil
	--self.DropDown = nil
	--self.FishGuideSlotTips = nil
	--self.FishSearchEmpty = nil
	--self.SearchBar = nil
	--self.TableViewGridList = nil
	--self.TextFishKing = nil
	--self.TextFishKing1 = nil
	--self.TextFishKing2 = nil
	--self.TextFishQueen = nil
	--self.TextFishQueen1 = nil
	--self.TextFishQueen2 = nil
	--self.TextSlash = nil
	--self.TextSlash1 = nil
	--self.TextSlash2 = nil
	--self.TextTitleName = nil
	--self.TextTotal = nil
	--self.TextTotal1 = nil
	--self.TextTotal2 = nil
	--self.AnimIn = nil
	--self.AnimSearchIn = nil
	--self.AnimSearchOut = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishGuidePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommSearchBtn)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonGuideBkg)
	self:AddSubView(self.DropDown)
	self:AddSubView(self.FishGuideSlotTips)
	self:AddSubView(self.FishSearchEmpty)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.TextTitleName)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishGuidePanelView:OnInit()
	self.FishGridAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewGridList, self.OnFishGridSelectChanged, false, false)
	self.FishSearchEmpty:SetTipsContent(_G.LSTR(180101)) --180101 "未搜索到相关鱼类"
	self.Binders = {
		{"FishGridList", UIBinderUpdateBindableList.New(self, self.FishGridAdapterTableView)},
		{"TotalFishUnLock", UIBinderSetText.New(self, self.TextTotal1)},
		{"TotalFish", UIBinderSetText.New(self, self.TextTotal2)},
		{"FishKingUnlock", UIBinderSetText.New(self, self.TextFishKing1)},
		{"TotalFishKing", UIBinderSetText.New(self, self.TextFishKing2)},
		{"FishQueenUnlock", UIBinderSetText.New(self, self.TextFishQueen1)},
		{"TotalFishQueen", UIBinderSetText.New(self, self.TextFishQueen2)},
		{"bFishDetailVisible", UIBinderSetIsVisible.New(self, self.FishGuideSlotTips)},
		{"bFishSearchEmptyVisible", UIBinderSetIsVisible.New(self, self.FishSearchEmpty)},
		{"FishSearchEmptyText", UIBinderSetText.New(self, self.FishSearchEmpty.Text_SearchAgain)},
	}
end

function FishGuidePanelView:OnDestroy()
end

function FishGuidePanelView:OnShow()
	self.TextSlash:SetText("/")
	self.TextSlash1:SetText("/")
	self.TextSlash2:SetText("/")
	--self.TextKing:SetText(_G.LSTR(180064)) --"仅显示鱼王和鱼皇"
	self.TextTitleName:SetTextTitleName(_G.LSTR(180054))--鱼类图鉴
	self.TextTotal:SetText(_G.LSTR(180055))--总数：
	self.TextFishKing:SetText(_G.LSTR(180056))--鱼王：
	self.TextFishQueen:SetText(_G.LSTR(180057))--鱼皇：
	self.SearchBar:SetHintText(_G.LSTR(180063)) --搜索鱼类
	self:ClearSerch()
	FishGuideVM:UpdateCountInfo()
	--选中
	self.DropDown:SetForceTrigger(true)
	local Params = self.Params
	if Params ~= nil and Params.FishData ~= nil then
		self.DropDown:UpdateItems(FishNotesDefine.DropData, 1)
		local Index = FishGuideVM:GetSelectIndexByFishID(Params.FishData.ID) or 1
		self:SetSelected(Index)
	else
		self.DropDown:UpdateItems(FishNotesDefine.DropData, FishGuideVM.LastDropDownIndex or 1)
	end
	self:PlayAnimToEnd(self.AnimUpdateList)
end

function FishGuidePanelView:OnHide()
	self.FishGridAdapterTableView:CancelSelected()
end

function FishGuidePanelView:OnRegisterUIEvent()
	self.BtnBack:AddBackClick(self.BtnBack, self.OnClickButtonBack)
	self.SearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
	UIUtil.AddOnFocusLostEvent(self, self.SearchBar.TextInput, self.OnTextFocusLost)
	UIUtil.AddOnClickedEvent(self, self.CommSearchBtn.BtnSearch, self.OnClickButtonSearch)
	UIUtil.AddOnClickedEvent(self, self.BtnFishInghole, self.OnClickButtonFishInghole)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDown, self.OnSelectionChangedDropDown)
end

function FishGuidePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FishNoteSkipLocation, self.OnSkipLocation)
	self:RegisterGameEvent(EventID.FishNoteRefreshGuideList, self.OnSelectionChangedDropDown)
end

function FishGuidePanelView:OnRegisterBinder()
	self:RegisterBinders(FishGuideVM, self.Binders)
end

--region 鱼列表刷新选中
function FishGuidePanelView:OnSelectionChangedDropDown(Index)
	FishGuideVM:UpdateFishList(Index)
	self:SetSelected()
end

---@type --默认选中激活的第一个 或上一个选择的 并置顶
function FishGuidePanelView:SetSelected(Index)
	local SelectedIndex = 1
	if Index then
		FishGuideVM.SelectedFishGridIndex = Index
	elseif FishGuideVM.SelectedFishGridIndex == nil or FishGuideVM.SelectedFishGridIndex == 0 then
		FishGuideVM:ResetSelectedFishGrid()
	end
	SelectedIndex = FishGuideVM.SelectedFishGridIndex or FishNotesDefine.SelectDefaultIndex or 1
	self.FishGridAdapterTableView:CancelSelected()
	self.FishGridAdapterTableView:SetSelectedIndex(SelectedIndex)
	if SelectedIndex > FishNotesDefine.GridColumn then
		self.TableViewGridList:SetScrollOffset(SelectedIndex-FishNotesDefine.GridColumn -1)
	else
		self.FishGridAdapterTableView:ScrollToIndex(SelectedIndex)
	end
end

---@type 选中的鱼切换
function FishGuidePanelView:OnFishGridSelectChanged(Index, ItemData, ItemView)
    FishGuideVM:UpdateFishDetail(Index, ItemData)
	self.FishGuideSlotTips:PlayAnimation(self.FishGuideSlotTips.AnimUpdate)
end
--endregion

--region 搜索
function FishGuidePanelView:OnTextFocusLost()
    UIUtil.SetIsVisible(self.SearchBar.BtnCancelNode, true,true)
end

---@type 打开搜索框
function FishGuidePanelView:OnClickButtonSearch()
    self:PlayAnimation(self.AnimSearchIn)
	self:ChangeSearchState(true)

    self.SearchBar:SetFocus()
	self.SearchBar:SetText('')
end

function FishGuidePanelView:OnSearchTextCommitted(SearchText)
	if string.isnilorempty(SearchText) then
		return
	end
	self:PlayAnimation(self.AnimUpdateList)
	FishGuideVM:ChangeSearchState(true)
	UIUtil.SetIsVisible(self.SearchBar.BtnCancelNode, true, true, false)
	if FishGuideVM:Search(SearchText) then
		self.DropDown:CancelSelected()
		self.FishGridAdapterTableView:CancelSelected()
		self:SetSelected(1)
	end 
end

---@type 关闭搜索框
function FishGuidePanelView:OnClickCancelSearchBar()
	self:ClearSerch()
	if FishGuideVM.SearchFishData == nil then
		self.DropDown:UpdateItems(FishNotesDefine.DropData, FishGuideVM.LastDropDownIndex or 1)
		self:SetSelected(FishGuideVM.SelectedFishGridIndex)
	else
		--如果搜索到了
		self.DropDown:UpdateItems(FishNotesDefine.DropData, 1)
		local Index = FishGuideVM:GetSelectIndexByFishID(FishGuideVM.SearchFishData.ID) or 1
		self:SetSelected(Index)
	end
end

function FishGuidePanelView:ClearSerch()
    self:PlayAnimation(self.AnimSearchOut)
    self.SearchBar:SetText('')
    self:ChangeSearchState(false)
    FishGuideVM:ChangeSearchState(false)
end

---@type 切换搜索状态
function FishGuidePanelView:ChangeSearchState(Flag)
	if Flag == true then
		UIUtil.SetIsVisible(self.SearchBar, true, true, true)
		UIUtil.SetIsVisible(self.DropDown, false, false, false)
		UIUtil.SetIsVisible(self.CommSearchBtn, false, false, false)
	else
		UIUtil.SetIsVisible(self.SearchBar, false, false, false)
		UIUtil.SetIsVisible(self.DropDown, true, true, true)
		UIUtil.SetIsVisible(self.CommSearchBtn, true, true, true)
	end
end
--endregion

--region 切换/跳转到钓场
---@type 切换钓场信息
function FishGuidePanelView:OnClickButtonFishInghole()
    UIViewMgr:HideView(UIViewID.FishGuide)
	UIViewMgr:ShowView(UIViewID.FishInghole)
end

---@type 跳转到指定的钓场
function FishGuidePanelView:OnSkipLocation(LocationInfo)
    UIViewMgr:HideView(UIViewID.FishGuide)
	UIViewMgr:ShowView(UIViewID.FishInghole, {SkipLocationInfo = LocationInfo})

	FishIngholeVM:SkipToSpecifiedLocation(LocationInfo)
end

---@type 关闭当前界面
function FishGuidePanelView:OnClickButtonBack()
	if UIViewMgr:IsViewVisible(UIViewID.GuideMainPanelView) then
		UIViewMgr:HideView(UIViewID.FishInghole)
	end
	UIViewMgr:HideView(UIViewID.FishGuide)
end
--endregion

return FishGuidePanelView