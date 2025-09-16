---
--- Author: Administrator
--- DateTime: 2023-09-04 10:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local UnlockDelayTime = AetherCurrentDefine.UnlockUIAnimDelayTime

---@class AetherCurrentTaskItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFinishi UFImage
---@field MI_DX_AetherCurrent_1 UFImage
---@field MI_DX_Common_AetherCurrent_1 UFImage
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentTaskItemView = LuaClass(UIView, true)

function AetherCurrentTaskItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgFinishi = nil
	--self.MI_DX_AetherCurrent_1 = nil
	--self.MI_DX_Common_AetherCurrent_1 = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentTaskItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentTaskItemView:OnInit()
	self.Binders = {
		{ "bActived", UIBinderSetIsVisible.New(self, self.ImgFinishi) },
		{ "StateChangeToActived", UIBinderValueChangedCallback.New(self, nil, self.OnPointStateChangedCallback) },
	}
end

function AetherCurrentTaskItemView:OnDestroy()

end

function AetherCurrentTaskItemView:OnShow()

end

function AetherCurrentTaskItemView:OnHide()

end

function AetherCurrentTaskItemView:OnRegisterUIEvent()

end

function AetherCurrentTaskItemView:OnRegisterGameEvent()

end

function AetherCurrentTaskItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function AetherCurrentTaskItemView:OnPointStateChangedCallback(NewState, OldState)
	if NewState == OldState or NewState == false then
		return
	end

	self:RegisterTimer(function()
		self:PlayUnlockAnimation()
	end, UnlockDelayTime, nil, 1)
end

function AetherCurrentTaskItemView:PlayUnlockAnimation()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	ViewModel.bActived = true
	ViewModel.StateChangeToActived = false
	self:PlayAnimation(self.AnimUnlock) -- 动画只修改了RenderOpcatiy
end


function AetherCurrentTaskItemView:OnAnimationFinished(Anim)
	
end

return AetherCurrentTaskItemView