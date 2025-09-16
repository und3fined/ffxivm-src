-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MallCfg : CfgBase
local MallCfg = {
	TableName = "c_Mall_cfg",
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

setmetatable(MallCfg, { __index = CfgBase })

MallCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MallCfg
