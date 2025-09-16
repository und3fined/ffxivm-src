---
--- Author: Administrator
--- DateTime: 2024-08-19 19:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChocoboFeeDingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelFail UFCanvasPanel
---@field PanelSucces UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextSucces UFTextBlock
---@field AnimFail UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboFeeDingTipsItemView = LuaClass(UIView, true)

function ChocoboFeeDingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelFail = nil
	--self.PanelSucces = nil
	--self.TextFail = nil
	--self.TextSucces = nil
	--self.AnimFail = nil
	--self.AnimSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboFeeDingTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboFeeDingTipsItemView:OnInit()

end

function ChocoboFeeDingTipsItemView:OnDestroy()

end

function ChocoboFeeDingTipsItemView:OnShow()
    -- LSTR string: 获得加速效果
    self.TextSucces:SetText(_G.LSTR(440004)) -- 获得加速效果
    -- LSTR string: 未获得加速效果
    self.TextFail:SetText(_G.LSTR(440005))  -- 未获得加速效果
end

function ChocoboFeeDingTipsItemView:OnHide()

end

function ChocoboFeeDingTipsItemView:OnRegisterUIEvent()

end

function ChocoboFeeDingTipsItemView:OnRegisterGameEvent()

end

function ChocoboFeeDingTipsItemView:OnRegisterBinder()

end

function ChocoboFeeDingTipsItemView:PlayHappyEffect()
    self:PlayAnimation(self.AnimSuccess)
end

function ChocoboFeeDingTipsItemView:PlaySadEffect()
    self:PlayAnimation(self.AnimFail)
end

return ChocoboFeeDingTipsItemView