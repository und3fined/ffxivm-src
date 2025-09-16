---
--- Author: Administrator
--- DateTime: 2023-11-16 15:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")


---@class BuddyFeedItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLove UFImage
---@field ItemSlot CommBackpack126SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyFeedItemView = LuaClass(UIView, true)

function BuddyFeedItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLove = nil
	--self.ItemSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyFeedItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyFeedItemView:OnInit()
	self.Binders = {
		{ "LoveImgVisible", UIBinderSetIsVisible.New(self, self.ImgLove) },
		
	}
end

function BuddyFeedItemView:OnDestroy()

end

function BuddyFeedItemView:OnShow()
end

function BuddyFeedItemView:OnHide()

end

function BuddyFeedItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ItemSlot.Btn, self.OnClickButtonItem)
end

function BuddyFeedItemView:OnRegisterGameEvent()

end

function BuddyFeedItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.ItemSlot:SetParams({Data = ViewModel.ItemVM})
end

function BuddyFeedItemView:OnClickButtonItem()
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


return BuddyFeedItemView