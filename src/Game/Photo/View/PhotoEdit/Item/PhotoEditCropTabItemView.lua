---
--- Author: Administrator
--- DateTime: 2025-06-30 10:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")


---@class PhotoEditCropTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIconNormal UFImage
---@field ImgIconSelect UFImage
---@field TextName UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoEditCropTabItemView = LuaClass(UIView, true)

function PhotoEditCropTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIconNormal = nil
	--self.ImgIconSelect = nil
	--self.TextName = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoEditCropTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoEditCropTabItemView:OnInit()
	self.Binders = 
	{
		{ "IsSelected", UIBinderSetIsChecked.New(self, self.ToggleBtn, true) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
	}
end

function PhotoEditCropTabItemView:OnDestroy()

end

function PhotoEditCropTabItemView:OnShow()

end

function PhotoEditCropTabItemView:OnHide()

end

function PhotoEditCropTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnBtnClicked)
end

function PhotoEditCropTabItemView:OnRegisterGameEvent()

end

function PhotoEditCropTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.ViewModel = Params.Data
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function PhotoEditCropTabItemView:OnBtnClicked()
    local Params = self.Params
    if nil == Params or nil == Params.Adapter then
        return
    end

    local Adapter = Params.Adapter
	Adapter:OnItemClicked(self, Params.Index)
end

function PhotoEditCropTabItemView:OnSelectChanged(IsSelected)
	if not self.ViewModel then
		return
	end
	self.ViewModel.IsSelected = IsSelected
end

return PhotoEditCropTabItemView