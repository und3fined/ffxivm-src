---
--- Author: Administrator
--- DateTime: 2024-02-28 17:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local LSTR = _G.LSTR

---@class GoldSaucerMooglePawMediumWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClosure UFButton
---@field BtnNormal UFButton
---@field BtnReccmmend UFButton
---@field PlayStyleCommFrameM_UIBP PlayStyleCommFrameMView
---@field Text URichTextBox
---@field TextCancel UFTextBlock
---@field TextConfirm UFTextBlock
---@field TextRemainingTimes UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawMediumWinView = LuaClass(UIView, true)

function GoldSaucerMooglePawMediumWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClosure = nil
	--self.BtnNormal = nil
	--self.BtnReccmmend = nil
	--self.PlayStyleCommFrameM_UIBP = nil
	--self.Text = nil
	--self.TextCancel = nil
	--self.TextConfirm = nil
	--self.TextRemainingTimes = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawMediumWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayStyleCommFrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawMediumWinView:InitConstStringInfo()
	self.TextCancel:SetText(LSTR(360021))
	self.TextConfirm:SetText(LSTR(360022))
end

function GoldSaucerMooglePawMediumWinView:OnInit()
	self.GameType = nil
	self.bHideSendMsg = true -- 关闭界面时是否发送不再翻倍挑战协议
	self:InitConstStringInfo()
end

function GoldSaucerMooglePawMediumWinView:OnDestroy()

end

function GoldSaucerMooglePawMediumWinView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local BgWidget = self.PlayStyleCommFrameM_UIBP
	if BgWidget then
		BgWidget:SetTitle(LSTR(360015))
		BgWidget:SetCurrencyVisible(false)
	end
	local RewardContent
	local ConstRewardContent = LSTR(360016)
	local GameType = Params.GameType
	self.GameType = GameType
	self.bHideSendMsg = true -- 打开界面时默认关闭界面自动发送不再翻倍挑战协议
	local RemainTime = Params.RemainTime
	local RemainTimeContent = string.format(LSTR(360017), TimeUtil.GetTimeFormat("%M:%S", math.ceil(RemainTime))) 
	local RewardChangeContent = ""
	if GameType == MiniGameType.MooglesPaw then
		local BaseReward = Params.BaseReward or 1
		local CurReward = Params.CurReward or 0
		local NextReward = Params.NextReward or 0
		local CurRewardMultiply = CurReward / BaseReward
		local NextRewardMultiply = NextReward / BaseReward
		local CurMultiplyContent = CurRewardMultiply == math.floor(CurRewardMultiply) and tostring(CurRewardMultiply) or string.format("%.2f", CurRewardMultiply)
		local NextMultiplyContent = NextRewardMultiply == math.floor(NextRewardMultiply) and tostring(NextRewardMultiply) or string.format("%.2f", NextRewardMultiply)
		RewardChangeContent = string.format(LSTR(360018), CurMultiplyContent, NextMultiplyContent)
	elseif GameType == MiniGameType.OutOnALimb or GameType == MiniGameType.TheFinerMiner then
		RewardChangeContent = string.format(LSTR(360019), tostring(Params.CurReward), tostring(Params.NewReward))
	end

	RewardContent = string.format("%s%s%s", ConstRewardContent, RemainTimeContent, RewardChangeContent)
	self.Text:SetText(RewardContent)
	local RemainChances = Params.RemainChances or 0
	self.TextRemainingTimes:SetText(string.format(LSTR(360020), RemainChances))
end

function GoldSaucerMooglePawMediumWinView:OnHide()
	if self.bHideSendMsg then
		-- 直接关闭界面默认不再次挑战
		EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = false})
	end

	local Major = MajorUtil.GetMajor()
	if Major then
		local Location = Major:FGetActorLocation()
		if Location then
			FLOG_INFO("MoogleTouchError:Role DoubleView Hide Pos %s %s %s", Location.X, Location.Y, Location.Z)
		end
	end
end

function GoldSaucerMooglePawMediumWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnBtnNormalClick)
	UIUtil.AddOnClickedEvent(self, self.BtnReccmmend, self.OnBtnReccmmendClick)
	UIUtil.AddOnClickedEvent(self, self.BtnClosure, self.OnBtnClosureClick)
end

function GoldSaucerMooglePawMediumWinView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawMediumWinView:OnRegisterBinder()

end

function GoldSaucerMooglePawMediumWinView:OnBtnNormalClick()
	EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = false})
	self.bHideSendMsg = false
	self:Hide()
end

function GoldSaucerMooglePawMediumWinView:OnBtnReccmmendClick()
	EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = true})
	self.bHideSendMsg = false
	self:Hide()
end

function GoldSaucerMooglePawMediumWinView:OnBtnClosureClick()
	self:Hide()
end

return GoldSaucerMooglePawMediumWinView