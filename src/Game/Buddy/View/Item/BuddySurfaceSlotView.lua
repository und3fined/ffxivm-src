---
--- Author: Administrator
--- DateTime: 2023-11-30 14:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class BuddySurfaceSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSlot CommBackpack126SlotView
---@field ImgCheck UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySurfaceSlotView = LuaClass(UIView, true)

function BuddySurfaceSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSlot = nil
	--self.ImgCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySurfaceSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySurfaceSlotView:OnInit()
	self.Binders = {
		{ "ImgCheckVisible", UIBinderSetIsVisible.New(self, self.ImgCheck) },
	}
end

function BuddySurfaceSlotView:OnDestroy()

end

function BuddySurfaceSlotView:OnShow()

end

function BuddySurfaceSlotView:OnHide()

end

function BuddySurfaceSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommSlot.Btn, self.OnClickButtonItem)
end

function BuddySurfaceSlotView:OnRegisterGameEvent()

end

function BuddySurfaceSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.CommSlot:SetParams({Data = ViewModel.ItemVM})

end

function BuddySurfaceSlotView:OnClickButtonItem()
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

return BuddySurfaceSlotView