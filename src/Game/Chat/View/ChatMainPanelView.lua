---
--- Author: anypkvcai
--- DateTime: 2021-11-03 14:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")
local ChatVM = require("Game/Chat/ChatVM")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require("Protocol/ProtoCS")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local RichTextUtil = require("Utils/RichTextUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ItemDefine = require("Game/Item/ItemDefine")
local ChatMgr = require("Game/Chat/ChatMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local VoiceMgr = require("Game/Voice/VoiceMgr")
local MajorUtil = require("Utils/MajorUtil")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local ChatSetting = require("Game/Chat/ChatSetting")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

local ChatCategory = ChatDefine.ChatCategory
local ChatChannel = ChatDefine.ChatChannel
local PrivateFilterTypes = ChatDefine.PrivateFilterTypes
local OpenSource = ChatDefine.OpenSource
local PARAM_TYPE_DEFINE = ProtoCS.PARAM_TYPE_DEFINE
local LSTR = _G.LSTR
local FVector2D = _G.UE.FVector2D
local ChatMsgType = ChatDefine.ChatMsgType

---@class ChatMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyPanel ChatArmyPanelView
---@field BtnAddFriend UFButton
---@field BtnCopyMsg UFButton
---@field BtnDeleteChatRecord UFButton
---@field BtnExit UFButton
---@field BtnGoTo UFButton
---@field BtnGoToRecruit CommBtnMView
---@field BtnGoToTeam CommBtnMView
---@field BtnGotoFriends CommBtnSView
---@field BtnMaskMsgTips UFButton
---@field BtnMore UFButton
---@field BtnMoreTipsMask UFButton
---@field BtnNewTips UFButton
---@field BtnPrivateSearch CommSearchBtnView
---@field BtnReportMsg UFButton
---@field BtnSendRecruit CommBtnMView
---@field BtnSetting UFButton
---@field ChatBarPanel ChatBarPanelView
---@field ChatWin UFCanvasPanel
---@field ComEmptyNoMsgTips CommBackpackEmptyView
---@field ComEmptyPrivate CommBackpackEmptyView
---@field ComRedDotPrivate CommonRedDotView
---@field CommInforBtn CommInforBtnView
---@field CommSidebarTabFrame CommSidebarTabFrameView
---@field CommTabsCategoryL CommTabsView
---@field CommonRedDotSetTips CommonRedDotView
---@field DownListCompSpeak CommDropDownListView
---@field DownListSystemMsgFilter CommDropDownListView
---@field FButton_Empty UFButton
---@field FHorTitlePrivate UFHorizontalBox
---@field FHorTitlePublic UFHorizontalBox
---@field FImgGoTo UFImage
---@field ImgOnlineStatus UFImage
---@field MakeFriendsPanel ChatMakeFriendView
---@field MsgFunctionTips UFCanvasPanel
---@field NewbiePanel ChatNewbiePanelView
---@field PanelBtnAdd UFCanvasPanel
---@field PanelBtnExit USizeBox
---@field PanelCategorySwitchL UFCanvasPanel
---@field PanelCategorySwitchS UFCanvasPanel
---@field PanelChannel UFCanvasPanel
---@field PanelDownListSpeak UFCanvasPanel
---@field PanelEmptyPrivate UFCanvasPanel
---@field PanelGoTo USizeBox
---@field PanelMore UFCanvasPanel
---@field PanelMoreTips UFCanvasPanel
---@field PanelNewTips UFCanvasPanel
---@field PanelRedDotPrivate UFCanvasPanel
---@field PioneerPanel ChatPioneerPanelView
---@field PrivateChannelPanel UFCanvasPanel
---@field PrivateDownList CommDropDownListView
---@field PrivateFilterPanel UFCanvasPanel
---@field PrivateSearchBar CommSearchBarView
---@field PrivateTopPanel UFCanvasPanel
---@field PublicChannelPanel UFCanvasPanel
---@field PublicInfoPanel UFCanvasPanel
---@field RecruitPanel UFCanvasPanel
---@field SizeBoxOnline USizeBox
---@field SizeBoxServer USizeBox
---@field SystemPanel UFCanvasPanel
---@field TableViewChannelPrivate UTableView
---@field TableViewChannelPublic UTableView
---@field TableViewChatMsg UTableView
---@field TeamPanel UFCanvasPanel
---@field TextAddFriend UFTextBlock
---@field TextDeleteChatRecord UFTextBlock
---@field TextNewTips UFTextBlock
---@field TextSubTitlePublic UFTextBlock
---@field TextSystemTips UFTextBlock
---@field TextTitlePrivate UFTextBlock
---@field TextTitlePublic UFTextBlock
---@field ToggleBtnCategoryS UToggleButton
---@field ToggleBtnWide UToggleButton
---@field TopMemu UFCanvasPanel
---@field AnimChatToNarrow UWidgetAnimation
---@field AnimChatToWide UWidgetAnimation
---@field AnimChatWinUpdate UWidgetAnimation
---@field AnimMsgFunctionTipsIn UWidgetAnimation
---@field AnimNewTipsShow UWidgetAnimation
---@field AnimPannelFriendMoreShow UWidgetAnimation
---@field AnimPrivateChannelChange UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMainPanelView = LuaClass(UIView, true)

function ChatMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyPanel = nil
	--self.BtnAddFriend = nil
	--self.BtnCopyMsg = nil
	--self.BtnDeleteChatRecord = nil
	--self.BtnExit = nil
	--self.BtnGoTo = nil
	--self.BtnGoToRecruit = nil
	--self.BtnGoToTeam = nil
	--self.BtnGotoFriends = nil
	--self.BtnMaskMsgTips = nil
	--self.BtnMore = nil
	--self.BtnMoreTipsMask = nil
	--self.BtnNewTips = nil
	--self.BtnPrivateSearch = nil
	--self.BtnReportMsg = nil
	--self.BtnSendRecruit = nil
	--self.BtnSetting = nil
	--self.ChatBarPanel = nil
	--self.ChatWin = nil
	--self.ComEmptyNoMsgTips = nil
	--self.ComEmptyPrivate = nil
	--self.ComRedDotPrivate = nil
	--self.CommInforBtn = nil
	--self.CommSidebarTabFrame = nil
	--self.CommTabsCategoryL = nil
	--self.CommonRedDotSetTips = nil
	--self.DownListCompSpeak = nil
	--self.DownListSystemMsgFilter = nil
	--self.FButton_Empty = nil
	--self.FHorTitlePrivate = nil
	--self.FHorTitlePublic = nil
	--self.FImgGoTo = nil
	--self.ImgOnlineStatus = nil
	--self.MakeFriendsPanel = nil
	--self.MsgFunctionTips = nil
	--self.NewbiePanel = nil
	--self.PanelBtnAdd = nil
	--self.PanelBtnExit = nil
	--self.PanelCategorySwitchL = nil
	--self.PanelCategorySwitchS = nil
	--self.PanelChannel = nil
	--self.PanelDownListSpeak = nil
	--self.PanelEmptyPrivate = nil
	--self.PanelGoTo = nil
	--self.PanelMore = nil
	--self.PanelMoreTips = nil
	--self.PanelNewTips = nil
	--self.PanelRedDotPrivate = nil
	--self.PioneerPanel = nil
	--self.PrivateChannelPanel = nil
	--self.PrivateDownList = nil
	--self.PrivateFilterPanel = nil
	--self.PrivateSearchBar = nil
	--self.PrivateTopPanel = nil
	--self.PublicChannelPanel = nil
	--self.PublicInfoPanel = nil
	--self.RecruitPanel = nil
	--self.SizeBoxOnline = nil
	--self.SizeBoxServer = nil
	--self.SystemPanel = nil
	--self.TableViewChannelPrivate = nil
	--self.TableViewChannelPublic = nil
	--self.TableViewChatMsg = nil
	--self.TeamPanel = nil
	--self.TextAddFriend = nil
	--self.TextDeleteChatRecord = nil
	--self.TextNewTips = nil
	--self.TextSubTitlePublic = nil
	--self.TextSystemTips = nil
	--self.TextTitlePrivate = nil
	--self.TextTitlePublic = nil
	--self.ToggleBtnCategoryS = nil
	--self.ToggleBtnWide = nil
	--self.TopMemu = nil
	--self.AnimChatToNarrow = nil
	--self.AnimChatToWide = nil
	--self.AnimChatWinUpdate = nil
	--self.AnimMsgFunctionTipsIn = nil
	--self.AnimNewTipsShow = nil
	--self.AnimPannelFriendMoreShow = nil
	--self.AnimPrivateChannelChange = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyPanel)
	self:AddSubView(self.BtnGoToRecruit)
	self:AddSubView(self.BtnGoToTeam)
	self:AddSubView(self.BtnGotoFriends)
	self:AddSubView(self.BtnPrivateSearch)
	self:AddSubView(self.BtnSendRecruit)
	self:AddSubView(self.ChatBarPanel)
	self:AddSubView(self.ComEmptyNoMsgTips)
	self:AddSubView(self.ComEmptyPrivate)
	self:AddSubView(self.ComRedDotPrivate)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommSidebarTabFrame)
	self:AddSubView(self.CommTabsCategoryL)
	self:AddSubView(self.CommonRedDotSetTips)
	self:AddSubView(self.DownListCompSpeak)
	self:AddSubView(self.DownListSystemMsgFilter)
	self:AddSubView(self.MakeFriendsPanel)
	self:AddSubView(self.NewbiePanel)
	self:AddSubView(self.PioneerPanel)
	self:AddSubView(self.PrivateDownList)
	self:AddSubView(self.PrivateSearchBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMainPanelView:OnInit()
	--- 尝试清除公共频道离线小红点提示
	ChatMgr:TryCleanPublicOfflineRedDotTips()

	self.AdapterChatMsg = UIAdapterTableView.CreateAdapter(self, self.TableViewChatMsg)
	self.TableAdapterChannelPublic = UIAdapterTableView.CreateAdapter(self, self.TableViewChannelPublic, self.OnSelectChangedPublicItem)
	self.TableAdapterChannelPrivate = UIAdapterTableView.CreateAdapter(self, self.TableViewChannelPrivate, self.OnSelectChangedPrivateItem)

	self.PrivateSearchBar:SetCallback(self, nil, self.OnSearchInputFinish, self.OnClickCancelSearchBar)
	self.PrivateSearchBar:SetHintText("")

	self.TempMargin = _G.UE.FMargin()
	self.ChatMsgSrcOffsets = UIUtil.CanvasSlotGetOffsets(self.TableViewChatMsg)

	self.CommTabsCategoryL.DefaultSelectByShow = false
	self.CommTabsCategoryL:SetCallBack(self, self.OnSelectionChangedTabsCategoryL)

	self.Binders = {
		{ "ChatMsgItemVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterChatMsg) },
		{ "ChatMsgItemVMList", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedChatMsgList) },
		{ "MsgScroolToBottom", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMsgScroolToBottom) },
		{ "NewMsgTipsVisible", 		UIBinderSetIsVisible.New(self, self.PanelNewTips) },
		{ "NoMsgTipsVisible", 		UIBinderSetIsVisible.New(self, self.ComEmptyNoMsgTips) },
		{ "NewMsgTipsCount", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedNewMsgTipsCount) },
		{ "NewMsgTipsText", 		UIBinderSetText.New(self, self.TextNewTips) },
		{ "TitleName", 				UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedTitleName) },
		{ "SubTitleName", 			UIBinderSetText.New(self, self.TextSubTitlePublic) },
		{ "ExitVisible", 			UIBinderSetIsVisible.New(self, self.PanelBtnExit) },
		{ "GoToIcon", 				UIBinderSetImageBrush.New(self, self.FImgGoTo)},
		{ "GoToVisible", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedGoToVisible) },
		{ "HelpInfoID", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHelpInfoID) },
		{ "IsWideMainWin", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsWideMainWin) },
		{ "DiffServerIconVisible", 	UIBinderSetIsVisible.New(self, self.SizeBoxServer) },

		{ "UpdateMsgTableViewListPos", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedUpateMsgTableViewListPos) },

		{ "OnlineStatusVisible",	UIBinderSetIsVisible.New(self, self.SizeBoxOnline) },
		{ "OnlineStatusIcon",		UIBinderSetBrushFromAssetPath.New(self, self.ImgOnlineStatus) },
		{ "IsNoShowPrivateChatItem",UIBinderSetIsVisible.New(self, self.PanelEmptyPrivate) },

		{ "IsPublicChat", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsPublicChat) },
		{ "CompSpeakChannelList", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCompSpeakChannelList) },
		{ "MakeFriendPanelVisible", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMakeFriendPanelVisible) },

		{ "ShowingPrivateItemVMList", 	UIBinderUpdateBindableList.New(self, self.TableAdapterChannelPrivate) },

		{ "PublicItemVMList", 		UIBinderUpdateBindableList.New(self, self.TableAdapterChannelPublic) },
		{ "CurClickedMsgItem", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurClickedMsgItem) },

		{ "CurSelectedChannelItem", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurSelectedChannelItem) },
		{ "ChatBarWidgetVisible", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedChatBarWidgetVisible) },
	}

	self.CommSidebarTabFrame.BtnClose:SetCallback(self, self.HideViewByBtnClose)

	self.ComEmptyPrivate:SetTipsContent(LSTR(50133)) -- "未搜索到任何聊天记录"
	self.ComEmptyNoMsgTips:SetTipsContent(LSTR(50089)) -- "暂无消息"
	self.BtnGotoFriends:SetText(LSTR(50135)) -- "前往好友"
	self.BtnGoToTeam:SetText(LSTR(50062)) -- "前往组队"
