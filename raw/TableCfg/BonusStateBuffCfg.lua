-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BonusStateBuffCfg : CfgBase
local BonusStateBuffCfg = {
	TableName = "c_bonus_state_buff_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'EffectName',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BonusStateBuffCfg, { __index = CfgBase })

BonusStateBuffCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BonusStateBuffCfg
