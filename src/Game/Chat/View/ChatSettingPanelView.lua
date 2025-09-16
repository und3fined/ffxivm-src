---
--- Author: xingcaicao
--- DateTime: 2024-12-18 18:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatUtil = require("Game/Chat/ChatUtil")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local ChatVM = require("Game/Chat/ChatVM")

local LSTR = _G.LSTR
local ChatChannel = ChatDefine.ChatChannel

local TabType = {
	Comprehensive = 1001,
	Color = 1002,
	Sort = 1003,
	Danmaku = 1004,
	Privacy = 1005,
}

local ColorChildren = {
	{
		Key = ChatChannel.Pioneer,
		Name = ChatUtil.GetChannelName(ChatChannel.Pioneer) , --"先锋"
	},
	{
		Key = ChatChannel.Recruit,
		Name = ChatUtil.GetChannelName(ChatChannel.Recruit) , --"招募"
	},
	{
		Key = ChatChannel.Newbie,
		Name = ChatUtil.GetChannelName(ChatChannel.Newbie) , --"新人"
	},
	{
		Key = ChatChannel.Army,
		Name = ChatUtil.GetChannelName(ChatChannel.Army) , --"部队"
	},
	{
		Key = ChatChannel.Nearby,
		Name = ChatUtil.GetChannelName(ChatChannel.Nearby) , --"附近"				
	},
	{
		Key = ChatChannel.Area,
		Name = ChatUtil.GetChannelName(ChatChannel.Area) , --"区域"				
	},
	{
		Key = ChatChannel.Team,
		Name = ChatUtil.GetChannelName(ChatChannel.Team) , --"队伍"				
	},
	{
		Key = ChatChannel.System,
		Name = ChatUtil.GetChannelName(ChatChannel.System) , --"系统"				
	},																				
}

local MainTabs = {
    {
        Key = TabType.Comprehensive,
        Name = LSTR(50105), --"综合频道显示",
    },
    {
        Key = TabType.Color,
        Name = LSTR(50106), --"频道颜色"
    },
	{
        Key = TabType.Sort,
        Name = LSTR(50024), --"频道排序"
    },
    {
        Key = TabType.Danmaku,
        Name = LSTR(50177), --"聊天与弹幕设置"
    },
    {
        Key = TabType.Privacy,
        Name = LSTR(50178), --"隐私防护设置"
    },
}

---@class ChatSettingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field ColorPanel ChatSettingColorPanelView
---@field CommMenu CommMenuView
---@field ComprehensivePanel ChatSettingComprehensiveChannelPanelView
---@field DanmakuPanel ChatSettingDanmakuPanelView
---@field PrivacyPanel ChatSettingPrivacyPanelView
---@field SortPanel ChatSettingChannelSortPanelView
---@field AnimMenuSwitch UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingPanelView = LuaClass(UIView, true)

function ChatSettingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.ColorPanel = nil
	--self.CommMenu = nil
	--self.ComprehensivePanel = nil
	--self.DanmakuPanel = nil
	--self.PrivacyPanel = nil
	--self.SortPanel = nil
	--self.AnimMenuSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.ColorPanel)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.ComprehensivePanel)
	self:AddSubView(self.DanmakuPanel)
	self:AddSubView(self.PrivacyPanel)
	self:AddSubView(self.SortPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingPanelView:OnInit()
	self.BG:SetTitleText(LSTR(50104)) -- "社交设置"
end

function ChatSettingPanelView:OnDestroy()

end

function ChatSettingPanelView:OnShow()
	-- 清理设置小红点
	ChatVM:ClearSetTipsRedDot()

	self.CurKey = nil

	local Params = self.Params or {}
	self.Channel = Params.Channel
	self.ChannelID = Params.ChannelID

	local Items, Key = self:GetMenuItems()
	self.CommMenu:UpdateItems(Items, false)
	self.CommMenu:SetSelectedKey(Key, true)
end

function ChatSettingPanelView:GetMenuItems()
	local SelectedKey = nil 
	local Channel = self.Channel
	if Channel == ChatChannel.Comprehensive then
		SelectedKey = TabType.Comprehensive
	end

	local Children = {}
	local MenuList = {}

	-- 先锋频道
	local IsAddPioneer = not ChatVM:IsClosedPioneerChannel()

	for _, v in ipairs(ColorChildren) do
		local Key = v.Key
		if Key ~= ChatChannel.Pioneer or IsAddPioneer then
			local Name = v.Name or ""
			table.insert(Children, {Key = Key, Name = Name})
			table.insert(MenuList, {Key = Key, Name = Name, Channel = Key})

			if nil == SelectedKey and Channel == Key then
				SelectedKey = Key 
			end
		end
	end
	
	-- 添加通讯贝
	local ChannelID = self.ChannelID
	local ChannelGroup = ChatChannel.Group
    local LinkShellItems = LinkShellVM.LinkShellItemVMList:GetItems() or {}

    for k, v in ipairs(LinkShellItems) do
        if v:IsJoined() then
			local Key = 10000 + k -- 此处不能使用通讯贝ID（超过int32数值范围)
			local Name = v.Name or ""
			local ID = v.ID
            table.insert(Children, {Key = Key, Name = Name})
			table.insert(MenuList, {Key = Key, Name = Name, Channel = ChannelGroup, ChannelID = ID})

			if nil == SelectedKey and Channel == ChannelGroup and ChannelID == ID then
				SelectedKey = Key
			end
        end
    end

	--缓存信息
	self.ColorMenuList = MenuList

	local ColorTab = table.find_by_predicate(MainTabs, function(e) 
		return e.Key == TabType.Color
	end)

	ColorTab.Children = Children

	return MainTabs, SelectedKey or TabType.Comprehensive
end

function ChatSettingPanelView:OnHide()
	self.CommMenu:CancelSelected()
	self.CurKey = nil
	self.ColorMenuList = nil 
end

function ChatSettingPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnClickedEvent(self,self.BG.ButtonClose, self.OnBtnClickedClose)
end

function ChatSettingPanelView:OnRegisterGameEvent()

end

function ChatSettingPanelView:OnRegisterBinder()

end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatSettingPanelView:OnSelectionChangedCommMenu(_, ItemData)
	if nil == ItemData then
		return
	end

	local Key = ItemData:GetKey()
	if Key == self.CurKey then
		return
	end

	self.CurKey = Key

	UIUtil.SetIsVisible(self.ComprehensivePanel, Key == TabType.Comprehensive)
	UIUtil.SetIsVisible(self.SortPanel, Key == TabType.Sort)
	UIUtil.SetIsVisible(self.DanmakuPanel, Key == TabType.Danmaku)
	UIUtil.SetIsVisible(self.PrivacyPanel, Key == TabType.Privacy)

	if Key ~= TabType.Comprehensive and Key ~= TabType.Sort and Key ~= TabType.Danmaku and Key ~= TabType.Privacy then
		UIUtil.SetIsVisible(self.ColorPanel, true)

		local Info = table.find_by_predicate(self.ColorMenuList or {}, function(e) return e.Key == Key end)
		if Info then
			self.ColorPanel:SetMenuInfo(Info)
		end

	else
		UIUtil.SetIsVisible(self.ColorPanel, false)
	end

	self:PlayAnimation(self.AnimMenuSwitch)
end

function ChatSettingPanelView:OnBtnClickedClose()
	_G.ChatMgr:ShowChatView(self.Channel, self.ChannelID)
end

return ChatSettingPanelView