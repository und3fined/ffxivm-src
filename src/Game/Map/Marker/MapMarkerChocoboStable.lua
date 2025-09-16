local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local NpcCfgTable = require("TableCfg/NpcCfg")
local MapNpcIconCfg = require("TableCfg/MapNpcIconCfg")
local MajorUtil = require("Utils/MajorUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local LSTR = _G.LSTR
local UE = _G.UE

---@class MapMarkerChocoboStable
local MapMarkerChocoboStable = LuaClass(MapMarker)

---Ctor
function MapMarkerChocoboStable:Ctor()
	self.NpcID = nil
	self.MapID = nil
	self.ListID = nil
	self.Radius = 0
	self.WorldPosX = 0
	self.WorldPosY = 0
	self.WorldPosZ = 0
	self.Name = ""
	self.IsBook = nil
end

function MapMarkerChocoboStable:GetType()
	return MapMarkerType.ChocoboStable
end

function MapMarkerChocoboStable:GetBPType()
	return MapMarkerBPType.ChocoboTransportPoint
end

function MapMarkerChocoboStable:GetPosition()
	return self.AreaUIPosX, self.AreaUIPosY
end

function MapMarkerChocoboStable:GetWorldPos()
	return self.WorldPosX, self.WorldPosY, self.WorldPosZ
end

function MapMarkerChocoboStable:GetTipsName()
	return self.Name
end

--[[
function MapMarkerChocoboStable:GetAlpha()
	if _G.FogMgr:IsAllActivate(self.MapID) then
		return 1
	end

	local MapNpcIconCfgItem = MapNpcIconCfg:FindCfgByKey(self.NpcID)
	if not MapNpcIconCfgItem then
		return 1
	end
	local InDiscovery = MapNpcIconCfgItem.InDiscovery
	if InDiscovery and InDiscovery > 0 then
		return _G.FogMgr:IsInFlag(self.MapID, InDiscovery) and 1 or 0.5
	end
	return 1
end
]]

function MapMarkerChocoboStable:IsIconVisible()
	return true
end

function MapMarkerChocoboStable:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerChocoboStable:UpdateMarker(Params)
	self.NpcID = Params.NpcID
	self.MapID = Params.MapID
	self.ListID = Params.ListID
	self.ID = Params.ListID

	local NpcCfgItem = NpcCfgTable:FindCfgByKey(self.NpcID)
	if NpcCfgItem then
		self.Name = NpcCfgItem.Name
	end

	self:UpdateIcon()
end

function MapMarkerChocoboStable:UpdateIcon()
	self.IsBook = _G.ChocoboTransportMgr:IsBook(self.MapID, self.NpcID)
	if self.IsBook then
		self:SetIconPath("PaperSprite'/Game/UI/Atlas/ChocoboTransport/Frames/UI_ChocoboTransport_Icon_BirdRoom_Activation_png.UI_ChocoboTransport_Icon_BirdRoom_Activation_png'")
	else
		self:SetIconPath("PaperSprite'/Game/UI/Atlas/ChocoboTransport/Frames/UI_ChocoboTransport_Icon_BirdRoom_Normal_png.UI_ChocoboTransport_Icon_BirdRoom_Normal_png'")
	end
end

function MapMarkerChocoboStable:SetWorldPos(X, Y, Z)
	self.WorldPosX = X
	self.WorldPosY = Y
	self.WorldPosZ = Z
end

function MapMarkerChocoboStable:OnTriggerMapEvent(EventParams)
	--判断目的地是否可达
	local Major = MajorUtil.GetMajor()
	local StartPos = Major:FGetActorLocation()
	local EndPos = {X=self.WorldPosX, Y=self.WorldPosY, Z=self.WorldPosZ}
	if not _G.ChocoboTransportMgr:IsSameMapBlock(self.MapID, StartPos, EndPos) then
		MsgTipsUtil.ShowTips(LSTR(580006), 3) --580006=该目的地无法使用陆行鸟运输到达，请使用其他运输方式。
		return
	end

	--寻找鸟房npc前面的位置点
	--local OffsetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(self.MapID, self.NpcID)
	--if OffsetPos then
	--	_G.ChocoboTransportMgr:SendFindPath(OffsetPos)
	--else
		_G.ChocoboTransportMgr:SendFindPath(UE.FVector(self.WorldPosX, self.WorldPosY, self.WorldPosZ))
	--end

	local Params = { MapMarker = self, ScreenPosition = EventParams.ScreenPosition }
	UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsChocoboTransport, Params)
end

--[[
function MapMarkerChocoboStable:IsIconVisible(Scale)
	self.IsBook = _G.ChocoboTransportMgr:IsBook(self.MapID, self.NpcID)
	if self.IsBook then
		self.IconPath = "PaperSprite'/Game/UI/Atlas/ChocoboTransport/Frames/UI_ChocoboTransport_Icon_BirdRoom_Activation_png.UI_ChocoboTransport_Icon_BirdRoom_Activation_png'"
	else
		self.IconPath = "PaperSprite'/Game/UI/Atlas/ChocoboTransport/Frames/UI_ChocoboTransport_Icon_BirdRoom_Normal_png.UI_ChocoboTransport_Icon_BirdRoom_Normal_png'"
	end
	return true
end
]]

return MapMarkerChocoboStable