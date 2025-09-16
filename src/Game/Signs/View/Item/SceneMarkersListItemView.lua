---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-21 15:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local SceneMarkersMainVM = require("Game/Signs/VM/SceneMarkersMainVM")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class SceneMarkersListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnCover UFButton
---@field BtnDelete UFButton
---@field ImgCurrentBG UFImage
---@field ImgFocus UFImage
---@field ImgOtherBG UFImage
---@field PanelList UFCanvasPanel
---@field TextList UFTextBlock
---@field TextSerialNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SceneMarkersListItemView = LuaClass(UIView, true)

function SceneMarkersListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnCover = nil
	--self.BtnDelete = nil
	--self.ImgCurrentBG = nil
	--self.ImgFocus = nil
	--self.ImgOtherBG = nil
	--self.PanelList = nil
	--self.TextList = nil
	--self.TextSerialNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SceneMarkersListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SceneMarkersListItemView:OnInit()
	self.Binders = {
		{ "Index", 					UIBinderSetTextFormat.New(self, self.TextSerialNumber, "%02d.")},
		{ "TittleText", 			UIBinderSetText.New(self, self.TextList) },
		{ "BtnBtnCoverVisible", 	UIBinderSetIsVisible.New(self, self.BtnCover, nil, true) },
		{ "BtnBtnDeleteVisible", 	UIBinderSetIsVisible.New(self, self.BtnDelete, nil, true) },
		{ "BtnBtnAddVisible", 		UIBinderSetIsVisible.New(self, self.BtnAdd, nil, true) },
		{ "IsSelected", 			UIBinderSetIsVisible.New(self, self.ImgFocus) },
		{ "IsEnable", 				UIBinderSetIsVisible.New(self, self.ImgCurrentBG) },
		{ "IsEnable", 				UIBinderSetIsVisible.New(self, self.ImgOtherBG, true) },
		{ "TextColor", 				UIBinderSetColorAndOpacityHex.New(self, self.TextSerialNumber) },
		{ "TextColor", 				UIBinderSetColorAndOpacityHex.New(self, self.TextList) },
	}
	self.IsClickedBtnCover = false
	self.IsClickedBtnDelete = false
end

function SceneMarkersListItemView:OnDestroy()

end

function SceneMarkersListItemView:OnShow()

end

function SceneMarkersListItemView:OnHide()

end

function SceneMarkersListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickBtnAdd)
	UIUtil.AddOnClickedEvent(self, self.BtnCover, self.OnClickBtnCover)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickBtnDelete)

end

function SceneMarkersListItemView:OnRegisterGameEvent()

end

function SceneMarkersListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function SceneMarkersListItemView:OnClickBtnAdd()
	local Params = self.Params
	if(Params and Params.Adapter) then
		Params.Adapter:OnItemClicked(self, Params.Index)
	end
end

function SceneMarkersListItemView:OnClickBtnCover()
	self.IsClickedBtnCover = true
	local Params = self.Params
	if(Params and Params.Adapter) then
		Params.Adapter:OnItemClicked(self, Params.Index)
	end
end

function SceneMarkersListItemView:OnClickBtnDelete()
	self.IsClickedBtnDelete = true
	local Params = self.Params
	if(Params and Params.Adapter) then
		Params.Adapter:OnItemClicked(self, Params.Index)
	end
end

function SceneMarkersListItemView:OnSelectChanged(IsSelected)
	self.ViewModel.IsSelected = IsSelected
end

return SceneMarkersListItemView