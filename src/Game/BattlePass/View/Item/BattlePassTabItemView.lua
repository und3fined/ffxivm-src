---
--- Author: Administrator
--- DateTime: 2024-01-09 14:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIUtil = require("Utils/UIUtil")

---@class BattlePassTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RedDot CommRedDotSlotView
---@field TextContent UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassTabItemView = LuaClass(UIView, true)

function BattlePassTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RedDot = nil
	--self.TextContent = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassTabItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextContent)},
		{ "IsRed", UIBinderSetIsVisible.New(self, self.RedDot)},
		{ "IsSelected", UIBinderSetIsChecked.New(self, self.ToggleBtn, true) },
	}
end

function BattlePassTabItemView:OnDestroy()

end

function BattlePassTabItemView:OnShow()

end

function BattlePassTabItemView:OnHide()

end

function BattlePassTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickedItem)
end

function BattlePassTabItemView:OnRegisterGameEvent()

end

function BattlePassTabItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function BattlePassTabItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
end

function BattlePassTabItemView:OnClickedItem()
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



return BattlePassTabItemView