end

--- 通过关闭按钮关闭的不会隐藏传入的界面ID的界面
function ChatMainPanelView:HideViewByBtnClose()
	self.IsHideCurShowView = false
	self:Hide()
end

function ChatMainPanelView:OnDestroy()

end

function ChatMainPanelView:OnShow()
	ChatVM.IsChatMainPanelVisible = true

	-- 清除所有弹幕消息
	_G.DanmakuMgr:ClearAllDanmakuMsg()

	-- 清除侧边栏
	ChatVM:ClearSidebarItem(true)

	-- 设置小红点
	ChatVM:UpdateSetTipsRedDot(ChatVM.IsShowSetTips)

	local PublicSelIdx, PrivateSelIdx = self:GetTableAdapterIdx()
	self.PublicChannelIdx = PublicSelIdx 
	self.PrivateChannelIdx = PrivateSelIdx 

	if PublicSelIdx then
		self.TableAdapterChannelPublic:SetSelectedIndex(PublicSelIdx)
	end

	if PrivateSelIdx then
		self.TableAdapterChannelPrivate:SetSelectedIndex(PrivateSelIdx)
	end

	self:ResetPrivateNodes()
	self:SetMsgFunctionTipsActive(false)
	self:UpdateToggleGroupCategory()
	self.PrivateDownList:UpdateItems(PrivateFilterTypes, 1)

	if self.IsOpenEmptyClick then
		UIUtil.SetIsVisible(self.FButton_Empty, false)
	else
		UIUtil.SetIsVisible(self.FButton_Empty, true,true)
	end

	self.IsHideCurShowView = true

	local IsWide = ChatVM.IsWideMainWin
	self.ToggleBtnWide:SetChecked(IsWide)
	self:SetWinWideOrNarrow(IsWide)

	-- 私聊小红点
	local IsOpen = ChatSetting.IsOpenPrivateRedDotTip()
	self:UpdateRedDotPanelVisible(IsOpen)

	self.AdapterChatMsg:SetItemChangedCallback(self.OnChatMsgItemChanged)

	_G.ObjectMgr:CollectGarbage(false)
