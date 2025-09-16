--
-- Author: anypkvcai
-- Date: 2020-12-11 15:39:47
-- Description:
--

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local TimeUtil = require("Utils/TimeUtil")

local NPCTalkTipsView = LuaClass(InfoTipsBaseView, true)

function NPCTalkTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.Img_CountDown = nil
	self.TextContent = nil
	self.TextNPCName = nil
	self.AniFadeOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.BeginTime = 0
end

function NPCTalkTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCTalkTipsView:OnInit()

end

function NPCTalkTipsView:OnDestroy()

end

function NPCTalkTipsView:OnShow()
	self.Super:OnShow()
	self.Text_Title:SetText(self.Params.Name)
	self.Text_Content:SetText(self.Params.Content)
	self.BeginTime = TimeUtil.GetLocalTimeMS()
end

function NPCTalkTipsView:OnHide()

end

function NPCTalkTipsView:OnRegisterUIEvent()

end

function NPCTalkTipsView:OnRegisterGameEvent()

end

function NPCTalkTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()

	self:RegisterTimer(self.OnTimerUpdateProgress, 0, 0.1, 0)
end

function NPCTalkTipsView:OnRegisterBinder()

end

function NPCTalkTipsView:OnTimerUpdateProgress()
	if nil == self.Params then return end

	local Time = (TimeUtil.GetLocalTimeMS() - self.BeginTime) / 1000
	local Progress = 1 - Time / self.Params.ShowTime
	--print("NPCTalkTipsView:OnTimerUpdateProgress", Time, Progress)

	self.Img_CountDown:SetPercent(Progress)

	--local Material = self.Img_CountDown:GetDynamicMaterial()
	--if nil ~= Material then
	--	Material:SetScalarParameterValue("ParamAngle", Progress)
	--end
end

return NPCTalkTipsView