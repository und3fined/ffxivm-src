-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class OnlineStatusSetCfg : CfgBase
local OnlineStatusSetCfg = {
	TableName = "c_online_status_set_cfg",
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

setmetatable(OnlineStatusSetCfg, { __index = CfgBase })

OnlineStatusSetCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return OnlineStatusSetCfg
