-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LoginMapCfg : CfgBase
local LoginMapCfg = {
	TableName = "c_login_map_cfg",
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

setmetatable(LoginMapCfg, { __index = CfgBase })

LoginMapCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LoginMapCfg
