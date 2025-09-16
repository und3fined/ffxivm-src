-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LoginTimeCfg : CfgBase
local LoginTimeCfg = {
	TableName = "c_login_time_cfg",
    LruKeyType = nil,
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

setmetatable(LoginTimeCfg, { __index = CfgBase })

LoginTimeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LoginTimeCfg
