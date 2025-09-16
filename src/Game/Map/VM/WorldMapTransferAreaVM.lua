local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local WorldMapTransferMapVM = require("Game/Map/VM/WorldMapTransferMapVM")
local MapUtil = require("Game/Map/MapUtil")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")
local MapMap2areaCfg = require("TableCfg/MapMap2areaCfg")
local ProtoRes = require("Protocol/ProtoRes")

local TELEPORT_CRYSTAL_TYPE = ProtoRes.TELEPORT_CRYSTAL_TYPE
local TELEPORT_CRYSTAL_ACROSSMAP = TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP


---@class WorldMapTransferAreaVM : UIViewModel
local WorldMapTransferAreaVM = LuaClass(UIViewModel)

function WorldMapTransferAreaVM:Ctor()
	self.AreaID = nil
	self.AreaName = nil
	self.MapList = UIBindableList.New(WorldMapTransferMapVM)
end

function WorldMapTransferAreaVM:IsEqualVM(Value)
	return nil ~= Value and Value.AreaID == self.AreaID
end

function WorldMapTransferAreaVM:UpdateVM(AreaInfo)
	self.AreaInfo = AreaInfo
    self.AreaID = AreaInfo.ID
	self.AreaName = AreaInfo.Name
	self:UpdateMapList()
end

function WorldMapTransferAreaVM:UpdateMapList()
	local MapList = {}
	local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()

	if _G.WorldMapVM.RegionID ~= _G.WorldMapVM.FavorRegionID then
		local TempList = _G.WorldMapVM.Area2MapTable[self.AreaID]
		for _, MapInfo in pairs(TempList) do
			local SearchConditions = string.format("MapID = %d AND Type == %d", MapInfo.ID, TELEPORT_CRYSTAL_ACROSSMAP)
			local AllCfg = TeleportCrystalCfg:FindAllCfg(SearchConditions)
			for i = 1, #AllCfg do
				local CrystalCfg = AllCfg[i]
				if CrystalCfg and CrystalMgr:IsExistActiveCrystal(CrystalCfg.ID)
					and MapUtil.IsUIMapOpenByVersion(MapUtil.GetUIMapID(MapInfo.ID)) then
					local CrystalName = MapUtil.GetTransferCrystalName(CrystalCfg.ID)
					table.insert(MapList, { ID = CrystalCfg.ID, MapID = MapInfo.ID, MapName = MapInfo.MapName, CrystalName = CrystalName })
				end
			end
		end

	else
		local FavorTransferList = _G.WorldMapMgr:GetFavorTransferList()
		for _, CrystalID in ipairs(FavorTransferList) do
			local CrystalCfg = TeleportCrystalCfg:FindCfgByKey(CrystalID)
			if CrystalCfg and CrystalMgr:IsExistActiveCrystal(CrystalCfg.ID)
				and MapUtil.IsUIMapOpenByVersion(MapUtil.GetUIMapID(CrystalCfg.MapID)) then
				local Map2area = MapMap2areaCfg:FindCfgByKey(CrystalCfg.MapID)
				if Map2area and Map2area.AreaID == self.AreaID then
					local CrystalName = MapUtil.GetTransferCrystalName(CrystalCfg.ID)
					table.insert(MapList, { ID = CrystalCfg.ID, MapID = CrystalCfg.MapID, MapName = Map2area.MapName, CrystalName = CrystalName })
				end
			end
		end
	end

	-- 排序规则：（1）按水晶是否激活 （2）按水晶所在地图的UIMapID里的优先级 （3）同地图的按水晶ID
	local function SortMap(WorldMapTransferMapVMLeft, WorldMapTransferMapVMRight)
		if WorldMapTransferMapVMLeft.IsActive ~= WorldMapTransferMapVMRight.IsActive then
			if WorldMapTransferMapVMLeft.IsActive then
				return true
			elseif WorldMapTransferMapVMRight.IsActive then
				return false
			end
		end

		if WorldMapTransferMapVMLeft.PriorityUI ~= WorldMapTransferMapVMRight.PriorityUI then
			return WorldMapTransferMapVMLeft.PriorityUI < WorldMapTransferMapVMRight.PriorityUI
		end

		return WorldMapTransferMapVMLeft.CrystalID < WorldMapTransferMapVMRight.CrystalID
	end

	self.MapList:UpdateByValues(MapList, SortMap)
end

function WorldMapTransferAreaVM:AdapterOnGetWidgetIndex()
	return 0
end

function WorldMapTransferAreaVM:AdapterOnGetChildren()
	return self.MapList:GetItems()
end

function WorldMapTransferAreaVM:AdapterOnGetCanBeSelected()
	return false
end

function WorldMapTransferAreaVM:AdapterOnGetIsVisible()
	return self.MapList:Length() > 0
end

return WorldMapTransferAreaVM