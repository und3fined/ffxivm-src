---
--- Author: Administrator
--- DateTime: 2023-12-28 19:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChocoboHeadVM = require("Game/Chocobo/Life/VM/ChocoboHeadVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ChocoboMainVM = nil

---@class ChocoboGenealogyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgColor UFImage
---@field ImgJoinMatch UFImage
---@field PanelHead UFCanvasPanel
---@field TextName UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---@field HeadIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboGenealogyItemView = LuaClass(UIView, true)

function ChocoboGenealogyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgColor = nil
	--self.ImgJoinMatch = nil
	--self.PanelHead = nil
	--self.TextName = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--self.HeadIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboGenealogyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboGenealogyItemView:OnInit()
    ChocoboMainVM = _G.ChocoboMainVM
    self.ViewModel = ChocoboHeadVM.New()
    self.IsSelect = false
end

function ChocoboGenealogyItemView:OnDestroy()

end

function ChocoboGenealogyItemView:OnShow()
end

function ChocoboGenealogyItemView:OnHide()
end

function ChocoboGenealogyItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnButtonClick)
end

function ChocoboGenealogyItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ChocoboGenealogyItemSelect, self.OnChocoboGenealogyItemSelect)
end

function ChocoboGenealogyItemView:OnRegisterBinder()
    local Binders = {
        { "Color", UIBinderSetColorAndOpacity.New(self, self.ImgColor) },
        { "IsJoinMatch", UIBinderSetIsVisible.New(self, self.ImgJoinMatch) },
        { "TextName", UIBinderSetText.New(self, self.TextName) },
        { "IsShow", UIBinderSetIsVisible.New(self, self.PanelHead) },
    }
    self:RegisterBinders(self.ViewModel, Binders)
end

function ChocoboGenealogyItemView:OnButtonClick()
    ChocoboMainVM:ChangeCurSelectGeneID(self.ViewModel.ChocoboID)
    EventMgr:SendEvent(EventID.ChocoboGenealogyItemSelect, {ID = self.ViewModel.ChocoboID, IsByClick = true})
end

function ChocoboGenealogyItemView:OnChocoboGenealogyItemSelect(Params)
    if Params ~= nil and Params.ID == self.ViewModel.ChocoboID then
        self:PlayAnimation(self.AnimChecked)
        self.IsSelect = true
    else
        if self.IsSelect then
            self:PlayAnimation(self.AnimUnchecked)
        end
        self.IsSelect = false
    end
end

return ChocoboGenealogyItemView