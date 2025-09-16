--
-- Author: Administrator
-- Date: 2024-08-27 15:39:34
-- Description:
--

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local UIUtil = require("Utils/UIUtil")
local InfoMissionTipsView = LuaClass(InfoTipsBaseView, true)

function InfoMissionTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgFail = nil
	--self.ImgMission = nil
	--self.PanelFail = nil
	--self.PanelPositive = nil
	--self.TextTitle = nil
	--self.TextTitleFail = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoMissionTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoMissionTipsView:OnInit()

end

function InfoMissionTipsView:OnDestroy()

end

function InfoMissionTipsView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	self.Super:OnShow()
	UIUtil.SetIsVisible(self.PanelFail, false)
	UIUtil.SetIsVisible(self.PanelPositive, false)
	if Params.ImagePanel == "PanelFail" then
		self:ShowPanelFail()
		UIUtil.SetIsVisible(self.PanelFail, true)
		self:PlayAnimation(self.AnimFail)
	else
		self:ShowPanelPositive()
		UIUtil.SetIsVisible(self.PanelPositive, true)
		self:PlayAnimation(self.AnimPositive)
	end
end

function InfoMissionTipsView:OnHide()
	if (self.Params.Callback ~= nil) then
		self.Params.Callback()
	end
end

function InfoMissionTipsView:OnRegisterUIEvent()

end

function InfoMissionTipsView:OnRegisterGameEvent()

end

function InfoMissionTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function InfoMissionTipsView:OnRegisterBinder()

end

function InfoMissionTipsView:ShowPanelPositive()
	local Params = self.Params
	self.TextTitle:SetText(Params.Content)
end

function InfoMissionTipsView:ShowPanelFail()
	local Params = self.Params
	self.TextTitleFail:SetText(Params.Content)
end

return InfoMissionTipsView