end

function ChatMainPanelView:OnHide()
	self.IsHideCurShowView = false 
	self.FilterSystemMsging = nil 

	ChatVM.IsChatMainPanelVisible = false

	self.PublicChannelIdx = nil
	self.PrivateChannelIdx = nil
	self.PrivateSearchBar:SetText("")
	ChatVM:ClearFilterPrivateItems()

	self:ResetPrivateNodes()

	self.TableAdapterChannelPublic:CancelSelected()
	self.TableAdapterChannelPrivate:CancelSelected()

	self.TableAdapterChannelPublic:ReleaseAllItem(true)
	self.TableAdapterChannelPrivate:ReleaseAllItem(true)
	self.AdapterChatMsg:ReleaseAllItem(true)
	self.AdapterChatMsg:SetItemChangedCallback()

	VoiceMgr:StopPlayFiles()
	VoiceMgr:StopTranslatingVoiceFile()

	---好友刷新最近聊天玩家信息
	_G.FriendMgr:RefreshRecentChatInfo()

	if self.IsHideCurShowView then
		self:HideCurShowPanel()
	else
		self.IsHideCurShowView = true
	end

	self:OnClickBtnMoreTipsMask()
	ChatMgr:CheckAndSaveUnreadPrivateChatMsg()
end

function ChatMainPanelView:UpdateView(Params)
	self.Source = Params.Source
	self.CurOpenViewID = Params.CurOpenViewID
	self.IsOpenEmptyClick = self.Params.IsOpenEmptyClick
	if self.IsOpenEmptyClick then
		UIUtil.SetIsVisible(self.FButton_Empty, false)
	else
		UIUtil.SetIsVisible(self.FButton_Empty, true,true)
	end

	self:OnValueChangedGoToVisible(ChatVM.GoToVisible)
	self:UpdateToggleGroupCategory()
end

function ChatMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnWide, self.OnStateChangedToggleBtnWide)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnCategoryS, self.OnStateChangedToggleBtnCategoryS)
	UIUtil.AddOnScrolledToEndEvent(self, self.TableViewChatMsg, self.OnTaleViewScrolledToEnd)

	UIUtil.AddOnSelectionChangedEvent(self, self.PrivateDownList, self.OnSelectionChangedDropDownList)
	UIUtil.AddOnSelectionChangedEvent(self, self.DownListCompSpeak, self.OnSelectionChangedCompSpeak)
	UIUtil.AddOnSelectionChangedEvent(self, self.DownListSystemMsgFilter, self.OnSelectionChangedSystemMsgFilter)

	UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnClickButtonExit)
	UIUtil.AddOnClickedEvent(self, self.BtnGoTo, self.OnClickButtonGoTo)
	UIUtil.AddOnClickedEvent(self, self.BtnNewTips, self.OnClickButtonNewTips)
	UIUtil.AddOnClickedEvent(self, self.BtnGotoFriends, self.OnClickButtonFriends)
	UIUtil.AddOnClickedEvent(self, self.BtnGoToTeam, self.OnClickButtonGoToTeam)

	-- 消息功能弹窗
	UIUtil.AddOnClickedEvent(self, self.BtnCopyMsg, self.OnClickCopyMsg)
	UIUtil.AddOnClickedEvent(self, self.BtnReportMsg, self.OnClickReportMsg)
	UIUtil.AddOnClickedEvent(self, self.BtnMaskMsgTips, self.OnClickMaskMsgTips)

	UIUtil.AddOnClickedEvent(self, self.BtnSetting, self.OnClickSetting)
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickBtnMore)
	UIUtil.AddOnClickedEvent(self, self.BtnMoreTipsMask, self.OnClickBtnMoreTipsMask)
	UIUtil.AddOnClickedEvent(self, self.BtnDeleteChatRecord, self.OnClickDeleteChatRecord)
	UIUtil.AddOnClickedEvent(self, self.BtnPrivateSearch.BtnSearch, self.OnClickedButtonSearch)
	UIUtil.AddOnClickedEvent(self, self.BtnAddFriend, self.OnClickedButtonAddFriend)

	UIUtil.AddOnClickedEvent(self, self.BtnGoToRecruit, self.OnClickedButtonGoToRecruit)
	UIUtil.AddOnClickedEvent(self, self.BtnSendRecruit, self.OnClickedButtonSendRecruit)

	---按策划需求，点击空白处关闭界面
	UIUtil.AddOnClickedEvent(self, self.FButton_Empty, self.HideViewByBtnClose)
