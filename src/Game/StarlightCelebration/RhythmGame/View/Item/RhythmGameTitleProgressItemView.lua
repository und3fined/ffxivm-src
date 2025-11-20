---
--- Author: Administrator
--- DateTime: 2025-07-15 20:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class RhythmGameTitleProgressItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AnimDeduct UWidgetAnimation
---@field AnimReset UWidgetAnimation
---@field AnimShineLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RhythmGameTitleProgressItemView = LuaClass(UIView, true)

function RhythmGameTitleProgressItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AnimDeduct = nil
	--self.AnimReset = nil
	--self.AnimShineLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RhythmGameTitleProgressItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RhythmGameTitleProgressItemView:OnInit()

end

function RhythmGameTitleProgressItemView:OnDestroy()

end

function RhythmGameTitleProgressItemView:OnShow()

end

function RhythmGameTitleProgressItemView:OnHide()

end

function RhythmGameTitleProgressItemView:OnRegisterUIEvent()

end

function RhythmGameTitleProgressItemView:OnRegisterGameEvent()

end

function RhythmGameTitleProgressItemView:OnValueUpdated(Value)
    if Value then
        self:PlayAnimation(self.AnimReset)
        self:PlayAnimation(self.AnimShineLoop, 0, 0)
    else
        self:StopAnimation(self.AnimShineLoop)
        self:PlayAnimation(self.AnimReset)
        self:PlayAnimation(self.AnimDeduct)
    end
end

function RhythmGameTitleProgressItemView:OnRegisterBinder()
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
            { "IsShow", UIBinderValueChangedCallback.New(self, nil, self.OnValueUpdated)}
        }
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

return RhythmGameTitleProgressItemView