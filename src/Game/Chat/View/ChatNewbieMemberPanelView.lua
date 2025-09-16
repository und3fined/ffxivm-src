---
--- Author: xingcaicao
--- DateTime: 2024-12-24 19:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatVM = require("Game/Chat/ChatVM")
local ChatMgr = require("Game/Chat/ChatMgr")
local NewbieMgr = require("Game/Newbie/NewbieMgr")
local MajorUtil = require("Utils/MajorUtil")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")

local LSTR = _G.LSTR
local FLOG_WARNING = _G.FLOG_WARNING
local NewbieMemberType = ChatDefine.NewbieMemberType 
local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify

---@class ChatNewbieMemberPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ComEmptyTips CommBackpackEmptyView
---@field CommDropDownList CommDropDownListView
---@field CommSidebarTabFrame CommSidebarTabFrameView
---@field FBtnQuit UFButton
---@field FBtnRefresh UFButton
---@field TableViewList UTableView
---@field TextRefresh URichTextBox
---@field TextTitleName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatNewbieMemberPanelView = LuaClass(UIView, true)

function ChatNewbieMemberPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ComEmptyTips = nil
	--self.CommDropDownList = nil
	--self.CommSidebarTabFrame = nil
	--self.FBtnQuit = nil
	--self.FBtnRefresh = nil
	--self.TableViewList = nil
	--self.TextRefresh = nil
	--self.TextTitleName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatNewbieMemberPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ComEmptyTips)
	self:AddSubView(self.CommDropDownList)
	self:AddSubView(self.CommSidebarTabFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatNewbieMemberPanelView:OnInit()
	self.IsInitConstInfo = false 
	self.CommSidebarTabFrame.BtnClose:SetCallback(self, self.OnClickClose)

    self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	self.Binders = {
		{ "NewbieMemberEmptyPanelVisible", UIBinderSetIsVisible.New(self, self.ComEmptyTips) },
		{ "ShowingNewbieMemberList", UIBinderUpdateBindableList.New(self, self.TableAdapterList) },
	}
end

function ChatNewbieMemberPanelView:OnDestroy()

end

function ChatNewbieMemberPanelView:OnShow()
	self:InitConstInfo()

	ChatMgr:SendQueryNewbieMembers()
end

function ChatNewbieMemberPanelView:OnHide()
	ChatVM:ClearNewbieMemberData()
	self.CommDropDownList:CancelSelected()
	self.CommDropDownList:ClearItems()

	TeamInviteVM:ClearInvitedRoleInfo()
end

function ChatNewbieMemberPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDownList, self.OnSelectionChangedDropDownList)

	UIUtil.AddOnClickedEvent(self, self.FBtnQuit, self.OnClickedButtonQuit)
	UIUtil.AddOnClickedEvent(self, self.FBtnRefresh, self.OnClickedButtonRefresh)
end

function ChatNewbieMemberPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamInviteJoin, self.OnGameEventTeamInviteJoin)
	self:RegisterGameEvent(EventID.ChatRefreshNewbieMember, self.OnEventRefreshNewbieMember)
    self:RegisterGameEvent(EventID.ChatIsJoinNewbieChannelChanged, self.OnEventIsJoinNewbieChannelChanged)
end

function ChatNewbieMemberPanelView:OnRegisterBinder()
	self:RegisterBinders(ChatVM, self.Binders)
end

function ChatNewbieMemberPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	self.TextTitleName:SetText(LSTR(50142)) -- "新人频道参与者"
	self.TextRefresh:SetText(LSTR(50146)) -- "刷新"
	self.ComEmptyTips:SetTipsContent(LSTR(50089)) -- "暂无消息"

end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function ChatNewbieMemberPanelView:OnGameEventTeamInviteJoin( RoleID )
	if nil == RoleID then
		return
	end

	TeamInviteVM:AddInvitedRole(RoleID)
end

