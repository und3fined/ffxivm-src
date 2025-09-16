--
-- Author: anypkvcai
-- Date: 2023-03-01 16:57
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerFixedPoint = require("Game/Map/Marker/MapMarkerFixedPoint")
local MapMarkerRegion = require("Game/Map/Marker/MapMarkerRegion")
local ProtoRes = require("Protocol/ProtoRes")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")

local MapUICfg = require("TableCfg/MapUICfg")
local MapMarkerCfg = require("TableCfg/MapMarkerCfg")
local MapMainCityCfg = require("TableCfg/MapMainCityCfg")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerEventType = ProtoRes.MapMarkerEventType


---@class MapMarkerProviderFixPoint : MapMarkerProvider
local MapMarkerProviderFixPoint = LuaClass(MapMarkerProvider)

function MapMarkerProviderFixPoint:Ctor()

end

function MapMarkerProviderFixPoint:GetMarkerType()
	return MapMarkerType.FixPoint
end

function MapMarkerProviderFixPoint:OnGetMarkers(UIMapID, MapID)
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	local MapMarkers = self:GetFixPointMarkers(Cfg.Marker) or {}

	self:GetTransDoorFixPointMarker(MapMarkers, UIMapID)

	local FollowMarker = self:GetFollowMarker()
	if FollowMarker then
		table.insert(MapMarkers, FollowMarker)
	end

	return MapMarkers
end

function MapMarkerProviderFixPoint:OnCreateMarker(Params, IsRegion)
	if IsRegion then
		return self:CreateMarker(MapMarkerRegion, Params.ID, Params)
	else
		return self:CreateMarker(MapMarkerFixedPoint, Params.ID, Params)
	end
end

function MapMarkerProviderFixPoint:GetFixPointMarkers(MarkerID)
	if MarkerID == 0 then
		return
	end
	local AllCfg = MapMarkerCfg:GetAllMarkerCfg(MarkerID)
	if nil == AllCfg then
		return
	end

	local MapMarkers = {}

	local IsLink = false

	for i = 1, #AllCfg do
		local MarkerCfg = AllCfg[i]
		if nil ~= MarkerCfg and MarkerCfg.Layout > 0 and (MarkerCfg.Icon > 0 or MarkerCfg.Name > 0)
			and MarkerCfg.EventType ~= MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR then
			local IsRegion = MarkerCfg.Region > 0
			local MapMarker = self:OnCreateMarker(MarkerCfg, IsRegion)
			if nil ~= MapMarker then
				table.insert(MapMarkers, MapMarker)

				-- 二级地图里这里比较难理解
				if IsRegion then
					--[[
					if IsLink then
						MapMarker:SetIsEnableHitTest(false)
					end
					IsLink = not IsLink and MapMarker:IsLink()
					--]]

					if MapMarker:IsLink() then
						-- 配置为Link的Region，默认只能点击包含大水晶的主城
						if not MapUtil.MapHasAcrossMapCrystal(MarkerCfg.EventArg) then
							MapMarker:SetIsEnableHitTest(false)
						end
					end

					self:GetRegionFixPointMarker(MapMarkers, MarkerCfg.EventArg, MarkerCfg.PosX, MarkerCfg.PosY, MapMarker:GetPictureScale())

					--print("ID, Link, IsEnableHitTest, Name", MapMarker:GetID(), MapMarker:IsLink(), MapMarker:GetIsEnableHitTest(), MapMarker:GetTipsName())
				end

			end
		end
	end

	return MapMarkers
end

---获取二级地图的标记
function MapMarkerProviderFixPoint:GetRegionFixPointMarker(MapMarkers, UIMapID, PosX, PosY, PictureScale)
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	local EventType = MapMarkerEventType.MAP_MARKER_EVENT_TELEPO
	local AllCfg = MapMarkerCfg:WorldMapGetAllMarkerCfgByEventType(Cfg.Marker, EventType)
	if nil == AllCfg then
		return
	end

	for i = 1, #AllCfg do
		-- 二级地图只显示传送大水晶，过滤掉小水晶；未开放地图大水晶要隐藏
		if MapUtil.IsAcrossMapCrystalByMarkerCfg(AllCfg[i])
			and MapUtil.IsUIMapOpenByVersion(UIMapID) then
			local Marker = self:OnCreateMarker(AllCfg[i], false)
			Marker:SetRegionInfo(PosX, PosY, PictureScale)
			table.insert(MapMarkers, Marker)
		end
	end
