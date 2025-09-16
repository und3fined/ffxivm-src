---
--- Author: Administrator
--- DateTime: 2024-08-09 09:38
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
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")

---@class PersonInfoPlayerHeadItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnPlayer UFButton
---@field DeleteNode UFCanvasPanel
---@field IconCheck UFImage
---@field ImgAdd UFImage
---@field ImgBkg UFImage
---@field ImgBlack UFImage
---@field ImgFrame UFImage
---@field ImgPlayer UFImage
---@field ImgSelect UFImage
---@field PanelAdd UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoPlayerHeadItemView = LuaClass(UIView, true)

function PersonInfoPlayerHeadItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnPlayer = nil
	--self.DeleteNode = nil
	--self.IconCheck = nil
	--self.ImgAdd = nil
	--self.ImgBkg = nil
	--self.ImgBlack = nil
	--self.ImgFrame = nil
	--self.ImgPlayer = nil
	--self.ImgSelect = nil
	--self.PanelAdd = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerHeadItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerHeadItemView:OnInit()
	self.Binders = {
		{ "IsSelt", 	UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsInUse", 	UIBinderSetIsVisible.New(self, self.IconCheck) },
		{ "HeadIcon", 	UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgPlayer, "Texture") },
	}
end

function PersonInfoPlayerHeadItemView:OnDestroy()

end

function PersonInfoPlayerHeadItemView:OnShow()

end

function PersonInfoPlayerHeadItemView:OnHide()

end

function PersonInfoPlayerHeadItemView:OnRegisterUIEvent()

end

function PersonInfoPlayerHeadItemView:OnRegisterGameEvent()

end

function PersonInfoPlayerHeadItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.VM = Params.Data
	self:RegisterBinders(self.VM, self.Binders)
end

function PersonInfoPlayerHeadItemView:OnSelectChanged(IsSelected)
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

return PersonInfoPlayerHeadItemView