end

function ChatMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ChatMsgClickHyperLink, 			self.OnEventMsgClickHyperLink)
    self:RegisterGameEvent(EventID.ChatQueryRoleItemInfo, 			self.OnEventQueryRoleItemInfo)
    self:RegisterGameEvent(EventID.ChatOpenPrivateRedDotTipChanged, self.OnEvenOpenPrivateRedDotTipChanged)
    self:RegisterGameEvent(EventID.TeamRecruitStateChanged, 		self.OnEventTeamRecruitStateChanged)
    self:RegisterGameEvent(EventID.ChatIsJoinNewbieChannelChanged, 	self.OnEventIsJoinNewbieChannelChanged)
end

function ChatMainPanelView:OnRegisterBinder()
	self.Source = self.Params.Source
	self.CurOpenViewID = self.Params.CurOpenViewID
	self.IsOpenEmptyClick = self.Params.IsOpenEmptyClick
	self:RegisterBinders(ChatVM, self.Binders)
end

function ChatMainPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 10, 0)
end

function ChatMainPanelView:OnTimer( )
	--私聊角色信息更新
	if ChatVM:IsStartPrivateChatRoleInfoUpdate() then
		self:UpdatePrivateChatRoleInfos()
	end
end

function ChatMainPanelView:ReleaseMsgItems( )
	self.AdapterChatMsg:ReleaseAllItem(true)
	_G.ObjectMgr:CollectGarbage(false)
end

function ChatMainPanelView:GetTableAdapterIdx( )
	local PublicSelIdx = nil 
	local PrivateSelIdx = nil 

	local Channel = ChatVM.CurChannel
	local ChannelID = ChatVM.CurChannelID
	if Channel == ChatChannel.Person then
		local ItemVMList = ChatVM.ShowingPrivateItemVMList
		if ItemVMList then
			local _, i = ItemVMList:Find(function(e) return e.Channel == Channel and e.ChannelID == ChannelID end)
			if i then
				PrivateSelIdx = i
			end
		end
	else
		local ItemVMList = ChatVM.PublicItemVMList
		if ItemVMList then
			if Channel ~= ChatChannel.Group then
				ChannelID = nil
			end

			local _, i = ItemVMList:Find(function(e) return e.Channel == Channel and (nil == ChannelID or e.ChannelID == ChannelID) end)
			if i then
				PublicSelIdx = i
			end
		end
	end

	return PublicSelIdx, PrivateSelIdx
end

function ChatMainPanelView:UpdatePrivateChatRoleInfos( )
	ChatVM:UpdatePrivateChatRoleInfos()
end

function ChatMainPanelView:ResetPrivateNodes( )
	self.PrivateDownList:FoldDropDown()

	UIUtil.SetIsVisible(self.PrivateSearchBar, false)
	UIUtil.SetIsVisible(self.PrivateFilterPanel, true)
	UIUtil.SetIsVisible(self.TableViewChannelPrivate, true)
end

function ChatMainPanelView:UpdateRedDotPanelVisible(IsOpen)
	UIUtil.SetIsVisible(self.PanelRedDotPrivate, IsOpen)
end

function ChatMainPanelView:UpdateCompChannelSpeakInfo(CurChannel, BarVisible)
	if BarVisible and CurChannel == ChatChannel.Comprehensive then
		UIUtil.SetIsVisible(self.PanelDownListSpeak, true)

		local DownListSpeak = self.DownListCompSpeak
		DownListSpeak:SetIsUpward(true)

		local Idx = 1
		local DataList = {}
		local SpeakChannel = ChatVM.CurCompSpeakChannel
		local SpeakChannelID = ChatVM.CurCompSpeakChannelID

		if DownListSpeak:IsEmpty() or self.IsRebuildSpeakList then
			self.IsRebuildSpeakList = false 

			for k, v in ipairs(ChatVM.CompSpeakChannelList or {}) do
				if SpeakChannel == v.Channel and SpeakChannelID == v.ChannelID then
					Idx = k
				end

				table.insert(DataList, {Name = v.Name})
			end

			DownListSpeak:UpdateItems(DataList, Idx)
		end

	else
		UIUtil.SetIsVisible(self.PanelDownListSpeak, false)
	end

end

function ChatMainPanelView:SetWinWideOrNarrow(IsWide)
	if IsWide then
		self:PlayAnimation(self.AnimChatToWide)
		self.CommSidebarTabFrame:PlayAnimationChatWide()
	else
		self:PlayAnimation(self.AnimChatToNarrow)
		self.CommSidebarTabFrame:PlayAnimationChatNarrow()
	end

	ChatVM.IsWideMainWin = IsWide
end

function ChatMainPanelView:UpdateSystemChannelInfo(CurChannel)
	if CurChannel == ChatChannel.System then 
		UIUtil.SetIsVisible(self.SystemPanel, true)

		local DownListSysFilter = self.DownListSystemMsgFilter
		local CurSysType = ChatVM.CurSysMsgType

		if DownListSysFilter:IsEmpty() then
			self.TextSystemTips:SetText(LSTR(50063)) -- "选择查看内容"

			local Idx = 1
			local DataList = {}

			for k, v in ipairs(ChatDefine.SystemMsgFilterTypes) do
				local SysType = v.SysType
				if CurSysType == SysType then
					Idx = k
				end

				table.insert(DataList, {ID = SysType, Name = LSTR(v.NameUkey)})
			end

			DownListSysFilter:UpdateItems(DataList, Idx or 1)

		else
			local Idx = DownListSysFilter:GetIndexByPredicate(function(e) return e.ID == CurSysType end)
			DownListSysFilter:SetDropDownIndex(Idx or 1)
		end

	else
		UIUtil.SetIsVisible(self.SystemPanel, false)
	end
end

