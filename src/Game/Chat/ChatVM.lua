---
--- Author: anypkvcai
--- DateTime: 2021-11-03 14:51
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatChannelComprehensiveVM = require("Game/Chat/VM/ChannelVM/ChatChannelComprehensiveVM")
local ChatChannelAreaVM = require("Game/Chat/VM/ChannelVM/ChatChannelAreaVM")
local ChatChannelArmyVM = require("Game/Chat/VM/ChannelVM/ChatChannelArmyVM")
local ChatChannelNearbyVM = require("Game/Chat/VM/ChannelVM/ChatChannelNearbyVM")
local ChatChannelNewbieVM = require("Game/Chat/VM/ChannelVM/ChatChannelNewbieVM")
local ChatChannelSystemVM = require("Game/Chat/VM/ChannelVM/ChatChannelSystemVM")
local ChatChannelTeamVM = require("Game/Chat/VM/ChannelVM/ChatChannelTeamVM")
local ChatChannelSceneTeamVM = require("Game/Chat/VM/ChannelVM/ChatChannelSceneTeamVM")
local ChatChannelGroupVM = require("Game/Chat/VM/ChannelVM/ChatChannelGroupVM")
local ChatChannelPrivateVM = require("Game/Chat/VM/ChannelVM/ChatChannelPrivateVM")
local ChatChannelPioneerVM = require("Game/Chat/VM/ChannelVM/ChatChannelPioneerVM")
local ChatChannelRecruitVM = require("Game/Chat/VM/ChannelVM/ChatChannelRecruitVM")
local ChatPublicChannelItemVM = require("Game/Chat/VM/ChatPublicChannelItemVM")
local ChatPrivateChannelItemVM = require("Game/Chat/VM/ChatPrivateChannelItemVM")
local ChatHyperlinkHistoryTextItemVM = require("Game/Chat/VM/ChatHyperlinkHistoryTextItemVM")
local ChatNewbieMemberItemVM = require("Game/Chat/VM/ChatNewbieMemberItemVM")
local ChatSettingSortItemVM = require("Game/Chat/VM/ChatSettingSortItemVM")
local ChatGifItemVM = require("Game/Chat/VM/ChatGifItemVM")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local ChatUtil = require("Game/Chat/ChatUtil")
local ChatSetting = require("Game/Chat/ChatSetting")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local SocialDefine = require("Game/Social/SocialDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ChatGifCfg = require("TableCfg/ChatGifCfg")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local Json = require("Core/Json")

local ChatCategory = ChatDefine.ChatCategory
local ChatChannel = ChatDefine.ChatChannel
local PrivateItemType = ChatDefine.PrivateItemType
local MaxPrivateSessionNum = ChatDefine.MaxPrivateSessionNum
local PrivateSessionTrimNum = ChatDefine.PrivateSessionTrimNum
local ChatMsgType = ChatDefine.ChatMsgType
local BarWidgetIndex = ChatDefine.BarWidgetIndex
local SysMsgType = ChatDefine.SysMsgType
local ChannelState = ChatDefine.ChannelState
local SidebarType = SidebarDefine.SidebarType.PrivateChat

local PARAM_TYPE_DEFINE = ProtoCS.PARAM_TYPE_DEFINE
local SPECIAL_SYSTEM_MSG_ID = ProtoCS.SPECIAL_SYSTEM_MSG_ID

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local FriendMgr = nil

--- 私聊会话排序算法
---@param lhs any
---@param rhs any
local PrivateChatItemSortFunc = function(lhs, rhs)
	local Time_lhs = lhs.Time or 0
	local Time_rhs = rhs.Time or 0

	Time_lhs = Time_lhs > 0 and Time_lhs or (lhs.CreateTime or 0)
	Time_rhs = Time_rhs > 0 and Time_rhs or (rhs.CreateTime or 0)

	if Time_lhs == Time_rhs then
		return (lhs.Name or "") < (rhs.Name or "")
	end

	return Time_lhs > Time_rhs
end

--- 公聊Item排序算法
---@param lhs any
---@param rhs any
local PublicChatItemSortFunc = function(lhs, rhs)
	local SortID_lhs = lhs.SortID
	local SortID_rhs = rhs.SortID
	if nil == SortID_lhs or nil == SortID_rhs then
		return nil == SortID_rhs
	end

	return SortID_lhs < SortID_rhs
end

--- 设置频道排序算法
---@param lhs any
---@param rhs any
local SettingItemSortFunc = function(lhs, rhs)
	local Pos_lhs = lhs.Pos
	local Pos_rhs = rhs.Pos
	if nil == Pos_lhs or nil == Pos_rhs then
		return nil == Pos_rhs
	end

	return Pos_lhs < Pos_rhs
end

---@class ChatVM : UIViewModel
---@field private WTListMsg table
local ChatVM = LuaClass(UIViewModel)

---Ctor
function ChatVM:Ctor()
	self.NotShowDeletePrivateMsgTip = false
	rawset(self, "WTListMsg", setmetatable({}, {__mode = "kv"}))
end

function ChatVM:OnInit()
    self:Reset(true)
end

function ChatVM:OnBegin()
	FriendMgr = _G.FriendMgr
end

function ChatVM:OnEnd()

end

function ChatVM:OnShutdown()
    self:Reset()
end

function ChatVM:Reset( IsInit )
	self.IsChatMainPanelVisible = false
    self.IsShowSetTips = true 
	self.RoleLoginTime = 0 

	self.CurCategory = nil 
	self.IsPublicChat = true
	self.CurChannel = nil
	self.CurChannelID = nil 
	self.CurSelectedChannelItem = nil

	self.TitleName = nil
	self.SubTitleName = nil
	self.ExitVisible = false
	self.GoToVisible = false
	self.GoToIcon = nil
	self.OnlineStatusVisible = false
	self.OnlineStatusIcon = nil
	self.DiffServerIconVisible = false -- 异服标识(和Major相比)
	self.HelpInfoID = 0 
	self.IsWideMainWin = true -- 聊天主界面是否为宽尺寸
	self.CurSysMsgType = SysMsgType.All

	self:SetChatBarVisible(true)

	self.ChatBarWidgetIndex = BarWidgetIndex.KeyboardInit 

	-- 聊天界面底部Widget（ChatBarPanel_UIBP)样式类型
	self.CurBarWidgetIndex = self.ChatBarWidgetIndex
	self.LastBarWidgetIndex = nil

	self.ChatMsgItemVMList = nil

	self:SetIsMsgEmpty(false)
	self.NewMsgTipsCount = 0
	self.NewMsgTipsVisible = false
	self.NewMsgTipsText = ""

	self.MsgScroolToBottom = nil 

	self.SendTimeCD = 0

	self.CurClickedMsgItem = nil -- 当前点击的聊天消息Item

	self.IsNoShowPrivateChatItem = true
	self.MakeFriendPanelVisible = false
	self.PrivateChatUnreadMsgIDs = {} -- 私聊未读消息(key: ChannelID，Value: {MessageID、MessageId......})
	self.PrivateFilterType = PrivateItemType.All

	self.UpdateComprehensiveMsg = false
	self.UpdateMsgTableViewListPos = false

	self.CurCompSpeakChannel = nil -- 综合频道，当前发言频道
	self.CurCompSpeakChannelID = nil -- 综合频道，当前发言频道ID
	self.CompSpeakChannelList = {} -- 综合频道发言频道列表

	-- 超链接
	self.CurHyperlinkCategoryIdx = 0 
	self.CurHyperlinkTabIdx = 1 
    self.HistoryTextVMList = self:ResetBindableList(self.HistoryTextVMList, ChatHyperlinkHistoryTextItemVM)
    self.HistoryGifVMList = self:ResetBindableList(self.HistoryGifVMList, ChatGifItemVM)

    self.PublicItemVMList = self:ResetBindableList(self.PublicItemVMList, ChatPublicChannelItemVM)
    self.PrivateItemVMList = self:ResetBindableList(self.PrivateItemVMList, ChatPrivateChannelItemVM)
    self.FilteredPrivateItemList = self:ResetBindableList(self.FilteredPrivateItemList)

	self.ShowingPrivateItemVMList = self.PrivateItemVMList

	-- 新人频道参与者
    self.NewbieMemberVMList = self:ResetBindableList(self.NewbieMemberVMList, ChatNewbieMemberItemVM)
    self.ShowingNewbieMemberList = self:ResetBindableList(self.ShowingNewbieMemberList)
	self.NewbieMemberEmptyPanelVisible = false 
	self.IsQueryingNewbieMember = false
	self.NewbieMemberFilterType = nil

	-- Gif表情
	self.UnlockGifIDMap = {}
    self.GifReadRedDotIDMap = {} 

	-- 先锋频道
	self.PioneerChannelState = ChannelState.Deleted
	self.PioneerChannelCloseTime = nil
	self.PioneerChannelDeleteTime = nil 
	self.PioneerChannelCloseTimeStr = nil
	self.PioneerChannelDeleteTimeStr = nil

	-- 频道排序
	self.SettingSortItemCount = 0
	self.SettingIsMoving = false
	self.SettingSortItemVMList = self:ResetBindableList(self.SettingSortItemVMList, ChatSettingSortItemVM)

	-- 侧边栏
	self.LatestPrivateChatMsg = nil

	if IsInit then
		self.ChannelVMList = {}
		self.ComprehensiveChannelVM = ChatChannelComprehensiveVM.New() -- 综合频道

		self:TryInitPublicItemVMList()
		self:InitChannelVM()
		self:SetNoCheckValueChange("NewMsgTipsCount", true)

	else
		self.ChannelVMSystem = nil
	end
