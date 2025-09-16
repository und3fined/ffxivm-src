-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PromoteLevelUpCfg : CfgBase
local PromoteLevelUpCfg = {
	TableName = "c_promote_level_up_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'UnlockedText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PromoteLevelUpCfg, { __index = CfgBase })

PromoteLevelUpCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PromoteLevelUpCfg
