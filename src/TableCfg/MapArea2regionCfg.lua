-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MapArea2regionCfg : CfgBase
local MapArea2regionCfg = {
	TableName = "c_map_area2region_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MapArea2regionCfg, { __index = CfgBase })

MapArea2regionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MapArea2regionCfg
