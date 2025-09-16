---
--- Author: anypkvcai
--- DateTime: 2021-04-26 16:18
--- Description:
---

local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local UIBinderAdapterBuffLeftTimeColor = require("Game/Buff/UIBinderAdapterBuffLeftTimeColor")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBuffPile = require("Binder/UIBinderSetBuffPile")
local BuffDefine = require("Game/Buff/BuffDefine")

---@class TeamBufferItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BuffCD UFCanvasPanel
---@field CDPanel UFCanvasPanel
---@field FImg_Buff UFImage
---@field FTextCD UFTextBlock
---@field FTextPile UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamBufferItemView = LuaClass(UIView, true)

function TeamBufferItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BuffCD = nil
	--self.CDPanel = nil
	--self.FImg_Buff = nil
	--self.FTextCD = nil
	--self.FTextPile = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.AdapterBufferTime = nil
end

function TeamBufferItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamBufferItemView:OnInit()
    self.Binders = {
        { "BuffIcon", UIBinderSetBrushFromMaterial.New(self, self.FImg_Buff) },
        { "IsBuffTimeDisplay", UIBinderSetIsVisible.New(self, self.CDPanel) },
		{ "LeftTime", UIBinderSetText.New(self, self.FTextCD) },
        { "IsEffective", UIBinderValueChangedCallback.New(self, nil, self.OnIsEffectiveChanged) },
		{ "IsFromMajor", UIBinderAdapterBuffLeftTimeColor.New(UIBinderSetColorAndOpacityHex.New(self, self.FTextCD)) },
        { "Pile", UIBinderSetBuffPile.New(self, self.FTextPile) },
    }
end

function TeamBufferItemView:OnDestroy()
end

function TeamBufferItemView:OnShow()
end

function TeamBufferItemView:OnHide()
end

function TeamBufferItemView:OnRegisterUIEvent()
end

function TeamBufferItemView:OnRegisterGameEvent()
end

function TeamBufferItemView:OnRegisterTimer()
end

function TeamBufferItemView:OnRegisterBinder()
    if nil == self.Params then
        return
    end

    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    self.BuffVM = ViewModel

    self:RegisterBinders(ViewModel, self.Binders)
end

function TeamBufferItemView:OnIsEffectiveChanged(NewValue, OldValue)
	if self.BuffVM == nil then
		FLOG_ERROR("MainActorBufferItemView.OnIsEffectiveChanged: self.BuffVM is nil")
		return
	end

    local BuffType = self.BuffVM.BuffSkillType
	UIUtil.SetImageDesaturate(self.FImg_Buff, nil, (BuffType == BuffDefine.BuffSkillType.Combat and not NewValue) and 1 or 0)  -- 0-正常，1-灰化
end

return TeamBufferItemView
