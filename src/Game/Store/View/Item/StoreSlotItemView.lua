
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local StoreDefine = require("Game/Store/StoreDefine")

local LSTR = _G.LSTR

---@class StoreSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgEquipment UFImage
---@field ImgIcon UFImage
---@field ImgQuality UFImage
---@field ImgSelect UFImage
---@field ImgSlot UFImage
---@field PanelPossess UFCanvasPanel
---@field TextPossess UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreSlotItemView = LuaClass(UIView, true)

function StoreSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgEquipment = nil
	--self.ImgIcon = nil
	--self.ImgQuality = nil
	--self.ImgSelect = nil
	--self.ImgSlot = nil
	--self.PanelPossess = nil
	--self.TextPossess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreSlotItemView:OnInit()
	self.Binders = {
		{ "SignIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "PartIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgEquipment) },
		{ "SlotBg", UIBinderSetBrushFromAssetPath.New(self, self.ImgSlot) },
		{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect, false, true, false) },
		{ "bOwned", UIBinderSetIsVisible.New(self, self.PanelPossess, false, true, false) },
	}
end

function StoreSlotItemView:OnDestroy()

end

function StoreSlotItemView:OnShow()
	self.TextPossess:SetText(LSTR(StoreDefine.SecondScreenType.Owned))
end

function StoreSlotItemView:OnHide()

end

function StoreSlotItemView:OnRegisterUIEvent()

end

function StoreSlotItemView:OnRegisterGameEvent()

end

function StoreSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreSlotItemView