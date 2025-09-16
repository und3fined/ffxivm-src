---
--- Author: v_hggzhang
--- DateTime: 2023-05-16 17:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@deprecated PENDING DELETE #TODO
---@class PWorldVoteGiveUpWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnAgree CommBtnLView
---@field BtnDisagree CommBtnLView
---@field FTextCD UFTextBlock
---@field FTextCD2 UFTextBlock
---@field FTextVotedResultNo UFTextBlock
---@field FTextVotedResultYes UFTextBlock
---@field HorizonBoxVotePre UFHorizontalBox
---@field RichTextBoxVotedNumber URichTextBox
---@field VotePost UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldVoteGiveUpWinView = LuaClass(UIView, true)

function PWorldVoteGiveUpWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnAgree = nil
	--self.BtnDisagree = nil
	--self.FTextCD = nil
	--self.FTextCD2 = nil
	--self.FTextVotedResultNo = nil
	--self.FTextVotedResultYes = nil
	--self.HorizonBoxVotePre = nil
	--self.RichTextBoxVotedNumber = nil
	--self.VotePost = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldVoteGiveUpWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnAgree)
	self:AddSubView(self.BtnDisagree)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldVoteGiveUpWinView:OnInit()
	self.Binders = {
        { "GiveUpDesc",       		UIBinderSetText.New(self, self.RichTextBoxVotedNumber) },
		{ "HasVoteGiveUp",       	UIBinderSetIsVisible.New(self, self.HorizonBoxVotePre, true) },
		{ "HasVoteGiveUp",       	UIBinderSetIsVisible.New(self, self.FTextCD, true) },
		{ "HasVoteGiveUp",       	UIBinderSetIsVisible.New(self, self.VotePost) },
		{ "HasVoteGiveUp",      	UIBinderSetIsVisible.New(self, self.FTextCD2) },

		{ "VoteOpGiveUpAccept",       	UIBinderSetIsVisible.New(self, self.FTextVotedResultYes) },
		{ "VoteOpGiveUpAccept",       	UIBinderSetIsVisible.New(self, self.FTextVotedResultNo, true) },
    }
end

function PWorldVoteGiveUpWinView:OnDestroy()

end

function PWorldVoteGiveUpWinView:OnShow()
end

function PWorldVoteGiveUpWinView:OnRegisterTimer()
	self:RegisterTimer(function()
		_G.PWorldTeamVM:UpdCounter()
	end, 0, 1, 0)
end

function PWorldVoteGiveUpWinView:OnHide()
	_G.SidebarMgr:TryOpenSidebarMainWin()
end

function PWorldVoteGiveUpWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDisagree, function()
		-- _G.FLOG_INFO("zhg TODO PWorldVoteGiveUpWinView self.BtnDisagree")
		_G.PWorldTeamMgr:ReqPWVoteGiveUp(false)
        self:Hide()
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnAgree, function()
		-- _G.FLOG_INFO("zhg TODO PWorldVoteGiveUpWinView self.BtnAgree")
		_G.PWorldTeamMgr:ReqPWVoteGiveUp(true)
        self:Hide()
	end)
end

function PWorldVoteGiveUpWinView:OnRegisterGameEvent()

end

function PWorldVoteGiveUpWinView:OnRegisterBinder()
    self:RegisterBinders(_G.PWorldTeamVM, self.Binders)
end

return PWorldVoteGiveUpWinView