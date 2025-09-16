---
--- Author: peterxie
--- DateTime: 2024-03-29 10:32
--- Description: 地图分层列表项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class WorldMapLocateListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field TextPlace UFTextBlock
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapLocateListItemView = LuaClass(UIView, true)

function WorldMapLocateListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.TextPlace = nil
	--self.AnimClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapLocateListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapLocateListItemView:OnInit()
	self.Binders = {
		{ "PlaceName", UIBinderSetText.New(self, self.TextPlace) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisible", UIBinderSetIsVisible.New(self, self.ImgIcon) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
	}
end

function WorldMapLocateListItemView:OnDestroy()

end

function WorldMapLocateListItemView:OnShow()

end

function WorldMapLocateListItemView:OnHide()

end

function WorldMapLocateListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickedBtnChange)
end

function WorldMapLocateListItemView:OnRegisterGameEvent()

end

function WorldMapLocateListItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function WorldMapLocateListItemView:OnClickedBtnChange()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	_G.WorldMapMgr:ChangeMap(ViewModel.ID)
end

return WorldMapLocateListItemView