-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class YellCfg : CfgBase
local YellCfg = {
	TableName = "c_yell_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Text',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(YellCfg, { __index = CfgBase })

YellCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return YellCfg
