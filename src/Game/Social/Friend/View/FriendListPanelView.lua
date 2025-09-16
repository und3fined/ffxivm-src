---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local FriendVM = require("Game/Social/Friend/FriendVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local OperationUtil = require("Utils/OperationUtil")
local FriendDefine = require("Game/Social/Friend/FriendDefine")

local LSTR = _G.LSTR
local ListState = FriendDefine.ListState

---@class FriendListPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoTo CommBtnXSView
---@field BtnGroupManage UFButton
---@field BtnSearch CommSearchBtnView
---@field CommEmpty CommBackpackEmptyView
---@field DropDownList CommDropDownListView
---@field ImgOnlineStatus UFImage
---@field PanelGroup UFCanvasPanel
---@field PanelSearch UFCanvasPanel
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field SearchInput CommSearchBarView
---@field TableViewList UTableView
---@field TextFavors UFTextBlock
---@field TextPlayerName URichTextBox
---@field TextSignature UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendListPanelView = LuaClass(UIView, true)

function FriendListPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoTo = nil
	--self.BtnGroupManage = nil
	--self.BtnSearch = nil
	--self.CommEmpty = nil
	--self.DropDownList = nil
	--self.ImgOnlineStatus = nil
	--self.PanelGroup = nil
	--self.PanelSearch = nil
	--self.PlayerHeadSlot = nil
	--self.SearchInput = nil
	--self.TableViewList = nil
	--self.TextFavors = nil
	--self.TextPlayerName = nil
	--self.TextSignature = nil
	--self.AnimIn = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendListPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoTo)
	self:AddSubView(self.BtnSearch)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.SearchInput)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendListPanelView:OnInit()
    self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	self.SearchInput:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchInput)

	self.Binders = {
		{ "ShowingFriendEntryVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterList) },
		{ "FriendListState", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedFriendListState) },
	}

end

function FriendListPanelView:OnDestroy()

end

function FriendListPanelView:OnShow()
	self:InitConstText()

	self.SearchInput:SetText("")
	UIUtil.ImageSetBrushFromAssetPath(self.PlayerHeadSlot.ImageIcon, "Texture2D'/Game/UI/Texture/Friend/UI_Friend_Img_Avatar_Confidant.UI_Friend_Img_Avatar_Confidant'", true)

	UIUtil.SetIsVisible(self.PanelSearch, false)
	UIUtil.SetIsVisible(self.PanelGroup, true)
	UIUtil.SetIsVisible(self.BtnGoTo, true, true)

	self:UpdateDropDownListItems()

	-- 请求好友列表
	FriendMgr:SendGetFriendListMsg()
end

function FriendListPanelView:OnHide()
	self.CurDropDownIdx = nil 
	FriendVM:ClearListPanelData()
end

function FriendListPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnSelectionChangedDropDownList)

	UIUtil.AddOnClickedEvent(self, self.BtnSearch.BtnSearch, self.OnClickedButtonSearch)
	UIUtil.AddOnClickedEvent(self, self.BtnGroupManage, self.OnClickedButtonGroupManage)
	UIUtil.AddOnClickedEvent(self, self.BtnGoTo.Button, self.OnClickedButtonBtnGoTo)
	UIUtil.AddOnClickedEvent(self, self.CommEmpty.Btn, self.OnClickedButtonCommEmptyBtn)
end

function FriendListPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FriendGroupInfoUpdate, self.OnUpdateDropDownList)
	self:RegisterGameEvent(EventID.FriendUpdate, self.OnUpdateDropDownList)
	self:RegisterGameEvent(EventID.FriendTransGroup, self.OnUpdateDropDownList)
	self:RegisterGameEvent(EventID.FriendAddBlack, self.OnUpdateDropDownList)
	self:RegisterGameEvent(EventID.FriendRemoveBlack, self.OnUpdateDropDownList)
	self:RegisterGameEvent(EventID.FriendPlayUpdateFriendListAnim, self.OnGameEventPlayUpdateListAnim)
