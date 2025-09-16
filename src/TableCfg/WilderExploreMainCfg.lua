-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WilderExploreMainCfg : CfgBase
local WilderExploreMainCfg = {
	TableName = "c_Wilder_Explore_Main_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Description',
            },
            {
                Name = 'OpenTabName',
            },
            {
                Name = 'RewardFuncName',
            },
            {
                Name = 'ProText',
            },
            {
                Name = 'RecomText',
            },
            {
                Name = 'NoRecomText',
            },
            {
                Name = 'BookNoText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(WilderExploreMainCfg, { __index = CfgBase })

WilderExploreMainCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return WilderExploreMainCfg
