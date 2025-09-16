-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SingstateCfg : CfgBase
local SingstateCfg = {
	TableName = "c_singstate_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SingName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SingstateCfg, { __index = CfgBase })

SingstateCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SingstateCfg
