---
--- Author: henghaoli
--- DateTime: 2022-08-19 17:05
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap
local HUDMgr = _G.HUDMgr

---@class JobSkillMonkView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EmptyEnergy UFCanvasPanel
---@field Energy UFCanvasPanel
---@field FImg_EmptyEnergy_1 UFImage
---@field FImg_EmptyEnergy_2 UFImage
---@field FImg_EmptyEnergy_3 UFImage
---@field FImg_EmptyEnergy_4 UFImage
---@field FImg_EmptyEnergy_5 UFImage
---@field FImg_Energy_1 UFImage
---@field FImg_Energy_2 UFImage
---@field FImg_Energy_3 UFImage
---@field FImg_Energy_4 UFImage
---@field FImg_Energy_5 UFImage
---@field Monk UFCanvasPanel
---@field AnimFullLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRelease UWidgetAnimation
---@field AnimShow1 UWidgetAnimation
---@field AnimShow2 UWidgetAnimation
---@field AnimShow3 UWidgetAnimation
---@field AnimShow4 UWidgetAnimation
---@field AnimShow5 UWidgetAnimation
---@field MonkFistFullColor Color
---@field MonkFistProgressColor Color
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillMonkView = LuaClass(ProfProSkillViewBase, true)

local SkillSpectrum_Monk_Base = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_Monk_Chakra = LuaClass(SkillSpectrum_Monk_Base, true)
local SkillSpectrum_Monk_Fist = LuaClass(SkillSpectrum_Monk_Base, true)

function JobSkillMonkView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EmptyEnergy = nil
	--self.Energy = nil
	--self.FImg_EmptyEnergy_1 = nil
	--self.FImg_EmptyEnergy_2 = nil
	--self.FImg_EmptyEnergy_3 = nil
	--self.FImg_EmptyEnergy_4 = nil
	--self.FImg_EmptyEnergy_5 = nil
	--self.FImg_Energy_1 = nil
	--self.FImg_Energy_2 = nil
	--self.FImg_Energy_3 = nil
	--self.FImg_Energy_4 = nil
	--self.FImg_Energy_5 = nil
	--self.Monk = nil
	--self.AnimFullLoop = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimRelease = nil
	--self.AnimShow1 = nil
	--self.AnimShow2 = nil
	--self.AnimShow3 = nil
	--self.AnimShow4 = nil
	--self.AnimShow5 = nil
	--self.MonkFistFullColor = nil
	--self.MonkFistProgressColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillMonkView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillMonkView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.MONK_CHAKRA, SkillSpectrum_Monk_Chakra)
	self:BindSpectrumBehavior(SpectrumIDMap.MONK_FIST, SkillSpectrum_Monk_Fist)
	self.TextUnlock:SetText(_G.LSTR(140077))  -- 斗气量谱
end

function JobSkillMonkView:OnDestroy()
	self.Super:OnDestroy()
end

function JobSkillMonkView:OnShow()
	self.Super:OnShow()
end

function JobSkillMonkView:OnHide()
	self.Super:OnHide()
end

function JobSkillMonkView:OnRegisterUIEvent()

end

function JobSkillMonkView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
end

function JobSkillMonkView:OnRegisterBinder()

end

function JobSkillMonkView:OnUpdateBuff(Params)
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

function JobSkillMonkView:OnRemoveBuff(Params)
	local BuffID = Params.IntParam1
	local EntityID = Params.ULongParam1

	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end

	for _, value in pairs(self.SpectrumPair) do
		if value and value.Begin and value.BuffID == BuffID then
			value:OnRemoveBuff(Params)
		end
	end
end

local function GetBuffInfo(InBuffID)
	return _G.SkillBuffMgr:GetBuffInfo(InBuffID)
end


function SkillSpectrum_Monk_Base:OnInit()
	self.Super:OnInit()
	self.bEnableUpdate = false
	self.bEnableAdvanceUpdate = false

	self.CurPile = 0
end

function SkillSpectrum_Monk_Base:OnPileChanged(NewPile, LastPile)
end

function SkillSpectrum_Monk_Base:SkillSpectrumOn()
	local BuffInfo = GetBuffInfo(self.BuffID)

	if BuffInfo then
		self:OnPileChanged(BuffInfo.Pile)
	end
end

function SkillSpectrum_Monk_Base:SkillSpectrumOff()
	self:OnPileChanged(0)
end

function SkillSpectrum_Monk_Base:OnCastBuff(BuffInfo)
	local Pile = BuffInfo.IntParam2
	self:OnPileChanged(Pile)
end

function SkillSpectrum_Monk_Base:OnRemoveBuff(BuffInfo)
	self:OnPileChanged(0)
end

function SkillSpectrum_Monk_Base:OnHide()
	self.Super:OnHide()
end


function SkillSpectrum_Monk_Chakra:OnInit()
	self.Super:OnInit()
	self.BuffID = 1100  -- 武僧量谱cfg里面没有BuffID, 直接写这里了
	self.MaxPile = 5
end

