---
--- Author: daniel
--- DateTime: 2023-03-20 12:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyTrendsFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFilterCondition UFButton
---@field TextConditionName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyTrendsFilterItemView = LuaClass(UIView, true)

function ArmyTrendsFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFilterCondition = nil
	--self.TextConditionName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyTrendsFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyTrendsFilterItemView:OnInit()

end

function ArmyTrendsFilterItemView:OnDestroy()

end

function ArmyTrendsFilterItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.TextConditionName:SetText(Params.Data.Name)
end

function ArmyTrendsFilterItemView:OnHide()

end

function ArmyTrendsFilterItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFilterCondition, self.OnClickedItem)
end

function ArmyTrendsFilterItemView:OnRegisterGameEvent()

end

function ArmyTrendsFilterItemView:OnRegisterBinder()

end

function ArmyTrendsFilterItemView:OnClickedItem()
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

return ArmyTrendsFilterItemView