--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-10 14:17:55
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-10 15:18:07
FilePath: \Script\Game\Sidebar\View\SidebarGiveUpTaskWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TeamDefine = require("Game/Team/TeamDefine")

---@class SidebarGiveUpTaskWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAccept CommBtnSView
---@field BtnFold UFButton
---@field BtnRefuse CommBtnSView
---@field EFF_ProBarLight UFImage
---@field PanelAgree UFCanvasPanel
---@field PanelBtn UHorizontalBox
---@field PanelHeading UFCanvasPanel
---@field PanelSideWin UFCanvasPanel
---@field ProBarCD UProgressBar
---@field RichTextNumber URichTextBox
---@field RichTextTitle URichTextBox
---@field TextNo UFTextBlock
---@field TextOther UFTextBlock
---@field TextYes UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBarLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarGiveUpTaskWinView = LuaClass(UIView, true)

function SidebarGiveUpTaskWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAccept = nil
	--self.BtnFold = nil
	--self.BtnRefuse = nil
	--self.EFF_ProBarLight = nil
	--self.PanelAgree = nil
	--self.PanelBtn = nil
	--self.PanelHeading = nil
	--self.PanelSideWin = nil
	--self.ProBarCD = nil
	--self.RichTextNumber = nil
	--self.RichTextTitle = nil
	--self.TextNo = nil
	--self.TextOther = nil
	--self.TextYes = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBarLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarGiveUpTaskWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAccept)
	self:AddSubView(self.BtnRefuse)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarGiveUpTaskWinView:OnInit()
	self.BindersGiveUp = {
        { "GiveUpDesc",       		UIBinderSetText.New(self, self.RichTextNumber) },
		{"VoteGiveUpCounterDescNew", UIBinderSetText.New(self, self.RichTextTitle)},
		{ "HasVoteGiveUp",       	UIBinderSetIsVisible.New(self, self.PanelBtn, true) },
		{ "HasVoteGiveUp",       	UIBinderSetIsVisible.New(self, self.PanelAgree) },
		{ "VoteOpGiveUpAccept",       	UIBinderSetIsVisible.New(self, self.TextYes) },
		{ "VoteOpGiveUpAccept",       	UIBinderSetIsVisible.New(self, self.TextNo, true) },
    }

	self.BindersExpelPlayer = {
        { "ExileDesc",       			UIBinderSetText.New(self, self.RichTextNumber) },
		{ "HasVoteExile",       	UIBinderSetIsVisible.New(self, self.PanelBtn, true) },
		{ "HasVoteExile",       	UIBinderSetIsVisible.New(self, self.PanelAgree) },
		{ "VoteOpExileAccept",       	UIBinderSetIsVisible.New(self, self.TextYes) },
		{ "VoteOpExileAccept",       	UIBinderSetIsVisible.New(self, self.TextNo, true) },
		{	"VoteExileCounterDesc", UIBinderSetText.New(self, self.RichTextTitle)},
    }

	local PworldVoteCfg = require("TableCfg/PworldVoteCfg")
	local ProtoCommon = require("Protocol/ProtoCommon")
	self.DurationGiveup = (PworldVoteCfg:FindCfgByKey(ProtoCommon.SceneVoteType.SceneVoteGiveup) or {}).Duration
	self.DurationExpel =  (PworldVoteCfg:FindCfgByKey(ProtoCommon.SceneVoteType.SceneVoteKick) or {}).Duration
end

