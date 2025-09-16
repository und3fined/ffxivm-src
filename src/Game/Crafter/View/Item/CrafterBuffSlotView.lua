---
--- Author: henghaoli
--- DateTime: 2024-12-27 18:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")

local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderAdapterBuffLeftTimeColor = require("Game/Buff/UIBinderAdapterBuffLeftTimeColor")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBuffPile = require("Binder/UIBinderSetBuffPile")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local BuffDefine = require("Game/Buff/BuffDefine")

---@class CrafterBuffSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CDPanel UFCanvasPanel
---@field FButtonSelect UFButton
---@field FImg_Buff UFImage
---@field FImg_Select UFImage
---@field FTextCD UFTextBlock
---@field FTextPile UFTextBlock
---@field FText_More UFTextBlock
---@field IconStop UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterBuffSlotView = LuaClass(UIView, true)

function CrafterBuffSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CDPanel = nil
	--self.FButtonSelect = nil
	--self.FImg_Buff = nil
	--self.FImg_Select = nil
	--self.FTextCD = nil
	--self.FTextPile = nil
	--self.FText_More = nil
	--self.IconStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterBuffSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterBuffSlotView:OnInit()
    self.FText_More:SetText("...")

    self.Binders = {
        {"BuffIcon", UIBinderSetBrushFromMaterial.New(self, self.FImg_Buff)},
        {"LeftTime", UIBinderSetText.New(self, self.FTextCD)},
        {"IsFromMajor", UIBinderAdapterBuffLeftTimeColor.New(UIBinderSetColorAndOpacityHex.New(self, self.FTextCD))},
        {"IsBuffTimeDisplay", UIBinderSetIsVisible.New(self, self.CDPanel) },
        {"IsEffective", UIBinderValueChangedCallback.New(self, nil, self.OnIsEffectiveChanged)},
        {"Pile", UIBinderSetBuffPile.New(self, self.FTextPile)},
    }
end

function CrafterBuffSlotView:OnDestroy()

end

function CrafterBuffSlotView:OnShow()

end

function CrafterBuffSlotView:OnHide()
    self.BuffVM = nil
end

function CrafterBuffSlotView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.FButtonSelect, self.OnClickButtonItem)
end

function CrafterBuffSlotView:OnRegisterGameEvent()

end

function CrafterBuffSlotView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = self.Params.Data
    if nil == ViewModel then return end

    self.BuffVM = ViewModel

    self:RegisterBinders(ViewModel, self.Binders)
end

function CrafterBuffSlotView:OnClickButtonItem()
    local Params = self.Params
    if nil == Params then return end

    local Adapter = Params.Adapter
    if nil == Adapter then return end

    Adapter:OnItemClicked(self, Params.Index)
end

function CrafterBuffSlotView:OnIsEffectiveChanged(NewValue, OldValue)
	if self.BuffVM == nil then
		FLOG_ERROR("CrafterBuffSlotView.OnIsEffectiveChanged: self.BuffVM is nil")
		return
	end

    local BuffType = self.BuffVM.BuffSkillType
	UIUtil.SetImageDesaturate(self.FImg_Buff, nil, (BuffType == BuffDefine.BuffSkillType.Combat and not NewValue) and 1 or 0)  -- 0-正常，1-灰化
	UIUtil.SetIsVisible(self.IconStop, BuffType == BuffDefine.BuffSkillType.BonusState and not NewValue)
end

return CrafterBuffSlotView