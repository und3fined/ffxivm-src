---
--- Author: Administrator
--- DateTime: 2024-12-18 10:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local ProtoCS = require("Protocol/ProtoCS")
local NodeOpType = ProtoCS.Game.Activity.NodeOpType
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
local EventID = require("Define/EventID")
local DataReportUtil = require("Utils/DataReportUtil")

---@class OpsCrystalSunmmoingInviteListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field IconBtn UFImage
---@field IconState UFImage
---@field ImgBG UFImage
---@field PlayerHead CommHeadView
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---@field TextNoinvited UFTextBlock
---@field TextState UFTextBlock
---@field iconJob UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCrystalSunmmoingInviteListItemView = LuaClass(UIView, true)

function OpsCrystalSunmmoingInviteListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.IconBtn = nil
	--self.IconState = nil
	--self.ImgBG = nil
	--self.PlayerHead = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--self.TextNoinvited = nil
	--self.TextState = nil
	--self.iconJob = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCrystalSunmmoingInviteListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCrystalSunmmoingInviteListItemView:OnInit()
	self.Binders = {
		{"JobIcon", UIBinderSetImageBrush.New(self, self.iconJob)},
		{"LevelText", UIBinderSetText.New(self, self.TextLevel)},
		{"RoleName", UIBinderSetText.New(self, self.TextName)},
		{"StateIcon", UIBinderSetImageBrush.New(self, self.IconState)},
		{"StateText", UIBinderSetText.New(self, self.TextState)},
		{"BtnIcon", UIBinderSetImageBrush.New(self, self.IconBtn)},
		{"IconColor", UIBinderSetColorAndOpacityHex.New(self, self.PlayerHead.ImageIcon)},
		--{"BgVisible", UIBinderSetIsVisible.New(self, self.ImgBG)},
	}
end

function OpsCrystalSunmmoingInviteListItemView:OnDestroy()

end

function OpsCrystalSunmmoingInviteListItemView:UpdateShow()
	if not self.ViewModel then return end
	local IsEmpty = self.ViewModel.IsEmptyRole or false	
	UIUtil.SetIsVisible(self.iconJob, true)
	UIUtil.SetIsVisible(self.TextLevel, not IsEmpty)
	UIUtil.SetIsVisible(self.TextName, not IsEmpty)
	UIUtil.SetIsVisible(self.IconState, not IsEmpty)
	UIUtil.SetIsVisible(self.TextState, not IsEmpty)
	UIUtil.SetIsVisible(self.TextNoinvited, IsEmpty)
	self.TextNoinvited:SetText(LSTR(100090))

	if not IsEmpty then
		self.PlayerHead:SetIsTriggerClick(true)
		UIUtil.SetIsVisible(self.PlayerHead.BtnClick, true, true)
		self.PlayerHead:SetInfo(self.ViewModel.RoleID)
	else
		UIUtil.SetIsVisible(self.PlayerHead.ImgNormalFrame, false)
		UIUtil.SetIsVisible(self.PlayerHead.ImgFrame, false)
		self.PlayerHead:SetIsTriggerClick(false)
		UIUtil.SetIsVisible(self.PlayerHead.BtnClick, false)
		local Path = "Texture2D'/Game/Assets/Icon/Head/UI_Icon_Head_Unknown.UI_Icon_Head_Unknown'"
		self.PlayerHead:SetIcon(Path)
	end
end

function OpsCrystalSunmmoingInviteListItemView:OnShow()
	self:UpdateShow()
end

function OpsCrystalSunmmoingInviteListItemView:OnHide()

end

function OpsCrystalSunmmoingInviteListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtn)
end

function OpsCrystalSunmmoingInviteListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OpsActivityUpdateInfo)
end

function OpsCrystalSunmmoingInviteListItemView:OpsActivityUpdateInfo()
	self:UpdateShow()
end

function OpsCrystalSunmmoingInviteListItemView:OnRegisterBinder()
	local ViewModel = self.Params.Data

	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsCrystalSunmmoingInviteListItemView:OnClickBtn()
	if not self.ViewModel then return end
	if not self.ViewModel.HasInit then return end
		
	local IsEmpty = self.ViewModel.IsEmptyRole or false	
	if IsEmpty then
		if self.ViewModel.ShareRewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
			OpsActivityMgr:SendActivityEventReport(self.ViewModel.NodeType, self.ViewModel.ShareParams)
		end

		DataReportUtil.ReportActivityClickFlowData(self.ViewModel.ActivityID, 2)
		_G.ShareMgr:ShareCrystalSummon("sCode="..(self.ViewModel.InviteCode or ""), "")
		return
	end
	
	if self.ViewModel.CanBreakBind then
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(100088), LSTR(100089), function()
			local Data = {OpenID = self.ViewModel.OpenID}
			OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.GetInviteListNodeID, NodeOpType.NodeOpTypeUnBindInvitee, {UnBindInvitee = Data})
		end)

		return
	end

	if _G.FriendMgr:IsFriend(self.ViewModel.RoleID) then
		_G.ChatMgr:GoToPlayerChatView(self.ViewModel.RoleID)
	else
		_G.FriendMgr:AddFriend(self.ViewModel.RoleID, FriendDefine.AddSource.Activity)
	end
end

return OpsCrystalSunmmoingInviteListItemView