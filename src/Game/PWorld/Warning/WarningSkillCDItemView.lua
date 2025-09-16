---
--- Author: skysong
--- DateTime: 2023-12-12 19:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetOutline = require("Binder/UIBinderSetOutlineColor")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

---@class WarningSkillCDItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgProBarBG UFImage
---@field ProBar UProgressBar
---@field TextSkillName UFTextBlock
---@field TextTime UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimRedIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WarningSkillCDItemView = LuaClass(UIView, true)

function WarningSkillCDItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgProBarBG = nil
	--self.ProBar = nil
	--self.TextSkillName = nil
	--self.TextTime = nil
	--self.AnimIn = nil
	--self.AnimRedIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WarningSkillCDItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WarningSkillCDItemView:OnInit()

end

function WarningSkillCDItemView:OnDestroy()

end

function WarningSkillCDItemView:OnShow()

end

function WarningSkillCDItemView:OnHide()

end

function WarningSkillCDItemView:OnRegisterUIEvent()

end

function WarningSkillCDItemView:OnRegisterGameEvent()

end

function WarningSkillCDItemView:OnRegisterBinder()
    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    self.ViewModel = ViewModel

    local Binders = {
        { "Name", UIBinderSetText.New(self, self.TextSkillName) },
        { "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
        { "RemainTime", UIBinderSetText.New(self, self.TextTime) },
        { "WarningTimeProgress", UIBinderSetPercent.New(self, self.ProBar) },
        { "NameColor",UIBinderSetOutline.New(self,self.TextSkillName)},
        { "RemainTimeColor",UIBinderSetOutline.New(self,self.TextTime)},
        { "ImgProBarBG", UIBinderSetBrushFromAssetPath.New(self, self.ImgProBarBG)},
    }

    self:RegisterBinders(self.ViewModel, Binders)
end

return WarningSkillCDItemView