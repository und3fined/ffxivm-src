-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RideTextCfg : CfgBase
local RideTextCfg = {
	TableName = "c_ride_text",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Expository',
            },
            {
                Name = 'Cry',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RideTextCfg, { __index = CfgBase })

RideTextCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return RideTextCfg
