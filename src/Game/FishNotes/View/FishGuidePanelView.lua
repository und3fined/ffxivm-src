---
--- Author: Administrator
--- DateTime: 2023-03-20 17:38
--- Description:
---

local LuaClass = require("Core/LuaClass")

local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EventID = require("Define/EventID")

local FishGuideVM = require("Game/FishNotes/FishGuideVM")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")
local FishNotesMgr = require("Game/FishNotes/FishNotesMgr")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")

local EToggleButtonState = _G.UE.EToggleButtonState
local FLinearColor = _G.UE.FLinearColor

---@class FishGuidePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnFishInghole UFButton
---@field CommonBkg CommonBkg01View
---@field FishGuideSlotTips FishGuideSlotTipsPanelView
---@field FishSearchEmpty CommEmptyView
---@field NewSearchBtn CommSearchBtnView
---@field SearchBar CommSearchBarView
---@field SearchBtn UFButton
---@field SingleBox CommSingleBoxView
---@field TableViewGridList UTableView
---@field TableViewMountList UTableView
---@field TextFishKing UFTextBlock
---@field TextFishKing1 UFTextBlock
---@field TextFishKing2 UFTextBlock
---@field TextFishQueen UFTextBlock
---@field TextFishQueen1 UFTextBlock
---@field TextFishQueen2 UFTextBlock
---@field TextKing UFTextBlock
---@field TextTitleName UFTextBlock
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
	--self.CommonBkg = nil
	--self.FishGuideSlotTips = nil
	--self.FishSearchEmpty = nil
	--self.NewSearchBtn = nil
	--self.SearchBar = nil
	--self.SearchBtn = nil
	--self.SingleBox = nil
	--self.TableViewGridList = nil
	--self.TableViewMountList = nil
	--self.TextFishKing = nil
	--self.TextFishKing1 = nil
	--self.TextFishKing2 = nil
	--self.TextFishQueen = nil
	--self.TextFishQueen1 = nil
	--self.TextFishQueen2 = nil
	--self.TextKing = nil
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
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.FishGuideSlotTips)
	self:AddSubView(self.FishSearchEmpty)
	self:AddSubView(self.NewSearchBtn)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishGuidePanelView:OnInit()
	self.FishGridAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewGridList, self.OnFishGridSelectChanged, false, false)

	self.FishSearchTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewMountList, nil, false, false)

	self.Binders = {
		{"FishGridList", UIBinderUpdateBindableList.New(self, self.FishGridAdapterTableView)},
		{"FishSearchList", UIBinderUpdateBindableList.New(self, self.FishSearchTableView)},
		{"TotalFishUnLock", UIBinderSetText.New(self, self.TextTotal1)},
		{"TotalFish", UIBinderSetText.New(self, self.TextTotal2)},
		{"FishKingUnlock", UIBinderSetText.New(self, self.TextFishKing1)},
		{"TotalFishKing", UIBinderSetText.New(self, self.TextFishKing2)},
		{"FishQueenUnlock", UIBinderSetText.New(self, self.TextFishQueen1)},
		{"TotalFishQueen", UIBinderSetText.New(self, self.TextFishQueen2)},

		{"bFishSearchListVisible", UIBinderSetIsVisible.New(self, self.TableViewMountList)},
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
	self.TextKing:SetText(_G.LSTR(180064)) --"仅显示鱼王和鱼皇"
	self.TextTitleName:SetText(_G.LSTR(180054))--鱼类图鉴
	self.TextTotal:SetText(_G.LSTR(180055))--总数：
	self.TextFishKing:SetText(_G.LSTR(180056))--鱼王：
	self.TextFishQueen:SetText(_G.LSTR(180057))--鱼皇：
	self.SearchBar:SetHintText(_G.LSTR(180063)) --搜索鱼类
	self:ClearSerch()
	self:OnUpdateGuideList()
	local Animation = self.AnimUpdateList
	local EndTime = Animation:GetEndTime()
	self:PlayAnimationTimeRange(Animation, EndTime)
end

function FishGuidePanelView:OnHide()
	self.FishGridAdapterTableView:CancelSelected()
	FishGuideVM:OnFishGuidePanelHide()
end

function FishGuidePanelView:OnRegisterUIEvent()
	self.BtnBack:AddBackClick(self.BtnBack, self.OnClickButtonBack)
	self.SearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
	UIUtil.AddOnFocusLostEvent(self, self.SearchBar.TextInput, self.OnTextFocusLost)
	UIUtil.AddOnClickedEvent(self, self.SearchBtn, self.OnClickButtonSearch)

	UIUtil.AddOnClickedEvent(self, self.BtnFishInghole, self.OnClickButtonFishInghole)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnClickSingleBox)
end

function FishGuidePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FishNoteSkipLocation, self.OnSkipLocation)
	self:RegisterGameEvent(EventID.FishNoteRefreshGuideList, self.OnUpdateGuideList)
end

function FishGuidePanelView:OnRegisterBinder()
	self:RegisterBinders(FishGuideVM, self.Binders)
end