end

function ChatVM:TryInitPublicItemVMList()
	local PublicItemVMList = self.PublicItemVMList 
	if nil == PublicItemVMList or PublicItemVMList:Length() > 0 then
		return
	end

	local DataList = {} 

	for _, v in ipairs(ChatDefine.DefaultPublicChannels) do
		if not ChatUtil.IsHideChannel(v) then -- 剔除掉隐藏的频道
			table.insert(DataList, {
				Channel = v,
				SortID = ChatUtil.GetChannelSortID(v),
			})
		end
	end

	PublicItemVMList:UpdateByValues(DataList, PublicChatItemSortFunc)
end

function ChatVM:InitChannelVM()
	local ChannelsConfig = {
		{ Channel = ChatChannel.Newbie, 		ViewModel = ChatChannelNewbieVM },
		{ Channel = ChatChannel.Army, 			ViewModel = ChatChannelArmyVM },
		{ Channel = ChatChannel.Area, 			ViewModel = ChatChannelAreaVM },
		{ Channel = ChatChannel.Team, 			ViewModel = ChatChannelTeamVM },
		{ Channel = ChatChannel.SceneTeam, 		ViewModel = ChatChannelSceneTeamVM },
		{ Channel = ChatChannel.Nearby, 		ViewModel = ChatChannelNearbyVM },
		{ Channel = ChatChannel.System, 		ViewModel = ChatChannelSystemVM },
		{ Channel = ChatChannel.Recruit, 		ViewModel = ChatChannelRecruitVM },
	}

	-- 添加综合频道
	table.insert(self.ChannelVMList, self.ComprehensiveChannelVM)

	-- 添加其他频道

	for i = 1, #ChannelsConfig do
		local Config = ChannelsConfig[i]
		table.insert(self.ChannelVMList, Config.ViewModel.New(Config.Channel))
	end

	self.ChannelVMSystem = self:FindChannelVM(ChatChannel.System)
end

function ChatVM:FindChannelVM(Channel, ChannelID, CreateIfNoneFound)
	for _, v in ipairs(self.ChannelVMList) do
		if v.Channel == Channel and (nil == ChannelID or v:GetChannelID() == ChannelID) then
			return v
		end
	end

	if CreateIfNoneFound then
		local ViewModel = nil
		if Channel == ChatChannel.Group then
			ViewModel = ChatChannelGroupVM

		elseif Channel == ChatChannel.Person then
			ViewModel = ChatChannelPrivateVM 

		elseif Channel == ChatChannel.Pioneer then
			ViewModel = ChatChannelPioneerVM 
		end

		if nil ~= ViewModel then
			local ChannelVM = ViewModel.New(Channel, ChannelID)
			table.insert(self.ChannelVMList, ChannelVM)

			return ChannelVM
		end
	end
end

function ChatVM:FindChannelItemVM(Channel, ChannelID)
	local ItemUBList = Channel == ChatChannel.Person and self.ShowingPrivateItemVMList or self.PublicItemVMList
	local Items = ItemUBList:GetItems()

	for _, v in ipairs(Items) do
		if v.Channel == Channel then
			if Channel == ChatChannel.Person or Channel == ChatChannel.Group then
				if v.ChannelID == ChannelID then
					return v
				end
			else
				return v
			end
		end
	end
end

function ChatVM:UpdateGroupChannelName(ChannelID)
	if nil == ChannelID then
		return
	end

	local Channel = ChatChannel.Group
	if ChatUtil.IsHideChannel(Channel) then
		return
	end

	local LinkShellItemVM = LinkShellVM:QueryLinkShell(ChannelID)
	if nil == LinkShellItemVM then
		return
	end

	local Item = self.PublicItemVMList:Find(function(e) return e.Channel == Channel and e.ChannelID == ChannelID end)
	if Item then
		Item:SetName(LinkShellItemVM.Name)

		if self.CurChannel == Channel and self.CurChannelID == ChannelID then
			self.TitleName = Item:GetName()
			self.SubTitleName = Item:GetSubName()
		end
	end
end

---更新队伍相关聊天数据
function ChatVM:UpdateTeamChatData(NoSortPublicItems)
	local RemovedChannel = nil
	local TeamChannel = nil 
	if _G.PWorldMgr:CurrIsInDungeon() then
		RemovedChannel = ChatChannel.Team
		TeamChannel = ChatChannel.SceneTeam
	else
		RemovedChannel = ChatChannel.SceneTeam
		TeamChannel = ChatChannel.Team
	end

	-- 更新公共频道数据列表中的组队信息
	local ItemVMList = self.PublicItemVMList
	if nil == ItemVMList then
		return
	end

	local Item = ItemVMList:Find(function(e) return e.Channel == RemovedChannel end)
	if Item then
		ItemVMList:Remove(Item)
	end

	if ItemVMList:Find(function(e) return e.Channel == TeamChannel end) then
		return
	end

	if ChatUtil.IsHideChannel(TeamChannel) then
		return
	end

	local Value = { Channel = TeamChannel, SortID = ChatUtil.GetChannelSortID(TeamChannel) }
	if ItemVMList:AddByValue(Value) and NoSortPublicItems ~= false then
		ItemVMList:Sort(PublicChatItemSortFunc)
	end
end

---更新通讯贝频道Item数据列表(增删)
function ChatVM:UpdateGroupChannelItems(NoSortPublicItems)
	local GroupChannel = ChatChannel.Group
	if ChatUtil.IsHideChannel(GroupChannel) then
		return
	end

	local IDList = LinkShellVM:GetLinkShellIDList()
	local ItemVMList = self.PublicItemVMList
	local SortID = ChatUtil.GetChannelSortID(GroupChannel) 

	for k, v in ipairs(IDList) do
		local LinkShellItemVM = LinkShellVM:QueryLinkShell(v)
		if LinkShellItemVM then
			local Item = ItemVMList:Find(function(e) return e and e.Channel == GroupChannel and e.ChannelID == v end)
			if nil == Item then
				Item = ItemVMList:AddByValue({ Channel = ChatChannel.Group, SortID = SortID + k })
				if Item then
					Item:UpdateByGroup(LinkShellItemVM)
				end

			else
				Item:SetName(LinkShellItemVM.Name)
			end
		end

		-- 增
		self:FindChannelVM(GroupChannel, v, true)
	end

	--删除未知通讯贝item
	ItemVMList:RemoveItemsByPredicate(function(e) 
		return e.Channel == GroupChannel and not table.contain(IDList, e.ChannelID) 
	end)

	-- 排序
	if NoSortPublicItems ~= false then
		ItemVMList:Sort(PublicChatItemSortFunc)
	end

	local IsSwitchComprehensive = false 
	local ChannelVMList = self.ChannelVMList

	-- 删除聊天消息
	for i = #ChannelVMList, 1, -1 do
		local v = ChannelVMList[i]
		if v then
			local Channel = v:GetChannel()
			if Channel == GroupChannel then
				local ChannelID = v:GetChannelID()
				if not table.contain(IDList, ChannelID) then
					v:ClearMsg()
					table.remove(ChannelVMList, i)

					-- 切到综合频道
					if self.CurChannel == Channel and self.CurChannelID == ChannelID then
						IsSwitchComprehensive = true
					end
				end
			end
		end
	end

	if IsSwitchComprehensive then
		self:SetChannel(ChatChannel.Comprehensive)

	else
		self:UpdateCurSelectedChannelItem()
	end
