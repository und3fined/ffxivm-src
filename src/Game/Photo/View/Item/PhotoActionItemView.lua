---
--- Author: Administrator
--- DateTime: 2024-01-30 10:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local PhotoUtil = require("Game/Photo/PhotoUtil")

---@class PhotoActionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoActionItemView = LuaClass(UIView, true)

function PhotoActionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoActionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoActionItemView:OnInit()

end

function PhotoActionItemView:OnDestroy()

end

function PhotoActionItemView:OnShow()
	UIUtil.SetIsVisible(self.RedDot, false)
end

function PhotoActionItemView:OnHide()

end

function PhotoActionItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function PhotoActionItemView:OnRegisterGameEvent()

end

function PhotoActionItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.Binders = {
		{ "ColorHex", UIBinderSetColorAndOpacityHex.New(self, self.TextName) },
		{ "ColorHex", UIBinderSetColorAndOpacityHex.New(self, self.ImgIcon) },
		{ "ImgSelectVisible", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		-- { "IsEnable", UIBinderSetIsVisible.New(self, self.Mask, true, true) },
		{ "NameText", UIBinderSetText.New(self, self.TextName)},
		{ "ImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },

	}
	self:RegisterBinders(ViewModel, self.Binders)
end

-- function PhotoActionItemView:OnSelectChanged(IsSelected)
-- 	local Params = self.Params
-- 	if nil == Params then
-- 		return
-- 	end

-- 	local VM = Params.Data
-- 	if nil == VM then
-- 		return
-- 	end

-- 	VM.ImgSelectVisible = IsSelected
-- end

function PhotoActionItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	if not ViewModel.IsEnable then
		PhotoUtil.ShowAnimTips(ViewModel.Type, ViewModel.ID)
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

return PhotoActionItemView