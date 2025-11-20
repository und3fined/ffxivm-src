---
--- Author: mingyyzhang
--- DateTime: 2025-06-17 19:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class HouseInviteFriendsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field CommHead CommHeadView
---@field IconAdd UFImage
---@field IconArrow UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInviteFriendsItemView = LuaClass(UIView, true)

function HouseInviteFriendsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.CommHead = nil
	--self.IconAdd = nil
	--self.IconArrow = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInviteFriendsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInviteFriendsItemView:OnInit()
	self.HasRoommate = false
	UIUtil.SetIsVisible(self.ImgSelect, false)
	UIUtil.SetIsVisible(self.IconArrow, false)
	self.Index = nil
	self.RoleID = nil
	self.Name = nil
end

function HouseInviteFriendsItemView:OnDestroy()

end

function HouseInviteFriendsItemView:OnShow()

end

function HouseInviteFriendsItemView:OnHide()

end

function HouseInviteFriendsItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommHead.BtnClick, self.OnClickAdd)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickDelete)
end

function HouseInviteFriendsItemView:OnRegisterGameEvent()
	--self:RegisterGameEvent(_G.EventID.HouseRemoveRoommate, self.OnRemoveRoommateRsp)
end

function HouseInviteFriendsItemView:OnRegisterBinder()

end

function HouseInviteFriendsItemView:SetDefaultView(Index)
	self.TextName:SetText(HouseLocalDef.RoommatesSettingInfoStr.InviteFriend)
	UIUtil.SetIsVisible(self.IconAdd, true)
	UIUtil.SetIsVisible(self.BtnDelete, false)
	local HeadWidget = self.CommHead
	if HeadWidget then
		if HeadWidget.ImageIcon then
			UIUtil.ImageSetBrushFromAssetPath(self.CommHead.ImageIcon , "MaterialInstanceConstant'/Game/UI/Material/UI_Desaturate.UI_Desaturate'")
		end

		if HeadWidget.ImgNormalFrame then
			UIUtil.SetIsVisible(HeadWidget.ImgNormalFrame, false)
		end

		if HeadWidget.ImgFrame then
			UIUtil.SetIsVisible(HeadWidget.ImgFrame, false)
		end
	end

	self.Index = Index
	if self.CommHead and self.CommHead.RoleVM then
		self.CommHead.RoleVM = nil
	end

	self.RoleID = nil
end

function HouseInviteFriendsItemView:SetRoommate(Index, RoleID)
	local RVM = _G.RoleInfoMgr:FindRoleVM(RoleID, true)
	if RVM then
		self.Name = RVM.Name
		if self.Name then
			self.TextName:SetText(self.Name)
		end
	end

	self.CommHead:SetInfo(RoleID)
	self.Index = Index
	self.RoleID = RoleID
	UIUtil.SetIsVisible(self.IconAdd, false)
	UIUtil.SetIsVisible(self.BtnDelete, true, true)
end

function HouseInviteFriendsItemView:OnClickAdd()
	if not self.RoleID then
		_G.UIViewMgr:ShowView(_G.UIViewID.HouseInfoInviteFriendsWinView)
	else
		_G.PersonInfoMgr:ShowPersonalSimpleInfoView(self.RoleID)
	end
end

function HouseInviteFriendsItemView:OnClickDelete()
	local function RCallback()
		_G.HouseInfoMgr:SendRemoveRoommate(_G.HouseInfoMgr.MajorHouseID, self.RoleID)
	end
	local function LCallback()
		_G.MsgBoxUtil.CloseMsgBox()
	end
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			HouseLocalDef.HouseDissolveBoxStr.Tittle,
			string.format(HouseLocalDef.HouseDissolveBoxStr.Content, self.Name),
			RCallback,
			LCallback
	)
end

return HouseInviteFriendsItemView