---
--- Author: Administrator
--- DateTime: 2025-07-22 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local BodyGuardEnumStage = GoldSauserMainPanelDefine.BodyGuardEnumStage

---@class GoldSauserMainBodyguardStageItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgIcon_1 UFImage
---@field ImgIcon_2 UFImage
---@field Anim1 UWidgetAnimation
---@field Anim2 UWidgetAnimation
---@field Anim3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainBodyguardStageItemView = LuaClass(UIView, true)

function GoldSauserMainBodyguardStageItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgIcon_1 = nil
	--self.ImgIcon_2 = nil
	--self.Anim1 = nil
	--self.Anim2 = nil
	--self.Anim3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainBodyguardStageItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainBodyguardStageItemView:OnInit()
	self.Binders = {
		{"State", UIBinderValueChangedCallback.New(self, nil, self.OnItemStageStateChange)},		
	}
end

function GoldSauserMainBodyguardStageItemView:OnDestroy()

end

function GoldSauserMainBodyguardStageItemView:OnShow()

end

function GoldSauserMainBodyguardStageItemView:OnHide()

end

function GoldSauserMainBodyguardStageItemView:OnRegisterUIEvent()

end

function GoldSauserMainBodyguardStageItemView:OnRegisterGameEvent()

end

function GoldSauserMainBodyguardStageItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSauserMainBodyguardStageItemView:OnItemStageStateChange(NewState)
	if not NewState then
		return
	end

	if NewState == BodyGuardEnumStage.Running then
		self:PlayAnimation(self.Anim1)
	elseif NewState == BodyGuardEnumStage.Finished then
		self:PlayAnimation(self.Anim2)
	elseif NewState == BodyGuardEnumStage.NotStart then
		self:PlayAnimation(self.Anim3)
	end
end

return GoldSauserMainBodyguardStageItemView