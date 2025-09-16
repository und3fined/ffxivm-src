--
-- Author: anypkvcai
-- Date: 2020-12-09 15:22:25
-- Description:
--

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

local ErrorTipsView = LuaClass(InfoTipsBaseView, true)

function ErrorTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text_Content = nil
	--self.Anim_Aoto_In = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AniOffset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ErrorTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ErrorTipsView:OnInit()

end

function ErrorTipsView:OnDestroy()

end

function ErrorTipsView:OnShow()
	self.Super:OnShow()
	self.Text_Content:SetText(self.Params.Content)
end

function ErrorTipsView:OnHide()

end

function ErrorTipsView:OnRegisterUIEvent()

end

function ErrorTipsView:OnRegisterGameEvent()

end

function ErrorTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function ErrorTipsView:OnRegisterBinder()

end

function ErrorTipsView:ForceOffline()
	self:PlayAnimation(self.AniOffset)
end

function ErrorTipsView:OnAnimationFinished(Animation)
	if self.AniOffset == Animation then
		self:Hide()
	end
end

return ErrorTipsView