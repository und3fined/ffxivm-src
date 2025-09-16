---
--- Author: Administrator
--- DateTime: 2025-03-17 20:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MusicAtlasRevertPanelVM = require("Game/MusicAtlas/View/MusicAtlasRevertPanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EventID = require("Define/EventID")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")



local LSTR = _G.LSTR

---@class MusicAtlasRevertPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack UFButton
---@field CommEmpty CommBackpackEmptyView
---@field FCanvasPanel_69 UFCanvasPanel
---@field ImgBG01 UFImage
---@field ImgPlay UFImage
---@field MusicAtlasProbarItem_UIBP MusicAtlasProbarItemView
---@field SearchBar CommSearchBarView
---@field TableViewList UTableView
---@field TextName UFTextBlock
---@field TextTItle01 UFTextBlock
---@field TextTItle02 UFTextBlock
---@field TextTime UFTextBlock
---@field ToggleBtnStart UToggleButton
---@field VerIconTabs CommVerIconTabsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicAtlasRevertPanelView = LuaClass(UIView, true)

function MusicAtlasRevertPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.CommEmpty = nil
	--self.FCanvasPanel_69 = nil
	--self.ImgBG01 = nil
	--self.ImgPlay = nil
	--self.MusicAtlasProbarItem_UIBP = nil
	--self.SearchBar = nil
	--self.TableViewList = nil
	--self.TextName = nil
	--self.TextTItle01 = nil
	--self.TextTItle02 = nil
	--self.TextTime = nil
	--self.ToggleBtnStart = nil
	--self.VerIconTabs = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicAtlasRevertPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.MusicAtlasProbarItem_UIBP)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicAtlasRevertPanelView:OnInit()
	self.ViewModel = MusicAtlasRevertPanelVM.New()
	self.MusicAtlasList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnAtlasSelectChanged, true)
	self.Binders = {
		{ "MusicAtlasList", UIBinderUpdateBindableList.New(self, self.MusicAtlasList) },
		{ "Subtitle", UIBinderSetText.New(self, self.TextTItle02) },
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },
		{ "MusicName", UIBinderSetText.New(self, self.TextName) },	
		{ "Percent", UIBinderSetSlider.New(self, self.MusicAtlasProbarItem_UIBP)},
		{ "PanelEmptyVisible", UIBinderSetIsVisible.New(self, self.CommEmpty)},
		{ "TableViewListVisible", UIBinderSetIsVisible.New(self, self.TableViewList)},
	}

	self.CurPlayingID = nil     --当前正在播放的ID
	self.CurPlayingIndex = nil  --当前正在播放的Index
	self.SerachChosedID = nil   --搜索时选中播放的ID
	self.SearchBar:SetCallback(self, nil, self.OnSearchCommit, self.OnCancelSearchClicked)
end

function MusicAtlasRevertPanelView:OnBeginChangedSlider()
	MusicPlayerMgr.IsDragSlide = true
end

function MusicAtlasRevertPanelView:OnValueChangedSlider(Percent)
	self.ChangedPercent = Percent
	local TotalTime = MusicPlayerMgr:GetMusicTime(self.CurPlayingID) or 0
	local CurTime = Percent * TotalTime

	self.ViewModel:SetTimeTextAndBar(CurTime, TotalTime)
end

function MusicAtlasRevertPanelView:OnEndChangedSlider()
	if self.PlayState then
		self.ViewModel:SetMusicSlideByPrecent(self.ChangedPercent)
	end
	MusicPlayerMgr.IsDragSlide = false
end

function MusicAtlasRevertPanelView:OnDestroy()

end

function MusicAtlasRevertPanelView:OnShow()
	self.IsClickClose = false
	self:SetSearchBarHintText()
	self.MusicAtlasProbarItem_UIBP:SetCaptureBeginCallBack(function (v)
		self:OnBeginChangedSlider()
	end)
	self.MusicAtlasProbarItem_UIBP:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v)
	end)
	self.MusicAtlasProbarItem_UIBP:SetCaptureEndCallBack(function (v)
		self:OnEndChangedSlider()
	end)

	self.ChangedPercent = 0
	self:InitTabInfo()
	if self.Params then
		self.CurMusicID = self.Params.CurChoseAtlasID  --跳转过来的乐谱ID
		self.TypeIndex = self.Params.TypeIndex         --跳转过来的TabIndex
		self.VerIconTabs:SetSelectedIndex(self.TypeIndex)
		self.VerIconTabs:ScrollIndexIntoView(self.TypeIndex)
		self:JumpToAtlas()
	end
	self.TextTItle01:SetText(LSTR(1170014))--乐谱回想