end

function ChatVM:SetChannel(Channel, ChannelID, NoCheckSameChannel)
	if NoCheckSameChannel ~= true and Channel == self.CurChannel then
		if Channel ~= ChatChannel.Group and Channel ~= ChatChannel.Person then
			return

		else
			if ChannelID == self.CurChannelID then
				return
			end
		end
	end

	if Channel == ChatChannel.Group then
		local IDList = LinkShellVM:GetLinkShellIDList()
		if nil == IDList or false == table.contain(IDList, ChannelID) then
			Channel = ChatChannel.Comprehensive
			ChannelID = nil
		end
	end

	self.UpdateMsgTableViewListPos = false
	
	self.CurChannel = Channel
	self.CurChannelID = ChannelID
	self:UpdateCurSelectedChannelItem()

	self:UpdateChatInfo(true)
	self:ClearNewMsgTips()
	self:ClearRedDotNum()
	self:UpdateMsgIsEmpty()

	_G.VoiceMgr:StopPlayFiles()
	_G.VoiceMgr:StopTranslatingVoiceFile()
end

function ChatVM:UpdateCurSelectedChannelItem()
	local Channel = self.CurChannel
	local ChannelID = self.CurChannelID
	local Item = self:FindChannelItemVM(Channel, ChannelID)
	if nil == Item then
		self.CurSelectedChannelItem = nil 
		self.TitleName = self.MakeFriendPanelVisible and LSTR(50137) or nil -- "好友"
		self.SubTitleName = nil
		self.ExitVisible = false
		self.GoToVisible = false
		self.GoToIcon = nil
		self.OnlineStatusVisible = false
		self.OnlineStatusIcon = nil
		self.DiffServerIconVisible = false
		self.HelpInfoID = 0 
		return
	end

	local ChannelVM = self:FindChannelVM(Channel)

	self.CurSelectedChannelItem = Item
	self.TitleName = Item:GetName()
	self.SubTitleName = Item:GetSubName()
	self.ExitVisible = ChannelVM ~= nil and ChannelVM:CheckExitVisible() or false
	self.HelpInfoID = Channel ~= nil and ChannelVM:GetHelpInfoID() or 0

	self:UpdateGoTo(nil, ChannelVM)

	if Channel ~= ChatChannel.Person then
		self.OnlineStatusVisible = false  
		self.OnlineStatusIcon = nil
		self.DiffServerIconVisible = false
		return
	end

	local PrivateItem = self.ShowingPrivateItemVMList:Find(function(e) return ChannelID == e.ChannelID end) or {}
	local Icon = PrivateItem.OnlineStatusIcon
	self.OnlineStatusVisible = not string.isnilorempty(Icon)  
	self.OnlineStatusIcon = Icon 

	local CurWorldID = PrivateItem.CurWorldID
	self.DiffServerIconVisible = CurWorldID and CurWorldID > 0 and CurWorldID ~= _G.PWorldMgr:GetCurrWorldID()
end

function ChatVM:UpdateGoTo(IsVisible, ChannelVM)
	local CurChannel = self.CurChannel
	if nil == IsVisible then
		ChannelVM = ChannelVM or self:FindChannelVM(CurChannel)
		if nil == ChannelVM then
			IsVisible = false
		else
			IsVisible = ChannelVM:CheckGoToVisible()
		end
	end

	self.GoToVisible = IsVisible

	if IsVisible then
		local Config = ChatUtil.FindChatChannelConfig(CurChannel) or {}
		self.GoToIcon = Config.GoToIcon
	else
		self.GoToIcon = nil 
	end
end

function ChatVM:SetCategory(Category)
	self.CurCategory = Category

	local IsPublic = Category == ChatCategory.Public
	self.IsPublicChat = IsPublic 
	self.MakeFriendPanelVisible = not IsPublic and (self.PrivateItemVMList:Length() <= 0)
end

function ChatVM:UpdateChatInfo(IsSortMsg)
	self:SetChatBarVisible(self:GetChatBarWidgetVisible())

	local CurChannel = self.CurChannel
	local ChannelVM = self:FindChannelVM(CurChannel, self.CurChannelID)
	if nil == ChannelVM then
		self.ChatMsgItemVMList = nil 
	else
		if IsSortMsg then
			ChannelVM:SortMsgVM()
		end

		self.ChatMsgItemVMList = ChannelVM.BindableListMsg
		if self.ChatMsgItemVMList then
			if self.WTListMsg[self.ChatMsgItemVMList] == nil then
				self.WTListMsg[self.ChatMsgItemVMList] = self.ChatMsgItemVMList
				self.ChatMsgItemVMList:RegisterUpdateListCallback(self, self.OnChatMsgListUpdate)
				self.ChatMsgItemVMList:RegisterAddItemsCallback(self, self.OnChatMsgListUpdate)
				self.ChatMsgItemVMList:RegisterRemoveItemsCallback(self, self.OnChatMsgListUpdate)
			end
		end
	end

	self:UpdateMsgIsEmpty()
end

function ChatVM:UpdateChatBarVisible( )
	self:SetChatBarVisible(self:GetChatBarWidgetVisible())
end

function ChatVM:UpdateCurBarWidgetIndex(WidgetIndex)
	local CurChannel = self.CurChannel
	if nil == CurChannel then
		return
	end

	self.LastBarWidgetIndex = self.CurBarWidgetIndex 

	if nil == WidgetIndex then
		self.CurBarWidgetIndex = self.ChatBarWidgetIndex 
	else
		self.ChatBarWidgetIndex = WidgetIndex
		self.CurBarWidgetIndex = WidgetIndex
	end
end

function ChatVM:GetChatBarWidgetVisible()
	local ChannelVM = self:FindChannelVM(self.CurChannel)
	if nil == ChannelVM then
		return false 
	end

	return ChannelVM:GetChatBarWidgetVisible()
end

function ChatVM:UpdateNewMsgTips()
	self.NewMsgTipsVisible = self.NewMsgTipsCount > 0
	if self.NewMsgTipsCount > 0 then
		self.NewMsgTipsText = self.NewMsgTipsCount
	end
end

function ChatVM:ClearNewMsgTips()
	self.NewMsgTipsCount = 0
	self:UpdateNewMsgTips()
end

function ChatVM:IsPrivateChatMsgUnread( ChannelID, MsgID )
	return MsgID > 0 and table.contain(self.PrivateChatUnreadMsgIDs[ChannelID] or {}, MsgID)
end

