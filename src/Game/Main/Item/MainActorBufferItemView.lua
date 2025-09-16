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

local UIBinderAdapterBuffLeftTimeColor = require("Game/Buff/UIBinderAdapterBuffLeftTimeColor")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBuffPile = require("Binder/UIBinderSetBuffPile")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local BuffDefine = require("Game/Buff/BuffDefine")

---@class MainActorBufferItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CDPanel UFCanvasPanel
---@field FButtonSelect UFButton
---@field FImg_Buff UFImage
---@field FTextCD UFTextBlock
---@field FTextPile UFTextBlock
---@field IconStop UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainActorBufferItemView = LuaClass(UIView, true)

function MainActorBufferItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CDPanel = nil
	--self.FButtonSelect = nil
	--self.FImg_Buff = nil
	--self.FTextCD = nil
	--self.FTextPile = nil
	--self.IconStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.AdapterBufferTime = nil
end

function MainActorBufferItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainActorBufferItemView:OnInit()
	self.Binders = {
		{ "BuffIcon", UIBinderSetBrushFromMaterial.New(self, self.FImg_Buff) },
        { "IsEffective", UIBinderValueChangedCallback.New(self, nil, self.OnIsEffectiveChanged) },
		{ "IsBuffTimeDisplay", UIBinderSetIsVisible.New(self, self.CDPanel) },
		{ "LeftTime", UIBinderSetText.New(self, self.FTextCD) },
		{ "IsFromMajor", UIBinderAdapterBuffLeftTimeColor.New(UIBinderSetColorAndOpacityHex.New(self, self.FTextCD)) },
        { "Pile", UIBinderSetBuffPile.New(self, self.FTextPile) },
	}
end

function MainActorBufferItemView:OnDestroy()

end

function MainActorBufferItemView:OnShow()

end

function MainActorBufferItemView:OnHide()
	self.BuffVM = nil
end

function MainActorBufferItemView:OnRegisterUIEvent()

end

function MainActorBufferItemView:OnRegisterGameEvent()

end

function MainActorBufferItemView:OnRegisterTimer()

end

function MainActorBufferItemView:OnRegisterBinder()
	if nil == self.Params then return end

	local ViewModel = self.Params.Data
	if nil == ViewModel then return end

	self.BuffVM = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function MainActorBufferItemView:OnIsEffectiveChanged(NewValue, OldValue)
	if self.BuffVM == nil then
		FLOG_ERROR("MainActorBufferItemView.OnIsEffectiveChanged: self.BuffVM is nil")
		return
	end

    local BuffType = self.BuffVM.BuffSkillType
	UIUtil.SetImageDesaturate(self.FImg_Buff, nil, (BuffType == BuffDefine.BuffSkillType.Combat and not NewValue) and 1 or 0)  -- 0-正常，1-灰化
	UIUtil.SetIsVisible(self.IconStop, BuffType == BuffDefine.BuffSkillType.BonusState and not NewValue)
end

return MainActorBufferItemView