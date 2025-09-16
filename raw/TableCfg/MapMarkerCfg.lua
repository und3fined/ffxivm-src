-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MapMarkerCfg : CfgBase
local MapMarkerCfg = {
	TableName = "c_MapMarker_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MapMarkerCfg, { __index = CfgBase })

MapMarkerCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


---GetMarkersCfg @获取某个地图的所有Marker
---@param Marker number
function MapMarkerCfg:GetAllMarkerCfg(Marker)
	local SearchConditions = string.format("Marker = %d", Marker)
	return self:FindAllCfg(SearchConditions)
end

---WorldMapGetAllMarkerCfgByEventType @获取某个地图的事件类型为EventType的所有Marker
---@param Marker number
---@param EventType number
function MapMarkerCfg:WorldMapGetAllMarkerCfgByEventType(Marker, EventType)
	local SearchConditions = string.format("Marker = %d AND EventType=%d", Marker, EventType)
	return self:FindAllCfg(SearchConditions)
end

---GetMarkerCfgByEventTypeAndArg @获取某个地图的事件类型为EventType并且事件参数为EventArg的Marker
---@param Marker number
---@param EventType number
function MapMarkerCfg:GetMarkerCfgByEventTypeAndArg(Marker, EventType, EventArg)
	local SearchConditions = string.format("Marker = %d AND EventType=%d AND EventArg=%d", Marker, EventType, EventArg)
	return self:FindCfg(SearchConditions)
end

---GetMarkerCfgByEventTypeAndArg2 @获取事件类型为EventType并且事件参数为EventArg的Marker，不区分地图
---@param Marker number
---@param EventType number
function MapMarkerCfg:GetMarkerCfgByEventTypeAndArg2(EventType, EventArg)
	local SearchConditions = string.format("EventType=%d AND EventArg=%d", EventType, EventArg)
	return self:FindAllCfg(SearchConditions)
end

return MapMarkerCfg
