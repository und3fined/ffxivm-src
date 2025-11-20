---
--- Author: Administrator
--- DateTime: 2025-08-07 14:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local SkillUtil = require("Utils/SkillUtil")
local EventID = require("Define/EventID")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap


---@class JobSkillMachinistView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgEnergyRed UFImage
---@field ImgNeedle UFImage
---@field MI_DX_Circle_1_Electricity_a UFImage
---@field MI_DX_Circle_1_Electricity_b UFImage
---@field MI_DX_Circle_1_Electricity_c UFImage
---@field MI_DX_Circle_1_Heat_a UFImage
---@field MI_DX_Circle_1_Heat_b UFImage
---@field MI_DX_Circle_1_Heat_c UFImage
---@field PanelElectricity UFCanvasPanel
---@field PanelHeat UFCanvasPanel
---@field PanelUnlock UFCanvasPanel
---@field ProgressBarBlue UProgressBar
---
---@field ProgressBarRed UProgressBar
---@field T_DX_Basic_2_Electricity_a UFImage
---@field T_DX_Basic_2_Heat_a UFImage
---@field T_DX_UI_Main_ProSkill_Machinist_1 UFImage
---@field T_DX_UI_Main_ProSkill_Machinist_2 UFImage
---@field TextNum UFTextBlock
---@field TextNum2 UFTextBlock
---@field TextNum3 UFTextBlock
---@field TextNum4 UFTextBlock
---@field TextUnlock UFTextBlock
---@field AnimElectricityIs100Loop UWidgetAnimation
---@field AnimElectricityLess50 UWidgetAnimation
---@field AnimElectricityOver50 UWidgetAnimation
---@field AnimElectricityOverLoadLoop UWidgetAnimation
---@field AnimHeatIs100Loop UWidgetAnimation
---@field AnimHeatLess50 UWidgetAnimation
---@field AnimHeatOver50 UWidgetAnimation
---@field AnimHeatOverHeat UWidgetAnimation
---@field AnimProBarElectricityDecrease UWidgetAnimation
---@field AnimProBarElectricityIncrease UWidgetAnimation
---@field AnimProBarHeatDecrease UWidgetAnimation
---@field AnimProBarHeatIncrease UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---@field ValueProBarHeatStart float
---@field ValueProBarHeatEnd float
---@field ValueProBarElectricityStart float
---@field ValueProBarElectricityEnd float
---@field CurveProBar CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillMachinistView = LuaClass(ProfProSkillViewBase, true)
local SkillSpectrum_Manchinist_Heat = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_Manchinist_Electric = LuaClass(ProSkillSpectrumBase, true)

function JobSkillMachinistView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgEnergyRed = nil
	--self.ImgNeedle = nil
	--self.MI_DX_Circle_1_Electricity_a = nil
	--self.MI_DX_Circle_1_Electricity_b = nil
	--self.MI_DX_Circle_1_Electricity_c = nil
	--self.MI_DX_Circle_1_Heat_a = nil
	--self.MI_DX_Circle_1_Heat_b = nil
	--self.MI_DX_Circle_1_Heat_c = nil
	--self.PanelElectricity = nil
	--self.PanelHeat = nil
	--self.PanelUnlock = nil
	--self.ProgressBarBlue = nil
	--self.ProgressBarRed = nil
	--self.T_DX_Basic_2_Electricity_a = nil
	--self.T_DX_Basic_2_Heat_a = nil
	--self.T_DX_UI_Main_ProSkill_Machinist_1 = nil
	--self.T_DX_UI_Main_ProSkill_Machinist_2 = nil
	--self.TextNum = nil
	--self.TextNum2 = nil
	--self.TextNum3 = nil
	--self.TextNum4 = nil
	--self.TextUnlock = nil
	--self.AnimElectricityIs100Loop = nil
	--self.AnimElectricityLess50 = nil
	--self.AnimElectricityOver50 = nil
	--self.AnimElectricityOverLoadLoop = nil
	--self.AnimHeatIs100Loop = nil
	--self.AnimHeatLess50 = nil
	--self.AnimHeatOver50 = nil
	--self.AnimHeatOverHeat = nil
	--self.AnimProBarElectricityDecrease = nil
	--self.AnimProBarElectricityIncrease = nil
	--self.AnimProBarHeatDecrease = nil
	--self.AnimProBarHeatIncrease = nil
	--self.AnimUnlock = nil
	--self.ValueProBarHeatStart = nil
	--self.ValueProBarHeatEnd = nil
	--self.ValueProBarElectricityStart = nil
	--self.ValueProBarElectricityEnd = nil
	--self.CurveProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillMachinistView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillMachinistView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.Manchinist_Heat, SkillSpectrum_Manchinist_Heat)
	self:BindSpectrumBehavior(SpectrumIDMap.Manchinist_Electric, SkillSpectrum_Manchinist_Electric)
