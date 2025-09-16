--[[
演奏助手计分板
LastEditors: moody
--]]
local LuaClass = require("Core/LuaClass")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local MusicScoreCfg = require("TableCfg/MusicScoreCfg")
local MusicTotalScoreCfg = require("TableCfg/MusicTotalScoreCfg")
local MathUtil = require("Utils/MathUtil")
local ProtoRes = require("Protocol/ProtoRes")

local MPAssistantScoreBoard = LuaClass()

function MPAssistantScoreBoard:Ctor()
	self:InitScoreCfg()
	self:Clear()
end

function MPAssistantScoreBoard:InitScoreCfg()
	self.CheckTimeRange = 0
	local ScoreCfg = MusicScoreCfg:FindAllCfg("ID > 0")
	self.ScoreLevels = {}
	for _, ScoreLevel in pairs(ScoreCfg) do
		self.ScoreLevels[ScoreLevel.ID] = ScoreLevel
		self.CheckTimeRange = math.max(self.CheckTimeRange, ScoreLevel.Time[2])
	end
	
	self.TotalScoreLevels = {}
	local TotalScoreCfg = MusicTotalScoreCfg:FindAllCfg("Level > 0")
	for _, TotalScoreLevel in pairs(TotalScoreCfg) do
		self.TotalScoreLevels[TotalScoreLevel.Level] = TotalScoreLevel
	end
end

function MPAssistantScoreBoard:GetMaxScore(SongCfg, IsLongClick)
	if SongCfg then
		local SingleMaxScore = self.ScoreLevels[MPDefines.AssistantScoreType.Perfect].BaseScore or 0
		print(table.tostring( SongCfg.NoteShort, SongCfg.NoteLong))
		return (IsLongClick and SongCfg.NoteShort or SongCfg.NoteLong) * SingleMaxScore
	end
	return nil
end

---@return number 返回总分类型及到下一个类型的进度百分比
function MPAssistantScoreBoard:GetTotalScore(CurScore, MaxScore)
	local Prog = CurScore / MaxScore
	if MathUtil.IsNearlyEqual(1, Prog) then
		return ProtoRes.MusicAwardRank.MusicAwardRank_SPP, 1.0
	end

	for Level = ProtoRes.MusicAwardRank.MusicAwardRank_SP, ProtoRes.MusicAwardRank.MusicAwardRank_LAST - 1 do
		local RangeMin = self.TotalScoreLevels[Level].Coefficient
		
		if Prog >= RangeMin then
			local RangeMax = self.TotalScoreLevels[Level - 1].Coefficient
			local CurLevelPercent = (Prog - RangeMin) / (RangeMax - RangeMin)
			return Level, CurLevelPercent
		end
	end

	return nil
end

function MPAssistantScoreBoard:GetCheckTimeRange()
	return self.CheckTimeRange
end

function MPAssistantScoreBoard:Clear()
	self.ScoreList = {}
	self.ScoreTypeCounter = {}
	self.ComboCount = 0
	self.MaxComboCount = 0
	self.Score = 0
end

function MPAssistantScoreBoard:IsValidScoreType(ScoreType)
	return ScoreType ~= nil and ScoreType ~= MPDefines.AssistantScoreType.None
end

function MPAssistantScoreBoard:IsUnhandled(ScoreIndex, UIEventType)
	local ScoreState = self.ScoreList[ScoreIndex]
	if ScoreState == nil then
		return true
	end

	if UIEventType == MPDefines.UIEventType.LongRelease then
		if not self:IsValidScoreType(ScoreState.ClickScoreType) then
			-- 若要响应释放事件，先要按下事件被响应
			return false
		end

		return not self:IsValidScoreType(ScoreState.LongReleaseScoreType)
	end

	return not self:IsValidScoreType(ScoreState.ClickScoreType)
end

function MPAssistantScoreBoard:SetComboCount(Count)
	self.ComboCount = Count
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantComboChanged, Count)
end

function MPAssistantScoreBoard:IncreaseComboCount()
	self:SetComboCount(self.ComboCount + 1)
	if self.ComboCount > self.MaxComboCount then
		self.MaxComboCount = self.ComboCount
	end
end

function MPAssistantScoreBoard:ClearComboCount()
	self:SetComboCount(0)
end

function MPAssistantScoreBoard:GetComboCount()
	return self.ComboCount
end

function MPAssistantScoreBoard:GetMaxComboCount()
	return self.MaxComboCount
end

