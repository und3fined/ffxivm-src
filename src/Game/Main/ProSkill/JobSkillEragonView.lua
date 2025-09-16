---
--- Author: chaooren
--- DateTime: 2022-04-06 15:10
--- Description:
---

local LuaClass = require("Core/LuaClass")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap

local Rragon_Base_TickInterval = 0.25

---@class JobSkillEragonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProBarBlue UProgressBar
---@field ProBarRed UProgressBar
---@field Text UFTextBlock
---@field AnimEye1 UWidgetAnimation
---@field AnimEye1Loop UWidgetAnimation
---@field AnimEye2 UWidgetAnimation
---@field AnimEye2Loop UWidgetAnimation
---@field AnimEye3 UWidgetAnimation
---@field AnimEye3Loop UWidgetAnimation
---@field AnimEyeStop UWidgetAnimation
---@field AnimInitial UWidgetAnimation
---@field AnimToBlue UWidgetAnimation
---@field AnimToRed UWidgetAnimation
---@field AnimToRedLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillEragonView = LuaClass(ProfProSkillViewBase, true)

local SkillSpectrum_Eragon_Eye = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_Eragon_Base = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_Eragon_Red = LuaClass(SkillSpectrum_Eragon_Base, true)
local SkillSpectrum_Eragon_Blue = LuaClass(SkillSpectrum_Eragon_Base, true)

function JobSkillEragonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProBarBlue = nil
	--self.ProBarRed = nil
	--self.Text = nil
	--self.AnimEye1 = nil
	--self.AnimEye1Loop = nil
	--self.AnimEye2 = nil
	--self.AnimEye2Loop = nil
	--self.AnimEye3 = nil
	--self.AnimEye3Loop = nil
	--self.AnimEyeStop = nil
	--self.AnimInitial = nil
	--self.AnimToBlue = nil
	--self.AnimToRed = nil
	--self.AnimToRedLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillEragonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillEragonView:IsSpectrumStart(SpectrumID)
	if self.SpectrumPair[SpectrumID] then
		return self.SpectrumPair[SpectrumID].Begin
	end
	return false
end

function JobSkillEragonView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.Eragon_Eye, SkillSpectrum_Eragon_Eye)
	self:BindSpectrumBehavior(SpectrumIDMap.Eragon_Red, SkillSpectrum_Eragon_Red)
	self:BindSpectrumBehavior(SpectrumIDMap.Eragon_Blue, SkillSpectrum_Eragon_Blue)
	self.TextUnlock:SetText(_G.LSTR(140094))  -- 龙血量谱
end

function JobSkillEragonView:OnDestroy()
	self.Super:OnDestroy()
end

function JobSkillEragonView:OnShow()
	self.Super:OnShow()
	if not self:IsSpectrumStart(SpectrumIDMap.Eragon_Red) and not self:IsSpectrumStart(SpectrumIDMap.Eragon_Blue) then
		self:PlayAnimation(self.AnimInitial)
	end
end

function JobSkillEragonView:OnHide()
	self.Super:OnHide()
end

function JobSkillEragonView:OnRegisterUIEvent()

end

function JobSkillEragonView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
end

function JobSkillEragonView:OnRegisterBinder()

end

function JobSkillEragonView:OnAnimationFinished(Anim)
	--手动stop的动画不应该执行完成回调
	if self.StopAnim == Anim then
		return
	end
	if Anim == self.AnimEye1 then
		self:PlayAnimation(self.AnimEye1Loop, 0, 0)
	elseif Anim == self.AnimEye2 then
		self:PlayAnimation(self.AnimEye2Loop, 0, 0)
	elseif Anim == self.AnimEye3 then
		self:PlayAnimation(self.AnimEye3Loop, 0, 0)
	elseif Anim == self.AnimToRed then
		self:PlayAnimation(self.AnimToRedLoop, 0, 0)
	end
end

function JobSkillEragonView:OnUpdateBuff(Params)
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

function JobSkillEragonView:OnRemoveBuff(Params)
	local BuffID = Params.IntParam1
	local EntityID = Params.ULongParam1
	--只受自身buff影响
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

function JobSkillEragonView:AdvanceStopAnimation(Anim)
	if Anim then
		self.StopAnim = Anim
		self:StopAnimation(Anim)
		self.StopAnim = nil
	end
end

function SkillSpectrum_Eragon_Eye:OnInit()
	self.Super:OnInit()
	self.bEnableUpdate = false
	self.bEnableAdvanceUpdate = false
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)) or 0
	self.CurPile = 0
end

function SkillSpectrum_Eragon_Eye:SkillSpectrumOn()
	local BuffInfo = GetBuffInfo(self.BuffID)
	if BuffInfo then
		local Pile = BuffInfo.Pile
		self.CurPile = Pile
		local AnimName = string.format("AnimEye%d", Pile)
		local Anim = self.View[AnimName]
		if Anim then
			self.View:PlayAnimation(Anim)
		end
	end
end

function SkillSpectrum_Eragon_Eye:SkillSpectrumOff()
	self:StopAnimByPile(self.CurPile)
	self.CurPile = 0
end

