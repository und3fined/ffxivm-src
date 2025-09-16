-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SysnoticeCfg : CfgBase
local SysnoticeCfg = {
	TableName = "c_sysnotice_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Content',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SysnoticeCfg, { __index = CfgBase })

SysnoticeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return SysnoticeCfg
