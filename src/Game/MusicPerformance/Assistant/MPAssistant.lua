--[[
Date: 2024-03-05 18:35:58
LastEditors: moody
LastEditTime: 2024-03-05 18:35:58
--]]
local LuaClass = require("Core/LuaClass")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MPAssistantScoreBoard = require("Game/MusicPerformance/Assistant/MPAssistantScoreBoard")
local MusicPerformanceSongVM = require("Game/Performance/VM/MusicPerformanceSongVM")

local MPAssistant = LuaClass()

function MPAssistant:Ctor()
	self:Clear()
	self.NoteEvents = {}
	self.ScoreBoard = MPAssistantScoreBoard.New()
	self:InitMusicScoreData()
end

function MPAssistant:InitMusicScoreData()
end

function MPAssistant:SetScoreDA(MusicScoreDA)
	if MusicScoreDA then
		self.MusicLength = MusicScoreDA.MusicLength
		self.TempoEvents = MusicScoreDA.TempoTrack.TempoEvents:ToTable()
		self.Tracks = MusicScoreDA.Tracks:ToTable()
	else
		self.MusicLength = 0
		self.TempoEvents = nil
		self.Tracks = nil
		MusicPerformanceUtil.Err("MPAssistant:StartMusicAssistant DA is nil.")
	end
end

function MPAssistant:Tick()
	if not self.IsWorking then
		return
	end

	self:TickAssistant()
end

function MPAssistant:TickAssistant()
	-- 更新时间
	self:UpdateCostTime(true)
	-- 更新在范围的Events
	self:UpdateActiveNoteEvents(true)
	-- 处理当前所有输入事件
	self:HandleClickEvents(true)
	-- 提示需要按下的按键
	self:UpdateFocus()

	self:CheckAssistantDone()
end

-- 积分逻辑的Tick 后续可能会做演奏比赛
function MPAssistant:TickScore()
	self:UpdateCostTime(false)
	local PrevScore = self.ScoreBoard:GetCurScore()

	 -- 结算超出判定时间的事件
	self:UpdateActiveNoteEvents()
	-- 处理当前所有输入事件
	self:HandleClickEvents()

	local CurScore = self.ScoreBoard:GetCurScore()
	-- 处理分数改变以及通知
	self:HandleScoreChange(PrevScore, CurScore)

	self:CheckAssistantDone()
end

function MPAssistant:UpdateCostTime(bPauseWhenTimeOut)
	local CurTimeMS = _G.TimeUtil.GetServerTimeMS()
	self.CostTimeMS = CurTimeMS - self.PrevTimeMS + self.CostTimeMS
	self.PrevTimeMS = CurTimeMS
	-- 保留演奏助手玩法的原逻辑，用于后续处理演奏游戏
	if not bPauseWhenTimeOut then
		return
	end

	-- 落下到按键区域没有响应时暂停
	local NoteEventsCount = self:GetNoteEventsCount()
	if self.CurCheckIndex <= NoteEventsCount then
		local NoteEvent = self:GetNoteEvent(self.CurCheckIndex)
		local CostLogicTimeMS = self:GetLogicTimeMS(self.CostTimeMS)
		local CheckTime = NoteEvent.Time
		-- 超时未按下
		if CostLogicTimeMS >= CheckTime then
			self.CostTimeMS = self:LogicTimeMSToCostTimeMS(CheckTime)
		end
	end

	if self.LastCostTimeMS == self.CostTimeMS then
		if self.IsWorking and not self.NoteItemDropPausing then
			self.NoteItemDropPausing = true -- 音符掉落暂停中状态
			self:NoteItemPause()
		end
	end
	self.LastCostTimeMS = self.CostTimeMS
end

function MPAssistant:CheckAssistantDone()
	local CostLogicTimeMS = self:GetLogicTimeMS(self.CostTimeMS)
	if CostLogicTimeMS >= (self.MusicLength + MPDefines.AssistantFallingDownConfig.AssistantDoneDelayTimeMS) then
		self:AssistantDone()
	end
end

function MPAssistant:HandleScoreChange(PrevScore, CurScore)
	if PrevScore ~= CurScore then
		local TotalScoreType, TotalScoreProg = self.ScoreBoard:GetTotalScore(CurScore, self.MaxScore)
		-- print("MP ", TotalScoreType, TotalScoreProg)
		_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantTotalScoreChanged, TotalScoreType, TotalScoreProg, CurScore)
	end
