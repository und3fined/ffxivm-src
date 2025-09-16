--
-- Author: anypkvcai
-- Date: 2020-12-11 15:39:16
-- Description:
--

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

local AreaTipsView = LuaClass(InfoTipsBaseView, true)

function AreaTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AreaTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AreaTipsView:OnInit()

end

function AreaTipsView:OnDestroy()

end

function AreaTipsView:OnShow()
	self.Super:OnShow()
	self.TextContent:SetText(self.Params.Content)
end

function AreaTipsView:OnHide()

end

function AreaTipsView:OnRegisterUIEvent()

end

function AreaTipsView:OnRegisterGameEvent()

end

function AreaTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function AreaTipsView:OnRegisterBinder()

end

return AreaTipsView