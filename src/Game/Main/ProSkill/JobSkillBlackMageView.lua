---
--- Author: chaooren
--- DateTime: 2022-02-16 15:38
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap

---@class JobSkillBlackMageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Gem01 UFImage
---@field FImg_Gem02 UFImage
---@field FImg_GemON01 UFImage
---@field FImg_GemON02 UFImage
---@field FImg_gem_frameOFF01_1 UFImage
---@field FImg_gem_frameOFF02_1 UFImage
---@field ImgProgressBar URadialImage
---@field PanelSwitcher1 UWidgetSwitcher
---@field PanelSwitcher2 UWidgetSwitcher
---@field PanelUnlock UFCanvasPanel
---@field Pointer UFCanvasPanel
---@field TextUnlock UFTextBlock
---@field Text_Time UTextBlock
---@field Time UFCanvasPanel
---@field AnimBlueIn1 UWidgetAnimation
---@field AnimBlueIn2 UWidgetAnimation
---@field AnimBlueIn3 UWidgetAnimation
---@field AnimGlowBall UWidgetAnimation
---@field AnimGlowDownLoop1 UWidgetAnimation
---@field AnimGlowDownLoop2 UWidgetAnimation
---@field AnimGlowTopLoop1 UWidgetAnimation
---@field AnimGlowTopLoop2 UWidgetAnimation
---@field AnimGlowTopLoop3 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMoon UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPointIn UWidgetAnimation
---@field AnimPurpleIn1 UWidgetAnimation
---@field AnimPurpleIn2 UWidgetAnimation
---@field AnimPurpleOut1 UWidgetAnimation
---@field AnimPurpleOut2 UWidgetAnimation
---@field AnimRedIn1 UWidgetAnimation
---@field AnimRedIn2 UWidgetAnimation
---@field AnimRedIn3 UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillBlackMageView = LuaClass(ProfProSkillViewBase, true)

local SkillSpectrum_BlackMage_Slot = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_BlackMage_Slot_Advance = LuaClass(SkillSpectrum_BlackMage_Slot, true)
local SkillSpectrum_BlackMage_ElemBase = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_BlackMage_Fire = LuaClass(SkillSpectrum_BlackMage_ElemBase, true)
local SkillSpectrum_BlackMage_Ice = LuaClass(SkillSpectrum_BlackMage_ElemBase, true)

function JobSkillBlackMageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Gem01 = nil
	--self.FImg_Gem02 = nil
	--self.FImg_GemON01 = nil
	--self.FImg_GemON02 = nil
	--self.FImg_gem_frameOFF01_1 = nil
	--self.FImg_gem_frameOFF02_1 = nil
	--self.ImgProgressBar = nil
	--self.PanelSwitcher1 = nil
	--self.PanelSwitcher2 = nil
	--self.PanelUnlock = nil
	--self.Pointer = nil
	--self.TextUnlock = nil
	--self.Text_Time = nil
	--self.Time = nil
	--self.AnimBlueIn1 = nil
	--self.AnimBlueIn2 = nil
	--self.AnimBlueIn3 = nil
	--self.AnimGlowBall = nil
	--self.AnimGlowDownLoop1 = nil
	--self.AnimGlowDownLoop2 = nil
	--self.AnimGlowTopLoop1 = nil
	--self.AnimGlowTopLoop2 = nil
	--self.AnimGlowTopLoop3 = nil
	--self.AnimIn = nil
	--self.AnimMoon = nil
	--self.AnimOut = nil
	--self.AnimPointIn = nil
	--self.AnimPurpleIn1 = nil
	--self.AnimPurpleIn2 = nil
	--self.AnimPurpleOut1 = nil
	--self.AnimPurpleOut2 = nil
	--self.AnimRedIn1 = nil
	--self.AnimRedIn2 = nil
	--self.AnimRedIn3 = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillBlackMageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillBlackMageView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.BLACKMAGE_SLOT, SkillSpectrum_BlackMage_Slot)
	self:BindSpectrumBehavior(SpectrumIDMap.BLACKMAGE_FIRE, SkillSpectrum_BlackMage_Fire)
	self:BindSpectrumBehavior(SpectrumIDMap.BLACKMAGE_ICE, SkillSpectrum_BlackMage_Ice)
	self:BindSpectrumBehavior(SpectrumIDMap.BLACKMAGE_SLOT_ADVANCE, SkillSpectrum_BlackMage_Slot_Advance)
	self.TextUnlock:SetText(_G.LSTR(140076))  -- 天语与元素量谱
end

function JobSkillBlackMageView:OnDestroy()
	self.Super:OnDestroy()
end

function JobSkillBlackMageView:OnShow()
	self.Super:OnShow()
