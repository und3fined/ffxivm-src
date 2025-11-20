---
--- Author: Administrator
--- DateTime: 2024-02-28 17:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local AudioType = GoldSaucerMiniGameDefine.AudioType
local LSTR = _G.LSTR

-- 轮次序号对应UI名称状态序号
local Round2StateIndex = {
	[1] = 2,
	[2] = 2,
	[3] = 3,
	[4] = 3,
	[5] = 4,
}

---@class GoldSaucerMooglePawRoundTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelRound2 UFCanvasPanel
---@field PanelRound3 UFCanvasPanel
---@field PanelRound4 UFCanvasPanel
---@field TextRound2 UFTextBlock
---@field TextRound3 UFTextBlock
---@field TextRound4 UFTextBlock
---@field AnimOutManual UWidgetAnimation
---@field AnimRound2 UWidgetAnimation
---@field AnimRound3 UWidgetAnimation
---@field AnimRound4 UWidgetAnimation
---@field AnimSection1 UWidgetAnimation
---@field AnimSection2 UWidgetAnimation
---@field AnimSection3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawRoundTipsItemView = LuaClass(UIView, true)

function GoldSaucerMooglePawRoundTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelRound2 = nil
	--self.PanelRound3 = nil
	--self.PanelRound4 = nil
	--self.TextRound2 = nil
	--self.TextRound3 = nil
	--self.TextRound4 = nil
	--self.AnimOutManual = nil
	--self.AnimRound2 = nil
	--self.AnimRound3 = nil
	--self.AnimRound4 = nil
	--self.AnimSection1 = nil
	--self.AnimSection2 = nil
	--self.AnimSection3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawRoundTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawRoundTipsItemView:InitConstStringInfo()
	self.TextRound2:SetText(LSTR(360023))
	self.TextRound3:SetText(LSTR(360024))
	self.TextRound4:SetText(LSTR(360025))
end

function GoldSaucerMooglePawRoundTipsItemView:OnInit()
	self.AnimOutEndCallBack = nil
	--self:InitConstStringInfo()
end

function GoldSaucerMooglePawRoundTipsItemView:OnDestroy()

end

function GoldSaucerMooglePawRoundTipsItemView:OnShow()
	
end

function GoldSaucerMooglePawRoundTipsItemView:OnHide()

end

function GoldSaucerMooglePawRoundTipsItemView:OnRegisterUIEvent()

end

function GoldSaucerMooglePawRoundTipsItemView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawRoundTipsItemView:OnRegisterBinder()

end

function GoldSaucerMooglePawRoundTipsItemView:ShowRoundTips(ViewModel, CallBack)
	local GameInst = ViewModel.MiniGame
	if not GameInst then
		return
	end

	UIUtil.SetIsVisible(self.PanelRound2, false)
	UIUtil.SetIsVisible(self.PanelRound3, false)
	UIUtil.SetIsVisible(self.PanelRound4, false)

	local CurRoundIndex = GameInst:GetRoundIndex() + 1
	local TotalRound = GameInst:GetTheMaxRound()

	local StateKey = 2
	if CurRoundIndex <= 2 then
		StateKey = 2
	elseif CurRoundIndex <= TotalRound - 1 then
		StateKey = 3
	else
		StateKey = 4
	end

	local PanelKeyToShow = string.format("PanelRound%s", tostring(StateKey))
	local AnimKeyToPlay = string.format("AnimRound%s", tostring(StateKey))
	local TextKeyToShow = string.format("TextRound%s", tostring(StateKey))
	local PanelToShow = self[PanelKeyToShow]
	local AnimToPlay = self[AnimKeyToPlay]
	local TextToShow = self[TextKeyToShow]
	if PanelToShow and AnimToPlay and TextToShow then
		UIUtil.SetIsVisible(PanelToShow, true)
		UIUtil.SetIsVisible(TextToShow, true)
		local FormatContent = StateKey == 4 and LSTR(360043) or string.format(LSTR(360041), CurRoundIndex, TotalRound)
		TextToShow:SetText(FormatContent)
		self:PlayAnimation(AnimToPlay)
		GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleRoundTitle)
		self.AnimOutEndCallBack = CallBack
	end
end

function GoldSaucerMooglePawRoundTipsItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimOutManual then
		local OutEndCallBack = self.AnimOutEndCallBack
		if OutEndCallBack then
			OutEndCallBack()
			self.AnimOutEndCallBack = nil
		end
	elseif Anim == self.AnimRound2 or Anim == self.AnimRound3 or Anim == self.AnimRound4 then
		self:RegisterTimer(function()
		    self:PlayAnimation(self.AnimOutManual)
		end, 0.5)
	end
end

return GoldSaucerMooglePawRoundTipsItemView