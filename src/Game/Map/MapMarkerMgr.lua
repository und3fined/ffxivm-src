--
-- Author: anypkvcai
-- Date: 2022-12-08 9:54
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapMarkerFactory = require("Game/Map/MapMarkerFactory")

local MapProviderConfigs = MapDefine.MapProviderConfigs
--local FLOG_INFO


---@class MapMarkerMgr : MgrBase
local MapMarkerMgr = LuaClass(MgrBase)

function MapMarkerMgr:OnInit()

end

function MapMarkerMgr:OnBegin()
	--FLOG_INFO = _G.FLOG_INFO
	self.MarkerProviders = {}
end

function MapMarkerMgr:OnEnd()
	self.MarkerProviders = nil
end

function MapMarkerMgr:OnShutdown()

end

function MapMarkerMgr:OnRegisterNetMsg()
end

function MapMarkerMgr:OnRegisterGameEvent()

end

function MapMarkerMgr:OnRegisterTimer()

end

---CreateProviders
---@param ContentType MapContentType
function MapMarkerMgr:CreateProviders(ContentType)
	local MarkerProviders = self.MarkerProviders
	if nil == MarkerProviders then
		return
	end
	--FLOG_INFO("MapMarkerMgr:CreateProviders %d", ContentType)

	local Configs = MapProviderConfigs[ContentType]
	if nil == Configs then
		return
	end

	local Providers = {}

	for i = 1, #Configs do
		local Provider = MapMarkerFactory.CreateMarkerProvider(Configs[i])
		Provider:SetContentType(ContentType)
		table.insert(Providers, Provider)
	end

	MarkerProviders[ContentType] = Providers
end

---ReleaseProviders
---@param ContentType MapContentType
function MapMarkerMgr:ReleaseProviders(ContentType)
	--FLOG_INFO("MapMarkerMgr:ReleaseProviders %d", ContentType)

	if nil ~= self.MarkerProviders then
		self.MarkerProviders[ContentType] = nil
	end
end

function MapMarkerMgr:GetMarkerProviders(MarkerType)
	local MarkerProviders = self.MarkerProviders
	if nil == MarkerProviders then
		return
	end

	local Providers = {}

	for _, v in pairs(MarkerProviders) do
		for i = 1, #v do
			local Provider = v[i]
			if Provider:GetMarkerType() == MarkerType then
				table.insert(Providers, Provider)
			end
		end
	end

	return Providers
end

---@param UIMapID number
---@param ContentType MapContentType
function MapMarkerMgr:GetMapMarkers(UIMapID, MapID, ContentType)
	local MarkerProviders = self.MarkerProviders
	if nil == MarkerProviders then
		return
	end

	local Providers = MarkerProviders[ContentType]
	if nil == Providers then
		return
	end

	local Markers = {}

	local _ <close> = CommonUtil.MakeProfileTag("MapMarkerMgr:GetMapMarkers")

	for i = 1, #Providers do
		local Provider = Providers[i]
		local _ <close> = CommonUtil.MakeProfileTag(string.format("Provider:GetMapMarkers_%s", MapMarkerMgr:GetMapMarkerTypeName(Provider:GetMarkerType())))
		table.merge_table(Markers, Provider:GetMapMarkers(UIMapID, MapID, ContentType))
	end

	return Markers
end


local IdToNameMap = nil

local function IDToName(MarkerType)
	if not IdToNameMap then
		IdToNameMap = {}
		local MapMarkerType = MapDefine.MapMarkerType
		for k, v in pairs(MapMarkerType) do
			IdToNameMap[v] = k
		end
	end

	return IdToNameMap[MarkerType] or "Unknown"
end

function MapMarkerMgr:GetMapMarkerTypeName(MarkerType)
	return IDToName(MarkerType)
end


---@param UIMapID number
---@param ContentType MapContentType
---@param MarkerType MapMarkerType
function MapMarkerMgr:GetMapSpecificMarkers(UIMapID, ContentType, MarkerType)
	local MarkerProviders = self.MarkerProviders
	if nil == MarkerProviders then
		return
	end

	local Providers = MarkerProviders[ContentType]
	if nil == Providers then
		return
	end

	local Markers = {}
	for i = 1, #Providers do
		local Provider = Providers[i]
		if Provider:GetMarkerType() == MarkerType then
			table.merge_table(Markers, Provider:GetMapMarkers(UIMapID, nil, ContentType))
		end
	end

	return Markers
end

function MapMarkerMgr:CheckVisionMarkerOnTimer(ContentType)
	local MarkerProviders = self.MarkerProviders
	if nil == MarkerProviders then
		return
	end

	local Providers = MarkerProviders[ContentType]
	if nil == Providers then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("MapMarkerMgr:CheckVisionMarkerOnTimer")

	for i = 1, #Providers do
		local Provider = Providers[i]
		Provider:CheckVisionMarkerOnTimer()
	end
end

return MapMarkerMgr