function SkillSpectrum_Eragon_Eye:OnCastBuff(BuffInfo)
	local Pile = BuffInfo.IntParam2
	if Pile ~= self.CurPile then
		self:StopAnimByPile(self.CurPile)
		self.CurPile = Pile
		local AnimName = string.format("AnimEye%d", Pile)
		local Anim = self.View[AnimName]
		if Anim then
			self.View:PlayAnimation(Anim)
		end
	end
end

function SkillSpectrum_Eragon_Eye:OnRemoveBuff(BuffInfo)
	print("SkillSpectrum_Eragon_Eye:OnRemoveBuff")
	self:StopAnimByPile(self.CurPile)
	self.CurPile = 0
end

function SkillSpectrum_Eragon_Eye:StopAnimByPile(Pile)
	--0层没有对应动画
	if Pile == 0 then
		return
	end
	local Anim = self.View[string.format("AnimEye%d", Pile)]
	local LoopAnim = self.View[string.format("AnimEye%dloop", Pile)]
	self.View:AdvanceStopAnimation(Anim)
	self.View:AdvanceStopAnimation(LoopAnim)
	self.View:PlayAnimation(self.View.AnimEyeStop)
end

function SkillSpectrum_Eragon_Base:OnInit()
	self.Super:OnInit()
	self.bEnableUpdate = false
	self.bEnableAdvanceUpdate = false
	self.EnterAnimName = ""
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)) or 0
	self.ProBarMax = 30
	self.TimerID = 0
	self.TimeCount = 0
end

function SkillSpectrum_Eragon_Base:SkillSpectrumOn()
	local BuffInfo = GetBuffInfo(self.BuffID)
	if BuffInfo then
		self:OnCastBuffInternal(BuffInfo.ExpdTime)
	else
		self.CurrentProgressBar:SetPercent(1)
	end
	local EnterAnim = self.View[self.EnterAnimName]
	if EnterAnim then
		self.View:PlayAnimation(EnterAnim)
	end
end

function SkillSpectrum_Eragon_Base:SkillSpectrumOff()
	local EnterAnim = self.View[self.EnterAnimName]
	self.View:AdvanceStopAnimation(EnterAnim)
	self:CancelTimer()
	--self.View:PlayAnimation(self.View.AnimInitial)
end

function SkillSpectrum_Eragon_Base:OnCastBuff(BuffInfo)
	self:CancelTimer()
	local ExpdTime = BuffInfo.ULongParam3
	self:OnCastBuffInternal(ExpdTime)
end

function SkillSpectrum_Eragon_Base:OnCastBuffInternal(TargetTime)
	local ExpdTime = TargetTime
	local Duration = (ExpdTime - TimeUtil.GetServerTimeMS()) / 1000
	local Precent = Duration / self.ProBarMax
	if Precent > 1 then
		Precent = 1
	end
	self.TimeCount = Duration
	self.View.Text:SetText(tostring(math.floor(Duration)))
	self.TimerID = self:CreateLoopTimer(self, self.Eragon_Base_Tick, 0, Rragon_Base_TickInterval)
	self.CurrentProgressBar:SetPercent(Precent)
end

function SkillSpectrum_Eragon_Base:Eragon_Base_Tick()
	--kun kun 让我这么写
	if self.SpectrumID == SpectrumIDMap.Eragon_Blue and self.View:IsSpectrumStart(SpectrumIDMap.Eragon_Red) then
		return
	end
	local CurTime = self.TimeCount - Rragon_Base_TickInterval
	if CurTime <= 0 then
		self:CancelTimer()
		return
	end
	local FloorCurTime = math.floor(CurTime)
	if FloorCurTime ~= math.floor(self.TimeCount) then
		self.View.Text:SetText(tostring(FloorCurTime))
	end
	local Precent = CurTime / self.ProBarMax
	if Precent > 1 then
		Precent = 1
	end
	self.CurrentProgressBar:SetPercent(Precent)
	self.TimeCount = CurTime
end

function SkillSpectrum_Eragon_Base:CancelTimer()
	if self.TimerID ~= 0 then
		self:ReleaseLoopTimer(self.TimerID)
		self.TimerID = 0
	end
end

function SkillSpectrum_Eragon_Red:OnInit()
	self.Super:OnInit()
	self.CurrentProgressBar = self.View.ProBarRed
	self.EnterAnimName = "AnimToRed"
end

function SkillSpectrum_Eragon_Red:SkillSpectrumOff()
	self.Super:SkillSpectrumOff()
	self.View:AdvanceStopAnimation(self.View.AnimToRedLoop)
	local bBlueEnable = self.View:IsSpectrumStart(SpectrumIDMap.Eragon_Blue)
	if bBlueEnable == false then
		self.View:PlayAnimation(self.View.AnimInitial)
	end
end

function SkillSpectrum_Eragon_Blue:OnInit()
	self.Super:OnInit()
	self.CurrentProgressBar = self.View.ProBarBlue
	self.EnterAnimName = "AnimToBlue"
end

function SkillSpectrum_Eragon_Blue:SkillSpectrumOff()
	self.Super:SkillSpectrumOff()
	self.View:AdvanceStopAnimation(self.View.AnimToRedLoop)
	local EnterAnim = self.View[self.EnterAnimName]
	local bRedEnable = self.View:IsSpectrumStart(SpectrumIDMap.Eragon_Red)
	if bRedEnable == false then
		self.View:PlayAnimationReverse(EnterAnim)
	end
end

return JobSkillEragonView