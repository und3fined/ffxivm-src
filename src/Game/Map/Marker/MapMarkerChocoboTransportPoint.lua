local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")
local MajorUtil = require("Utils/MajorUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local UE = _G.UE

---@class MapMarkerChocoboTransportPoint
local MapMarkerChocoboTransportPoint = LuaClass(MapMarker)

---Ctor
function MapMarkerChocoboTransportPoint:Ctor()
	self.ID = 0
	self.MapID = 0
	self.Radius = 0
	self.WorldPosX = 0
	self.WorldPosY = 0
	self.WorldPosZ = 0
	self.Name = ""
	self.IconPath = ""
	self.IsTrackQuest = false
end

function MapMarkerChocoboTransportPoint:GetType()
	return MapMarkerType.ChocoboTransportPoint
end

function MapMarkerChocoboTransportPoint:GetBPType()
	return MapMarkerBPType.Quest
end

function MapMarkerChocoboTransportPoint:GetPosition()
	return self.AreaUIPosX, self.AreaUIPosY
end

function MapMarkerChocoboTransportPoint:GetWorldPos()
	return self.WorldPosX, self.WorldPosY, self.WorldPosZ
end

function MapMarkerChocoboTransportPoint:GetTipsName()
	return self.Name
end

function MapMarkerChocoboTransportPoint:GetIconPath()
	return self.IconPath
end

function MapMarkerChocoboTransportPoint:IsIconVisible()
	return true
end

function MapMarkerChocoboTransportPoint:GetIsTrackQuest()
	return self.IsTrackQuest
end

function MapMarkerChocoboTransportPoint:SetIsTrackQuest(IsTrack)
	self.IsTrackQuest = IsTrack
end

function MapMarkerChocoboTransportPoint:GetTargetID()
	return self.ID
end

function MapMarkerChocoboTransportPoint:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerChocoboTransportPoint:UpdateMarker(Params)
	self.MapID = Params.MapID
	self.ID = Params.QuestID

	if Params.NaviType == QuestDefine.NaviType.NpcResID then
		self.NaviNpcID = Params.NaviObjID --这里不能用NpcID,只有陆行鸟房才记录在NpcID
	elseif Params.NaviType == QuestDefine.NaviType.CrystalID then
		self.NaviCrystalID = Params.NaviObjID
	elseif Params.NaviType == QuestDefine.NaviType.EObjResID then
		self.NaviEObjID = Params.NaviObjID
	end

	self.IsHasAssistPos = Params.AssistPos ~= nil

	local QuestCfgItem = QuestHelper.GetQuestCfgItem(Params.QuestID)
	if QuestCfgItem then
		local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
		if ChapterCfgItem then
			self.Name = ChapterCfgItem.QuestName
			self.IconPath = _G.QuestMgr:GetQuestIconAtLog(Params.QuestID, ChapterCfgItem.QuestType)
		end
	end
end

function MapMarkerChocoboTransportPoint:SetWorldPos(X, Y, Z)
	self.WorldPosX = X
	self.WorldPosY = Y
	self.WorldPosZ = Z
end

function MapMarkerChocoboTransportPoint:OnTriggerMapEvent(EventParams)
	--判断目的地是否可达
	local Major = MajorUtil.GetMajor()
	local StartPos = Major:FGetActorLocation()
	local EndPos = {X=self.WorldPosX, Y=self.WorldPosY, Z=self.WorldPosZ}
	if not _G.ChocoboTransportMgr:IsSameMapBlock(self.MapID, StartPos, EndPos) then
		MsgTipsUtil.ShowTips(LSTR(580006), 3)
		return
	end
	--没有辅助点,是npc,则寻找npc前面的位置点
	--if not self.IsHasAssistPos and self.NaviNpcID and self.NaviNpcID > 0 then
	--	local OffsetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(self.MapID, self.NaviNpcID)
	--	if OffsetPos then
	--		_G.ChocoboTransportMgr:SendFindPath(OffsetPos)
	--	else
	--		_G.ChocoboTransportMgr:SendFindPath(UE.FVector(self.WorldPosX, self.WorldPosY, self.WorldPosZ))
	--	end
	--else
		_G.ChocoboTransportMgr:SendFindPath(UE.FVector(self.WorldPosX, self.WorldPosY, self.WorldPosZ))
	--end
	local Params = { MapMarker = self, ScreenPosition = EventParams.ScreenPosition }
	UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsChocoboTransport, Params)
end

return MapMarkerChocoboTransportPoint