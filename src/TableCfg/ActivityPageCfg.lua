-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ActivityPageCfg : CfgBase
local ActivityPageCfg = {
	TableName = "c_activity_page_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'PageName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ActivityPageCfg, { __index = CfgBase })

ActivityPageCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ActivityPageCfg
