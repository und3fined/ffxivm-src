local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local MapUICfg = require("TableCfg/MapUICfg")
local NpcCfgTable = require("TableCfg/NpcCfg")
local LeveQuestDefine = require("Game/LeveQuest/LeveQuestDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerLeveQuest : MapMarker
local MapMarkerLeveQuest = LuaClass(MapMarker)

---Ctor
function MapMarkerLeveQuest:Ctor()

end

function MapMarkerLeveQuest:GetType()
	return MapMarkerType.LeveQuest
end

function MapMarkerLeveQuest:GetBPType()
	return MapMarkerBPType.CommGameplay
end

function MapMarkerLeveQuest:InitMarker(Params)
    self:UpdateMarker(Params)
end

function MapMarkerLeveQuest:UpdateMarker(Params)
	self.ID = Params.ID
    self.IconPath = Params.IconPath
    self.AreaUIPosX = Params.PosX
	self.AreaUIPosY = Params.PosY

    local NpcCfgItem = NpcCfgTable:FindCfgByKey(self.ID)
	if NpcCfgItem then
		self.Name = NpcCfgItem.Name
	end

	self:UpdateFollow()
end

function MapMarkerLeveQuest:IsNameVisible(Scale)
	return false
end

function MapMarkerLeveQuest:GetTipsName()
	return self.Name
end

function MapMarkerLeveQuest:OnTriggerMapEvent(EventParams)
	local bClickedEnable, Type = _G.LeveQuestMgr:GetLeveQuestStatus(self.ID)

    if bClickedEnable then
        -- if Type == LeveQuestDefine.ToggleIndex.Accept then
            MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
        -- end
    end
end

function MapMarkerLeveQuest:IsCanShowInDiscovery()
	if _G.FogMgr:IsAllActivate(self.MapID) then
		return true
	end

	local InDiscovery = _G.MapAreaMgr:GetDiscoveryIDByLocation(self.WorldPosX, self.WorldPosY, self.WorldPosZ, self.MapID)
	if InDiscovery and InDiscovery > 0 then
		return _G.FogMgr:IsInFlag(self.MapID, InDiscovery)
	end

	return true
end

function MapMarkerLeveQuest:IsControlByFog()
	return true
end

return MapMarkerLeveQuest