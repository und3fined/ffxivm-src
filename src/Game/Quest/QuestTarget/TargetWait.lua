---
--- Author: lydianwang
--- DateTime: 2022-02-14
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local TimeUtil = require("Utils/TimeUtil")

local QuestHelper = require("Game/Quest/QuestHelper")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local QuestMgr = nil
local QuestRegister = nil

---@class TargetWait
local TargetWait = LuaClass(TargetBase, true)

function TargetWait:Ctor(_, Properties)
    self.WaitSecond = tonumber(Properties[1])
    self.bIsOnlineTime = (tonumber(Properties[2]) == 1)

	self.SubTimerID = nil
	self.TargetVMItem = nil
	self.ChapterID = nil

	QuestMgr = _G.QuestMgr
	QuestRegister = QuestMgr.QuestRegister
end

function TargetWait:DoStartTarget()
	local QuestCfgItem = QuestHelper.GetQuestCfgItem(self.QuestID)
	if QuestCfgItem then
		self.ChapterID = QuestCfgItem.ChapterID
	end

	local StartTimeMS = 0
	if  self.bIsOnlineTime and (self.Count ~= 0) then
		StartTimeMS = QuestMgr.LoginServerTimeMS
	else
		local Quest = QuestMgr.QuestMap[self.QuestID]
		if Quest ~= nil then
			StartTimeMS = Quest.AcceptTimeMS
		else
			QuestHelper.PrintQuestError("TargetWait %d get invalid QuestID %d", self.TargetID, self.QuestID)
		end
	end

	local CurrTime = math.max(0,
		math.floor((TimeUtil.GetServerTimeMS() - StartTimeMS) / 1000))

	-- 由于Count会发送给后台，用Count代表目标在线时间进度，单位为秒
	if self.bIsOnlineTime then
		CurrTime = CurrTime + self.Count
	end

	if CurrTime >= self.WaitSecond then
		QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
		return
	end

	self.SubTimerID = QuestRegister:RegisterPerSecondSubTimer(
		self,
		CurrTime,
		self.WaitSecond,
		self.CallbackOnTimer,
		self.CallbackOnStop)
end

function TargetWait:DoClearTarget()
	if self.SubTimerID ~= nil then
		QuestRegister:UnRegisterPerSecondSubTimer(self.SubTimerID)
		self.SubTimerID = nil
	end
end

function TargetWait:CallbackOnTimer(CurrTime)
	if self.TargetVMItem == nil then
		self.TargetVMItem = QuestMainVM:GetTargetVM(self.ChapterID, self.TargetID)
		if self.TargetVMItem == nil then
			QuestHelper.PrintQuestError("TargetWait %d can't find its TargetVM", self.TargetID)
			return
		end
	end
	self.TargetVMItem:UpdateCountdown(self.WaitSecond - CurrTime)
end

function TargetWait:CallbackOnStop(bFinished)
	if bFinished then
		QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
	end

	if self.TargetVMItem == nil then
		self.TargetVMItem = QuestMainVM:GetTargetVM(self.ChapterID, self.TargetID)
		if self.TargetVMItem == nil then return end
	end
	self.TargetVMItem:UpdateCountdown(nil)
end

return TargetWait