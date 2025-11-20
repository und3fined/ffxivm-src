---
--- Author: AlexCY
--- DateTime: 2025-06-03 10:47
--- Description:新版翻倍界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ProtoRes = require("Protocol/ProtoRes")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local LSTR = _G.LSTR

---@class GoldSaucerMooglePawMediumWinNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNormal UFButton
---@field BtnReccmmend UFButton
---@field CommBackpack126Slot1 CommBackpack126SlotView
---@field CommBackpack126Slot2 CommBackpack126SlotView
---@field PlayStyleCommFrameM_UIBP PlayStyleCommFrameMView
---@field TextCancel UFTextBlock
---@field TextConfirm UFTextBlock
---@field TextContent URichTextBox
---@field TextSlot1 UFTextBlock
---@field TextSlot2 UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle1 UFTextBlock
---@field TextTitle2 UFTextBlock
---@field TextTitle3 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawMediumWinNewView = LuaClass(UIView, true)

function GoldSaucerMooglePawMediumWinNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNormal = nil
	--self.BtnReccmmend = nil
	--self.CommBackpack126Slot1 = nil
	--self.CommBackpack126Slot2 = nil
	--self.PlayStyleCommFrameM_UIBP = nil
	--self.TextCancel = nil
	--self.TextConfirm = nil
	--self.TextContent = nil
	--self.TextSlot1 = nil
	--self.TextSlot2 = nil
	--self.TextTime = nil
	--self.TextTitle1 = nil
	--self.TextTitle2 = nil
	--self.TextTitle3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawMediumWinNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack126Slot1)
	self:AddSubView(self.CommBackpack126Slot2)
	self:AddSubView(self.PlayStyleCommFrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawMediumWinNewView:InitConstStringInfo()
	self.TextCancel:SetText(LSTR(360021))
	self.TextConfirm:SetText(LSTR(360022))
	self.TextContent:SetText(LSTR(360016))
	self.TextTitle1:SetText(LSTR(360039))
	self.TextTitle3:SetText(LSTR(360040))
end

function GoldSaucerMooglePawMediumWinNewView:OnInit()
	self.GameType = nil
	self.bHideSendMsg = true -- 关闭界面时是否发送不再翻倍挑战协议
	self:InitConstStringInfo()
end

function GoldSaucerMooglePawMediumWinNewView:OnDestroy()

end

function GoldSaucerMooglePawMediumWinNewView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local BgWidget = self.PlayStyleCommFrameM_UIBP
	if BgWidget then
		BgWidget:SetTitle(LSTR(360015))
		BgWidget:SetCurrencyVisible(false)
	end

	local GameType = Params.GameType
	self.GameType = GameType
	self.bHideSendMsg = true -- 打开界面时默认关闭界面自动发送不再翻倍挑战协议
	local RemainTime = Params.RemainTime
	local RemainTimeContent = string.format(LSTR(360017), TimeUtil.GetTimeFormat("%M:%S", math.ceil(RemainTime)))
	self.TextTime:SetText(RemainTimeContent)

	local NextRound = Params.NextRound or 0
	local TotalRound = Params.TotalRound or 0
	self.TextTitle2:SetText(string.format(LSTR(360041), NextRound, TotalRound))

	local BaseReward = Params.BaseReward or 1
	local CurReward = Params.CurReward or 0
	local NextReward = Params.NextReward or 0
	self:UpdateMoneySlotDataByRoundChange(CurReward, NextReward)
	local CurRewardMultiply = CurReward / BaseReward
	local NextRewardMultiply = NextReward / BaseReward
	local CurMultiplyContent = CurRewardMultiply == math.floor(CurRewardMultiply) and tostring(CurRewardMultiply) or string.format("%.2f", CurRewardMultiply)
	local NextMultiplyContent = NextRewardMultiply == math.floor(NextRewardMultiply) and tostring(NextRewardMultiply) or string.format("%.2f", NextRewardMultiply)
	self.TextSlot1:SetText(string.format(LSTR(360042), CurMultiplyContent))
	self.TextSlot2:SetText(string.format(LSTR(360042), NextMultiplyContent))
end

function GoldSaucerMooglePawMediumWinNewView:OnHide()
	if self.bHideSendMsg then
		-- 直接关闭界面默认不再次挑战
		EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = false})
	end
