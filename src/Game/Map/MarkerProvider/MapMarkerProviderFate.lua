local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerFate = require("Game/Map/Marker/MapMarkerFate")
local MapDefine = require("Game/Map/MapDefine")
local ProtoCS = require("Protocol/ProtoCS")


---@class MapMarkerProviderFate : MapMarkerProvider
local MapMarkerProviderFate = LuaClass(MapMarkerProvider)

function MapMarkerProviderFate:Ctor()

end

function MapMarkerProviderFate:GetMarkerType()
	return MapDefine.MapMarkerType.Fate
end

function MapMarkerProviderFate:OnGetMarkers(UIMapID, MapID)
	if UIMapID ~= _G.MapMgr:GetUIMapID() then
		return
	end

	local Markers = {}

	local CurrActiveFateList = _G.FateMgr.CurrActiveFateList
	for _, Fate in pairs(CurrActiveFateList) do
		local bEndSubmit = Fate.State == ProtoCS.FateState.FateState_EndSubmitItem
		local bEnd = Fate.State == ProtoCS.FateState.FateState_Finished
		if (not bEnd) then
			local Marker = self:OnCreateMarker(Fate)
			table.insert(Markers, Marker)
		end
	end
	return Markers
end

function MapMarkerProviderFate:OnCreateMarker(Params)
	if MapUtil.GetUIMapID(Params.MapID) ~= self.UIMapID then
		return
	end

	return self:CreateMarker(MapMarkerFate, Params.ID, Params)
end


return MapMarkerProviderFate