--
-- Author: anypkvcai
-- Date: 2023-03-01 16:20
-- Description:
--

--local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local MapUtil = require("Game/Map/MapUtil")


---@class MapMarkerProvider
local MapMarkerProvider = {}

function MapMarkerProvider:Ctor()
	-- 地图显示标记列表
	self.MapMarkers = {}

	--[[
	小地图视野标记列表，其他地图类型默认是全部显示

	目前只处理怪物，其他类型也可用这种机制
	因为地图标记的增删更新写法各异，不好直接统一，后面可以选择几个主要类型处理
	--]]
	self.MiniMapVisionMarkers = nil

	-- 地图内容类型
	self.ContentType = nil
end

function MapMarkerProvider:SetContentType(ContentType)
	self.ContentType = ContentType
end

function MapMarkerProvider:GetContentType()
	return self.ContentType
end

---获取标记类型
---@return number MapMarkerType
function MapMarkerProvider:GetMarkerType()

end

---获取显示标记列表
---@param UIMapID number
---@param MapID number
function MapMarkerProvider:GetMapMarkers(UIMapID, MapID)
	self.UIMapID = UIMapID
	self.MapID = MapID

	self.MapMarkers = {}

	local MapMarkers = self:OnGetMarkers(UIMapID, MapID)
	if nil == MapMarkers then
		return
	end

	self.MapMarkers = MapMarkers

	return MapMarkers
end

---OnGetMarkers @获取UIMapID所有Marker
---@param UIMapID number 通用配置的Marker由UIMapID决定
---@param MapID number 玩法相关的Marker由MapID决定，如Fate、Quest
---@private
function MapMarkerProvider:OnGetMarkers(UIMapID, MapID)

end

---OnCreateMarker  @如果添加成功 返回MapMarker 否则返回 nil
---@param Params any
---@return MapMarker | nil
function MapMarkerProvider:OnCreateMarker(Params, ...)

end

---CreateMarker
---@param MarkerClass MapMarker
---@param MarkerID number
---@param Params any
function MapMarkerProvider:CreateMarker(MarkerClass, MarkerID, Params, ...)
	if nil == MarkerClass then
		return
	end

	--local Marker = MarkerClass.New()
	local MapMarkerFactory = require("Game/Map/MapMarkerFactory")
	local Marker = MapMarkerFactory.CreateMarker(MarkerClass)
	Marker:SetID(MarkerID)
	Marker:SetUIMapID(self.UIMapID)
	Marker:SetAreaUIMapID(self.UIMapID)
	Marker:SetMapID(MapUtil.GetMapID(self.UIMapID))
	Marker:InitMarker(Params, ...)

	return Marker
end

---清空标记列表
function MapMarkerProvider:ClearMarkers()
	self:SendRemoveMarkerListEvent(self.MapMarkers)
	self.MapMarkers = {}
	self.MiniMapVisionMarkers = nil
end

---更新标记列表，等于重新创建标记列表，一般用于整个标记类型都刷新的情况
function MapMarkerProvider:UpdateMarkers()
	local Markers = self:OnGetMarkers(self.UIMapID, self.MapID)
	if nil == Markers or #Markers == 0 then
		return
	end

	self.MapMarkers = Markers

	self:SendAddMarkerListEvent(self.MapMarkers)
end

---清空并更新标记列表
function MapMarkerProvider:ClearAndUpdateMarkers()
	self:ClearMarkers()
	self:UpdateMarkers()
end

---增加指定标记列表
function MapMarkerProvider:AddMarkersByList(AddMarkers)
	if nil == AddMarkers or #AddMarkers == 0 then
		return
	end

	table.merge_table(self.MapMarkers, AddMarkers)

	self:SendAddMarkerListEvent(AddMarkers)
end

---移除符合条件的所有标记
function MapMarkerProvider:RemoveMarkersByPredicate(Predicate)
	local MapMarkers = self.MapMarkers
	if nil == MapMarkers then
		return
	end

	local RemoveMarkers = {}
	local toRemove = {}

	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
		if Predicate(Marker) then
			table.insert(toRemove, i)
			table.insert(RemoveMarkers, Marker)
		end
    end

	if #RemoveMarkers > 0 then
		for i = #toRemove, 1, -1 do
			table.remove(MapMarkers, toRemove[i])
		end

		self:SendRemoveMarkerListEvent(RemoveMarkers)
	end
end

---根据参数增加一个标记
---@param InParams any
function MapMarkerProvider:AddMarker(InParams)
	local Marker = self:OnCreateMarker(InParams)
	if nil == Marker then
		return
	end

	if nil == self.MapMarkers then
		return
	end

	table.insert(self.MapMarkers, Marker)

	self:SendAddMarkerEvent(Marker)

	return Marker
end

---根据参数查找并移除一个标记
---@param Params any
function MapMarkerProvider:RemoveMarker(Params)
	local Marker = self:FindMarker(Params)
	if nil == Marker then
		return
	end

	if nil == self.MapMarkers then
		return
	end

	table.remove_item(self.MapMarkers, Marker)

	self:SendRemoveMarkerEvent(Marker)
end

---更新一个标记
---@param Params any @如果找不到Marker时要新增Marker，注意MapMarker类的InitMarker和UpdateMarker参数要一致
function MapMarkerProvider:UpdateMarker(Params, NewParams)
	local Marker = self:FindMarker(Params)
	if nil == Marker then
		self:AddMarker(NewParams)
		return
	end

	Marker:UpdateMarker(NewParams)

	self:SendUpdateMarkerEvent(Marker)
