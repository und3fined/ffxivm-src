-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChatGifTypeCfg : CfgBase
local ChatGifTypeCfg = {
	TableName = "c_chat_gif_type_cfg",
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
    DefaultValues = {
        ID = 1,
        RedDotID = 302,
    },
	LuaData = {
        {
        },
        {
            ID = 2,
            RedDotID = 303,
        },
	},
}

setmetatable(ChatGifTypeCfg, { __index = CfgBase })

ChatGifTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ChatGifTypeCfg
