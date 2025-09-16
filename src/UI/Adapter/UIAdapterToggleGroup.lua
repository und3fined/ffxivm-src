---
--- Author: anypkvcai
--- DateTime: 2021-08-10 10:38
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIAdapterDynamicEntryBox = require("UI/Adapter/UIAdapterDynamicEntryBox")
local UIUtil = require("Utils/UIUtil")

---@class UIAdapterToggleGroup : UIAdapterDynamicEntryBox
local UIAdapterToggleGroup = LuaClass(UIAdapterDynamicEntryBox, true)

---CreateAdapter
---@param View UIView
---@param Widget UToggleGroupDynamic
---@return UIView
function UIAdapterToggleGroup.CreateAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged)
	local Adapter = UIAdapterToggleGroup.New()
	Adapter:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged)
	return Adapter
end

---Ctor
function UIAdapterToggleGroup:Ctor()
end

function UIAdapterToggleGroup:OnInit()
	UIUtil.AddOnStateChangedEvent(self, self.Widget, self.OnStateChanged)
end

function UIAdapterToggleGroup:OnStateChanged(ToggleGroup, ToggleButton, Index, State)
	local LuaIndex = Index + 1

	local ItemView = self.SubViews[LuaIndex]
	if nil == ItemView then
		return
	end

	local ItemData = self:GetItemDataByIndex(LuaIndex)
	self:HandleSelected(LuaIndex, ItemData, ItemView)

	if nil ~= ItemView.OnItemClicked then
		ItemView:OnItemClicked()
	end
end

function UIAdapterToggleGroup:UpdateAll(DataList, Num)
	self.Super:UpdateAll(DataList, Num)

	self.Widget:InitToggleButtons()
end

function UIAdapterToggleGroup:ClearAll()
	self.Super:ClearAll()

	self.Widget:ClearToggleButtons()
end

return UIAdapterToggleGroup
