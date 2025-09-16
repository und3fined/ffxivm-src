---
--- Author: Administrator
--- DateTime: 2024-01-23 09:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

---@class ChocoboLevelUpItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgProBarBg UFImage
---@field Probar UProgressBar
---@field ProbarIncrease UProgressBar
---@field RichTextValueNumber URichTextBox
---@field TextValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboLevelUpItemView = LuaClass(UIView, true)

function ChocoboLevelUpItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgProBarBg = nil
	--self.Probar = nil
	--self.ProbarIncrease = nil
	--self.RichTextValueNumber = nil
	--self.TextValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboLevelUpItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboLevelUpItemView:OnInit()

end

function ChocoboLevelUpItemView:OnDestroy()

end

function ChocoboLevelUpItemView:OnShow()

end

function ChocoboLevelUpItemView:OnHide()

end

function ChocoboLevelUpItemView:OnRegisterUIEvent()

end

function ChocoboLevelUpItemView:OnRegisterGameEvent()

end

function ChocoboLevelUpItemView:OnRegisterBinder()
    
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
        { "AttrName", UIBinderSetText.New(self, self.TextValue) },
        { "CurValue", UIBinderSetText.New(self, self.RichTextValueNumber) },
        { "AttrIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
        { "OldProgress", UIBinderSetPercent.New(self, self.Probar) },
        { "NewProgress", UIBinderSetPercent.New(self, self.ProbarIncrease) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

return ChocoboLevelUpItemView