function SkillSpectrum_Monk_Chakra:OnPileChanged(NewPile, _)
	local LastPile = self.CurPile
	self.CurPile = NewPile
	local View = self.View

	if NewPile > LastPile then
		local AnimRelease = View.AnimRelease
		if View:IsAnimationPlaying(AnimRelease) then
			View:StopAnimation(AnimRelease)
			local Duration = AnimRelease:GetEndTime()
			View:PlayAnimationTimeRange(AnimRelease, Duration, Duration, 1, nil, 1.0, false)
		end

		for i = LastPile + 1, NewPile do
			local Anim = View[string.format("AnimShow%d", i)]
			if Anim then
				View:PlayAnimation(Anim)
			end
		end

		if NewPile == self.MaxPile then
			View:PlayAnimation(View.AnimFullLoop, 0, 0)
		end

		return
	end

	if NewPile < self.MaxPile then
		View:StopAnimation(View.AnimFullLoop)
		if NewPile == 0 then
			View:PlayAnimationToEndTime(View.AnimRelease)
		end
	end

	for i = NewPile + 1, LastPile do
		local HideWidget = View[string.format("FImg_Energy_%d", i)]
		if HideWidget then
			HideWidget:SetRenderOpacity(0)
		end
	end
end

function SkillSpectrum_Monk_Chakra:SkillSpectrumOff()
	self.Super:SkillSpectrumOff()
end

function SkillSpectrum_Monk_Chakra:OnSpectrumStudy()
	UIUtil.SetIsVisible(self.View.Monk, true)
end

function SkillSpectrum_Monk_Chakra:OnSpectrumDeStudy()
	UIUtil.SetIsVisible(self.View.Monk, false)
end

local FVector2D = _G.UE.FVector2D
local FMargin = _G.UE.FMargin
local TextureAspectRatio = 112 / 20
local TextureLength = 160
local TextureSize = FVector2D(TextureLength, TextureLength / TextureAspectRatio)
local Padding = FMargin()
Padding.Top = -4
Padding.Left = -5

local MonkFistTextureMap = {
	[0] = "PaperSprite'/Game/UI/Atlas/JobSkill/Monk/Frames/UI_JobSkill_Monk_HUD_Img_Bg_png.UI_JobSkill_Monk_HUD_Img_Bg_png'",
	[1] = "PaperSprite'/Game/UI/Atlas/JobSkill/Monk/Frames/UI_JobSkill_Monk_HUD_Img_Probar1_png.UI_JobSkill_Monk_HUD_Img_Probar1_png'",
	[2] = "PaperSprite'/Game/UI/Atlas/JobSkill/Monk/Frames/UI_JobSkill_Monk_HUD_Img_Probar2_png.UI_JobSkill_Monk_HUD_Img_Probar2_png'",
	[3] = "PaperSprite'/Game/UI/Atlas/JobSkill/Monk/Frames/UI_JobSkill_Monk_HUD_Img_Probar3_png.UI_JobSkill_Monk_HUD_Img_Probar3_png'",
	[4] = "PaperSprite'/Game/UI/Atlas/JobSkill/Monk/Frames/UI_JobSkill_Monk_HUD_Img_Full_png.UI_JobSkill_Monk_HUD_Img_Full_png'",
}
local DefaultTexturePath = MonkFistTextureMap[0]

function SkillSpectrum_Monk_Fist:OnInit()
	self.Super:OnInit()
	self.BuffID = 1101
	self.MaxPile = 4

	self.MonkFistFullColor = "FC554CFF"
	self.MonkFistProgressColor = "EDBB6CFF"
	if self.View.MonkFistFullColor and self.View.MonkFistProgressColor then
		self.MonkFistFullColor = self.View.MonkFistFullColor:ToHex()
		self.MonkFistProgressColor = self.View.MonkFistProgressColor:ToHex()
	end

	local EntityID = MajorUtil.GetMajorEntityID()
	HUDMgr:SetSpectrumParams(EntityID, 1, nil, nil, DefaultTexturePath, DefaultTexturePath, TextureSize, Padding)
end

function SkillSpectrum_Monk_Fist:OnCastBuff(BuffInfo)
	self.Super:OnCastBuff(BuffInfo)

	HUDMgr:SetHPBarVisible(BuffInfo.ULongParam1, true)
end

function SkillSpectrum_Monk_Fist:OnRemoveBuff(BuffInfo)
	self.Super:OnRemoveBuff(BuffInfo)
end

function SkillSpectrum_Monk_Fist:OnPileChanged(NewPile)
	self.CurPile = NewPile

	local EntityID = MajorUtil.GetMajorEntityID()

	if EntityID == nil or EntityID == 0 then
		return
	end

	local TexturePath = MonkFistTextureMap[NewPile]

	HUDMgr:SetSpectrumParams(EntityID, 1, nil, nil, TexturePath, TexturePath)
end

function SkillSpectrum_Monk_Fist:OnSpectrumStudy()
	local EntityID = MajorUtil.GetMajorEntityID()
	local TexturePath = DefaultTexturePath
	if self.CurPile > 0 then
		TexturePath = MonkFistTextureMap[self.CurPile]
	end
	HUDMgr:SetSpectrumParams(EntityID, 0, true, nil, TexturePath, TexturePath, TextureSize, Padding)
end

function SkillSpectrum_Monk_Fist:OnSpectrumDeStudy()
	local EntityID = MajorUtil.GetMajorEntityID()
	HUDMgr:SetSpectrumParams(EntityID, nil, false, nil)
end

return JobSkillMonkView