end

function MPAssistant:AssistantDone()
	self.IsDone = true
	self.IsWorking = false
	self:Clear()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantDone)
end

function MPAssistant:Pause()
	self.IsWorking = false
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantPause)
end

function MPAssistant:Stop()
	self:Clear()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantStop)
end

--恢复(IsFromPausePanel区别二种情况：暂停面板继续、上一个音符按下后)
function MPAssistant:Resume(IsFromPausePanel)
	if not self.IsDone and self.MusicLength and self.MusicLength > 0 then
		self.IsWorking = true
		self.PrevTimeMS = _G.TimeUtil.GetServerTimeMS()
		--如果是暂停界面恢复时，节拍器不能工作
		if not IsFromPausePanel then
			_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantResume, self.CostTimeMS)
		end
	end
end

--UI音符掉落暂停
function MPAssistant:NoteItemPause()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantPause)
end

--UI音符掉落继续
function MPAssistant:NoteItemResume()
	self.NoteItemDropPausing = false
	self:Resume(false)
end

-- function MPAssistant:Restart()
-- 	self:Clear(true)
-- 	self:Start()
-- end

function MPAssistant:GetMusicLength()
	return self.MusicLength
end

---@param TrackID : number 默认为1，目前只使用Track1，其他Track是伴奏
function MPAssistant:GetTempo(TrackID)
	TrackID = TrackID or 1
	return self.TempoEvents:Get(TrackID) or nil
end

---@param TrackID : number 默认为1，目前只使用Track1，其他Track是伴奏
function MPAssistant:GetNoteEvents(TrackID)
	TrackID = TrackID or 1
	return self.Tracks and self.Tracks[TrackID].NoteEvents or nil
end

function MPAssistant:GetNoteEvent(EventID, TrackID)
	TrackID = TrackID or 1
	if TrackID == 1 and self.NoteEvents[EventID] then
		-- 使用缓存，避免反复创建的开销
		return self.NoteEvents[EventID]
	end
	local Events = self:GetNoteEvents(TrackID)
	if Events and EventID <= Events:Length() then
		local Event = Events:Get(EventID)
		if TrackID == 1 then
			self.NoteEvents[EventID] = Event
		end
		return Event
	end
end

function MPAssistant:GetNoteEventsCount(TrackID)
	local NoteEvents = self:GetNoteEvents(TrackID)
	return NoteEvents and NoteEvents:Length() or 0
end

function MPAssistant:IsWorking()
	return self.IsWorking
end

function MPAssistant:StartMusicAssistant(SongData, IsLongClick, Rate)
	self.IsLongClick = IsLongClick
	self.SongData = SongData
	self.Rate = Rate
	self:Clear()
	local MusicScoreDA = _G.ObjectMgr:LoadObjectSync(string.format("MusicPerformanceScoreDataAsset'/Game/Assets/Audio/PerformanceAssistantMsb/msb/%s.%s'", SongData.Path, SongData.Path))
	-- self.MaxScore = self.ScoreBoard:GetMaxScore(self.SongData, IsLongClick)
	self:SetScoreDA(MusicScoreDA)
	self:Start()
end

function MPAssistant:Start()
	self.PrevTimeMS = _G.TimeUtil.GetServerTimeMS()
	self.IsWorking = true
end

function MPAssistant:Clear(IsKeepScoreData)
	self.PrevTimeMS = 0
	self.CostTimeMS = 0
	self.LastCostTimeMS = 0
	if not IsKeepScoreData then
		self.MusicLength = 0
		self.TempoEvents = nil
		self.Tracks = nil
	end

	self.IsWorking = false
	self.IsDone = false
	self.NoteItemDropPausing = false

	self.StartRangeIndex = 1
	self.CurCheckIndex = 1
	self.LastCheckIndex = 1 --主要用于长乐器LongRelease时的情况
	self.PendingInputEvents = {}
	self.NoteStates = {}
	self.NoteEvents = {}
	if self.ScoreBoard then
		self.ScoreBoard:Clear()
	end
end

function MPAssistant:MakeInputEvent(Tone, UIEventType)
	return {
		Tone = Tone,
		UIEventType = UIEventType
	}
end

function MPAssistant:AddInputEvent(Tone, UIEventType)
	if self.IsWorking then
		-- print("MPAssistant:AddInputEvent", Tone, UIEventType)
		table.insert(self.PendingInputEvents, self:MakeInputEvent(Tone, UIEventType))
	end
