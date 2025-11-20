---
--- Author: mingyyzhang
--- DateTime: 2025-07-01 15:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TeamDefine = require("Game/Team/TeamDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")

---@class HouseInfoInviteFriendsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInvite UFButton
---@field BtnUnabletoInvite UFButton
---@field IconInvited UFImage
---@field IconSever UFImage
---@field ImgBg UFImage
---@field ImgOnlineStatus UFImage
---@field PlayerHeadSlot CommHeadView
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field SizeBoxServer UFHorizontalBox
---@field TextLocation UFTextBlock
---@field TextPlayerName URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoInviteFriendsItemView = LuaClass(UIView, true)
local InviteItemBgEnum = TeamDefine.InviteItemBgEnum

function HouseInfoInviteFriendsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInvite = nil
	--self.BtnUnabletoInvite = nil
	--self.IconInvited = nil
	--self.IconSever = nil
	--self.ImgBg = nil
	--self.ImgOnlineStatus = nil
	--self.PlayerHeadSlot = nil
	--self.ProfSlot = nil
	--self.SizeBoxServer = nil
	--self.TextLocation = nil
	--self.TextPlayerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoInviteFriendsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoInviteFriendsItemView:OnInit()
	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	self.ProfInfoVM = SimpleProfInfoVM.New()
	self.ItemBinders = {
		--{ "NotInvite", 	UIBinderSetIsVisible.New(self, 	self.BtnInvite) },
		{ "Invited", 	UIBinderSetIsVisible.New(self, 	self.IconInvited) },
		--{ "IsLock", 	UIBinderSetIsVisible.New(self, 	self.BtnUnabletoInvite) },
		{ "ProfID", 	UIBinderValueChangedCallback.New(self, nil, self.OnProfIDChanged) },
		{ "HeadInfo", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadInfo) },
	}
	self.RoleVMBinders = {
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName) },
		{ "MapResName", 		UIBinderValueChangedCallback.New(self, nil, self.UpdateTextLocation) },
		{ "OnlineStatusIcon", 	UIBinderSetImageBrush.New(self, self.ImgOnlineStatus) },
		{ "CurWorldID", TeamRecruitUtil.NewCrossServerShowBinder(nil, self, self.IconSever)},
		{ "IsOnline", 			UIBinderValueChangedCallback.New(self, nil, self.OnIsOnlineChanged) },
	}
	self.FailCondition = 0
end

function HouseInfoInviteFriendsItemView:OnDestroy()

end

function HouseInfoInviteFriendsItemView:OnShow()

end

function HouseInfoInviteFriendsItemView:OnHide()

end

function HouseInfoInviteFriendsItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInvite, self.OnClickInvite)
	UIUtil.AddOnClickedEvent(self, self.BtnUnabletoInvite, self.OnClickUnableInvite)
end

function HouseInfoInviteFriendsItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OnlineStatusChangedInVision, function(_, Params)
		if self:GetRoleID() and self:GetRoleID() == ActorUtil.GetRoleIDByEntityID(Params.EntityID) then
			local RoleVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
			if RoleVM then
				RoleVM:SetOnlineStatus(Params.OnlineStatus)
			end
		end
	end)

	self:RegisterGameEvent(EventID.HouseInviteRsp, self.OnHouseInviteRsp)
end

function HouseInfoInviteFriendsItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if self.ViewModel == nil then
		return
	end
	
	local RVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
	if RVM then
		--职业
		self.ProfInfoVM:UpdateVM(
			{
				ProfID = RVM.Prof,
				Level  = RVM.Level or 0,
				LevelDesc  = tostring(RVM.Level) or "",
				IsEmpty = nil == RVM.ProfID or RVM.ProfID <= 0
			})

		self.ProfSlot:SetParams({ Data = self.ProfInfoVM})

		--角色等级低于10级
		local MaxLevel = RVM:GetMaxProfLevel()
		if MaxLevel < 10 then
			UIUtil.SetIsVisible(self.BtnUnabletoInvite, true, true)
			UIUtil.SetIsVisible(self.BtnInvite, false)
			self.FailCondition = 2
		end

		self:RegisterBinders(RVM, self.RoleVMBinders)
	end
	--判断玩家是否有室友
	if self.ViewModel.HasRoommate > 0 then  
		UIUtil.SetIsVisible(self.BtnUnabletoInvite, true, true)
		UIUtil.SetIsVisible(self.BtnInvite, false)
		self.FailCondition = 1
	end
	self.ViewModel.Invited = false
	self:RegisterBinders(self.ViewModel, self.ItemBinders)
