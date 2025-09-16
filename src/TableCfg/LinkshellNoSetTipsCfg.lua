-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LinkshellNoSetTipsCfg : CfgBase
local LinkshellNoSetTipsCfg = {
	TableName = "c_linkshell_no_set_tips_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc1',
            },
            {
                Name = 'Desc2',
            },
		}
    },
    DefaultValues = {
        ID = 1,
    },
	LuaData = {
        {
        },
        {
            ID = 2,
        },
        {
            ID = 3,
        },
        {
            ID = 4,
        },
	},
}

setmetatable(LinkshellNoSetTipsCfg, { __index = CfgBase })

LinkshellNoSetTipsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LinkshellNoSetTipsCfg
