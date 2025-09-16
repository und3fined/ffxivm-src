-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MapMainCityCfg : CfgBase
local MapMainCityCfg = {
	TableName = "c_MapMainCity_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ID = 1,
        MainCityMapID = 12001,
        _MapIDList = '[12001,12002,2006,2009]',
        _UIMapIDList = '[13,14,73]',
    },
	LuaData = {
        {
        },
        {
            ID = 2,
            MainCityMapID = 11001,
            _MapIDList = '[11001,11002,11009,2005]',
            _UIMapIDList = '[2,3]',
        },
        {
            ID = 3,
            MainCityMapID = 13001,
            _MapIDList = '[13001,13002,13009,13010]',
            _UIMapIDList = '[11,12]',
        },
	},
}

setmetatable(MapMainCityCfg, { __index = CfgBase })

MapMainCityCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MapMainCityCfg