end

function HouseInfoInviteFriendsItemView:OnProfIDChanged(ProfID)
	if nil == ProfID then
		return
	end

	local ProfFunc = RoleInitCfg:FindFunction(ProfID)
	if nil == ProfFunc then
		return
	end

	local Bg = InviteItemBgEnum[ProfFunc]
	if string.isnilorempty(Bg) then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgBg, Bg)
	local RVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
	if RVM then
		--职业
		self.ProfInfoVM:UpdateVM({
				ProfID = RVM.Prof,
				Level  = RVM.Level or 0,
				LevelDesc  = tostring(RVM.Level) or "",
				IsEmpty = nil == RVM.ProfID or RVM.ProfID <= 0
			})
		self.ProfSlot:SetParams({ Data = self.ProfInfoVM})
	end
end

function HouseInfoInviteFriendsItemView:OnValueChangedHeadInfo()
	self.PlayerHeadSlot:SetInfo(self:GetRoleID())
end

function HouseInfoInviteFriendsItemView:UpdateTextLocation()
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
	if RoleVM.IsOnline then
		self.TextLocation:SetText(RoleVM.MapResName)
	else
		local OfflineTime =  TimeUtil.GetServerTime() - RoleVM.LogoutTime
		self.TextLocation:SetText(LocalizationUtil.GetTimerForLowPrecision(OfflineTime))
	end
end

function HouseInfoInviteFriendsItemView:OnIsOnlineChanged(IsOnline)
	if self.FailCondition == 0 then
		UIUtil.SetIsVisible(self.BtnInvite, IsOnline, true)
		UIUtil.SetIsVisible(self.BtnUnabletoInvite, false)
	end

	local Opacity = IsOnline and 1 or 0.5
	UIUtil.SetRenderOpacity(self.ProfSlot, Opacity)
	UIUtil.SetRenderOpacity(self.PlayerHeadSlot, Opacity)
	UIUtil.SetRenderOpacity(self.ImgOnlineStatus, Opacity)
	UIUtil.SetRenderOpacity(self.TextPlayerName, Opacity)

	self:UpdateTextLocation()
end

function HouseInfoInviteFriendsItemView:GetRoleID()
	return self.ViewModel and self.ViewModel.RoleID or nil
end

function HouseInfoInviteFriendsItemView:OnClickInvite()
	if #_G.HouseInfoMgr.Roommates >= 3 then
		MsgTipsUtil.ShowTips(HouseLocalDef.RoommatesInviteWinViewStr.InviteFailTips[1])
	end
	UIUtil.SetIsVisible(self.BtnInvite, false)
	self.ViewModel.Invited = true
	_G.HouseInfoMgr:SendInviteRoommate(_G.HouseInfoMgr.MajorHouseID, self:GetRoleID())
end

function HouseInfoInviteFriendsItemView:OnHouseInviteRsp(MsgBody)
	if MsgBody.TargetID == self:GetRoleID() then
		local RVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
		if RVM then
			MsgTipsUtil.ShowTips(string.format(HouseLocalDef.RoommatesInviteWinViewStr.InviteTips, RVM.Name))
		end
	end
end

function HouseInfoInviteFriendsItemView:OnClickUnableInvite()
	if self.FailCondition == 1 then
		MsgTipsUtil.ShowTips(HouseLocalDef.RoommatesInviteWinViewStr.InviteFailTips[2])
	elseif self.FailCondition == 2 then
		MsgTipsUtil.ShowTips(HouseLocalDef.RoommatesInviteWinViewStr.InviteFailTips[3])
	end
end

return HouseInfoInviteFriendsItemView