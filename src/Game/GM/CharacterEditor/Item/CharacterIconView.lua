---
--- Author: richyczhou
--- DateTime: 2025-08-19 19:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local FLOG_INFO = _G.FLOG_INFO

---@class CharacterIconView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UButton
---@field Icon UFImage
---@field IndexText UTextBlock
---@field SelectBg UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CharacterIconView = LuaClass(UIView, true)

function CharacterIconView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Icon = nil
	--self.IndexText = nil
	--self.SelectBg = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CharacterIconView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CharacterIconView:OnInit()
    self.Binders = {
        { "IsSelected", UIBinderSetIsVisible.New(self, self.SelectBg)},
        { "IndexText", UIBinderSetText.New(self, self.IndexText)},
    }
end

function CharacterIconView:OnDestroy()

end

function CharacterIconView:OnShow()
    --local Params = self.Params
    --if nil == Params then return end
    --
    -----@type CharacterIconVM
    --local CharacterIconVM = Params.Data
    --if nil == CharacterIconVM then return end
    --print("[CharacterIconView:OnShow] Index: " .. CharacterIconVM.IndexText)
end

function CharacterIconView:OnHide()

end

function CharacterIconView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Button, self.OnButtonClicked)
end

function CharacterIconView:OnRegisterGameEvent()

end

function CharacterIconView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function CharacterIconView:OnButtonClicked()
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

function CharacterIconView:OnSelectChanged(IsSelected)
    local ViewModel = self.Params.Data
    if ViewModel and ViewModel.OnSelectedChange then
        --FLOG_INFO("[CharacterIconView:OnSelectChanged] [%d] IsSelected: %s", ViewModel.IndexText, tostring(IsSelected))
        ViewModel:OnSelectedChange(IsSelected)
    end
end

return CharacterIconView