end

function GoldSaucerMooglePawMediumWinNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnBtnNormalClick)
	UIUtil.AddOnClickedEvent(self, self.BtnReccmmend, self.OnBtnReccmmendClick)
end

function GoldSaucerMooglePawMediumWinNewView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawMediumWinNewView:OnRegisterBinder()
	local MoneySlotLeft = self.CommBackpack126Slot1
	if MoneySlotLeft then
		self.MoneyVMLeft = ItemUtil.CreateItem(SCORE_TYPE.SCORE_TYPE_KING_DEE, 0)
		MoneySlotLeft:SetParams({Data = self.MoneyVMLeft})
		MoneySlotLeft:SetClickButtonCallback(self, self.OnMoneySlotClickLeft)
	end

	local MoneySlotRight = self.CommBackpack126Slot2
	if MoneySlotRight then
		self.MoneyVMRight = ItemUtil.CreateItem(SCORE_TYPE.SCORE_TYPE_KING_DEE, 0)
		MoneySlotRight:SetParams({Data = self.MoneyVMRight})
		MoneySlotRight:SetClickButtonCallback(self, self.OnMoneySlotClickRight)
	end
end

function GoldSaucerMooglePawMediumWinNewView:OnBtnNormalClick()
	EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = false})
	self.bHideSendMsg = false
	self:Hide()
end

function GoldSaucerMooglePawMediumWinNewView:OnBtnReccmmendClick()
	EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = self.GameType or MiniGameType.OutOnALimb, bRestart = true})
	self.bHideSendMsg = false
	self:Hide()
end

function GoldSaucerMooglePawMediumWinNewView:OnMoneySlotClickLeft()
	ItemTipsUtil.ShowTipsByResID(SCORE_TYPE.SCORE_TYPE_KING_DEE, self.CommBackpack126Slot1, {X = 0, Y = 0})
end

function GoldSaucerMooglePawMediumWinNewView:OnMoneySlotClickRight()
	ItemTipsUtil.ShowTipsByResID(SCORE_TYPE.SCORE_TYPE_KING_DEE, self.CommBackpack126Slot2, {X = 0, Y = 0})
end

function GoldSaucerMooglePawMediumWinNewView:UpdateMoneySlotDataByRoundChange(LeftNum, RightNum)
	local ScoreResID = SCORE_TYPE.SCORE_TYPE_KING_DEE
	local MoneySlotLeft = self.CommBackpack126Slot1
	if MoneySlotLeft then
		MoneySlotLeft:SetIconChooseVisible(false)
		MoneySlotLeft:SetItemLevelVisible(false)
		local ColorIcon = ItemUtil.GetItemColorIcon(ScoreResID)
		local IconID = ItemUtil.GetItemIcon(ScoreResID)
		local ImgName = UIUtil.GetIconPath(IconID)
		MoneySlotLeft:SetQualityImg(ColorIcon)
		MoneySlotLeft:SetIconImg(ImgName)
		MoneySlotLeft:SetNum(LeftNum)
		MoneySlotLeft:SetClickButtonCallback(self, self.OnMoneySlotClickLeft)
	end

	local MoneySlotRight = self.CommBackpack126Slot2
	if MoneySlotRight then
		MoneySlotRight:SetIconChooseVisible(false)
		MoneySlotRight:SetItemLevelVisible(false)
		local ColorIcon = ItemUtil.GetItemColorIcon(ScoreResID)
		local IconID = ItemUtil.GetItemIcon(ScoreResID)
		local ImgName = UIUtil.GetIconPath(IconID)
		MoneySlotRight:SetQualityImg(ColorIcon)
		MoneySlotRight:SetIconImg(ImgName)
		MoneySlotRight:SetNum(RightNum)
		MoneySlotRight:SetClickButtonCallback(self, self.OnMoneySlotClickRight)
	end
end

return GoldSaucerMooglePawMediumWinNewView