-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MapRegionCfg : CfgBase
local MapRegionCfg = {
	TableName = "c_map_region_cfg",
    LruKeyType = nil,
	KeyName = "MapID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MapRegionCfg, { __index = CfgBase })

MapRegionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MapRegionCfg
