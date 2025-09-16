--
-- Author: anypkvcai
-- Date: 2024-08-18 22:29
-- Description:
--



local UILayerConfig = require("Define/UILayerConfig")
local UIShowType = require("UI/UIShowType")

local LayerMutex = UILayerConfig.LayerMutex

local UIViewState = {}

function UIViewState.New(View)
	local State = { View = View, SetVisibleViewIDs = {}, SetInvisibleViewIDs = {}, ShowTypeHiddenViewIDs = {}, LayerHiddenViewIDs = {} }
	setmetatable(State, { __index = UIViewState })
	return State
end

function UIViewState:OnViewShow(View)
	self:UpdateState(View)
end

function UIViewState:OnViewHide(View)
	if View == self.View then
		return
	end

	local ViewID = View:GetViewID()

	table.remove_item(self.SetVisibleViewIDs, ViewID)
	table.remove_item(self.SetInvisibleViewIDs, ViewID)
	table.remove_item(self.ShowTypeHiddenViewIDs, ViewID)
	table.remove_item(self.LayerHiddenViewIDs, ViewID)
end

function UIViewState:UpdateState(View)
	local ViewID = View:GetViewID()

	if not table.find_item(self.SetVisibleViewIDs, ViewID) and self:CheckSetVisible(View) then
		table.insert(self.SetVisibleViewIDs, ViewID)
	end

	if not table.find_item(self.SetInvisibleViewIDs, ViewID) and self:CheckSetInvisible(View) then
		table.insert(self.SetInvisibleViewIDs, ViewID)
	end

	if not table.find_item(self.ShowTypeHiddenViewIDs, ViewID) and self:CheckShowType(View:GetShowType(), View:GetLayer(), View:GetZOrder()) then
		table.insert(self.ShowTypeHiddenViewIDs, ViewID)
	end

	if not table.find_item(self.LayerHiddenViewIDs, ViewID) and self:CheckLayer(View:GetLayer()) then
		table.insert(self.LayerHiddenViewIDs, ViewID)
	end
end

function UIViewState:SetVisible(bVisible)
	self.bVisible = bVisible
end

function UIViewState:GetVisible()
	return self.bVisible
end

function UIViewState:CalculateVisible()
	if #self.SetVisibleViewIDs > 0 then
		return true
	end

	if #self.SetInvisibleViewIDs > 0 then
		return false
	end

	if #self.ShowTypeHiddenViewIDs > 0 then
		return false
	end

	if #self.LayerHiddenViewIDs > 0 then
		return false
	end

	return true
end

function UIViewState:CheckSetVisible(View)
	local ListToSetVisible = View:GetViewListToSetVisible()
	if nil == ListToSetVisible then
		return false
	end

	return table.find_item(ListToSetVisible, self.View:GetViewID())
end

function UIViewState:CheckSetInvisible(View)
	local ListToSetInvisible = View:GetViewListToSetInvisible()
	if nil == ListToSetInvisible then
		return false
	end

	return table.find_item(ListToSetInvisible, self.View:GetViewID())
end

function UIViewState:CheckShowType(ShowType, Layer, ZOrder)
	local View = self.View
	if View:GetLayer() ~= Layer then
		return false
	end

	if View:GetZOrder() > ZOrder then
		return false
	end

	if ShowType == UIShowType.Popup then
		if View:GetShowType() == UIShowType.Popup then
			return true
		end
	elseif ShowType == UIShowType.HideOthers then
		return true
	end

	return false
end

function UIViewState:CheckLayer(Layer)
	local LayerBit = LayerMutex[Layer]
	if nil == LayerBit then
		return false
	end

	return (LayerBit & self.View:GetLayer()) ~= 0
end

return UIViewState