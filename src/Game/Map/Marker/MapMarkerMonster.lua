--
-- Author: peterxie
-- Date: 2024-11-07
-- Description: 怪物
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUIUtil = require("Utils/ActorUIUtil")
local MapDefine = require("Game/Map/MapDefine")
local ProtoRes = require("Protocol/ProtoRes")
local MonsterCfg = require("TableCfg/MonsterCfg")
local NPCBaseCfg = require("TableCfg/NpcbaseCfg")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local MapMarkerPriority = MapDefine.MapMarkerPriority


---@class MapMarkerMonster : MapMarker
local MapMarkerMonster = LuaClass(MapMarker)

function MapMarkerMonster:Ctor()
	self.EntityID = nil -- 怪物EntityID
	self.ResID = nil -- 怪物资源ID
    self.IsBoss = false -- 是否是Boss

	self.IsColosseumCrystal = false -- 是否是PVP水晶bnpc
end

function MapMarkerMonster:GetType()
	return MapMarkerType.Monster
end

function MapMarkerMonster:GetBPType()
    return MapMarkerBPType.Monster
end

function MapMarkerMonster:InitMarker(Params)
	self.EntityID = Params.EntityID
	self.ResID = Params.ResID
	self.IsColosseumCrystal = Params.IsColosseumCrystal

	if self.IsColosseumCrystal then
		-- PVP地图水晶bnpc图标要动态更新
		self:UpdateMarker(Params)
		self.IsBoss = true
	else
		-- 非PVP地图的怪物
		local ProfileName = MonsterCfg:FindValue(self.ResID, "ProfileName")
		local iProfileName = tonumber(ProfileName)
		if iProfileName == nil then
			return
		end

		local RankType = NPCBaseCfg:FindValue(iProfileName, "Rank")
		if RankType ~= nil and RankType < ProtoRes.NPC_RANK_TYPE.Hidden then
			if RankType == ProtoRes.NPC_RANK_TYPE.Boss then
				self.IsBoss = true
				self.IconPath = MapDefine.MapIconConfigs.MonsterBoss
			else
				self.IsBoss = false
				self.IconPath = MapDefine.MapIconConfigs.MonsterNormal
			end
		else
			-- 不显示地图红点
			self.IconPath = ""
		end
	end
end

function MapMarkerMonster:UpdateMarker(Params)
	if self.IsColosseumCrystal then
		-- PVP地图水晶bnpc图标要动态更新
		local IconID = _G.PVPColosseumMgr:GetCrystalMapMarkerIconID()
		self.IconPath = MapUtil.GetIconPath(IconID)
	end
end

function MapMarkerMonster:GetPriority()
	local MarkerPriority = MapMarkerPriority.MiddleDefault

	if self.IsColosseumCrystal then
		-- PVP地图水晶bnpc图标优先级，主角最上层，水晶第二层，其他玩家第三层，物件第四层
		MarkerPriority = MapMarkerPriority.Telepo
	end

	return MarkerPriority
end

---获取视野内怪物的UI坐标
function MapMarkerMonster:GetAreaMapPos()
	if self.EntityID then
		return MapUtil.GetActorUIPosByEntityID(self.UIMapID, self.EntityID)
	end
end

function MapMarkerMonster:NeedShowInMiniMap()
	return self:IsInMiniMapVision() and self:IsEnmityMonster()
end

---怪物标记是否仇恨目标
function MapMarkerMonster:IsEnmityMonster()
	if self.IsBoss then
		-- Boss怪图标，一直显示
		return true
	else
		-- 其他怪图标，只有与玩家或玩家的小队成员进入战斗后才显示，死亡或脱战后隐藏
		local EnmityTarget = _G.TargetMgr:GetTargetOfMonster(self.EntityID)
		if EnmityTarget > 0 then
			if MajorUtil.GetMajorEntityID() == EnmityTarget or ActorUIUtil.IsTeamMember(EnmityTarget) then
				return true
			end
		end
	end

	return false
end

return MapMarkerMonster