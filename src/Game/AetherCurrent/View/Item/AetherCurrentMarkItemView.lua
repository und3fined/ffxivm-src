---
--- Author: Alex
--- DateTime: 2024-03-28 10:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local AetherCurrentsMgr = require("Game/AetherCurrent/AetherCurrentsMgr")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local AetherCurrentCfg = require("TableCfg/AetherCurrentCfg")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local WindPulseSpringActivateType = ProtoRes.WindPulseSpringActivateType
local UnlockMapAnimDelayTime = AetherCurrentDefine.UnlockMapAnimDelayTime
local UnlockUIAnimDelayTime = AetherCurrentDefine.UnlockUIAnimDelayTime
local FLOG_INFO = _G.FLOG_INFO

---@class AetherCurrentMarkItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMark UFImage
---@field MI_DX_AetherCurrent_1 UFImage
---@field MI_DX_Common_AetherCurrent_1 UFImage
---@field AnimUnlockMapGreen UWidgetAnimation
---@field AnimUnlockMapYellow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentMarkItemView = LuaClass(UIView, true)

function AetherCurrentMarkItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMark = nil
	--self.MI_DX_AetherCurrent_1 = nil
	--self.MI_DX_Common_AetherCurrent_1 = nil
	--self.AnimUnlockMapGreen = nil
	--self.AnimUnlockMapYellow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentMarkItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentMarkItemView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetImageBrush.New(self, self.ImgMark) },
		{ "bWaitForPlayEffect", UIBinderValueChangedCallback.New(self, nil, self.OnPlayEffectWhenOpenPanel) },
	}
end

function AetherCurrentMarkItemView:OnDestroy()
end

function AetherCurrentMarkItemView:OnShow()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local bWaitForPlayEffect = ViewModel.bWaitForPlayEffect
	UIUtil.SetIsVisible(self.ImgMark, not bWaitForPlayEffect)
	UIUtil.SetRenderOpacity(self.ImgMark, bWaitForPlayEffect and 0 or 1)
end

function AetherCurrentMarkItemView:OnHide()

end

function AetherCurrentMarkItemView:OnRegisterUIEvent()

end

function AetherCurrentMarkItemView:OnRegisterGameEvent()

end

function AetherCurrentMarkItemView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

--- 打开界面时播放新的开放点的特效
function AetherCurrentMarkItemView:OnPlayEffectWhenOpenPanel(bWaitForPlayEffect)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	if not bWaitForPlayEffect then
		return
	end
	FLOG_INFO("AetherCurrentMarkItemView:OnPlayEffectWhenOpenPanel Show MapItem Marker Active")
	self:RegisterTimer(function()
		FLOG_INFO("AetherCurrentMarkItemView:OnPlayEffectWhenOpenPanel Show MapItem Marker Active Anim")
		self:PlayUnlockAnimation()
	end, UnlockMapAnimDelayTime + UnlockUIAnimDelayTime, nil, 1)
end

function AetherCurrentMarkItemView:PlayUnlockAnimation()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end
	local PointID = ViewModel.SubViewMarkerPointID
	if not PointID then
		return
	end
	UIUtil.SetIsVisible(self.ImgMark, true)
	local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
	if PointCfg then
		if PointCfg.CurrentType == WindPulseSpringActivateType.Interact then
			self:PlayAnimation(self.AnimUnlockMapGreen) -- 动画只修改了RenderOpcatiy
		elseif PointCfg.CurrentType == WindPulseSpringActivateType.Task then
			self:PlayAnimation(self.AnimUnlockMapYellow) -- 动画只修改了RenderOpcatiy
		end
	end
	AetherCurrentsMgr:ClearLastAddPointDataByPointIDInMap(PointID)
	ViewModel.bWaitForPlayEffect = false
end

return AetherCurrentMarkItemView