local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MajorUtil = require("Utils/MajorUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local LSTR = _G.LSTR
local UE = _G.UE

---最早只显示码头,现在所有传送npc都用这个
---@class MapMarkerChocoboWharf
local MapMarkerChocoboWharf = LuaClass(MapMarker)

---Ctor
function MapMarkerChocoboWharf:Ctor()
	self.WharfNpcID = nil
	self.MapID = nil
	self.WorldPosX = 0
	self.WorldPosY = 0
	self.WorldPosZ = 0
	self.TipName = ""
	self.Icon = nil
	self.IsCanClick = false --只有任务最近的港口可以点击
end

function MapMarkerChocoboWharf:SetCanClick(Val)
	self.IsCanClick = Val
end

function MapMarkerChocoboWharf:GetType()
	return MapMarkerType.ChocoboTransportWharf
end

function MapMarkerChocoboWharf:GetBPType()
	return MapMarkerBPType.CommIconBottom
end

function MapMarkerChocoboWharf:GetPosition()
	return self.AreaUIPosX, self.AreaUIPosY
end

function MapMarkerChocoboWharf:GetWorldPos()
	return self.WorldPosX, self.WorldPosY, self.WorldPosZ
end

function MapMarkerChocoboWharf:GetTipsName()
	return self.TipName
end

function MapMarkerChocoboWharf:GetAlpha()
	return 1
end

function MapMarkerChocoboWharf:IsIconVisible()
	return true
end

function MapMarkerChocoboWharf:InitMarker(Params)
	self:UpdateMarker(Params)
end

---@param Params @c_trans_graph_cfg
function MapMarkerChocoboWharf:UpdateMarker(Params)
	self.WharfNpcID = Params.ActorResID
	self.MapID = _G.PWorldMgr:GetCurrMapResID()

	local GapItem = _G.ChocoboTransportMgr:GetMapGapItem(self.MapID, self.WharfNpcID )
	if GapItem then
		self.TipName = GapItem.MapName
		self.Icon = GapItem.MapIcon
	end

	self:UpdateIcon()
end

function MapMarkerChocoboWharf:UpdateIcon()
	self:SetIconPath(self.Icon)
end

function MapMarkerChocoboWharf:SetWorldPos(X, Y, Z)
	self.WorldPosX = X
	self.WorldPosY = Y
	self.WorldPosZ = Z
end

function MapMarkerChocoboWharf:OnTriggerMapEvent(EventParams)
	--判断目的地是否可达
	local Major = MajorUtil.GetMajor()
	local StartPos = Major:FGetActorLocation()
	local EndPos = {X=self.WorldPosX, Y=self.WorldPosY, Z=self.WorldPosZ}
	if not _G.ChocoboTransportMgr:IsSameMapBlock(self.MapID, StartPos, EndPos) then
		MsgTipsUtil.ShowTips(LSTR(580006), 3)
		return
	end

	_G.ChocoboTransportMgr:SendFindPath(UE.FVector(self.WorldPosX, self.WorldPosY, self.WorldPosZ))

	local Params = { MapMarker = self, ScreenPosition = EventParams.ScreenPosition }
	UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsChocoboTransport, Params)
end

return MapMarkerChocoboWharf