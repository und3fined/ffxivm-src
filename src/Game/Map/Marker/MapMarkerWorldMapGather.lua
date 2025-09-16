--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-12-09 15:27:41
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-12-09 15:38:27
FilePath: \Client\Source\Script\Game\Map\Marker\MapMarkerWorldMapGather.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--
-- Author: peterxie
-- Date: 2024-06-03 11:44
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local GatherPointCfg = require("TableCfg/GatherPointCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerWorldMapGather : MapMarker
local MapMarkerWorldMapGather = LuaClass(MapMarker)

function MapMarkerWorldMapGather:Ctor()
	self.bTracking = false
	self.Radius = 0 -- 采集点半径
	self.bSelected = false
end

function MapMarkerWorldMapGather:GetType()
	return MapMarkerType.WorldMapGather
end

function MapMarkerWorldMapGather:GetBPType()
	return MapMarkerBPType.GatherRange
end

function MapMarkerWorldMapGather:InitMarker(Params)
	self.ResID = Params.ResID

	local Cfg = GatherPointCfg:FindCfgByKey(Params.ResID)
	if nil ~= Cfg then
		self.IconPath = Cfg.MapIcon
		self.Name = Cfg.Name

		-- 普通和限时采集点表现有区分
		if Cfg.IsUnknownLoc == 1 then
			self.Radius = 400
		else
			self.Radius = 600
		end
	end

	self:UpdateMarker(Params)
end

function MapMarkerWorldMapGather:UpdateMarker(Params)
    self:UpdateFollow()
end

function MapMarkerWorldMapGather:IsNameVisible(Scale)
	return false
end

function MapMarkerWorldMapGather:GetTipsName()
	return self:GetName()
end

function MapMarkerWorldMapGather:GetRadius()
	return self.Radius
end

function MapMarkerWorldMapGather:OnTriggerMapEvent(EventParams)
	local GatherData = _G.GatheringLogMgr:GetSelectGatherData()
	if GatherData == nil then
		_G.FLOG_INFO("MapMarkerWorldMapGather:OnTriggerMapEvent GatherData is nil")
		return
	end
	local GatheringItemJobID = GatherData.GatheringJob
	if _G.GatheringLogMgr:GetCurProfbLock(GatheringItemJobID) then
		MsgTipsUtil.ShowTips(_G.LSTR(700034)) -- "职业未解锁"
		return
	end
	MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
end

function MapMarkerWorldMapGather:ToggleFollow()
	if self:GetIsFollow() then
		_G.WorldMapMgr:CancelMapFollow()
	else
		local MajorProfID = MajorUtil.GetMajorProfID()
		local GatherData = _G.GatheringLogMgr:GetSelectGatherData()
		if GatherData == nil then
			return nil
		end
		local GatheringItemJobID = GatherData.GatheringJob
		--若玩家职业与当前所需职业不符，需要弹出切换职业弹窗
		if MajorProfID ~= GatheringItemJobID then
			_G.GatheringLogMgr:ShowProfUnmatchTips(GatheringItemJobID)
			return false
		end

		self:StartMapFollow()
		_G.WorldMapMgr:ReportData(MapDefine.MapReportType.MapFollow, "1", self:GetType())
		-- if _G.WorldMapMgr:IsOpenAutoPath(self:GetMapID()) then
		-- 	_G.UIViewMgr:HideView(_G.UIViewID.GatheringLogMainPanelView)
		-- end
	end
end

function MapMarkerWorldMapGather:GetIsSelected()
	return self.bSelected
end

function MapMarkerWorldMapGather:SetIsSelected(bSelected)
	self.bSelected = bSelected
end

function MapMarkerWorldMapGather:GetIsTracking()
	return self.bTracking
end

function MapMarkerWorldMapGather:SetIsTracking(bTracking)
	self.bTracking = bTracking
end


return MapMarkerWorldMapGather