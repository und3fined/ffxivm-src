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
---@field PanelSideWin UFCanvasPanel
---@field ProBarCD UProgressBar
---@field SwitcherResult UWidgetSwitcher
---@field TextAgreeVotes02 URichTextBox
---@field TextDisagreeVotes URichTextBox
---@field TextFailed URichTextBox
---@field TextPass URichTextBox
---@field TextVoteResult UFTextBlock
---@field AnimFold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldVoteExpelResultWinView = LuaClass(UIView, true)

local UIDisplayTime <const> = 5

function PWorldVoteExpelResultWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.PanelSideWin = nil
	--self.ProBarCD = nil
	--self.SwitcherResult = nil
	--self.TextAgreeVotes02 = nil
	--self.TextDisagreeVotes = nil
	--self.TextFailed = nil
	--self.TextPass = nil
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
		_G.FLOG_ERROR("error: PWorldVoteExpelResultWinView:OnShow Params = nil\n" .. debug.traceback())
		return
	end

	local AcceptCnt = 	Params.AcceptCnt or 0
	local AgainstCnt = 	Params.AgainstCnt or 0
	local Succ = 		Params.Succ or false
	local Param1 = 		Params.Param1

	local Idx = Succ and 1 or 0
	self.SwitcherResult:SetActiveWidgetIndex(Idx)

	-- title
	self.TextVoteResult:SetText(Params.Title)
	-- result
	local TmpResultText = string.sformat(_G.LSTR(1320268), AcceptCnt, AgainstCnt)
	self.TextDisagreeVotes:SetText(TmpResultText)
	self.TextAgreeVotes02:SetText(TmpResultText)
	-- content
	self.TextPass:SetText(Params.Content)
	self.TextFailed:SetText(Params.Content)

	self:StartTimer()
end

function PWorldVoteExpelResultWinView:StartTimer()
	self:EndTimer()

	self.TimerHdl = self:RegisterTimer(function()
		self:Hide()
	end, UIDisplayTime)

	self.CountDownTime = os.time()
	self.TimeIDCountDown = self:RegisterTimer(function()
		local TimeLeft = os.time() - self.CountDownTime
		self.ProBarCD:SetPercent(math.clamp(1 - (TimeLeft / UIDisplayTime), 0, 1))
	end, 0.1, 0.1, 0)
end

function PWorldVoteExpelResultWinView:EndTimer()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end

	if self.TimeIDCountDown then
		self:UnRegisterTimer(self.TimeIDCountDown)
		self.TimeIDCountDown = nil
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