end

function MusicAtlasRevertPanelView:InitTabInfo()
	local AllTypeList = MusicPlayerMgr.AtlasTabList
	local NewTyepList = self:GetTypeList(AllTypeList)
	self.ViewModel.AllTypeList = NewTyepList
	self.VerIconTabs:UpdateItems(NewTyepList)
end

function MusicAtlasRevertPanelView:JumpToAtlas()
	for Index, Value in ipairs(self.ViewModel.MusicAtlasList.Items) do
		if Value.MusicID == self.CurMusicID then
			self.MusicAtlasList:SetSelectedIndex(Index)
			self.MusicAtlasList:ScrollToIndex(Index)
		end
	end
end

function MusicAtlasRevertPanelView:OnHide()
	MusicPlayerMgr:SetRecallState(false)
	self:ExitRevert()
	if not self.IsClickClose then
		MusicPlayerMgr:ExitRevertState()
	end
end

function MusicAtlasRevertPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack, self.CloseViewByClick)
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnTabSelectChanged)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnStart, self.ClickToggleBtnStart)
end

function MusicAtlasRevertPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateRevertState, self.SetTimeTextAndBar)
	self:RegisterGameEvent(EventID.ExitRevertState, self.CloseView)
end

function MusicAtlasRevertPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function MusicAtlasRevertPanelView:OnAtlasSelectChanged(Index, ItemData)
	if MusicPlayerMgr.CurPlayingRevertID ~= ItemData.MusicID then
		self:PlayMusic(Index, ItemData.MusicID, false)
	elseif MusicPlayerMgr.CurPlayingRevertID == ItemData.MusicID and not self.PlayState then
		self:PlayMusic(Index, ItemData.MusicID, true)
	end
end

function MusicAtlasRevertPanelView:PlayMusic(Index, MusicID, IsSame)
	self.ViewModel:UpdateBtnMusicName(MusicID)
	if not IsSame and not MusicPlayerMgr.IsbReconnect then
		self.ChangedPercent = 0
	end

	self.PlayState = true
	MusicPlayerMgr.ReCallPlayState = true
	self.ToggleBtnStart:SetChecked(true)
	self.CurPlayingID = MusicID
	self.CurPlayingIndex = Index
	self.CurPlayingTypeIndex = self.TypeIndex
	MusicPlayerMgr.CurRevertPlayingMusicIndex = Index
	MusicPlayerMgr.CurRevertPlayingTypeIndex = self.TypeIndex
	self.ViewModel:StopPlayChoseMusic()
	MusicPlayerMgr:PlayAtlasRevertMusic(MusicID)
	self.ViewModel:PlayChoseMusic(MusicID, self.ChangedPercent)
	if self.IsSearching then
		self.SerachChosedID = MusicID
	end

	--回想状态下断线恢复进度
	if MusicPlayerMgr.IsbReconnect and MusicPlayerMgr.ReCallPlayState then
		self.ViewModel:SetMusicSlideByPrecent(MusicPlayerMgr.CurPlayPercent)
		MusicPlayerMgr.IsbReconnect = false
	end
end

function MusicAtlasRevertPanelView:OnTabSelectChanged(Index, ItemData)
	self.TypeIndex = Index
	local CurType = self.ViewModel.AllTypeList[Index].Type
	local CurAtlasList = MusicPlayerMgr:GetAtlasInfoByType(CurType)
	local UnLockList = self.ViewModel:GetUnLockAtlas(CurAtlasList)
	self.CurUnLockList = UnLockList
	if UnLockList and #UnLockList < 1 then
		self.CommEmpty:SetTipsContent(LSTR(1170004))
	end
	self.ViewModel:UpdateItemInfo(UnLockList)
	self.ViewModel:SetSubTitle(CurType, false)
	if Index == self.CurPlayingTypeIndex then
		self.MusicAtlasList:SetSelectedIndex(self.CurPlayingIndex)
	else
		self.MusicAtlasList:CancelSelected()
	end
	if self.IsSearching then
		self.SearchBar:OnClickButtonCancel()
	end
