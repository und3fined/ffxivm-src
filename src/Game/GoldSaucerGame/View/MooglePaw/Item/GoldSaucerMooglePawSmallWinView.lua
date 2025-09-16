---
--- Author: Administrator
--- DateTime: 2024-02-28 17:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local ScoreMgr = require("Game/Score/ScoreMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local LuaCameraMgr = require("Game/Camera/LuaCameraMgr")
local MooglePawParamsCfg = require("TableCfg/MooglePawParamsCfg")
local CatchBallParamType = ProtoRes.Game.CatchBallParamType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType

local LSTR = _G.LSTR

---@class GoldSaucerMooglePawSmallWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNormal UFButton
---@field BtnReccmmend UFButton
---@field FHorizontalBox_0 UFHorizontalBox
---@field MoneySlot CommMoneySlotView
---@field PanelCold UFCanvasPanel
---@field PlayStyleCommFrameS_UIBP PlayStyleCommFrameSView
---@field RichTextBox_36 URichTextBox
---@field TextCancel UFTextBlock
---@field TextConfirm UFTextBlock
---@field TextGoldinadequate UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawSmallWinView = LuaClass(UIView, true)

function GoldSaucerMooglePawSmallWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNormal = nil
	--self.BtnReccmmend = nil
	--self.FHorizontalBox_0 = nil
	--self.MoneySlot = nil
	--self.PanelCold = nil
	--self.PlayStyleCommFrameS_UIBP = nil
	--self.RichTextBox_36 = nil
	--self.TextCancel = nil
	--self.TextConfirm = nil
	--self.TextGoldinadequate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawSmallWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MoneySlot)
	self:AddSubView(self.PlayStyleCommFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawSmallWinView:InitConstStringInfo()
	self.TextCancel:SetText(LSTR(360030))
	self.TextConfirm:SetText(LSTR(360028))
	self.TextGoldinadequate:SetText(LSTR(360031))
	self.TextQuantity:SetText(1)

end

function GoldSaucerMooglePawSmallWinView:OnInit()
	self.ClientDefine = nil
	self.GameType = nil
	self.bCanStartGame = nil
	self.bEnterGame = nil
	self.EnsureFailQuit = nil
	self.RecoverGameLoop = nil
	self:InitConstStringInfo()
end

function GoldSaucerMooglePawSmallWinView:OnDestroy()

end

function GoldSaucerMooglePawSmallWinView:Reset()
	self.ClientDefine = nil
	self.GameType = nil
	self.bCanStartGame = nil
	self.bEnterGame = nil
	self.EnsureFailQuit = nil
	self.RecoverGameLoop = nil
	self:UnRegisterAllTimer()
end

function GoldSaucerMooglePawSmallWinView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	self.bEnterGame = Params.bEnterGame
	-- FLOG_INFO("GoldSaucerMooglePawSmallWinView:OnShow() bEnterGame = %s", self.bEnterGame)
	local GameType = Params.GameType
	self.GameType = GameType
	self.ClientDefine = MiniGameClientConfig[GameType]
	local bShowJDIcon
	if Params.bEnterGame then -- 作为进入游戏Tips
		local Dcfg = self.ClientDefine
		if Dcfg == nil then
			return
		end

		local TextTitle = self.TextTitle
		if TextTitle then
			TextTitle:SetText(Dcfg.Name)
		end

		self.PlayStyleCommFrameS_UIBP.RichTextBox_Title:SetText(Dcfg.Name)
		local ContentText = Dcfg.OKWinContent
		if ContentText then
			self.RichTextBox_36:SetText(ContentText)
		end
		bShowJDIcon = true
		self:UpdateScoreData()
		LuaCameraMgr:ResumeCamera(true) -- 交互后统一改变摄像机视角，避免摄像机碰撞造成的人物消失
	else				-- 作为退出游戏tip
		self.EnsureFailQuit = Params.EnsureFailQuit
		self.RecoverGameLoop = Params.RecoverGameLoop
		bShowJDIcon = false
		self.RichTextBox_36:SetText(LSTR(360026))
		self.PlayStyleCommFrameS_UIBP.RichTextBox_Title:SetText(LSTR(360027))
		self.TextConfirm:SetText(LSTR(360028))
	end
	UIUtil.SetIsVisible(self.PanelCold, bShowJDIcon)
	self.MoneySlot:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)

	self:SetBtnEnabled(true)
