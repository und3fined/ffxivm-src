---
--- Author: Administrator
--- DateTime: 2024-01-17 15:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

---@class ChocoboNewBornDetailItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ProBar UProgressBar
---@field TextStat UFTextBlock
---@field TextValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboNewBornDetailItemView = LuaClass(UIView, true)

function ChocoboNewBornDetailItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ProBar = nil
	--self.TextStat = nil
	--self.TextValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboNewBornDetailItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboNewBornDetailItemView:OnInit()

end

function ChocoboNewBornDetailItemView:OnDestroy()

end

function ChocoboNewBornDetailItemView:OnShow()

end

function ChocoboNewBornDetailItemView:OnHide()

end

function ChocoboNewBornDetailItemView:OnRegisterUIEvent()

end

function ChocoboNewBornDetailItemView:OnRegisterGameEvent()

end

function ChocoboNewBornDetailItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    local Binders = {
        { "AttrName", UIBinderSetText.New(self, self.TextStat) },
        { "AttrValue", UIBinderSetText.New(self, self.TextValue) },
        { "AttrValuePercent", UIBinderSetPercent.New(self, self.Probar)},
        { "AttrIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

return ChocoboNewBornDetailItemView