function ChatVM:AddChatMsgInternal(ChannelVM, ChatMsg)
	if nil == ChannelVM then
		return
	end

	local MsgID = ChatMsg.ID 
	if MsgID > 0 and ChannelVM:IsExist(MsgID) then
		return
	end

	local Sender = ChatMsg.Sender
	local Data = ChatMsg.Data
	local Content = Data.Content
	local IsRead = true  -- 消息是否已被阅读
	local Channel = ChannelVM.Channel
	local ChannelID = ChannelVM:GetChannelID()
	local ChannelSystem = ChatChannel.System

	if Channel == ChatChannel.Person then
		-- 异常私聊信息
		if Sender ~= nil and Sender > 0 and Sender ~= ChannelID and not MajorUtil.IsMajorByRoleID(Sender) then
			FLOG_WARNING("[ChatVM] Invalid private message data, Sender: %s, ChannelID: %s", tostring(Sender), tostring(ChannelID))
			return
		end

		IsRead = not self:IsPrivateChatMsgUnread(ChannelID, MsgID)
		self:CreatePrivateItem(ChannelID)
		 
		local PrivateItem = self.PrivateItemVMList:Find(function(e) return ChannelID == e.ChannelID end)
		if PrivateItem then
			PrivateItem:SetTime(ChatMsg.Time)
			self.PrivateItemVMList:Sort(PrivateChatItemSortFunc)
		end

		if not IsRead and ChatSetting.IsOpenPrivateRedDotTip() then
			_G.MainPanelVM:SetPersonChatHeadTipsPlayer(Sender)
		end

	else
		-- 黑名单消息屏蔽：公聊--前台屏蔽，私聊--后台屏蔽
		if FriendMgr:IsInBlackList(Sender) then
			return
		end

		IsRead = MsgID < 0 or MsgID <= ChannelVM:GetCurrentMsgID()
	end

	if not IsRead then
		ChannelVM:SetCurrentMsgID(MsgID)
	end

	local MsgType = Data.MsgType
	if nil == MsgType then
		MsgType = Channel == ChannelSystem and ChatMsgType.SystemNotice or ChatMsgType.Msg
	end

	local SysMsgID = Data.SysMsgID
	if SysMsgID == SPECIAL_SYSTEM_MSG_ID.SPECIAL_SYSTEM_MSG_ID_GET_GOODS then -- 获得物品提示
	elseif SysMsgID > 0 then
		if Channel ~= ChannelSystem then
			self.ChannelVMSystem:AddMsg(Channel, MsgType, ChatMsg, Content, true)
		end
	end

	local MsgItemVM = ChannelVM:AddMsg(Channel, MsgType, ChatMsg, Content, IsRead, ChannelID)

	-- 综合频道
	local Time = ChatMsg.Time or 0
	local IsAddComprehensiveChannel = Channel ~= ChatChannel.Person and Time > self.RoleLoginTime
	IsAddComprehensiveChannel =  IsAddComprehensiveChannel and ChatSetting.IsDisplayInComprehensiveChannel(Channel, ChannelID, MsgType) and not MsgItemVM:IsComprehensiveInvisible()  
	if IsAddComprehensiveChannel then
		local IsTeam = Channel == ChatChannel.Team
		local IsSceneTeam = Channel == ChatChannel.SceneTeam
		if IsTeam or IsSceneTeam then
			if _G.PWorldMgr:CurrIsInDungeon() then
				IsAddComprehensiveChannel = IsSceneTeam
			else
				IsAddComprehensiveChannel = IsTeam
			end
		end

		if IsAddComprehensiveChannel then
			local VM = self.ComprehensiveChannelVM 
			if VM then
				VM:Add(MsgItemVM)
			end

			self.UpdateComprehensiveMsg = true
		end
	end

	local CurChannel = self.CurChannel
	if CurChannel ~= ChannelSystem then
		local CurChannelID = self.CurChannelID
		if Channel == CurChannel and (ChannelID == CurChannelID or ChannelID == 0 or ChannelID == nil) then
			if MajorUtil.IsMajorByRoleID(Sender) then
				self.NewMsgTipsCount = 0
			else
				self.NewMsgTipsCount = self.NewMsgTipsCount + 1
			end
		end
	end

	if self.UpdateComprehensiveMsg and CurChannel == ChatChannel.Comprehensive then 
		-- 玩家通过综合频道发送消息成功
		if self.ChatBarWidgetVisible and MajorUtil.IsMajorByRoleID(Sender) then
			self.MsgScroolToBottom = true
		end
	end

	if Time > self.RoleLoginTime then
		self:HandleNewMsgInternal(Channel, MsgItemVM)
	end
end

function ChatVM:HandleNewMsgInternal(Channel, MsgItemVM)
	local IsPerson = Channel == ChatChannel.Person
	if MsgItemVM:IsOtherPlayerMsg() then
		if not self.IsChatMainPanelVisible then
			-- 侧边栏
			if IsPerson and ChatSetting.IsOpenPrivateSidebar() then
				self:TryAddSidebarItem(MsgItemVM)
			end
		end
	end

	local Sender = MsgItemVM.Sender

	-- 弹幕
	if IsPerson then
		if ChatSetting.IsOpenPrivateDanmaku() and Sender ~= nil then
			RoleInfoMgr:QueryRoleSimple(Sender, function()
				_G.DanmakuMgr:AddDanmakuPrivateChat(ChatUtil.GetChatSimpleDesc(MsgItemVM))
			end)
		end

	elseif Channel == ChatChannel.Team or Channel == ChatChannel.SceneTeam then
		if ChatSetting.IsOpenTeamDanmaku() and Sender ~= nil then
			RoleInfoMgr:QueryRoleSimple(Sender, function()
				_G.DanmakuMgr:AddDanmakuTeamChat(ChatUtil.GetChatSimpleDesc(MsgItemVM))
			end)
		end
	end
end

function ChatVM:AddChatMsgList(Channel, ChannelID, ChatMsgList)
	local ChannelVM = self:FindChannelVM(Channel, ChannelID, true)
	if nil == ChannelVM then
		return
	end

	for _, v in ipairs(ChatMsgList) do
		self:AddChatMsgInternal(ChannelVM, v)
	end

	self:OnAddChatMsg(ChannelVM)
end

function ChatVM:OnAddChatMsg(ChannelVM)
	ChannelVM:TrimChatMsg()

	local CurChannel = self.CurChannel
	if self.UpdateComprehensiveMsg then
		self.ComprehensiveChannelVM:TrimChatMsg()
		self.UpdateComprehensiveMsg = false

		if CurChannel == ChatChannel.Comprehensive then
			self.UpdateMsgTableViewListPos = true
		end
	end

	if ChannelVM.Channel == CurChannel then 
		local CurChannelID = self.CurChannelID
		if nil == CurChannelID or ChannelVM:GetChannelID() == CurChannelID then
			ChannelVM:ClearRedDot()
		else
			ChannelVM:UpdateRedDot()
		end

	else
		ChannelVM:UpdateRedDot()
	end
end

function ChatVM:ClearRedDotNum()
	local ChannelVM = self:FindChannelVM(self.CurChannel, self.CurChannelID)
	if nil == ChannelVM then
		return
	end

	ChannelVM:ClearRedDot()
end

function ChatVM:ClearPublicChannelRedDotNum()
	for _, v in ipairs(self.ChannelVMList) do
		if v:GetChannel() ~= ChatChannel.Person then
			v:ClearRedDot()
		end
	end
end

function ChatVM:CheckIsInChannel(Channel, ChannelID)
	local ChannelVM = self:FindChannelVM(Channel, ChannelID)
	if nil == ChannelVM then
		FLOG_ERROR("ChatVM:CheckIsInChannel, The specified channel could not be found")
		return false
	end

	return ChannelVM:CheckIsInChannel()
end

function ChatVM:ParseSimpleHref(MsgData, ParamIndex)
	if nil == MsgData then
		return
	end

	local ParamList = MsgData.ParamList
	if nil == ParamList then
		return
	end

	local Param = ParamList[ParamIndex]
	if nil == Param then
		return
	end

	return _G.ChatMgr:DecodeChatParams(Param.Param), Param.Type, Param.ID
end

function ChatVM:HrefClicked(ViewModel, ParamIndex)
	local MsgData = ViewModel.MsgData
	if nil == MsgData then
		return
	end

	EventMgr:SendEvent(EventID.ChatMsgClickHyperLink, MsgData, ParamIndex)
end

function ChatVM:OnComprehensiveChannelsChange()
	local RemovePredicate = function(e)
		return not ChatSetting.IsDisplayInComprehensiveChannel(e:GetChannel(), e:GetChannelID(), e:GetMsgType())
	end

	local VM = self.ComprehensiveChannelVM
	if VM then
		VM.BindableListMsg:RemoveItemsByPredicate(RemovePredicate, true)
	end

	--更新综合频道发言频道列表
	self:UpdateCompSpeakChannelList()
end

-- 设置所有队伍频道相关消息为历史消息
function ChatVM:SetAllTeamChannelMsgToHistory(Channel)
	if nil == Channel then
		return
	end

	-- 队伍频道
	local ChannelVM = ChatVM:FindChannelVM(Channel)
	if ChannelVM then
		ChannelVM:SetMsgToHistory()
	end
