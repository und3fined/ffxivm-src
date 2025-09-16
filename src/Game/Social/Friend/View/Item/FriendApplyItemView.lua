---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local FVector2D = _G.UE.FVector2D

---@class FriendApplyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnOk UFButton
---@field BtnRefuse UFButton
---@field BtnReport UFButton
---@field CommPlayerItem CommPlayerItemView
---@field PanelRemark UFHorizontalBox
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TextRemark UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendApplyItemView = LuaClass(UIView, true)

function FriendApplyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnOk = nil
	--self.BtnRefuse = nil
	--self.BtnReport = nil
	--self.CommPlayerItem = nil
	--self.PanelRemark = nil
	--self.ProfSlot = nil
	--self.TextRemark = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendApplyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerItem)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendApplyItemView:OnInit()
	self.Binders = {
		{ "Remark", UIBinderValueChangedCallback.New(self, nil, self.OnRemarkChanged) },
	}
end

function FriendApplyItemView:OnDestroy()

end

function FriendApplyItemView:OnShow()

end

function FriendApplyItemView:OnHide()

end

function FriendApplyItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, 		self.OnClickButtonRefuse)
	UIUtil.AddOnClickedEvent(self, self.BtnOk, 			self.OnClickButtonOk)
    UIUtil.AddOnClickedEvent(self, self.BtnReport, 		self.OnClickButtonReport)
end

function FriendApplyItemView:OnRegisterGameEvent()

end

function FriendApplyItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function FriendApplyItemView:OnRemarkChanged(Remark)
	Remark = Remark or ""
	self.TextRemark:SetText(Remark)

	local IsShowMark = not string.isnilorempty(Remark)
	UIUtil.SetIsVisible(self.PanelRemark, IsShowMark)
	UIUtil.SetIsVisible(self.BtnReport, IsShowMark, IsShowMark)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendApplyItemView:OnClickButtonRefuse()
	local VM = self.ViewModel
	if VM then
		FriendMgr:SendFriendsConfirmAddMsg(VM.RoleID, false)
	end
end

function FriendApplyItemView:OnClickButtonOk()
	-- 需要判断玩家自己的好友数量有没有达到上限
    if FriendMgr:IsFriendNumLimit(true) then
		return
	end

	local VM = self.ViewModel
	if VM then
		FriendMgr:SendFriendsConfirmAddMsg(VM.RoleID, true)
	end
end

function FriendApplyItemView:OnClickButtonReport()
	local VM = self.ViewModel
	if nil == VM then
		return
	end

	local RoleID = VM.RoleID
	if nil == RoleID or RoleID <= 0 then
		return
	end

	local Remark = VM.Remark
	if string.isnilorempty(Remark) then
		return
	end

	local Alignment = FVector2D(0, 1)
	local Offset = FVector2D(-1 * UIUtil.GetWidgetSize(self.BtnReport).X - 10, 10)
	TipsUtil.ShowReportTips(self.BtnReport, Offset, Alignment, function()
		local Params = { 
			ReporteeRoleID = RoleID, 
			ReportContent = Remark
		}

		_G.ReportMgr:OpenViewByFriendRequest(Params)
	end)
end

return FriendApplyItemView