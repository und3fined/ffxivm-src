---
--- Author: Administrator
--- DateTime: 2024-03-19 11:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
--local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetMaterialVectorParameterValue = require("Binder/UIBinderSetMaterialVectorParameterValue")
local UIBinderSetMaterialScalarParameterValue = require("Binder/UIBinderSetMaterialScalarParameterValue")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DiscoverNoteMgr = require("Game/SightSeeingLog/DiscoverNoteMgr")
local FLOG_INFO = _G.FLOG_INFO

---@class SightSeeingLogListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_27 UFCanvasPanel
---@field ImgFrameSelect UFImage
---@field ImgFrameSelectEFF UFImage
---@field ImgPhoto UFImage
---@field MI_DX_Transform_SightSeeing_2 UFImage
---@field P_DX_SightSeeingLog_1 UUIParticleEmitter
---@field PanelFrameSelect UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field TextNumber UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SightSeeingLogListItemView = LuaClass(UIView, true)

function SightSeeingLogListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_27 = nil
	--self.ImgFrameSelect = nil
	--self.ImgFrameSelectEFF = nil
	--self.ImgPhoto = nil
	--self.MI_DX_Transform_SightSeeing_2 = nil
	--self.P_DX_SightSeeingLog_1 = nil
	--self.PanelFrameSelect = nil
	--self.RedDot2 = nil
	--self.TextNumber = nil
	--self.AnimClick = nil
	--self.AnimIn1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SightSeeingLogListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SightSeeingLogListItemView:OnInit()
	self.Binders = {
		{"IconPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgPhoto, "MainTexture")},
		{"Color", UIBinderSetMaterialVectorParameterValue.New(self, self.ImgPhoto, "Color")},
		{"Int", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgPhoto, "Int")},
		{"Tint", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgPhoto, "Tint")},
		{"Opacity", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgPhoto, "Opacity")},
		{"IndexText", UIBinderSetText.New(self, self.TextNumber)},
		{"bCompleted", UIBinderSetIsVisible.New(self, self.ImgPhoto)},
		{"AnimInSwitch", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimNotify)},
		{"bSelected", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimClickNotify)},
		{"RedDotName", UIBinderValueChangedCallback.New(self, nil, self.OnSetItemRedDotName)},
		{"TextNumberColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNumber)},
		{"OffsetAngle", UIBinderSetRenderTransformAngle.New(self, self.FCanvasPanel_27)},
		{"bShowPerfectCondEffect", UIBinderValueChangedCallback.New(self, nil, self.OnShowOrHidePerfectCondEffect)},
	}
end

function SightSeeingLogListItemView:OnDestroy()

end

function SightSeeingLogListItemView:OnShow()

end

function SightSeeingLogListItemView:OnHide()

end

function SightSeeingLogListItemView:OnRegisterUIEvent()

end

function SightSeeingLogListItemView:OnRegisterGameEvent()

end

function SightSeeingLogListItemView:OnRegisterBinder()
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

function SightSeeingLogListItemView:OnPlayAnimNotify()
	self:PlayAnimation(self.AnimIn1)
end

function SightSeeingLogListItemView:OnPlayAnimClickNotify(bSelected)
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	if bSelected then
		self:PlayAnimation(self.AnimClick)
		-- FLOG_INFO("SightSeeingLogListItemView:OnPlayAnimClickNotify selected")

		local NoteID = ViewModel.ItemID
		if NoteID then
			DiscoverNoteMgr:RemoveNewUnlockNoteItemRedDot(NoteID)
		end
	else
		--self:PlayAnimation(self.AnimClick, 0.0, 1, _G.UE.EUMGSequencePlayMode.Reverse)
		self.P_DX_SightSeeingLog_1:ResetParticle()
		self:StopAnimation(self.AnimClick)
		UIUtil.SetIsVisible(self.PanelFrameSelect, false)
		-- FLOG_INFO("SightSeeingLogListItemView:OnPlayAnimClickNotify select cancel")
	end
end

function SightSeeingLogListItemView:OnSetItemRedDotName(Name, OldValue)
	if Name == OldValue then
		return
	end
	self.RedDot2:SetRedDotNameByString(Name)
end

function SightSeeingLogListItemView:OnShowOrHidePerfectCondEffect(bShow)
	UIUtil.SetIsVisible(self.MI_DX_Transform_SightSeeing_2, bShow)
end

return SightSeeingLogListItemView