---
--- Author: chaooren
--- DateTime: 2023-03-30 15:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local JobSkillSummonerVM = require("Game/Main/ProSkill/JobSkillSummonerVM")

local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")

---@class JobSkillSummonerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_ProSkillInteract_UIBP CommonProSkillInteractView
---@field Dragon UFCanvasPanel
---@field EFF_JobSkill UFCanvasPanel
---@field Gemstone JobSkillSummonerGemstoneItemView
---@field PanelUnlock UFCanvasPanel
---@field ProgressBarDragon UProgressBar
---@field ProgressBarRabbit UProgressBar
---@field Rabbit UFCanvasPanel
---@field RabbitNormal UFCanvasPanel
---@field Summoner UWidgetSwitcher
---@field TextTime1 UFTextBlock
---@field TextTime1_2 UFTextBlock
---@field TextTime1_3 UFTextBlock
---@field TextUnlock UFTextBlock
---@field Anim_Disable_In UWidgetAnimation
---@field Anim_Disable_Out UWidgetAnimation
---@field AnimDragon1Loop UWidgetAnimation
---@field AnimDragon1To2 UWidgetAnimation
---@field AnimDragon2Loop UWidgetAnimation
---@field AnimDragon2To1 UWidgetAnimation
---@field AnimDragon3Loop UWidgetAnimation
---@field AnimDragon3To4 UWidgetAnimation
---@field AnimDragon4To3 UWidgetAnimation
---@field AnimDragonType1 UWidgetAnimation
---@field AnimDragonType2 UWidgetAnimation
---@field AnimRabbit1To2 UWidgetAnimation
---@field AnimRabbit2Loop UWidgetAnimation
---@field AnimRabbit2To1 UWidgetAnimation
---@field AnimRabbitOpen UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---@field AnimPoint UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillSummonerView = LuaClass(ProfProSkillViewBase, true)

local SkillSpectrum_Summoner_Animal = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_Summoner_Dragon = LuaClass(SkillSpectrum_Summoner_Animal, true)
local SkillSpectrum_Summoner_Rabbit = LuaClass(SkillSpectrum_Summoner_Animal, true)

function JobSkillSummonerView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_ProSkillInteract_UIBP = nil
	--self.Dragon = nil
	--self.EFF_JobSkill = nil
	--self.Gemstone = nil
	--self.PanelUnlock = nil
	--self.ProgressBarDragon = nil
	--self.ProgressBarRabbit = nil
	--self.Rabbit = nil
	--self.RabbitNormal = nil
	--self.Summoner = nil
	--self.TextTime1 = nil
	--self.TextTime1_2 = nil
	--self.TextTime1_3 = nil
	--self.TextUnlock = nil
	--self.Anim_Disable_In = nil
	--self.Anim_Disable_Out = nil
	--self.AnimDragon1Loop = nil
	--self.AnimDragon1To2 = nil
	--self.AnimDragon2Loop = nil
	--self.AnimDragon2To1 = nil
	--self.AnimDragon3Loop = nil
	--self.AnimDragon3To4 = nil
	--self.AnimDragon4To3 = nil
	--self.AnimDragonType1 = nil
	--self.AnimDragonType2 = nil
	--self.AnimRabbit1To2 = nil
	--self.AnimRabbit2Loop = nil
	--self.AnimRabbit2To1 = nil
	--self.AnimRabbitOpen = nil
	--self.AnimUnlock = nil
	--self.AnimPoint = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillSummonerView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_ProSkillInteract_UIBP)
	self:AddSubView(self.Gemstone)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillSummonerView:OnInit()
	self.Super:OnInit()
	self.SpectrumBuffID = 1096
	--TODO[chaooren] 召唤师以太超流没有逻辑，但存在对应配置
	self:BindSpectrumBehavior(SpectrumIDMap.Summoner, ProSkillSpectrumBase)
	self:BindSpectrumBehavior(SpectrumIDMap.Summoner_Dragon, SkillSpectrum_Summoner_Dragon)
	self:BindSpectrumBehavior(SpectrumIDMap.Summoner_Rabbit, SkillSpectrum_Summoner_Rabbit)
	self.TextUnlock:SetText(_G.LSTR(140095))  -- 同调量谱
end

function JobSkillSummonerView:OnDestroy()
	self.Super:OnDestroy()
