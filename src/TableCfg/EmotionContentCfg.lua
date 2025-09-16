-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EmotionContentCfg : CfgBase
local EmotionContentCfg = {
	TableName = "c_emotion_content_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ContentText',
            },
            {
                Name = 'TargetContentText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EmotionContentCfg, { __index = CfgBase })

EmotionContentCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return EmotionContentCfg
