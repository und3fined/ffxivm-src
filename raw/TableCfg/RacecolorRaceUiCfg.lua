-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RacecolorRaceUiCfg : CfgBase
local RacecolorRaceUiCfg = {
	TableName = "c_racecolor_race_ui_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RacecolorRaceUiCfg, { __index = CfgBase })

RacecolorRaceUiCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY
function RacecolorRaceUiCfg:FindAllColorCfg()
	local SearchConditions = "ID < 256"
	return self:FindAllCfg(SearchConditions)
end

function RacecolorRaceUiCfg:FindRangeColorCfg(Low, High)
	local SearchConditions = string.format("ID >= %d AND ID <= %d", Low, High)
	return self:FindAllCfg(SearchConditions)
end

return RacecolorRaceUiCfg
