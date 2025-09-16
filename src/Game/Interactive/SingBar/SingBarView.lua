---
--- Author: chriswang
--- DateTime: 2021-12-01 10:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")

---@class SingBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProgressSingBar UProgressBar
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SingBarView = LuaClass(UIView, true)

function SingBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProgressSingBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SingBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SingBarView:OnInit()

end

function SingBarView:OnDestroy()

end

function SingBarView:OnShow()
	_G.InteractiveMgr:SetMajorIsinging(true)
end

function SingBarView:OnHide()
	self:CloseSingTimer()
	_G.InteractiveMgr:SetMajorIsinging(false)
end

function SingBarView:OnRegisterUIEvent()

end

function SingBarView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorSingBarBreak, self.OnMajorSingBarBreak)
end

function SingBarView:OnRegisterBinder()

end

function SingBarView:CloseSingTimer()
	if self.SingTimerID then
		TimerMgr:CancelTimer(self.SingTimerID)
		self.SingTimerID = nil
	end
end

function SingBarView:UpdateProcessBar()
	local PassTime = TimeUtil.GetLocalTimeMS() - self.BeginTime
	if PassTime >= self.SingTime then
		self:CloseSingTimer()
		self:Hide()

		FLOG_INFO("SingBarView:UpdateProcessBar, OnMajorSingOver: " .. tostring(PassTime / self.SingTime) .. " time: " .. TimeUtil.GetLocalTimeMS())

		--正常结束
		_G.SingBarMgr:OnMajorSingOver(MajorUtil.GetMajorEntityID(), false)
		return
	end

	local Percent = PassTime / self.SingTime
	if Percent > 0.99 then
		Percent = 1
	end

	-- FLOG_INFO("SingBar percent: " .. tostring(Percent) .. " time: " .. TimeUtil.GetLocalTimeMS() .. " passTime: " .. PassTime .. "Sing: " .. self.SingTime)
	self.ProgressSingBar:SetPercent(Percent)
	_G.InteractiveMgr:SetMajorIsinging(true)
end

--参数是ms
--时间加长一点点
function SingBarView:BeginSingBar(SingTime, SingName)
	self.SingTime = SingTime + _G.SingBarMgr.SingLifeAddTime

	if SingName then
		self.SingBarName:SetText(SingName)
	end

	self:CloseSingTimer()
	if not self.SingTimerID then
		self.SingTimerID = TimerMgr:AddTimer(self, self.UpdateProcessBar, 0, 0.02, 0)
	end

	self.ProgressSingBar:SetPercent(0)

	FLOG_INFO("SingBar BeginSingBar time: " .. TimeUtil.GetLocalTimeMS() .. " singTime: " .. SingTime)
	self.BeginTime = TimeUtil.GetLocalTimeMS()
end

--对于打断，则调用专有接口
function SingBarView:BreakSingBar()
	self:CloseSingTimer()
	self:Hide()
end

function SingBarView:OnMajorSingBarBreak()
	self:BreakSingBar()
end

return SingBarView