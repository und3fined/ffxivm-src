--
-- Author: anypkvcai
-- Date: 2020-12-11 15:39:20
-- Description:
--

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

local BottomTipsView = LuaClass(InfoTipsBaseView, true)

function BottomTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BottomTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BottomTipsView:OnInit()

end

function BottomTipsView:OnDestroy()

end

function BottomTipsView:OnShow()
	self.Super:OnShow()
	self.TextContent:SetText(self.Params.Content)
end

function BottomTipsView:OnHide()

end

function BottomTipsView:OnRegisterUIEvent()

end

function BottomTipsView:OnRegisterGameEvent()

end

function BottomTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function BottomTipsView:OnRegisterBinder()

end

return BottomTipsView