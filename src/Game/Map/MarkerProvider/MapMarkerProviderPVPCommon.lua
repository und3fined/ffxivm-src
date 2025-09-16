--
-- Author: peterxie
-- Date:
-- Description: PVP地图通用标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerPVPCommon = require("Game/Map/Marker/MapMarkerPVPCommon")
local MapMarkerMonster = require("Game/Map/Marker/MapMarkerMonster")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local ProtoRes = require("Protocol/ProtoRes")

local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ColosseumTeam = PVPColosseumDefine.ColosseumTeam
local ColosseumMapMarkerLayoutType = PVPColosseumDefine.ColosseumMapMarkerLayoutType
local ColosseumMapLayouts = PVPColosseumDefine.ColosseumMapLayouts
local ColosseumConstant = PVPColosseumDefine.ColosseumConstant


---@class MapMarkerProviderPVPCommon
local MapMarkerProviderPVPCommon = LuaClass(MapMarkerProvider)

function MapMarkerProviderPVPCommon:Ctor()

end

function MapMarkerProviderPVPCommon:GetMarkerType()
	return MapDefine.MapMarkerType.PVPCommon
end

function MapMarkerProviderPVPCommon:OnGetMarkers(UIMapID, MapID)
   local MapMarkers = self:CreateSGMarkers()

   local CrystalMarker = self:CreateCrystalMarker()
	if CrystalMarker then
		table.insert(MapMarkers, CrystalMarker)
	end

    return MapMarkers
end

function MapMarkerProviderPVPCommon:OnCreateMarker(Params)
    local Marker
    if Params.IsColosseumCrystal then
        Marker = self:CreateMarker(MapMarkerMonster, Params.ID, Params)
    else
        Marker = self:CreateMarker(MapMarkerPVPCommon, Params.ID, Params)
        local X, Y = MapUtil.GetUIPosByLocation(Params.Location, self.UIMapID)
	    Marker:SetAreaMapPos(X, Y)
    end

    return Marker
end

---创建动态物件对应的标记
function MapMarkerProviderPVPCommon:CreateSGMarkers()
    local MapMarkers = {}

    local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
    local CurrMapLayouts = ColosseumMapLayouts[CurrMapID]
    if CurrMapLayouts == nil then
        return MapMarkers
    end

    for i = 1, ColosseumTeam.COLOSSEUM_TEAM_MAX do
        for j = 1, ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_MAX do
            local SgInstanceID = CurrMapLayouts[i][j]
            local SgLocation -- 获取SG的位置动作地图标记坐标

            --[[
            local DynData = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE, SgInstanceID)
            if DynData and DynData.MapDynamicAssetModel then
                local SgActor = DynData.MapDynamicAssetModel
                SgLocation = SgActor:K2_GetActorLocation()
            end
            --]]

            local SgTransform = _G.UE.FTransform()
            if _G.PWorldMgr:GetInstanceAssetTransform(SgInstanceID, SgTransform) then
                SgLocation = SgTransform:GetLocation()
            end

            if SgLocation then
                local Params = { ID = SgInstanceID, Location = SgLocation, GameplayID = ProtoRes.Game.GameID.GameIDPvpcolosseumCrystal, TeamIndex = i, LayoutType = j, }
                local Marker = self:OnCreateMarker(Params)
                table.insert(MapMarkers, Marker)
            else
                _G.FLOG_INFO(string.format("[MapMarkerProviderPVPCommon:CreateSGMarkers] sg not find, SgInstanceID=%d", SgInstanceID))
            end
        end
    end

	return MapMarkers
end

---创建水晶bnpc对应的标记
function MapMarkerProviderPVPCommon:CreateCrystalMarker()
    local CrystalCharacter = _G.PVPColosseumMgr:GetCrystalCharacter()
    if CrystalCharacter == nil then
        return nil
    end
    local AttributeComp = CrystalCharacter:GetAttributeComponent()
    if AttributeComp == nil then
        return nil
    end

    local EntityID = AttributeComp.EntityID
    local ResID = AttributeComp.ResID
    local Params = { ID = EntityID, EntityID = EntityID, ResID = ResID, IsColosseumCrystal = true, }
	local Marker = self:OnCreateMarker(Params)
    return Marker
end

function MapMarkerProviderPVPCommon:OnVisionEnter(EntityID, ResID)
	if ResID == ColosseumConstant.EXD_BNPC_BASE_MKS_CRYSTAL then
		local Params = { ID = EntityID, EntityID = EntityID, ResID = ResID, IsColosseumCrystal = true, }
	    self:AddMarker(Params)
	end
end

function MapMarkerProviderPVPCommon:OnVisionLeave(EntityID, ResID)
    if ResID == ColosseumConstant.EXD_BNPC_BASE_MKS_CRYSTAL then
	    self:RemoveMarker(EntityID)
    end
end

---更新动态物件标记图标
function MapMarkerProviderPVPCommon:UpdateColosseumSGMarker()
	local MapMarkers = self.MapMarkers
	if nil == MapMarkers then
		return
	end

	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
        -- 动态物件标记里只有检查点图标要动态更新
        if Marker.LayoutType == ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_CHECK_POINT then
            Marker:UpdateMarker()
            self:SendUpdateMarkerEvent(Marker)
        end
    end
end

---更新水晶bnpc标记图标
function MapMarkerProviderPVPCommon:UpdateColosseumCrystalMarker()
	local MapMarkers = self.MapMarkers
	if nil == MapMarkers then
		return
	end

	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
        if Marker.IsColosseumCrystal then
            Marker:UpdateMarker()
            self:SendUpdateMarkerEvent(Marker)
        end
    end
end


return MapMarkerProviderPVPCommon