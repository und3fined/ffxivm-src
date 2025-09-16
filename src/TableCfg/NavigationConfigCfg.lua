-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class NavigationConfigCfg : CfgBase
local NavigationConfigCfg = {
	TableName = "c_navigation_config_cfg",
    LruKeyType = nil,
	KeyName = "ConfigID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(NavigationConfigCfg, { __index = CfgBase })

NavigationConfigCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return NavigationConfigCfg
