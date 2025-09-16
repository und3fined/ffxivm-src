---
--- Author: Administrator
--- DateTime: 2024-03-08 14:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class PhotoStateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoStateItemView = LuaClass(UIView, true)

function PhotoStateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoStateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoStateItemView:OnInit()
	self.Binders = 
	{
		{ "Name", 				UIBinderSetText.New(self, self.TextName) },
		{ "Icon", 				UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IsSelected", 		UIBinderSetIsVisible.New(self, self.ImgSelect) },
	}
end

function PhotoStateItemView:OnDestroy()

end

function PhotoStateItemView:OnShow()

end

function PhotoStateItemView:OnHide()

end

function PhotoStateItemView:OnRegisterUIEvent()

end

function PhotoStateItemView:OnRegisterGameEvent()

end

function PhotoStateItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function PhotoStateItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then
		return
	end

	local VM = Params.Data
	if nil == VM then
		return
	end

	VM.IsSelected = IsSelected
end

return PhotoStateItemView