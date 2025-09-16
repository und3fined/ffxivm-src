---
--- Author: Administrator
--- DateTime: 2024-12-11 16:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class BattlePassAdvanceListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Item96Slot BattlePassAdvance96SlotView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassAdvanceListItemView = LuaClass(UIView, true)

function BattlePassAdvanceListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Item96Slot = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassAdvanceListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Item96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassAdvanceListItemView:OnInit()
	self.Binders = {
		{ "ItemName", UIBinderSetText.New(self, self.TextName)},
	}
end

function BattlePassAdvanceListItemView:OnDestroy()

end

function BattlePassAdvanceListItemView:OnShow()

end

function BattlePassAdvanceListItemView:OnHide()

end

function BattlePassAdvanceListItemView:OnRegisterUIEvent()
end

function BattlePassAdvanceListItemView:OnRegisterGameEvent()

end

function BattlePassAdvanceListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.Item96Slot:SetParams({Data = self.ViewModel})
end

return BattlePassAdvanceListItemView