end

---通过类型过滤
---@param ItemType ChatDefine.PrivateItemType @类型 
function ChatVM:FilterPrivateItemByType( ItemType )
	if nil == ItemType then
		return
	end

	self.PrivateFilterType = ItemType 

	if ItemType == PrivateItemType.All then 
		self:ClearFilterPrivateItems()
		return
	end

	self.FilteredPrivateItemList:Clear()
	self.FilteredPrivateItemList:AddRange(self.PrivateItemVMList:FindAll(function(e) return e.Type == ItemType end))

	self.ShowingPrivateItemVMList = self.FilteredPrivateItemList
	self:UpdateIsNoPrivateChatItem()
	self:CheckCurSelectedChannelItem()
end

--- 通过玩家名关键词过滤
---@param Keyword string @关键词 
function ChatVM:FilterPrivateItemsByKeyword( Keyword )
	self.FilteredPrivateItemList:Clear()

	local CurType = self.PrivateFilterType
	local Pattern = CommonUtil.ReviseRegexSpecialCharsPattern(Keyword)

	self.FilteredPrivateItemList:AddRange(self.PrivateItemVMList:FindAll(
		function(e) 
			if CurType ~= PrivateItemType.All and CurType ~= e.Type then
				return false
			end

			local Name = e.Name
			return Name and string.find(Name, Pattern)
		end
	))

	self.ShowingPrivateItemVMList = self.FilteredPrivateItemList
	self:UpdateIsNoPrivateChatItem()

	self:CheckCurSelectedChannelItem()
end

function ChatVM:CheckCurSelectedChannelItem()
	local VMList = self.ShowingPrivateItemVMList
	if nil == VMList:Find(function(e) return e.ChannelID == self.CurChannelID end) then
		local ChannelID = VMList:Length() > 0 and VMList:Get(1).ChannelID or nil
		if ChannelID then
			self:SetChannel(ChatChannel.Person, ChannelID)
		end

	else
		self:UpdateCurSelectedChannelItem()
	end
end

function ChatVM:RebuildPrivateItems()
	self:FilterPrivateItemByType(self.PrivateFilterType)
end

function ChatVM:ClearFilterPrivateItems()
	self.PrivateFilterType = PrivateItemType.All
	self.ShowingPrivateItemVMList = self.PrivateItemVMList
	self:UpdateIsNoPrivateChatItem()
	self:UpdateCurSelectedChannelItem()
end

function ChatVM:UpdateIsNoPrivateChatItem()
	self.IsNoShowPrivateChatItem = self.ShowingPrivateItemVMList:Length() <= 0
end

function ChatVM:AddLocalCachingPrivateItems(Infos)
	if nil == Infos or #Infos <= 0 then
		return
	end

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local VMList = self.PrivateItemVMList

	for _, v in ipairs(Infos) do
		local RoleID = v.RoleID
		if RoleID and RoleID ~= MajorRoleID and nil == VMList:Find(function(e) return RoleID == e.ChannelID end) then
			local Item = VMList:AddByValue(v)
			if Item then
				local ChannelVM = self:FindChannelVM(Item.Channel, Item.ChannelID, true)
				if ChannelVM then
					ChannelVM:UpdateRedDot()
				end
			end
		end
	end

	self:UpdateIsNoPrivateChatItem()

	VMList:Sort(PrivateChatItemSortFunc)
end

function ChatVM:CreatePrivateItem(RoleID)
	if nil == RoleID or MajorUtil.IsMajorByRoleID(RoleID) then 
		return
	end

	local PrivateItem = self.PrivateItemVMList:Find(function(e) return RoleID == e.ChannelID end)
	if PrivateItem then
		return
	end

	RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
		if nil == RoleVM then
			return
		end

		local VMList = self.PrivateItemVMList 
		local ID = RoleVM.RoleID
		if nil == ID or VMList:Find(function(e) return ID == e.ChannelID end) then
			return
		end

		local Item = VMList:AddByValue({RoleID = ID, CreateTime = TimeUtil.GetServerTime()}, nil, false)
		if Item then
			local ChannelVM = self:FindChannelVM(Item.Channel, Item.ChannelID, true)
			if ChannelVM then
				ChannelVM:UpdateRedDot()
			end

			Item:UpdateRoleInfo(RoleVM)
			Item:UpdateFriendFlag()
		end

		VMList:Sort(PrivateChatItemSortFunc)

		-- 检测 私聊会话数量是否超出限制
		local CurNum = VMList:Length()
		if CurNum > PrivateSessionTrimNum and CurNum > MaxPrivateSessionNum then 
			local From = CurNum - PrivateSessionTrimNum + 1
			local To = CurNum
			local Items = VMList:GetItems()

			local ReadSeqList = {}
			local RemoveChannelIDs = {}

			for i = #Items, 1, -1 do
				if i >= From and i <= To then
					local TempItemVM = Items[i]

					-- 清除待删除会话的未读消息（服务器）
					local ChannelVM = self:FindChannelVM(TempItemVM.Channel, TempItemVM.ChannelID)
					if ChannelVM then
						ChannelVM:ClearUnreadInfo()

						local ChannelID = ChannelVM:GetChannelID()
						table.insert(RemoveChannelIDs, ChannelID)

						table.insert(ReadSeqList, {
							Channel = { Type = ChannelVM:GetChannel(), ChannelID = ChannelID },
							Ack = ChannelVM:GetCurrentMsgID()
						})
					end

					VMList:RemoveAt(i)
				end
			end

			-- 把删除掉的会话所有消息设置为已读
			_G.ChatMgr:SendSetChatChannelHaveRead(ReadSeqList)

			-- 删除私聊消息文件
			_G.ChatMgr:DeletePrivateChatMsgFile(RemoveChannelIDs)
		end

		-- 重新生成ShowingPrivateItemVMList
		self:RebuildPrivateItems()

		-- 存储私聊
		_G.ChatMgr:ActivateSavePrivateSessionsMark()

		self.IsNoShowPrivateChatItem = false 
	end)
end

function ChatVM:UpdatePrivateItem(RoleID, CreateIfNoItem)
	if nil == RoleID or MajorUtil.IsMajorByRoleID(RoleID) then 
		return
	end

	local PrivateItem = self.PrivateItemVMList:Find(function(e) return RoleID == e.ChannelID end)
	if PrivateItem then
		local FilterType = self.PrivateFilterType
		if PrivateItem:UpdateFriendFlag() and FilterType ~= PrivateItemType.All then
			self:FilterPrivateItemByType(FilterType)
		end

	else
		if CreateIfNoItem then
			self:CreatePrivateItem(RoleID)
		end
	end
end

--- 更新私聊角色信息
function ChatVM:UpdatePrivateChatRoleInfos()
	local RoleIDList = {}
	local Items = self.PrivateItemVMList:GetItems()

    for _, v in ipairs(Items) do
		local RoleID = v.RoleID 
		if RoleID then
			table.insert(RoleIDList, RoleID)
		end
    end

	RoleInfoMgr:QueryRoleSimples(RoleIDList, function()
		for _, v in ipairs(Items) do
			local RoleVM = RoleInfoMgr:FindRoleVM(v.RoleID)
			if RoleVM then
				v:UpdateRoleInfo(RoleVM)
			end
		end

		-- 当前展示列表
		local ShowingItems = self.ShowingPrivateItemVMList:GetItems()

		for _, v in ipairs(ShowingItems) do
			local RoleVM = RoleInfoMgr:FindRoleVM(v.RoleID)
			if RoleVM then
				v:UpdateRoleInfo(RoleVM)
			end
		end

		if self.CurChannel == ChatChannel.Person then
			self:UpdateCurSelectedChannelItem()
		end
	end, nil, false)
end

-- 是否开始私聊角色信息更新
function ChatVM:IsStartPrivateChatRoleInfoUpdate()
	return self.IsNoShowPrivateChatItem ~= true and self.CurChannel == ChatChannel.Person
end

function ChatVM:AddPrivateChatUnreadMsg(ChannelID, MsgID)
	if nil == ChannelID or nil == MsgID then
		return
	end

	self.PrivateChatUnreadMsgIDs[ChannelID] = table.merge(self.PrivateChatUnreadMsgIDs[ChannelID] or {}, MsgID)
