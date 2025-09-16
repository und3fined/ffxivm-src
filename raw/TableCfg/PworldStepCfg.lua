-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PworldStepCfg : CfgBase
local PworldStepCfg = {
	TableName = "c_pworld_step_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Steps',
                Children = {
                    {
                        Name = 'Text',
                    },
				},
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PworldStepCfg, { __index = CfgBase })

PworldStepCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return PworldStepCfg