end

function JobSkillSummonerView:ShowView(Params, IsInheritedParams)
	if rawget(self, "IsShowView") then
		return
	end

	self.SummonerVM = JobSkillSummonerVM.New()
	self.Super:ShowView(Params, IsInheritedParams)
end

function JobSkillSummonerView:OnShow()
	self.Gemstone:SetVM(self.SummonerVM)
	self.Super:OnShow()
end

function JobSkillSummonerView:OnHide()
	self.Super:OnHide()
end

function JobSkillSummonerView:OnRegisterUIEvent()

end

function JobSkillSummonerView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
	self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
	self:RegisterGameEvent(EventID.UseSkillNotSummonEvent, self.OnUseSkillNotSummon)
end

function JobSkillSummonerView:OnRegisterBinder()
	local Binders = {
		{ "AnimalIndex", UIBinderSetActiveWidgetIndex.New(self, self.Summoner) },
		{ "DragonInitLoopAnim", UIBinderIsLoopAnimPlay.New(self, nil,self.AnimDragon2Loop, true) },
		{ "Position", UIBinderCanvasSlotSetPosition.New(self, self.Gemstone, true) },
		{ "Position", UIBinderCanvasSlotSetPosition.New(self, self.EFF_JobSkill, true) },
	}

	self:RegisterBinders(self.SummonerVM, Binders)
end

function JobSkillSummonerView:OnGameEventMajorDead()
	self:StopAllAnimations()
	self.Gemstone:StopAllAnimations()
	self.SummonerVM:Reset()
	self:SetSpectrumState(false)
end

function JobSkillSummonerView:OnUpdateBuff(Params)
	local EntityID = Params.ULongParam1
	local BuffID = Params.IntParam1
	--只受自身buff影响
	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end
	if BuffID == self.SpectrumBuffID then
		self:SetSpectrumState(true)
	end
	for _, value in pairs(self.SpectrumPair) do
		if value and value.Begin then
			value:OnCastBuff(Params)
		end
	end
end

function JobSkillSummonerView:OnRemoveBuff(Params)
	local EntityID = Params.ULongParam1
	local BuffID = Params.IntParam1
	--只受自身buff影响
	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end
	if BuffID == self.SpectrumBuffID then
		self:SetSpectrumState(false)
	end
	for _, value in pairs(self.SpectrumPair) do
		if value and value.Begin then
			value:OnRemoveBuff(Params)
		end
	end
end

function JobSkillSummonerView:UpdateView(Params)
	--【Bug】进入和本地图相同的副本内，召唤师量谱不会刷新
	self:OnHide()
	self.Super:UpdateView(Params)
end

function JobSkillSummonerView:SetSpectrumState(State)
	UIUtil.SetIsVisible(self.Summoner, State)
	UIUtil.SetIsVisible(self.Gemstone, State)
	UIUtil.SetIsVisible(self.RabbitNormal, not State)
	if State then
		self:PlayAnimation(self.AnimRabbitOpen)
	end
end

local function GetBuffInfo(InBuffID)
	return _G.SkillBuffMgr:GetBuffInfo(InBuffID)
end

function JobSkillSummonerView:OnUseSkillNotSummon()
	self:PlayAnimation(self.AnimPoint)
end

function SkillSpectrum_Summoner_Animal:OnInit()
	self.Super:OnInit()
	local SpectrumTypeParam2 = _G.MainProSkillMgr:GetSpectrumTypeParam2(self.SpectrumID)
	self.GemBuffList = SpectrumTypeParam2[1]
	self.GemStatusList = SpectrumTypeParam2[2]
	--self.GemBuffList = _G.MainProSkillMgr:GetSpectrumTypeParam2(self.SpectrumID) or "0, 0, 0"
	self.CurProgress = nil
	self.ProgressTime = nil

	self.TimerID = 0
end

function SkillSpectrum_Summoner_Animal:OnSpectrumStudy()
	local ViewVM = self.View.SummonerVM
	ViewVM.AnimalIndex = self.AnimalIndex
	ViewVM.Position = self.Position
	self.CurProgress:SetPercent(0)

	local BuffComponent = MajorUtil.GetMajorBuffComponent()
	if BuffComponent then
		local Pile = BuffComponent:GetBuffPile(self.View.SpectrumBuffID)
		self.View:SetSpectrumState(Pile > 0)
	end
