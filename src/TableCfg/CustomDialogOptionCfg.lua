-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CustomDialogOptionCfg : CfgBase
local CustomDialogOptionCfg = {
	TableName = "c_custom_dialog_option_cfg",
    LruKeyType = nil,
	KeyName = "CustomTalkID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Title',
            },
            {
                Name = 'Options',
                Children = {
                    {
                        Name = 'Title',
                    },
				},
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CustomDialogOptionCfg, { __index = CfgBase })

CustomDialogOptionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CustomDialogOptionCfg
