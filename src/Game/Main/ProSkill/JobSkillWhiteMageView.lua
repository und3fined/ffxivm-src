---
--- Author: chaooren
--- DateTime: 2022-04-08 14:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap

---@class JobSkillWhiteMageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlueCurve UTextureCurve
---@field Img_Tree_1 UImage
---@field Img_Tree_2 UImage
---@field Img_Tree_3 UImage
---@field M_EFF_Glow_003_T1 UImage
---@field M_EFF_Glow_003_T2 UImage
---@field MainUIMoveControl_UIBP_3 MainUIMoveControlView
---@field PanelUnlock UFCanvasPanel
---@field ProgressBar_Hp UProgressBar
---@field ProgressBar_Hp_1 UProgressBar
---@field ProgressBar_Mp UProgressBar
---@field RedCurve UTextureCurve
---@field RedCurve_1 UTextureCurve
---@field TextUnlock UFTextBlock
---@field Anim_Devil_Part_1 UWidgetAnimation
---@field Anim_Devil_Part_1_Del UWidgetAnimation
---@field Anim_Devil_Part_2 UWidgetAnimation
---@field Anim_Devil_Part_2_Del UWidgetAnimation
---@field Anim_Devil_Part_3 UWidgetAnimation
---@field Anim_Devil_Part_3_Del UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillWhiteMageView = LuaClass(ProfProSkillViewBase, true)
local SkillSpectrum_WHITEMAGE_MP = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_WHITEMAGE_HP = LuaClass(ProSkillSpectrumBase, true)

function JobSkillWhiteMageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlueCurve = nil
	--self.Img_Tree_1 = nil
	--self.Img_Tree_2 = nil
	--self.Img_Tree_3 = nil
	--self.M_EFF_Glow_003_T1 = nil
	--self.M_EFF_Glow_003_T2 = nil
	--self.MainUIMoveControl_UIBP_3 = nil
	--self.PanelUnlock = nil
	--self.ProgressBar_Hp = nil
	--self.ProgressBar_Hp_1 = nil
	--self.ProgressBar_Mp = nil
	--self.RedCurve = nil
	--self.RedCurve_1 = nil
	--self.TextUnlock = nil
	--self.Anim_Devil_Part_1 = nil
	--self.Anim_Devil_Part_1_Del = nil
	--self.Anim_Devil_Part_2 = nil
	--self.Anim_Devil_Part_2_Del = nil
	--self.Anim_Devil_Part_3 = nil
	--self.Anim_Devil_Part_3_Del = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillWhiteMageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MainUIMoveControl_UIBP_3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillWhiteMageView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.WHITEMAGE_HP, SkillSpectrum_WHITEMAGE_HP)
	self:BindSpectrumBehavior(SpectrumIDMap.WHITEMAGE_MP, SkillSpectrum_WHITEMAGE_MP)
	self.TextUnlock:SetText(_G.LSTR(140082))  -- 百合花茎量谱
end

function JobSkillWhiteMageView:OnDestroy()

end

function JobSkillWhiteMageView:OnShow()
	self.Super:OnShow()
end

function JobSkillWhiteMageView:OnHide()

end

function JobSkillWhiteMageView:OnRegisterUIEvent()

end

function JobSkillWhiteMageView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

function JobSkillWhiteMageView:OnRegisterBinder()

end

function SkillSpectrum_WHITEMAGE_MP:OnInit()
	self.Super:OnInit()
	--self:SkillSpectrumOff()
end

function SkillSpectrum_WHITEMAGE_MP:SkillSpectrumOn()
	self.CurrentProgressBar = self.View.ProgressBar_Mp
	UIUtil.SetIsVisible(self.View.M_EFF_Glow_003_T1, true)
end

function SkillSpectrum_WHITEMAGE_MP:SkillSpectrumOff()
	self.View.ProgressBar_Mp:SetPercent(0)
	if self.View.Img_Tree_2.RenderOpacity == 1 then
		self.View:PlayAnimationToEndTime(self.View.Anim_Devil_Part_1_Del)
	end
	if self.View.Img_Tree_1.RenderOpacity == 1 then
		self.View:PlayAnimationToEndTime(self.View.Anim_Devil_Part_2_Del)
	end
	--self.View.Mask1:SetMaskTransformPivot(_G.UE.FVector2D(0.5, 1))
	self.View.M_EFF_Glow_003_T1.Slot:SetPosition(_G.UE.FVector2D(self.View.BlueCurve:Eval(self.View.BlueCurve.CurveSizeY, 0), self.View.BlueCurve.CurveSizeY))
	UIUtil.SetIsVisible(self.View.M_EFF_Glow_003_T1, false)
end

