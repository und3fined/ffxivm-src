---
--- Author: enqingchen
--- DateTime: 2022-03-14 17:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetItemIcon = require("Binder/UIBinderSetItemIcon")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

--@ViewModel
local MagicsparInlaySlotItemVM = require("Game/Magicspar/VM/MagicsparInlaySlotItemVM")

---@class MagicsparInlaySlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Eff UImage
---@field EffCircl UImage
---@field FBtn_Inlay UFButton
---@field FImg_Add UFImage
---@field FImg_Empty UFImage
---@field FImg_StoneIcon UFImage
---@field AnimBlueLoop UWidgetAnimation
---@field AnimRedLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInlaySlotItemView = LuaClass(UIView, true)

function MagicsparInlaySlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Eff = nil
	--self.EffCircl = nil
	--self.FBtn_Inlay = nil
	--self.FImg_Add = nil
	--self.FImg_Empty = nil
	--self.FImg_StoneIcon = nil
	--self.AnimBlueLoop = nil
	--self.AnimRedLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparInlaySlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInlaySlotItemView:OnInit()
	self.ViewModel = MagicsparInlaySlotItemVM.New()
end

function MagicsparInlaySlotItemView:OnDestroy()

end

function MagicsparInlaySlotItemView:OnShow()

end

function MagicsparInlaySlotItemView:OnHide()

end

function MagicsparInlaySlotItemView:OnRegisterUIEvent()

end

function MagicsparInlaySlotItemView:OnRegisterGameEvent()

end

function MagicsparInlaySlotItemView:OnRegisterBinder()
	local Binders = {
		{ "bInlay", UIBinderSetIsVisible.New(self, self.FImg_StoneIcon) },
		--{ "bInlay", UIBinderSetIsVisible.New(self, self.FImg_Add, true, true) },
		--{ "bInlay", UIBinderSetIsVisible.New(self, self.FImg_Empty, true, true) },
		{ "ResID", UIBinderSetItemIcon.New(self, self.FImg_StoneIcon, false) },
		{ "bSelect", UIBinderValueChangedCallback.New(self, nil, self.OnSlotSelectChange) },
		{ "bInlay", UIBinderValueChangedCallback.New(self, nil, self.OnSlotSelectChange) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function MagicsparInlaySlotItemView:OnSlotSelectChange(NewValue, OldValue)
	if self.ViewModel.bSelect == true then
		if self.ViewModel.bInlay == true then
			UIUtil.SetIsVisible(self.FImg_Add, false)
			UIUtil.SetIsVisible(self.FImg_Empty, false)
		else
			UIUtil.SetIsVisible(self.FImg_Add, false)
			UIUtil.SetIsVisible(self.FImg_Empty, true)
		end
	else
		if self.ViewModel.bInlay == true then
			UIUtil.SetIsVisible(self.FImg_Empty, false)
			UIUtil.SetIsVisible(self.FImg_Add, false)
		else
			UIUtil.SetIsVisible(self.FImg_Empty, false)
			UIUtil.SetIsVisible(self.FImg_Add, true)
		end
	end
end

function MagicsparInlaySlotItemView:InitSlot(InResID, Index, bNomal, OnClick)
	self.ViewModel:InitMagicsparSlot(InResID, Index, bNomal)
	UIUtil.AddOnClickedEvent(self, self.FBtn_Inlay, OnClick)
end

return MagicsparInlaySlotItemView