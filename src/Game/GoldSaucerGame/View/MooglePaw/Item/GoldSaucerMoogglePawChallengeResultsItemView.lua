---
--- Author: Administrator
--- DateTime: 2024-03-04 19:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local AudioType = GoldSaucerMiniGameDefine.AudioType
local LSTR = _G.LSTR

---@class GoldSaucerMoogglePawChallengeResultsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMonster UFImage
---@field ImgMonsterFail123 UFImage
---@field PanelFail UFCanvasPanel
---@field PanelFailBG UFCanvasPanel
---@field PanelMianResult UFCanvasPanel
---@field PanelNornalBG UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field PanelTimesup UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextSuccess UFTextBlock
---@field TextTimesup UFTextBlock
---@field AnimFaill UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---@field AnimTimesup UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMoogglePawChallengeResultsItemView = LuaClass(UIView, true)

function GoldSaucerMoogglePawChallengeResultsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMonster = nil
	--self.ImgMonsterFail123 = nil
	--self.PanelFail = nil
	--self.PanelFailBG = nil
	--self.PanelMianResult = nil
	--self.PanelNornalBG = nil
	--self.PanelSuccess = nil
	--self.PanelTimesup = nil
	--self.TextFail = nil
	--self.TextSuccess = nil
	--self.TextTimesup = nil
	--self.AnimFaill = nil
	--self.AnimSuccess = nil
	--self.AnimTimesup = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMoogglePawChallengeResultsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMoogglePawChallengeResultsItemView:InitConstStringInfo()
	self.TextTimesup:SetText(LSTR(360012))
	self.TextSuccess:SetText(LSTR(360013))
	self.TextFail:SetText(LSTR(360014))
end

function GoldSaucerMoogglePawChallengeResultsItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSaucerMoogglePawChallengeResultsItemView:OnDestroy()

end

function GoldSaucerMoogglePawChallengeResultsItemView:OnShow()

end

function GoldSaucerMoogglePawChallengeResultsItemView:OnHide()

end

function GoldSaucerMoogglePawChallengeResultsItemView:OnRegisterUIEvent()

end

function GoldSaucerMoogglePawChallengeResultsItemView:OnRegisterGameEvent()

end

function GoldSaucerMoogglePawChallengeResultsItemView:OnRegisterBinder()

end

function GoldSaucerMoogglePawChallengeResultsItemView:UpdateChallengeResult(EndState)
	local bSuccess = EndState == MiniGameRoundEndState.Success
	UIUtil.SetIsVisible(self.PanelNornalBG, bSuccess)
	UIUtil.SetIsVisible(self.PanelFailBG, not bSuccess)

	UIUtil.SetIsVisible(self.PanelTimesup, false)
	UIUtil.SetIsVisible(self.PanelSuccess, false)
	UIUtil.SetIsVisible(self.PanelFail, false)
	if bSuccess then
		UIUtil.SetIsVisible(self.PanelSuccess, true)
		self:PlayAnimation(self.AnimSuccess)
		GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleSuccessResult)
	else
		if EndState == MiniGameRoundEndState.FailTime then
			UIUtil.SetIsVisible(self.PanelTimesup, true)
			self:PlayAnimation(self.AnimTimesup)
		elseif EndState == MiniGameRoundEndState.FailRule then -- 视觉图暂时也按照次数用尽结算
			UIUtil.SetIsVisible(self.PanelFail, true)
			--self.TextFail:SetText(LSTR("次数用尽"))
			self:PlayAnimation(self.AnimFaill)
		end
		GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleFailResult)
	end
end

return GoldSaucerMoogglePawChallengeResultsItemView