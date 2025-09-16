--
-- Author: anypkvcai
-- Date: 2020-12-11 15:39:09
-- Description:
--

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local UIUtil = require("Utils/UIUtil")

local ActiveTipsView = LuaClass(InfoTipsBaseView, true)

function ActiveTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Count = nil
	--self.MaxCount = nil
	--self.Panel_Icon = nil
	--self.SizeBox1 = nil
	--self.SpacerL = nil
	--self.SpacerR = nil
	--self.TargetProgress = nil
	--self.TextContent = nil
	--self.AniOffsetIn = nil
	--self.AniOffsetOut = nil
	--self.AniStayIn = nil
	--self.AniStayOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ActiveTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ActiveTipsView:OnInit()

end

function ActiveTipsView:OnDestroy()

end

function ActiveTipsView:OnShow()
	self.Super:OnShow()
	local bShowMark = self.Params.bTargetFinish
	UIUtil.SetIsVisible(self.Panel_Icon, bShowMark)
	if self.Params.PlayOffset then 
		self:PlayAnimation(self.AniOffsetIn)
	else
		self:PlayAnimation(self.AniStayIn)
	end
	self.TextContent:SetText(self.Params.Content)
	local bShowTargetProgress = (not bShowMark)
		and (self.Params.MaxCount ~= nil) and (self.Params.Count ~= nil)
	UIUtil.SetIsVisible(self.TargetProgress, bShowTargetProgress)

	if bShowTargetProgress then
		self.Count:SetText(self.Params.Count)
		self.MaxCount:SetText(string.format("/%d", self.Params.MaxCount))
	end
	self.IsOffsetOut = false
end

function ActiveTipsView:OnHide()
	if not  self.IsOffsetOut then 
		self:PlayAnimation(self.AniStayOut)
	end
end

function ActiveTipsView:OnRegisterUIEvent()

end

function ActiveTipsView:OnRegisterGameEvent()

end

function ActiveTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function ActiveTipsView:OnRegisterBinder()

end

function ActiveTipsView:ForceOffline()
	self:PlayAnimation(self.AniOffsetOut)
end

function ActiveTipsView:OnAnimationFinished(Animation)
	if self.AniOffsetOut == Animation then
		self.IsOffsetOut = true
		self:Hide()
	end
end

return ActiveTipsView