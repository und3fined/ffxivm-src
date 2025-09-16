---
--- Author: Administrator
--- DateTime: 2024-08-16 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")


local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")

---@class PersonInfoPlayerHeadCustItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPlayer UFButton
---@field CommonRedDot CommonRedDotView
---@field IconCheck UFImage
---@field ImgAdd UFImage
---@field ImgBkg UFImage
---@field ImgBkg2 UFImage
---@field ImgBlack UFImage
---@field ImgFrame UFImage
---@field ImgPlayer UFImage
---@field ImgSelect UFImage
---@field PanelAdd UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoPlayerHeadCustItemView = LuaClass(UIView, true)

function PersonInfoPlayerHeadCustItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPlayer = nil
	--self.CommonRedDot = nil
	--self.IconCheck = nil
	--self.ImgAdd = nil
	--self.ImgBkg = nil
	--self.ImgBkg2 = nil
	--self.ImgBlack = nil
	--self.ImgFrame = nil
	--self.ImgPlayer = nil
	--self.ImgSelect = nil
	--self.PanelAdd = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerHeadCustItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerHeadCustItemView:OnInit()
	self.Binders = {
		{ "IsSelt", 	UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsInUse", 	UIBinderSetIsVisible.New(self, self.IconCheck) },
		-- { "HeadIcon", 	UIBinderSetBrushFromAssetPath.New(self, self.ImgFrame) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.PanelAdd) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.BtnPlayer, false, true) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ImgPlayer, true) },

		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ImgFrame, true) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ImgBkg, true) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ImgBkg2) },

		{ "Idx", 	UIBinderValueChangedCallback.New(self, nil, self.OnValChgIdx) },

		{ "HeadIconUrl", 	UIBinderValueChangedCallback.New(self, nil, self.OnValChgUrl) },
	}
end

function PersonInfoPlayerHeadCustItemView:OnDestroy()

end

function PersonInfoPlayerHeadCustItemView:OnShow()

end

function PersonInfoPlayerHeadCustItemView:OnHide()

end

function PersonInfoPlayerHeadCustItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPlayer, self.OnBtnEdit)
end

function PersonInfoPlayerHeadCustItemView:OnRegisterGameEvent()

end

function PersonInfoPlayerHeadCustItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.VM = Params.Data
	self:RegisterBinders(self.VM, self.Binders)
end

function PersonInfoPlayerHeadCustItemView:OnValChgUrl(Val)
	if string.isnilorempty(Val) then
		return
	end

	PersonPortraitHeadHelper.SetHeadByUrl(self.ImgPlayer, Val, 'HeadCustItem::OnValChgUrl')
end

function PersonInfoPlayerHeadCustItemView:OnValChgIdx(Val)
	if Val == 1 then
		self.CommonRedDot:SetRedDotIDByID(202)
	else
		self.CommonRedDot:SetRedDotIDByID(0)
	end
end

function PersonInfoPlayerHeadCustItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then
		return
	end

	local VM = Params.Data
	if nil == VM then
		return
	end

	VM.IsSelt = IsSelected
end

function PersonInfoPlayerHeadCustItemView:OnBtnEdit()
	UIViewMgr:ShowView(UIViewID.PersonInfoHeadPanel)
end

return PersonInfoPlayerHeadCustItemView