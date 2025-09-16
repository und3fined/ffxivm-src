--
-- Author: anypkvcai
-- Date: 2023-10-13 15:32
-- Description:
--
---@type WidgetPoolMgr
local WidgetPoolMgr = require("UI/WidgetPoolMgr")

local AsyncViewHelper = {
	LoadingInfoQueue = {}
}

---AddAsyncLoadingView
---@param ViewID number
---@param Params any
---@param Callback function
function AsyncViewHelper:AddAsyncLoadingView(ViewID, Params, Callback)
	if nil ~= self:FindViewInfo(ViewID) then
		return
	end

	local Info = { ViewID = ViewID, Params = Params, Callback = Callback }
	table.insert(self.LoadingInfoQueue, Info)
end

---OnAsyncLoadFinished
---@param View UIView
function AsyncViewHelper:OnAsyncLoadFinished(View)
	if nil == View then
		return
	end

	local Info = self:FindViewInfo(View:GetViewID())
	if nil ~= Info then
		Info.View = View
	end
end

---OnHideView
---@param ViewID number
function AsyncViewHelper:OnHideView(ViewID)
	local Info = table.remove_item(self.LoadingInfoQueue, ViewID, "ViewID")
	if nil == Info then
		return false
	end

	local View = Info.View
	if nil ~= View then
		WidgetPoolMgr:RecycleWidget(View)
		return true
	end
end

---FindViewInfo
---@param ViewID number
function AsyncViewHelper:FindViewInfo(ViewID)
	return table.find_item(self.LoadingInfoQueue, ViewID, "ViewID")
end

---PopFinishedViewInfos
function AsyncViewHelper:PopFinishedViewInfos()
	local ViewInfos = {}
	local LoadingInfoQueue = self.LoadingInfoQueue

	for i = 1, #LoadingInfoQueue do
		local Info = LoadingInfoQueue[i]
		if nil ~= Info.View then
			table.insert(ViewInfos, Info)
		else
			break
		end
	end

	for i = #ViewInfos, 1, -1 do
		table.remove(LoadingInfoQueue, i)
	end

	return ViewInfos
end

---ClearAll
function AsyncViewHelper:ClearAll()
	local LoadingInfoQueue = self.LoadingInfoQueue

	for i = 1, #LoadingInfoQueue do
		local Info = LoadingInfoQueue[i]
		local View = Info.View
		if nil ~= View then
			WidgetPoolMgr:RecycleWidget(View)
		end
	end

	self.LoadingInfoQueue = {}
end

return AsyncViewHelper