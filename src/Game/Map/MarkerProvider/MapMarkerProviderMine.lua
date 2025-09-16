local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerMine = require("Game/Map/Marker/MapMarkerMine")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType


---@class MapMarkerProviderMine
local MapMarkerProviderMine = LuaClass(MapMarkerProvider)

---Ctor
function MapMarkerProviderMine:Ctor()

end

---@return number MapMarkerType
function MapMarkerProviderMine:GetMarkerType()
	return MapMarkerType.TreasureMine
end

function MapMarkerProviderMine:OnGetMarkers(UIMapID)
	return self:CreateMineMarkers()
end

function MapMarkerProviderMine:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerMine, 0, Params)

	local X, Y = MapUtil.GetUIPosByLocation(Params.Pos, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end

function MapMarkerProviderMine:CreateMineMarkers()
	self:ClearMarkers()

	local MapMarkers = {}
	local SelfData = _G.TreasureHuntMgr:GetTreasureHuntSelfData()
	if SelfData ~= nil then
		for _, Data in pairs(SelfData) do
			local UIMapID = MapUtil.GetUIMapID(Data.MapResID)
			if self.UIMapID == UIMapID then
				local Marker = self:OnCreateMarker(Data)
				table.insert(MapMarkers,Marker)
			end
		end
	end

	local TeamData = _G.TreasureHuntMgr:GetTreasureHuntTeamData()
	for _, Data in pairs(TeamData) do
		local UIMapID = MapUtil.GetUIMapID(Data.MapResID)
		if self.UIMapID == UIMapID then
			local Marker = self:OnCreateMarker(Data)
			table.insert(MapMarkers,Marker)
		end
	end

	return MapMarkers
end

function MapMarkerProviderMine:AddMapMine(Param)
	local CurrentUIMapID = self.UIMapID
	local UIMapID = MapUtil.GetUIMapID(Param.MapResID)
	if CurrentUIMapID == UIMapID then
		local Marker = self:OnCreateMarker(Param)
		table.insert(self.MapMarkers,Marker)
		self:SendAddMarkerEvent(Marker)
	end
end

function MapMarkerProviderMine:UpdateMapMine(Params)
	self:ClearMarkers()

    local CurrentUIMapID = self.UIMapID
	local MapMarkers = {}
	local SelfData = _G.TreasureHuntMgr:GetTreasureHuntSelfData()
	for _, Data in pairs(SelfData) do
		local UIMapID = MapUtil.GetUIMapID(Data.MapResID)
		if CurrentUIMapID == UIMapID then
			local Marker = self:OnCreateMarker(Data)
			table.insert(MapMarkers,Marker)
		end
	end
	local TeamData = _G.TreasureHuntMgr:GetTreasureHuntTeamData()
	for _, Data in pairs(TeamData) do
		local UIMapID = MapUtil.GetUIMapID(Data.MapResID)
		if CurrentUIMapID == UIMapID then
			local Marker = self:OnCreateMarker(Data)
			table.insert(MapMarkers,Marker)
		end
	end

	self.MapMarkers = MapMarkers

	self:SendAddMarkerListEvent(MapMarkers)
end

function MapMarkerProviderMine:ClearMapMine(Param)
	self:ClearMarkers()
end

function MapMarkerProviderMine:RemoveMapMine(Params)
	local Markers = {}
	local toRemove = {}

	-- 收集所有需要移除的索引
	for _, Data in pairs(Params) do
		for Index, Marker in pairs(self.MapMarkers) do
			if Marker.PosID == Data.PosID then
				table.insert(toRemove, Index)
				table.insert(Markers, Marker)
				break
			end
		end
	end

	-- 反向移除元素以避免索引问题
	for i = #toRemove, 1, -1 do
		table.remove(self.MapMarkers, toRemove[i])
	end
	
	-- 通知地图删除标记
	if #Markers > 0 then
		self:SendRemoveMarkerListEvent(Markers)
	end
end

function MapMarkerProviderMine:FindMarker(Params)
end

return MapMarkerProviderMine