-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ProfClassCfg : CfgBase
local ProfClassCfg = {
	TableName = "c_prof_class_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ProfClass',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ProfClassCfg, { __index = CfgBase })

ProfClassCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ProfClassCfg
