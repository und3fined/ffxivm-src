---
--- Author: chaooren
--- DateTime: 2022-12-21 11:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap
local HUDMgr = _G.HUDMgr

local NinjaSkillPosition = {
	[1] = {_G.UE.FVector2D(133, 68)},
	[2] = {_G.UE.FVector2D(-5, 68), _G.UE.FVector2D(-138, 68)},
	[3] = {_G.UE.FVector2D(-68, -4), _G.UE.FVector2D(-4, -140), _G.UE.FVector2D(-137, -140)},
}

local NinjaSkillAnchors = {
	[1] = {_G.UE.FVector2D(0, 0)},
	[2] = {_G.UE.FVector2D(0, 0), _G.UE.FVector2D(1, 0)},
	[3] = {_G.UE.FVector2D(0.5, 0), _G.UE.FVector2D(0, 1), _G.UE.FVector2D(1, 1)},
}

local NinjaSkillRotation = {
	[1] = {0},
	[2] = {0, 0},
	[3] = {0, -120, 120}
}

-- 技能ID和结印的映射
local SkillIDSealMap = {
	[11017] = 1,
	[11018] = 2,
	[11019] = 3,
	[11020] = 4,
	[11021] = 5,
	[11022] = 6,
	[11023] = 7,
	[11024] = 8,
}

---@class JobSkillNinjaView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CirclePendantSwitcher UFWidgetSwitcher
---@field EFF UFCanvasPanel
---@field JobSkillNinja1 JobSkillNinjaItemView
---@field JobSkillNinja2 JobSkillNinjaItemView
---@field JobSkillNinja3 JobSkillNinjaItemView
---@field PanelUnlock UFCanvasPanel
---@field TextUnlock UFTextBlock
---@field AnimEnergy0 UWidgetAnimation
---@field AnimEnergy1 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSkill1 UWidgetAnimation
---@field AnimSkill2 UWidgetAnimation
---@field AnimSkill3 UWidgetAnimation
---@field AnimSkill4 UWidgetAnimation
---@field AnimSkill5 UWidgetAnimation
---@field AnimSkill6 UWidgetAnimation
---@field AnimSkill7 UWidgetAnimation
---@field AnimSkill8 UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillNinjaView = LuaClass(ProfProSkillViewBase, true)

local SkillSpectrum_Ninja_SkillBase = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_Ninja_One = LuaClass(SkillSpectrum_Ninja_SkillBase, true)
local SkillSpectrum_Ninja_Two = LuaClass(SkillSpectrum_Ninja_SkillBase, true)
local SkillSpectrum_Ninja_Three = LuaClass(SkillSpectrum_Ninja_SkillBase, true)
local SkillSpectrum_Ninja_HUD = LuaClass(ProSkillSpectrumBase, true)

