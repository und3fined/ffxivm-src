---
--- Author: henghaoli
--- DateTime: 2022-09-07 10:01
--- Description:
---

local LuaClass = require("Core/LuaClass")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local JobSkillWarriorVM = require("Game/Main/ProSkill/JobSkillWarriorVM")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap

---@class JobSkillWarriorView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Shine UFImage
---@field PanelUnlock UFCanvasPanel
---@field ProgressBar_Energy UProgressBar
---@field ProgressBar_EnergyDeduction UProgressBar
---@field TextUnlock UFTextBlock
---@field Text_Time UTextBlock
---@field AnimShake UWidgetAnimation
---@field AnimShine100 UWidgetAnimation
---@field AnimShine50 UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillWarriorView = LuaClass(ProfProSkillViewBase, true)

local SkillSpectrum_Warrior = LuaClass(ProSkillSpectrumBase, true)

function JobSkillWarriorView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Shine = nil
	--self.PanelUnlock = nil
	--self.ProgressBar_Energy = nil
	--self.ProgressBar_EnergyDeduction = nil
	--self.TextUnlock = nil
	--self.Text_Time = nil
	--self.AnimShake = nil
	--self.AnimShine100 = nil
	--self.AnimShine50 = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillWarriorView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillWarriorView:OnInit()
	self.Super:OnInit()
	-- # TODO - 策划配好表后更改ID
	self:BindSpectrumBehavior(SpectrumIDMap.Warrior, SkillSpectrum_Warrior)

	self.WarriorVM = JobSkillWarriorVM.New()
	self.TextUnlock:SetText(_G.LSTR(140081))  -- 兽魂量谱
end

function JobSkillWarriorView:OnDestroy()
	self.Super:OnDestroy()
end

function JobSkillWarriorView:OnShow()
	self.Super:OnShow()
end

function JobSkillWarriorView:OnHide()
	self.Super:OnHide()
end

function JobSkillWarriorView:OnRegisterUIEvent()

end

function JobSkillWarriorView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

function JobSkillWarriorView:OnRegisterBinder()
	local Binders = {
		{"WrathPercent", UIBinderValueChangedCallback.New(self, nil, self.OnWrathPercentChanged)},
		{"bIs50AnimPlay", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimShine50)},
		{"bIs100AnimPlay", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimShine100)},
	}
	self:RegisterBinders(self.WarriorVM, Binders)
end

function JobSkillWarriorView:OnWrathPercentChanged(NewValue, OldValue)
	self.Text_Time:SetText(tostring(NewValue))
	self.ProgressBar_Energy:SetPercent(NewValue / 100)

	if nil == OldValue or OldValue < NewValue then
		self.ProgressBar_EnergyDeduction:SetPercent(NewValue / 100)
	else
		self:PlayAnimation(self.AnimShake)
		-- # TODO - 第一个参数是量谱ID, 策划配好表后更改
		self:OnSpectrumUpdate_EachTimer(SpectrumIDMap.Warrior, OldValue, NewValue)
	end

	local WarriorVM = self.WarriorVM
	if NewValue < 50 then
		WarriorVM.bIs50AnimPlay = false
		WarriorVM.bIs100AnimPlay = false
	elseif NewValue < 100 then
		WarriorVM.bIs50AnimPlay = true
		WarriorVM.bIs100AnimPlay = false
	else
		WarriorVM.bIs50AnimPlay = false
		WarriorVM.bIs100AnimPlay = true
	end
end


function SkillSpectrum_Warrior:OnInit()
	self.Super:OnInit()
	self.bEnableAdvanceUpdate = false  -- 只有量谱减少时需要迟滞的效果, 因此手动调用OnSpectrumUpdate_EachTimer
	self.Delay = 0.2                   -- Timer开始执行的延迟
end

function SkillSpectrum_Warrior:SkillSpectrumOff()
	-- 切图timer取消, 会出现两个条不一致的情况, 这里强制设置一下
	self.View.WarriorVM.WrathPercent = 0
	self.View.ProgressBar_EnergyDeduction:SetPercent(0)
end

function SkillSpectrum_Warrior:ValueUpdateFunc(CurValue, TargetValue)
	self.View.WarriorVM.WrathPercent = math.floor(TargetValue * 100 / self.SpectrumMaxValue)
end

function SkillSpectrum_Warrior:ValueUpdateEachFunc(EachValue, TargetValue)
	self.View.ProgressBar_EnergyDeduction:SetPercent(EachValue / 100)
end

return JobSkillWarriorView