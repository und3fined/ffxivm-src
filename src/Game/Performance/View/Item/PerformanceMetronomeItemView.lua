---
--- Author: moodliu
--- DateTime: 2023-12-07 15:10
--- Description:节拍器UI (节拍器设置主界面、发起合奏确认界面、主界面右下角）
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MusicPerformanceMetronomeVM = require("Game/Performance/VM/MusicPerformanceMetronomeVM")

---@class PerformanceMetronomeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMetroPlay UFButton
---@field ImgCircleBlack UFImage
---@field ImgCircleBlue UFImage
---@field ImgCircleYellow UFImage
---@field ImgPlay UFImage
---@field AnimRefresh UWidgetAnimation
---@field Animstop UWidgetAnimation
---@field AnimSwing UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceMetronomeItemView = LuaClass(UIView, true)

function PerformanceMetronomeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMetroPlay = nil
	--self.ImgCircleBlack = nil
	--self.ImgCircleBlue = nil
	--self.ImgCircleYellow = nil
	--self.ImgPlay = nil
	--self.AnimRefresh = nil
	--self.Animstop = nil
	--self.AnimSwing = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceMetronomeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceMetronomeItemView:OnInit()
	self.VM = MusicPerformanceMetronomeVM.New()
end

function PerformanceMetronomeItemView:OnDestroy()

end

function PerformanceMetronomeItemView:OnShow()
	self.VM.ImgPlayVisible = true
end

function PerformanceMetronomeItemView:OnActive()
	self:ResetMetronome()
end

function PerformanceMetronomeItemView:OnInactive()
	self:ResetMetronome()
end

function PerformanceMetronomeItemView:OnHide()
	self:ResetMetronome()
end

function PerformanceMetronomeItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMetroPlay, self.OnBtnMetroPlayClicked)
end

function PerformanceMetronomeItemView:OnRegisterGameEvent()
end

function PerformanceMetronomeItemView:SetVMSettingsSaved()
	self.VM:SetSaved()
end

function PerformanceMetronomeItemView:IsWorking()
	return self.Timer ~= nil
end

function PerformanceMetronomeItemView:ResetMetronome()
	self:UpdateBeat(0, 1)
	self.VM.ImgPlayVisible = true
	_G.TimerMgr:CancelTimer(self.Timer)
	self.Timer = nil

	self.VM.ImgCircleYellowVisible = false
	self.VM.ImgCircleBlueVisible = false

	if self.AnimSwing then
		self:StopAnimation(self.AnimSwing)
	end
	if self.Animstop then
		self:PlayAnimation(self.Animstop)
	end
end

function PerformanceMetronomeItemView:SetAnimSwingSpeed(AnimSpeed)
	if self.AnimSwing then
		self:SetPlaybackSpeed(self.AnimSwing, AnimSpeed)
	end
end

function PerformanceMetronomeItemView:GetAnimSwingSpeed()
	local BeatTime = 60.0 / self.VM.BPM
	local SwingCircleTime = self.AnimSwing:GetEndTime() -- 转一个来回的时间
	local AnimBeatTime = SwingCircleTime / 2			-- 一个beat的时间
	local AnimSpeed = AnimBeatTime / BeatTime

	return AnimSpeed
end