end

function JobSkillBlackMageView:OnHide()
	self.Super:OnHide()
end

function JobSkillBlackMageView:OnRegisterUIEvent()

end

function JobSkillBlackMageView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
end

function JobSkillBlackMageView:OnRegisterBinder()

end

function JobSkillBlackMageView:OnUpdateBuff(Params)
	local BuffID = Params.IntParam1
	local EntityID = Params.ULongParam1
	--只受自身buff影响
	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end
	for _, value in pairs(self.SpectrumPair) do
		if value and value.Begin and value.BuffID == BuffID then
			value:OnCastBuff(Params)
		end
	end
end

function JobSkillBlackMageView:SetPanelSwitcher1Off()
	local bFireBegin = self.SpectrumPair[SpectrumIDMap.BLACKMAGE_FIRE] and self.SpectrumPair[SpectrumIDMap.BLACKMAGE_FIRE].Begin or false
	local bIceBegin = self.SpectrumPair[SpectrumIDMap.BLACKMAGE_ICE] and self.SpectrumPair[SpectrumIDMap.BLACKMAGE_ICE].Begin or false
	if bFireBegin == false and bIceBegin == false then
		self.PanelSwitcher1:SetActiveWidgetIndex(0)
	end
end

local function GetBuffInfo(InBuffID)
	return _G.SkillBuffMgr:GetBuffInfo(InBuffID)
end

function JobSkillBlackMageView:StopAllAnimGlow(bCheck)
	local bFireBegin = self.SpectrumPair[SpectrumIDMap.BLACKMAGE_FIRE] and self.SpectrumPair[SpectrumIDMap.BLACKMAGE_FIRE].Begin or false
	local bIceBegin = self.SpectrumPair[SpectrumIDMap.BLACKMAGE_ICE] and self.SpectrumPair[SpectrumIDMap.BLACKMAGE_ICE].Begin or false
	if not bCheck or (bFireBegin == false and bIceBegin == false) then
		self:StopAnimation(self.AnimGlowTopLoop1)
		self:StopAnimation(self.AnimGlowTopLoop2)
		self:StopAnimation(self.AnimGlowTopLoop3)
	end
end

--用来解决停止动画A、播放A、停止A的bug
function JobSkillBlackMageView:StopAllAnimGlowWithout(Anim)
	if self.AnimGlowTopLoop1 ~= Anim then
		self:StopAnimation(self.AnimGlowTopLoop1)
	end
	if self.AnimGlowTopLoop2 ~= Anim then
		self:StopAnimation(self.AnimGlowTopLoop2)
	end
	if self.AnimGlowTopLoop3 ~= Anim then
		self:StopAnimation(self.AnimGlowTopLoop3)
	end
end

function JobSkillBlackMageView:StopAnimGlowBall()
	if self.SpectrumPair == nil then
		return
	end
	local bFireBegin = self.SpectrumPair[SpectrumIDMap.BLACKMAGE_FIRE] and self.SpectrumPair[SpectrumIDMap.BLACKMAGE_FIRE].Begin or false
	local bIceBegin = self.SpectrumPair[SpectrumIDMap.BLACKMAGE_ICE] and self.SpectrumPair[SpectrumIDMap.BLACKMAGE_ICE].Begin or false
	if bFireBegin == false and bIceBegin == false then
		self:StopAnimation(self.AnimGlowBall)
	end
end

local function BuffCountDown(Widget)
	if Widget ~= nil then
		local Time = tonumber(Widget:GetText())
		if Time > 0 then
			Time = Time - 1
			Widget:SetText(tostring(Time))
		elseif UIUtil.IsVisible(Widget) then
			UIUtil.SetIsVisible(Widget, false)
		end
	end
end

function SkillSpectrum_BlackMage_ElemBase:OnInit()
	self.Super:OnInit()
	self.View.PanelSwitcher1:SetActiveWidgetIndex(0)
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)) or 0
	self.BuffTimer = 0
	--暂时没有Update的需求，给关掉
	self.bEnableUpdate = false
	self.bEnableAdvanceUpdate = false
end

function SkillSpectrum_BlackMage_ElemBase:SkillSpectrumOn()
	self.View.PanelSwitcher1:SetActiveWidgetIndex(1)
	self.View:PlayAnimation(self.View.AnimMoon)
	if self.View:IsAnimationPlaying(self.View.AnimGlowBall) == false then
		self.View:PlayAnimation(self.View.AnimGlowBall, 0, 0)
	end
	local BuffInfo = GetBuffInfo(self.BuffID)
	if BuffInfo then
		local ExpdTime = BuffInfo.ExpdTime
		local Pile = BuffInfo.Pile
		self:ShowBuffEffect(Pile, (ExpdTime - TimeUtil.GetServerTimeMS()) / 1000)
	end
