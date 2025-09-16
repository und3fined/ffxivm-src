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

---@class GoldSaucerMooglePawRoundTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelRound2 UFCanvasPanel
---@field PanelRound3 UFCanvasPanel
---@field PanelRound4 UFCanvasPanel
---@field TextRound2 UFTextBlock
---@field TextRound3 UFTextBlock
---@field TextRound4 UFTextBlock
---@field AnimOut UWidgetAnimation
---@field AnimRound2 UWidgetAnimation
---@field AnimRound3 UWidgetAnimation
---@field AnimRound4 UWidgetAnimation
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
	--self.AnimOut = nil
	--self.AnimRound2 = nil
	--self.AnimRound3 = nil
	--self.AnimRound4 = nil
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
	self:InitConstStringInfo()
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
	local PanelKeyToShow = string.format("PanelRound%s", tostring(CurRoundIndex))
	local AnimKeyToPlay = string.format("AnimRound%s", tostring(CurRoundIndex))
	local PanelToShow = self[PanelKeyToShow]
	local AnimToPlay = self[AnimKeyToPlay]
	if PanelToShow and AnimToPlay then
		UIUtil.SetIsVisible(PanelToShow, true)
		self:PlayAnimation(AnimToPlay)
		GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleRoundTitle)
		self.AnimOutEndCallBack = CallBack
	end
end

function GoldSaucerMooglePawRoundTipsItemView:OnAnimationFinished(Anim)
	local AnimEndTime = Anim:GetEndTime()
	self:RegisterTimer(function()
		local OutEndCallBack = self.AnimOutEndCallBack
		if OutEndCallBack then
			OutEndCallBack()
			self.AnimOutEndCallBack = nil
		end
	end, AnimEndTime)
	
end

return GoldSaucerMooglePawRoundTipsItemView