---
--- Author: Administrator
--- DateTime: 2025-06-24 15:56
--- Description:赐福模式入场提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local UIUtil = require("Utils/UIUtil")
local FairyBlessedWeightCfg = require("TableCfg/FairyBlessedWeightCfg")
local FairyBlessedTargetCfg = require("TableCfg/FairyBlessedTargetCfg")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local BLESSED_KIND = ProtoCS.Game.FairyBlessed.BLESSED_KIND
local AudioType = GoldSaucerMiniGameDefine.AudioType
local LSTR = _G.LSTR

---@class GoldSaucerInfoTextTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Panel1 UFCanvasPanel
---@field Panel2 UFCanvasPanel
---@field PanelPositiveSmall UFCanvasPanel
---@field TextPositiveSmallSubTitle UFTextBlock
---@field TextPositiveSmallTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerInfoTextTipsView = LuaClass(UIView, true)

function GoldSaucerInfoTextTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Panel1 = nil
	--self.Panel2 = nil
	--self.PanelPositiveSmall = nil
	--self.TextPositiveSmallSubTitle = nil
	--self.TextPositiveSmallTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerInfoTextTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerInfoTextTipsView:OnInit()

end

function GoldSaucerInfoTextTipsView:OnDestroy()

end

function GoldSaucerInfoTextTipsView:OnShow()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local BlessKind = ViewModel.BlessKind
	UIUtil.SetIsVisible(self.Panel1, BlessKind == BLESSED_KIND.BLESSED_KIND_LITTLE)
	UIUtil.SetIsVisible(self.Panel2, BlessKind == BLESSED_KIND.BLESSED_KIND_BIG)

	local MainTitleText = BlessKind == BLESSED_KIND.BLESSED_KIND_BIG and LSTR(1660002) or LSTR(1660001)
	self.TextPositiveSmallTitle:SetText(MainTitleText)

	local EobjResID = ViewModel.EobjResID
	local WeightCfg = FairyBlessedWeightCfg:FindCfg(string.format("EObjResID = %d", EobjResID))
	if WeightCfg then
		local TargetCfg = FairyBlessedTargetCfg:FindCfgByKey(WeightCfg.Activity)
		if TargetCfg then
			self.TextPositiveSmallSubTitle:SetText(TargetCfg.EnterSubTitle or "")
		end
	end
    GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.BlessTipsEnter)
end

function GoldSaucerInfoTextTipsView:OnHide()

end

function GoldSaucerInfoTextTipsView:OnRegisterUIEvent()

end

function GoldSaucerInfoTextTipsView:OnRegisterGameEvent()

end

function GoldSaucerInfoTextTipsView:OnRegisterBinder()

end

return GoldSaucerInfoTextTipsView