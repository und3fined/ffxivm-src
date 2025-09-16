---
--- Author: v_hggzhang
--- DateTime: 2022-05-11 15:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderAdapterBuffLeftTimeColor = require("Game/Buff/UIBinderAdapterBuffLeftTimeColor")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBuffPile = require("Binder/UIBinderSetBuffPile")
local BuffDefine = require("Game/Buff/BuffDefine")

---@class MainBuffSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BuffCD UFCanvasPanel
---@field CDPanel UFCanvasPanel
---@field FButtonSelect UFButton
---@field FImg_Buff UFImage
---@field FImg_Select UFImage
---@field FTextCD UFTextBlock
---@field FTextPile UFTextBlock
---@field FText_More UFTextBlock
---@field IconStop UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainBuffSlotView = LuaClass(UIView, true)

function MainBuffSlotView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BuffCD = nil
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

function MainBuffSlotView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainBuffSlotView:OnInit()
    self.FText_More:SetText("...")

    self.Binders = {
        {"BuffIcon", UIBinderSetBrushFromMaterial.New(self, self.FImg_Buff)},
        {"LeftTime", UIBinderSetText.New(self, self.FTextCD)},
        {"IsFromMajor", UIBinderAdapterBuffLeftTimeColor.New(UIBinderSetColorAndOpacityHex.New(self, self.FTextCD))},
        {"IsEffective", UIBinderValueChangedCallback.New(self, nil, self.OnIsEffectiveChanged)},
        {"IsBuffTimeDisplay", UIBinderSetIsVisible.New(self, self.CDPanel) },
        {"Pile", UIBinderSetBuffPile.New(self, self.FTextPile)},
    }
end

function MainBuffSlotView:OnDestroy()
end

function MainBuffSlotView:OnShow()
end

function MainBuffSlotView:OnHide()
    self.BuffVM = nil
end

function MainBuffSlotView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.FButtonSelect, self.OnClickButtonItem)
end

function MainBuffSlotView:OnRegisterGameEvent()
end

function MainBuffSlotView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then return end

    local ViewModel = self.Params.Data
    if nil == ViewModel then return end

    self.BuffVM = ViewModel
    self:RegisterBinders(ViewModel, self.Binders)
end

function MainBuffSlotView:OnClickButtonItem()
    local Params = self.Params
    if nil == Params then return end

    local Adapter = Params.Adapter
    if nil == Adapter then return end

    Adapter:OnItemClicked(self, Params.Index)
end

function MainBuffSlotView:OnIsEffectiveChanged(NewValue, OldValue)
	if self.BuffVM == nil then
		FLOG_ERROR("MainBuffSlotView.OnIsEffectiveChanged: self.BuffVM is nil")
		return
	end

    local BuffType = self.BuffVM.BuffSkillType
	UIUtil.SetImageDesaturate(self.FImg_Buff, nil, (BuffType == BuffDefine.BuffSkillType.Combat and not NewValue) and 1 or 0)  -- 0-正常，1-灰化
	UIUtil.SetIsVisible(self.IconStop, BuffType == BuffDefine.BuffSkillType.BonusState and not NewValue)
end

return MainBuffSlotView
