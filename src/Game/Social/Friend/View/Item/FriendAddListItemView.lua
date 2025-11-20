---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local GameStyleCfg = require("TableCfg/GameStyleCfg")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local MajorUtil = require("Utils/MajorUtil")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local TeamRecruitMgr = require("Game/TeamRecruit/TeamRecruitMgr")

local FVector2D = _G.UE.FVector2D
local MaxGameStyleCount = PersonInfoDefine.MaxGameStyleCount

---@class FriendAddListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAddFriend UFButton
---@field BtnChat UFButton
---@field BtnTeamInvite UFButton
---@field BtnTeamRecruitShare UFButton
---@field CommPlayerItem CommPlayerItemView
---@field HorOptBtns UFHorizontalBox
---@field ImgSuc UFImage
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TableViewStyle UTableView
---@field TextSignature UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendAddListItemView = LuaClass(UIView, true)

function FriendAddListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAddFriend = nil
	--self.BtnChat = nil
	--self.BtnTeamInvite = nil
	--self.BtnTeamRecruitShare = nil
	--self.CommPlayerItem = nil
	--self.HorOptBtns = nil
	--self.ImgSuc = nil
	--self.ProfSlot = nil
	--self.TableViewStyle = nil
	--self.TextSignature = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendAddListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerItem)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendAddListItemView:OnInit()
	self.TableAdapterStyle = UIAdapterTableView.CreateAdapter(self, self.TableViewStyle, self.OnSelectChangedStyle, true)

	self.Binders = {
		{ "IsFriend", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateBtnsVisible) },
	}

	self.BindersTeamInviteVM = {
		{ "CurInvitedRoleNum", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateBtnsVisible) },
	}
end

function FriendAddListItemView:OnDestroy()

end

function FriendAddListItemView:OnShow()

end

function FriendAddListItemView:OnHide()

end

function FriendAddListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnClickButtonChat)
	UIUtil.AddOnClickedEvent(self, self.BtnAddFriend, self.OnClickButtonAddFriend)
	UIUtil.AddOnClickedEvent(self, self.BtnTeamInvite, self.OnClickButtonTeamInvite)
	UIUtil.AddOnClickedEvent(self, self.BtnTeamRecruitShare, self.OnClickButtonRecruitShare)
end

function FriendAddListItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.TeamRecruitStateChanged, self.OnEventMsgTeamRecruitStateChanged)
    self:RegisterGameEvent(EventID.TeamRecruitShareToPlayerSuc, self.OnEventMsgShareTeamRecruitToPlayerSuc)
end

function FriendAddListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local EntryVM = Params.Data
	self.RoleID = EntryVM.RoleID
	self.ViewModel = EntryVM 

	-- 玩家未设置游戏风格时，显示签名
	local StyleIDs = EntryVM.PlayStyleIDs or {}
	self.TextSignature:SetText(#StyleIDs <= 0 and EntryVM.Signature or "")

	-- 游戏风格
	local Data = {}

	for k, v in ipairs(StyleIDs) do
		if k > MaxGameStyleCount then
			break
		end

		local Cfg = GameStyleCfg:GetGameStyleCfg(v) 
		if Cfg then
			table.insert(Data, {ID = Cfg.ID, Desc = Cfg.Desc, Icon = Cfg.Icon})
		end
	end

	self.TableAdapterStyle:UpdateAll(Data)

	self:RegisterBinders(EntryVM, self.Binders)
	self:RegisterBinders(TeamInviteVM, self.BindersTeamInviteVM)
end

function FriendAddListItemView:OnUpdateBtnsVisible()
	local VM = self.ViewModel or {}
	local RoleID = VM.RoleID
	if MajorUtil.IsMajorByRoleID(RoleID) then
		UIUtil.SetIsVisible(self.HorOptBtns, false)
		return
	end

	local BtnAddFriendVisible = false 
	local BtnInvitedVisible = false 
	local BtnRecruitVisible = false
	local ImgSucVisible = false 

	local IsFriend = VM.IsFriend
	if IsFriend then
		if VM.IsOnline then
			if TeamRecruitMgr:IsRecruiting() then -- 招募中
				local IsShared = RoleID and table.contain(TeamRecruitVM.CurSharedRoleIDs, RoleID) 
				BtnRecruitVisible = not IsShared
				ImgSucVisible = IsShared

			else
				local IsInvited = RoleID and table.contain(TeamInviteVM.CurInvitedRoleIDs, RoleID) 
				BtnInvitedVisible = not IsInvited 
				ImgSucVisible = IsInvited
			end
		end
	else
		BtnAddFriendVisible = true 
	end

	UIUtil.SetIsVisible(self.BtnAddFriend, BtnAddFriendVisible, BtnAddFriendVisible)
	UIUtil.SetIsVisible(self.BtnTeamInvite, BtnInvitedVisible, BtnInvitedVisible)
	UIUtil.SetIsVisible(self.BtnTeamRecruitShare, BtnRecruitVisible, BtnRecruitVisible)
	UIUtil.SetIsVisible(self.ImgSuc, ImgSucVisible)

	UIUtil.SetIsVisible(self.HorOptBtns, true)
end

function FriendAddListItemView:OnSelectChangedStyle(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	local Desc = ItemData.Desc
	if not string.isnilorempty(Desc) then
		if UIViewMgr:IsViewVisible(UIViewID.CommHelpInfoTipsView) then
			UIViewMgr:HideView(UIViewID.CommHelpInfoTipsView)
		end

		local Node = ItemView:GetTipsWinPosNode()
		if nil ~= Node then
			TipsUtil.ShowInfoTips(Desc, Node, FVector2D(-20, 20), FVector2D(0, 1))
		end
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function FriendAddListItemView:OnEventMsgTeamRecruitStateChanged()
	self:OnUpdateBtnsVisible()
end

function FriendAddListItemView:OnEventMsgShareTeamRecruitToPlayerSuc()
	self:OnUpdateBtnsVisible()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendAddListItemView:OnClickButtonChat()
	_G.ChatMgr:GoToPlayerChatView(self.RoleID)
end

function FriendAddListItemView:OnClickButtonAddFriend()
	FriendMgr:AddFriend(self.RoleID, FriendDefine.AddSource.FriendTab)
end

function FriendAddListItemView:OnClickButtonTeamInvite()
	local ProtoCS = require("Protocol/ProtoCS")
	_G.TeamMgr:InviteJoinTeam(self.RoleID, ProtoCS.Team.Team.ReqSource.ReqSourceFriend)
end

function FriendAddListItemView:OnClickButtonRecruitShare()
	TeamRecruitUtil.ShareSelfRecruitToPlayer(self.RoleID)
end

return FriendAddListItemView