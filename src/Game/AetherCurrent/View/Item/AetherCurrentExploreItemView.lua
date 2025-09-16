---
--- Author: Administrator
--- DateTime: 2023-09-04 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local UnlockDelayTime = AetherCurrentDefine.UnlockUIAnimDelayTime
local FLOG_INFO = _G.FLOG_INFO

---@class AetherCurrentExploreItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFinishi UFImage
---@field MI_DX_AetherCurrent_1 UFImage
---@field MI_DX_Common_AetherCurrent_1 UFImage
---@field AnimUnlockMap UWidgetAnimation
---@field AnimUnlockUI UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentExploreItemView = LuaClass(UIView, true)

function AetherCurrentExploreItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgFinishi = nil
	--self.MI_DX_AetherCurrent_1 = nil
	--self.MI_DX_Common_AetherCurrent_1 = nil
	--self.AnimUnlockMap = nil
	--self.AnimUnlockUI = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentExploreItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentExploreItemView:OnInit()
	self.Binders = {
		{ "bActived", UIBinderSetIsVisible.New(self, self.ImgFinishi) },
		{ "StateChangeToActived", UIBinderValueChangedCallback.New(self, nil, self.OnPointStateChangedCallback) },
	}
end

function AetherCurrentExploreItemView:OnDestroy()

end

function AetherCurrentExploreItemView:OnShow()

end

function AetherCurrentExploreItemView:OnHide()

end

function AetherCurrentExploreItemView:OnRegisterUIEvent()

end

function AetherCurrentExploreItemView:OnRegisterGameEvent()

end

function AetherCurrentExploreItemView:OnRegisterBinder()
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

function AetherCurrentExploreItemView:OnPointStateChangedCallback(NewState, OldState)
	if NewState == OldState or NewState == false then
		return
	end
	FLOG_INFO("AetherCurrentExploreItemView:OnPointStateChangedCallback Show MapItem Marker Active")
	self:RegisterTimer(function()
		FLOG_INFO("AetherCurrentExploreItemView:OnPointStateChangedCallback Show MapItem Marker Active Anim")
		self:PlayUnlockAnimation()
	end, UnlockDelayTime, nil, 1)
end

function AetherCurrentExploreItemView:PlayUnlockAnimation()
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
	self:PlayAnimation(self.AnimUnlockUI) -- 动画只修改了RenderOpcatiy
end

return AetherCurrentExploreItemView