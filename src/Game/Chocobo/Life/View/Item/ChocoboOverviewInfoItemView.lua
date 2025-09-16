---
--- Author: Administrator
--- DateTime: 2023-12-14 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

---@class ChocoboOverviewInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ChocoboStar ChocoboStarPanelItemView
---@field ImgIcon UFImage
---@field Probar UProgressBar
---@field TextValue UFTextBlock
---@field TextValueNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboOverviewInfoItemView = LuaClass(UIView, true)

function ChocoboOverviewInfoItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ChocoboStar = nil
	--self.ImgIcon = nil
	--self.Probar = nil
	--self.TextValue = nil
	--self.TextValueNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboOverviewInfoItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ChocoboStar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboOverviewInfoItemView:OnInit()
end

function ChocoboOverviewInfoItemView:OnDestroy()

end

function ChocoboOverviewInfoItemView:OnShow()

end

function ChocoboOverviewInfoItemView:OnHide()

end

function ChocoboOverviewInfoItemView:OnRegisterUIEvent()

end

function ChocoboOverviewInfoItemView:OnRegisterGameEvent()

end

function ChocoboOverviewInfoItemView:OnRegisterBinder()
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
            { "AttrName", UIBinderSetText.New(self, self.TextValue) },
            { "AttrValue", UIBinderSetText.New(self, self.TextValueNumber) },
            { "AttrValuePercent", UIBinderSetPercent.New(self, self.Probar)},
            { "AttrIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
        }
    end
    self:RegisterBinders(ViewModel, self.Binders)

    if self.VM.IsRent then
        UIUtil.SetIsVisible(self.TextValueNumber, false)
        UIUtil.SetIsVisible(self.Probar, false)
    else
        local MainVMBinders = {
            { "IsShowSimpleAttrMode", UIBinderSetIsVisible.New(self, self.TextValueNumber) },
            { "IsShowSimpleAttrMode", UIBinderSetIsVisible.New(self, self.Probar) },
        }
        self:RegisterBinders(_G.ChocoboMainVM, MainVMBinders)
    end
end

return ChocoboOverviewInfoItemView