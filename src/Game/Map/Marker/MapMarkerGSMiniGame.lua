--
-- Author: Alex
-- Date: 2025-06-23 10:01
-- Description:金碟游乐场小游戏标记
--


local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local GoldSaucerBlessingDefine = require("Game/GoldSaucerMiniGame/GoldSaucerBlessingDefine")
local EBlessingState = GoldSaucerBlessingDefine.EBlessingState
local BLESSED_KIND = ProtoCS.Game.FairyBlessed.BLESSED_KIND

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType

local LSTR = _G.LSTR

---@class MapMarkerGSMiniGame
local MapMarkerGSMiniGame = LuaClass(MapMarker)

---Ctor
function MapMarkerGSMiniGame:Ctor()
    self.BlessState = EBlessingState.NotBegin
    self.BlessKind = BLESSED_KIND.BLESSED_KIND_NONE
end

function MapMarkerGSMiniGame:GetType()
	return MapMarkerType.GSMiniGame
end

function MapMarkerGSMiniGame:GetBPType()
	return MapMarkerBPType.GSMiniGame
end

function MapMarkerGSMiniGame:InitMarker(Params)
    self:UpdateMarker(Params)
end

function MapMarkerGSMiniGame:UpdateMarker(Params)
    local GameID = Params.GameID
    if GameID then
        self.ID = GameID
    end
    
    local IconPath = Params.IconPath
    if IconPath then
        self:SetIconPath(IconPath)
    end
    
    local Name = Params.Name
    if Name then
        self:SetName(Name)
    end
    
    local BlessState = Params.BlessState
    if BlessState then
        self.BlessState = BlessState
    end
   
    local BlessKind = Params.BlessKind
    if BlessKind then
        self.BlessKind = BlessKind
    end
end

function MapMarkerGSMiniGame:GetMarkerBlessState()
    return self.BlessState
end

function MapMarkerGSMiniGame:GetTipsName()
    local BlessState = self.BlessState
    if not BlessState then
        return self.Name
    end
	if BlessState == EBlessingState.NotBegin then
        return self.Name
    elseif BlessState == EBlessingState.Prepare then
        return LSTR(1660001)
    elseif BlessState == EBlessingState.InBlessingNormal or BlessState == EBlessingState.InBlessingWarning then
        local BlessKind = self.BlessKind
        if BlessKind == BLESSED_KIND.BLESSED_KIND_BIG then
            return LSTR(1660002)
        else
            return LSTR(1660001)
        end
    end
end

function MapMarkerGSMiniGame:OnTriggerMapEvent(EventParams)
    MapUtil.ShowWorldMapGoldSaucerMarkerTips(self, EventParams)
end

return MapMarkerGSMiniGame