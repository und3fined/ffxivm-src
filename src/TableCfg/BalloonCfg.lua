-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BalloonCfg : CfgBase
local BalloonCfg = {
	TableName = "c_balloon_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Text',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BalloonCfg, { __index = CfgBase })

BalloonCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BalloonCfg
