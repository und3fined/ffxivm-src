-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DefaultDialogCfg : CfgBase
local DefaultDialogCfg = {
	TableName = "c_default_dialog_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'DialogContent',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(DefaultDialogCfg, { __index = CfgBase })

DefaultDialogCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return DefaultDialogCfg
