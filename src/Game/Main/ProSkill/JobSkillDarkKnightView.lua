---
--- Author: Administrator
--- DateTime: 2025-08-07 14:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap

---@class JobSkillDarkKnightView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgDarkArts3 UFImage
---@field MI_DX_2_a UFImage
---@field PanelDarkArts UFCanvasPanel
---@field PanelHead UFCanvasPanel
---@field PanelUnlock UFCanvasPanel
---@field ProgressBarOrange UProgressBar
---@field ProgressBarPurple UProgressBar
---@field ProgressBarRed UProgressBar
---@field TextNum UFTextBlock
---@field TextUnlock UFTextBlock
---@field AnimDarkArtsHide UWidgetAnimation
---@field AnimDarkArtsLoop UWidgetAnimation
---@field AnimDarkArtsShow UWidgetAnimation
---@field AnimEnergyIs100 UWidgetAnimation
---@field AnimEnergyIs50 UWidgetAnimation
---@field AnimEnergyLess50 UWidgetAnimation
---@field AnimEnergyOver50 UWidgetAnimation
---@field AnimProBarDecrease UWidgetAnimation
---@field AnimProBarIncrease UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---@field ValueProBarStart float
---@field ValueProBarEnd float
---@field CurveProBar CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillDarkKnightView = LuaClass(ProfProSkillViewBase, true)
local SkillSpectrum_DarkKnight_Blood = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_DarkKnight_Art = LuaClass(ProSkillSpectrumBase, true)
-- local SkillSpectrum_DarkKnight_Darkness = LuaClass(ProSkillSpectrumBase, true)

function JobSkillDarkKnightView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgDarkArts3 = nil
	--self.MI_DX_2_a = nil
	--self.PanelDarkArts = nil
	--self.PanelHead = nil
	--self.PanelUnlock = nil
	--self.ProgressBarOrange = nil
	--self.ProgressBarPurple = nil
	--self.ProgressBarRed = nil
	--self.TextNum = nil
	--self.TextUnlock = nil
	--self.AnimDarkArtsHide = nil
	--self.AnimDarkArtsLoop = nil
	--self.AnimDarkArtsShow = nil
	--self.AnimEnergyIs100 = nil
	--self.AnimEnergyIs50 = nil
	--self.AnimEnergyLess50 = nil
	--self.AnimEnergyOver50 = nil
	--self.AnimProBarDecrease = nil
	--self.AnimProBarIncrease = nil
	--self.AnimUnlock = nil
	--self.ValueProBarStart = nil
	--self.ValueProBarEnd = nil
	--self.CurveProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillDarkKnightView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillDarkKnightView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.DarkKnight_Blood, SkillSpectrum_DarkKnight_Blood)
	self:BindSpectrumBehavior(SpectrumIDMap.DarkKnight_Art, SkillSpectrum_DarkKnight_Art)
	-- self:BindSpectrumBehavior(SpectrumIDMap.DarkKnight_Darkness, SkillSpectrum_DarkKnight_Darkness)
end

function JobSkillDarkKnightView:OnDestroy()

end

function JobSkillDarkKnightView:OnShow()
	self.Super:OnShow()
end

function JobSkillDarkKnightView:OnHide()

end

function JobSkillDarkKnightView:OnRegisterUIEvent()

end

function JobSkillDarkKnightView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
end

function JobSkillDarkKnightView:OnRegisterBinder()

end

function JobSkillDarkKnightView:OnUpdateBuff(Params)
	local BuffID = Params.IntParam1
	local EntityID = Params.ULongParam1

	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end

	local SpectrumPair = self.SpectrumPair
	for _, value in pairs(SpectrumPair) do
		if value and value.Begin and value.BuffID == BuffID then
			value:OnCastBuff(Params)
		end
	end
end

function JobSkillDarkKnightView:OnRemoveBuff(Params)
	local BuffID = Params.IntParam1
	local EntityID = Params.ULongParam1

	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end

	local SpectrumPair = self.SpectrumPair
	for _, value in pairs(SpectrumPair) do
		if value and value.Begin and value.BuffID == BuffID then
			value:OnRemoveBuff(Params)
		end
	end
end

--DarkKnight_Blood START

function SkillSpectrum_DarkKnight_Blood:OnInit()
	self.Super:OnInit()
	self:SkillSpectrumOff()
end

function SkillSpectrum_DarkKnight_Blood:SkillSpectrumOn()
	self.CurrentProgressBar = self.View.ProgressBarRed
	UIUtil.SetIsVisible(self.View.ProgressBarRed, true)
	UIUtil.SetIsVisible(self.View.ProgressBarOrange, false)
	UIUtil.SetIsVisible(self.View.ProgressBarPurple, false)
end

function SkillSpectrum_DarkKnight_Blood:SkillSpectrumOff()
	if nil ~= self.CurrentProgressBar then
		self.CurrentProgressBar = nil
	end
	self.View.ProgressBarRed:SetPercent(0)
	self.View.TextNum:SetText(0)
	UIUtil.SetIsVisible(self.View.ProgressBarRed, false)
	UIUtil.SetIsVisible(self.View.ProgressBarOrange, false)
	UIUtil.SetIsVisible(self.View.ProgressBarPurple, false)
end

function SkillSpectrum_DarkKnight_Blood:ValueUpdateFunc(CurValue, TargetValue)
	local TypeParams = _G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)
	local Threshold1 = TypeParams[1]
	local Threshold2 = TypeParams[2]
	-- 暗黑值量谱呼吸动效
	if TargetValue < Threshold1 then
		self.View:PlayAnimationToEndTime(self.View.AnimEnergyLess50)
	elseif TargetValue >= Threshold1 and TargetValue < Threshold2 then
		if CurValue < Threshold1 then
			self.View:PlayAnimation(self.View.AnimEnergyIs50)
		end
		self.View:PlayAnimationToEndTime(self.View.AnimEnergyOver50)
	elseif TargetValue >= Threshold2 then
		self.View:PlayAnimationToEndTime(self.View.AnimEnergyIs100)
	end
	-- 暗黑值变化ProgressBar动效
	local CurPercent = CurValue / self.SpectrumMaxValue
	local TargetPercent = TargetValue / self.SpectrumMaxValue
	-- 直接使用蓝图函数
	self.View:PlayAnimProBar(CurPercent,TargetPercent)
	local TextValue = math.floor(TargetValue / 100)
	self.View.TextNum:SetText(tostring(TextValue))
end

function SkillSpectrum_DarkKnight_Blood:ValueUpdateEachFunc(CurValue)

end

--DarkKnight_Blood END

--DarkKnight_Art START

function SkillSpectrum_DarkKnight_Art:OnInit()
	self.Super:OnInit()
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID))
end

function SkillSpectrum_DarkKnight_Art:SkillSpectrumOn()
	UIUtil.SetIsVisible(self.View.PanelDarkArts, true)
end

function SkillSpectrum_DarkKnight_Art:SkillSpectrumOff()
	UIUtil.SetIsVisible(self.View.PanelDarkArts, false)
end

function SkillSpectrum_DarkKnight_Art:OnCastBuff(Params)
	self.View:PlayAnimation(self.View.AnimDarkArtsShow)
	self.View:PlayAnimation(self.View.AnimDarkArtLoop)
end

function SkillSpectrum_DarkKnight_Art:OnRemoveBuff(Params)
	self.View:PlayAnimation(self.View.AnimDarkArtsHide)
	self.View:StopAnimation(self.View.AnimDarkArtLoop)
end

--DarkKnight_Art END

return JobSkillDarkKnightView