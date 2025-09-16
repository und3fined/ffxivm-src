---
--- Author: Administrator
--- DateTime: 2024-03-04 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local CuffRewardCfg = require("TableCfg/CuffRewardCfg")
local LSTR = _G.LSTR
local ScoreStage = { Best = 3, Nice = 2, Good = 1}

local MiniGameProgressType = GoldSaucerMiniGameDefine.MiniGameProgressType
local AudioType = GoldSaucerMiniGameDefine.AudioType
local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldSaucerMonsterTossShootingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field MI_DX_Common_GoldSaucer_1 UFImage
---@field MI_DX_Common_GoldSaucer_3 UFImage
---@field PanelTipsFail UFCanvasPanel
---@field PanelTipsSuccess UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextSmall UFTextBlock
---@field TextSuccess UFTextBlock
---@field AnimTipsFail UWidgetAnimation
---@field AnimTipsSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMonsterTossShootingTipsItemView = LuaClass(UIView, true)

function GoldSaucerMonsterTossShootingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.MI_DX_Common_GoldSaucer_1 = nil
	--self.MI_DX_Common_GoldSaucer_3 = nil
	--self.PanelTipsFail = nil
	--self.PanelTipsSuccess = nil
	--self.TextFail = nil
	--self.TextSmall = nil
	--self.TextSuccess = nil
	--self.AnimTipsFail = nil
	--self.AnimTipsSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossShootingTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossShootingTipsItemView:OnInit()
	self.Binders = {
		{"bSuccessTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsSuccess)},
		{"SubText", UIBinderSetText.New(self, self.TextSmall)},

		{"bFailTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsFail)},

		{"bSubDataVisible", UIBinderSetIsVisible.New(self, self.ImgLine)},
		{"bSubDataVisible", UIBinderSetIsVisible.New(self, self.TextSmall)},

		{"SubTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSmall)},
	}
	-- 默认加载一次BP默认的多语言  
	self.TextSuccess:SetText(LSTR(270008)) -- 	成功
	self.TextFail:SetText(LSTR(270007)) -- 		失败
	self.TextSmall:SetText(LSTR(270050)) -- 		三连命中
end

function GoldSaucerMonsterTossShootingTipsItemView:OnDestroy()
end

function GoldSaucerMonsterTossShootingTipsItemView:OnShow()
end

function GoldSaucerMonsterTossShootingTipsItemView:OnHide()
end

function GoldSaucerMonsterTossShootingTipsItemView:OnRegisterUIEvent()

end

function GoldSaucerMonsterTossShootingTipsItemView:OnRegisterGameEvent()

end

function GoldSaucerMonsterTossShootingTipsItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSaucerMonsterTossShootingTipsItemView:ShowResult(bHit)
	if bHit then
		self:PlayAnimation(self.AnimTipsSuccess)
	else
		self:PlayAnimation(self.AnimTipsFail)
	end
end

function GoldSaucerMonsterTossShootingTipsItemView:IsForceGC()
	return true
end

return GoldSaucerMonsterTossShootingTipsItemView