---
--- Author: Alex
--- DateTime: 2024-04-16 16:00
--- Description:孤树&矿脉翻倍界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ItemVM = require("Game/Item/ItemVM")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local LSTR = _G.LSTR

---@class NewOutOnALimbDoubleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot1 CommBackpackSlotView
---@field BackpackSlot2 CommBackpackSlotView
---@field BtnClosure UFButton
---@field BtnNormal UFButton
---@field BtnReccmmend UFButton
---@field PlayStyleCommFrameM_UIBP PlayStyleCommFrameMView
---@field Text URichTextBox
---@field TextCancel UFTextBlock
---@field TextChallenge1 UFTextBlock
---@field TextChallenge2 UFTextBlock
---@field TextConfirm UFTextBlock
---@field TextRemainingTimes UFTextBlock
---@field TextTime URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewOutOnALimbDoubleWinView = LuaClass(UIView, true)

function NewOutOnALimbDoubleWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot1 = nil
	--self.BackpackSlot2 = nil
	--self.BtnClosure = nil
	--self.BtnNormal = nil
	--self.BtnReccmmend = nil
	--self.PlayStyleCommFrameM_UIBP = nil
	--self.Text = nil
	--self.TextCancel = nil
	--self.TextChallenge1 = nil
	--self.TextChallenge2 = nil
	--self.TextConfirm = nil
	--self.TextRemainingTimes = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewOutOnALimbDoubleWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot1)
	self:AddSubView(self.BackpackSlot2)
	self:AddSubView(self.PlayStyleCommFrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewOutOnALimbDoubleWinView:InitConstStringInfo()
	self.TextChallenge1:SetText(LSTR(370022))
	self.TextChallenge2:SetText(LSTR(370023))
	self.TextCancel:SetText(LSTR(370024))
	self.TextConfirm:SetText(LSTR(370025))
end

function NewOutOnALimbDoubleWinView:OnInit()
	self.GameType = nil
	self.bHideSendMsg = true -- 关闭界面时是否发送不再翻倍挑战协议

	self.ScoreItemBefore = ItemVM.New()
	self.ScoreItemAfter = ItemVM.New()
	self:InitConstStringInfo()
end

function NewOutOnALimbDoubleWinView:OnDestroy()

end

function NewOutOnALimbDoubleWinView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local BgWidget = self.PlayStyleCommFrameM_UIBP
	if BgWidget then
		BgWidget:SetTitle(LSTR(370018))
		BgWidget:SetCurrencyVisible(false)
	end
	
	local ConstRewardContent = LSTR(370019)
	self.Text:SetText(ConstRewardContent)
	local GameType = Params.GameType
	self.GameType = GameType
	self.bHideSendMsg = true -- 打开界面时默认关闭界面自动发送不再翻倍挑战协议
	local RemainTime = Params.RemainTime
	local RemainTimeContent = string.format(LSTR(370020), TimeUtil.GetTimeFormat("%M:%S", math.ceil(RemainTime))) 
	self.TextTime:SetText(RemainTimeContent)
	
	local RemainChances = Params.RemainChances or 0
	self.TextRemainingTimes:SetText(string.format(LSTR(370021), RemainChances))
	
	local SrcReward = Params.CurReward or 0
	local SrcItem = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, SrcReward)
	self.ScoreItemBefore:UpdateVM(SrcItem)
	
	local DstReward = Params.NewReward or 0
	local DstItem = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, DstReward)
	self.ScoreItemAfter:UpdateVM(DstItem)
	
end

function NewOutOnALimbDoubleWinView:OnHide()
	-- 直接关闭界面默认不再次挑战
	if self.bHideSendMsg then
		EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = false})
	end
end

function NewOutOnALimbDoubleWinView:OnRegisterUIEvent()
	self.BackpackSlot1:SetClickButtonCallback(self.BackpackSlot1, function(TargetItemView)
		ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, false, TargetItemView)
	end)
	self.BackpackSlot2:SetClickButtonCallback(self.BackpackSlot2, function(TargetItemView)
		ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, false, TargetItemView)
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnBtnNormalClick)
	UIUtil.AddOnClickedEvent(self, self.BtnReccmmend, self.OnBtnReccmmendClick)
	UIUtil.AddOnClickedEvent(self, self.BtnClosure, self.OnBtnClosureClick)
end

function NewOutOnALimbDoubleWinView:OnRegisterGameEvent()

end

function NewOutOnALimbDoubleWinView:OnRegisterBinder()
	self.BackpackSlot1:SetParams({Data = self.ScoreItemBefore})
	self.BackpackSlot2:SetParams({Data = self.ScoreItemAfter})
end

function NewOutOnALimbDoubleWinView:OnBtnNormalClick()
	EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = false})
	self.bHideSendMsg = false
	self:Hide()
end

function NewOutOnALimbDoubleWinView:OnBtnReccmmendClick()
	EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = true})
	self.bHideSendMsg = false
	self:Hide()
end

function NewOutOnALimbDoubleWinView:OnBtnClosureClick()
	self:Hide()
end

return NewOutOnALimbDoubleWinView