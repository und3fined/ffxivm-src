---
--- Author: anypkvcai
--- DateTime: 2021-08-10 19:41
--- Description:
---



local LuaClass = require("Core/LuaClass")
local UIAdapterBindableList = require("UI/Adapter/UIAdapterBindableList")
local UIUtil = require("Utils/UIUtil")

---@class UIAdapterPanelWidget : UIAdapterBindableList
local UIAdapterPanelWidget = LuaClass(UIAdapterBindableList, true)

---CreateAdapter
---@param View UIView
---@param Widget UCanvasPanel
---@return UIView
function UIAdapterPanelWidget.CreateAdapter(View, Widget)
	local Adapter = UIAdapterPanelWidget.New()
	Adapter:InitAdapter(View, Widget)
	return Adapter
end

---Ctor
function UIAdapterPanelWidget:Ctor()

end

---InitAdapter
---@param View UIView
---@param Widget UPanelWidget
function UIAdapterPanelWidget:InitAdapter(View, Widget)
	self.Super:InitAdapter(View, Widget)
end

function UIAdapterPanelWidget:OnInit()
	local Widget = self.Widget
	if nil == Widget then
		return
	end

	local Children = Widget:GetAllChildren()
	if nil == Children then
		return
	end

	local Length = Children:Length()

	for i = 1, Length do
		local ItemView = Children:Get(i)
		if nil ~= ItemView then
			self:AddSubView(ItemView)
		end
	end
end

function UIAdapterPanelWidget:ClearChildren()
	for i = 1, #self.SubViews do
		local ItemView = self.SubViews[i]
		if nil ~= ItemView then
			if nil ~= ItemView.HideView then
				ItemView:HideView()
			end
		end
	end
end

function UIAdapterPanelWidget:UpdateChildren()
	for i = 1, #self.SubViews do
		local ItemView = self.SubViews[i]
		if nil ~= ItemView then
			local ItemData = self:GetItemDataByIndex(i)
			if nil ~= ItemData then
				ItemView:SetVisible(true)
				ItemView:ShowView({ Index = i, Data = ItemData, Adapter = self })
			else
				ItemView:SetVisible(false)
			end
		end
	end
end

function UIAdapterPanelWidget:GetChildren(Index)
	if nil == Index then
		return
	end

	local SubViews = self.SubViews
	if nil == SubViews then
		return
	end

	return SubViews[Index]
end

return UIAdapterPanelWidget