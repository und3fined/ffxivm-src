--
-- Author: peterxie
-- Date:
-- Description: 地图传送列表地图
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapUICfg = require("TableCfg/MapUICfg")


---@class WorldMapTransferMapVM : UIViewModel
local WorldMapTransferMapVM = LuaClass(UIViewModel)

function WorldMapTransferMapVM:Ctor()
	self.ID = nil
	self.MapID = nil -- 地图ID
	self.IsHouse = false -- 是否房屋传送，默认是地图水晶传送
	self.Addr = nil			--房屋地址
	self.EtherGid = nil		--房屋私有水晶ID
	self.CrystalID = nil -- 水晶ID
	self.HouseID = nil -- 房屋ID

	self.InfoName1 = nil
	self.InfoName2 = nil
	self.IconPath = nil -- 水晶图标路径
	self.IconPath2 = nil -- 扩展图标
	self.IsShowIcon2 = false -- 是否显示扩展图标

	self.IsActive = false -- 是否激活状态
	self.PriorityUI = 0 -- PriorityUI用来排序

	self.IsInFavor = false -- 是否收藏状态
	self.CanFavor = true -- 是否能收藏
end

function WorldMapTransferMapVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID
end

function WorldMapTransferMapVM:UpdateVM(Info)
	self.IsHouse = Info.IsHouse
	if self.IsHouse then
		self:UpdateVMByHouse(Info)
	else
		self:UpdateVMByMap(Info)
	end
end

function WorldMapTransferMapVM:UpdateVMByMap(MapInfo)
	self.MapInfo = MapInfo
	self.ID = MapInfo.ID
	self.CrystalID = MapInfo.ID
	self.MapID = MapInfo.MapID

    self.InfoName1 = MapInfo.MapName -- 地图名称
	self.InfoName2 = MapInfo.CrystalName -- 水晶名称
	self.IconPath2 = nil
	self.IsShowIcon2 = false

	local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
	self.IsActive = CrystalMgr:IsExistActiveCrystal(self.CrystalID)
	if self.IsActive then
		self.IconPath = MapDefine.MapIconConfigs.CrystalBig
	else
		self.IconPath = MapDefine.MapIconConfigs.CrystalBigGray
	end

	local UIMapID = MapUtil.GetUIMapID(self.MapID)
	self.PriorityUI = MapUICfg:FindValue(UIMapID, "PriorityUI")
	self.IsInFavor = _G.WorldMapMgr:IsInTransferFavor(self.CrystalID)
	self.CanFavor = true
end

function WorldMapTransferMapVM:UpdateVMByHouse(HouseInfo)
	self.HouseInfo = HouseInfo
	self.ID = HouseInfo.ID
	self.HouseID = HouseInfo.ID
	self.MapID = HouseInfo.MapID
	self.Addr = HouseInfo.Addr		--房屋地址
	self.EtherGid = HouseInfo.EtherGid		--房屋私有水晶ID
	local HouseName
	if HouseInfo.Type == 1 then
		HouseName = "个人房屋"
	elseif HouseInfo.Type == 2 then
		HouseName = "部队房屋"
	elseif HouseInfo.Type == 3 then
		HouseName = "共享房屋"
	end
	self.InfoName1 = HouseName -- 房屋名称

	self.IconPath = MapDefine.MapIconConfigs.CrystalHouse

	if HouseInfo.WorldID and HouseInfo.WorldID ~= _G.PWorldMgr:GetCurrWorldID() then
		if HouseInfo.Type == 1 or HouseInfo.Type == 2 then
			self.IconPath2 = MapDefine.MapIconConfigs.ServerOriginal
		elseif HouseInfo.Type == 3 then
			self.IconPath2 = MapDefine.MapIconConfigs.ServerCross
		end
		self.IsShowIcon2 = true

		-- 不在当前服务器时，显示服务器名称
		self.InfoName2 = _G.LoginMgr:GetMapleNodeName(HouseInfo.WorldID)
	else
		self.IconPath2 = nil
		self.IsShowIcon2 = false

		-- 在当前服务器时，显示地图名称
		local UIMapID = MapUtil.GetUIMapID(self.MapID)
		self.InfoName2 = MapUtil.GetMapName(UIMapID)
		if self.Addr and self.Addr.EstateID then
			local EstateInfoCfg = require("TableCfg/EstateInfoCfg")
			local EstateInfo = EstateInfoCfg:FindCfgByKey(self.Addr.EstateID )
			if EstateInfo then
				self.InfoName2 = EstateInfo.EstateName
			end
		end
	end

	self.IsActive = true
	self.PriorityUI = HouseInfo.Type
	self.IsInFavor = false
	self.CanFavor = false
end

function WorldMapTransferMapVM:AdapterOnGetWidgetIndex()
	return 1
end

function WorldMapTransferMapVM:AdapterOnGetCanBeSelected()
    return true
 end

return WorldMapTransferMapVM