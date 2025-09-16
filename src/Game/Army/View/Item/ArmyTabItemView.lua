---
--- Author: daniel
--- DateTime: 2023-03-08 10:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTabName UFTextBlock
---@field ToggleBtnTab UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyTabItemView = LuaClass(UIView, true)

function ArmyTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextTabName = nil
	--self.ToggleBtnTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyTabItemView:OnInit()

end

function ArmyTabItemView:OnDestroy()

end

function ArmyTabItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.TextTabName:SetText(Params.Data.Name)
end

function ArmyTabItemView:OnHide()

end

function ArmyTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnTab, self.OnClickedItem)
end

function ArmyTabItemView:OnRegisterGameEvent()
end

function ArmyTabItemView:OnRegisterBinder()

end

function ArmyTabItemView:OnClickedItem()
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

---@field IsSelected boolean
function ArmyTabItemView:OnSelectChanged(IsSelected)
	self.ToggleBtnTab:SetChecked(IsSelected, false)
end

return ArmyTabItemView