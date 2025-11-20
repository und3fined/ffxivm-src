-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChatGlobalCfg : CfgBase
local ChatGlobalCfg = {
	TableName = "c_chat_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ID = 1,
        _Val = '[6]',
    },
	LuaData = {
        {
            _Val = '[9999]',
        },
        {
            ID = 3,
        },
        {
            ID = 4,
            _Val = '[14]',
        },
        {
            ID = 5,
        },
        {
            ID = 6,
            _Val = '[40]',
        },
	},
}

setmetatable(ChatGlobalCfg, { __index = CfgBase })

ChatGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ChatGlobalCfg
