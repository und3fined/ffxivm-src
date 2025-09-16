-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CliffHangerCfg : CfgBase
local CliffHangerCfg = {
	TableName = "c_CliffHanger_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SignUpTipContent',
            },
            {
                Name = 'RescueChickenGameDesc',
            },
            {
                Name = 'RescueChickenGameInfo',
            },
            {
                Name = 'RescueChickenZone',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CliffHangerCfg, { __index = CfgBase })

CliffHangerCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CliffHangerCfg
