---
--- Author: xingcaicao
--- DateTime: 2024-07-16 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local TipsUtil = require("Utils/TipsUtil")

local FVector2D = _G.UE.FVector2D

---@class LinkShellApplyListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnOk UFButton
---@field BtnRefuse UFButton
---@field BtnReport UFButton
---@field CommPlayerItem CommPlayerItemView
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TextRemark UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellApplyListItemView = LuaClass(UIView, true)

function LinkShellApplyListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnOk = nil
	--self.BtnRefuse = nil
	--self.BtnReport = nil
	--self.CommPlayerItem = nil
	--self.ProfSlot = nil
	--self.TextRemark = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellApplyListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerItem)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellApplyListItemView:OnInit()

end

function LinkShellApplyListItemView:OnDestroy()

end

function LinkShellApplyListItemView:OnShow()

end

function LinkShellApplyListItemView:OnHide()

end

function LinkShellApplyListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, 	self.OnClickButtonRefuse)
	UIUtil.AddOnClickedEvent(self, self.BtnOk, 		self.OnClickButtonOk)
    UIUtil.AddOnClickedEvent(self, self.BtnReport, 	self.OnClickButtonReport)
end

function LinkShellApplyListItemView:OnRegisterGameEvent()

end

function LinkShellApplyListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.RoleID = ViewModel.RoleID

	-- 申请备注语
	local Remark = ViewModel.ReqRemark or ""
	self.TextRemark:SetText(Remark)
	self.Remark = Remark

	local IsShowBtnReport = not string.isnilorempty(Remark)
	UIUtil.SetIsVisible(self.BtnReport, IsShowBtnReport, IsShowBtnReport)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellApplyListItemView:OnClickButtonRefuse()
	local RoleID = self.RoleID
	if RoleID then
		LinkShellMgr:SendMsgAuditJoinLinkShellReq(LinkShellVM.CurLinkShellID, RoleID, false)
	end
end

function LinkShellApplyListItemView:OnClickButtonOk()
	local RoleID = self.RoleID
	if RoleID then
		LinkShellMgr:SendMsgAuditJoinLinkShellReq(LinkShellVM.CurLinkShellID, RoleID, true)
	end
end

function LinkShellApplyListItemView:OnClickButtonReport()
	local RoleID = self.RoleID
	if nil == RoleID or RoleID <= 0 then
		return
	end

	local Remark = self.Remark
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

		-- 复用邀请信息的接口(@张凌飞 @ds_herui)
		_G.ReportMgr:OpenViewByLinkShellInvitation(Params) 
	end, true)
end

return LinkShellApplyListItemView