-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MapCfg : CfgBase
local MapCfg = {
	TableName = "c_map_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'RegionName',
            },
            {
                Name = 'DisplayName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MapCfg, { __index = CfgBase })

MapCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return MapCfg
