---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class LoginNewLanguageItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field PanelSelect UFCanvasPanel
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewLanguageItemView = LuaClass(UIView, true)

function LoginNewLanguageItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.PanelSelect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewLanguageItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewLanguageItemView:OnInit()

end

function LoginNewLanguageItemView:OnDestroy()

end

function LoginNewLanguageItemView:OnShow()
    local Params = self.Params
    if nil == Params then return end

    ---@type LoginLanguageItemVM
    local LoginLanguageItemVM = Params.Data
    if nil == LoginLanguageItemVM then return end

    self.TextName:SetText(LoginLanguageItemVM.Name)
end

function LoginNewLanguageItemView:OnHide()

end

function LoginNewLanguageItemView:OnRegisterUIEvent()

end

function LoginNewLanguageItemView:OnRegisterGameEvent()

end

function LoginNewLanguageItemView:OnRegisterBinder()

end

function LoginNewLanguageItemView:OnSelectChanged(IsSelected)
    UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

return LoginNewLanguageItemView