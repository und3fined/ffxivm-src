local LuaClass = require("Core/LuaClass")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

---@class MapMarkerMineVM : MapMarkerVM
local MapMarkerMineVM = LuaClass(MapMarkerVM)

---Ctor
function MapMarkerMineVM:Ctor()
	self.TreasureMineTime = ""
end

function MapMarkerMineVM:UpdateVM(Value)
	self.MapMarker = Value
	self.Name = Value:GetName()
	self.IconPath = Value:GetIconPath()
	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
	self:UpdateMarkerVisible()

	self.PosID = Value:GetPosID()
	self.StartTime = Value:GetStartTime()
	self:CloseOpenChestTimer()
	self.OpenChestTimer = _G.TimerMgr:AddTimer(self, self.CountDownTreasureHuntInfo, 0, 0.1, -1)
end

function MapMarkerMineVM:CloseOpenChestTimer()
	if self.OpenChestTimer ~= nil then
		_G.TimerMgr:CancelTimer(self.OpenChestTimer)
		self.OpenChestTimer = nil
	end
end

function MapMarkerMineVM:CountDownTreasureHuntInfo()
	if self.StartTime == nil then
		self:CloseOpenChestTimer()
		local Params = {}
		table.insert(Params, { self.PosID })
		_G.EventMgr:SendEvent(EventID.TreasureHuntRemoveMapMine, Params)
		return
	end

    local ServerTime = TimeUtil.GetServerLogicTime()
	local TreasureHuntTimeLimit = _G.TreasureHuntMgr:GetTreasureHuntTimeLimit()
    local RemainTime = self.StartTime + TreasureHuntTimeLimit - ServerTime
    if RemainTime <= 0 then
		self:CloseOpenChestTimer()
		local Params = {}
		table.insert(Params, { self.PosID })
		_G.EventMgr:SendEvent(EventID.TreasureHuntRemoveMapMine, Params)
    	return
    end

    local RemainSec = RemainTime
	self.TreasureMineTime = LocalizationUtil.GetCountdownTimeForShortTime(RemainSec, "mm:ss") or ""
end

return MapMarkerMineVM