function ChatMainPanelView:UpdateRecruitInfo(CurChannel)
	if CurChannel ~= ChatChannel.Recruit then
		UIUtil.SetIsVisible(self.RecruitPanel, false)
		return
	end

	if not self.IsHasSetRecruitConstText then
		self.BtnGoToRecruit:SetButtonText(LSTR(50170)) -- "前往招募"
		self.BtnSendRecruit:SetButtonText(LSTR(50171)) -- "发送招募"

		self.IsHasSetRecruitConstText = false
	end

	local IsRecruiting = _G.TeamRecruitMgr:IsRecruiting()
	UIUtil.SetIsVisible(self.BtnSendRecruit, IsRecruiting, true)
	UIUtil.SetIsVisible(self.RecruitPanel, true)
end

function ChatMainPanelView:UpdatePublicChannelPanels()
	local BarWidgetVisible = ChatVM.ChatBarWidgetVisible
	local CurChannel = ChatVM.CurChannel
	if BarWidgetVisible == self.CurBarWidgetVisible and CurChannel == self.CurChannel then
		return
	end

	local IsShrink = BarWidgetVisible

	-- 综合频道发言信息
	self:UpdateCompChannelSpeakInfo(CurChannel, BarWidgetVisible)

	-- 新人频道
	local IsShowNewbiePanel = not BarWidgetVisible and CurChannel == ChatChannel.Newbie
	UIUtil.SetIsVisible(self.NewbiePanel, IsShowNewbiePanel)
	IsShrink = IsShrink or IsShowNewbiePanel

	-- 部队宣传
	local IsShowArmyPanel = not BarWidgetVisible and CurChannel == ChatChannel.Army
	UIUtil.SetIsVisible(self.ArmyPanel, IsShowArmyPanel)
	IsShrink = IsShrink or IsShowArmyPanel

	-- 系统
	self:UpdateSystemChannelInfo(CurChannel)

	-- 组队
	local IsShowTeamPanel = not BarWidgetVisible and (CurChannel == ChatChannel.Team or CurChannel == ChatChannel.SceneTeam)
	UIUtil.SetIsVisible(self.TeamPanel, IsShowTeamPanel)
	IsShrink = IsShrink or IsShowTeamPanel

	-- 先锋频道
	local IsShowPioneerPanel = not BarWidgetVisible and CurChannel == ChatChannel.Pioneer
	UIUtil.SetIsVisible(self.PioneerPanel, IsShowPioneerPanel)
	IsShrink = IsShrink or IsShowPioneerPanel

	-- 招募频道
	self:UpdateRecruitInfo(CurChannel)

	self.CurBarWidgetVisible = BarWidgetVisible
	self.CurChannel = CurChannel

	local SrcOffsets = self.ChatMsgSrcOffsets
	if SrcOffsets then
		IsShrink =  IsShrink or (CurChannel == ChatChannel.System or CurChannel == ChatChannel.Recruit)
		local Margin = self.TempMargin
		Margin.Left = SrcOffsets.Left
		Margin.Top = SrcOffsets.Top
		Margin.Right = SrcOffsets.Right
		Margin.Bottom = IsShrink and SrcOffsets.Bottom or 20 

		UIUtil.CanvasSlotSetOffsets(self.TableViewChatMsg, Margin)
	end
end

function ChatMainPanelView:OnSelectChangedPublicItem(Index, ItemData, ItemView)
	if ItemData ~= nil then
		local CurIdx = self.PublicChannelIdx
		if CurIdx and CurIdx ~= Index then
			self:ReleaseMsgItems()
		end

		self.PublicChannelIdx = Index

		local Channel = ItemData.Channel
		local ChannelID = ItemData.ChannelID
		if nil == ChannelID then
			local ChannelVM = ChatVM:FindChannelVM(Channel)
			if ChannelVM then
				ChannelID = ChannelVM:GetChannelID()
			end
		end

		ChatVM:SetChannel(Channel, ChannelID)

		if Index then
			self.TableAdapterChannelPublic:ScrollIndexIntoView(Index)
		end
	end

	---更新公聊的一些宣传面板信息
	self:UpdatePublicChannelPanels()
end

function ChatMainPanelView:OnSelectChangedPrivateItem(Index, ItemData, ItemView)
	if nil == ItemData or nil == Index then
		return
	end

	local CurIdx = self.PrivateChannelIdx
	if CurIdx and CurIdx ~= Index then
		self:ReleaseMsgItems()
	end

	self.PrivateChannelIdx = Index

	ChatVM:SetChannel(ItemData.Channel, ItemData.ChannelID)

	if Index then
		self.TableAdapterChannelPrivate:ScrollIndexIntoView(Index)
	end
end

function ChatMainPanelView:OnValueChangedChatMsgList()
	self.TableViewChatMsg:ScrollToBottom()
end

function ChatMainPanelView:OnValueChangedMsgScroolToBottom(NewValue)
	if NewValue then
		self.TableViewChatMsg:ScrollToBottom()
		ChatVM.MsgScroolToBottom = false
	end
end

function ChatMainPanelView:OnValueChangedNewMsgTipsCount(NewValue)
	if NewValue > 0 then
		if self.AdapterChatMsg:IsAtEndOfList() then
			ChatVM:ClearNewMsgTips()

			self.TableViewChatMsg:ScrollToBottom()
		else
			ChatVM:UpdateNewMsgTips()
		end
	else
		self.TableViewChatMsg:ScrollToBottom()
	end
end

function ChatMainPanelView:UpdateMorePanelVisible()
	if ChatVM.MakeFriendPanelVisible or string.isnilorempty(ChatVM.TitleName) or ChatVM.IsPublicChat then
		UIUtil.SetIsVisible(self.PanelMore, false)
	else
		UIUtil.SetIsVisible(self.PanelMore, true)
		self:PlayAnimation(self.AnimPannelFriendMoreShow)
	end
end

function ChatMainPanelView:OnValueChangedTitleName(NewValue)
	if ChatVM.IsPublicChat then
		self.TextTitlePublic:SetText(NewValue)

	else
		self.TextTitlePrivate:SetText(NewValue)
	end

	self:UpdateMorePanelVisible()
end


function ChatMainPanelView:OnValueChangedGoToVisible(NewValue)
	local CurChannel = ChatVM.CurChannel
	if NewValue then
		local Source = self.Source
		if Source == OpenSource.ArmyWin and CurChannel == ChatChannel.Army then 
			ChatVM:UpdateGoTo(false)
			return
		end

		if Source == OpenSource.LinkShellWin and CurChannel == ChatChannel.Group then 
			ChatVM:UpdateGoTo(false)
			return
		end
	end

	UIUtil.SetIsVisible(self.PanelGoTo, NewValue, true)
end

