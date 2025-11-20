---
--- Author: richyczhou
--- DateTime: 2025-09-08 19:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")

local FLOG_INFO = _G.FLOG_INFO

---@class EquipColorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnColor UFButton
---@field ImgColor UFImage
---@field ImgSelectEffect UFImage
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipColorItemView = LuaClass(UIView, true)

function EquipColorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnColor = nil
	--self.ImgColor = nil
	--self.ImgSelectEffect = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipColorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipColorItemView:OnInit()
    self.Binders = {
        { "bItemSelect", UIBinderSetIsVisible.New(self, self.ImgSelectEffect)},
        --{ "bItemSelect", UIBinderSetIsVisible.New(self, self.TextNum) },
        { "ColorID", UIBinderSetText.New(self, self.TextNum)},
        { "HexColor", UIBinderSetBrushTintColorHex.New(self, self.ImgColor) },
    }
end

function EquipColorItemView:OnDestroy()

end

function EquipColorItemView:OnShow()
    --FLOG_INFO("[EquipColorItemView:OnShow]")
end

function EquipColorItemView:OnHide()

end

function EquipColorItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnColor, self.OnColorButtonClicked)
end

function EquipColorItemView:OnRegisterGameEvent()

end

function EquipColorItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    ---@type EquipColorItemVM
    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    --print("[EquipColorItemView:OnRegisterBinder] VM:" .. ViewModel:GetName())
    self:RegisterBinders(ViewModel, self.Binders)
end

function EquipColorItemView:OnColorButtonClicked()
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

function EquipColorItemView:OnSelectChanged(IsSelected)
    ---@type EquipColorItemVM
    local ViewModel = self.Params.Data
    if ViewModel and ViewModel.OnSelectedChange then
        ViewModel:OnSelectedChange(IsSelected)
    end
end

return EquipColorItemView