function PerformanceMetronomeItemView:Play(Offset)
	_G.TimerMgr:CancelTimer(self.Timer)
	self.Timer = nil
	self:UpdateBeat(Offset, 1)

	local PrevTime = 0
	local CurBeat = 0
	local CostTime = 0

	if self.AnimSwing then
		self:PlayAnimation(self.AnimSwing, 0, 0, _G.UE.EUMGSequencePlayMode.Forward, self:GetAnimSwingSpeed())
	end

	local BeatTicker = function(_, ElapsedTime)
		local BeatTime = 60.0 / self.VM.BPM
		CostTime = ElapsedTime - PrevTime + CostTime
		local ThisBeat = CurBeat + math.floor(CostTime / BeatTime)
		self:SetAnimSwingSpeed(self:GetAnimSwingSpeed())

		-- -- 指针更新
		-- local Progress = CostTime / BeatTime
		-- local IntegerPart, DecimalPart = math.modf(Progress)
		-- local AngleMin = -60
		-- local AngleMax = 60
		-- local Delta = AngleMax - AngleMin
		-- if ThisBeat % 2 == 0 then
		-- 	self.VM.ImgPendulumAngle = AngleMin + Delta * DecimalPart
		-- else
		-- 	self.VM.ImgPendulumAngle = AngleMax - Delta * DecimalPart
		-- end

		if CurBeat ~= ThisBeat then
			-- 更新Beat
			CostTime = CostTime % BeatTime
			CurBeat = ThisBeat
			local BeatPerBar = self.VM.BeatPerBar
			local CurBar = math.floor(CurBeat / BeatPerBar) + Offset
			-- Beat Changed
			if CurBeat % BeatPerBar == 0 then
				self.VM.ImgCircleYellowVisible = true
				-- 仅有准备小节振铃优先级最高
				if self.VM.Prepare == 1 and self.VM.EffectPrepareOnly == 1 and CurBar < 0 then
					MusicPerformanceUtil.PlayMetroAccSound()
				elseif self.VM.Prepare == 1 and self.VM.EffectPrepareOnly == 1 and CurBar >= 0 then
					MusicPerformanceUtil.PlayMetroTickSound()
				elseif self.VM.Effect == 1 then
					MusicPerformanceUtil.PlayMetroAccSound()
				else
					MusicPerformanceUtil.PlayMetroTickSound()
				end
			else
				self.VM.ImgCircleBlueVisible = true
				MusicPerformanceUtil.PlayMetroTickSound()
			end
			self:UpdateBeat(CurBar, CurBeat % BeatPerBar + 1)
		else
			--首次进入
			if PrevTime < 0.001 then
				-- start trigger
				self.VM.ImgCircleYellowVisible = true
				--小节振铃关时，由于“仅有准备小节振铃”优先级最高，所以也要振铃
				if self.VM.Effect == 1 or (self.VM.Effect == 0 and self.VM.EffectPrepareOnly == 1)then
					MusicPerformanceUtil.PlayMetroAccSound()
				end
			else
				self.VM.ImgCircleYellowVisible = false
				self.VM.ImgCircleBlueVisible = false
			end
		end
		PrevTime = ElapsedTime
	end
	self.Timer = _G.TimerMgr:AddTimer(nil, BeatTicker, 0, 0.05, 0)
end

function PerformanceMetronomeItemView:OnBtnMetroPlayClicked()
	self.VM.ImgPlayVisible = not self.VM.ImgPlayVisible
	if not self.VM.ImgPlayVisible then
		local Offset = MusicPerformanceUtil.GetBarOffset(self.VM.Prepare)
		self:Play(Offset)
	else
		self:ResetMetronome()
	end
end

function PerformanceMetronomeItemView:OnRegisterBinder()
	local Binders = {
		{ "ImgPlayVisible", UIBinderSetIsVisible.New(self, self.ImgPlay) },
		{ "ImgCircleBlueVisible", UIBinderSetIsVisible.New(self, self.ImgCircleBlue, false, true) },
		{ "ImgCircleYellowVisible", UIBinderSetIsVisible.New(self, self.ImgCircleYellow, false, true) },
		{ "BtnMetroPlayVisible", UIBinderSetIsVisible.New(self, self.BtnMetroPlay, false, true) },
	}

	self:RegisterBinders(self.VM, Binders)
end

function PerformanceMetronomeItemView:SetParentVM(VM)
	self.ParentVM = VM
end

function PerformanceMetronomeItemView:UpdateBeat(CurBar, BeatCount)
	if self.ParentVM then
		if CurBar >= 0 then
			CurBar = CurBar + 1
		end
		self.ParentVM.TempoTip = string.format("%d:%d", CurBar, BeatCount)
	end
end

return PerformanceMetronomeItemView