function SkillSpectrum_WHITEMAGE_MP:ValueUpdateFunc(CurValue, TargetValue)
	local TypeParams = _G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)
	local Threshold1 = TypeParams[1]
	local Threshold2 = TypeParams[2]
	if CurValue < Threshold1 and TargetValue >= Threshold1 then
		self.View:PlayAnimation(self.View.Anim_Devil_Part_1)
	end
	if CurValue < Threshold2 and TargetValue >= Threshold2 then
		self.View:PlayAnimation(self.View.Anim_Devil_Part_2)
	end

	if CurValue >= Threshold2 and TargetValue < Threshold2 then
		self.View:PlayAnimationToEndTime(self.View.Anim_Devil_Part_2_Del)
	end
	if CurValue >= Threshold1 and TargetValue < Threshold1 then
		self.View:PlayAnimationToEndTime(self.View.Anim_Devil_Part_1_Del)
	end
end

function SkillSpectrum_WHITEMAGE_MP:ValueUpdateEachFunc(CurValue)
	local Value = CurValue / self.SpectrumMaxValue
	--self.View.Mask1:SetMaskTransformPivot(_G.UE.FVector2D(0.5, 1- Value / 2))
	local CurveSize = self.View.BlueCurve.CurveSizeY
	local PositionY = CurveSize - Value * CurveSize
	local PositionX = self.View.BlueCurve:Eval(PositionY, 0)
	self.View.M_EFF_Glow_003_T1.Slot:SetPosition(_G.UE.FVector2D(PositionX, PositionY))

	local CurProgressBar = self.CurrentProgressBar
	CurProgressBar:SetPercent(Value)
end
--WHITEMAGE_MP END

--WHITEMAGE_HP START
local Redthreshold = 0.6	--红色量谱被分为两段，Value[0,1]小于该值应用第一段，大于该值应用第二段
function SkillSpectrum_WHITEMAGE_HP:OnInit()
	self.Super:OnInit()
	--self:SkillSpectrumOff()
end

function SkillSpectrum_WHITEMAGE_HP:SkillSpectrumOn()
	UIUtil.SetIsVisible(self.View.M_EFF_Glow_003_T2, true)
end

function SkillSpectrum_WHITEMAGE_HP:SkillSpectrumOff()
	self.View.ProgressBar_Hp:SetPercent(0)
	self.View.ProgressBar_Hp_1:SetPercent(0)
	if self.View.Img_Tree_3.RenderOpacity == 1 then
		self.View:PlayAnimationToEndTime(self.View.Anim_Devil_Part_3_Del)
	end
	--self.View.Mask2:SetMaskTransformPivot(_G.UE.FVector2D(0.5, 1))
	self.View.M_EFF_Glow_003_T2.Slot:SetPosition(_G.UE.FVector2D(self.View.RedCurve_1:Eval(0, 0), 0) + self.View.RedCurve_1.Slot:GetPosition())
	UIUtil.SetIsVisible(self.View.M_EFF_Glow_003_T2, false)
end

function SkillSpectrum_WHITEMAGE_HP:ValueUpdateFunc(CurValue, TargetValue)
	local TypeParams = _G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)
	local Threshold1 = TypeParams[1]
	if CurValue < Threshold1 and TargetValue >= Threshold1 then
		self.View:PlayAnimation(self.View.Anim_Devil_Part_3)
	elseif CurValue >= Threshold1 and TargetValue < Threshold1 then
		self.View:PlayAnimationToEndTime(self.View.Anim_Devil_Part_3_Del)
	end
end

function SkillSpectrum_WHITEMAGE_HP:ValueUpdateEachFunc(CurValue)
	local Value = CurValue / self.SpectrumMaxValue
	--self.View.Mask2:SetMaskTransformPivot(_G.UE.FVector2D(0.5, 1 - Value / 2))

	if Value <= Redthreshold then
		local MapValue = Value / Redthreshold
		self.View.ProgressBar_Hp:SetPercent(MapValue)
		if self.View.ProgressBar_Hp_1.Percent ~= 0 then
			self.View.ProgressBar_Hp_1:SetPercent(0)
		end
		local CurveSize = self.View.RedCurve_1.CurveSizeY
		local PositionY = MapValue * CurveSize
		local PositionX = self.View.RedCurve_1:Eval(PositionY, 0)
		self.View.M_EFF_Glow_003_T2.Slot:SetPosition(_G.UE.FVector2D(PositionX, PositionY) + self.View.RedCurve_1.Slot:GetPosition())
	else
		local MapValue = (Value - Redthreshold) / (1 - Redthreshold)
		self.View.ProgressBar_Hp_1:SetPercent(MapValue)
		if self.View.ProgressBar_Hp.Percent ~= 1 then
			self.View.ProgressBar_Hp:SetPercent(1)
		end
		local CurveSize = self.View.RedCurve.CurveSizeY
		local PositionY = CurveSize - MapValue * CurveSize
		local PositionX = self.View.RedCurve:Eval(PositionY, 0)
		self.View.M_EFF_Glow_003_T2.Slot:SetPosition(_G.UE.FVector2D(PositionX, PositionY))
	end
end


return JobSkillWhiteMageView