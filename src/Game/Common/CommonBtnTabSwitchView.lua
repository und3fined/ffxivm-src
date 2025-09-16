---
--- Author: anypkvcai
--- DateTime: 2021-08-17 11:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
-- local BackpackMainVM = require("Game/Backpack/BackpackMainVM")

---@class CommonBtnTabSwitchView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RedDot_Left CommRedDotView
---@field RedDot_Right CommRedDotView
---@field ToggleGroupType UToggleGroup
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonBtnTabSwitchView = LuaClass(UIView, true)

function CommonBtnTabSwitchView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RedDot_Left = nil
	--self.RedDot_Right = nil
	--self.ToggleGroupType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonBtnTabSwitchView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot_Left)
	self:AddSubView(self.RedDot_Right)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonBtnTabSwitchView:OnInit()
	UIUtil.SetIsVisible(self.RedDot_Left, false)
	UIUtil.SetIsVisible(self.RedDot_Right, false)
end

function CommonBtnTabSwitchView:OnDestroy()

end

function CommonBtnTabSwitchView:OnShow()

end

function CommonBtnTabSwitchView:OnHide()

end

function CommonBtnTabSwitchView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupType, self.OnGroupStateChangedType)
end

function CommonBtnTabSwitchView:OnRegisterGameEvent()

end

function CommonBtnTabSwitchView:OnRegisterTimer()

end

function CommonBtnTabSwitchView:OnRegisterBinder()

end

function CommonBtnTabSwitchView:OnGroupStateChangedType(ToggleGroup, ToggleButton, Index, State)
	--print("BackpackTabListView:OnGroupStateChangedType", Index, State)

	if UIUtil.IsToggleButtonChecked(State) then
		--BackpackMainVM:SetTopTabIndex(Index)
	end
end

return CommonBtnTabSwitchView