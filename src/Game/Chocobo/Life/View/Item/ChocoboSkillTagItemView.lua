---
--- Author: Administrator
--- DateTime: 2023-12-29 16:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ChocoboSkillTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgType UFImage
---@field TextType UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboSkillTagItemView = LuaClass(UIView, true)

function ChocoboSkillTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgType = nil
	--self.TextType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboSkillTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboSkillTagItemView:OnInit()

end

function ChocoboSkillTagItemView:OnDestroy()

end

function ChocoboSkillTagItemView:OnShow()

end

function ChocoboSkillTagItemView:OnHide()

end

function ChocoboSkillTagItemView:OnRegisterUIEvent()

end

function ChocoboSkillTagItemView:OnRegisterGameEvent()

end

function ChocoboSkillTagItemView:OnRegisterBinder()
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
        { "TagText", UIBinderSetText.New(self, self.TextType) },
        { "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgType) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

return ChocoboSkillTagItemView