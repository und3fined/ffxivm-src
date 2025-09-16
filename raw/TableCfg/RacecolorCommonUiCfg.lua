-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RacecolorCommonUiCfg : CfgBase
local RacecolorCommonUiCfg = {
	TableName = "c_racecolor_common_ui_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RacecolorCommonUiCfg, { __index = CfgBase })

RacecolorCommonUiCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function RacecolorCommonUiCfg:FindAllColorCfg()
	local SearchConditions = "ID < 256"
	return self:FindAllCfg(SearchConditions)
end

return RacecolorCommonUiCfg
