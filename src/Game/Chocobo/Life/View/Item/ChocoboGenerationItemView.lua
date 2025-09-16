---
--- Author: Administrator
--- DateTime: 2024-01-02 10:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class ChocoboGenerationItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArrow UFImage
---@field ImgSelect UFImage
---@field TextGeneration UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboGenerationItemView = LuaClass(UIView, true)

function ChocoboGenerationItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArrow = nil
	--self.ImgSelect = nil
	--self.TextGeneration = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboGenerationItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboGenerationItemView:OnInit()

end

function ChocoboGenerationItemView:OnDestroy()

end

function ChocoboGenerationItemView:OnShow()
    
end

function ChocoboGenerationItemView:OnHide()
    
end

function ChocoboGenerationItemView:OnRegisterUIEvent()

end

function ChocoboGenerationItemView:OnRegisterGameEvent()

end

function ChocoboGenerationItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.VM = ViewModel

    local Binders = {
        { "ID", UIBinderSetText.New(self, self.TextGeneration) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgArrow) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

function ChocoboGenerationItemView:OnSelectChanged(Value)
    if Value then
        self:PlayAnimation(self.AnimChecked)
    else
        self:PlayAnimation(self.AnimUnchecked)
    end
end

return ChocoboGenerationItemView