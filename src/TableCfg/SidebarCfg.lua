-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SidebarCfg : CfgBase
local SidebarCfg = {
	TableName = "c_sidebar_cfg",
    LruKeyType = nil,
	KeyName = "Type",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TypeName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SidebarCfg, { __index = CfgBase })

SidebarCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SidebarCfg
