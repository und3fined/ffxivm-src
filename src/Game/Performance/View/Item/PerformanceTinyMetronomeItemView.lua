---
--- Author: moodliu
--- DateTime: 2023-12-07 15:34
--- Description:微型节拍器面板 （演奏助手过程中、合奏过程中）
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MusicPerformanceMetronomeVM = require("Game/Performance/VM/MusicPerformanceMetronomeVM")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceTinyMetronomeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCircleBlack UFImage
---@field ImgCircleBlue UFImage
---@field ImgCircleYellow UFImage
---@field ImgPendulum UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceTinyMetronomeItemView = LuaClass(UIView, true)

function PerformanceTinyMetronomeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCircleBlack = nil
	--self.ImgCircleBlue = nil
	--self.ImgCircleYellow = nil
	--self.ImgPendulum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceTinyMetronomeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceTinyMetronomeItemView:OnInit()
	self.VM = MusicPerformanceMetronomeVM.New()
	self.VM:SetSaved()
	self.OuterCostTime = nil		-- 通过外部来控制指针运动
	self.SpeedValue = 1
end

function PerformanceTinyMetronomeItemView:SetAnimSwingSpeed(AnimSpeed)
	if self.AnimSwing then
		self:SetPlaybackSpeed(self.AnimSwing, AnimSpeed)
	end
end

function PerformanceTinyMetronomeItemView:GetAnimSwingSpeed()
	local BeatTime = 60.0 / self.VM.BPM
	local SwingCircleTime = self.AnimSwing:GetEndTime() -- 转一个来回的时间
	local AnimBeatTime = SwingCircleTime / 2			-- 一个beat的时间
	local AnimSpeed = AnimBeatTime / BeatTime

	return AnimSpeed * self.SpeedValue
end

function PerformanceTinyMetronomeItemView:OnDestroy()

end

-- 调用Play重新Play
function PerformanceTinyMetronomeItemView:Pause()
	_G.TimerMgr:CancelTimer(self.Timer)
	self:PauseAnimation(self.AnimSwing)
end

function PerformanceTinyMetronomeItemView:SetBPM(BPM)
	self.VM.BPM = BPM
end

function PerformanceTinyMetronomeItemView:SetBeatPerBar(BeatPerBar)
	self.VM.BeatPerBar = BeatPerBar
end

function PerformanceTinyMetronomeItemView:SetSpeedValue(SpeedValue)
	self.SpeedValue = SpeedValue
end

function PerformanceTinyMetronomeItemView:GetBeatTime()
	return 60.0 / (self.VM.BPM or MPDefines.MetronomeSettings.DefaultSetting.BPM)
end

