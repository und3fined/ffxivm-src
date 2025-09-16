---
--- Author: chunfengluo
--- DateTime: 2023-04-18 10:00
--- Description:
---

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

---@class FateErrorTipsView : InfoTipsBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Text_Content URichTextBox
---@field Anim_Aoto_In UWidgetAnimation
---@field Anim_Aoto_Out UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateErrorTipsView = LuaClass(InfoTipsBaseView, true)

function FateErrorTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text_Content = nil
	--self.Anim_Aoto_In = nil
	--self.Anim_Aoto_Out = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateErrorTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateErrorTipsView:OnInit()

end

function FateErrorTipsView:OnDestroy()

end

function FateErrorTipsView:OnShow()
	self.Super:OnShow()
	self.Text_Content:SetText(self.Params.Content)
end

function FateErrorTipsView:OnHide()

end

function FateErrorTipsView:OnRegisterUIEvent()

end

function FateErrorTipsView:OnRegisterGameEvent()

end

function FateErrorTipsView:OnRegisterBinder()

end

function FateErrorTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

return FateErrorTipsView