function ChatMainPanelView:OnValueChangedHelpInfoID(NewValue)
	if nil == NewValue or NewValue <= 0 then
		UIUtil.SetIsVisible(self.CommInforBtn, false)
		return
	end

	UIUtil.SetIsVisible(self.CommInforBtn, true)
	self.CommInforBtn:SetHelpInfoID(NewValue)
end

function ChatMainPanelView:OnValueChangedIsWideMainWin(NewValue)
	UIUtil.SetIsVisible(self.PrivateTopPanel, NewValue)
	UIUtil.SetIsVisible(self.PanelCategorySwitchL, NewValue)
	UIUtil.SetIsVisible(self.PanelCategorySwitchS, not NewValue)
end

function ChatMainPanelView:OnValueChangedUpateMsgTableViewListPos(NewValue)
	if not NewValue then
		return
	end

	if self.AdapterChatMsg:IsAtEndOfList() then
		self.TableViewChatMsg:ScrollToBottom()
	end

	ChatVM.UpdateMsgTableViewListPos = false 
end

function ChatMainPanelView:SetMsgFunctionTipsActive(b)
	UIUtil.SetIsVisible(self.MsgFunctionTips, b)

	if b then
		--播放动效
		self:PlayAnimation(self.AnimMsgFunctionTipsIn)

	else
		self.CurClickedMsgItem = nil 
		ChatVM:SetCurClickedMsgItem(nil)
	end
end

function ChatMainPanelView:OnValueChangedIsPublicChat(NewValue)
	UIUtil.SetIsVisible(self.FHorTitlePublic, NewValue)
	UIUtil.SetIsVisible(self.PublicChannelPanel, NewValue)
	UIUtil.SetIsVisible(self.PublicInfoPanel, NewValue)

	local IsPrivate = not NewValue
	UIUtil.SetIsVisible(self.FHorTitlePrivate, IsPrivate)
	UIUtil.SetIsVisible(self.PrivateChannelPanel, IsPrivate)

	self:UpdateMorePanelVisible()
end

function ChatMainPanelView:OnValueChangedCompSpeakChannelList()
	if not self.IsShowView then
		return
	end

	self.IsRebuildSpeakList = true
	self:UpdateCompChannelSpeakInfo(ChatVM.CurChannel, ChatVM.ChatBarWidgetVisible)
end

function ChatMainPanelView:OnValueChangedMakeFriendPanelVisible(NewValue)
	UIUtil.SetIsVisible(self.MakeFriendsPanel, NewValue)

	local b = not NewValue
	UIUtil.SetIsVisible(self.ChatWin, b)
	UIUtil.SetIsVisible(self.PanelChannel, b)
	self.CommSidebarTabFrame:SetImgTabVisible(b)

	self:UpdateMorePanelVisible()
end

function ChatMainPanelView:OnValueChangedCurClickedMsgItem(NewValue)
	if nil == NewValue or nil == NewValue.ViewModel then
		self.CurClickedMsgItem = nil
		return
	end

	self.CurClickedMsgItem = NewValue

	local ViewportPos = self.CurClickedMsgItem:GetNodeViewportPosition()
	local LocalPos = UIUtil.ViewportToLocal(self.TopMemu, ViewportPos) 
	local MsgNodeSize = self.CurClickedMsgItem:GetNodeSize()
	local MsgFunctionTipsSize = UIUtil.CanvasSlotGetSize(self.MsgFunctionTips)

	-- 自身聊天信息
	if NewValue.ViewModel.IsMajor then 
		LocalPos.X = LocalPos.X - (MsgNodeSize.X / 2) + (MsgFunctionTipsSize.X / 2) - 15

	else
		LocalPos.X = LocalPos.X + (MsgNodeSize.X / 2) + (MsgFunctionTipsSize.X / 2)

	end

	UIUtil.CanvasSlotSetPosition(self.MsgFunctionTips, LocalPos)

	self:SetMsgFunctionTipsActive(true)
end

function ChatMainPanelView:OnValueChangedCurSelectedChannelItem(NewValue)
	if ChatVM.IsPublicChat then
		self.TableAdapterChannelPublic:SetSelectedItem(NewValue)

	else
		self.TableAdapterChannelPrivate:SetSelectedItem(NewValue)
		UIUtil.SetIsVisible(self.PanelMoreTips, false)
	end
end

function ChatMainPanelView:OnValueChangedChatBarWidgetVisible()
	self:UpdatePublicChannelPanels()
end

function ChatMainPanelView:OnSearchInputFinish(SearchText)
	ChatVM:FilterPrivateItemsByKeyword(SearchText)

	UIUtil.SetIsVisible(self.TableViewChannelPrivate, true)
end

function ChatMainPanelView:OnClickCancelSearchBar()
	ChatVM:FilterPrivateItemByType(ChatVM.PrivateFilterType)
	self:ResetPrivateNodes()
end

function ChatMainPanelView:UpdateToggleGroupCategory()
	self.CommTabsCategoryL:SetSelectedIndex(ChatVM.CurCategory or ChatCategory.Public)
end

function ChatMainPanelView:GetGoodsTipsOffset()
	if nil == self.GoodsOffset then
		self.GoodsOffset = FVector2D(10, 0)
	end

	return self.GoodsOffset
end

function ChatMainPanelView:OnChatMsgItemChanged()
	if self.FilterSystemMsging then 
		self.TableViewChatMsg:ScrollToBottom()
		self.FilterSystemMsging = nil 
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function ChatMainPanelView:OnEventMsgClickHyperLink( MsgData, ParamIndex )
	if nil == MsgData or nil == ParamIndex then
		return
	end

	local SimpleHref, Type = ChatVM:ParseSimpleHref(MsgData, ParamIndex)
	if nil == SimpleHref then
		return
	end

	if Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TASK then -- 任务
		local Task = SimpleHref.Task
		if Task ~= nil then
			---跳转后需要隐藏
			self:Hide()
			UIViewMgr:ShowView(UIViewID.QuestLogMainPanel, { QuestID = Task.TaskID })
		end

	elseif Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM then -- 物品
		local Item = SimpleHref.Item
		if Item ~= nil then
			if Item.GID ~= nil and Item.GID > 0 and Item.RoleID ~= nil and Item.RoleID > 0 then
				_G.RoleInfoMgr:SendQueryRoleItemInfo(Item.GID, Item.RoleID, { ItemDefine.QueryRoleItemType.ChatHyperlink, Item.ResID })

			else
				ItemTipsUtil.ShowTipsByResID(Item.ResID, self.ChatWin, self:GetGoodsTipsOffset())
			end
		end
	elseif Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_TREASUREHUNT then -- 宝图
		local TeamTreasureHunt =  SimpleHref.TeamTreasureHunt
		if TeamTreasureHunt ~= nil then
			local MajorRoleID = MajorUtil.GetMajorRoleID()
			if TeamTreasureHunt.RoleID == MajorRoleID or _G.TeamMgr:IsInTeam() then 
				_G.TreasureHuntMgr:CheckInterpretMapReq(TeamTreasureHunt)
			else
				-- 10056("你不在队伍，无法打开宝图")
				local strContent = LSTR(50056)
				MsgTipsUtil.ShowTips(strContent)
			end
 		end
	elseif Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_MAP then
		local Map = SimpleHref.Map
		if Map ~= nil then
			local QuestID = Map.QuestID 
			if QuestID then
				_G.QuestFaultTolerantMgr:ShowWorldMap(Map.MapID, Map.QuestID)
			else
				_G.WorldMapMgr:OpenMapFromChatHyperlink(Map.MapID, FVector2D(Map.X or 0, Map.Y or 0))
			end

			---跳转后需要隐藏
			self:Hide()
		end

	elseif Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ACHIEVEMENT_SHARE then -- 成就分享
		local AchievementShare = SimpleHref.AchievementShare
		if AchievementShare ~= nil then
			_G.AchievementMgr:OpenAchieveMainViewByAchieveID(AchievementShare.ID)
		end
	end