function PerformanceTinyMetronomeItemView:Play(TimeOffset)
	_G.FLOG_INFO("TinyMetronomeItemView:Play== [TimeOffset=%f]", TimeOffset)
	_G.TimerMgr:CancelTimer(self.Timer)
	self.Timer = nil

	local PrevTime = 0
	local CurBeat = 0
	local CostTime = TimeOffset or 0

	if self.AnimSwing then
		-- 动画的开始播放位置占比率：当前音符所在时间(秒) 除以 动画播放一次的真实总时间(秒)，然后modf取到的小数点后面的数，则是动画的开始播放位置占比率
		-- 动画播放一次的真实总时间SwingCircleTimeReal：动画的总时间 * 每分钟节拍数的占比率(因为这个BMP玩家是会设置的，并不是每60秒就60的BMP)
		-- 取到的小数点后面的数DecimalPart：因为整数部分就相当于 按动画的总时间 把这个音符的总时间里分成了N份，小数部分才是这个动画此时此刻应该开始的位置
		-- StartAtTime：动画的开始播放位置占比率不能直接用给StartAtTime，他只是在 动画播放一次的总时间 的一个占比率，所以需要(DecimalPart * SwingCircleTime)

		local SwingCircleTime = self.AnimSwing:GetEndTime() --动画的总时间(转一个来回的时间)
		local BeatTime = self:GetBeatTime()
		local SwingCircleTimeReal = SwingCircleTime * BeatTime
		local IntegerPart, DecimalPart = math.modf(CostTime / SwingCircleTimeReal)	-- 求动画的进度
		--_G.FLOG_INFO("TinyMetronomeItemView:Play AnimSwing== [StartAtTime=%f, CostTime=%f, BeatTime=%f, DecimalPart=%f,  IntegerPart=%f]", DecimalPart * SwingCircleTime, CostTime, BeatTime, DecimalPart, IntegerPart)
		self:PlayAnimation(self.AnimSwing, DecimalPart * SwingCircleTime, 0, _G.UE.EUMGSequencePlayMode.Forward, self:GetAnimSwingSpeed())
	end

	local BeatTicker = function(_, ElapsedTime)
		local BeatTime = self:GetBeatTime()
		CostTime = self.OuterCostTime or (ElapsedTime - PrevTime + CostTime)
		local ThisBeat = CurBeat + math.floor(CostTime / BeatTime)
		self:SetAnimSwingSpeed(self:GetAnimSwingSpeed())

		-- 指针更新
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
			-- Beat Changed
			if CurBeat % BeatPerBar == 0 then
				self.VM.ImgCircleYellowVisible = true
				local CurBar = math.floor(CurBeat / BeatPerBar)
				-- 关闭小节振铃或只在准备阶段响铃 tiny默认开启准备阶段
				-- 仅有准备小节振铃优先级最高
				if self.VM.Prepare == 1 and self.VM.EffectPrepareOnly == 1 and CurBar < 2 then
					MusicPerformanceUtil.PlayMetroAccSound()
				elseif self.VM.Prepare == 1 and self.VM.EffectPrepareOnly == 1 and CurBar >= 2 then
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
		else
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

function PerformanceTinyMetronomeItemView:OnShow()
	self:ResetMetronome()
end

function PerformanceTinyMetronomeItemView:OnHide()
	self:ResetMetronome()
end

function PerformanceTinyMetronomeItemView:ResetMetronome()
	_G.TimerMgr:CancelTimer(self.Timer)
	self.Timer = nil
	
	if self.AnimSwing then
		self:StopAnimation(self.AnimSwing)
		self:PlayAnimation(self.Animstop, 0)
	end
	self.VM.ImgCircleYellowVisible = false
	self.VM.ImgCircleBlueVisible = false
end

function PerformanceTinyMetronomeItemView:OnRegisterUIEvent()

end

function PerformanceTinyMetronomeItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MusicPerformanceStartEnsemble, self.OnEventStartEnsemble)
end

function PerformanceTinyMetronomeItemView:OnEventStartEnsemble(Params)
	MusicPerformanceUtil.Log("PerformanceTinyMetronomeItemView:OnEventStartEnsemble()")
	self.VM:SetSaved()
	self.VM.BPM = _G.MusicPerformanceVM.EnsembleMetronome.BPM
	self.VM.BeatPerBar = _G.MusicPerformanceVM.EnsembleMetronome.Beat
	self.VM.Prepare = true

	-- 计算Offset
	local TimeDeltaS = (_G.TimeUtil.GetServerTimeMS() - _G.MusicPerformanceVM.BeginTimeMs) / 1000
	if TimeDeltaS < 0 then
		MusicPerformanceUtil.Wrn("PerformanceTinyMetronomeItemView:OnEventStartEnsemble() TimeDeltaS < 0")
		return
	end

	--local TimeOffset = math.floor(TimeDeltaS / 60)
	self:Play(TimeDeltaS)
end

function PerformanceTinyMetronomeItemView:OnRegisterBinder()
	local Binders = {
		{ "ImgCircleBlueVisible", UIBinderSetIsVisible.New(self, self.ImgCircleBlue, false, true) },
		{ "ImgCircleYellowVisible", UIBinderSetIsVisible.New(self, self.ImgCircleYellow, false, true) },
	}

	self:RegisterBinders(self.VM, Binders)

end

return PerformanceTinyMetronomeItemView