---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
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

local FVector2D = _G.UE.FVector2D
local MaxGameStyleCount = PersonInfoDefine.MaxGameStyleCount

---@class FriendAddListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAddFriend UFButton
---@field BtnChat UFButton
---@field BtnTeamInvite UFButton
---@field CommPlayerItem CommPlayerItemView
---@field HorOptBtns UFHorizontalBox
---@field ImgInvited UFImage
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
	--self.CommPlayerItem = nil
	--self.HorOptBtns = nil
	--self.ImgInvited = nil
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
	UIUtil.AddOnClickedEvent(self, self.BtnAddFriend, 	self.OnClickButtonAddFriend)
	UIUtil.AddOnClickedEvent(self, self.BtnTeamInvite, self.OnClickButtonTeamInvite)
end

function FriendAddListItemView:OnRegisterGameEvent()

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

	local IsFriend = VM.IsFriend
	if IsFriend then
		local IsInvited = false
		if RoleID then
			IsInvited = table.contain(TeamInviteVM.CurInvitedRoleIDs, RoleID) 
		end

		UIUtil.SetIsVisible(self.BtnTeamInvite, not IsInvited, true)
		UIUtil.SetIsVisible(self.ImgInvited, IsInvited)
		UIUtil.SetIsVisible(self.BtnAddFriend, false)

	else
		UIUtil.SetIsVisible(self.BtnAddFriend, true, true)
		UIUtil.SetIsVisible(self.BtnTeamInvite, false)
		UIUtil.SetIsVisible(self.ImgInvited, false)
	end

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

return FriendAddListItemView