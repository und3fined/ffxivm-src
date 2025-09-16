-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ShareActivityCfg : CfgBase
local ShareActivityCfg = {
	TableName = "c_share_activity_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TitleBig',
            },
            {
                Name = 'TitleMedium',
            },
            {
                Name = 'TitleSmall',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ShareActivityCfg, { __index = CfgBase })

ShareActivityCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ShareActivityCfg