end

function ChatVM:DelPrivateChatUnreadMsg(ChannelID, MsgID)
	if nil == ChannelID then
		return
	end

	if nil == MsgID then
		self.PrivateChatUnreadMsgIDs[ChannelID] = nil
		return
	end

	local MsgIDList = self.PrivateChatUnreadMsgIDs[ChannelID]
	if nil == MsgIDList then
		return
	end

	local IsStartDel = false

	for i = #MsgIDList, 1, -1 do
		local v = MsgIDList[i]
		if v == MsgID then 
			IsStartDel = true
		end

		if IsStartDel then
			table.remove(MsgIDList, i)
		end
	end
end

function ChatVM:DeleteComprehensiveChannelChatMsg(MsgItemVM)
	if nil == MsgItemVM then
		return
	end

	local VM = self.ComprehensiveChannelVM
	if nil == VM then
		return
	end

	VM.BindableListMsg:RemoveByPredicate(function(e) return e == MsgItemVM end, true)
end

--- 清空频道所有聊天消息
function ChatVM:ClearChannelAllChatMsg(Channel, ChannelID, ShowNoMsgTips)
	if Channel == ChatChannel.Person then
		-- 删除私聊文件
		_G.ChatMgr:DeletePrivateChatMsgFile({ ChannelID })
	end

	-- 清空具体频道消息
	local ChannelVM = self:FindChannelVM(Channel, ChannelID)
	if ChannelVM then
		ChannelVM:ClearMsg()
	end

	self:UpdateMsgIsEmpty()
end

function ChatVM:GetSendCDRemainTime()
	local Time = TimeUtil.GetServerTimeMS()
	return self.SendTimeCD - Time
end

function ChatVM:CheckSendTimeCD()
	local Time = self:GetSendCDRemainTime()
	if Time > 0 then
		-- 50037("您的发言太频繁请稍后再试")
		MsgTipsUtil.ShowTips(LSTR(50037))
		return false
	end

	return true
end

function ChatVM:UpdateSendTimeCD(Channel, ChannelID)
	if nil == Channel then
		return
	end

	local ChannelVM = self:FindChannelVM(Channel, ChannelID)
	if nil == ChannelVM then
		return
	end

	local Config = ChatUtil.FindChatChannelConfig(Channel)
	local Time = TimeUtil.GetServerTimeMS()
	local SendTimeCD = Time + (Config.MsgCD or 1000)

	ChannelVM:SetSendTimeCD(SendTimeCD)
	self.SendTimeCD = SendTimeCD
end

function ChatVM:IsPrivateChatCurrent()
	return self.CurChannel == ChatChannel.Person
end

function ChatVM:GetCurInputMsgMaxLength()
	local Config = ChatUtil.FindChatChannelConfig(self.CurChannel) or {}
	return Config.MsgLength or 999 
end

function ChatVM:CheckInputMsgLengthLimit(Text)
	local MaxLen = self:GetCurInputMsgMaxLength()
	if MaxLen < CommonUtil.GetStrLen(Text) then
		Text = CommonUtil.SubStr(Text, 1, MaxLen)
		return false, Text
	end

	return true 
end

function ChatVM:ShowChatMainView(Channel, ChannelID, Source, CurOpenViewID, IsOpenEmptyClick)
	-- 检测先锋频道是否已删除
	self:CheckPioneerChannel()

	if nil == Channel then
		Channel = self.CurChannel
		ChannelID = self.CurChannelID
	end

	if nil == Channel 
		or ChatUtil.IsHideChannel(Channel)
		or (Channel == ChatChannel.Pioneer and self:IsHidePioneerChannel()) then
		Channel = ChatChannel.Comprehensive
		ChannelID = nil 
	end

	if Channel == ChatChannel.Comprehensive then
		self:UpdateCompSpeakChannelList()
	end

	self:SetCategory(Channel ~= ChatChannel.Person and ChatCategory.Public or ChatCategory.Private)
	self:SetChannel(Channel, ChannelID, true)
	local Param = {
		Source = Source,
		CurOpenViewID = CurOpenViewID,
		IsOpenEmptyClick = IsOpenEmptyClick,
	}
	UIViewMgr:ShowView(UIViewID.ChatMainPanel, Param)
end

-------------------------------------------------------------------------------------------------
--- 超链接

function ChatVM:TryAddHistoryInfo(ChatMsg)
	if nil == ChatMsg or nil == ChatMsg.Data then
		return
	end

	local MsgData = ChatMsg.Data
	if string.isnilorempty(MsgData.Content) then
		return
	end

	local ParamList = {}
	local SimpleHref, HrefType = self:ParseSimpleHref(MsgData, 1)
    if SimpleHref then
        if HrefType == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_VOICE then --语音处理成纯文本

		elseif HrefType == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_GIF then	-- Gif表情
			local Gif = SimpleHref.Gif
			if Gif then
				self:AddRecentGif(Gif)
			end

			return

        else
            ParamList = MsgData.ParamList or {}
        end
    end

	local VMList = self.HistoryTextVMList

	-- 检查重复
	for k, v in pairs(VMList:GetItems() or {}) do
		if MsgData.Content == v.RawContent then
			VMList:RemoveAt(k)
		end
	end

	-- 检查数量
	local Num = VMList:Length()
	if Num >= ChatDefine.MaxHistoryTextNum then
		VMList:RemoveAt(Num)
	end

	local Info = {
		Content 	= MsgData.Content,
		ParamList 	= ParamList
	}

	VMList:InsertByValue(Info, 1)
end

function ChatVM:AddRecentGif(Gif)
	if nil == Gif then 
		return
	end

	local ID = Gif.ID
	if nil == ID then
		return
	end

	local VMList = self.HistoryGifVMList

	-- 检查重复
	for k, v in pairs(VMList:GetItems() or {}) do
		if ID == v.ID then
			VMList:RemoveAt(k)
		end
	end

	-- 检查数量
	local Num = VMList:Length()
	if Num >= ChatDefine.MaxRecentGifNum then
		VMList:RemoveAt(Num)
	end

	VMList:InsertByValue(Gif, 1)
end

function ChatVM:DeleteRolePublicChannelMsg(RoleID)
	if nil == RoleID then
		return
	end

	local PersonChannel = ChatChannel.Person
	local ComprehensiveChannel = ChatChannel.Comprehensive

	local PredicateFunc = function(e) return e.Sender == RoleID end

	-- 公共频道
	for _, v in ipairs(self.ChannelVMList) do
		local Channel = v:GetChannel()
		if Channel ~= PersonChannel and Channel ~= ComprehensiveChannel then
			v:DeleteChatMsgByPredicate(PredicateFunc)
		end
	end
end

function ChatVM:FilterSystemMsg(SysMsgType)
	self.CurSysMsgType = SysMsgType
	self.ChannelVMSystem:OnFilterChanged()	
end

---更新综合频道发言频道列表
function ChatVM:UpdateCompSpeakChannelList()
	local ItemVMList = self.PublicItemVMList
	if nil == ItemVMList then
		return
	end

	local DataList = {}

	for _, v in ipairs(ItemVMList:GetItems()) do
		local Channel = v.Channel
		if Channel ~= ChatChannel.Comprehensive and Channel ~= ChatChannel.System then
			local ChannelID = v.ChannelID
			local ChannelVM = self:FindChannelVM(Channel, ChannelID)
			if ChannelVM 
				and ChannelVM:GetChatBarWidgetVisible() -- 可发言
				and ChatSetting.IsDisplayInComprehensiveChannel(Channel, ChannelID) then -- 综合频道设置了信息可见 

				table.insert(DataList, {
					Channel = Channel,
					ChannelID = ChannelID,
					Name = v:GetName()
				})
			end
		end
	end

	self.CompSpeakChannelList = DataList 

	if self.CurChannel == ChatChannel.Comprehensive then
		self:UpdateChatBarVisible()
	end
end

function ChatVM:GetSendMsgChannelAndChannelID()
	local Channel = self.CurChannel
	local ChannelID = self.CurChannelID
	if Channel == ChatChannel.Comprehensive then -- 综合频道发言
		Channel = ChatVM.CurCompSpeakChannel
		ChannelID = ChatVM.CurCompSpeakChannelID
	end

	return Channel, ChannelID
