---
--- Author: Administrator
--- DateTime: 2024-03-19 18:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ChocoboRacePlayerBuffItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBuff UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRacePlayerBuffItemView = LuaClass(UIView, true)

function ChocoboRacePlayerBuffItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBuff = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRacePlayerBuffItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRacePlayerBuffItemView:OnInit()

end

function ChocoboRacePlayerBuffItemView:OnDestroy()

end

function ChocoboRacePlayerBuffItemView:OnShow()

end

function ChocoboRacePlayerBuffItemView:OnHide()

end

function ChocoboRacePlayerBuffItemView:OnRegisterUIEvent()

end

function ChocoboRacePlayerBuffItemView:OnRegisterGameEvent()

end

function ChocoboRacePlayerBuffItemView:OnRegisterBinder()
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

    local Binders = 
    {
        { "EffectIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBuff) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

return ChocoboRacePlayerBuffItemView