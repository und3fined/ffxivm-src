-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FaceLookatCfg : CfgBase
local FaceLookatCfg = {
	TableName = "c_face_lookat_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FaceLookatCfg, { __index = CfgBase })

FaceLookatCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---FindCfgByRaceIDTribeGender
---@param RaceID number
---@param Tribe number
---@param Gender number
function FaceLookatCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d", RaceID, Tribe, Gender)
	return self:FindAllCfg(SearchConditions)
end

return FaceLookatCfg
