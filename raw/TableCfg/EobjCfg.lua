-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EobjCfg : CfgBase
local EobjCfg = {
	TableName = "c_eobj_cfg",
    LruKeyType = "integer",
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

setmetatable(EobjCfg, { __index = CfgBase })

EobjCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return EobjCfg
