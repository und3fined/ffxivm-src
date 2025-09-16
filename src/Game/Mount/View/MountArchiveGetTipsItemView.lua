---
--- Author: jamiyang
--- DateTime: 2023-08-08 19:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class MountArchiveGetTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGO UFButton
---@field ImgIcon UFImage
---@field TextWay UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountArchiveGetTipsItemView = LuaClass(UIView, true)

function MountArchiveGetTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGO = nil
	--self.ImgIcon = nil
	--self.TextWay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountArchiveGetTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountArchiveGetTipsItemView:OnInit()

end

function MountArchiveGetTipsItemView:OnDestroy()

end

function MountArchiveGetTipsItemView:OnShow()

end

function MountArchiveGetTipsItemView:OnHide()

end

function MountArchiveGetTipsItemView:OnRegisterUIEvent()

end

function MountArchiveGetTipsItemView:OnRegisterGameEvent()

end

function MountArchiveGetTipsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel
	local Binders = {
		{ "GetWayIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon, true) },
		{ "GetText",  UIBinderSetText.New(self, self.TextWay) },
	}
	self:RegisterBinders(ViewModel, Binders)

end

return MountArchiveGetTipsItemView