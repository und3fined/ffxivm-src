---
--- Author: Administrator
--- DateTime: 2025-01-03 20:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")

local PVPDuelVM = require("Game/PVP/Duel/VM/PVPDuelVM")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR
local WolvesDenPierMgr = _G.WolvesDenPierMgr
local SidebarMgr = _G.SidebarMgr

---@class PVPDuelPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLeft CommBtnLView
---@field BtnMid CommBtnLView
---@field BtnRight CommBtnLView
---@field CommonPopUpBG CommonPopUpBGView
---@field ImgCrosssword UFImage
---@field ImgFlagBlue UFImage
---@field ImgFlagRed UFImage
---@field ImgS1 UFImage
---@field ImgV1 UFImage
---@field PVPColosseumIntroduction1 PVPColosseumIntroductionItemView
---@field PVPColosseumIntroduction2 PVPColosseumIntroductionItemView
---@field PanelVS1 UFCanvasPanel
---@field TextDuel UFTextBlock
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPDuelPanelView = LuaClass(UIView, true)

function PVPDuelPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLeft = nil
	--self.BtnMid = nil
	--self.BtnRight = nil
	--self.CommonPopUpBG = nil
	--self.ImgCrosssword = nil
	--self.ImgFlagBlue = nil
	--self.ImgFlagRed = nil
	--self.ImgS1 = nil
	--self.ImgV1 = nil
	--self.PVPColosseumIntroduction1 = nil
	--self.PVPColosseumIntroduction2 = nil
	--self.PanelVS1 = nil
	--self.TextDuel = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPDuelPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnLeft)
	self:AddSubView(self.BtnMid)
	self:AddSubView(self.BtnRight)
	self:AddSubView(self.CommonPopUpBG)
	self:AddSubView(self.PVPColosseumIntroduction1)
	self:AddSubView(self.PVPColosseumIntroduction2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPDuelPanelView:OnInit()
	self.Binders = {
		{ "IsInviteDuel", UIBinderValueChangedCallback.New(self, nil, self.OnIsInviteDuelChanged) },
		{ "RemainTime", UIBinderValueChangedCallback.New(self, nil, self.OnRemainTimehanged) },
	}
end

function PVPDuelPanelView:OnDestroy()

end

function PVPDuelPanelView:OnShow()

end

function PVPDuelPanelView:OnHide()

end

function PVPDuelPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnClickBtnLeft)
	UIUtil.AddOnClickedEvent(self, self.BtnMid, self.OnClickBtnMid)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnClickBtnRight)
end

function PVPDuelPanelView:OnRegisterGameEvent()

end

function PVPDuelPanelView:OnRegisterBinder()
	self:RegisterBinders(PVPDuelVM, self.Binders)
end

function PVPDuelPanelView:OnIsInviteDuelChanged(NewValue, OldValue)
	self:SetText(NewValue)
	self:SetButton(NewValue)
	self:SetPlayerIcon(NewValue)
end

function PVPDuelPanelView:OnRemainTimehanged(NewValue, OldValue)
	if PVPDuelVM.IsInviteDuel then
		self.BtnLeft:SetText(string.format(LSTR(1330014), NewValue))
	else
		self.BtnLeft:SetText(string.format(LSTR(1330015), NewValue))
	end
end

function PVPDuelPanelView:OnClickBtnLeft()
	if PVPDuelVM.IsInviteDuel then
		WolvesDenPierMgr:CancelDuel(PVPDuelVM:GetTargetID())
	else
		WolvesDenPierMgr:ReplyDuel(PVPDuelVM:GetInviterID(), false)
	end
	SidebarMgr:TryOpenSidebarMainWin()
end

function PVPDuelPanelView:OnClickBtnMid()
	WolvesDenPierMgr:TryAddSidebarItem()
	SidebarMgr:TryOpenSidebarMainWin()
	self:Hide()
end

function PVPDuelPanelView:OnClickBtnRight()
	WolvesDenPierMgr:ReplyDuel(PVPDuelVM:GetInviterID(), true)
	SidebarMgr:TryOpenSidebarMainWin()
end

function PVPDuelPanelView:SetText(IsInviteDuel)
	local DuelText = ""
	local TipsText = ""
	if IsInviteDuel then
		DuelText = LSTR(1330003)
		TipsText = LSTR(1330004)
	else
		DuelText = LSTR(1330012)
		TipsText = LSTR(1330005)
	end
	self.TextDuel:SetText(DuelText)
	self.TextTips:SetText(TipsText)
end

function PVPDuelPanelView:SetButton(IsInviteDuel)
	self.BtnLeft:SetIsNormal(true)
	self.BtnMid:SetIsNormal(not IsInviteDuel)
	self.BtnRight:SetIsNormal(false)

	if IsInviteDuel then
		self.BtnLeft:SetText(string.format(LSTR(1330014), PVPDuelVM.RemainTime))
	else
		self.BtnLeft:SetText(string.format(LSTR(1330015), PVPDuelVM.RemainTime))
		self.BtnRight:SetText(LSTR(1330016))
	end

	self.BtnMid:SetText(LSTR(1330013))
	
	UIUtil.SetIsVisible(self.BtnLeft, true, true)
	UIUtil.SetIsVisible(self.BtnMid, true, true)
	UIUtil.SetIsVisible(self.BtnRight, not IsInviteDuel, true)
end

function PVPDuelPanelView:SetPlayerIcon(IsInviteDuel)
	local InviterParams = {
		Data = PVPDuelVM.Inviter
	}
	local TargetParams = {
		Data = PVPDuelVM.Target
	}

	if IsInviteDuel then
		self.PVPColosseumIntroduction1:SetParams(InviterParams)
		self.PVPColosseumIntroduction2:SetParams(TargetParams)
	else
		self.PVPColosseumIntroduction1:SetParams(TargetParams)
		self.PVPColosseumIntroduction2:SetParams(InviterParams)
	end
end

return PVPDuelPanelView