---
--- Author: Administrator
--- DateTime: 2024-02-22 15:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class WardrobeBagSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field RichNum URichTextBox
---@field TextSlot1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeBagSlotItemView = LuaClass(UIView, true)

function WardrobeBagSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.RichNum = nil
	--self.TextSlot1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeBagSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeBagSlotItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextSlot1) },
		{ "Num", UIBinderSetText.New(self, self.RichNum)},
	}

	self.View = nil
	self.Callback = nil
end

function WardrobeBagSlotItemView:OnDestroy()

end

function WardrobeBagSlotItemView:OnShow()

end

function WardrobeBagSlotItemView:OnHide()

end

function WardrobeBagSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnClickButtonItem)
end

function WardrobeBagSlotItemView:OnRegisterGameEvent()
end

function WardrobeBagSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.BagSlot:SetParams({Data = ViewModel.BagSlotVM})
end

function WardrobeBagSlotItemView:SetCallback(View, Callback)
	self.View = View
	self.Callback = Callback
end

function WardrobeBagSlotItemView:OnClickButtonItem()
	if self.Callback~= nil then
		self.Callback(self.View, self.Callback)
	end
end


return WardrobeBagSlotItemView