local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerMonster = require("Game/Map/Marker/MapMarkerMonster")
local MapDefine = require("Game/Map/MapDefine")
local MonsterCfg = require("TableCfg/MonsterCfg")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local MapMarkerType = MapDefine.MapMarkerType
local MapContentType = MapDefine.MapContentType


---@class MapMarkerProviderMonster : MapMarkerProvider
local MapMarkerProviderMonster = LuaClass(MapMarkerProvider)

function MapMarkerProviderMonster:Ctor()

end

function MapMarkerProviderMonster:GetMarkerType()
	return MapMarkerType.Monster
end

function MapMarkerProviderMonster:OnGetMarkers(UIMapID, MapID)
	local MapMarkers = self:CreateMonsterMarkers()
	if self:GetContentType() == MapContentType.MiniMap then
		self:InitVisionMarkers(MapMarkers)
	else
		return MapMarkers
	end
end

function MapMarkerProviderMonster:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerMonster, Params.ID, Params)
	if nil == Marker then
		return
	end

	return Marker
end

function MapMarkerProviderMonster:CreateMonsterMarkers()
	local MapMarkers = {}

	local ActorManager = _G.UE.UActorManager.Get()
	local AllMonsters = ActorManager:GetAllMonsters()
	local Length = AllMonsters:Length()
	for i = 1, Length do
		local Monster = AllMonsters:GetRef(i)
		local AttributeComp = Monster:GetAttributeComponent()
		local EntityID = AttributeComp.EntityID
		local ResID = AttributeComp.ResID

		if self:CanShowInMap(ResID) then
			local Params = { ID = EntityID, EntityID = EntityID, ResID = ResID }
			local Marker = self:OnCreateMarker(Params)
			table.insert(MapMarkers, Marker)
		end
	end

	return MapMarkers
end

function MapMarkerProviderMonster:OnVisionEnter(EntityID, ResID)
	if self:GetContentType() == MapContentType.MiniMap then
		if self:CanShowInMap(ResID) then
			local Params = { ID = EntityID, EntityID = EntityID, ResID = ResID }
			local Marker = self:OnCreateMarker(Params)
			self:AddVisionMarker(Marker)
		end
	end
end

function MapMarkerProviderMonster:OnVisionLeave(EntityID, ResID)
	if self:GetContentType() == MapContentType.MiniMap then
		self:RemoveVisionMarker(EntityID)
	end
end

---怪物是否在地图上显示
---@return boolean
function MapMarkerProviderMonster:CanShowInMap(ResID)
	-- bnpc表，配置不显示地图红点
	local NoShowMap = MonsterCfg:FindValue(ResID, "NoShowMap")
	if NoShowMap and NoShowMap == 1 then
		return false
	end

	local ProfileName = MonsterCfg:FindValue(ResID, "ProfileName")
	local iProfileName = tonumber(ProfileName)
	if iProfileName == nil then
		return false
	end

	-- 全局配置表，配置不在雷达地图上显示的形象名ID
	if self.NoShowMapNPCBaseIDList == nil then
		self.NoShowMapNPCBaseIDList = ClientGlobalCfg:GetConfigValueList(ProtoRes.client_global_cfg_id.GLOBAL_CFG_NOT_SHOW_MAP_NPCBASE_ID)
	end
	if table.find_item(self.NoShowMapNPCBaseIDList, iProfileName) ~= nil then
		return false
	end

	return true
end

function MapMarkerProviderMonster:UpdateMonsters()
	self:ClearMarkers()

	local MapMarkers = self:CreateMonsterMarkers()
	self:InitVisionMarkers(MapMarkers)
end


return MapMarkerProviderMonster