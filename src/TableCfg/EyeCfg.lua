-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EyeCfg : CfgBase
local EyeCfg = {
	TableName = "c_eye",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EyeCfg, { __index = CfgBase })

EyeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---FindCfgByRaceIDTribeGender
---@param RaceID number
---@param Tribe number
---@param Gender number
function EyeCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d", RaceID, Tribe, Gender)
	return self:FindAllCfg(SearchConditions)
end

return EyeCfg
