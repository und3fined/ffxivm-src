-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateNpcDialogCfg : CfgBase
local FateNpcDialogCfg = {
	TableName = "c_fate_npc_dialog_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'FateName',
            },
            {
                Name = 'MapName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateNpcDialogCfg, { __index = CfgBase })

FateNpcDialogCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateNpcDialogCfg
