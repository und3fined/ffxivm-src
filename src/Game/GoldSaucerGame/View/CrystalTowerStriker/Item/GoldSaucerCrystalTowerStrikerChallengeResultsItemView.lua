---
--- Author: Administrator
--- DateTime: 2024-03-08 19:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GoldSaucerCrystalTowerStrikerChallengeResultsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCrystal1 UFImage
---@field ImgCrystal10 UFImage
---@field ImgCrystal2 UFImage
---@field ImgCrystal3 UFImage
---@field ImgCrystal4 UFImage
---@field ImgCrystal5 UFImage
---@field ImgCrystal6 UFImage
---@field ImgCrystal7 UFImage
---@field ImgCrystal8 UFImage
---@field ImgCrystal9 UFImage
---@field ImgIceberg UFImage
---@field ImgIceberg2 UFImage
---@field PanelFail UFCanvasPanel
---@field PanelFailBG UFCanvasPanel
---@field PanelMianResult UFCanvasPanel
---@field PanelNornalBG UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field PanelTimesup UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextSuccess UFTextBlock
---@field TextTimesup UFTextBlock
---@field AnimInFail UWidgetAnimation
---@field AnimInTimeUp UWidgetAnimation
---@field AnimMainLoop UWidgetAnimation
---@field AnimVictory UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCrystalTowerStrikerChallengeResultsItemView = LuaClass(UIView, true)

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCrystal1 = nil
	--self.ImgCrystal10 = nil
	--self.ImgCrystal2 = nil
	--self.ImgCrystal3 = nil
	--self.ImgCrystal4 = nil
	--self.ImgCrystal5 = nil
	--self.ImgCrystal6 = nil
	--self.ImgCrystal7 = nil
	--self.ImgCrystal8 = nil
	--self.ImgCrystal9 = nil
	--self.ImgIceberg = nil
	--self.ImgIceberg2 = nil
	--self.PanelFail = nil
	--self.PanelFailBG = nil
	--self.PanelMianResult = nil
	--self.PanelNornalBG = nil
	--self.PanelSuccess = nil
	--self.PanelTimesup = nil
	--self.TextFail = nil
	--self.TextSuccess = nil
	--self.TextTimesup = nil
	--self.AnimInFail = nil
	--self.AnimInTimeUp = nil
	--self.AnimMainLoop = nil
	--self.AnimVictory = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnInit()

end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnDestroy()

end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnShow()
	local LSTR = _G.LSTR
	self.TextTimesup:SetText(LSTR(250023)) -- 时间结束
	self.TextSuccess:SetText(LSTR(250024)) -- 挑战成功
	self.TextFail:SetText(LSTR(250025)) -- 挑战失败
end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnHide()

end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnRegisterUIEvent()

end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnRegisterGameEvent()

end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnRegisterBinder()

end

function GoldSaucerCrystalTowerStrikerChallengeResultsItemView:OnAnimationFinished(Animation)
	if Animation == self.AnimVictory or Animation == self.AnimInFail or Animation == self.TextTimesup then
		if self:IsAnimationPlaying(self.AnimMainLoop) then
			self:StopAnimation(self.AnimMainLoop)
		end
		self:PlayAnimation(self.AnimMainLoop, 0, 0)
	end
end

return GoldSaucerCrystalTowerStrikerChallengeResultsItemView