function JobSkillNinjaView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CirclePendantSwitcher = nil
	--self.EFF = nil
	--self.JobSkillNinja1 = nil
	--self.JobSkillNinja2 = nil
	--self.JobSkillNinja3 = nil
	--self.PanelUnlock = nil
	--self.TextUnlock = nil
	--self.AnimEnergy0 = nil
	--self.AnimEnergy1 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimSkill1 = nil
	--self.AnimSkill2 = nil
	--self.AnimSkill3 = nil
	--self.AnimSkill4 = nil
	--self.AnimSkill5 = nil
	--self.AnimSkill6 = nil
	--self.AnimSkill7 = nil
	--self.AnimSkill8 = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillNinjaView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.JobSkillNinja1)
	self:AddSubView(self.JobSkillNinja2)
	self:AddSubView(self.JobSkillNinja3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillNinjaView:OnInit()
	self.Super:OnInit()
	self.Count = 0
	self:BindSpectrumBehavior(SpectrumIDMap.Ninja_1, SkillSpectrum_Ninja_One)
	self:BindSpectrumBehavior(SpectrumIDMap.Ninja_2, SkillSpectrum_Ninja_Two)
	self:BindSpectrumBehavior(SpectrumIDMap.Ninja_3, SkillSpectrum_Ninja_Three)
	self:BindSpectrumBehavior(SpectrumIDMap.Ninja_HUD, SkillSpectrum_Ninja_HUD)

	self.JobSkillNinja1:InitHutonType("Day")
	self.JobSkillNinja2:InitHutonType("Land")
	self.JobSkillNinja3:InitHutonType("People")

	self.TextUnlock:SetText(_G.LSTR(140078))  -- 忍术量谱
end

function JobSkillNinjaView:OnDestroy()

end

function JobSkillNinjaView:OnShow()
	self.Super:OnShow()
end

function JobSkillNinjaView:OnHide()

end

function JobSkillNinjaView:OnRegisterUIEvent()

end

function JobSkillNinjaView:OnRegisterGameEvent()
    self.Super:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
end

function JobSkillNinjaView:OnRegisterBinder()

end

function JobSkillNinjaView:OnMajorUseSkill(Params)
	local SkillID = Params.IntParam1 or 0
	local SealIndex = SkillIDSealMap[SkillID]
	if not SealIndex then
		return
	end

	self:PlayAnimation(self["AnimSkill" .. tostring(SealIndex)])
end

function JobSkillNinjaView:SetEnergyState(bHasEnergy)
	if self.bHasEnergy == bHasEnergy then
		return
	end

	if bHasEnergy then
		self:PlayAnimation(self.AnimEnergy1)
	else
		self:PlayAnimation(self.AnimEnergy0)
	end
	self.bHasEnergy = bHasEnergy
end

function JobSkillNinjaView:SwitchSkillCount(Count)
	if self.Count == Count then
		return
	end

	for i = 1, 3 do
		local Widget = self[string.format("JobSkillNinja%d", i)]
		if i <= Count then
			local Anchor = _G.UE.FAnchors()
			Anchor.Minimum = NinjaSkillAnchors[Count][i]
			Anchor.Maximum = NinjaSkillAnchors[Count][i]
			UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
			UIUtil.CanvasSlotSetPosition(Widget, NinjaSkillPosition[Count][i])
			Widget.ImgCircle:SetRenderTransformAngle(NinjaSkillRotation[Count][i])
			UIUtil.SetIsVisible(Widget.FCanvasPanel, true)
		else
			UIUtil.SetIsVisible(Widget.FCanvasPanel, false)
		end
	end
	self.CirclePendantSwitcher:SetActiveWidgetIndex(math.max(Count - 1, 0))
end

function SkillSpectrum_Ninja_SkillBase:OnSpectrumStudy()
	self.View:SwitchSkillCount(self.SkillCount)
end

function SkillSpectrum_Ninja_SkillBase:OnSpectrumDeStudy()
	self.View:SwitchSkillCount(0)
end

function SkillSpectrum_Ninja_One:OnInit()
	self.Super:OnInit()
	self.SkillCount = 1
end

function SkillSpectrum_Ninja_Two:OnInit()
	self.Super:OnInit()
	self.SkillCount = 2
end

function SkillSpectrum_Ninja_Three:OnInit()
	self.Super:OnInit()
	self.SkillCount = 3
end

local HalfVal = 0.5
local FullVal = 1.0
local FVector2D = _G.UE.FVector2D
local FMargin = _G.UE.FMargin
local BgTexture = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_HUD_Img_Bg_png.UI_Ninja_HUD_Img_Bg_png'"
local HalfTexture = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_HUD_Img_Half_png.UI_Ninja_HUD_Img_Half_png'"
local MoreHalfTexture = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_HUD_Img_MoreHalf_png.UI_Ninja_HUD_Img_MoreHalf_png'"
local FullTexture = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_HUD_Img_Full_png.UI_Ninja_HUD_Img_Full_png'"
local TextureSize = FVector2D(142, 33.4)
local Padding = FMargin()
Padding.Top = -8

local function InitHUDParams()
	local EntityID = MajorUtil.GetMajorEntityID()
	HUDMgr:SetSpectrumParams(EntityID, nil, nil, "FFFFFFFF", HalfTexture, BgTexture, TextureSize, Padding)
end

function SkillSpectrum_Ninja_HUD:OnInit()
	self.Super:OnInit()
	InitHUDParams()
end

function SkillSpectrum_Ninja_HUD:SkillSpectrumOn()
	local EntityID = MajorUtil.GetMajorEntityID()
	HUDMgr:SetSpectrumParams(EntityID, 0, true)
end

-- 实际进度条占据的空间为84%, 即起始进度为8%, 因此需要将进度进行映射
local ValidPercent = 0.84
local InitPercent = (1 - ValidPercent) / 2

function SkillSpectrum_Ninja_HUD:ValueUpdateFunc(CurValue, TargetValue)
	local BasicAmount = TargetValue / self.SpectrumMaxValue
	local FixedAmount = InitPercent + BasicAmount * ValidPercent
	local EntityID = MajorUtil.GetMajorEntityID()
	local Texture
	if BasicAmount < HalfVal then
		Texture = HalfTexture
	elseif BasicAmount < FullVal then
		Texture = MoreHalfTexture
	else
		Texture = FullTexture
	end

	HUDMgr:SetSpectrumParams(EntityID, FixedAmount, nil, nil, Texture)
end

function SkillSpectrum_Ninja_HUD:SkillSpectrumOff()
	local EntityID = MajorUtil.GetMajorEntityID()
	HUDMgr:SetSpectrumParams(EntityID, 0, false)
end

function SkillSpectrum_Ninja_HUD:OnSpectrumStudy()
	InitHUDParams()
end

return JobSkillNinjaView