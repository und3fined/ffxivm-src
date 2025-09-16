-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StainIdCfg : CfgBase
local StainIdCfg = {
	TableName = "c_stain_id_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(StainIdCfg, { __index = CfgBase })

StainIdCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return StainIdCfg
