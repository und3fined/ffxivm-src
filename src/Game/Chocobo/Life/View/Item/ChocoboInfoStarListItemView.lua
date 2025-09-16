---
--- Author: Administrator
--- DateTime: 2023-12-14 15:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ChocoboInfoStarListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ChocoboStar ChocoboStarPanelItemView
---@field ImgIcon UFImage
---@field TextValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboInfoStarListItemView = LuaClass(UIView, true)

function ChocoboInfoStarListItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ChocoboStar = nil
	--self.ImgIcon = nil
	--self.TextValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboInfoStarListItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ChocoboStar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboInfoStarListItemView:OnInit()
end

function ChocoboInfoStarListItemView:OnDestroy()

end

function ChocoboInfoStarListItemView:OnShow()
end

function ChocoboInfoStarListItemView:OnHide()

end

function ChocoboInfoStarListItemView:OnRegisterUIEvent()

end

function ChocoboInfoStarListItemView:OnRegisterGameEvent()

end

function ChocoboInfoStarListItemView:OnRegisterBinder()
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
            { "AttrIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
        }
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

return ChocoboInfoStarListItemView