end

function ChatMainPanelView:OnEventQueryRoleItemInfo(ResID, Item)
	if Item ~= nil then
		ItemTipsUtil.ShowTipsByItem(Item, self.ChatWin, self:GetGoodsTipsOffset())

	else
		ItemTipsUtil.ShowTipsByResID(ResID, self.ChatWin, self:GetGoodsTipsOffset())
	end
end

function ChatMainPanelView:OnEvenOpenPrivateRedDotTipChanged()
	local IsOpen = ChatSetting.IsOpenPrivateRedDotTip()
	self:UpdateRedDotPanelVisible(IsOpen)
end

function ChatMainPanelView:OnEventTeamRecruitStateChanged()
	self:UpdateRecruitInfo(ChatVM.CurChannel)
end

function ChatMainPanelView:OnEventIsJoinNewbieChannelChanged()
	if ChatVM.CurChannel == ChatChannel.Newbie then
		ChatVM:UpdateCurSelectedChannelItem()
		ChatVM:UpdateChatInfo()
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatMainPanelView:OnStateChangedToggleBtnWide(ToggleButton, State)
	self:SetWinWideOrNarrow(UIUtil.IsToggleButtonChecked(State))
end

function ChatMainPanelView:OnSelectionChangedTabsCategoryL(Index)
	local IsPrivate = Index == ChatCategory.Private
	self.ToggleBtnCategoryS:SetChecked(IsPrivate, false)

	if Index == ChatVM.CurCategory then
		return
	end

	self.PublicChannelIdx = nil
	self.PrivateChannelIdx = nil
	self:ReleaseMsgItems()

	ChatVM:SetCategory(Index)

	if IsPrivate then
		self.TableAdapterChannelPublic:CancelSelected()
		self.PrivateSearchBar:SetText("")
		ChatVM:ClearFilterPrivateItems()

		local ItemVMList = ChatVM.ShowingPrivateItemVMList
		if ItemVMList then
			local FirstItemVM = ItemVMList:Get(1)
			if FirstItemVM then
				ChatVM:SetChannel(ChatChannel.Person, FirstItemVM.ChannelID)
			else
				ChatVM:SetChannel()
			end
		end

		self.PrivateDownList:ResetDropDown()
		self:ResetPrivateNodes()
		self:UpdatePrivateChatRoleInfos()

	else
		self.TableAdapterChannelPrivate:CancelSelected()
		ChatVM:SetChannel(ChatChannel.Comprehensive)
		ChatVM:UpdateCompSpeakChannelList()
	end
end

function ChatMainPanelView:OnStateChangedToggleBtnCategoryS(ToggleButton, State)
	if UIUtil.IsToggleButtonChecked(State) then
		self.CommTabsCategoryL:SetSelectedIndex(ChatCategory.Private)
	else
		self.CommTabsCategoryL:SetSelectedIndex(ChatCategory.Public)
	end
end

function ChatMainPanelView:OnTaleViewScrolledToEnd()
	ChatVM:ClearNewMsgTips()
end

function ChatMainPanelView:OnSelectionChangedDropDownList( Index )
	if ChatVM.CurChannel ~= ChatChannel.Person then
		return
	end

	local TypeInfo = PrivateFilterTypes[Index]
	if nil == TypeInfo then
		return
	end
	
	ChatVM:FilterPrivateItemByType(TypeInfo.Type)
end

function ChatMainPanelView:OnSelectionChangedCompSpeak(Index)
	local SpeakList = ChatVM.CompSpeakChannelList or {}
	local Info = SpeakList[Index]
	if nil == Info then
		return
	end

	ChatVM.CurCompSpeakChannel = Info.Channel
	ChatVM.CurCompSpeakChannelID = Info.ChannelID
end

function ChatMainPanelView:OnSelectionChangedSystemMsgFilter(Index, ItemData)
	if nil == ItemData then 
		return
	end

	local Type = ItemData.ID
	if ChatVM.CurSysMsgType == Type then
		return
	end

	self.FilterSystemMsging = true

	ChatVM:FilterSystemMsg(Type)
end

function ChatMainPanelView:OnClickButtonExit()
	local CurChannel = ChatVM.CurChannel
	if CurChannel == ChatChannel.Pioneer then
		MsgBoxUtil.ShowMsgBoxTwoOp(
			nil,
			LSTR(50164),  -- "退出先锋频道"
			LSTR(50165), -- "是否要退出先锋频道(退出后可再次主动加入)"
			function() 
				ChatMgr:SendQuitPioneerChannel()
			end,
			nil, LSTR(10003), LSTR(50166))
	end
end

function ChatMainPanelView:OnClickButtonGoTo()
	local CurChannel = ChatVM.CurChannel
	if CurChannel == ChatChannel.Newbie then
		UIViewMgr:ShowView(UIViewID.ChatNewbieMemberPanel)
		self:Hide()

	elseif CurChannel == ChatChannel.Army then
		if _G.ArmyMgr:OpenArmyMainPanel() then
			---跳转后需要隐藏
			self:Hide()
		end

	elseif CurChannel == ChatChannel.Team or CurChannel == ChatChannel.SceneTeam then
		---跳转后需要隐藏
		self:Hide()
		UIViewMgr:ShowView(UIViewID.TeamMainPanel)

	elseif CurChannel == ChatChannel.Group then
		UIViewMgr:ShowView(UIViewID.SocialMainPanel, { LinkShellID = ChatVM.CurChannelID })

		---跳转后需要隐藏
		self:Hide()
	end
