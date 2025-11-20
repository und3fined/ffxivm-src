---
--- Author: Administrator
--- DateTime: 2024-02-04 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local AudioType = GoldSaucerMiniGameDefine.AudioType
local LSTR = _G.LSTR

---@class GoldSaucerCuffchallengeBeginsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Begins UScaleBox
---@field P_EFF_particles_GoldSaucer_Cuff_9 UUIParticleEmitter
---@field PanelLine UFCanvasPanel
---@field PanelSubtitle UFCanvasPanel
---@field Prepare UScaleBox
---@field RichTextSub URichTextBox
---@field ScaleBoxTitle UScaleBox
---@field TextBegins UFTextBlock
---@field TextPrepare UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimBegins UWidgetAnimation
---@field AnimFinal UWidgetAnimation
---@field AnimGreen UWidgetAnimation
---@field AnimPrepare UWidgetAnimation
---@field IsLineVisible bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffchallengeBeginsItemView = LuaClass(UIView, true)

function GoldSaucerCuffchallengeBeginsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Begins = nil
	--self.P_EFF_particles_GoldSaucer_Cuff_9 = nil
	--self.PanelLine = nil
	--self.PanelSubtitle = nil
	--self.Prepare = nil
	--self.RichTextSub = nil
	--self.ScaleBoxTitle = nil
	--self.TextBegins = nil
	--self.TextPrepare = nil
	--self.TextTitle = nil
	--self.AnimBegins = nil
	--self.AnimFinal = nil
	--self.AnimGreen = nil
	--self.AnimPrepare = nil
	--self.IsLineVisible = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffchallengeBeginsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffchallengeBeginsItemView:OnInit()
	self.PrepareEndCallBack = nil
	self.BeginEndCallBack = nil
	self.BlessReadyEndCallBack = nil
end

function GoldSaucerCuffchallengeBeginsItemView:OnDestroy()

end

function GoldSaucerCuffchallengeBeginsItemView:OnShow()

end

function GoldSaucerCuffchallengeBeginsItemView:OnHide()
	self:StopAllAnimations()
	self.PrepareEndCallBack = nil
	self.BeginEndCallBack = nil
	self.BlessReadyEndCallBack = nil
end

function GoldSaucerCuffchallengeBeginsItemView:OnRegisterUIEvent()

end

function GoldSaucerCuffchallengeBeginsItemView:OnRegisterGameEvent()

end

function GoldSaucerCuffchallengeBeginsItemView:OnRegisterBinder()

end

function GoldSaucerCuffchallengeBeginsItemView:SetPrepare(CallBack)
	UIUtil.SetIsVisible(self.Begins, false)
	UIUtil.SetIsVisible(self.ScaleBoxTitle, false)
	UIUtil.SetIsVisible(self.Prepare, true)
	UIUtil.SetIsVisible(self.PanelSubtitle, false)
	self.TextPrepare:SetText(LSTR(250021)) -- 准备
	self:PlayAnimation(self.AnimPrepare)
	self.PrepareEndCallBack = CallBack
end

--- 显示开始效果的标题内容
function GoldSaucerCuffchallengeBeginsItemView:SetBegin(CallBack, CustomTitle, CustomSubTitle)
	UIUtil.SetIsVisible(self.Begins, true)
	UIUtil.SetIsVisible(self.Prepare, false)
	UIUtil.SetIsVisible(self.ScaleBoxTitle, false)
	local MainTitleContent = LSTR(250022) -- 开始
	if CustomTitle then
		MainTitleContent = CustomTitle
	end
	self.TextBegins:SetText(MainTitleContent)
	local bSubTitleValid = CustomSubTitle ~= nil
	UIUtil.SetIsVisible(self.PanelSubtitle, bSubTitleValid)
	if bSubTitleValid then
		self.RichTextSub:SetText(CustomSubTitle)
	end
	self:PlayAnimation(self.AnimBegins)
	self.BeginEndCallBack = CallBack
end

function GoldSaucerCuffchallengeBeginsItemView:SetBlessRoundReady(CallBack)
	UIUtil.SetIsVisible(self.Begins, false)
	UIUtil.SetIsVisible(self.Prepare, false)
	UIUtil.SetIsVisible(self.PanelSubtitle, false)
	UIUtil.SetIsVisible(self.ScaleBoxTitle, true)
	self.TextTitle:SetText(LSTR(1660007)) -- 赐福时间
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.BigBlessReady)
	self:PlayAnimation(self.AnimGreen)
	self.BlessReadyEndCallBack = CallBack
end

function GoldSaucerCuffchallengeBeginsItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimPrepare then
		local PrepareCallBack = self.PrepareEndCallBack
		if PrepareCallBack then
			PrepareCallBack()
			self.PrepareEndCallBack = nil
		end
	elseif Anim == self.AnimBegins then
		local BeginCallBack = self.BeginEndCallBack
		if BeginCallBack then
			BeginCallBack()
			self.BeginCallBack = nil
		end
		self:ResetParticle()
	elseif Anim == self.AnimGreen then
		local BlessReadyEndCallBack = self.BlessReadyEndCallBack
		if BlessReadyEndCallBack then
			BlessReadyEndCallBack()
			self.BlessReadyEndCallBack = nil
		end
	end
end

function GoldSaucerCuffchallengeBeginsItemView:ResetParticle()
	self.P_EFF_particles_GoldSaucer_Cuff_9:ResetParticle()
	_G.ObjectMgr:CollectGarbage(false)
end

return GoldSaucerCuffchallengeBeginsItemView