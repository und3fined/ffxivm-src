---
--- Author: Administrator
--- DateTime: 2025-08-01 15:14
--- Description:
---

local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")


---@class FootPrintTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock_29 UFTextBlock
---@field Root UCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AniOffset UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FootPrintTipsView = LuaClass(InfoTipsBaseView, true)

function FootPrintTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock_29 = nil
	--self.Root = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AniOffset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FootPrintTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FootPrintTipsView:OnInit()

end

function FootPrintTipsView:OnDestroy()

end

function FootPrintTipsView:OnShow()
	self.Super:OnShow()
	self.FTextBlock_29:SetText(self.Params.Content)
end

function FootPrintTipsView:OnHide()

end

function FootPrintTipsView:OnRegisterUIEvent()

end

function FootPrintTipsView:OnRegisterGameEvent()

end

function FootPrintTipsView:OnRegisterBinder()

end

function FootPrintTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function FootPrintTipsView:ForceOffline()
	self:PlayAnimation(self.AniOffset)
end

function FootPrintTipsView:OnAnimationFinished(Animation)
	if self.AniOffset == Animation then
		self:Hide()
	end
end

return FootPrintTipsView