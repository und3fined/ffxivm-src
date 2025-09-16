local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MapCfg = require("TableCfg/MapCfg")
local MajorUtil = require("Utils/MajorUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local LSTR = _G.LSTR
local UE = _G.UE

---@class MapMarkerChocoboTransferLine
local MapMarkerChocoboTransferLine = LuaClass(MapMarker)

---Ctor
function MapMarkerChocoboTransferLine:Ctor()
	self.TransferLineID = nil
	self.MapID = nil
	self.ListID = nil
	self.Radius = 0
	self.WorldPosX = 0
	self.WorldPosY = 0
	self.WorldPosZ = 0
	self.TipName = ""
	self.TipIcon = ""
	self.IsCanClick = false --只有任务最近的传送口可以点击
end

function MapMarkerChocoboTransferLine:SetCanClick(Val)
	self.IsCanClick = Val
end

function MapMarkerChocoboTransferLine:GetType()
	return MapMarkerType.ChocoboTransportTransferLine
end

function MapMarkerChocoboTransferLine:GetBPType()
	return MapMarkerBPType.CommIconBottom
end

function MapMarkerChocoboTransferLine:GetPosition()
	return self.AreaUIPosX, self.AreaUIPosY
end

function MapMarkerChocoboTransferLine:GetWorldPos()
	return self.WorldPosX, self.WorldPosY, self.WorldPosZ
end

function MapMarkerChocoboTransferLine:GetTipsName()
	return self.TipName
end

function MapMarkerChocoboTransferLine:GetAlpha()
	return 0 --不可见能点击
end

function MapMarkerChocoboTransferLine:IsIconVisible()
	return true
end

function MapMarkerChocoboTransferLine:InitMarker(Params)
	self:UpdateMarker(Params)
end

---@param Params @c_trans_graph_cfg
function MapMarkerChocoboTransferLine:UpdateMarker(Params)
	self.DstMapID = Params.DstMapID
	self.MapID = _G.PWorldMgr:GetCurrMapResID()
	self.TransferLineID = Params.ID

	local MapCfgItem = MapCfg:FindCfgByKey(self.DstMapID)
	if MapCfgItem then
		self.TipName = string.format(LSTR(580007), MapCfgItem.DisplayName) --580007=前往%s
	end

	--self:UpdateIcon()
end

function MapMarkerChocoboTransferLine:UpdateIcon()
end

function MapMarkerChocoboTransferLine:SetWorldPos(X, Y, Z)
	self.WorldPosX = X
	self.WorldPosY = Y
	self.WorldPosZ = Z
end

function MapMarkerChocoboTransferLine:OnTriggerMapEvent(EventParams)
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


return MapMarkerChocoboTransferLine