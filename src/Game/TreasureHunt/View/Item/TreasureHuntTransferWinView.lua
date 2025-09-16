---
--- Author: Administrator
--- DateTime: 2024-05-28 09:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local TreasureHuntTransferVM = require("Game/TreasureHunt/VM/TreasureHuntTransferVM")

local TreasureHuntMgr = nil
local TeamMgr = nil 

---@class TreasureHuntTransferWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTransfer CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TeamMemberView UTableView
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntTransferWinView = LuaClass(UIView, true)

function TreasureHuntTransferWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTransfer = nil
	--self.Comm2FrameM_UIBP = nil
	--self.TeamMemberView = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntTransferWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnTransfer)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntTransferWinView:OnInit()
	TreasureHuntMgr = _G.TreasureHuntMgr
	TeamMgr = _G.TeamMgr

	self.ViewModel = TreasureHuntTransferVM.New()
	self.TeamMemberAdapter = UIAdapterTableView.CreateAdapter(self, self.TeamMemberView, self.OnSelectChangedTeamMember, true)
	self.TeamMemberAdapter:SetScrollbarIsVisible(false)

	self.NewCaptainRoleID = nil
end

function TreasureHuntTransferWinView:OnDestroy()

end

function TreasureHuntTransferWinView:OnShow()
	self.Comm2FrameM_UIBP:SetTitleText(_G.LSTR(640045)) --转让队长
	self.Text:SetText(_G.LSTR(640044)) --请选择一位队员转让
	self.BtnTransfer:SetBtnName(_G.LSTR(10002)) --确定  SetTitleText

	self:UpdateTeamMembers()

	local CurrSelected = 1
	self.TeamMemberAdapter:SetSelectedIndex(CurrSelected)
end

function TreasureHuntTransferWinView:OnHide()

end

function TreasureHuntTransferWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTransfer, self.TransferCaption)
end

function TreasureHuntTransferWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamLeave, self.UpdateTeamMembers)
end

function TreasureHuntTransferWinView:OnRegisterBinder()
	self.Binders = {
		{ "TeamMemberList", UIBinderUpdateBindableList.New(self, self.TeamMemberAdapter) },
	}
	self:RegisterBinders(self.ViewModel,self.Binders)
end

function TreasureHuntTransferWinView:UpdateTeamMembers()
	self.ViewModel:UpdateVM()
end

function TreasureHuntTransferWinView:OnSelectChangedTeamMember(Index, ItemData, ItemView)
	self.NewCaptainRoleID = ItemData.TeamMemberRoleID
end

function TreasureHuntTransferWinView:TransferCaption()
	self:Hide()
	if self.NewCaptainRoleID == nil then return end

	if TeamMgr:CheckCanOpTeam(true) then
		TeamMgr:SendSetCaptainReq(TeamMgr.TeamID, self.NewCaptainRoleID)
	end
end

return TreasureHuntTransferWinView