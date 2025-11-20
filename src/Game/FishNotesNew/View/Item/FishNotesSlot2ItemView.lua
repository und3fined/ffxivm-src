---
--- Author: v_vvxinchen
--- DateTime: 2025-06-03 10:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class FishNotesSlot2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommLight152Slot_UIBP CommLight152SlotView
---@field ImgFishCrown UFImage
---@field ImgInch UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNotesSlot2ItemView = LuaClass(UIView, true)

function FishNotesSlot2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommLight152Slot_UIBP = nil
	--self.ImgFishCrown = nil
	--self.ImgInch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNotesSlot2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommLight152Slot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNotesSlot2ItemView:OnInit()
	self.Binders = {
		{ "bSizeKing",UIBinderSetIsVisible.New(self, self.ImgFishCrown)},
		{ "bUnLockState",UIBinderSetIsVisible.New(self, self.ImgInch)},
		{ "InchIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgInch)},
	}
end

function FishNotesSlot2ItemView:OnDestroy()

end

function FishNotesSlot2ItemView:OnShow()

end

function FishNotesSlot2ItemView:OnHide()

end

function FishNotesSlot2ItemView:OnRegisterUIEvent()

end

function FishNotesSlot2ItemView:OnRegisterGameEvent()

end

function FishNotesSlot2ItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
	self.CommLight152Slot_UIBP:SetParams({Data = ViewModel})
end

return FishNotesSlot2ItemView