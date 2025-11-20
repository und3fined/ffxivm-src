--
-- Author: peterxie
-- Date:
-- Description: 房屋土地标记
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")


---@class MapMarkerHouseLand : MapMarker
local MapMarkerHouseLand = LuaClass(MapMarker)

function MapMarkerHouseLand:Ctor()
	self.LandInfo = nil -- 房屋土地信息
	self.TipsName = "" -- 房屋土地提示信息

	self.IsShowPlayerHead = false -- 是否显示玩家头像
	self.PlayerRoleID = nil -- 玩家角色ID
end

function MapMarkerHouseLand:GetType()
	return MapDefine.MapMarkerType.HouseLand
end

function MapMarkerHouseLand:GetBPType()
	return MapDefine.MapMarkerBPType.HouseLand
end

function MapMarkerHouseLand:InitMarker(Params)
    local LandInfo = Params.LandInfo
    if LandInfo == nil then
        return
    end
    self.LandInfo = LandInfo
    self.Radius = Params.Radius

    self.IsShowPlayerHead = false
    local HouseInfo = _G.HouseLandMgr:GetHouseStateInfo(LandInfo)
    if HouseInfo then
        self.IconPath = HouseInfo.IconPath
        self.TipsName = HouseInfo.Tips

        if HouseInfo.IsHouse then
            if HouseInfo.IsFriendHouse or HouseInfo.IsShareHouse then
                self.IsShowPlayerHead = true
                self.PlayerRoleID = LandInfo.Owner
            elseif HouseInfo.IsMyHouse then
                local MajorUtil = require("Utils/MajorUtil")
                self.IsShowPlayerHead = true
                self.PlayerRoleID = MajorUtil.GetMajorRoleID()
            end
        end
    end

    self:UpdateMarker(Params)
end

function MapMarkerHouseLand:IsNameVisible(Scale)
	return false
end

function MapMarkerHouseLand:GetTipsName()
	return self.TipsName
end

function MapMarkerHouseLand:GetRadius()
	return self.Radius
end

function MapMarkerHouseLand:GetLandInfo()
	return self.LandInfo
end

function MapMarkerHouseLand:OnTriggerMapEvent(EventParams)
	_G.FLOG_INFO(string.format("[MapMarkerHouseLand:OnTriggerMapEvent] %s", self:ToString()))
	local Params = { MapMarker = self, ScreenPosition = EventParams.ScreenPosition }
	_G.UIViewMgr:ShowView(_G.UIViewID.WorldMapMarkerTipsHouse, Params)
end

return MapMarkerHouseLand