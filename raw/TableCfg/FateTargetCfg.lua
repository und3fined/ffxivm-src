-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateTargetCfg : CfgBase
local FateTargetCfg = {
	TableName = "c_fate_target_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'FateName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateTargetCfg, { __index = CfgBase })

FateTargetCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateTargetCfg
