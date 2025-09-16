-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TransCfg : CfgBase
local TransCfg = {
	TableName = "c_trans_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Question',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TransCfg, { __index = CfgBase })

TransCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TransCfg