end

function SkillSpectrum_Summoner_Animal:OnSpectrumDeStudy()
	-- local BuffComponent = MajorUtil.GetMajorBuffComponent()
	-- if BuffComponent then
	-- 	local Pile = BuffComponent:GetBuffPile(self.View.SpectrumBuffID)
	-- 	self.View:SetSpectrumState(Pile>0)
	-- end
end

function SkillSpectrum_Summoner_Animal:SkillSpectrumOn()
	local ViewVM = self.View.SummonerVM
	ViewVM:ResetGemPileList()

	local ProgressBuffInfo = GetBuffInfo(self.ProgressBuffID)
	if ProgressBuffInfo ~= nil then
		self:DoProgressBuffAdd(ProgressBuffInfo.ExpdTime)
	end

	for index, value in ipairs(self.GemStatusList) do
		local BuffInfo = GetBuffInfo(value)
		if BuffInfo then
			self:OnCastGemStatusBuff(index, true)
		end
	end

	for index, value in ipairs(self.GemBuffList) do
		local BuffInfo = GetBuffInfo(value)
		if BuffInfo then
			self:OnCastGemBuff(index, BuffInfo.ExpdTime, BuffInfo.Pile)
		end
	end
end

function SkillSpectrum_Summoner_Animal:SkillSpectrumOff()
	--量谱提前关闭
	local MainView = self.View
	if self.TimerID > 0 then
		MainView:StopAllAnimations()
		MainView:PlayAnimation(self.LoopBeginAnim, 0, 1, _G.UE.EUMGSequencePlayMode.Reverse)
		self:ReleaseLoopTimer(self.TimerID)
		self.TimerID = 0
	else
		MainView:StopAllAnimations()
		--在动画播放的时候打断（关闭UI等），会动画中的对象变为动画第一帧的状态，重设对象属性
		MainView:PlayAnimationToEndTime(self.LoopEndAnim, 0.5, 1, _G.UE.EUMGSequencePlayMode.Forward)
	end

	self.CurProgress:SetPercent(0)

	local GemView = self.View.Gemstone
	GemView:StopAllAnimations()
	GemView:PlayAnimationToEndTime(GemView.AnimState1)
end

function SkillSpectrum_Summoner_Animal:OnCastBuff(Params)
	local BuffID = Params.IntParam1
	if BuffID == self.ProgressBuffID then
		self:DoProgressBuffAdd(Params.ULongParam3)
	else
		for index, value in ipairs(self.GemBuffList) do
			if BuffID == value then
				self:OnCastGemBuff(index, Params.ULongParam3, Params.IntParam2)
				return
			end
		end

		for index, value in ipairs(self.GemStatusList) do
			if BuffID == value then
				self:OnCastGemStatusBuff(index, true)
				return
			end
		end
	end
end

function SkillSpectrum_Summoner_Animal:OnRemoveBuff(Params)
	local BuffID = Params.IntParam1

	if BuffID == self.ProgressBuffID then
		self:DoProgressBuffRemove()
		return
	end

	for index, value in ipairs(self.GemBuffList) do
		if BuffID == value then
			self:OnCastGemBuff(index, -1, 0)
			return
		end
	end

	for index, value in ipairs(self.GemStatusList) do
		if BuffID == value then
			self:OnCastGemStatusBuff(index, false)
			return
		end
	end
end


function SkillSpectrum_Summoner_Animal:OnCastGemBuff(Index, TargetTime, Pile)
	self.View.SummonerVM:SetGemData(Index, TargetTime, Pile)
end

function SkillSpectrum_Summoner_Animal:OnCastGemStatusBuff(Index, bCast)
	self.View.SummonerVM:SetGemStatus(Index, bCast)
end

local TickInterval = 0.15

function SkillSpectrum_Summoner_Animal:DoProgressBuffAdd(ExpdTime)
	self.View:PlayAnimation(self.LoopAnim, 0, 0, nil, 1.0, true)
	self.View:PlayAnimation(self.LoopBeginAnim)
	local BeginServerTimeMS = TimeUtil.GetServerTimeMS()
	local Duration = (ExpdTime - BeginServerTimeMS) / 1000
	if self.TimerID > 0 then
		self:ReleaseLoopTimer(self.TimerID)
	end
	if Duration > 0 then
		local ViewVM = self.View.SummonerVM
		ViewVM:SwitchState(-1, 1, -1)
		self.TimerID = self:CreateLoopTimer(self, self.ProgressBuffTick, 0, TickInterval, {BeginServerTimeMS, Duration})
	else
		self:OnProgressBuffTickEnd()
	end
