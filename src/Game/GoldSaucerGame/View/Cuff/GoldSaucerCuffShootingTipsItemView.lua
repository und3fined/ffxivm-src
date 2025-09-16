---
--- Author: bowxiong
--- DateTime: 2025-02-26 16:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CuffRewardCfg = require("TableCfg/CuffRewardCfg")
local LSTR = _G.LSTR
local ScoreStage = { Best = 3, Nice = 2, Good = 1}

---@class GoldSaucerCuffShootingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNumberHundred UFImage
---@field ImgNumberIndivual UFImage
---@field ImgNumberTen UFImage
---@field ImgNumberThousand UFImage
---@field ImgPz UFImage
---@field MI_DX_Common_GoldSaucer_3 UFImage
---@field P_DX_OutOnALimb_1 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_1 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_3 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_4 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_5 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_6 UUIParticleEmitter
---@field P_EFF_particles_GoldSaucer_7 UUIParticleEmitter
---@field PanelStrengthValue UFCanvasPanel
---@field PanelTipsBlue UFCanvasPanel
---@field PanelTipsFail UFCanvasPanel
---@field PanelTipsGreen UFCanvasPanel
---@field PanelTipsYellow UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextGood UFTextBlock
---@field TextPretty UFTextBlock
---@field TextPretty_1 UFTextBlock
---@field AnimTipsBlue UWidgetAnimation
---@field AnimTipsFail UWidgetAnimation
---@field AnimTipsGreen UWidgetAnimation
---@field AnimTipsYellow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffShootingTipsItemView = LuaClass(UIView, true)

function GoldSaucerCuffShootingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNumberHundred = nil
	--self.ImgNumberIndivual = nil
	--self.ImgNumberTen = nil
	--self.ImgNumberThousand = nil
	--self.ImgPz = nil
	--self.MI_DX_Common_GoldSaucer_3 = nil
	--self.P_DX_OutOnALimb_1 = nil
	--self.P_EFF_particles_GoldSaucer_1 = nil
	--self.P_EFF_particles_GoldSaucer_3 = nil
	--self.P_EFF_particles_GoldSaucer_4 = nil
	--self.P_EFF_particles_GoldSaucer_5 = nil
	--self.P_EFF_particles_GoldSaucer_6 = nil
	--self.P_EFF_particles_GoldSaucer_7 = nil
	--self.PanelStrengthValue = nil
	--self.PanelTipsBlue = nil
	--self.PanelTipsFail = nil
	--self.PanelTipsGreen = nil
	--self.PanelTipsYellow = nil
	--self.TextFail = nil
	--self.TextGood = nil
	--self.TextPretty = nil
	--self.TextPretty_1 = nil
	--self.AnimTipsBlue = nil
	--self.AnimTipsFail = nil
	--self.AnimTipsGreen = nil
	--self.AnimTipsYellow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffShootingTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffShootingTipsItemView:OnInit()
	local AllRewardCfg = CuffRewardCfg:FindAllCfg()
	self.CuffResultValue = { 
		Best = AllRewardCfg[ScoreStage.Best].Score,
		Nice = AllRewardCfg[ScoreStage.Nice].Score,
		Good = AllRewardCfg[ScoreStage.Good].Score,
	}

	self.ENum = {
		[0] = "Zero",
		[1] = "One",
		[2] = "Two",
		[3] = "Three",
		[4] = "Four",
		[5] = "Five",
		[6] = "Six",
		[7] = "Seven",
		[8] = "Eight",
		[9] = "Nine",
	}

	self.NumPath = {
		Zero = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score0_png.UI_GoldSaucer_Cuff_Number_Score0_png'",
		One = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score1_png.UI_GoldSaucer_Cuff_Number_Score1_png'",
		Two = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score2_png.UI_GoldSaucer_Cuff_Number_Score2_png'",
		Three = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score3_png.UI_GoldSaucer_Cuff_Number_Score3_png'",
		Four = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score4_png.UI_GoldSaucer_Cuff_Number_Score4_png'",
		Five = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score5_png.UI_GoldSaucer_Cuff_Number_Score5_png'",
		Six = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score6_png.UI_GoldSaucer_Cuff_Number_Score6_png'",
		Seven = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score7_png.UI_GoldSaucer_Cuff_Number_Score7_png'",
		Eight = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score8_png.UI_GoldSaucer_Cuff_Number_Score8_png'",
		Nine = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Number_Score9_png.UI_GoldSaucer_Cuff_Number_Score9_png'"
	}

	self.Binders = {
		{"bPrettyTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsGreen)},
		{"bGoodTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsBlue)},
		{"bFailTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsFail)},
		{"bYellowTipVisible", UIBinderSetIsVisible.New(self, self.PanelTipsYellow)},
	}
end

function GoldSaucerCuffShootingTipsItemView:OnDestroy()

end

function GoldSaucerCuffShootingTipsItemView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local StrengthValue = self.Params.StrengthValue
	self:SetResultByPower(StrengthValue)
end

function GoldSaucerCuffShootingTipsItemView:OnHide()

end

function GoldSaucerCuffShootingTipsItemView:OnRegisterUIEvent()

end

function GoldSaucerCuffShootingTipsItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffShootingTipsItemView:OnRegisterBinder()

end

function GoldSaucerCuffShootingTipsItemView:OnAnimationFinished(Anim)
	self:Hide()
end

function GoldSaucerCuffShootingTipsItemView:SetResultByPower(StrengthValue)
	UIUtil.SetIsVisible(self.PanelStrengthValue, true)
	self:SetStrengthValue(StrengthValue)
	local CuffResultValue = self.CuffResultValue
	local bGreenVisible, bBlueVisible, bFailVisible, bYellowVisible = false, false, false, false
	if tonumber(StrengthValue) >= CuffResultValue.Best then
		bYellowVisible = true
	elseif tonumber(StrengthValue) >= CuffResultValue.Nice then
		bBlueVisible = true
	elseif tonumber(StrengthValue) >= CuffResultValue.Good then
		bGreenVisible = true
	else
		bFailVisible = true
	end
	UIUtil.SetIsVisible(self.PanelTipsGreen, bGreenVisible)
	UIUtil.SetIsVisible(self.PanelTipsYellow, bYellowVisible)
	UIUtil.SetIsVisible(self.PanelTipsFail, bFailVisible)
	UIUtil.SetIsVisible(self.PanelTipsBlue, bBlueVisible)

	local NeedAnim
	if bYellowVisible then
		NeedAnim = self.AnimTipsYellow
		self.TextPretty_1:SetText(LSTR(270052)) -- 全力一击
	elseif bBlueVisible then
		NeedAnim = self.AnimTipsBlue
		self.TextGood:SetText(LSTR(250030)) -- 打得漂亮
	elseif bGreenVisible then
		NeedAnim = self.AnimTipsGreen
		self.TextPretty:SetText(LSTR(250031)) -- 打得好
	elseif bFailVisible then
		NeedAnim = self.AnimTipsFail
		self.TextFail:SetText(LSTR(270007)) -- 失败
	end
	if NeedAnim ~= nil then
		self:PlayAnimation(NeedAnim)
	end
end

function GoldSaucerCuffShootingTipsItemView:SetStrengthValue(StrengthValue)
	local bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = false, false, false, false
	if StrengthValue - 1000 >= 0 then
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = true, true, true, true
	elseif StrengthValue - 100 >= 0 then
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = true, true, true, false
	elseif StrengthValue - 10 >= 0 then
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = true, true, false, false
	elseif StrengthValue - 1 >= 0 then
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = true, false, false, false
	else
		bIndivualVisible, bTenVisible, bHundredVisible, bThousandVisible = false, false, false, false
	end
	UIUtil.SetIsVisible(self.ImgNumberIndivual, bIndivualVisible)
	UIUtil.SetIsVisible(self.ImgNumberTen, bTenVisible)
	UIUtil.SetIsVisible(self.ImgNumberHundred, bHundredVisible)
	UIUtil.SetIsVisible(self.ImgNumberThousand, bThousandVisible)

	local Thousand = math.floor(StrengthValue / 1000)
	local Hundred = math.floor(StrengthValue % 1000 / 100)
	local Ten = math.floor(StrengthValue % 100 /10)
	local Indivaul = math.floor(StrengthValue % 10)
	local ENum = self.ENum
	local NumPath = self.NumPath
	if bIndivualVisible then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgNumberIndivual, NumPath[ENum[Indivaul]] )
	end
	if bTenVisible then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgNumberTen, NumPath[ENum[Ten]] )
	end
	if bHundredVisible then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgNumberHundred, NumPath[ENum[Hundred]] )
	end
	if bThousandVisible then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgNumberThousand, NumPath[ENum[Thousand]] )
	end
end

return GoldSaucerCuffShootingTipsItemView