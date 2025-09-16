-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FaceCfg : CfgBase
local FaceCfg = {
	TableName = "c_face",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FaceCfg, { __index = CfgBase })

FaceCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---FindCfgByRaceIDTribeGender
---@param RaceID number
---@param Tribe number
---@param Gender number
function FaceCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d", RaceID, Tribe, Gender)
	return self:FindAllCfg(SearchConditions)
end

return FaceCfg
