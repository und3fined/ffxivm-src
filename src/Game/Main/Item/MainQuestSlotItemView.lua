---
--- Author: sammrli
--- DateTime: 2025-02-20 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class MainQuestSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack74Slot CommBackpack74SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainQuestSlotItemView = LuaClass(UIView, true)

function MainQuestSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack74Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainQuestSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainQuestSlotItemView:OnInit()

end

function MainQuestSlotItemView:OnDestroy()

end

function MainQuestSlotItemView:OnShow()

end

function MainQuestSlotItemView:OnHide()

end

function MainQuestSlotItemView:OnRegisterUIEvent()
	self.CommBackpack74Slot:SetClickButtonCallback(self, self.OnClickItemHandle)
end

function MainQuestSlotItemView:OnRegisterGameEvent()

end

function MainQuestSlotItemView:OnRegisterBinder()

end

function MainQuestSlotItemView:OnClickItemHandle()
	local Params = self.Params
	if not Params then return end
	local ViewModel = Params.Data
	if not ViewModel then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ViewModel.ResID, self)
end

return MainQuestSlotItemView