-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HeaderFrameTabCfg : CfgBase
local HeaderFrameTabCfg = {
	TableName = "c_header_frame_tab_cfg",
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
        Priority = 1,
    },
	LuaData = {
        {
        },
        {
            ID = 2,
            Priority = 2,
        },
        {
            ID = 3,
            Priority = 3,
        },
        {
            ID = 4,
            Priority = 4,
        },
	},
}

setmetatable(HeaderFrameTabCfg, { __index = CfgBase })

HeaderFrameTabCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return HeaderFrameTabCfg