end

---查找一个标记
---@param Params any @默认是通过ID查找, 如果是其他条件查找，子类要重写FindMarker函数
function MapMarkerProvider:FindMarker(Params)
	return table.find_item(self.MapMarkers, Params, "ID")
end


---更新地图追踪标记
---大部分标记类型通过标记ID就可以查找，有些标记类型查找需要通过更多参数，这种标记子类要重写该函数
---@param FollowInfo table 地图追踪信息
function MapMarkerProvider:UpdateFollowMarker(FollowInfo)
	if FollowInfo == nil then
		return
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		local FollowMarkerID = FollowInfo.FollowID
		local Marker = self:FindMarker(FollowMarkerID)
		if Marker then
			Marker:UpdateFollow()
			self:SendUpdateMarkerEvent(Marker)
		end
	else
		_G.EventMgr:SendEvent(_G.EventID.WorldMapUpdateAllMarker)
	end
end


---通知地图增加指定标记
---@param Marker MapMarker
function MapMarkerProvider:SendAddMarkerEvent(Marker)
	local Params = { ContentType = self:GetContentType(), Marker = Marker }
	EventMgr:SendEvent(EventID.MapOnAddMarker, Params)
end

---通知地图移除指定标记
---@param Marker MapMarker
function MapMarkerProvider:SendRemoveMarkerEvent(Marker)
	local Params = { ContentType = self:GetContentType(), Marker = Marker }
	EventMgr:SendEvent(EventID.MapOnRemoveMarker, Params)
end

---通知地图更新指定标记
---@param Marker MapMarker
function MapMarkerProvider:SendUpdateMarkerEvent(Marker)
	local Params = { ContentType = self:GetContentType(), Marker = Marker }
	EventMgr:SendEvent(EventID.MapOnUpdateMarker, Params)
end

---通知地图增加指定标记列表
---@param MapMarkers table<MapMarker>
function MapMarkerProvider:SendAddMarkerListEvent(MapMarkers)
	local Params = { ContentType = self:GetContentType(), Markers = MapMarkers }
	EventMgr:SendEvent(EventID.MapOnAddMarkerList, Params)
end

---通知地图移除指定标记列表
---@param MapMarkers table<MapMarker>
function MapMarkerProvider:SendRemoveMarkerListEvent(MapMarkers)
	local Params = { ContentType = self:GetContentType(), Markers = MapMarkers }
	EventMgr:SendEvent(EventID.MapOnRemoveMarkerList, Params)
end


function MapMarkerProvider:InitVisionMarkers(MapMarkers)
	self.MiniMapVisionMarkers = MapMarkers
end

function MapMarkerProvider:AddVisionMarker(Marker)
	if nil == self.MiniMapVisionMarkers then
		self.MiniMapVisionMarkers = {}
	end

	table.insert(self.MiniMapVisionMarkers, Marker)
end

function MapMarkerProvider:RemoveVisionMarker(Params)
	-- 先检查视野标记列表
	local MapMarkers = self.MiniMapVisionMarkers
	if MapMarkers then
		local Marker = self:FindVisionMarker(Params)
		if Marker then
			table.remove_item(self.MiniMapVisionMarkers, Marker)
			return
		end
	end

	-- 再检查显示标记列表
	self:RemoveMarker(Params)
end

function MapMarkerProvider:FindVisionMarker(Params)
	if nil == self.MiniMapVisionMarkers then
		return
	end

	return table.find_item(self.MiniMapVisionMarkers, Params, "ID")
end

function MapMarkerProvider:CheckVisionMarkerOnTimer()
	self:CheckVisionMarkerList()
end

---检查视野标记列表
---从视野标记列表中移除，加入显示标记列表
function MapMarkerProvider:CheckVisionMarkerList()
	local MapMarkers = self.MiniMapVisionMarkers
	if nil == MapMarkers then
		return
	end

	if #MapMarkers == 0 then
		return
	end

	local ShowMarkers = {}
	local toRemoveFromVision = {}

	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
		if Marker:NeedShowInMiniMap() then
			table.insert(toRemoveFromVision, i)
			table.insert(ShowMarkers, Marker)
		end
	end

	if #ShowMarkers > 0 then
		for i = #toRemoveFromVision, 1, -1 do
			table.remove(self.MiniMapVisionMarkers, toRemoveFromVision[i])
		end

		self.MapMarkers = self.MapMarkers or {}
		table.merge_table(self.MapMarkers, ShowMarkers)

		self:SendAddMarkerListEvent(ShowMarkers)
	end
end

---检查显示标记列表
---从显示标记列表中移除，加入视野标记列表
function MapMarkerProvider:CheckShowMarkerList()
	local MapMarkers = self.MapMarkers
	if nil == MapMarkers then
		return
	end

	if #MapMarkers == 0 then
		return
	end

	local HideMarkers = {}
	local toRemoveFromShow = {}

	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
		if not Marker:NeedShowInMiniMap() then
			table.insert(toRemoveFromShow, i)
			table.insert(HideMarkers, Marker)
		end
	end

	if #HideMarkers > 0 then
		for i = #toRemoveFromShow, 1, -1 do
			table.remove(self.MapMarkers, toRemoveFromShow[i])
		end

		self.MiniMapVisionMarkers = self.MiniMapVisionMarkers or {}
		table.merge_table(self.MiniMapVisionMarkers, HideMarkers)

		self:SendRemoveMarkerListEvent(HideMarkers)
	end
end

return MapMarkerProvider