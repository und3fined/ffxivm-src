-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class AtlasEntranceCfg : CfgBase
local AtlasEntranceCfg = {
	TableName = "c_atlas_entrance_cfg",
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

setmetatable(AtlasEntranceCfg, { __index = CfgBase })

AtlasEntranceCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return AtlasEntranceCfg