end

-- LogicTime是指乘以速率后的时间
function MPAssistant:GetLogicTimeMS(TimeMS)
	TimeMS = TimeMS or self.CostTimeMS
	return (TimeMS * self.Rate - MPDefines.AssistantFallingDownConfig.EarlyAppearOffsetMS)
end

-- LogicTime是指乘以速率后的时间
function MPAssistant:LogicTimeMSToCostTimeMS(LogicTimeMS)
	return (LogicTimeMS + MPDefines.AssistantFallingDownConfig.EarlyAppearOffsetMS) / self.Rate
end

function MPAssistant:GetMaxCheckTimeMS(LogicTimeMS)
	local EarlyAppearOffsetMS = MPDefines.AssistantFallingDownConfig.EarlyAppearOffsetMS
	local MaxCheckTimeMS = LogicTimeMS + MPDefines.PlayLimit * 1000 + EarlyAppearOffsetMS
	return MaxCheckTimeMS
end

function MPAssistant:UpdateActiveNoteEvents(bUIUpdateOnly)
	local LogicTimeMS = self:GetLogicTimeMS()
	local NoteEvents = self:GetNoteEvents()
	local EventCount = NoteEvents and NoteEvents:Length() or 0

	-- EndTime[i] < EndTime[i + 1]
	-- EndTime[i] - StartTime[i] <= PlayLimit * 1000
	-- 所以判断哪些Index需要UI响应最多进行到 EndTime[i] > LogicTimeMS + PlayLimit * 1000 + EarlyAppearOffsetMS 即可

	local EventIndex = _G.ObjectPoolMgr:AllocCommonTable()
	local MaxCheckTimeMS = self:GetMaxCheckTimeMS(LogicTimeMS)

	for i = self.StartRangeIndex, EventCount do
		local NoteEvent = self:GetNoteEvent(i)
		local EndTime = self.IsLongClick and (NoteEvent.Time + NoteEvent.Duration) or (NoteEvent.Time)
		if LogicTimeMS > EndTime then
			-- 结算超出判定时间的事件
			self.StartRangeIndex = i + 1
			if not bUIUpdateOnly then
				self:HandleTimeOutNoteEvent(i, NoteEvent)
			end
		elseif MaxCheckTimeMS < EndTime then
			break
		else
			-- 进行UI显示
			table.insert(EventIndex, i)
		end
	end

	-- 不使用事件驱动更新，因为事件会产生部分内存开销（数据拷贝/字符串）
	local AssistPanel = self:GetAssistantView()
	if AssistPanel then
		AssistPanel:OnAssistantUIItemRefresh(self, EventIndex, LogicTimeMS, self.IsLongClick)
	end
	_G.ObjectPoolMgr:FreeCommonTable(EventIndex)
end

-- 中止连击
function MPAssistant:ComboEnd()
	self.ScoreBoard:ClearComboCount()
end

function MPAssistant:GetToneBase(Tone)
	return Tone % MPDefines.KeyDefines.KEY_MAX
end

---@param IsToneFuzzyMatch 是否进行模糊匹配
function MPAssistant:IsToneMatch(Tone1, Tone2, IsToneFuzzyMatch)
	if IsToneFuzzyMatch then
		return self:GetToneBase(Tone1) == self:GetToneBase(Tone2)
	else
		return Tone1 == Tone2
	end
end


function MPAssistant:FindMatchedNoteEvent(ClickEvent, IsToneFuzzyMatch)
	local LogicTimeMS = self:GetLogicTimeMS()
	local NoteEvents = self:GetNoteEvents()
	local EventCount = NoteEvents and NoteEvents:Length() or 0

	for i = self.StartRangeIndex, EventCount do
		local NoteEvent = self:GetNoteEvent(i)
		-- 直到超出范围
		if not self:IsInCheckRange(LogicTimeMS, NoteEvent) then
			return nil
		end

		if self:IsToneMatch(NoteEvent.Tone, ClickEvent.Tone, IsToneFuzzyMatch) then
			if self.ScoreBoard:IsUnhandled(i, ClickEvent.UIEventType) then
				return i, NoteEvent
			end
		end
	end

	return nil
end

