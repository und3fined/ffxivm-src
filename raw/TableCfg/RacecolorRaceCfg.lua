-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RacecolorRaceCfg : CfgBase
local RacecolorRaceCfg = {
	TableName = "c_racecolor_race_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RacecolorRaceCfg, { __index = CfgBase })

RacecolorRaceCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function RacecolorRaceCfg:FindAllColorCfg()
	local SearchConditions = "ID < 256"
	return self:FindAllCfg(SearchConditions)
end

function RacecolorRaceCfg:FindRangeColorCfg(Low, High)
	local SearchConditions = string.format("ID >= %d AND ID <= %d", Low, High)
	return self:FindAllCfg(SearchConditions)
end
return RacecolorRaceCfg
