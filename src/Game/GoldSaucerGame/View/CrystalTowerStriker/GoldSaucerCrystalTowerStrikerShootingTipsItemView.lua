---
--- Author: bowxiong
--- DateTime: 2025-03-12 18:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local CrystalTowerAudioDefine = require("Game/GoldSaucerMiniGame/CrystalTower/CrystalTowerAudioDefine")
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local EventID = _G.EventID

---@class GoldSaucerCrystalTowerStrikerShootingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine3 UFImage
---@field ImgLine5 UFImage
---@field MI_DX_Common_GoldSaucer_3 UFImage
---@field PanelTipsBlue UFCanvasPanel
---@field PanelTipsFail UFCanvasPanel
---@field PanelTipsGreen UFCanvasPanel
---@field PanelTipsYellow UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextGood UFTextBlock
---@field TextPretty UFTextBlock
---@field TextPretty_1 UFTextBlock
---@field TextSmall2 UFTextBlock
---@field TextSmall3 UFTextBlock
---@field TextSmall4 UFTextBlock
---@field AnimTipsBlue UWidgetAnimation
---@field AnimTipsFail UWidgetAnimation
---@field AnimTipsGreen UWidgetAnimation
---@field AnimTipsYellow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCrystalTowerStrikerShootingTipsItemView = LuaClass(UIView, true)

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine3 = nil
	--self.ImgLine5 = nil
	--self.MI_DX_Common_GoldSaucer_3 = nil
	--self.PanelTipsBlue = nil
	--self.PanelTipsFail = nil
	--self.PanelTipsGreen = nil
	--self.PanelTipsYellow = nil
	--self.TextFail = nil
	--self.TextGood = nil
	--self.TextPretty = nil
	--self.TextPretty_1 = nil
	--self.TextSmall2 = nil
	--self.TextSmall3 = nil
	--self.TextSmall4 = nil
	--self.AnimTipsBlue = nil
	--self.AnimTipsFail = nil
	--self.AnimTipsGreen = nil
	--self.AnimTipsYellow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnInit()
	self.Binders = {
		{"bPrettyTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsGreen)},
		{"Text", UIBinderSetText.New(self, self.TextPretty)},
		{"SubText", UIBinderSetText.New(self, self.TextSmall2)},

		{"bGoodTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsBlue)},
		{"Text", UIBinderSetText.New(self, self.TextGood)},
		{"SubText", UIBinderSetText.New(self, self.TextSmall3)},

		{"bFailTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsFail)},
		{"Text", UIBinderSetText.New(self, self.TextFail)},
		{"SubText", UIBinderSetText.New(self, self.TextSmall4)},

		{"bYellowTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsYellow)},
		{"Text", UIBinderSetText.New(self, self.TextPretty_1)},

		{"bSubDataVisible", UIBinderSetIsVisible.New(self, self.ImgLine3)},
		{"bSubDataVisible", UIBinderSetIsVisible.New(self, self.ImgLine5)},
		{"bSubDataVisible", UIBinderSetIsVisible.New(self, self.TextSmall2)},
		{"bSubDataVisible", UIBinderSetIsVisible.New(self, self.TextSmall3)},
		{"bSubDataVisible", UIBinderSetIsVisible.New(self, self.TextSmall4)}, --

		{"SubTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSmall2)},
		{"SubTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSmall3)},
		{"SubTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSmall4)},
	}
	-- 默认加载一次BP默认的多语言
	self.TextPretty:SetText(LSTR(250030)) -- 		打得漂亮
	self.TextSmall2:SetText(LSTR(270050)) -- 		三连命中
	self.TextGood:SetText(LSTR(250031)) -- 		打得好
	self.TextSmall3:SetText(LSTR(270050)) -- 		三连命中
	self.TextFail:SetText(LSTR(270007)) -- 		失败
	self.TextSmall4:SetText(LSTR(270051)) -- 		没什么手感.....
	self.TextPretty_1:SetText(LSTR(270052)) -- 	 全力一击
end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnDestroy()

end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnShow()

end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnHide()

end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnRegisterUIEvent()

end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MiniGameMainPanelPlayAnim, self.MiniGameCuffMainPlayAnimEvent)
end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnRegisterBinder()
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

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:OnAnimationFinished(_)
	if self.ParentView then
		self.ParentView:HideShootingTips()
	end
end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:MiniGameCuffMainPlayAnimEvent(InAnim)
	local Anim = MiniGameClientConfig[MiniGameType.CrystalTower].Anim
	if InAnim == Anim.AnimTipsYellow then
		self:PlayAnimation(self.AnimTipsYellow)
		AudioUtil.LoadAndPlay2DSound(CrystalTowerAudioDefine.AudioPath.GameResultPerfect)
	elseif InAnim == Anim.AnimTipsBlue then
		self:PlayAnimation(self.AnimTipsBlue)
	elseif InAnim == Anim.AnimTipsGreen then
		self:PlayAnimation(self.AnimTipsGreen)
	elseif InAnim == Anim.AnimTipsFail then
		self:PlayAnimation(self.AnimTipsFail)
	end
end

function GoldSaucerCrystalTowerStrikerShootingTipsItemView:IsForceGC()
	return true
end

return GoldSaucerCrystalTowerStrikerShootingTipsItemView