end

function SkillSpectrum_Summoner_Animal:DoProgressBuffRemove()
	self.View.SummonerVM:ResetGemPileList()
end

function SkillSpectrum_Summoner_Animal:ProgressBuffTick(Params)
	local ExpdTime = (TimeUtil.GetServerTimeMS() - Params[1]) / 1000
	local LastTime = Params[2] - ExpdTime
	if LastTime > 0 then
		self.ProgressTime:SetText(tostring(math.floor(LastTime)))
		self.CurProgress:SetPercent(LastTime / Params[2])
	else
		self:OnProgressBuffTickEnd()
	end
end

function SkillSpectrum_Summoner_Animal:OnProgressBuffTickEnd()
	self.View:StopAnimation(self.LoopAnim)
	self.View:StopAnimation(self.LoopBeginAnim)
	self.View:PlayAnimationToEndTime(self.LoopEndAnim)
	self:ReleaseLoopTimer(self.TimerID)
	self.TimerID = 0
	self.View.SummonerVM:SwitchState(-1, -1, 1)
end

function SkillSpectrum_Summoner_Dragon:OnInit()
	self.Super:OnInit()
	self.ProgressBuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)) or 0
	self.CurProgress = self.View.ProgressBarDragon
	self.ProgressTime = self.View.TextTime1
	self.LoopBeginAnim = self.View.AnimDragon2To1
	self.LoopAnim = self.View.AnimDragon1Loop
	self.LoopEndAnim = self.View.AnimDragon1To2
	self.AnimalIndex = 0
	self.Position = UE.FVector2D(118, 92)
end

function SkillSpectrum_Summoner_Dragon:OnProgressBuffTickEnd()
	self.Super:OnProgressBuffTickEnd()
	self.View.SummonerVM.DragonInitLoopAnim = true
end

function SkillSpectrum_Summoner_Dragon:OnSpectrumStudy()
	self.Super:OnSpectrumStudy()
	local ViewVM = self.View.SummonerVM
	ViewVM.DragonInitLoopAnim = true
	self.View:PlayAnimation(self.View.AnimDragonType1)
	for i = 1, 3 do
		ViewVM[string.format("GemstoneCanvas%d", i)] = true
	end
end

function SkillSpectrum_Summoner_Dragon:OnSpectrumDeStudy()
	local ViewVM = self.View.SummonerVM
	if ViewVM then
		ViewVM.DragonInitLoopAnim = false
	end
end

function SkillSpectrum_Summoner_Dragon:DoProgressBuffAdd(ExpdTime)
	self.Super:DoProgressBuffAdd(ExpdTime)
	self.View.SummonerVM.DragonInitLoopAnim = false
end

function SkillSpectrum_Summoner_Rabbit:OnInit()
	self.Super:OnInit()
	local TableParam1 = string.split(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID), "|") or {}
	self.ProgressBuffID = tonumber(TableParam1[1]) or 0
	self.GemShowLevel = load("return " .. tostring(TableParam1[2] or {}))()
	self.CurProgress = self.View.ProgressBarRabbit
	self.ProgressTime = self.View.TextTime1_2
	self.AnimalIndex = 1
	self.Position = UE.FVector2D(140, 80)

	self.LoopBeginAnim = self.View.AnimRabbit1To2
	self.LoopAnim = self.View.AnimRabbit2Loop
	self.LoopEndAnim = self.View.AnimRabbit2To1
end

function SkillSpectrum_Summoner_Rabbit:OnSpectrumStudy()
	self.Super:OnSpectrumStudy()
	local MaxIndex = 3
	local MajorLevel = MajorUtil.GetMajorLevel()
	for index, value in ipairs(self.GemShowLevel) do
		if value > (MajorLevel or 1) then
			MaxIndex = index - 1
			break
		end
	end
	local ViewVM = self.View.SummonerVM
	for i = 1, 3 do
		ViewVM[string.format("GemstoneCanvas%d", i)] = i <= MaxIndex
	end
end
return JobSkillSummonerView