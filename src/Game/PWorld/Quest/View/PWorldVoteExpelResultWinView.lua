---
--- Author: v_hggzhang
--- DateTime: 2023-05-16 17:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PWorldVoteExpelResultWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnSideBar UButton
---@field ExileMemPanel UHorizontalBox
---@field ImgIcon UImage
---@field PanelSideWin UFCanvasPanel
---@field RaidalCD URadialImage
---@field SwitcherResult UWidgetSwitcher
---@field TextAgreeVotes UFTextBlock
---@field TextAgreeVotes02 UFTextBlock
---@field TextDisagreeVotes UFTextBlock
---@field TextDisagreeVotes02 UFTextBlock
---@field TextFailed UFTextBlock
---@field TextPass UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextServerName UFTextBlock
---@field TextVoteResult UFTextBlock
---@field AnimFold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldVoteExpelResultWinView = LuaClass(UIView, true)

function PWorldVoteExpelResultWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnSideBar = nil
	--self.ExileMemPanel = nil
	--self.ImgIcon = nil
	--self.PanelSideWin = nil
	--self.RaidalCD = nil
	--self.SwitcherResult = nil
	--self.TextAgreeVotes = nil
	--self.TextAgreeVotes02 = nil
	--self.TextDisagreeVotes = nil
	--self.TextDisagreeVotes02 = nil
	--self.TextFailed = nil
	--self.TextPass = nil
	--self.TextPlayerName = nil
	--self.TextServerName = nil
	--self.TextVoteResult = nil
	--self.AnimFold = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldVoteExpelResultWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldVoteExpelResultWinView:OnInit()
	self.TextPass:SetText(_G.LSTR(1320180))
	self.TextFailed:SetText(_G.LSTR(1320181))
end

function PWorldVoteExpelResultWinView:OnDestroy()

end
--[[
	Params = {
		AcceptCnt = 1,
		AgainstCnt = 1,
		MajorAccept = true,
		Param1 = "玩家名字"，
	}
]]
function PWorldVoteExpelResultWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	if Params then
		local AcceptCnt = 	Params.AcceptCnt or 0
		local AgainstCnt = 	Params.AgainstCnt or 0
		local Succ = 		Params.Succ or false
		local Param1 = 		Params.Param1

		local Idx = Succ and 1 or 0
		self.SwitcherResult:SetActiveWidgetIndex(Idx)

		local AcceptText = string.sformat(LSTR(1320111), tostring(AcceptCnt))
		local RejectText = string.sformat(LSTR(1320112), tostring(AgainstCnt))
		if Succ then
			self.TextAgreeVotes02:SetText(AcceptText)
			self.TextDisagreeVotes02:SetText(RejectText)
		else
			self.TextAgreeVotes:SetText(AcceptText)
			self.TextDisagreeVotes:SetText(RejectText)
		end

		if Param1 then
			UIUtil.SetIsVisible(self.ExileMemPanel, true)
			UIUtil.SetIsVisible(self.TextVoteResult, false)
			local RoleID = Param1
			local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
			if RoleVM then
				self.TextPlayerName:SetText(RoleVM.Name)
			end
			self.TextServerName:SetText(_G.LSTR(1320113))
		else
			UIUtil.SetIsVisible(self.ExileMemPanel, false)
			UIUtil.SetIsVisible(self.TextVoteResult, true)
			self.TextVoteResult:SetText(_G.LSTR(1320114))
		end

		self:StartTimer()
	else
		_G.FLOG_ERROR("PWorldVoteExpelResultWinView:OnShow Params = nil")
		self:Hide()
	end
end

function PWorldVoteExpelResultWinView:StartTimer()
	self:EndTimer()

	self.TimerHdl = self:RegisterTimer(function()
		self:Hide()
	end, 3)
end

function PWorldVoteExpelResultWinView:EndTimer()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end
end

function PWorldVoteExpelResultWinView:OnHide()
	self:EndTimer()
end

function PWorldVoteExpelResultWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, function()
        self:Hide()
	end)
end

function PWorldVoteExpelResultWinView:OnRegisterGameEvent()

end

function PWorldVoteExpelResultWinView:OnRegisterBinder()

end

return PWorldVoteExpelResultWinView