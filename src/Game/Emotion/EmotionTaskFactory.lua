--[[
Date: 2021-12-01 
LastEditors: moody
LastEditTime: 2021-12-01 23:33:03
--]]
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local EmotionTaskBase = require("Game/Emotion/EmotionTaskBase")
local HoldWeaponTask = require("Game/Emotion/Tasks/HoldWeaponTask")
local SitTask = require("Game/Emotion/Tasks/SitTask")
local EmtionCfg = require("TableCfg/EmotionCfg")

local EmotionTaskFactory = LuaClass()

function EmotionTaskFactory:CreateTask(Params)
	local FromID = Params.ULongParam1
	local ToID = Params.ULongParam2
	local EmotionID = Params.IntParam1
	local bForceLoop = Params.BoolParam1
	local EmotionMgr = _G.EmotionMgr

	local Task = nil
	if EmotionMgr.IsHoldWeaponID(EmotionID) then  --持有武器（ID = 116）
		Task = HoldWeaponTask.New()
	elseif EmotionMgr.IsSitEmotionID(EmotionID) then  --坐下（ID = 50、52）
		Task = SitTask.New()
	else
		Task = EmotionTaskBase.New()
	end

	Task.FromID = FromID
	Task.EmotionID = EmotionID
	Task.ToID = ToID
	Task.bForceLoop = bForceLoop
	Task.IDType = Params.IDType
	local Cfg = EmtionCfg:FindCfgByKey(Task.EmotionID)
	if Cfg then
		Task.MotionType = tonumber(Cfg.MotionType)
		Task.EmotionName = tonumber(Cfg.MotionName)
		Task.IsBattleEmotion = tonumber(Cfg.IsBattleEmotion)
		Task.IsTurnToTarget = tonumber(Cfg.IsTurnToTarget)
		Task.bOpenHeightAdjust = tonumber(Cfg.IsHeightAdjust) ~= 0
		Task.LookAtRule = tonumber(Cfg.LookAtRule)
	end

	Task.bIsLastFace = EmotionMgr:IsBodyToFacePlaying(FromID)

	return Task
end

return EmotionTaskFactory