---
--- Author: Administrator
--- DateTime: 2023-08-14 16:49
--- Description: 地图下拉列表项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")


---@class WorldMapTabDropDownItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgIcon02 UFImage
---@field ImgLine UFImage
---@field ImgSelect UFImage
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapTabDropDownItemView = LuaClass(UIView, true)

function WorldMapTabDropDownItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgIcon02 = nil
	--self.ImgLine = nil
	--self.ImgSelect = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapTabDropDownItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapTabDropDownItemView:OnInit()
	self.Binders = {
		{ "PlaceName", UIBinderSetText.New(self, self.TextContent) },
		{ "IsLocation", UIBinderSetIsVisible.New(self, self.ImgIcon, false, false, false) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "bHaveFlyRight", UIBinderSetIsVisible.New(self, self.ImgIcon02) },
		{ "IconFlyAdmitted", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon02) },
	}
end

function WorldMapTabDropDownItemView:OnDestroy()

end

function WorldMapTabDropDownItemView:OnShow()

end

function WorldMapTabDropDownItemView:OnHide()

end

function WorldMapTabDropDownItemView:OnRegisterUIEvent()

end

function WorldMapTabDropDownItemView:OnRegisterGameEvent()

end

function WorldMapTabDropDownItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return WorldMapTabDropDownItemView