-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ModuleOpenCfg : CfgBase
local ModuleOpenCfg = {
	TableName = "c_module_open_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SysNotice',
            },
            {
                Name = 'SubSysNotice',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ModuleOpenCfg, { __index = CfgBase })

ModuleOpenCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ModuleOpenCfg