end

function FriendListPanelView:OnRegisterBinder()
	self:RegisterBinders(FriendVM, self.Binders)
end

function FriendListPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.SearchInput:SetHintText(LSTR(30054)) -- "搜索好友"
	self.TextPlayerName:SetText(LSTR(30062))
	self.TextSignature:SetText(LSTR(30063))
	self.BtnGoTo.TextContent:SetText(LSTR(30064))
end

function FriendListPanelView:UpdateDropDownListItems( )
	local ListData = FriendVM:GetDropDownItems()
	self.DropDownListData = ListData

	self.DropDownList:UpdateItems(ListData, self.CurDropDownIdx or 1)
end

---@param SearchText string @回调的文本
function FriendListPanelView:OnSearchTextCommitted(SearchText)
	if not string.isnilorempty(SearchText) then
		FriendVM:FilterFriendByKeyword(SearchText)
	end
end

function FriendListPanelView:OnClickCancelSearchInput()
	self.SearchInput:SetText("")
	FriendVM:ClearFilterData()

	-- 重置回初始状态
	self.DropDownList:SetDropDownIndex(1)

	UIUtil.SetIsVisible(self.PanelSearch, false)
	UIUtil.SetIsVisible(self.PanelGroup, true)
end

function FriendListPanelView:OnValueChangedFriendListState(NewValue)
	if NewValue == ListState.Normal then
		UIUtil.SetIsVisible(self.CommEmpty, false)
		return
	end

	local CommEmpty = self.CommEmpty 
	UIUtil.SetIsVisible(CommEmpty, true)

	local Tips = "" 
	local IsShowEmptyBtn = false
	if NewValue == ListState.NoFriend then
		Tips = LSTR(30065) -- "暂时还没有好友哦！快去添加其他光之战士吧库啵！"
		IsShowEmptyBtn = true
		CommEmpty:SetBtnText(LSTR(30066)) -- "添加好友"

	elseif NewValue == ListState.ListEmpty then
		Tips = LSTR(30052) -- "列表是空的"

	elseif NewValue == ListState.SearchEmpty then
		Tips = LSTR(30053) -- "暂无搜索结果"
	end

	CommEmpty:SetTipsContent(Tips)
	CommEmpty:ShowPanelBtn(IsShowEmptyBtn)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendListPanelView:OnSelectionChangedDropDownList( Index )
	if nil == self.DropDownListData or nil == Index or self.CurDropDownIdx == Index then
		return
	end

	local GroupID = (self.DropDownListData[Index] or {}).GroupID
	if GroupID then
		-- 初次，OnShow函数里面会拉取一次好友信息之后，会刷新列表
		FriendVM:FilterFriendVMByGroupID(GroupID, nil == self.CurDropDownIdx)
		self.CurDropDownIdx = Index
	end
end

function FriendListPanelView:OnClickedButtonSearch()
	FriendVM.FriendListEmptyPanelVisible = false

	UIUtil.SetIsVisible(self.PanelGroup, false)
	UIUtil.SetIsVisible(self.PanelSearch, true)
end

function FriendListPanelView:OnClickedButtonGroupManage()
	UIViewMgr:ShowView(UIViewID.FriendGroupManageWin) 
end

function FriendListPanelView:OnClickedButtonBtnGoTo()
	OperationUtil.OpenGameBot("")
end

function FriendListPanelView:OnClickedButtonCommEmptyBtn()
	local ParentView = self.ParentView
	if nil == ParentView then
		return
	end

	ParentView:SwitchToFindFriendTab()
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function FriendListPanelView:OnUpdateDropDownList( )
	self:UpdateDropDownListItems()
end

function FriendListPanelView:OnGameEventPlayUpdateListAnim()
    self:PlayAnimation(self.AnimUpdateList)
end

return FriendListPanelView