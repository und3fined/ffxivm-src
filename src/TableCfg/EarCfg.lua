-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EarCfg : CfgBase
local EarCfg = {
	TableName = "c_ear",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EarCfg, { __index = CfgBase })

EarCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--FindCfgByRaceIDTribeGender
---@param RaceID number
---@param Tribe number
---@param Gender number
function EarCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d", RaceID, Tribe, Gender)
	return self:FindAllCfg(SearchConditions)
end

return EarCfg
