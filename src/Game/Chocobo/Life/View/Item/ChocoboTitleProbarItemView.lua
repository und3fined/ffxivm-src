---
--- Author: Administrator
--- DateTime: 2023-12-14 15:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class ChocoboTitleProbarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProBar UProgressBar
---@field ProbarNode ChocoboProbarNodeItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTitleProbarItemView = LuaClass(UIView, true)

function ChocoboTitleProbarItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProBar = nil
	--self.ProbarNode = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTitleProbarItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ProbarNode)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTitleProbarItemView:OnInit()

end

function ChocoboTitleProbarItemView:OnDestroy()

end

function ChocoboTitleProbarItemView:OnShow()

end

function ChocoboTitleProbarItemView:OnHide()

end

function ChocoboTitleProbarItemView:OnRegisterUIEvent()
    
end

function ChocoboTitleProbarItemView:OnRegisterGameEvent()

end

function ChocoboTitleProbarItemView:OnRegisterBinder()
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
        { "Progress", UIBinderSetPercent.New(self, self.ProBar) },
        { "NodeName", UIBinderSetText.New(self, self.ProbarNode.TextTitle) },
        { "NodeNameColor", UIBinderSetColorAndOpacityHex.New(self, self.ProbarNode.TextTitle) },
        { "IsGet", UIBinderSetIsVisible.New(self, self.ProbarNode.PanelGet) },
        { "IsShowRedPoint", UIBinderSetIsVisible.New(self, self.ProbarNode.ImgPoint) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ProbarNode.ImgSelect) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

function ChocoboTitleProbarItemView:OnSelectChanged(Value)
    if self.VM ~= nil then
        self.VM:SetSelect(Value)
    end
end

return ChocoboTitleProbarItemView