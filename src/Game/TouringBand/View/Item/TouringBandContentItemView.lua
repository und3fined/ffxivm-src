---
--- Author: Administrator
--- DateTime: 2024-07-08 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TouringBandContentItemVM = require("Game/TouringBand/VM/TouringBandContentItemVM")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIUtil = require("Utils/UIUtil")

---@class TouringBandContentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconActionLock UFImage
---@field IconActionUnlock UFImage
---@field IconExteriorLock UFImage
---@field IconExteriorUnlock UFImage
---@field IconPetLock UFImage
---@field IconPetUnlock UFImage
---@field PanelAction UFHorizontalBox
---@field PanelCondition UFCanvasPanel
---@field PanelExterior UFHorizontalBox
---@field PanelLock UFCanvasPanel
---@field PanelPet UFHorizontalBox
---@field TextAction UFTextBlock
---@field TextBkgContent UFTextBlock
---@field TextCondition UFTextBlock
---@field TextEPet UFTextBlock
---@field TextExterior UFTextBlock
---@field TextLock UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandContentItemView = LuaClass(UIView, true)

function TouringBandContentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconActionLock = nil
	--self.IconActionUnlock = nil
	--self.IconExteriorLock = nil
	--self.IconExteriorUnlock = nil
	--self.IconPetLock = nil
	--self.IconPetUnlock = nil
	--self.PanelAction = nil
	--self.PanelCondition = nil
	--self.PanelExterior = nil
	--self.PanelLock = nil
	--self.PanelPet = nil
	--self.TextAction = nil
	--self.TextBkgContent = nil
	--self.TextCondition = nil
	--self.TextEPet = nil
	--self.TextExterior = nil
	--self.TextLock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandContentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandContentItemView:OnInit()
    self.ViewModel = TouringBandContentItemVM.New()
end

function TouringBandContentItemView:OnDestroy()

end

function TouringBandContentItemView:OnShow()
    UIUtil.SetIsVisible(self.IconExteriorLock, false)
    UIUtil.SetIsVisible(self.IconPetLock, false)
    UIUtil.SetIsVisible(self.IconActionLock, false)
end

function TouringBandContentItemView:OnHide()

end

function TouringBandContentItemView:OnRegisterUIEvent()

end

function TouringBandContentItemView:OnRegisterGameEvent()

end

function TouringBandContentItemView:OnRegisterBinder()
    local Binders = {
        { "TextContent", UIBinderSetText.New(self, self.TextBkgContent)},
        { "TextCondition", UIBinderSetText.New(self, self.TextCondition)},
        
        { "IsShowPanelLock", UIBinderSetIsVisible.New(self, self.PanelLock) },
        { "TextLock", UIBinderSetText.New(self, self.TextLock)},
        
        { "TextExterior", UIBinderSetText.New(self, self.TextExterior)},
        { "TextEPet", UIBinderSetText.New(self, self.TextEPet)},
        { "TextAction", UIBinderSetText.New(self, self.TextAction)},
        
        { "TextExteriorColor", UIBinderSetColorAndOpacityHex.New(self, self.TextExterior) },
        { "TextEPetColor", UIBinderSetColorAndOpacityHex.New(self, self.TextEPet) },
        { "TextActionColor", UIBinderSetColorAndOpacityHex.New(self, self.TextAction) },
        
        { "TextExteriorColor", UIBinderSetColorAndOpacityHex.New(self, self.IconExteriorUnlock) },
        { "TextEPetColor", UIBinderSetColorAndOpacityHex.New(self, self.IconPetUnlock) },
        { "TextActionColor", UIBinderSetColorAndOpacityHex.New(self, self.IconActionUnlock) },
        
        { "IsShowPanelCondition", UIBinderSetIsVisible.New(self, self.PanelCondition) },
        { "IsShowExterior", UIBinderSetIsVisible.New(self, self.PanelExterior) },
        { "IsShowEPet", UIBinderSetIsVisible.New(self, self.PanelPet) },
        { "IsShowAction", UIBinderSetIsVisible.New(self, self.PanelAction) },
    }
    self:RegisterBinders(self.ViewModel, Binders)
end

function TouringBandContentItemView:GetViewModel()
    if self.ViewModel == nil then
        self.ViewModel = TouringBandContentItemVM.New()
    end
    
    return self.ViewModel
end

return TouringBandContentItemView