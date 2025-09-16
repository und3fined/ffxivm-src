local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapUtil = require("Game/Map/MapUtil")
local MapUICfg = require("TableCfg/MapUICfg")


---@class WorldMapTransferMapVM : UIViewModel
local WorldMapTransferMapVM = LuaClass(UIViewModel)

function WorldMapTransferMapVM:Ctor()
	self.CrystalID = nil
	self.MapID = nil
	self.MapName = nil
	self.CrystalName = nil
	self.IconPath = nil
	self.IsActive = false
	self.PriorityUI = 0
	self.IsInFavor = false
end

function WorldMapTransferMapVM:IsEqualVM(Value)
	return nil ~= Value and Value.CrystalID == self.CrystalID
end

function WorldMapTransferMapVM:UpdateVM(MapInfo)
	self.MapInfo = MapInfo
	self.CrystalID = MapInfo.ID
	self.MapID = MapInfo.MapID
    self.MapName = MapInfo.MapName
	self.CrystalName = MapInfo.CrystalName

	local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
	self.IsActive = CrystalMgr:IsExistActiveCrystal(self.CrystalID)
	if self.IsActive then
		self.IconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060453.UI_Icon_060453'"
	else
		self.IconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060453_gray.UI_Icon_060453_gray'"
	end

	-- PriorityUI用来排序
	local UIMapID = MapUtil.GetUIMapID(self.MapID)
	self.PriorityUI = MapUICfg:FindValue(UIMapID, "PriorityUI")

	self.IsInFavor = _G.WorldMapMgr:IsInTransferFavor(self.CrystalID)
end

function WorldMapTransferMapVM:GetID()
	return self.CrystalID
end

function WorldMapTransferMapVM:AdapterOnGetWidgetIndex()
	return 1
end

function WorldMapTransferMapVM:AdapterOnGetCanBeSelected()
    return true
 end

return WorldMapTransferMapVM