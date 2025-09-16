-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EmotionCfg : CfgBase
local EmotionCfg = {
	TableName = "c_emotion_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'EmotionName',
            },
            {
                Name = 'WayToGet',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EmotionCfg, { __index = CfgBase })

EmotionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return EmotionCfg
