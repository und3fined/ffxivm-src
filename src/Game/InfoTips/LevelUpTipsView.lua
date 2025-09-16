--
-- Author: anypkvcai
-- Date: 2020-12-08 14:53:55
-- Description:
--

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

local LevelUpTipsView = LuaClass(InfoTipsBaseView, true)

function LevelUpTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextUpgrade = nil
	--self.Anim_Aoto_In = nil
	--self.Anim_Aoto_Out = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LevelUpTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LevelUpTipsView:OnInit()

end

function LevelUpTipsView:OnDestroy()

end

function LevelUpTipsView:OnShow()
	self.Super:OnShow()
	-- self.TextContent:SetText(self.Params.Content)
end

function LevelUpTipsView:OnHide()

end

function LevelUpTipsView:OnRegisterUIEvent()

end

function LevelUpTipsView:OnRegisterGameEvent()

end

function LevelUpTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function LevelUpTipsView:OnRegisterBinder()

end

return LevelUpTipsView