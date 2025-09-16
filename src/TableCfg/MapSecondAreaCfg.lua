-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MapSecondAreaCfg : CfgBase
local MapSecondAreaCfg = {
	TableName = "c_map_second_area_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'AreaName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MapSecondAreaCfg, { __index = CfgBase })

MapSecondAreaCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MapSecondAreaCfg
