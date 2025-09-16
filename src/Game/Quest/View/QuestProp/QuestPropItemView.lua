---
--- Author: lydianwang
--- DateTime: 2023-05-11 19:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class QuestPropItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnUnselect UFButton
---@field ItemSlot CommBackpackSlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local QuestPropItemView = LuaClass(UIView, true)

local OPAQUE = 1
local TRANSLUCENT = 0.5

function QuestPropItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnUnselect = nil
	--self.ItemSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function QuestPropItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function QuestPropItemView:OnInit()
	self.bSelected = false
end

function QuestPropItemView:OnDestroy()

end

function QuestPropItemView:OnShow()

end

function QuestPropItemView:OnHide()

end

function QuestPropItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnUnselect, self.OnClickedUnselect)
end

function QuestPropItemView:OnRegisterGameEvent()

end

function QuestPropItemView:OnRegisterBinder()
	if self.Params.Data == nil then return end

	local Binders = {
		{ "bShowUnselect", UIBinderSetIsVisible.New(self, self.BtnUnselect, false, true) },
	}
	self:RegisterBinders(self.Params.Data, Binders)
end

function QuestPropItemView:OnSelectChanged(IsSelected)
	self.ItemSlot:OnSelectChanged(IsSelected)
end

function QuestPropItemView:OnClickedUnselect()
	local Adapter = self.Params.Adapter
	if Adapter and Adapter.OnClickedUnselect then
		Adapter:OnClickedUnselect(self.Params.Index, self.Params.Data, self)
	end
end

return QuestPropItemView