end

function ChatVM:GetChannelRealName(Channel, ChannelID)
	if nil == Channel then
		return
	end

	local Ret = nil
	if Channel == ChatChannel.Group then
		Ret = (self:FindChannelItemVM(Channel, ChannelID) or {}).Name
	end

	if string.isnilorempty(Ret) then
		Ret = ChatUtil.GetChannelName(Channel)
	end

	return Ret
end

---------------------------------------------------------------------------------------------------------------
--- 新人频道成员

function ChatVM:UpdateNewbieMemberVMList(RoleIDs)
	if not UIViewMgr:IsViewVisible(UIViewID.ChatNewbieMemberPanel) then
		self:ClearNewbieMemberData()
		return
	end

	if nil == RoleIDs or #RoleIDs <= 0 then
		self:ClearNewbieMemberData()
		return
	end

	local RoleIDList = {}
	local MajorRoleID = MajorUtil.GetMajorRoleID()

	for _, v in ipairs(RoleIDs) do
		if v ~= MajorRoleID then
			table.insert(RoleIDList, v)
		end
	end

	RoleInfoMgr:QueryRoleSimples(RoleIDList, function()
		self.IsQueryingNewbieMember = false

		local DataList = {}

		for _, v in ipairs(RoleIDList) do
			local RoleVM = RoleInfoMgr:FindRoleVM(v)
			if RoleVM then
				table.insert(DataList, RoleVM)
			end
		end

		self.NewbieMemberVMList:UpdateByValues(DataList, SocialDefine.PlayerItemSortFunc)
		self:FilterNewbieMembers(self.NewbieMemberFilterType, true)

		EventMgr:SendEvent(EventID.ChatRefreshNewbieMember)
	end, nil, false)

end

function ChatVM:FilterNewbieMembers(Type, NoCheckSame)
	if nil == Type or self.IsQueryingNewbieMember then
		return
	end

	if NoCheckSame ~= true and Type == self.NewbieMemberFilterType then 
		return
	end

	self.NewbieMemberFilterType = Type

    local Items = {}
	local NewbieMemberType = ChatDefine.NewbieMemberType
    if Type == NewbieMemberType.All then
		Items = self.NewbieMemberVMList:GetItems()
	else
		Items = self.NewbieMemberVMList:FindAll(function(Item) return Item.MemberType == Type end)
    end

	self.ShowingNewbieMemberList:Update(Items)
    self.NewbieMemberEmptyPanelVisible = #Items <= 0
end

function ChatVM:RemoveNewbieMember(RoleID)
	if nil == RoleID then
		return
	end

    local ItemVMList = self.ShowingNewbieMemberList
    if ItemVMList then
        ItemVMList:RemoveByPredicate(function(Item) return Item.RoleID == RoleID end)
    end

    ItemVMList = self.NewbieMemberVMList
    if ItemVMList then
        ItemVMList:RemoveByPredicate(function(Item) return Item.RoleID == RoleID end)
    end
end

function ChatVM:ClearNewbieMemberData()
	self.NewbieMemberEmptyPanelVisible = false 
	self.IsQueryingNewbieMember = false
	self.NewbieMemberFilterType = nil
	self.NewbieMemberVMList:Clear()
	self.ShowingNewbieMemberList:Clear()
end

-------------------------------------------------------------------------------------------------------
---Gif

function ChatVM:UpdateUnlockGifs(IDs)
	if table.is_nil_empty(IDs) then
		return
	end

	if nil == self.UnlockGifIDMap then 
		self.UnlockGifIDMap = {}
	end

	for _, v in ipairs(IDs) do
		self.UnlockGifIDMap[v] = true
	end

    self:UpdateGifUnreadRedDots(IDs)
end

function ChatVM:UpdateGifReadRedDotIDs(IDs)
    self.GifReadRedDotIDMap = table.invert(IDs)
    self:UpdateGifUnreadRedDots(table.indices(self.UnlockGifIDMap))
end

-- 更新Gif未读红点
function ChatVM:UpdateGifUnreadRedDots(UnlockGifIDs)
    local ReadIDMap = self.GifReadRedDotIDMap
    if nil == ReadIDMap then
        return
    end

    for _, v in pairs(UnlockGifIDs) do
        local Cfg = ChatGifCfg:FindCfgByKey(v)
        if Cfg then
            local RedDotID = Cfg.RedDotID or 0
            if RedDotID > 0 and ReadIDMap[RedDotID] == nil then
                RedDotMgr:SetRedDotNodeValueByID(RedDotID, 1, false)
            end
        end
    end
end

function ChatVM:AddGifReadRedDotIDs(RedDotIDs)
    if table.is_nil_empty(RedDotIDs) then
        return
    end

	local IsChanged = false
    local ReadIDMap = self.GifReadRedDotIDMap   

	for _, v in ipairs(RedDotIDs) do
		if nil == ReadIDMap[v] then
			ReadIDMap[v] = true
			RedDotMgr:SetRedDotNodeValueByID(v, 0, false)

			IsChanged = true 
		end
	end

	if IsChanged then
		local ReadIDs = table.indices(ReadIDMap)
		local Str = Json.encode(ReadIDs)
		if Str then 
			_G.ClientSetupMgr:SendSetReq(ClientSetupID.ChatReadGifRedDotIDs, Str)
		end
	end
end

-------------------------------------------------------------------------------------------------------
--- 先锋频道

function ChatVM:CheckPioneerChannel()
	local DeleteTime = self.PioneerChannelDeleteTime
	if nil == DeleteTime then
		return
	end

	local ServerTime = TimeUtil.GetServerLogicTime()
	if ServerTime >= DeleteTime then
		self:DeletePionnerChannel(true)
		return
	end

	local CloseTime = self.PioneerChannelCloseTime
	if CloseTime and ServerTime >= CloseTime then
		self:ClosePionnerChannel(true)
		return
	end
end

--- 更新先锋频道状态
function ChatVM:UpdatePioneerChannelState(State)
	self.PioneerChannelState = State

	local ChatMgr = _G.ChatMgr
	if ChatMgr ~= nil then
		local bDiscard = self:IsInPioneerChannel() ~= true
		ChatMgr:SetPioneerChannelNetPackDiscardFlag(bDiscard)
	end
end

--- 更新先锋频道信息
---@param IsInChannel boolean @是否加入频道
---@param CloseTime number @频道关闭时间(s)
function ChatVM:UpdatePioneerChannelInfo(IsInChannel, CloseTime)
	local ServerTime <const> = TimeUtil.GetServerLogicTime()
	local DeleteTime = CloseTime + ChatDefine.PionnerChannelCloseShowTime
	self.PioneerChannelDeleteTime = DeleteTime

	if ServerTime > DeleteTime then -- 关闭展示时间 7 天后删除
		self:DeletePionnerChannel()

	elseif ServerTime >= CloseTime then
		self:ClosePionnerChannel()

	else
		local State = ChannelState.Joining
		if not IsInChannel then
			State = ChannelState.Exited
		end

		self:UpdatePioneerChannelState(State)

		self.PioneerChannelCloseTime = CloseTime 
		local bShow = ((CloseTime or 0) - ServerTime) < (999 * 24 * 3600)
		if bShow then
			self.PioneerChannelCloseTimeStr = _G.LocalizationUtil.LocalizeStringDate_Timestamp_YMD(CloseTime) 
		else
			self.PioneerChannelCloseTimeStr = ""
		end
		self.PioneerChannelDeleteTimeStr = nil 
		self:FindChannelVM(ChatChannel.Pioneer, nil, true)
		self:UpdatePublicItemVMPionner()
	end

	if self.CurChannel == ChatChannel.Pioneer then
		self:UpdateCurSelectedChannelItem()
		self:UpdateChatInfo()
		EventMgr:SendEvent(EventID.ChatRefreshPioneerPanel)
	end
end