function SidebarGiveUpTaskWinView:OnShow()
	local UIViewMgr = require("UI/UIViewMgr")
	UIViewMgr:HideView(_G.UIViewID.PWorldQuestMenu)
	local PWorldHelper = require("Game/PWorld/PWorldHelper")

	if self.Params and self.Params.ShowType == TeamDefine.VoteType.TASK_GIVEUP then
		self.BtnAccept:SetText(PWorldHelper.GetPWorldText("BTN_GIVEUP_YES"))
		self.BtnRefuse:SetText(PWorldHelper.GetPWorldText("BTN_GIVEUP_NO"))
		self.TextOther:SetText(_G.LSTR(1320186))
		self.TextYes:SetText(_G.LSTR(1320188))
		self.TextNo:SetText(_G.LSTR(1320187))
	end

	if self.Params and self.Params.ShowType == TeamDefine.VoteType.EXPEL_PLAYER then
		self.BtnAccept:SetText(PWorldHelper.GetPWorldText("BTN_EXPEL_YES"))
		self.BtnRefuse:SetText(PWorldHelper.GetPWorldText("BTN_EXPEL_NO"))
		self.TextOther:SetText(_G.LSTR(1320177))
		self.TextYes:SetText(_G.LSTR(1320179))
		self.TextNo:SetText(_G.LSTR(1320178))
	end
end

function SidebarGiveUpTaskWinView:OnHide()
	_G.SidebarMgr:TryOpenSidebarMainWin()
end

function SidebarGiveUpTaskWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnFoldButtonClick)
	UIUtil.AddOnClickedEvent(self, self.BtnAccept, self.OnAgreeeButtonClick)
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnRefuseButtonClick)
end

function SidebarGiveUpTaskWinView:OnFoldButtonClick()
	self:Hide()
end

function SidebarGiveUpTaskWinView:OnAgreeeButtonClick()
	if self.Params.ShowType == TeamDefine.VoteType.TASK_GIVEUP then
		_G.PWorldTeamMgr:ReqPWVoteGiveUp(true)
	elseif self.Params.ShowType == TeamDefine.VoteType.EXPEL_PLAYER then
		_G.PWorldTeamMgr:ReqPWVoteExile(true)
	end
end

function SidebarGiveUpTaskWinView:OnRefuseButtonClick()
	if self.Params.ShowType == TeamDefine.VoteType.TASK_GIVEUP then
		_G.PWorldTeamMgr:ReqPWVoteGiveUp(false)
	elseif self.Params.ShowType == TeamDefine.VoteType.EXPEL_PLAYER then
		_G.PWorldTeamMgr:ReqPWVoteExile(false)
	end
end

function SidebarGiveUpTaskWinView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimerUpdate, 0, 1, 0, nil)
end


function SidebarGiveUpTaskWinView:OnTimerUpdate()
	if self.Params == nil then
		return
	end

	_G.PWorldTeamVM:UpdCounter()

	if self.Params.ShowType == TeamDefine.VoteType.EXPEL_PLAYER then
		_G.PWorldTeamVM:UpdCounterExile()
		_G.PWorldTeamVM:UpdVoteExile()
		self.ProBarCD:SetPercent(_G.PWorldTeamVM.VoteExileCounter / self.DurationExpel)
	end

	if self.Params.ShowType == TeamDefine.VoteType.TASK_GIVEUP then
		self.ProBarCD:SetPercent(_G.PWorldTeamVM.VoteGiveUpCounter / self.DurationGiveup)
	end
end

function SidebarGiveUpTaskWinView:OnRegisterGameEvent()

end

function SidebarGiveUpTaskWinView:OnRegisterBinder()
	if self.Params == nil then
		_G.FLOG_ERROR(debug.traceback("SidebarGiveUpTaskWinView:OnRegisterBinder: SidebarGiveUpTaskWinView needs params to show!"))
		return
	end

	self:UnRegisterAllBinder()

	if self.Params.ShowType == TeamDefine.VoteType.TASK_GIVEUP then
		self:RegisterBinders(_G.PWorldTeamVM, self.BindersGiveUp)
	elseif self.Params.ShowType == TeamDefine.VoteType.EXPEL_PLAYER then
		self:RegisterBinders(_G.PWorldTeamVM, self.BindersExpelPlayer)
	end
end

return SidebarGiveUpTaskWinView