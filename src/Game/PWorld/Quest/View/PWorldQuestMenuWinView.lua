---
--- Author: v_zanchang
--- DateTime: 2022-09-27 09:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PWorldQuestMgr
local PWorldTeamMgr
local MsgTipsID = require("Define/MsgTipsID")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local TeamDefine = require("Game/Team/TeamDefine")
local PWorldHelper = require("Game/PWorld/PWorldHelper")

local LSTR = _G.LSTR
---@class PWorldQuestMenuWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnAdd CommBtnLView
---@field BtnExit CommBtnXLView
---@field BtnExpel CommBtnLView
---@field BtnGiveUp CommBtnLView
---@field BtnQuit CommBtnLView
---@field BtnQuitPunish CommBtnLView
---@field Icon_SearcherType UFImage
---@field ImgIcon01 UFImage
---@field PanelAdd UFCanvasPanel
---@field PanelDetailPage UFCanvasPanel
---@field PanelExpel UFCanvasPanel
---@field PanelGiveUp UFCanvasPanel
---@field PanelSetPage UFCanvasPanel
---@field PanelSetting UFCanvasPanel
---@field ScorllBoxFunctionPage UScrollBox
---@field SwitcherQuit UWidgetSwitcher
---@field TexGiveUpVote UFTextBlock
---@field TextAdd UFTextBlock
---@field TextAddDetail UFTextBlock
---@field TextExpel UFTextBlock
---@field TextExpelDetail UFTextBlock
---@field TextGiveUpDetail UFTextBlock
---@field TextGiveUpRule※只有任务开始15分钟后才_1 UFTextBlock
---@field TextGiveUpRule※只有任务开始15分钟后才_2 UFTextBlock
---@field TextIntro UFTextBlock
---@field TextIntroDesc UFTextBlock
---@field TextMsg UFTextBlock
---@field TextMsgDesc UFTextBlock
---@field TextPunish UFTextBlock
---@field TextQuit UFTextBlock
---@field TextQuitPunish UFTextBlock
---@field TextSetting UFTextBlock
---@field TextTitle01 UFTextBlock
---@field Text_SearcherCheck UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldQuestMenuWinView = LuaClass(UIView, true)

function PWorldQuestMenuWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnAdd = nil
	--self.BtnExit = nil
	--self.BtnExpel = nil
	--self.BtnGiveUp = nil
	--self.BtnQuit = nil
	--self.BtnQuitPunish = nil
	--self.Icon_SearcherType = nil
	--self.ImgIcon01 = nil
	--self.PanelAdd = nil
	--self.PanelDetailPage = nil
	--self.PanelExpel = nil
	--self.PanelGiveUp = nil
	--self.PanelSetPage = nil
	--self.PanelSetting = nil
	--self.ScorllBoxFunctionPage = nil
	--self.SwitcherQuit = nil
	--self.TexGiveUpVote = nil
	--self.TextAdd = nil
	--self.TextAddDetail = nil
	--self.TextExpel = nil
	--self.TextExpelDetail = nil
	--self.TextGiveUpDetail = nil
	--self.TextGiveUpRule※只有任务开始15分钟后才_1 = nil
	--self.TextGiveUpRule※只有任务开始15分钟后才_2 = nil
	--self.TextIntro = nil
	--self.TextIntroDesc = nil
	--self.TextMsg = nil
	--self.TextMsgDesc = nil
	--self.TextPunish = nil
	--self.TextQuit = nil
	--self.TextQuitPunish = nil
	--self.TextSetting = nil
	--self.TextTitle01 = nil
	--self.Text_SearcherCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldQuestMenuWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnAdd)
	self:AddSubView(self.BtnExit)
	self:AddSubView(self.BtnExpel)
	self:AddSubView(self.BtnGiveUp)
	self:AddSubView(self.BtnQuit)
	self:AddSubView(self.BtnQuitPunish)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldQuestMenuWinView:OnInit()
    PWorldQuestMgr = _G.PWorldQuestMgr
	PWorldTeamMgr = _G.PWorldTeamMgr

	self.Binders = {
		{ "CanGiveUp", 				UIBinderSetIsEnabled.New(self, self.BtnGiveUp)},
		{ "CanSupplement",       	UIBinderSetIsEnabled.New(self, self.BtnAdd) },
		{ "bCanExpel",       		UIBinderSetIsEnabled.New(self, self.BtnExpel) },
		{ "Mode", 					UIBinderValueChangedCallback.New(self, nil, self.OnBindMode) },
		{ "FuncAlpha", 				UIBinderSetRenderOpacity.New(self, self.PanelGiveUp) },
		{ "FuncAlpha", 				UIBinderSetRenderOpacity.New(self, self.PanelAdd) },
		{ "FuncAlpha", 				UIBinderSetRenderOpacity.New(self, self.PanelExpel) },
	}

	self.TeamBinders = {
		{ "IsSupplementing", UIBinderValueChangedCallback.New(self, nil, function(_, V)
			local Str = V and LSTR(1320103) or LSTR(1320104)
			self.BtnAdd:SetText(Str)
		end)}
	}

	self.BG:SetTitleText(LSTR(1320157))
	self.TexGiveUpVote:SetText(LSTR(1320158))
	self.TextGiveUpDetail:SetText(LSTR(1320159))
	self.BtnGiveUp:SetBtnName(LSTR(1320160))

	self.BtnAdd:SetBtnName(LSTR(1320163))
	self.TextAdd:SetText(LSTR(1320161))
	self.TextAddDetail:SetText(LSTR(1320162))

	self.TextExpel:SetText(LSTR(1320164))
	self.TextExpelDetail:SetText(LSTR(1320165))
	self.BtnExpel:SetText(LSTR(1320169))

	self.TextSetting:SetText(LSTR(1320168))
	self.BtnExit:SetText(LSTR(1320170))