function ChatVM:DeletePionnerChannel( IsShowTips )
	self.PioneerChannelCloseTime = nil 
	self.PioneerChannelDeleteTime = nil
	self.PioneerChannelCloseTimeStr = nil
	self.PioneerChannelDeleteTimeStr = nil

	self:UpdatePioneerChannelState(ChannelState.Deleted)
	self:UpdatePublicItemVMPionner()

	if IsShowTips then
		-- 50168("先锋频道已删除")
		MsgTipsUtil.ShowTips(LSTR(50168))
	end

	-- 清除先锋频道数据
	ChatVM:ClearChannelAllChatMsg(ChatChannel.Pioneer, nil, false)
end

function ChatVM:ClosePionnerChannel( IsShowTips )
	self.PioneerChannelCloseTime = nil 
	self.PioneerChannelCloseTimeStr = nil

	self:UpdatePioneerChannelState(ChannelState.Closed)

	local DeleteTimeStr = nil
	local DeleteTime = self.PioneerChannelDeleteTime
	if DeleteTime then
		DeleteTimeStr = _G.LocalizationUtil.LocalizeStringDate_Timestamp_YMD(DeleteTime)
	end

	self.PioneerChannelDeleteTimeStr = DeleteTimeStr

	if IsShowTips then
		-- 50124("先锋频道已关闭")
		MsgTipsUtil.ShowTips(LSTR(50124))
	end

	self:FindChannelVM(ChatChannel.Pioneer, nil, true)
	self:UpdatePublicItemVMPionner()

	-- 清除先锋频道数据
	ChatVM:ClearChannelAllChatMsg(ChatChannel.Pioneer, nil, false)
end

--- 更新公共频道数据列表中的先锋频道信息
function ChatVM:UpdatePublicItemVMPionner( NoSortPublicItems )
	local ItemVMList = self.PublicItemVMList
	if nil == ItemVMList then
		return
	end

	local State = self.PioneerChannelState
	local Channel = ChatChannel.Pioneer
	local Item = ItemVMList:Find(function(e) return e.Channel == Channel end)
	if State == ChannelState.Deleted then
		if Item ~= nil then
			ItemVMList:Remove(Item)
		end

	else
		if ChatUtil.IsHideChannel(Channel) then
			return
		end

		if nil == Item then
			local Value = { Channel = Channel, SortID = ChatUtil.GetChannelSortID(Channel) }
			if ItemVMList:AddByValue(Value) and NoSortPublicItems ~= false then
				ItemVMList:Sort(PublicChatItemSortFunc)
			end
		end
	end

	self:UpdateCurSelectedChannelItem()
end

function ChatVM:IsClosedPioneerChannel()
	local State = self.PioneerChannelState
	return State == ChannelState.Closed or State == ChannelState.Deleted
end	

function ChatVM:IsInPioneerChannel()
	return self.PioneerChannelState == ChannelState.Joining
end	

function ChatVM:IsHidePioneerChannel()
	if self.PioneerChannelState == ChannelState.Deleted then
		return true
	end

	return ChatUtil.IsHideChannel(ChatChannel.Pioneer) 
end

-------------------------------------------------------------------------------------------------------
---频道排序

function ChatVM:TryInitSettingSortItemVMList()
	local ItemVMList = self.SettingSortItemVMList 
	if nil == ItemVMList or ItemVMList:Length() > 0 then
		return
	end

	local DataList = {}

	for _, v in ipairs(ChatDefine.SettingSortChannels) do
		local Config = ChatUtil.FindChatChannelConfig(v)
		local Info = {}
		Info.Name = Config.Name or ""
		Info.Channel = v
		Info.Pos = ChatUtil.GetChannelPos(v) 
		Info.CannotHide = Config.CannotHide
		Info.IsHide = ChatUtil.IsHideChannel(v)

		table.insert(DataList, Info)
	end

	self.SettingSortItemCount = #DataList
	ItemVMList:UpdateByValues(DataList, SettingItemSortFunc)
end	

function ChatVM:SortSettingSortItemVMList()
	local ItemVMList = self.SettingSortItemVMList 
	if nil == ItemVMList then
		return
	end

	ItemVMList:Sort(SettingItemSortFunc)
end

function ChatVM:SaveSettingSortInfo()
	-- 保存设置
	local ItemVMList = self.SettingSortItemVMList 
	if nil == ItemVMList then
		return
	end

	local HideChannelList = {}
	local PosList = {}

	for k, v in ipairs(ItemVMList:GetItems()) do
		local Channel = v.Channel

		if v.IsHide then
			table.insert(HideChannelList, Channel)
		end

		PosList[Channel] = k
	end

	local IsRebuild = ChatSetting.SaveChannelShowPosMap(PosList)
	IsRebuild = ChatSetting.SaveHideChannels(HideChannelList) or IsRebuild
	if not IsRebuild then
		return
	end

	local PublicItemVMList = self.PublicItemVMList 
	if nil == PublicItemVMList then
		return
	end

	local DataList = {} 

	for _, v in ipairs(ChatDefine.DefaultPublicChannels) do
		if not ChatUtil.IsHideChannel(v) then -- 剔除掉隐藏的频道
			table.insert(DataList, {
				Channel = v,
				SortID = ChatUtil.GetChannelSortID(v),
			})
		end
	end

	PublicItemVMList:UpdateByValues(DataList)

	-- 组队
	self:UpdateTeamChatData(false)

	-- 通讯贝
	self:UpdateGroupChannelItems(false)

	-- 先锋频道
	self:UpdatePublicItemVMPionner(false)

	PublicItemVMList:Sort(PublicChatItemSortFunc)
end

-------------------------------------------------------------------------------------------------------
---主界面侧标拦（最新私聊信息）

function ChatVM:TryAddSidebarItem(MsgItemVM)
	if nil == MsgItemVM then
		return
	end

	self.LatestPrivateChatMsgItemVM = MsgItemVM

    if SidebarMgr:GetSidebarItemVM(SidebarType) ~= nil then
        return
    end

    local StartTime = TimeUtil.GetServerTime()
    SidebarMgr:AddSidebarItem(SidebarType, StartTime, nil, nil, false)

	local ItemVM = SidebarMgr:GetSidebarItemVM(SidebarType)
	if ItemVM ~= nil then
		UIViewMgr:ShowView(UIViewID.SidebarPrivateChat, ItemVM)
	end
end

function ChatVM:ClearSidebarItem(IsHideWin)
	if IsHideWin then
		local SidebarViewID = UIViewID.SidebarPrivateChat
		if UIViewMgr:IsViewVisible(SidebarViewID) then
			UIViewMgr:HideView(SidebarViewID)
		end
	end

	self.LatestPrivateChatMsgItemVM = nil
	SidebarMgr:RemoveSidebarItem(SidebarType)
end

-------------------------------------------------------------------------------------------------------
--- 聊天设置提示小红点

function ChatVM:UpdateSetTipsRedDot(b)
    self.IsShowSetTips = b 
    RedDotMgr:SetRedDotNodeValueByID(ChatDefine.SetTipsRedDotID, b and 1 or 0, false)
end

function ChatVM:ClearSetTipsRedDot()
    if not self.IsShowSetTips then
        return
    end

	self:UpdateSetTipsRedDot(false)
    _G.ClientSetupMgr:SendSetReq(ClientSetupID.ChatShownChatSetTips, "1")
end

function ChatVM:SetCurClickedMsgItem(Item)
	self.CurClickedMsgItem = Item
end

function ChatVM:SetIsMsgEmpty(Value)
	self.NoMsgTipsVisible = Value
end

function ChatVM:UpdateMsgIsEmpty()
	local b = self:GetChatBarWidgetVisible()
	if not b then
		local CurChannel = self.CurChannel
		if CurChannel == ChatChannel.Newbie then
			b = _G.NewbieMgr:IsInNewbieChannel()
		else
			b = CurChannel == ChatChannel.Team or CurChannel == ChatChannel.SceneTeam
		end
	end

	self:SetIsMsgEmpty(self.ChatMsgItemVMList == nil or (b and self.ChatMsgItemVMList:Length() <= 0))
end

---@private
function ChatVM:OnChatMsgListUpdate()
	self.MsgDataUpdateCount = (self.MsgDataUpdateCount or 0) + 1
	self:UpdateMsgIsEmpty()
end

function ChatVM:SetChatBarVisible(Value)
	self.ChatBarWidgetVisible = Value
end

return ChatVM