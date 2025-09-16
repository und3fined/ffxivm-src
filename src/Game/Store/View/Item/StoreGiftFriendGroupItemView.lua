
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class StoreGiftFriendGroupItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgDown UFImage
---@field ImgUp UFImage
---@field RichTextDesc URichTextBox
---@field ToggleItem UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreGiftFriendGroupItemView = LuaClass(UIView, true)

function StoreGiftFriendGroupItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgDown = nil
	--self.ImgUp = nil
	--self.RichTextDesc = nil
	--self.ToggleItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreGiftFriendGroupItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreGiftFriendGroupItemView:OnInit()

end

function StoreGiftFriendGroupItemView:OnDestroy()

end

function StoreGiftFriendGroupItemView:OnShow()
end

function StoreGiftFriendGroupItemView:OnHide()

end

function StoreGiftFriendGroupItemView:OnRegisterUIEvent()

end

function StoreGiftFriendGroupItemView:OnRegisterGameEvent()

end

function StoreGiftFriendGroupItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	local Binders = {
		{ "Desc",	UIBinderSetText.New(self, self.RichTextDesc) },
		{ "IsExpanded",	UIBinderSetIsChecked.New(self, self.ToggleItem, false, true) },
	}
	self:RegisterBinders(ViewModel, Binders)
end

return StoreGiftFriendGroupItemView