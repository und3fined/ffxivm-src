---
--- Author: bowxiong
--- DateTime: 2024-11-25 15:30
--- Description: 单独处理新手引导提示
---

local LuaClass = require("Core/LuaClass")
local TipsUnit = require("Game/TipsQueue/TipsUnit")

local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr

---@class TutorialTipsUnit
---
local TutorialTipsUnit = LuaClass(TipsUnit)

function TutorialTipsUnit:Ctor(Config)
	self.bIsPlay = false
end

---BeginPlay 提示触发之后判断一下是否通过了新手引导的检测
---@param NowTime number
---@param bIsLast boolean
---@return boolean @消息提示是否正常播放
function TutorialTipsUnit:BeginPlay(NowTime, bIsLast)
	if self.LifeTime > 0 and (NowTime - self.AddTime) > self.LifeTime then
		-- 已经是无效的TipsUnit
		return false
	end
	if self.OnPlayCallback then
		self.OnPlayCallback(self.Params)
	end
	self.bIsPlay = self:CheckTutorialState()
	return self.bIsPlay
end

---Update
---@param NowTime number
---@param bInterupt boolean @是否需要提前结束
---@return boolean @消息提示是否结束
function TutorialTipsUnit:Update(NowTime, bInterupt)
	-- 新手引导不允许被别的提示打断, 判断当前是否还在播放新手引导
	self.bIsPlay = self:CheckTutorialState()
	return not self.bIsPlay
end

---StopTips
---@param NowTime number
---@param StopReason number @消息提示结束原因
---@param bForce boolean @强制打断, 不考虑LeastTime
---@return boolean @消息提示是否正常结束
function TutorialTipsUnit:StopTips(NowTime, StopReason, bForce)
	return not self.bIsPlay
end

---CheckTutorialState 检查新手引导相关提示是否在播放
---@return boolean @新手引导或者新手指南是否播放
function TutorialTipsUnit:CheckTutorialState()
	return (not _G.NewTutorialMgr:CanPlayTutorial()) or
		(not _G.TutorialGuideMgr:IsPlayQueueEmpty()) or
		UIViewMgr:IsViewVisible(UIViewID.TutorialEntrancePanel) or
		UIViewMgr:IsViewVisible(UIViewID.TutorialGuideShowPanel)
end

return TutorialTipsUnit