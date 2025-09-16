--
-- Author: anypkvcai, chaooren
-- Date: 2020-12-01 16:45:07
-- Description:预警引导读条
--

local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local UIView = require("UI/UIView")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local MainPanelVM = require("Game/Main/MainPanelVM")

---@class MainActorWarningItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImageBreakable UFImage
---@field PanelChant UFCanvasPanel
---@field ProBarChant UProgressBar
---@field TextBreakSuccess UTextBlock
---@field TextSkillName UFTextBlock
---@field AnimMainLoop UWidgetAnimation
---@field AnimLoopStop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainActorWarningItemView = LuaClass(UIView, true)

function MainActorWarningItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImageBreakable = nil
	--self.PanelChant = nil
	--self.ProBarChant = nil
	--self.TextBreakSuccess = nil
	--self.TextSkillName = nil
	--self.AnimMainLoop = nil
	--self.AnimLoopStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainActorWarningItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainActorWarningItemView:OnInit()
	self.Binders = {
		{"IsReadingInfoVisible", UIBinderValueChangedCallback.New(self, nil, self.OnReadingInfoVisbleChanged)},
		{"ReadingInfoPercent", UIBinderSetPercent.New(self, self.ProBarChant)},
		{"ReadingInfoSkillName", UIBinderSetText.New(self, self.TextSkillName)},
	}

	-- self.IsBreak = false
	-- self.TimerBreak = nil
end

function MainActorWarningItemView:OnDestroy()

end

function MainActorWarningItemView:OnShow()

end

function MainActorWarningItemView:OnHide()

end

function MainActorWarningItemView:OnRegisterUIEvent()

end

function MainActorWarningItemView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.EndDamageWarning, self.OnDamageWarningBreak)
end

function MainActorWarningItemView:OnRegisterTimer()

end

function MainActorWarningItemView:OnRegisterBinder()
	self:RegisterBinders(MainPanelVM, self.Binders)
end

-- function MainActorWarningItemView:OnDamageWarningBreak(Params)
-- 	local EntityID = Params.ULongParam1
-- 	if EntityID == _G.MainPanelMgr.SelectedEntityID and not self.IsBreak and UIUtil.IsVisible(self.PanelChant) then
-- 		self.IsBreak = true
-- 		self:StopAllAnimations()
-- 		self:PlayAnimation(self.AnimLoopStop)
-- 		local Duration = self.AnimLoopStop:GetEndTime() - self.AnimLoopStop:GetStartTime()
-- 		self.TimerBreak = self:RegisterTimer(self.OnTimerBreak, Duration, 1, 1)
-- 	end
-- end

-- function MainActorWarningItemView:OnTimerBreak()
-- 	self.IsBreak = false
-- 	self.TimerBreak = nil
-- 	self:StopAllAnimations()
-- 	self:PlayAnimation(self.AnimHide)
-- end

function MainActorWarningItemView:OnReadingInfoVisbleChanged(NewValue, OldValue)
	if NewValue then
		self:StopAllAnimations()
		self:PlayAnimation(self.AnimMainLoop, 0, 0)
		self:PlayAnimation(self.AnimShow)

		-- self.IsBreak = false
		-- if self.TimerBreak then
		-- 	self:UnRegisterTimer(self.TimerBreak)
		-- 	self.TimerBreak = nil
		-- end
	else -- if not self.IsBreak then
		self:StopAllAnimations()
		self:PlayAnimation(self.AnimHide)
	end
end

return MainActorWarningItemView