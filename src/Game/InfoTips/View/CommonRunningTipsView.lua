---
--- Author: loiafeng
--- DateTime: 2024-08-19 10:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommonRunningTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommTextSlide CommTextSlideView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonRunningTipsView = LuaClass(UIView, true)

function CommonRunningTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommTextSlide = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonRunningTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTextSlide)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonRunningTipsView:OnInit()
	FLOG_INFO("loiafeng Debug: CommonRunningTipsView:OnInit()")

	self.TipsQueue = {}
	self.IsRunning = false
end

function CommonRunningTipsView:OnDestroy()
	self.IsRunning = false
	self.TipsQueue = {}
end

function CommonRunningTipsView:OnShow()

end

function CommonRunningTipsView:OnHide()

end

function CommonRunningTipsView:OnRegisterUIEvent()

end

function CommonRunningTipsView:OnRegisterGameEvent()

end

function CommonRunningTipsView:OnRegisterBinder()

end

---@private
function CommonRunningTipsView:OnRunningComplete()
	FLOG_INFO("loiafeng Debug: CommonRunningTipsView:OnRunningComplete()")

	self.IsRunning = false
	self:TryShowContent()
end

---@private
function CommonRunningTipsView:TryShowContent()
	if self.IsRunning then
		return
	end

	if table.empty(self.TipsQueue) then
		self:Hide()
		return
	end

	self.IsRunning = true
	local Content = self.TipsQueue[1]
	table.remove(self.TipsQueue, 1)

	FLOG_INFO("loiafeng Debug: CommonRunningTipsView:TryShowContent(): " .. tostring(Content))
	self.CommTextSlide:ShowSliderText(Content, function() self:OnRunningComplete() end)
end

function CommonRunningTipsView:AddToQueue(Content)
	FLOG_INFO("loiafeng Debug: CommonRunningTipsView:AddToQueue(): " .. tostring(Content))

	if not string.isnilorempty(Content) then
		table.insert(self.TipsQueue, Content)
	end

	self:TryShowContent()
end

return CommonRunningTipsView