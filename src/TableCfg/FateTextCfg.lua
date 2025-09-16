-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateTextCfg : CfgBase
local FateTextCfg = {
	TableName = "c_fate_text_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'NameCh',
            },
            {
                Name = 'StoryCh',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateTextCfg, { __index = CfgBase })

FateTextCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateTextCfg
