-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TouringBandCfg : CfgBase
local TouringBandCfg = {
	TableName = "c_touring_band_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'BandName',
            },
            {
                Name = 'BandDisplay',
            },
            {
                Name = 'StoryContent',
            },
            {
                Name = 'Condition',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TouringBandCfg, { __index = CfgBase })

TouringBandCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TouringBandCfg
