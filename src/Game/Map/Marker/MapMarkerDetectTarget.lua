--
-- Author: Alex
-- Date:2025-02-24
-- Description: 普通探索全收集辅助探测功能目标
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapUtil = require("Game/Map/MapUtil")
--local ProtoRes = require("Protocol/ProtoRes")
local MapDefine = require("Game/Map/MapDefine")
--local NpcCfg = require("TableCfg/NpcCfg")
--local MapNpcIconCfg = require("TableCfg/MapNpcIconCfg")
--local EObjCfg = require("TableCfg/EobjCfg")
local CompleteSkillCfg = require("TableCfg/DiscoverNoteCompleteSkillCfg")


local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
--local ClientEObjType = ProtoRes.ClientEObjType


---@class MapMarkerDetectTarget
local MapMarkerDetectTarget = LuaClass(MapMarker)

function MapMarkerDetectTarget:Ctor()
    self.ActiveID = nil -- 普通探索全收集生效ID
    self.ActorType = nil
    self.Location = nil
end

function MapMarkerDetectTarget:GetType()
	return MapMarkerType.DetectTarget
end

function MapMarkerDetectTarget:GetBPType()
	return MapMarkerBPType.CommIconTop
end

function MapMarkerDetectTarget:InitMarker(Params)
	-- 探索笔记表读表确定
    local ActiveID = Params.ActiveID
    self.ActiveID = ActiveID

    self.IconPath = MapDefine.MapIconConfigs.WorldMapLocation
    local Cfg = CompleteSkillCfg:FindCfgByKey(ActiveID)
    if Cfg then
        local IconPath = Cfg.MarkerIconPath
        if IconPath and IconPath ~= "" then
            self.IconPath = IconPath
        end

        local IconTipsName = Cfg.MarkerCustomName or ""
        self.TipsName = IconTipsName
    end

    self.ActorType = Params.ActorType
    self.Location = Params.Position
	self:UpdateMarker()
end

function MapMarkerDetectTarget:UpdateMarker(_)
    self:UpdateFollow()
end

function MapMarkerDetectTarget:IsNameVisible(_)
	return false
end

function MapMarkerDetectTarget:GetTipsName()
	return self.TipsName
end

function MapMarkerDetectTarget:OnTriggerMapEvent(EventParams)
	MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
end

function MapMarkerDetectTarget:GetSubType()
	return self.ActorType
end

return MapMarkerDetectTarget