end

function SkillSpectrum_BlackMage_ElemBase:SkillSpectrumOff()
	self.View:StopAnimGlowBall()
	self.View:StopAllAnimGlow(true)
	self.View:SetPanelSwitcher1Off()
	self:ReleaseLoopTimer(self.BuffTimer)
	self.BuffTimer = 0
end

function SkillSpectrum_BlackMage_ElemBase:OnCastBuff(BuffInfo)
	local TargetTime = BuffInfo.ULongParam3
	local Pile = BuffInfo.IntParam2
	self:ShowBuffEffect(Pile, (TargetTime - TimeUtil.GetServerTimeMS()) / 1000)
end

function SkillSpectrum_BlackMage_ElemBase:ShowBuffEffect(Pile, Time)
	self:ReleaseLoopTimer(self.BuffTimer)
	self.BuffTimer = 0
	if Pile > 0 then
		if Pile > 3 then Pile = 3 end
		local AnimName = string.format("%s%d", self.AnimNameBase, Pile)
		self.View:PlayAnimation(self.View[AnimName])
		local GlowTopLoopAnim = self.View[string.format("AnimGlowTopLoop%d", Pile)]
		self.View:StopAllAnimGlowWithout(GlowTopLoopAnim)
		self.View:PlayAnimation(GlowTopLoopAnim, 0, 0)
	end
	if Time > 0 then
		UIUtil.SetIsVisible(self.View.Time, true)
		UIUtil.SetIsVisible(self.View.Text_Time, true)
		local FloorTime = math.floor(Time)
		self.View.Text_Time:SetText(tostring(FloorTime))
		self.BuffTimer = self:CreateLoopTimer(nil, BuffCountDown, Time - FloorTime + 1, 1, self.View.Text_Time)
	else
		UIUtil.SetIsVisible(self.View.Time, false)
	end
end

function SkillSpectrum_BlackMage_Fire:OnInit()
	self.Super:OnInit()
	self.AnimNameBase = "AnimRedIn"
	--bug=135996663 【主干】【职业】咒术师-升级刷新量谱状态时对应量谱特效没有重置
	--拥有星极冰Buff时，升到3级时BlackMage_ElemBase初始化重置了量谱表现
	if self.View.SpectrumPair then
		local IceSpectrumPair = self.View.SpectrumPair[SpectrumIDMap.BLACKMAGE_ICE]
		local IceBuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(SpectrumIDMap.BLACKMAGE_ICE)) or 0
		local IceBuffInfo = GetBuffInfo(IceBuffID)
		--恢复重置的量谱表现
		if IceBuffInfo and IceSpectrumPair then
			self.View.PanelSwitcher1:SetActiveWidgetIndex(1)
			if self.View:IsAnimationPlaying(self.View.AnimGlowBall) == false then
				self.View:PlayAnimation(self.View.AnimGlowBall, 0, 0)
			end
			local ExpdTime = IceBuffInfo.ExpdTime
			local Pile = IceBuffInfo.Pile
			IceSpectrumPair:ShowBuffEffect(Pile, (ExpdTime - TimeUtil.GetServerTimeMS()) / 1000)
		end
	end
end

function SkillSpectrum_BlackMage_Ice:OnInit()
	self.Super:OnInit()
	self.AnimNameBase = "AnimBlueIn"
end

local MaskBoxEffectMin = 0
local MaskBoxEffectMax = 0.25
local MaxSlotValue = 10000
function SkillSpectrum_BlackMage_Slot:OnInit()
	self.Super:OnInit()
	self.View.PanelSwitcher2:SetActiveWidgetIndex(0)
	self.SlotCount = 0
end

function SkillSpectrum_BlackMage_Slot:SkillSpectrumOn()
	self.View.PanelSwitcher2:SetActiveWidgetIndex(1)
	self.View.FImg_Gem01:SetRenderOpacity(0)
	self.View.FImg_Gem02:SetRenderOpacity(0)
	self.ActiveCount = 0
	self.View.ImgProgressBar:SetPercent(MaskBoxEffectMin)
end

function SkillSpectrum_BlackMage_Slot:SkillSpectrumOff()
	self.View.PanelSwitcher2:SetActiveWidgetIndex(0)
end

function SkillSpectrum_BlackMage_Slot:OnSpectrumMaxValueUpdate(MaxValue)
	self:ReGenerateGemSlot(MaxValue / MaxSlotValue)
end

function SkillSpectrum_BlackMage_Slot:OnSpectrumStudy()
	UIUtil.SetIsVisible(self.View.PanelSwitcher2, true)
	--self:ReGenerateGemSlot(self.SlotCount)