function ChatNewbieMemberPanelView:OnEventRefreshNewbieMember()
	local CommDropDownList = self.CommDropDownList
	if CommDropDownList:IsEmpty() then
		local Idx = 1
		local DefaultType = nil
		local Identity = OnlineStatusUtil.QueryMentorRelatedIdentity((MajorUtil.GetMajorRoleVM() or {}).Identity)
		if Identity == OnlineStatusIdentify.OnlineStatusIdentifyNewHand
			or Identity == OnlineStatusIdentify.OnlineStatusIdentifyReturner then -- 新人、回归者
			DefaultType = NewbieMemberType.Mentor

		elseif Identity == OnlineStatusIdentify.OnlineStatusIdentifyMentor then -- 指导者
			DefaultType = NewbieMemberType.NewcomerAndReturner
		end

		-- 类型下拉框
		local DataList = {}

		for k, v in ipairs(ChatDefine.NewbieMemberFilterConfig) do
			local Type = v.Type
			table.insert(DataList, {ID = Type, Name = LSTR(v.NameUkey)})

			if DefaultType and DefaultType == Type then
				Idx = k
			end
		end

		self.CommDropDownList:UpdateItems(DataList, Idx)
	end

	self.TableAdapterList:ScrollToTop()
end

function ChatNewbieMemberPanelView:OnEventIsJoinNewbieChannelChanged()
	if not NewbieMgr:IsInNewbieChannel() then
		self:Hide()
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatNewbieMemberPanelView:OnSelectionChangedDropDownList(Index, ItemData)
	if nil == ItemData then 
		return
	end

	ChatVM:FilterNewbieMembers(ItemData.ID)
end

function ChatNewbieMemberPanelView:OnClickedButtonQuit()
	if NewbieMgr:IsMajorNewcomerOrReturner() then
		local BackToGame = function()  
			if self.HelpInfoMidWinView ~= nil then
				self.HelpInfoMidWinView:Hide()
				self.HelpInfoMidWinView = nil
			end
		end

		local ConfirmFun = function() 
			if self.HelpInfoMidWinView ~= nil then
				self.HelpInfoMidWinView:Hide()
				self.HelpInfoMidWinView = nil
				NewbieMgr:QuitChannelReq()
				self:Hide()
			end
		end
		-- 10004 "提 示"    50130  "<span color="#d96c6cff">退出新人频道不会令“新人”或者“回归者”状态解除。</>"   50131 "是否退出新人频道？退出后只有再次收到指导者的邀请时才能再次加入新人频道。"
		local Cfgs = {{ HelpName = LSTR(10004), SecTitle = LSTR(50131), SecContent = {} }, {SecTitle = "", SecContent = { { SecContent = LSTR(50130) } }} }
		-- 10010 "退 出"   10003 "取 消"
		local Params = { Cfgs = Cfgs, ShowBtn = true, LeftBtnText = LSTR(10010), RightBtnText = LSTR(10003), View = self, RightBtnCB = BackToGame, LeftBtnCB = ConfirmFun, CloseBtnCB = nil, IsMentorResign = true }
		self.HelpInfoMidWinView = _G.UIViewMgr:ShowView(_G.UIViewID.HelpInfoMidWinView, Params)
	else
		NewbieMgr:QuitChannelReq()
		self:Hide()
	end
end

function ChatNewbieMemberPanelView:OnClickedButtonRefresh()
	if ChatVM.IsQueryingNewbieMember then
		FLOG_WARNING("ChatNewbieMemberPanelView.OnClickedButtonRefresh: is querying data")
		return
	end


	ChatVM.ShowingNewbieMemberList:Clear()
	ChatMgr:SendQueryNewbieMembers()
end

function ChatNewbieMemberPanelView:OnClickClose()
	self:Hide()
	ChatMgr:ShowChatView(ChatDefine.ChatChannel.Newbie)
end

return ChatNewbieMemberPanelView