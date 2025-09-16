---
--- Author: xingcaicao
--- DateTime: 2024-12-19 20:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatVM = require("Game/Chat/ChatVM")
local ChatSetting = require("Game/Chat/ChatSetting")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")

local LSTR = _G.LSTR
local ChatChannel = ChatDefine.ChatChannel
local SysMsgType = ChatDefine.SysMsgType

---@class ChatSettingComprehensiveChannelPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnReset UFButton
---@field CheckBoxArea CommSingleBoxView
---@field CheckBoxArmy CommSingleBoxView
---@field CheckBoxGroup CommSingleBoxView
---@field CheckBoxNearby CommSingleBoxView
---@field CheckBoxNewbie CommSingleBoxView
---@field CheckBoxPioneer CommSingleBoxView
---@field CheckBoxRecruit CommSingleBoxView
---@field CheckBoxSysBattle CommSingleBoxView
---@field CheckBoxSysNotice CommSingleBoxView
---@field CheckBoxSysStory CommSingleBoxView
---@field CheckBoxSystem CommSingleBoxView
---@field CheckBoxTeam CommSingleBoxView
---@field CommInforBtn CommInforBtnView
---@field FTextArea UFTextBlock
---@field FTextArmy UFTextBlock
---@field FTextCompDesc UFTextBlock
---@field FTextGroupChannel UFTextBlock
---@field FTextNearby UFTextBlock
---@field FTextNewbie UFTextBlock
---@field FTextNormalChannel UFTextBlock
---@field FTextPioneer UFTextBlock
---@field FTextRecruit UFTextBlock
---@field FTextSysBattle UFTextBlock
---@field FTextSysNotice UFTextBlock
---@field FTextSysStory UFTextBlock
---@field FTextSystemChannel UFTextBlock
---@field FTextTeam UFTextBlock
---@field ImgGroupMask UFImage
---@field ImgSystemMask UFImage
---@field PioneerPanel UFCanvasPanel
---@field TableViewGroup UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingComprehensiveChannelPanelView = LuaClass(UIView, true)

function ChatSettingComprehensiveChannelPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnReset = nil
	--self.CheckBoxArea = nil
	--self.CheckBoxArmy = nil
	--self.CheckBoxGroup = nil
	--self.CheckBoxNearby = nil
	--self.CheckBoxNewbie = nil
	--self.CheckBoxPioneer = nil
	--self.CheckBoxRecruit = nil
	--self.CheckBoxSysBattle = nil
	--self.CheckBoxSysNotice = nil
	--self.CheckBoxSysStory = nil
	--self.CheckBoxSystem = nil
	--self.CheckBoxTeam = nil
	--self.CommInforBtn = nil
	--self.FTextArea = nil
	--self.FTextArmy = nil
	--self.FTextCompDesc = nil
	--self.FTextGroupChannel = nil
	--self.FTextNearby = nil
	--self.FTextNewbie = nil
	--self.FTextNormalChannel = nil
	--self.FTextPioneer = nil
	--self.FTextRecruit = nil
	--self.FTextSysBattle = nil
	--self.FTextSysNotice = nil
	--self.FTextSysStory = nil
	--self.FTextSystemChannel = nil
	--self.FTextTeam = nil
	--self.ImgGroupMask = nil
	--self.ImgSystemMask = nil
	--self.PioneerPanel = nil
	--self.TableViewGroup = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingComprehensiveChannelPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBoxArea)
	self:AddSubView(self.CheckBoxArmy)
	self:AddSubView(self.CheckBoxGroup)
	self:AddSubView(self.CheckBoxNearby)
	self:AddSubView(self.CheckBoxNewbie)
	self:AddSubView(self.CheckBoxPioneer)
	self:AddSubView(self.CheckBoxRecruit)
	self:AddSubView(self.CheckBoxSysBattle)
	self:AddSubView(self.CheckBoxSysNotice)
	self:AddSubView(self.CheckBoxSysStory)
	self:AddSubView(self.CheckBoxSystem)
	self:AddSubView(self.CheckBoxTeam)
	self:AddSubView(self.CommInforBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingComprehensiveChannelPanelView:OnInit()
	self.IsInitConstInfo = false 

	self.TableAdapterGroup = UIAdapterTableView.CreateAdapter(self, self.TableViewGroup)

	local ChannelInfo = {
		{ CheckBox = self.CheckBoxRecruit, 	Channel = ChatChannel.Recruit },
		{ CheckBox = self.CheckBoxArmy, 	Channel = ChatChannel.Army },
		{ CheckBox = self.CheckBoxTeam, 	Channel = ChatChannel.Team },
		{ CheckBox = self.CheckBoxNewbie, 	Channel = ChatChannel.Newbie },
		{ CheckBox = self.CheckBoxNearby, 	Channel = ChatChannel.Nearby },
		{ CheckBox = self.CheckBoxArea, 	Channel = ChatChannel.Area },
		{ CheckBox = self.CheckBoxSystem, 	Channel = ChatChannel.System },
		{ CheckBox = self.CheckBoxGroup, 	Channel = ChatChannel.Group },
		{ CheckBox = self.CheckBoxPioneer, 	Channel = ChatChannel.Pioneer },
	}

	self.ChannelInfo = ChannelInfo

	for i, v in ipairs(ChannelInfo) do
		v.CheckBox:SetStateChangedCallback(self, self.OnStateChangedChannel, i)
	end

	local SystemMsgTypeInfo = {
		{ CheckBox = self.CheckBoxSysBattle, MsgType = SysMsgType.Battle },
		{ CheckBox = self.CheckBoxSysNotice, MsgType = SysMsgType.Notice },
		{ CheckBox = self.CheckBoxSysStory,  MsgType = SysMsgType.Story },
	}

	self.SystemMsgTypeInfo = SystemMsgTypeInfo

	for i, v in ipairs(SystemMsgTypeInfo) do
		v.CheckBox:SetStateChangedCallback(self, self.OnStateChangedSysMsgType, i)
	end
end

function ChatSettingComprehensiveChannelPanelView:OnDestroy()

end

function ChatSettingComprehensiveChannelPanelView:OnShow()
	self:InitConstInfo()

	-- 通讯贝
	local GroupChannel = ChatDefine.ChatChannel.Group
	local Items = ChatVM.PublicItemVMList:GetItems()
	local GroupList = table.find_all_by_predicate(Items, function(e) return e.Channel == GroupChannel end)
	self.TableAdapterGroup:UpdateAll(GroupList)

	-- 综合频道设置
	self:UpdateChannelCheckBox(ChatSetting.GetComprehensiveChannels())

	-- 系统频道
	self:UpdateSystemChannelSubCheckBox(ChatSetting.GetComprehensiveChannelSysMsgTypes())

	-- 屏蔽的通讯贝
	self.UncheckedGroupIDs = table.shallowcopy(ChatSetting.GetComprehensiveChannelBlockGroupIDs() or {})

	-- 先锋频道
	local IsClosedPioneer = ChatVM:IsClosedPioneerChannel()
	UIUtil.SetIsVisible(self.PioneerPanel, not IsClosedPioneer)
end

function ChatSettingComprehensiveChannelPanelView:OnHide()
	local Channels = self.CheckedChannels
	local IsUpdateChannels = Channels ~= nil and ChatSetting.SetComprehensiveChannels(Channels) or false

	local MsgTypes = self.CheckedSysMsgTypes 
	local IsUpdateSysMsgTypes = MsgTypes ~= nil and ChatSetting.SetComprehensiveChannelSysMsgTypes(MsgTypes) or false

	local GroupIDs = self.UncheckedGroupIDs
	local IsUpdateGroup = GroupIDs ~= nil and ChatSetting.SetComprehensiveChannelBlockGroupIDs(GroupIDs) or false

	if IsUpdateChannels 
		or (IsUpdateSysMsgTypes and self.CheckBoxSystem:GetChecked())  
		or (IsUpdateGroup and self.CheckBoxGroup:GetChecked())  then
		ChatVM:OnComprehensiveChannelsChange()
	end
end

function ChatSettingComprehensiveChannelPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickedBtnReset)
end

function ChatSettingComprehensiveChannelPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LinkShellDestory, self.OnEventGroupDestory) -- 退出/被踢/解散
	self:RegisterGameEvent(EventID.ChatSettingComprehensiveChannelBlockGroup, self.OnEventBlockGroup)
end

function ChatSettingComprehensiveChannelPanelView:OnRegisterBinder()

end

function ChatSettingComprehensiveChannelPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	self.FTextCompDesc:SetText(LSTR(50108)) 		-- "综合频道将显示以下内容"
	self.FTextNormalChannel:SetText(LSTR(50109)) 	-- "常规频道"
	self.FTextSystemChannel:SetText(LSTR(50110)) 	-- "系统频道"
	self.FTextGroupChannel:SetText(LSTR(50111)) 	-- "通讯贝"

	self.FTextArmy:SetText(LSTR(50113))		-- "部队频道"
	self.FTextTeam:SetText(LSTR(50114))		-- "队伍频道"
	self.FTextNewbie:SetText(LSTR(50115))	-- "新人频道"
	self.FTextNearby:SetText(LSTR(50116))	-- "附近频道"
	self.FTextArea:SetText(LSTR(50117))		-- "区域频道"
	self.FTextPioneer:SetText(LSTR(50099))	-- "先锋频道"
	self.FTextRecruit:SetText(LSTR(50100))	-- "招募频道"

	self.FTextSysBattle:SetText(LSTR(50118)) -- "战斗信息"
	self.FTextSysNotice:SetText(LSTR(50119)) -- "通知信息"
	self.FTextSysStory:SetText(LSTR(50120))	 -- "剧情信息"
end

function ChatSettingComprehensiveChannelPanelView:UpdateMaskVisible(Channel, IsChecked)
	if Channel == ChatChannel.System then 
		UIUtil.SetIsVisible(self.ImgSystemMask, not IsChecked, true)
	elseif Channel == ChatChannel.Group then
		UIUtil.SetIsVisible(self.ImgGroupMask, not IsChecked, true)
	end
end

function ChatSettingComprehensiveChannelPanelView:UpdateChannelCheckBox(Value)
	self.CheckedChannels = Value

	for _, v in ipairs(self.ChannelInfo) do
		local Channel = v.Channel
		local IsChecked = nil ~= table.find_item(Value, Channel)
		v.CheckBox:SetChecked(IsChecked, false)

		self:UpdateMaskVisible(Channel, IsChecked)
	end
end

function ChatSettingComprehensiveChannelPanelView:UpdateSystemChannelSubCheckBox(Value)
	self.CheckedSysMsgTypes = Value

	for _, v in ipairs(self.SystemMsgTypeInfo) do
		local MsgType = v.MsgType
		local IsChecked = nil ~= table.find_item(Value, MsgType)
		v.CheckBox:SetChecked(IsChecked, false)
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatSettingComprehensiveChannelPanelView:OnStateChangedChannel(IsChecked, Index)
	local CheckedList = self.CheckedChannels
	if nil == CheckedList then
		return
	end

	local Info = self.ChannelInfo[Index]
	if nil == Info then
		return
	end

	local Channel = Info.Channel
	if nil == Channel then
		return
	end

	if IsChecked then
		table.insert(CheckedList, Channel)
	else
		table.remove_item(CheckedList, Channel)
	end

	self:UpdateMaskVisible(Channel, IsChecked)
end

function ChatSettingComprehensiveChannelPanelView:OnStateChangedSysMsgType(IsChecked, Index)
	local CheckedList = self.CheckedSysMsgTypes
	if nil == CheckedList then
		return
	end

	local Info = self.SystemMsgTypeInfo[Index]
	if nil == Info then
		return
	end

	local MsgType = Info.MsgType
	if nil == MsgType then
		return
	end

	if IsChecked then
		table.insert(CheckedList, MsgType)
	else
		table.remove_item(CheckedList, MsgType)
	end

	if #CheckedList <= 0 then
		self.CheckBoxSystem:SetChecked(false, true)
	end
end

function ChatSettingComprehensiveChannelPanelView:OnClickedBtnReset()
	self:UpdateChannelCheckBox(table.shallowcopy(ChatDefine.ChatDefaultSetting.ComprehensiveChannels))
	self:UpdateSystemChannelSubCheckBox(table.shallowcopy(ChatDefine.ChatDefaultSetting.ComprehensiveChannelSysMsgTypes))

	self.UncheckedGroupIDs = {}
	EventMgr:SendEvent(EventID.ChatSettingComprehensiveChannelBlockGroupClear)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 


function ChatSettingComprehensiveChannelPanelView:OnEventGroupDestory(LinkShellID)
	if LinkShellID then
		table.remove_item(self.UncheckedGroupIDs, LinkShellID)
	end
end

function ChatSettingComprehensiveChannelPanelView:OnEventBlockGroup(GroupID, IsDisplay)
	local UncheckedList = self.UncheckedGroupIDs
	if nil == UncheckedList or nil == GroupID then
		return
	end


	if IsDisplay then
		table.remove_item(UncheckedList, GroupID)

	else
		if LinkShellVM:QueryLinkShell(GroupID) then
			table.insert(UncheckedList, GroupID)
		end
	end

	if #UncheckedList >= self.TableAdapterGroup:GetNum() then
		self.CheckBoxGroup:SetChecked(false, true)
	end
end

return ChatSettingComprehensiveChannelPanelView