end

---获取传送门标记。传送门标记显示在主城地图上，是手游新加的标记
function MapMarkerProviderFixPoint:GetTransDoorFixPointMarker(MapMarkers, UIMapID)
	if not self:CanShowDransDoorMarker(UIMapID) then
		return
	end

	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if nil == Cfg then
		return
	end

	local EventType = MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR
	local AllCfg = MapMarkerCfg:WorldMapGetAllMarkerCfgByEventType(Cfg.Marker, EventType)
	if nil == AllCfg then
		return
	end

	for i = 1, #AllCfg do
		local Marker = self:OnCreateMarker(AllCfg[i], false)
		table.insert(MapMarkers, Marker)
	end
end

---是否显示传送门标记
function MapMarkerProviderFixPoint:CanShowDransDoorMarker(UIMapID)
	-- 判断主角当前是否在主城
	local bInMainCity = false
	local CurrMainCityMapID = 0
	local CurrMapID = _G.PWorldMgr:GetCurrMapResID()

	local AllCfg = MapMainCityCfg:FindAllCfg()
	for _, MapMainCityCfgData in ipairs(AllCfg) do
		if table.contain(MapMainCityCfgData.MapIDList, CurrMapID)
			and table.contain(MapMainCityCfgData.UIMapIDList, UIMapID) then
			bInMainCity = true
			CurrMainCityMapID = MapMainCityCfgData.MainCityMapID
			break
		end
	end
	if not bInMainCity then
		return false
	end

	-- 判断所在主城是否全部小水晶都激活
	local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
	local bAllActivated = CrystalMgr:IsAllSamllCrystalActivated(CurrMainCityMapID)

	return bAllActivated
end


-- 获取当前UIMapID的地标点追踪标记
function MapMarkerProviderFixPoint:GetFollowMarker()
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil  then
		return
	end
	if FollowInfo.FollowType ~= self:GetMarkerType() then
		return
	end
	local MarkerCfg = MapMarkerCfg:FindCfgByKey(FollowInfo.FollowID)
	if MarkerCfg == nil then
		return
	end
	local FollowUIMapID = FollowInfo.FollowUIMapID

	if MapUtil.IsAreaMap(self.UIMapID) then
		-- 三级地图的追踪标记在GetFixPointMarkers已处理
		return

	elseif MapUtil.IsRegionMap(self.UIMapID) then
		-- 二级地图的追踪标记
		if MapUtil.IsSpecialUIMap(FollowUIMapID) then
			return
		end
		local RegionUIMapID = MapUtil.GetUpperUIMapID(FollowUIMapID)
		if RegionUIMapID == self.UIMapID then
			-- 在GetFixPointMarkers里已处理传送大水晶，如果追踪了传送大水晶要过滤掉
			-- 二级地图，金碟游乐场大水晶默认没处理，如果追踪了传送大水晶要显示
			if MapUtil.IsAcrossMapCrystalByMarkerCfg(MarkerCfg) and FollowUIMapID ~= 196 then
				return
			end
			local Marker = self:OnCreateMarker(MarkerCfg, false)
			local SetPosResult = MapUtil.SetRegionUIPos(Marker, self.UIMapID, FollowUIMapID)
			if not SetPosResult then
				return
			end
			return Marker
		end

	elseif MapUtil.IsWorldMap(self.UIMapID) then
		-- 一级地图的追踪标记
		local Marker = self:OnCreateMarker(MarkerCfg, false)
		local RegionUIMapID = MapUtil.GetUpperUIMapID(FollowUIMapID)
		MapUtil.SetWorldUIPos(Marker, self.UIMapID, RegionUIMapID)
		return Marker
	end
end

-- 水晶激活后更新水晶标记
function MapMarkerProviderFixPoint:UpdateCrystalMarker(Params)
	for _, Marker in ipairs(self.MapMarkers) do
		if MapMarkerEventType.MAP_MARKER_EVENT_TELEPO == Marker:GetEventType() then
			local CrystalID = Marker:GetEventArg()
			if CrystalID == Params then
				Marker:UpdateMarker()
				self:SendUpdateMarkerEvent(Marker)

				-- 水晶激活，如果正在追踪要取消
				local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
				if FollowInfo and FollowInfo.FollowType == MapMarkerType.FixPoint and FollowInfo.FollowID == Marker:GetID() then
					_G.WorldMapMgr:CancelMapFollow()
				end

				break
			end
		end
	end
end

return MapMarkerProviderFixPoint