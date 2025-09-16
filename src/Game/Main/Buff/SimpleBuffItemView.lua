---
--- Author: v_hggzhang
--- DateTime: 2022-05-18 16:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local BuffDefine = require("Game/Buff/BuffDefine")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")
local UIBinderSetBuffPile = require("Binder/UIBinderSetBuffPile")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class SimpleBuffItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButtonSelect UFButton
---@field FImg_Buff UFImage
---@field FImg_SelectBuff UFImage
---@field FImg_SelectDebuff UFImage
---@field FTextPile UFTextBlock
---@field IconStop UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SimpleBuffItemView = LuaClass(UIView, true)

function SimpleBuffItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButtonSelect = nil
	--self.FImg_Buff = nil
	--self.FImg_SelectBuff = nil
	--self.FImg_SelectDebuff = nil
	--self.FTextPile = nil
	--self.IconStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SimpleBuffItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SimpleBuffItemView:OnInit()
    self.BuffVM = nil
    self.Binders = {
        {"BuffIcon", UIBinderSetBrushFromMaterial.New(self, self.FImg_Buff)},
        {"IsEffective", UIBinderValueChangedCallback.New(self, nil, self.OnIsEffectiveChanged)},
        {"Pile", UIBinderSetBuffPile.New(self, self.FTextPile)},
    }
end

function SimpleBuffItemView:OnDestroy()
end

function SimpleBuffItemView:OnShow()
end

function SimpleBuffItemView:OnHide()
    self.BuffVM = nil
end

function SimpleBuffItemView:OnRegisterGameEvent()
end

function SimpleBuffItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.FButtonSelect, self.OnClickButtonItem)
end

function SimpleBuffItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    self.BuffVM = ViewModel

    self:RegisterBinders(ViewModel, self.Binders)
end

function SimpleBuffItemView:OnClickButtonItem()
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

function SimpleBuffItemView:OnSelectChanged(IsSelected)
    if self.BuffVM == nil then
        FLOG_ERROR("SimpleBuffItemView.OnSelectChanged(): Invalid self.BuffVM")
        return
    end

    local IsNegative = (self.BuffVM.BuffActiveType == BuffDefine.BuffDisplayActiveType.Negative)
    UIUtil.SetIsVisible(self.FImg_SelectBuff, IsSelected and not IsNegative)
    UIUtil.SetIsVisible(self.FImg_SelectDebuff, IsSelected and IsNegative)
end

function SimpleBuffItemView:OnIsEffectiveChanged(NewValue, OldValue)
	if self.BuffVM == nil then
		FLOG_ERROR("SimpleBuffItemView.OnIsEffectiveChanged: self.BuffVM is nil")
		return
	end

    local BuffType = self.BuffVM.BuffSkillType
	UIUtil.SetImageDesaturate(self.FImg_Buff, nil, (BuffType == BuffDefine.BuffSkillType.Combat and not NewValue) and 1 or 0)  -- 0-正常，1-灰化
	UIUtil.SetIsVisible(self.IconStop, BuffType == BuffDefine.BuffSkillType.BonusState and not NewValue)
end

return SimpleBuffItemView