function MPAssistant:HandleTimeOutNoteEvent(NoteIndex, NoteEvent)
	-- print("MPAssistant:HandleTimeOutNoteEvent")
	
	self.ScoreBoard:HandleTimeOutNoteEvent(self.IsLongClick, NoteIndex, NoteEvent)
end

-- 处理输入事件的积分与消息通知
function MPAssistant:HandleNoteEvent(InputEvent, NoteEventIndex, NoteEvent)
	-- print("MPAssistant:HandleNoteEvent", table.tostring(InputEvent), NoteEventIndex, table.tostring(NoteEvent))
	local ScoreType = self.ScoreBoard:CalcScoreType(self:GetLogicTimeMS(), InputEvent.UIEventType, NoteEvent)
	self.ScoreBoard:SetScoreType(NoteEventIndex, InputEvent.UIEventType, ScoreType)
end

function MPAssistant:HandleClickEvents(bHandleCurEventOnly)
	if not self.IsWorking then
		return
	end

	for _, InputEvent in ipairs(self.PendingInputEvents) do
		if bHandleCurEventOnly then
			self:HandleCurEvent(InputEvent)
		else
			self:HandleMatchInput(InputEvent)
		end
	end

	_G.TableTools.ClearTable(self.PendingInputEvents)
end

function MPAssistant:HandleMatchInput(InputEvent)
	local NoteEventIndex, MatchedNoteEvent = self:FindMatchedNoteEvent(InputEvent)
	--print("MPAssistant:HandleClickEvents", MatchedNoteEvent)
	if MatchedNoteEvent then
		self:HandleNoteEvent(InputEvent, NoteEventIndex, MatchedNoteEvent)
	end
end

function MPAssistant:GetCheckStartTimeMS(EventTimeMS)
	return EventTimeMS - MPDefines.AssistantFallingDownConfig.CheckTimeRangeMS
end

function MPAssistant:HandleCurEvent(InputEvent)
	local UIEventType = InputEvent.UIEventType
	local LogicTimeMS = self:GetLogicTimeMS()
	if UIEventType == MPDefines.UIEventType.LongRelease then
		if self.LastCheckIndex ~= self.CurCheckIndex then
			self.LastCheckIndex = self.CurCheckIndex
			-- 释放时，将Cur之前的所有和Event有相同Tone的置灰
			_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantItemUpdate, LogicTimeMS, self.LastCheckIndex, InputEvent.Tone, false)
			self:NoteItemResume()
		end
	elseif UIEventType ~= MPDefines.UIEventType.None then
		local CurEvent = self:GetNoteEvent(self.CurCheckIndex)
		if CurEvent and CurEvent.Tone == InputEvent.Tone and LogicTimeMS >= self:GetCheckStartTimeMS(CurEvent.Time) then
			self.LastCheckIndex = self.CurCheckIndex
			self.CurCheckIndex = self.CurCheckIndex + 1
			_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceAssistantItemUpdate, LogicTimeMS, self.CurCheckIndex, InputEvent.Tone, true)
			self:NoteItemResume()
		end
	end
end

function MPAssistant:GetAssistantView()
	local AssistPanel = _G.UIViewMgr:FindVisibleView(_G.UIViewID.PerformanceAssistantPanelView)
	return AssistPanel
end

function MPAssistant:UpdateFocus()
	local CurEvent = self:GetNoteEvent(self.CurCheckIndex)
	if CurEvent then
		local LogicTimeMS = self:GetLogicTimeMS()
		if LogicTimeMS >= self:GetCheckStartTimeMS(CurEvent.Time) then
			local AssistPanel = self:GetAssistantView()
			if AssistPanel then
				AssistPanel:OnAssistantItemFocus(self.CurCheckIndex)
			end
		end
	end
end

function MPAssistant:IsInCheckRange(LogicTimeMS, NoteEvent)
	if not self.IsWorking then
		return false
	end

	local StartTimeMS = NoteEvent.Time
	local StartRangeTimeMS = StartTimeMS - self.ScoreBoard:GetCheckTimeRange()
	-- 短键只需要检查是否在Start区间内
	if not self.IsLongClick then
		return LogicTimeMS >= StartRangeTimeMS and LogicTimeMS <= StartTimeMS
	end

	local EndTimeMS = NoteEvent.Time + NoteEvent.Duration
	-- 长键需要检查是否在start和end区间内
	return LogicTimeMS >= StartRangeTimeMS and LogicTimeMS <= EndTimeMS
end

return MPAssistant