end

function JobSkillMachinistView:OnDestroy()

end

function JobSkillMachinistView:OnShow()
	self.Super:OnShow()
end

function JobSkillMachinistView:OnHide()

end

function JobSkillMachinistView:OnRegisterUIEvent()

end

function JobSkillMachinistView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
end

function JobSkillMachinistView:OnRegisterBinder()

end

function JobSkillMachinistView:OnUpdateBuff(Params)
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

function JobSkillMachinistView:OnRemoveBuff(Params)
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

function JobSkillMachinistView:OnHeatUpdateBuffTime(ExpdTime)
	local BuffTime = BuffUIUtil.GetLeftTimeSecondByExpdTime(ExpdTime)
	self.TextNum4:SetText(tostring(BuffTime))
end

function JobSkillMachinistView:OnElectricUpdateBuffTime(ExpdTime)
	local BuffTime = BuffUIUtil.GetLeftTimeSecondByExpdTime(ExpdTime)
	self.TextNum3:SetText(tostring(BuffTime))
end

--Machinist_Heat START

function SkillSpectrum_Manchinist_Heat:OnInit()
	self.Super:OnInit()
	self:SkillSpectrumOff()
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParam2(self.SpectrumID))
	self.CurAnim = nil
	self.HeatTimerID = 0
end

function SkillSpectrum_Manchinist_Heat:SkillSpectrumOn()
	self.CurrentProgressBar = self.View.ProgressBarRed
	UIUtil.SetIsVisible(self.View.PanelHeat, true)
	UIUtil.SetIsVisible(self.View.ProgressBarRed, true)
end

function SkillSpectrum_Manchinist_Heat:SkillSpectrumOff()
	if self.CurAnim ~= nil then
		self.View:StopAnimation(self.CurAnim)
		self.CurAnim = nil
	end
	self.View.ProgressBarRed:SetPercent(0)
	if nil ~= self.CurrentProgressBar then
		self.CurrentProgressBar = nil
	end
	self.View.TextNum:SetText(0)
	UIUtil.SetIsVisible(self.View.TextNum4, false)
	UIUtil.SetIsVisible(self.View.ProgressBarRed, false)
end

function SkillSpectrum_Manchinist_Heat:ValueUpdateFunc(CurValue, TargetValue)
	local TypeParams = _G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)
	local Threshold1 = TypeParams[1]
	local Threshold2 = TypeParams[2]
	--热能量谱呼吸动效
	if self.CurAnim ~= nil then
		self.View:StopAnimation(self.CurAnim)
	end
	if TargetValue < Threshold1 then
		self.View:PlayAnimation(self.View.AnimHeatLess50)
		self.CurAnim = self.View.AnimHeatLess50
	elseif TargetValue >= Threshold1 and TargetValue < Threshold2 then
		self.View:PlayAnimation(self.View.AnimHeatOver50)
		self.CurAnim = self.View.AnimHeatOver50
	elseif TargetValue >= Threshold2 then
		self.View:PlayAnimation(self.View.AnimHeatIs100Loop, 0, 0,nil, 1.0, true)
		self.CurAnim = self.View.AnimHeatIs100Loop
	end
	-- 热能值ProgressBar变化
	local CurPercent = CurValue / self.SpectrumMaxValue
	local TargetPercent = TargetValue / self.SpectrumMaxValue
	-- 这里直接使用蓝图函数
	self.View:PlayAnimProBarHeat(CurPercent, TargetPercent)
	local TextValue = math.floor(TargetValue / 100)
	self.View.TextNum:SetText(tostring(TextValue))
end

function SkillSpectrum_Manchinist_Heat:ValueUpdateEachFunc(CurValue)

end

function SkillSpectrum_Manchinist_Heat:OnCastBuff(BuffInfo)
	local ExpdTime = BuffInfo.ULongParam3
	self.ExpdTime = ExpdTime

	if self.HeatTimerID ~= 0 then
		self.View:UnRegisterTimer(self.HeatTimerID)
		self.HeatTimerID = 0
	end

	if self.CurAnim ~= nil then
		self.View:StopAnimation(self.CurAnim)
	end
	self.View:PlayAnimation(self.View.AnimHeatOverHeat)
	UIUtil.SetIsVisible(self.View.TextNum4, true)
	self.HeatTimerID = self.View:RegisterTimer(self.View.OnHeatUpdateBuffTime,0,1,0,ExpdTime)
end

function SkillSpectrum_Manchinist_Heat:OnRemoveBuff(BuffInfo)
	self.View:StopAnimation(self.View.AnimHeatOverHeat)
	if self.CurAnim ~= nil then
		if self.CurAnim == self.View.AnimHeatIs100Loop then
			self.View:PlayAnimation(self.CurAnim, 0, 0,nil, 1.0, true)
		else
			self.View:PlayAnimation(self.CurAnim)
		end
	end
	UIUtil.SetIsVisible(self.View.TextNum4, false)
	if self.HeatTimerID ~= 0 then
		self.View:UnRegisterTimer(self.HeatTimerID)
		self.HeatTimerID = 0
	end
