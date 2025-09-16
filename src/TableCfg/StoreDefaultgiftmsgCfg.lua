-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StoreDefaultgiftmsgCfg : CfgBase
local StoreDefaultgiftmsgCfg = {
	TableName = "c_store_defaultgiftmsg_cfg",
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

setmetatable(StoreDefaultgiftmsgCfg, { __index = CfgBase })

StoreDefaultgiftmsgCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return StoreDefaultgiftmsgCfg
