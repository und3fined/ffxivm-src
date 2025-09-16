---
--- Author: Administrator
--- DateTime: 2023-12-14 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class ChocoboStarRedItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgStarM UFImage
---@field ImgStarS UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboStarRedItemView = LuaClass(UIView, true)

function ChocoboStarRedItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgStarM = nil
	--self.ImgStarS = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboStarRedItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboStarRedItemView:OnInit()

end

function ChocoboStarRedItemView:OnDestroy()

end

function ChocoboStarRedItemView:OnShow()

end

function ChocoboStarRedItemView:OnHide()

end

function ChocoboStarRedItemView:OnRegisterUIEvent()

end

function ChocoboStarRedItemView:OnRegisterGameEvent()

end

function ChocoboStarRedItemView:OnValueUpdated(_)
    if self.VM then
        local VM = self.VM
        _G.UIUtil.SetIsVisible(self.ImgStarM, VM.IsShwoImgStarM)
        _G.UIUtil.SetIsVisible(self.ImgStarS, VM.IsShwoImgStarS)
    end
end

function ChocoboStarRedItemView:OnRegisterBinder()
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

return ChocoboStarRedItemView