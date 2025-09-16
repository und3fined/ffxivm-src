-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PlaceNameCfg : CfgBase
local PlaceNameCfg = {
	TableName = "c_PlaceName_cfg",
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

setmetatable(PlaceNameCfg, { __index = CfgBase })

PlaceNameCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PlaceNameCfg