function FishGuidePanelView:OnUpdateGuideList()
	local IsCheck = self.SingleBox:GetChecked()
	self:OnClickSingleBox(nil, IsCheck)
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
	self.FishGridAdapterTableView:SetSelectedIndex(SelectedIndex)
	if SelectedIndex > FishNotesDefine.GridColumn then
		self.TableViewGridList:SetScrollOffset(SelectedIndex-FishNotesDefine.GridColumn -1)
	else
		self.TableViewGridList:ScrollToIndex(SelectedIndex)
	end
end

---@type 选中的鱼切换
function FishGuidePanelView:OnFishGridSelectChanged(Index, ItemData, ItemView)
	-- UIUtil.SetIsVisible(ItemView.ImgSelect, not UIUtil.IsVisible(ItemView.ImgSelect))

    FishGuideVM:SetSelectedFishGridIndex(Index)
	self.FishGuideSlotTips:PlayAnimation(self.FishGuideSlotTips.AnimUpdate)
end

---@type 关闭当前界面
function FishGuidePanelView:OnClickButtonBack()
	if UIViewMgr:IsViewVisible(UIViewID.GuideMainPanelView) then
		UIViewMgr:HideView(UIViewID.FishInghole)
	end
	UIViewMgr:HideView(UIViewID.FishGuide)
end

---@type 是否只显示鱼王鱼皇
function FishGuidePanelView:OnClickSingleBox(_, State)
	self:RefreshFilter(State)
	self.FishGridAdapterTableView:CancelSelected()
	self:SetSelected()
end

function FishGuidePanelView:RefreshFilter(State)
	if State == true or State == EToggleButtonState.Checked then
		self.TextKing:SetColorAndOpacity(FLinearColor.FromHex("D4FDCCFF"))
		FishGuideVM:FilterShowFish(true)
	else
		self.TextKing:SetColorAndOpacity(FLinearColor.FromHex("9C9788FF"))
		FishGuideVM:FilterShowFish(false)
	end
end

function FishGuidePanelView:ClearSerch()
    self:PlayAnimation(self.AnimSearchOut)
    self.SearchBar:SetText('')
    self:ChangeSearchState(false)
    FishGuideVM:ChangeSearchState(false)
end

function FishGuidePanelView:OnTextFocusLost()
    UIUtil.SetIsVisible(self.SearchBar.BtnCancelNode, true,true)
end

---@type 关闭搜索框
function FishGuidePanelView:OnClickCancelSearchBar()
	self:ClearSerch()
	local bFilterShow = FishGuideVM.LastbFilterShow
	if FishGuideVM.SearchFishIndex == 0 then
		FishGuideVM.FishGridList:Clear()
		self.FishGridAdapterTableView:CancelSelected()
		FishGuideVM.bFilterShow = bFilterShow
		self.SingleBox:SetChecked(bFilterShow)
		self:RefreshFilter(bFilterShow)
		self:SetSelected(FishGuideVM.SelectedFishGridIndex)
	else
		--如果搜索到了 
		local SelectedFishGridIndex = 0
		--且搜索之前选择的是筛选鱼王
		if bFilterShow then
			for Index, value in pairs(FishGuideVM.FilterDataList) do
				if value.ID == FishGuideVM.SelectFishNumberID then
					--且鱼王里还有搜索到的选择
					SelectedFishGridIndex = Index
					FishGuideVM.bFilterShow = bFilterShow
					self.SingleBox:SetChecked(bFilterShow)
					FishGuideVM:UpdateFilterFishList()
					self.FishGridAdapterTableView:CancelSelected()
					self:SetSelected(SelectedFishGridIndex)
					break
				end
			end
		end
		if SelectedFishGridIndex == 0 then
			if not table.is_nil_empty(FishGuideVM.FishCfgList) then
				for Index, value in pairs(FishGuideVM.FishCfgList) do
					if value.ID == FishGuideVM.SelectFishNumberID then
						FishGuideVM.SelectedFishGridIndex = Index
						break
					end
				end
			end
			FishGuideVM:UpdateFishList()
			self.FishGridAdapterTableView:CancelSelected()
			self:SetSelected(FishGuideVM.SelectedFishGridIndex)

			self.SingleBox:SetChecked(false)
			self.TextKing:SetColorAndOpacity(FLinearColor.FromHex("9C9788FF"))
		end
	end
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
		self.FishGridAdapterTableView:CancelSelected()
		self:SetSelected(1)
	end 
end

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

---@type 切换搜索状态
function FishGuidePanelView:ChangeSearchState(Flag)
	if Flag == true then
		UIUtil.SetIsVisible(self.SearchBar, true, true, true)
		UIUtil.SetIsVisible(self.SingleBox, false, false, false)
		UIUtil.SetIsVisible(self.SearchBtn, false, false, false)
		UIUtil.SetIsVisible(self.TextKing, false, false, false)
	else
		UIUtil.SetIsVisible(self.SearchBar, false, false, false)
		UIUtil.SetIsVisible(self.SingleBox, true, true, true)
		UIUtil.SetIsVisible(self.SearchBtn, true, true, true)
		UIUtil.SetIsVisible(self.TextKing, true, true, true)
	end
end	

return FishGuidePanelView