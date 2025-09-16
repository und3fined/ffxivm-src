---
--- Author: Administrator
--- DateTime: 2023-05-19 10:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

local UIViewMgr = _G.UIViewMgr

---@class TutorialGestureTips1ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelProBar UFCanvasPanel
---@field ProBarFull URadialImage
---@field TextTips URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
-- 这里要走系统提示表的流程,改下类型
local TutorialGestureTips1ItemView = LuaClass(InfoTipsBaseView, true)

function TutorialGestureTips1ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelProBar = nil
	--self.ProBarFull = nil
	--self.TextTips = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGestureTips1ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGestureTips1ItemView:OnInit()

end

function TutorialGestureTips1ItemView:OnDestroy()
end

function TutorialGestureTips1ItemView:SetText(Content)
	self.TextTips:SetText(Content)
end

function TutorialGestureTips1ItemView:OnShow()
	self.Super:OnShow()

	self.NormalClose = false

	if self.Params == nil then
		return
	end

	local function OnTimerEnd()
		local Cfg = _G.NewTutorialMgr:GetRunningCfg(self.TutorialID)

		if Cfg == nil then
			local GuideUIName = self.Params.Cfg.GuideBPName
			local GuideUIViewID = UIViewMgr:GetViewIDByName(GuideUIName)
			UIViewMgr:HideView(GuideUIViewID)
		else
			_G.EventMgr:SendEvent(_G.EventID.TutorialTimerEnd, {TutorialID = self.TutorialID})
		end
	end

	if self.Params.Cfg ~= nil then
		self.TutorialID = self.Params.Cfg.TutorialID
		self.TextTips:SetText(self.Params.Cfg.Content)

		if self.Params.Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			UIUtil.SetIsVisible(self.PanelProBar, false)
		end

		self:StartCountDown(self.Params.Cfg.Time,self,OnTimerEnd)
	elseif self.Params.Content then
		self.TextTips:SetText(self.Params.Content)
	end
end

function TutorialGestureTips1ItemView:OnHide()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end

	--_G.TipsQueueMgr:Pause(false)

	UIUtil.SetIsVisible(self.PanelProBar, false)

	if not self.NormalClose then
		_G.EventMgr:SendEvent(_G.EventID.TutorialTimerEnd, {TutorialID = self.TutorialID})
	end
end

function TutorialGestureTips1ItemView:OnRegisterUIEvent()

end

function TutorialGestureTips1ItemView:OnRegisterGameEvent()

end

function TutorialGestureTips1ItemView:OnRegisterBinder()

end


function TutorialGestureTips1ItemView:PlayAnimIn()
	self.Super:PlayAnimIn()
end

function TutorialGestureTips1ItemView:StartCountDown(Time, View, Callback)
	self:RemoveTimer()
	local Inv = 0.05

	if Time and Time > 0 then
		self.CountDown = Time
		UIUtil.SetIsVisible(self.PanelProBar, true)

		local Duration = Time
		local PlaySpeed = self.AnimProgress:GetEndTime() / Duration
		self:PlayAnimation(self.AnimProgress, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed)

		local Start = TimeUtil.GetLocalTimeMS()
		self.TimerHdl = self:RegisterTimer(function()
			local Cur = TimeUtil.GetLocalTimeMS()
			local Delta = (Cur - Start) / 1000
			if Delta > self.CountDown then
				if Callback ~= nil then
					self.NormalClose = true
					self:RemoveTimer()
					Callback()
				end
				return
			end
		end, 0, Inv, 0)
	else
		UIUtil.SetIsVisible(self.PanelProBar, false)
	end

end

function TutorialGestureTips1ItemView:RemoveTimer()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end
end


return TutorialGestureTips1ItemView