end

--Machinist_Heat END

--Machinist_Electric START

function SkillSpectrum_Manchinist_Electric:OnInit()
	self.Super:OnInit()
	local ProfID = MajorUtil.GetMajorProfID()
	local ProfLevel = MajorUtil.GetMajorLevelByProf(ProfID)
	local LearnedLevel = SkillUtil.GetSkillLearnLevel(self.SpectrumID,ProfID)
	if ProfLevel < LearnedLevel then
		UIUtil.SetIsVisible(self.View.PanelElectricity, false)
	end
	self:SkillSpectrumOff()
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParam2(self.SpectrumID))
	self.CurAnim = nil
	self.ElectricTimerID = 0
end

function SkillSpectrum_Manchinist_Electric:SkillSpectrumOn()
	self.CurrentProgressBar = self.View.ProgressBarBlue
	UIUtil.SetIsVisible(self.View.PanelElectricity, true)
	UIUtil.SetIsVisible(self.View.ProgressBarBlue, true)
end

function SkillSpectrum_Manchinist_Electric:SkillSpectrumOff()
	if self.CurAnim ~= nil then
		self.View:StopAnimation(self.CurAnim)
		self.CurAnim = nil
	end
	self.View.ProgressBarBlue:SetPercent(0)
	if nil ~= self.CurrentProgressBar then
		self.CurrentProgressBar = nil
	end
	self.View.TextNum2:SetText(0)
	UIUtil.SetIsVisible(self.View.ProgressBarBlue, false)
	UIUtil.SetIsVisible(self.View.TextNum3, false)
end

function SkillSpectrum_Manchinist_Electric:ValueUpdateFunc(CurValue, TargetValue)
	local TypeParams = _G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)
	local Threshold1 = TypeParams[1]
	local Threshold2 = TypeParams[2]
	-- 电能量谱呼吸动效
	if self.CurAnim ~= nil then
		self.View:StopAnimation(self.CurAnim)
	end
	if TargetValue < Threshold1 then
		self.View:PlayAnimation(self.View.AnimElectricityLess50)
		self.CurAnim = self.View.AnimElectricityLess50
	elseif TargetValue >= Threshold1 and TargetValue < Threshold2 then
		self.View:PlayAnimation(self.View.AnimElectricityOver50)
		self.CurAnim = self.View.AnimElectricityOver50
	elseif TargetValue >= Threshold2 then
		self.View:PlayAnimation(self.View.AnimElectricityIs100Loop, 0, 0,nil, 1.0, true)
		self.CurAnim = self.View.AnimElectricityIs100Loop
	end
	-- 电能值ProgressBar变化
	local CurPercent = CurValue / self.SpectrumMaxValue
	local TargetPercent = TargetValue / self.SpectrumMaxValue
	-- 这里直接使用蓝图函数
	self.View:PlayAnimProBarElectricity(CurPercent, TargetPercent)
	local TextValue = math.floor(TargetValue / 100)
	self.View.TextNum2:SetText(tostring(TextValue))

end

function SkillSpectrum_Manchinist_Electric:ValueUpdateEachFunc(CurValue)

end

function SkillSpectrum_Manchinist_Electric:OnCastBuff(BuffInfo)
	local ExpdTime = BuffInfo.ULongParam3
	self.ExpdTime = ExpdTime

	if self.ElectricTimerID ~= 0 then
		self.View:UnRegisterTimer(self.ElectricTimerID)
		self.ElectricTimerID = 0
	end

	UIUtil.SetIsVisible(self.View.TextNum3, true)
	if self.CurAnim ~= nil then
		self.View:StopAnimation(self.CurAnim)
	end
	self.View:PlayAnimation(self.View.AnimElectricityOverLoadLoop, 0, 0,nil, 1.0, true)
	self.ElectricTimerID = self.View:RegisterTimer(self.View.OnElectricUpdateBuffTime,0,1,0,ExpdTime)
end


function SkillSpectrum_Manchinist_Electric:OnRemoveBuff(BuffInfo)
	UIUtil.SetIsVisible(self.View.TextNum3, false)
	self.View:StopAnimation(self.View.AnimElectricityOverLoadLoop)
	if self.CurAnim ~= nil then
		if self.CurAnim == self.View.AnimElectricityIs100Loop then
			self.View:PlayAnimation(self.CurAnim, 0, 0,nil, 1.0, true)
		else
			self.View:PlayAnimation(self.CurAnim)
		end
	end
	if self.ElectricTimerID ~= 0 then
		self.View:UnRegisterTimer(self.ElectricTimerID)
		self.ElectricTimerID = 0
	end
end

--Machinist_Electric END

return JobSkillMachinistView