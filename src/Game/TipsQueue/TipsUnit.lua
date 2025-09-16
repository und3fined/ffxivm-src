---
--- Author: bowxiong
--- DateTime: 2024-11-08 15:01
--- Description: 处理单个消息提示的通用逻辑, 如果有需要特殊处理的消息类型, 自行实现子类
---

local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")

---@class TipsUnit
local TipsUnit = LuaClass()

function TipsUnit:Ctor(Config)
	self.Type = Config and Config.Type or ProtoRes.tip_class_type.TIP_NONE 	--默认类型为TIP_NONE
	self.OnPlayCallback = Config and Config.Callback 						--开始播放提示的回调
	self.OnUpdateCallback = Config and Config.UpdateCallback 				--刷新提示的回调
	self.OnStopCallback = Config and Config.StopCallback 					--提示结束的回调, 包括正常播放结束、被各种原因中断
	self.Params = Config and Config.Params									--提示回调的参数
	self.Priority = Config and Config.Priority or 0 						--提示优先级, 默认最高
	self.Key = Config and Config.Key										--提示的Key值, 判断是否为重复的提示
	self.AddTime = TimeUtil.GetGameTimeMS() 								--记录提示加入队列的时间(ms)
	self.StartTime = 0 														--记录提示的开始时间(ms)
	local Duration = Config and Config.Duration or 3						--提示的持续时间, 默认3秒
	local LifeTime = Config and Config.LifeTime or 0 						--提示的有效时间, 默认能够立刻停止
	local LeastTime = Config and Config.LeastTime or Duration				--提示的最少显示时间, 默认和持续时间一致
	self.Duration = 1000 * Duration
	self.LifeTime = 1000 * LifeTime
	self.LeastTime = 1000 * LeastTime
	self.bEnableInterrupt = self.LeastTime < self.Duration
end

---RefreshTimer
function TipsUnit:RefreshTimer()
	if self.StartTime > 0 then
		self.StartTime = TimeUtil.GetGameTimeMS()
	else
		self.AddTime = TimeUtil.GetGameTimeMS()
	end
end

---IsStart
---@return boolean @消息提示是否开始播放
function TipsUnit:IsStart()
	return self.StartTime > 0
end

---IsEqual
---@return boolean @消息提示是否重复
function TipsUnit:IsEqual(Tips)
	if self.Key and Tips.Key then
		return self.Key == Tips.Key
	end
	return false
end

---IsStart
---@return boolean @消息提示是否开始播放
function TipsUnit:IsComplete(NowTime)
	return self:IsStart() and (NowTime - self.StartTime) >= self.Duration
end

---BeginPlay
---@param NowTime number
---@param bIsLast boolean @是否为当前类型队列的最后一个, 有些情况下需要批量处理所有同类型的提示
---@return boolean @消息提示是否正常播放
function TipsUnit:BeginPlay(NowTime, bIsLast)
	-- 只在Tip开始播放的时候判断LifeTime
	if self.LifeTime > 0 and (NowTime - self.AddTime) > self.LifeTime then
		-- 已经是无效的TipsUnit
		return false
	end
	if self.OnPlayCallback == nil then
		return false
	end
	self.StartTime = NowTime
	local bRet = self.OnPlayCallback(self.Params)
	return (bRet == nil) or bRet
end

---Update
---@param NowTime number
---@param bInterupt boolean @是否需要提前结束
---@return boolean @消息提示是否结束
function TipsUnit:Update(NowTime, bInterupt)
	local DeltaTime = NowTime - self.StartTime
	local LimitTime = self.Duration
	if bInterupt and self.bEnableInterrupt then
		LimitTime = self.LeastTime
	end
	if DeltaTime >= LimitTime then
		return true
	end
	if self.OnUpdateCallback then
		local bRet = self.OnUpdateCallback(DeltaTime, self.Params)
		if bRet == true then
			return true
		end
	end
	return false
end

---BeginPlay
---@param NowTime number
---@param StopReason number @消息提示结束原因
---@param bForce boolean @强制结束, 不考虑LeastTime
---@return boolean @消息提示是否可以结束
function TipsUnit:StopTips(NowTime, StopReason, bForce)
	local DeltaTime = NowTime - self.StartTime
	if self.OnStopCallback == nil then
		-- 如果没有配置结束回调, 轮播队列没办法停止提示, 只能继续播完
		return DeltaTime >= self.Duration
	end
	-- 消息提示还没开始
	if not self:IsStart() then
		return self.LeastTime <= 0
	end

	local LimitTime = self.bEnableInterrupt and self.LeastTime or self.Duration
	if bForce or DeltaTime >= LimitTime then
		local bRet = self.OnStopCallback(DeltaTime, StopReason, self.Params)
		return bRet
	end
	-- 消息提示此时还不允许被打断
	return false
end

return TipsUnit