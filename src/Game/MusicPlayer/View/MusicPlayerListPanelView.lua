---
--- Author: Administrator
--- DateTime: 2023-12-08 11:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MusicPlayerListPanelVM = require("Game/MusicPlayer/View/MusicPlayerListPanelVM")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local EventID = require("Define/EventID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local EventMgr = require("Event/EventMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LSTR = _G.LSTR


---@class MusicPlayerListPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackEmpty CommBackpackEmptyView
---@field BtnSearch UFButton
---@field CommSearchBar2 CommSearchBarView
---@field EmptyStatePanel UFCanvasPanel
---@field ImgEmptyState UFImage
---@field ListPanel UFCanvasPanel
---@field MusicDropDownListNew CommDropDownListView
---@field SearchBtnPanel UFCanvasPanel
---@field TableViewSidebarList UTableView
---@field TextListTitle UFTextBlock
---@field TextState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicPlayerListPanelView = LuaClass(UIView, true)

function MusicPlayerListPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackEmpty = nil
	--self.BtnSearch = nil
	--self.CommSearchBar2 = nil
	--self.EmptyStatePanel = nil
	--self.ImgEmptyState = nil
	--self.ListPanel = nil
	--self.MusicDropDownListNew = nil
	--self.SearchBtnPanel = nil
	--self.TableViewSidebarList = nil
	--self.TextListTitle = nil
	--self.TextState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicPlayerListPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackEmpty)
	self:AddSubView(self.CommSearchBar2)
	self:AddSubView(self.MusicDropDownListNew)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicPlayerListPanelView:OnInit()
	self.ViewModel = MusicPlayerListPanelVM.New()
	self.RightMusicItemList = UIAdapterTableView.CreateAdapter(self, self.TableViewSidebarList,self.OnSelectChanged,true)
	self.Binders = {
		{ "RightMusicList", UIBinderUpdateBindableList.New(self, self.RightMusicItemList) },
	}
	self.CommSearchBar2:SetCallback(self, nil, self.OnSearchCommit, self.OnCancelSearchClicked)
end

function MusicPlayerListPanelView:OnDestroy()

end

function MusicPlayerListPanelView:OnShow()
	self.CurSerachChosedType = nil
	local Content = string.format("<span color=\"#6c6964\">%s</>", LSTR(1190022))--暂未收录乐曲哦, 快去找找吧库啵!
	self.BackpackEmpty:SetTipsContent(Content)
	local BtnText = string.format("<span color=\"#1D1D1DFF\">%s</>", LSTR(1190028))--查看
	self.BackpackEmpty:SetBtnText(BtnText)
	self.CommSearchBar2:SetHintText(LSTR(1190029))
	self.TextListTitle:SetText(LSTR(1190018))
	self.TextState:SetText(LSTR(1190007))
	self.MusicDropDownListNew:SetIsCancelHideClearSelected(false)
	local IsVisible = UIUtil.IsVisible(self.MusicDropDownListNew)
	if not IsVisible then
		UIUtil.SetIsVisible(self.MusicDropDownListNew, true)
	end
	UIUtil.SetIsVisible(self.CommSearchBar2, false)
	UIUtil.SetIsVisible(self.SearchBtnPanel, true)

	self.IsCanChose = false
	self.CurMusicList = {}
	self:InitMusicInfo()
	--self.ViewModel:UpdateDropList()
	--self:InitDropList()
end

function MusicPlayerListPanelView:OnHide()
	if self.IsSearch then
		self:OnCancelSearchClicked()
	end
	self.CurMusicList = {}
	self.ViewModel:Clear()
end

function MusicPlayerListPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.MusicDropDownListNew, self.OnSelectionChangedDropDownList)
	UIUtil.AddOnClickedEvent(self,  self.BtnSearch, self.OnBtnSearchClick)
	UIUtil.AddOnClickedEvent(self,  self.BackpackEmpty.Btn, self.JumpToAtlas)
end

