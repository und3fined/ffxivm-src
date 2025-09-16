---
--- Author: Administrator
--- DateTime: 2025-03-11 20:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class GoldSauserMainPanelAwardThingItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommBackpack126SlotView
---@field IconCollect UFImage
---@field ImgSelect UFImage
---@field TextCategory UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelAwardThingItemView = LuaClass(UIView, true)

function GoldSauserMainPanelAwardThingItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm126Slot = nil
	--self.IconCollect = nil
	--self.ImgSelect = nil
	--self.TextCategory = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelAwardThingItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelAwardThingItemView:OnInit()

end

function GoldSauserMainPanelAwardThingItemView:OnDestroy()

end

function GoldSauserMainPanelAwardThingItemView:OnShow()
	UIUtil.SetIsVisible(self.Comm126Slot.Btn, false)
end

function GoldSauserMainPanelAwardThingItemView:OnHide()

end

function GoldSauserMainPanelAwardThingItemView:OnRegisterUIEvent()

end

function GoldSauserMainPanelAwardThingItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelAwardThingItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	local Binders = {
		{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "bMarked", UIBinderSetIsVisible.New(self, self.IconCollect) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "BelongTypeName", UIBinderSetText.New(self, self.TextCategory) },
	}

	self:RegisterBinders(VM, Binders)
	self.Comm126Slot:SetParams({Data = VM})
end

function GoldSauserMainPanelAwardThingItemView:OnSelectChanged(bSelect)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	VM:SetSelected(bSelect)
end

return GoldSauserMainPanelAwardThingItemView