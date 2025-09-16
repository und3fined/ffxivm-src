---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local UIView = require("UI/UIView")
local LocalizationUtil = require("Utils/LocalizationUtil")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local LuaClass = require("Core/LuaClass")
local QueueMgr = require("Game/LoginNew/Mgr/QueueMgr")
local UIBinderSetServerName = require("Binder/UIBinderSetServerName")
local UIBinderSetServerState = require("Binder/UIBinderSetServerState")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LSTR = _G.LSTR

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO

---@class LoginNewTipsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnOut CommBtnLView
---@field BtnRecommend CommBtnLView
---@field FHorizontalFull UFHorizontalBox
---@field FHorizontalLineUp UFHorizontalBox
---@field FHorizontalTime UFHorizontalBox
---@field FHorizontalWait UFHorizontalBox
---@field LoginNewSever LoginNewSeverItemView
---@field Panel2Btns UFHorizontalBox
---@field PopUpBG CommonPopUpBGView
---@field RichTextBoxTitle URichTextBox
---@field SpacerMid USpacer
---@field TextLineUp UFTextBlock
---@field TextLineUp2 UFTextBlock
---@field TextSever UFTextBlock
---@field TextTime UFTextBlock
---@field TextTime2 UFTextBlock
---@field TextTime_1 UFTextBlock
---@field TextWait UFTextBlock
---@field TextWait2 UFTextBlock
---@field TextWait2_1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewTipsWinView = LuaClass(UIView, true)

function LoginNewTipsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnOut = nil
	--self.BtnRecommend = nil
	--self.FHorizontalFull = nil
	--self.FHorizontalLineUp = nil
	--self.FHorizontalTime = nil
	--self.FHorizontalWait = nil
	--self.LoginNewSever = nil
	--self.Panel2Btns = nil
	--self.PopUpBG = nil
	--self.RichTextBoxTitle = nil
	--self.SpacerMid = nil
	--self.TextLineUp = nil
	--self.TextLineUp2 = nil
	--self.TextSever = nil
	--self.TextTime = nil
	--self.TextTime2 = nil
	--self.TextTime_1 = nil
	--self.TextWait = nil
	--self.TextWait2 = nil
	--self.TextWait2_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewTipsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnOut)
	self:AddSubView(self.BtnRecommend)
	self:AddSubView(self.LoginNewSever)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewTipsWinView:OnInit()
	self.BtnOut:SetText(LSTR(LoginStrID.SvrQueueQuit))
	self.BtnRecommend:SetText(LSTR(LoginStrID.SvrQueueRecommend))
	self.TextLineUp:SetText(LSTR(LoginStrID.SvrQueuing))
	self.TextTime:SetText(LSTR(LoginStrID.SvrQueueDuration))
	self.TextWait:SetText(LSTR(LoginStrID.SvrQueueWait))
	self.TextTime_1:SetText(LSTR(LoginStrID.SvrQueueTips))
	self.TextWait2_1:SetText(")")

	self:InitBinders()
end

function LoginNewTipsWinView:OnDestroy()

end

function LoginNewTipsWinView:OnShow()
	UIUtil.SetIsVisible(self.BtnClose, false, false)

	if QueueMgr.bShowQueue then
		self:ShowQueue()
	else
		self:ShowServerFull()
	end
end

function LoginNewTipsWinView:OnHide()
	FLOG_INFO("[LoginNewTipsWinView:OnHide] ")
	if self.TimerId ~= nil then
		_G.TimerMgr:CancelTimer(self.TimerId)
		self.TimerId = nil
	end
end

function LoginNewTipsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRecommend, self.OnClickBtnRecommend)
	UIUtil.AddOnClickedEvent(self, self.BtnOut, self.OnClickBtnOut)
end

function LoginNewTipsWinView:OnRegisterGameEvent()

end

function LoginNewTipsWinView:OnRegisterBinder()
	self:RegisterBinders(LoginNewVM, self.Binders)
end

function LoginNewTipsWinView:OnClickBtnOut()
	FLOG_INFO("[LoginNewTipsWinView:OnClickBtnOut]")
	QueueMgr:CancelQueue()
end

function LoginNewTipsWinView:OnClickBtnRecommend()
	FLOG_INFO("[LoginNewTipsWinView:OnClickBtnRecommend]")
	UIViewMgr:ShowView(UIViewID.LoginServerList)
end

function LoginNewTipsWinView:InitBinders()
	local Binders = {
		-- 服务器名称
		{ "WorldID", UIBinderSetServerName.New(self, self.TextSever) },
		{ "WorldState", UIBinderSetServerState.New(self, self.LoginNewSever.ImgSeverState) },
		{ "FakeWaitTotalTimeStr", UIBinderSetText.New(self, self.TextWait2) },
		{ "FakeWaitCountTimeStr", UIBinderSetText.New(self, self.TextTime2) },
		{ "FakeWaitPeople", UIBinderSetText.New(self, self.TextLineUp2) },
	}

	self.Binders = Binders
end

function LoginNewTipsWinView:ShowQueue()
	FLOG_INFO("[LoginNewTipsWinView:ShowQueue]")
	self.RichTextBoxTitle:SetText(LSTR(LoginStrID.SvrQueueTitle))
	UIUtil.SetIsVisible(self.BtnOut, true)
	UIUtil.SetIsVisible(self.SpacerMid, true)
	UIUtil.SetIsVisible(self.FHorizontalLineUp, true)
	UIUtil.SetIsVisible(self.FHorizontalTime, true)
	UIUtil.SetIsVisible(self.FHorizontalWait, true)
	UIUtil.SetIsVisible(self.FHorizontalFull, false)
end

function LoginNewTipsWinView:ShowServerFull()
	FLOG_INFO("[LoginNewTipsWinView:ShowServerFull]")
	self.RichTextBoxTitle:SetText(LSTR(LoginStrID.SvrFull))
	UIUtil.SetIsVisible(self.BtnOut, false)
	UIUtil.SetIsVisible(self.SpacerMid, false)
	UIUtil.SetIsVisible(self.FHorizontalLineUp, false)
	UIUtil.SetIsVisible(self.FHorizontalTime, false)
	UIUtil.SetIsVisible(self.FHorizontalWait, false)
	UIUtil.SetIsVisible(self.FHorizontalFull, true)
end

return LoginNewTipsWinView