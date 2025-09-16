---
--- Author: Administrator
--- DateTime: 2024-08-19 19:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChocoboFeeDingStatusItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelFail UFCanvasPanel
---@field PanelHappy UFCanvasPanel
---@field PanelSad UFCanvasPanel
---@field AnimHappy UWidgetAnimation
---@field AnimSad UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboFeeDingStatusItemView = LuaClass(UIView, true)

function ChocoboFeeDingStatusItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelFail = nil
	--self.PanelHappy = nil
	--self.PanelSad = nil
	--self.AnimHappy = nil
	--self.AnimSad = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboFeeDingStatusItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboFeeDingStatusItemView:OnInit()

end

function ChocoboFeeDingStatusItemView:OnDestroy()

end

function ChocoboFeeDingStatusItemView:OnShow()

end

function ChocoboFeeDingStatusItemView:OnHide()

end

function ChocoboFeeDingStatusItemView:OnRegisterUIEvent()

end

function ChocoboFeeDingStatusItemView:OnRegisterGameEvent()

end

function ChocoboFeeDingStatusItemView:OnRegisterBinder()

end

function ChocoboFeeDingStatusItemView:PlayHappyEffect(Listener, InCallBack)
    self.Listener = Listener
    self.Callback = InCallBack
    self:PlayAnimation(self.AnimHappy)
end

function ChocoboFeeDingStatusItemView:PlaySadEffect(Listener, InCallBack)
    self.Listener = Listener
    self.Callback = InCallBack
    self:PlayAnimation(self.AnimSad)
end

function ChocoboFeeDingStatusItemView:OnAnimationFinished(Anim)
    if Anim == self.AnimHappy or Anim == self.AnimSad then
        if self.Callback ~= nil then
            self.Callback(self.Listener)
            self.Callback = nil
            self.Listener = nil
        end
    end
end

return ChocoboFeeDingStatusItemView