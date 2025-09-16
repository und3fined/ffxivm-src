local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerLeveQuest = require("Game/Map/Marker/MapMarkerLeveQuest")
local MapDefine = require("Game/Map/MapDefine")
local MapEditDataMgr = _G.MapEditDataMgr


---@class MapMarkerProviderLeveQuest : MapMarkerProvider
local MapMarkerProviderLeveQuest = LuaClass(MapMarkerProvider)

function MapMarkerProviderLeveQuest:Ctor()
end

function MapMarkerProviderLeveQuest:GetMarkerType()
	return MapDefine.MapMarkerType.LeveQuest
end

function MapMarkerProviderLeveQuest:OnGetMarkers(UIMapID, MapID)
	local Markers = {}

	local MarkList = self:FindMarkerParams()
	if MarkList == nil then
		return
	end

	for _, LeveQuestMarker in pairs(MarkList) do
		local Marker = self:OnCreateMarker(LeveQuestMarker)
		table.insert(Markers, Marker)
	end

	return Markers
end

function MapMarkerProviderLeveQuest:FindMarkerParams()
	local _ <close> = CommonUtil.MakeProfileTag("MapMarkerProviderLeveQuest:FindMarkerParams")

	local MapID = self.MapID
    if nil == MapID or 0 == MapID then
        return
    end
    local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if MapEditCfg == nil then
		return
	end

    local MarkerList = {}

    local NpcList = _G.LeveQuestMgr:GetMapNpcList()
	for _, v in ipairs(NpcList) do
		if v.NpcID ~= nil then
        	local NpcData = MapEditDataMgr:GetNpc(v.NpcID, MapEditCfg)
        	if NpcData ~= nil then
				local BelongUIMapID = _G.MapAreaMgr:GetUIMapIDByLocation(NpcData.BirthPoint, self.MapID)
				if BelongUIMapID == self.UIMapID then
					local TempTabel = {}
					TempTabel.ID = v.NpcID
					TempTabel.IconPath = v.IconPath
					TempTabel.PosX ,TempTabel.PosY = MapUtil.GetUIPosByLocation(NpcData.BirthPoint, self.UIMapID)
					TempTabel.BirthPoint = NpcData.BirthPoint
					table.insert(MarkerList, TempTabel)
				end
        	end
    	end
	end

    return MarkerList
end

function MapMarkerProviderLeveQuest:FindMarkerParamByNpcResID(NpcID, bIsRemove)
	local MarkerParam = {}

	if NpcID ~= nil then
        local NpcData = MapEditDataMgr:GetNpc(NpcID)
        if NpcData ~= nil then
			if bIsRemove then
            	MarkerParam.ID = NpcID
            	MarkerParam.IconPath = nil
            	MarkerParam.PosX = nil
				MarkerParam.PosY = nil
				MarkerParam.BirthPoint = nil
				return MarkerParam
			else
				local NpcList = _G.LeveQuestMgr:GetMapNpcList()
				for _, v in ipairs(NpcList) do
					if v.NpcID == NpcID then
						local TempTabel = {}
						TempTabel.ID = v.NpcID
						TempTabel.IconPath = v.IconPath
						TempTabel.PosX ,TempTabel.PosY = MapUtil.GetUIPosByLocation(NpcData.BirthPoint, self.UIMapID)
						TempTabel.BirthPoint = NpcData.BirthPoint
						return TempTabel
					end
				end
			end
        end
    end
end

function MapMarkerProviderLeveQuest:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerLeveQuest, Params.ID, Params)

	Marker:SetWorldPos(Params.BirthPoint.X, Params.BirthPoint.Y, Params.BirthPoint.Z)

	return Marker
end


return MapMarkerProviderLeveQuest