---
--- Author: bowxiong
--- DateTime: 2024-11-09 10:00
--- Description: 单独处理模块解锁和便捷使用的消息提示, 这些提示由自己的队列管理
---

local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local TipsUnit = require("Game/TipsQueue/TipsUnit")
local TipsQueueDefine = require("Game/TipsQueue/TipsQueueDefine")

---@class CustomTipsUnit
---
local CustomTipsUnit = LuaClass(TipsUnit)

function CustomTipsUnit:Ctor(Config)
	self.bIsPlay = false
end

function CustomTipsUnit:PostPlay()
	self.bIsPlay = true
	if self.Type == ProtoRes.tip_class_type.TIP_EASY_USE then
		-- 便捷使用不做判断
		self.bIsPlay = false
	elseif self.Type == ProtoRes.tip_class_type.TIP_SYS_UNLOCK or self.Type == ProtoRes.tip_class_type.TIP_SKILL_UNLOCK then
		self.bIsPlay =  _G.ModuleOpenMgr:IsPlayingMotion()
	end
end

---BeginPlay 模块解锁和便捷使用都有自己的队列, 这里直接返回false, 一次回调完所有的提示
---@param NowTime number
---@param bIsLast boolean
---@return boolean @消息提示是否正常播放
function CustomTipsUnit:BeginPlay(NowTime, bIsLast)
	if self.LifeTime > 0 and (NowTime - self.AddTime) > self.LifeTime then
		-- 已经是无效的TipsUnit
		return false
	end
	if self.OnPlayCallback then
		self.OnPlayCallback(self.Params)
	end
	-- 只处理最后一个提示
	if not bIsLast then
		return false
	end
	self:PostPlay()
	self.StartTime = NowTime
	return self.bIsPlay
end

---Update
---@param NowTime number
---@param bInterupt boolean @是否需要提前结束
---@return boolean @消息提示是否结束
function CustomTipsUnit:Update(NowTime, bInterupt)
	-- 如果已经播放了, 等待配置的ShowTime结束后再检查
	local DeltaTime = NowTime - self.StartTime
	local LimitTime = self.Duration
	if bInterupt and self.bEnableInterrupt then
		LimitTime = self.LeastTime
	end
	if DeltaTime < LimitTime then
		return false
	end
	-- 虽然配置的时间已经结束了, 但是提示可能没有结束
	if self.Type == ProtoRes.tip_class_type.TIP_EASY_USE then
		-- 便捷使用不做判断
		self.bIsPlay = false
	elseif self.Type == ProtoRes.tip_class_type.TIP_SYS_UNLOCK or self.Type == ProtoRes.tip_class_type.TIP_SKILL_UNLOCK then
		self.bIsPlay = _G.ModuleOpenMgr:IsPlayingMotion()
	end
	return not self.bIsPlay
end

---BeginPlay
---@param NowTime number
---@param StopReason number @消息提示结束原因
---@param bForce boolean @强制打断, 不考虑LeastTime
---@return boolean @消息提示是否正常播放
function CustomTipsUnit:StopTips(NowTime, StopReason, bForce)
	if self.Type == ProtoRes.tip_class_type.TIP_SYS_UNLOCK or self.Type == ProtoRes.tip_class_type.TIP_SKILL_UNLOCK then
		if StopReason == TipsQueueDefine.STOP_REASON.PLAYSEQUENCE or StopReason == TipsQueueDefine.STOP_REASON.PWORLDCHANGE then
			_G.ModuleOpenMgr:ForceClearMotion()
		end
	end
	return not self.bIsPlay
end

return CustomTipsUnit