function MusicPlayerListPanelView:OnBtnSearchClick()
	self.IsSearch = true
	MusicPlayerMgr.PlayerIsSearch = true
	local IsVisible = UIUtil.IsVisible(self.MusicDropDownListNew)
	if IsVisible then
		UIUtil.SetIsVisible(self.MusicDropDownListNew, false)
		UIUtil.SetIsVisible(self.CommSearchBar2, true)
		UIUtil.SetIsVisible(self.SearchBtnPanel, false)
	end
end

function MusicPlayerListPanelView:OnCancelSearchClicked()
	self.IsSearch = false
	MusicPlayerMgr.PlayerIsSearch = false
	UIUtil.SetIsVisible(self.MusicDropDownListNew, true)
	UIUtil.SetIsVisible(self.CommSearchBar2, false)
	UIUtil.SetIsVisible(self.SearchBtnPanel, true)
	local BackpackEmptyVisible = UIUtil.IsVisible(self.BackpackEmpty)
	if BackpackEmptyVisible then
		UIUtil.SetIsVisible(self.BackpackEmpty, false)
	end
	local Content = string.format("<span color=\"#6c6964\">%s</>", LSTR(1190022))--暂未收录乐曲哦, 快去找找吧库啵!
	self.BackpackEmpty:SetTipsContent(Content)
	self.ViewModel:UpdateMusicListInfo(self.CurMusicList) 
	local TypeIndex = self.DropDownIndex
	if MusicPlayerMgr.RighListChoseMusicID and MusicPlayerMgr.RightListChoseType then
		TypeIndex = self:GetTabIndexByType(self.CurSerachChosedType)
	end
	self.MusicDropDownListNew:SetSelectedIndex(TypeIndex)
end

function MusicPlayerListPanelView:OnSearchCommit(Text)
	local result = self.ViewModel:MatchMusic(Text)
	local MusicList = self:GetMusicList(result)
	local BackpackEmptyVisible = UIUtil.IsVisible(self.BackpackEmpty)
	if #MusicList > 0 then
		self.ViewModel:UpdateMusicListInfo(MusicList) 
		if BackpackEmptyVisible then
			UIUtil.SetIsVisible(self.BackpackEmpty, false)
		end
	else
		self.ViewModel:UpdateMusicListInfo({})
		UIUtil.SetIsVisible(self.BackpackEmpty, true)
		local Content = string.format("<span color=\"#6c6964\">%s</>", LSTR(1190030)) --暂未收录乐曲哦，快去找找吧库啵！
		self.BackpackEmpty:SetTipsContent(Content)
		self.BackpackEmpty:ShowPanelBtn(false)
	end
end

function MusicPlayerListPanelView:OnSelectionChangedDropDownList(Index, ItemData, ItemView)
	--FLOG_ERROR("OnSelectionChangedDropDownList = %d", Index)
	local DropListInfo = self.ViewModel.DropListInfo and self.ViewModel.DropListInfo[Index]
	local MusicList
	if DropListInfo then
		MusicList = self:GetMusicList(DropListInfo.MusicInfo)
	else
		MusicList = {}
	end

	self.DropDownIndex = Index
	MusicPlayerMgr.RightListChoseType = Index
	if #MusicList == 0 then
		UIUtil.SetIsVisible(self.BackpackEmpty, true)
	else
		UIUtil.SetIsVisible(self.BackpackEmpty, false)
	end

	self.ViewModel:UpdateMusicListInfo(MusicList) 
	self.CurMusicList = MusicList
	local MusicIndex = self:GetMusicIndex()
	self.RightMusicItemList:SetSelectedIndex(MusicIndex)
end

function MusicPlayerListPanelView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.UpdateUnLockInfo, self.InitMusicInfo)
end

function MusicPlayerListPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function MusicPlayerListPanelView:OnSelectChanged(Index, ItemData, ItemView)
	--FLOG_ERROR("MusicPlayerListPanelView Select INDEX = %d",Index)
	if not self.IsCanChose then
		return
	end
	if MusicPlayerMgr.RighListChoseMusicID == ItemData.MusicID then
		--搜索状态可以再进行选择，但不会重复播放
		if self.IsSearch then
			self.CurSerachChosedType = ItemData.Type
		end
		return
	end
	MusicPlayerMgr.RighListChoseIndex = Index
	MusicPlayerMgr.RighListChoseMusicID = ItemData.MusicID
	if self.IsSearch then
		self.CurSerachChosedType = ItemData.Type
	end
	MusicPlayerMgr.IsChoseRight = true
	EventMgr:SendEvent(EventID.RightListChose)
	EventMgr:SendEvent(EventID.UpdateMainPlayerState, ItemData.MusicID, true)
end

function MusicPlayerListPanelView:InitDropList(Index)
	self.TabList = self:GetTabList()
	self.MusicDropDownListNew:UpdateItems(self.TabList, Index)
end

function MusicPlayerListPanelView:InitMusicInfo()
	self.ViewModel:UpdateDropList()
	local Index = 1
	if MusicPlayerMgr.RighListChoseMusicID and MusicPlayerMgr.RightListChoseType then
		Index = MusicPlayerMgr.RightListChoseType
	end
	self:InitDropList(Index)
	local MusicList = self:GetMusicList(self.ViewModel.DropListInfo[Index].MusicInfo)
	self.MusicDropDownListNew:SetSelectedIndex(Index)
	if MusicList == nil then
		MusicList = {}
	end

	if #MusicList == 0 then
		UIUtil.SetIsVisible(self.BackpackEmpty, true)
	else
		UIUtil.SetIsVisible(self.TableViewSidebarList, true)
		UIUtil.SetIsVisible(self.BackpackEmpty, false)
		self.ViewModel:UpdateMusicListInfo(MusicList) 
		self.CurMusicList = MusicList
	end
	self.IsCanChose = true
	local MusicIndex = self:GetMusicIndex()
	self.RightMusicItemList:SetSelectedIndex(MusicIndex)
end

function MusicPlayerListPanelView:SetEmptyState()
end

function MusicPlayerListPanelView:ClearIndex()
	self.RightMusicItemList:SetSelectedIndex(0)
end

function MusicPlayerListPanelView:GetMusicIndex()
	local Index = nil
	local CurPlayingMusicID = MusicPlayerMgr.RighListChoseMusicID
	local List = self.CurMusicList
	
	if List == nil or CurPlayingMusicID == nil then
		return nil
	end

	for i = 1, #List do
		if CurPlayingMusicID == List[i].MusicID then
			Index = i

			return Index
		end
	end

	return Index
end

function MusicPlayerListPanelView:JumpToAtlas()
	local Data = {}
	Data.Index = self:GetJumpToIndex()
	UIViewMgr:ShowView(UIViewID.MusicAtlasMainView, Data)
end

function MusicPlayerListPanelView:GetJumpToIndex()
	local Index = 1
	if self.DropDownIndex ~= 1 then
		Index = self.DropDownIndex - 1
	end

	return Index
end

function MusicPlayerListPanelView:GetTabList()
	local NewList = {}
	for _, Info in ipairs(self.ViewModel.DropListInfo) do
		if Info.ShowType == 1 then
			if Info.MusicInfo and  #Info.MusicInfo > 0 then
				table.insert(NewList, Info)
			end
		else
			table.insert(NewList, Info)
		end
	end

	return NewList
end

function MusicPlayerListPanelView:GetMusicList(List)
	local MusicList = {}
	
	if not List then
		return MusicList
	end

	for _, Value in ipairs(List) do
		if Value and Value.MusicID then
			local MusicInfo = MusicPlayerMgr.AllAtlasList[Value.MusicID]
			if MusicInfo.OnOff == 1 then
				Value.Type = MusicInfo.PlayType
				table.insert(MusicList, Value)
			end
		end
	end

	return MusicList
end

function MusicPlayerListPanelView:GetTabIndexByType(Type)
	for Index, Value in ipairs(self.TabList) do
		if Value.Type == Type then
			return Index
		end
	end
end

return MusicPlayerListPanelView