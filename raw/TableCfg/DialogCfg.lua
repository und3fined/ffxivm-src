-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DialogCfg : CfgBase
local DialogCfg = {
	TableName = "c_dialog_cfg",
    LruKeyType = "integer",
	KeyName = "DialogID",
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

setmetatable(DialogCfg, { __index = CfgBase })

DialogCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return DialogCfg
