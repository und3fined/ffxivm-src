-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LifeskillEffectCfg : CfgBase
local LifeskillEffectCfg = {
	TableName = "c_lifeskill_effect_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(LifeskillEffectCfg, { __index = CfgBase })

LifeskillEffectCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LifeskillEffectCfg
