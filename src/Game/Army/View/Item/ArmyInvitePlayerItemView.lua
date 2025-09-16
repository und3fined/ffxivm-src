---
--- Author: Administrator
--- DateTime: 2025-03-06 20:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TeamDefine = require("Game/Team/TeamDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local InviteSignSideDefine = require("Game/Common/InviteSignSideWin/InviteSignSideDefine")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")

local InviteItemBgEnum = TeamDefine.InviteItemBgEnum

---@class ArmyInvitePlayerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInvite UFButton
---@field ImgBg UFImage
---@field ImgInvited UFImage
---@field ImgOnlineStatus UFImage
---@field ImgServer UFImage
---@field InviteIcon UFImage
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field SizeBoxServer USizeBox
---@field TextLocation UFTextBlock
---@field TextPlayerName URichTextBox
---@field TextState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInvitePlayerItemView = LuaClass(UIView, true)

function ArmyInvitePlayerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInvite = nil
	--self.ImgBg = nil
	--self.ImgInvited = nil
	--self.ImgOnlineStatus = nil
	--self.ImgServer = nil
	--self.InviteIcon = nil
	--self.PlayerHeadSlot = nil
	--self.ProfSlot = nil
	--self.SizeBoxServer = nil
	--self.TextLocation = nil
	--self.TextPlayerName = nil
	--self.TextState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyInvitePlayerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInvitePlayerItemView:OnInit()
	---绑定itemvm
	self.ItemVMBinders = {
		{ "ProfID", 			UIBinderValueChangedCallback.New(self, nil, self.OnProfIDChanged) },
		{ "FilterKeyword", UIBinderValueChangedCallback.New(self, nil, self.OnFilterKeywordChanged) },
		{ "BtnIcon", UIBinderSetBrushFromAssetPath.New(self, self.InviteIcon) },
	}

	---绑定角色VM
	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	self.RoleVMBinders = {
		{ "MapResName", 		UIBinderValueChangedCallback.New(self, nil, self.UpdateTextLocation) },
		{ "OnlineStatusIcon", 	UIBinderSetImageBrush.New(self, self.ImgOnlineStatus) },
		{ "CurWorldID", TeamRecruitUtil.NewCrossServerShowBinder(nil, self, self.SizeBoxServer)},
		{ "IsOnline", 			UIBinderValueChangedCallback.New(self, nil, self.OnIsOnlineChanged) },

	}


end

function ArmyInvitePlayerItemView:OnShow()
	---todo  署名邀请这边貌似无此文本表现,先隐藏
	UIUtil.SetIsVisible(self.TextState, false)
end

function ArmyInvitePlayerItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInvite, self.OnClickButtonInvite)
end

function ArmyInvitePlayerItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OnlineStatusChangedInVision, function(_, Params)
		if self:GetRoleID() and self:GetRoleID() == ActorUtil.GetRoleIDByEntityID(Params.EntityID) then
			local RoleVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
			if RoleVM then
				RoleVM:SetOnlineStatus(Params.OnlineStatus)
			end
		end
	end)

	self:RegisterGameEvent(EventID.OnlineStatusMajorChanged, function(_, NewStatus, OldStatus)
		if self:GetRoleID() and self:GetRoleID() == MajorUtil.GetMajorRoleID() then
			local RoleVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
			if RoleVM then
				RoleVM:SetOnlineStatus(NewStatus)
			end
		end
	end)
end

function ArmyInvitePlayerItemView:OnRegisterTimer()

end



function ArmyInvitePlayerItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if self.ViewModel == nil then
		return
	end

	--职业
	self.ProfSlot:SetParams({ Data = self.ViewModel.ProfInfoVM })
	--玩家头像
	self.PlayerHeadSlot:SetInfo(self:GetRoleID())

	self:RegisterBinders(self.ViewModel, self.ItemVMBinders)

	local RVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true) 
	if RVM then
		self:RegisterBinders(RVM, self.RoleVMBinders)
	end
	
end

function ArmyInvitePlayerItemView:OnProfIDChanged(ProfID)
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
end

--- 搜索字符串变化
function ArmyInvitePlayerItemView:OnFilterKeywordChanged(Keyword)
	if nil == self.ViewModel then
		return
	end

	local Name = self.ViewModel.Name or ""
	local VM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
	if string.isnilorempty(Keyword) then
		self.TextPlayerName:SetText(Name)
		return
	end

    local Pattern = string.revisePattern(Keyword)
    local Repl = string.format('<span color="#d1906d">%s</>', Keyword)
    Name = string.gsub(Name, Pattern, Repl)
	self.TextPlayerName:SetText(Name)
end


-------------------------------------------------------------------------------------------------------
---Component CallBack
function ArmyInvitePlayerItemView:OnClickButtonInvite()
	if self.ViewModel then
		--- 根据类型处理邀请逻辑
		if self.ViewModel.ItemType == InviteSignSideDefine.InviteItemType.ArmySignInvite then
			--- 部队署名邀请
			self:ArmySignInvite()
		elseif self.ViewModel.ItemType == InviteSignSideDefine.InviteItemType.ArmyInvite then
			--- 部队邀请
			self:ArmyInvite()
		end
	end
end

--- 部队署名邀请
function ArmyInvitePlayerItemView:ArmySignInvite()
	if self.ViewModel then
		local RoleID = self.ViewModel.RoleID
		if RoleID then
			_G.ArmyMgr:CheckAndSendGroupSignInvite(RoleID)
		end
	end
end

--- 部队邀请
function ArmyInvitePlayerItemView:ArmyInvite()
	if self.ViewModel then
		local RoleID = self.ViewModel.RoleID
		if RoleID then
			_G.ArmyMgr:CheckAndSendGroupInvite(RoleID)
		end
	end
end

function ArmyInvitePlayerItemView:GetRoleID()
	return self.ViewModel and self.ViewModel.RoleID or nil
end

function ArmyInvitePlayerItemView:GetOnlineStatus()
	local VM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
	return VM and VM.OnlineStatus or 0
end

function ArmyInvitePlayerItemView:UpdateTextLocation()
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
	if RoleVM.IsOnline then
		self.TextLocation:SetText(RoleVM.MapResName)
	else
		local OfflineTime =  TimeUtil.GetServerTime() - RoleVM.LogoutTime
		self.TextLocation:SetText(LocalizationUtil.GetTimerForLowPrecision(OfflineTime))
	end
end

function ArmyInvitePlayerItemView:OnIsOnlineChanged(IsOnline)
	UIUtil.SetIsVisible(self.BtnInvite, IsOnline, true)

	local Opacity = IsOnline and 1 or 0.5
	UIUtil.SetRenderOpacity(self.ProfSlot, Opacity)
	UIUtil.SetRenderOpacity(self.PlayerHeadSlot, Opacity)
	UIUtil.SetRenderOpacity(self.ImgOnlineStatus, Opacity)
	UIUtil.SetRenderOpacity(self.TextPlayerName, Opacity)

	self:UpdateTextLocation()
end

return ArmyInvitePlayerItemView