---
--- Author: Administrator
--- DateTime: 2023-12-26 16:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class SkillTypeTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgType UFImage
---@field TextType UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillTypeTagItemView = LuaClass(UIView, true)

function SkillTypeTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgType = nil
	--self.TextType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillTypeTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillTypeTagItemView:OnInit()

end

function SkillTypeTagItemView:OnDestroy()

end

function SkillTypeTagItemView:OnShow()

end

function SkillTypeTagItemView:OnHide()

end

function SkillTypeTagItemView:OnRegisterUIEvent()

end

function SkillTypeTagItemView:OnRegisterGameEvent()

end

function SkillTypeTagItemView:OnRegisterBinder()
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

return SkillTypeTagItemView