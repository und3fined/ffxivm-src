-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class OnlineStatusCfg : CfgBase
local OnlineStatusCfg = {
	TableName = "c_online_status_cfg",
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

setmetatable(OnlineStatusCfg, { __index = CfgBase })

OnlineStatusCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return OnlineStatusCfg
