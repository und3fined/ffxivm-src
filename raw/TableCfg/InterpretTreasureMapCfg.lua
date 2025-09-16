-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class InterpretTreasureMapCfg : CfgBase
local InterpretTreasureMapCfg = {
	TableName = "c_interpret_treasure_map_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MapTitle',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(InterpretTreasureMapCfg, { __index = CfgBase })

InterpretTreasureMapCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return InterpretTreasureMapCfg
