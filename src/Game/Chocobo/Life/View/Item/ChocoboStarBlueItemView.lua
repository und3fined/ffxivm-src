---
--- Author: Administrator
--- DateTime: 2023-12-14 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class ChocoboStarBlueItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgStarM UFImage
---@field ImgStarS UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboStarBlueItemView = LuaClass(UIView, true)

function ChocoboStarBlueItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgStarM = nil
	--self.ImgStarS = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboStarBlueItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboStarBlueItemView:OnInit()
end

function ChocoboStarBlueItemView:OnDestroy()

end

function ChocoboStarBlueItemView:OnShow()
end

function ChocoboStarBlueItemView:OnHide()

end

function ChocoboStarBlueItemView:OnRegisterUIEvent()

end

function ChocoboStarBlueItemView:OnRegisterGameEvent()

end

function ChocoboStarBlueItemView:OnValueUpdated(_)
    if self.VM then
        local VM = self.VM
        _G.UIUtil.SetIsVisible(self.ImgStarM, VM.IsShwoImgStarM)
        _G.UIUtil.SetIsVisible(self.ImgStarS, VM.IsShwoImgStarS)
    end
end

function ChocoboStarBlueItemView:OnRegisterBinder()
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

    if not self.Binders then
        self.Binders = {
            { "IsUpdated", UIBinderValueChangedCallback.New(self, nil, self.OnValueUpdated)}
        }
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

return ChocoboStarBlueItemView