end

function PWorldQuestMenuWinView:OnShow()
	self.bDestroyed = false
	_G.PWorldQuestVM:UpdateVM()
end

function PWorldQuestMenuWinView:OnRegisterTimer()
	self:RegisterTimer(function()
		PWorldQuestMgr:OnTimer()
	end, 0, 1, 0)
end

function PWorldQuestMenuWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnExit, function ()

		if _G.PWorldQuestVM.CanExit or _G.PWorldMgr.IsFinished or _G.PWorldTeamMgr:HasAddedMember() then
			if PWorldQuestMgr.IsRolling then
				_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(1320270), _G.LSTR(1320269), function()
					_G.PWorldMgr:SendLeavePWorld()
					self:CustomHide()
				end,
				nil, _G.LSTR(1320271), _G.LSTR(1320272))
				return
			end
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(1320067), _G.LSTR(1320105), function()
					_G.PWorldMgr:SendLeavePWorld()
					self:CustomHide()
				end,
				nil, nil, _G.LSTR(1320060))
		else
			_G.UIViewMgr:ShowView(_G.UIViewID.PWorldExitTaskWin, {
				TextTitle = LSTR(1320106),
				TextContent = PWorldHelper.GetPWorldText("QUIT_FUBEN_POPUP"),
				OKCallback = function ()
					_G.PWorldMgr:SendLeavePWorld()
					self:CustomHide()
				end
			})
		end
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnGiveUp, function()
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self , _G.LSTR(1320037), _G.LSTR(1320107), function()
			if _G.PWorldTeamMgr:IsVoting() then
				_G.MsgTipsUtil.ShowTipsByID(101015)
				return
			end
			_G.PWorldTeamMgr:ReqPWVoteStartGiveUp()
		end, nil, nil, _G.LSTR(1320108))
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnAdd, function()
		if PWorldTeamMgr.IsSupplementing then
			PWorldTeamMgr:ReqStopAddMem()
		else
			_G.UIViewMgr:ShowView(_G.UIViewID.PWorldAddMember)
		end
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnExpel, function()
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self , _G.LSTR(1320037), _G.LSTR(1320109), function()
			if _G.PWorldTeamMgr:IsVoting() then
				_G.MsgTipsUtil.ShowTipsByID(101015)
				return
			end
			_G.UIViewMgr:ShowView(_G.UIViewID.PWorldVoteBest, {ShowType=TeamDefine.VoteType.EXPEL_PLAYER})
		end, nil, _G.LSTR(1320174), _G.LSTR(1320175), {TipsText = LSTR(1320110)})
	end)
end

function PWorldQuestMenuWinView:OnRegisterGameEvent()
    -- left empty yet
end

function PWorldQuestMenuWinView:OnRegisterBinder()
	self:RegisterBinders(_G.PWorldQuestVM, self.Binders)
	self:RegisterBinders(_G.PWorldTeamVM, self.TeamBinders)
end

--- @region binder

function PWorldQuestMenuWinView:OnBindMode(Mode)
	self.TextTitle01:SetText(PWorldQuestUtil.GetSceneModeName(Mode) or "")

	local Icon = PWorldQuestUtil.GetSceneModeIcon(Mode)
	if string.isnilorempty(Icon) then
		UIUtil.SetIsVisible(self.PanelSetting, false)
	else
		UIUtil.SetIsVisible(self.PanelSetting, true)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon01, Icon)
	end
end

function PWorldQuestMenuWinView:OnDestroy()
	self.bDestroyed = true
end

function PWorldQuestMenuWinView:CustomHide()
	if not self.bDestroyed then
		self:Hide()
	end
end

return PWorldQuestMenuWinView