function MPAssistantScoreBoard:SetScoreType(ScoreIndex, UIEventType, ScoreType)
	local ScoreState = self.ScoreList[ScoreIndex]
	if ScoreState == nil then
		ScoreState = {}
		self.ScoreList[ScoreIndex] = ScoreState
	end

	if UIEventType == MPDefines.UIEventType.LongRelease then
		ScoreState.LongReleaseScoreType = ScoreType
	else
		ScoreState.ClickScoreType = ScoreType
	end

	if self:IsValidScoreType(ScoreType) then
		if ScoreType == MPDefines.AssistantScoreType.Bad or ScoreType == MPDefines.AssistantScoreType.Miss then
			self:ClearComboCount()
		else
			self:IncreaseComboCount()
		end
		self.ScoreTypeCounter[ScoreType] = (self.ScoreTypeCounter[ScoreType] or 0) + 1

		print("SendEvent(_G.EventID.MusicPerformanceAssistantItemScoreUpdate", ScoreIndex, UIEventType, MPDefines.AssistantFallingDownConfig.AnimCommentNames[ScoreType])
		_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantItemScoreUpdate, ScoreIndex, UIEventType, ScoreType)
	end

	self:AddScore(ScoreType)
end

function MPAssistantScoreBoard:AddScore(ScoreType)
	local ScoreLevel = self.ScoreLevels[ScoreType]
	if ScoreLevel then
		self.Score = self.Score + ScoreLevel.DeterminationCoefficient * ScoreLevel.BaseScore
	end
end

function MPAssistantScoreBoard:GetCurScore()
	return self.Score
end

function MPAssistantScoreBoard:CalcScoreType(LogicTimeMs, UIEventType, NoteEvent)
	local NoteTimeMs
	if UIEventType == MPDefines.UIEventType.LongRelease then
		NoteTimeMs = NoteEvent.Time + NoteEvent.Duration
	else
		NoteTimeMs = NoteEvent.Time
	end

	return self:CalcScoreTypeInternal(LogicTimeMs, UIEventType, NoteTimeMs)
end

function MPAssistantScoreBoard:HandleTimeOutNoteEvent(IsLongClick, NoteIndex, NoteEvent)
	if not IsLongClick then
		if self:IsUnhandled(NoteIndex, MPDefines.UIEventType.ShortClick) then
			self:SetScoreType(NoteIndex, MPDefines.UIEventType.ShortClick, MPDefines.AssistantScoreType.Miss)
		end
	else
		local IsEnterUnhandled = self:IsUnhandled(NoteIndex, MPDefines.UIEventType.LongClick)
		local IsEndUnhandled = self:IsUnhandled(NoteIndex, MPDefines.UIEventType.LongRelease)

		if not IsEnterUnhandled then
			if IsEndUnhandled then
				-- 长按超时算作perfect
				self:SetScoreType(NoteIndex, MPDefines.UIEventType.LongRelease, MPDefines.AssistantScoreType.Perfect)
			end
		else
			-- 未首判，则全视作Miss
			self:SetScoreType(NoteIndex, MPDefines.UIEventType.LongClick, MPDefines.AssistantScoreType.Miss)
			self:SetScoreType(NoteIndex, MPDefines.UIEventType.LongRelease, MPDefines.AssistantScoreType.Miss)
		end
	end
end

function MPAssistantScoreBoard:CalcScoreTypeInternal(LogicTimeMs, UIEventType, NoteTime)
	local DeltaTimeMs = NoteTime - LogicTimeMs
	if DeltaTimeMs < 0 then
		if UIEventType ~= MPDefines.UIEventType.LongClick then
			MusicPerformanceUtil.Err("MPAssistantScoreBoard:CalcScoreTypeInternal DeltaTimeMs < 0")
	    	return MPDefines.AssistantScoreType.None
		else
			-- 只有首判事件才会出现DeltaTimeMs < 0 的情况
			-- 此时首判为Bad，同时开始等待尾判
			return MPDefines.AssistantScoreType.Bad
		end
	end

	print("Assistant DeltaTime", DeltaTimeMs)
	for Index, ScoreLevel in pairs(self.ScoreLevels) do
		if ScoreLevel.Time[1] <= DeltaTimeMs and ScoreLevel.Time[2] >= DeltaTimeMs then
			print("Assistant Index", Index)
			return Index
		end
	end

	if UIEventType == MPDefines.UIEventType.LongRelease then
		-- 只有Release的情况可能进入了检测区域但是又不满足任何得分情况，此时视作Miss
		return MPDefines.AssistantScoreType.Miss
	end
	-- 进入了这里按正常流程是不可能没有匹配到任何等级的
	MusicPerformanceUtil.Err("MPAssistantScoreBoard:CalcScoreTypeInternal Not Match any score level.")
	return MPDefines.AssistantScoreType.None
end

return MPAssistantScoreBoard