end

function ChatMainPanelView:OnClickButtonNewTips()
	ChatVM:ClearNewMsgTips()
end

function ChatMainPanelView:OnClickButtonFriends()
	---跳转后需要隐藏
	self:Hide()
	UIViewMgr:ShowView(UIViewID.SocialMainPanel)
end

function ChatMainPanelView:OnClickButtonGoToTeam()
	---跳转后需要隐藏
	self:Hide()
	UIViewMgr:ShowView(UIViewID.TeamMainPanel)
end

function ChatMainPanelView:OnClickCopyMsg()
	if self.CurClickedMsgItem and self.CurClickedMsgItem.ViewModel then
		local Content = self.CurClickedMsgItem.ViewModel.RawContent
		local Text = RichTextUtil.ClearHyperlinkAttr(Content) or ""
		_G.UE.UPlatformUtil.ClipboardCopy(Text)

		-- 10057("复制成功")
		MsgTipsUtil.ShowTips(LSTR(50057))

		self.ChatBarPanel:SetChatText(Text)
	end

	self:SetMsgFunctionTipsActive(false)
end

function ChatMainPanelView:OnClickReportMsg()
	if nil == self.CurClickedMsgItem then
		self:SetMsgFunctionTipsActive(false)
		return
	end

	local MsgItemVM = self.CurClickedMsgItem.ViewModel
	if nil == MsgItemVM then
		self:SetMsgFunctionTipsActive(false)
		return
	end

	if MsgItemVM.IsMajor then
		MsgTipsUtil.ShowTips(LSTR(50058)) -- 10058("不能举报自己")

		self:SetMsgFunctionTipsActive(false)
		return
	end

	local RoleID = MsgItemVM.Sender
	if nil == RoleID then
		self:SetMsgFunctionTipsActive(false)
		return
	end

	local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
	if RoleVM then
		local MsgTypeParam = 0
		local FileID = nil
		local MsgType = MsgItemVM:GetMsgType()
		if MsgType == ChatMsgType.Voice then
			MsgTypeParam = 1
			FileID = MsgItemVM.VoiceID
		end

		local Params = { 
			ReporteeRoleID = RoleVM.RoleID, 
			ReportContent = MsgItemVM:GetContent(),
			CallbackList = { 
				msgtype = MsgTypeParam,
				fileid = FileID,
			},
		}
		_G.ReportMgr:OpenViewBySpeech(Params)
	end

	self:SetMsgFunctionTipsActive(false)
end

function ChatMainPanelView:OnClickMaskMsgTips()
	self:SetMsgFunctionTipsActive(false)
end

function ChatMainPanelView:OnClickSetting()
	UIViewMgr:ShowView(UIViewID.ChatSettingPanel, {Channel = ChatVM.CurChannel, ChannelID = ChatVM.CurChannelID})
	self:Hide()
end

function ChatMainPanelView:OnClickBtnMore()
	if not self.InitMoreConstText then
		self.TextAddFriend:SetText(LSTR(50087)) -- "添加好友"
		self.TextDeleteChatRecord:SetText(LSTR(50088)) -- "清空记录"
		self.InitMoreConstText = true
	end

	local IsFriend = _G.FriendMgr:IsFriend(ChatVM.CurChannelID)
	UIUtil.SetIsVisible(self.PanelBtnAdd, not IsFriend)
	UIUtil.SetIsVisible(self.PanelMoreTips, true)
end

function ChatMainPanelView:OnClickBtnMoreTipsMask()
	UIUtil.SetIsVisible(self.PanelMoreTips, false)
end

function ChatMainPanelView:OnClickDeleteChatRecord()
	local ItemVM = ChatVM.CurSelectedChannelItem 
	if nil == ItemVM then
		return
	end

	local Channel = ItemVM.Channel
	if Channel ~= ChatChannel.Person then
		return
	end

	local ChannelID = ItemVM.ChannelID

	if ChatVM.NotShowDeletePrivateMsgTip then
		ChatVM:ClearChannelAllChatMsg(Channel, ChannelID)

	else
		-- 10059('是否删除与<span color="#6fb1e9ff">%s</>的聊天记录？')、10060("提 示")、10003("取 消")、10002("确 认")
		local Content = string.format(LSTR(50059), ItemVM:GetName())
		MsgBoxUtil.ShowMsgBoxTwoOp(
			nil, 
			LSTR(10004), --"提 示"
			Content,
			function(_, Info) 
				ChatVM:ClearChannelAllChatMsg(Channel, ChannelID)
				ChatVM.NotShowDeletePrivateMsgTip = Info and Info.IsNeverAgain == true or false
			end,
			nil, LSTR(10003), LSTR(10002), {bUseNever = true})
	end

	self:OnClickBtnMoreTipsMask()
end

function ChatMainPanelView:OnClickedButtonSearch()
	self.PrivateDownList:FoldDropDown()

	UIUtil.SetIsVisible(self.PrivateFilterPanel, false)
	UIUtil.SetIsVisible(self.TableViewChannelPrivate, false)
	UIUtil.SetIsVisible(self.PrivateSearchBar, true)
end

function ChatMainPanelView:OnClickedButtonAddFriend()
	local CurChannel = ChatVM.CurChannel
	if CurChannel ~= ChatChannel.Person then
		return
	end

	_G.FriendMgr:AddFriend(ChatVM.CurChannelID, FriendDefine.AddSource.PrivateChat)

	self:OnClickBtnMoreTipsMask()
end

function ChatMainPanelView:OnClickedButtonGoToRecruit()
	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	if not TeamRecruitUtil.TryOpenTeamRecruitView() then
		return
	end

	if _G.TeamRecruitMgr:IsRecruiting() then
		_G.TeamRecruitMgr:ShowRecruitDetailView(_G.TeamRecruitMgr.RecruitID, {bNoLimit=true})
	end
end

function ChatMainPanelView:OnClickedButtonSendRecruit()
	if not _G.TeamRecruitMgr:IsRecruiting() then
		self:UpdateRecruitInfo(ChatVM.CurChannel)
		return
	end

	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	TeamRecruitUtil.ShareSelfRecruitToChat(ChatChannel.Recruit)
end

--- 界面切换处理，按策划要求，跳转界面前隐藏掉当前和底下的界面
function ChatMainPanelView:HideCurShowPanel()
	if self.CurOpenViewID then
		UIViewMgr:HideView(self.CurOpenViewID)
	end
end

return ChatMainPanelView