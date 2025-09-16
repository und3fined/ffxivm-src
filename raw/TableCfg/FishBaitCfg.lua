-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FishBaitCfg : CfgBase
local FishBaitCfg = {
	TableName = "c_fish_bait_cfg",
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

setmetatable(FishBaitCfg, { __index = CfgBase })

FishBaitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FishBaitCfg