end

function MusicAtlasRevertPanelView:ClickToggleBtnStart()
	if MusicPlayerMgr.ReCallPlayState then
		self.PlayState = false
		MusicPlayerMgr.ReCallPlayState = false
		self.ToggleBtnStart:SetChecked(false)
		MusicPlayerMgr:StopCurRevertMusic()
		self.ViewModel:StopPlayChoseMusic()
	else
		MusicPlayerMgr.ReCallPlayState = true
		self.ToggleBtnStart:SetChecked(true)
		self.MusicAtlasList:SetSelectedIndex(self.CurPlayingIndex)
	end
end

function MusicAtlasRevertPanelView:SetTimeTextAndBar(Time)
	if Time == nil then
		return
	end
	local CurTime = Time.CurTime
	local TotalTime = Time.TotalTime

	self.ViewModel:SetTimeTextAndBar(CurTime, TotalTime)
	self.ChangedPercent = self.ViewModel.Percent
	MusicPlayerMgr.CurPlayPercent = self.ViewModel.Percent
	if CurTime >= TotalTime then
		MusicPlayerMgr.CurRevertPlayTime = 0
		self.ViewModel:SetMusicSlideByPrecent(0)
		return
	end
end

function MusicAtlasRevertPanelView:RestPlayCurMusic()
	MusicPlayerMgr.CurRevertPlayTime = 0
	self.ViewModel:SetMusicSlideByPrecent(0)
end

function MusicAtlasRevertPanelView:ExitRevert()
	MusicPlayerMgr.ReCallPlayState = false
	MusicPlayerMgr:StopCurRevertMusic()
	self.ViewModel:StopPlayChoseMusic()
end

function MusicAtlasRevertPanelView:OnSearchCommit(Text)
	if Text == "" or Text == nil then
		return
	end
	self.IsSearching = true
	local result = self.ViewModel:MatchMusic(Text)
	self.CurSearchList = result
	self.VerIconTabs:SetSelectedIndex(0)
	self.MusicAtlasList:CancelSelected()
	self.ViewModel:SetSubTitle(self.CurTypeIndex, true)
	self.ViewModel:UpdateItemInfo(result)
end

function MusicAtlasRevertPanelView:SetSearchBarHintText()
	self.SearchBar:SetHintText(LSTR(1170011)) --搜索乐谱或编号
	self.CommEmpty:SetTipsContent(LSTR(1170006))
end

function MusicAtlasRevertPanelView:OnCancelSearchClicked()
	self.IsSearching = false
	self.ViewModel:UpdateItemInfo(self.CurUnLockList)
	if self.SerachChosedID then
		local TypeIndex, MusicIndex = self.ViewModel:GetSearchMusicIDInfo(self.SerachChosedID)
		self.VerIconTabs:SetSelectedIndex(TypeIndex or 1)
		self.VerIconTabs:ScrollIndexIntoView(TypeIndex or 1)
		self.MusicAtlasList:SetSelectedIndex(MusicIndex or 0)
		self.MusicAtlasList:ScrollToIndex(MusicIndex)
	else
		self.VerIconTabs:SetSelectedIndex(self.CurPlayingTypeIndex)
		self.VerIconTabs:ScrollIndexIntoView(self.CurPlayingTypeIndex)
		self.MusicAtlasList:SetSelectedIndex(self.CurPlayingIndex)
		self.MusicAtlasList:ScrollToIndex(self.CurPlayingIndex)
	end
	self.SerachChosedID = nil
end

function MusicAtlasRevertPanelView:GetTypeList(List)
	local TabList = List
	--屏蔽红点
	for _, Value in ipairs(TabList) do
		Value.RedDotData = {}
	end
	return TabList
end

function MusicAtlasRevertPanelView:CloseViewByClick()
	self.IsClickClose = true
	self:Hide()
end

function MusicAtlasRevertPanelView:CloseView()
	self:Hide()
end

return MusicAtlasRevertPanelView