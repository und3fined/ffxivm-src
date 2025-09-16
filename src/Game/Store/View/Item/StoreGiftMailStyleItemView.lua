
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class StoreGiftMailStyleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMailStyle UFImage
---@field PanelLock UFCanvasPanel
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreGiftMailStyleItemView = LuaClass(UIView, true)

function StoreGiftMailStyleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMailStyle = nil
	--self.PanelLock = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreGiftMailStyleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreGiftMailStyleItemView:OnInit()

end

function StoreGiftMailStyleItemView:OnDestroy()

end

function StoreGiftMailStyleItemView:OnShow()

end

function StoreGiftMailStyleItemView:OnHide()

end

function StoreGiftMailStyleItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickButtonItem)
end

function StoreGiftMailStyleItemView:OnRegisterGameEvent()

end

function StoreGiftMailStyleItemView:OnRegisterBinder()
	local Binders = {
		{ "IconPath", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgMailStyle) },
		{ "Islock", 		UIBinderSetIsVisible.New(self, self.PanelLock) },
		{ "IsSelected", 	UIBinderSetIsChecked.New(self, self.ToggleBtn) },
	}
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, Binders)
end

function StoreGiftMailStyleItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	
	Adapter:OnItemClicked(self, Params.Index)

end

return StoreGiftMailStyleItemView