end

function SkillSpectrum_BlackMage_Slot:OnSpectrumDeStudy()
	UIUtil.SetIsVisible(self.View.PanelSwitcher2, false)
end

function SkillSpectrum_BlackMage_Slot:ReGenerateGemSlot(Count)
	Count = math.floor(Count)
	self.SlotCount = Count	--水晶个数不固定
	if Count == 0 then
		UIUtil.SetIsVisible(self.View.FImg_gem_frameOFF01_1, false)
		UIUtil.SetIsVisible(self.View.FImg_gem_frameOFF02_1, false)
		UIUtil.SetIsVisible(self.View.FImg_GemON01, false)
		UIUtil.SetIsVisible(self.View.FImg_GemON02, false)
	elseif Count == 1 then
		UIUtil.SetIsVisible(self.View.FImg_gem_frameOFF01_1, true)
		UIUtil.SetIsVisible(self.View.FImg_gem_frameOFF02_1, false)
		UIUtil.SetIsVisible(self.View.FImg_GemON01, true)
		UIUtil.SetIsVisible(self.View.FImg_GemON02, false)
	elseif Count == 2 then
		UIUtil.SetIsVisible(self.View.FImg_gem_frameOFF01_1, true)
		UIUtil.SetIsVisible(self.View.FImg_gem_frameOFF02_1, true)
		UIUtil.SetIsVisible(self.View.FImg_GemON01, true)
		UIUtil.SetIsVisible(self.View.FImg_GemON02, true)
	else
		FLOG_ERROR("SkillSpectrum_BlackMage_Slot:ReGenerateGemSlot Count Error")
	end
end

function SkillSpectrum_BlackMage_Slot_Advance:OnInit()
	self.Super:OnInit()
	self.bEnablePointer = false
	self.LoopCount = 2
	self.DeltaTime = 0.25
	UIUtil.SetIsVisible(self.View.Pointer, false)
	--self.SlotCount = math.floor(_G.MainProSkillMgr:GetSpectrumMaxValue(self.SpectrumID) / MaxSlotValue)
end

function SkillSpectrum_BlackMage_Slot_Advance:SkillSpectrumOn()
	self.Super:SkillSpectrumOn()
	self.bEnablePointer = _G.MainProSkillMgr:GetSpectrumMaxValue(self.SpectrumID) > 0
	if self.bEnablePointer then
		UIUtil.SetIsVisible(self.View.Pointer, true)
		self.View.Pointer:SetRenderTransformAngle(0)
		--self.View:PlayAnimation(self.View.AnimPointIn)
		self.View:PlayAnimationToEndTime(self.View.AnimPointIn)
	end
end

function SkillSpectrum_BlackMage_Slot_Advance:SkillSpectrumOff()
	self.Super:SkillSpectrumOff()
	UIUtil.SetIsVisible(self.View.Pointer, false)
	self.View:StopAnimation(self.View.AnimGlowDownLoop1)
	self.View:StopAnimation(self.View.AnimGlowDownLoop2)
end

function SkillSpectrum_BlackMage_Slot_Advance:ValueUpdateEachFunc(CurValue, TargetValue)
	local Count = math.floor(CurValue / MaxSlotValue)
	local Percent = (CurValue / MaxSlotValue) - Count
	local MaskAngle = MaskBoxEffectMax * Percent
	if TargetValue >= CurValue then
		self.View.ImgProgressBar:SetPercent(MaskAngle)
		if self.bEnablePointer then
			local PointMaxAngle = 90
			local CurAngle = Percent * PointMaxAngle
			self.View.Pointer:SetRenderTransformAngle(CurAngle)
		end
	end

	if Count > self.SlotCount then
		Count = self.SlotCount
	end
	local Distance = math.abs(Count - self.ActiveCount)
	if Distance > 1 then
		FLOG_WARNING("Why???!!!")
		return
	end
	if Count > self.ActiveCount then
		self.View:StopAnimation(self.View[string.format("AnimPurpleOut%d", Count)])
		self.View:PlayAnimationToEndTime(self.View[string.format("AnimPurpleIn%d", Count)])
		self.View:PlayAnimationToEndTime(self.View[string.format("AnimGlowDownLoop%d", Count)], 0, 0)
	elseif Count < self.ActiveCount then
		self.View:StopAnimation(self.View[string.format("AnimPurpleIn%d", Count + 1)])
		self.View:PlayAnimationToEndTime(self.View[string.format("AnimPurpleOut%d", Count + 1)])
		self.View:StopAnimation(self.View[string.format("AnimGlowDownLoop%d", Count + 1)])
	end
	self.ActiveCount = Count
end


return JobSkillBlackMageView