end

function GoldSaucerMooglePawSmallWinView:OnHide()
	if self.bEnterGame then
		_G.InteractiveMgr:ShowEntrances()
	else
		if self.RecoverGameLoop then
			self.RecoverGameLoop()
			self.RecoverGameLoop = nil
		end
	end
	self:Reset()
end

function GoldSaucerMooglePawSmallWinView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.BtnClosure, self.OnBtnNormalClick)
	UIUtil.AddOnClickedEvent(self, self.BtnReccmmend, self.OnBtnReccmmendClick)
	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnBtnNormalClick)
end

function GoldSaucerMooglePawSmallWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateScore, self.OnUpdateScoreValue)
end

function GoldSaucerMooglePawSmallWinView:OnRegisterBinder()

end

function GoldSaucerMooglePawSmallWinView:OnBtnReccmmendClick()
	if self.bEnterGame then
		local bCanStart = self.bCanStartGame
		if bCanStart then
			local Params = self.Params
			if Params == nil then
				return
			end
			GoldSaucerMiniGameMgr:OnDetailMiniGameStart(self.GameType, Params.EntityID)
		else
			_G.JumboCactpotMgr:GetJDcoin()
			self:Hide()
		end
	else
		local FailQuit = self.EnsureFailQuit
		if FailQuit then
			FailQuit()
			self.EnsureFailQuit = nil
		end
		self.RecoverGameLoop = nil
		self:Hide()
	end
end

function GoldSaucerMooglePawSmallWinView:OnBtnNormalClick()
	self:Hide()
end

function GoldSaucerMooglePawSmallWinView:OnUpdateScoreValue(ScoreID)
	if ScoreID ~= ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE then
		return
	end
	self:UpdateScoreData()
end

function GoldSaucerMooglePawSmallWinView:UpdateScoreData()
	if GoldSaucerMiniGameMgr:GetTheCurMiniGameInst() ~= nil then
		FLOG_ERROR("CurMiniGameInst is Exit")
		return
	end
	self.MoneySlot:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)

	local DCfg = self.ClientDefine
	if DCfg == nil then
		return
	end

	local ScoreCost = DCfg.Cost or 0
	if self.GameType == MiniGameType.MooglesPaw then
		local CostParamCfg = MooglePawParamsCfg:FindCfgByKey(CatchBallParamType.CatchBallParamTypeGoldCoinCost)
		if CostParamCfg then
			ScoreCost = CostParamCfg.Value
		end
	end
	local MajorKingDeeNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	local bShowOkPanel = MajorKingDeeNum >= ScoreCost
	self.bCanStartGame = bShowOkPanel
	UIUtil.SetIsVisible(self.FHorizontalBox_0, bShowOkPanel)
	UIUtil.SetIsVisible(self.TextGoldinadequate, not bShowOkPanel)
	local ConfirmBtnContent = bShowOkPanel and LSTR(360028) or LSTR(360029)
	self.TextConfirm:SetText(ConfirmBtnContent)
	-- 这一段省略配置赋值，蓝图默认为1 24.02.29  Alex
	--[[if bShowOkPanel then
		self.TextNumber:SetText(tostring(ScoreCost))
	end--]]
end

function GoldSaucerMooglePawSmallWinView:SetBtnEnabled(bEnable)
	self.BtnReccmmend:SetIsEnabled(bEnable)
	self.BtnNormal:SetIsEnabled(bEnable)
	self.PlayStyleCommFrameS_UIBP:SetBtnCloseEnable(bEnable)
end


return GoldSaucerMooglePawSmallWinView