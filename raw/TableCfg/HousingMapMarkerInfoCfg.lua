-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HousingMapMarkerInfoCfg : CfgBase
local HousingMapMarkerInfoCfg = {
	TableName = "c_HousingMapMarkerInfo_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(HousingMapMarkerInfoCfg, { __index = CfgBase })

HousingMapMarkerInfoCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


---查找指定UI地图的所有房屋地图标记
function HousingMapMarkerInfoCfg:GetAllMarkerInfoCfg(UIMapID)
	local SearchConditions = string.format("UIMapID = %d", UIMapID)
	return self:FindAllCfg(SearchConditions)
end

---查找房屋地图标记
function HousingMapMarkerInfoCfg:GetMarkerInfoCfg(MapID, BlockID)
	local SearchConditions = string.format("MapID = %d AND BlockID = %d", MapID, BlockID)
	return self:FindCfg(SearchConditions)
end

return HousingMapMarkerInfoCfg
