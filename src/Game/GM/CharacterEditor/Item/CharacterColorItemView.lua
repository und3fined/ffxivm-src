---
--- Author: richyczhou
--- DateTime: 2025-08-22 15:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")

---@class CharacterColorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnColor UFButton
---@field ImgColor UFImage
---@field ImgSelectEffect UFImage
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CharacterColorItemView = LuaClass(UIView, true)

function CharacterColorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnColor = nil
	--self.ImgColor = nil
	--self.ImgSelectEffect = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CharacterColorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CharacterColorItemView:OnInit()
    self.Binders = {
        { "bItemSelect", UIBinderSetIsVisible.New(self, self.ImgSelectEffect)},
        { "bItemSelect", UIBinderSetIsVisible.New(self, self.TextNum) },
        { "SelectText", UIBinderSetText.New(self, self.TextNum)},
        { "ItemColorAndOpacity", UIBinderSetColorAndOpacity.New(self, self.ImgColor) },
    }
end

function CharacterColorItemView:OnDestroy()

end

function CharacterColorItemView:OnShow()

end

function CharacterColorItemView:OnHide()

end

function CharacterColorItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnColor, self.OnClickButtonItem)
end

function CharacterColorItemView:OnRegisterGameEvent()

end

function CharacterColorItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    ---@type CharacterColorItemVM
    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function CharacterColorItemView:OnClickButtonItem()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

    Adapter:OnItemClicked(self, Params.Index)
end

function CharacterColorItemView:OnSelectChanged(IsSelected)
    ---@type CharacterColorItemVM
    local ViewModel = self.Params.Data
    if ViewModel and ViewModel.OnSelectedChange then
        ViewModel:OnSelectedChange(IsSelected)
    end
end

return CharacterColorItemView