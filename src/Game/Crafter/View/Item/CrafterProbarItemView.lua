---
--- Author: henghaoli
--- DateTime: 2024-09-09 16:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class CrafterProbarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgLight UFImage
---@field ImgProbar UFImage
---@field PanelProbar UFCanvasPanel
---@field TextBlue UFTextBlock
---@field AnimLightIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterProbarItemView = LuaClass(UIView, true)

function CrafterProbarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgLight = nil
	--self.ImgProbar = nil
	--self.PanelProbar = nil
	--self.TextBlue = nil
	--self.AnimLightIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterProbarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterProbarItemView:ResetAnimLightIn()
	self:StopAnimation(self.AnimLightIn)
	self:PlayAnimationTimeRange(self.AnimLightIn, 0.0, 0.01, 1, nil, 1.0, false)
end

function CrafterProbarItemView:PlayAnimLightIn()
	self:PlayAnimation(self.AnimLightIn)
end

function CrafterProbarItemView:OnShow()
	self:ResetAnimLightIn()
	if self.Params and self.Params.TextBlue then
		self.TextBlue:SetText(self.Params.TextBlue)
	end
end

function CrafterProbarItemView:OnHide()

end

function CrafterProbarItemView:OnRegisterUIEvent()

end

function CrafterProbarItemView:OnRegisterGameEvent()

end

function CrafterProbarItemView:OnRegisterBinder()

end

return CrafterProbarItemView