---
--- Author: haialexzhou
--- DateTime: 2021-05-11 15:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ReviveFloatButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFloat UButton
---@field ProgressBarTime URadialImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ReviveFloatButtonView = LuaClass(UIView, true)

function ReviveFloatButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFloat = nil
	--self.ProgressBarTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ReviveFloatButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ReviveFloatButtonView:OnInit()

end

function ReviveFloatButtonView:OnDestroy()

end

function ReviveFloatButtonView:OnShow()
	if (_G.ReviveMgr == nil or _G.ReviveMgr.ReviveInfo == nil) then
		return
	end

	self.MaxProcessTime = (_G.ReviveMgr.ReviveInfo.RescueDeadline - _G.ReviveMgr.ReceivedReviveInfoTime) * 1000
	self.RescueDeadline = _G.ReviveMgr.ReviveInfo.RescueDeadline * 1000

	self:OnCountdown()
end

function ReviveFloatButtonView:OnHide()

end

function ReviveFloatButtonView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFloat, self.OnClickButtonFloat)
end

function ReviveFloatButtonView:OnRegisterGameEvent()

end

function ReviveFloatButtonView:OnRegisterTimer()
	self:RegisterTimer(self.OnCountdown, 0, 0.1, 0)
end

function ReviveFloatButtonView:OnRegisterBinder()

end

function ReviveFloatButtonView:OnClickButtonFloat()
	_G.UIViewMgr:ShowView(_G.UIViewID.BeReviveView)
	self:Hide()
end

function ReviveFloatButtonView:OnCountdown()
	if (self.ProgressBarTime == nil) then
		return
	end
	
	local LeftTime = self.RescueDeadline - _G.TimeUtil.GetServerTimeMS()
	local Percent = (LeftTime >= 0 and LeftTime or 0) / self.MaxProcessTime

	self.ProgressBarTime:SetPercent(Percent)

	if LeftTime <= 0 then
		self:OnReject()
	end
end

function ReviveFloatButtonView:OnReject()
	_G.ReviveMgr:SendRevive(false)
	self:Hide()
end

return ReviveFloatButtonView