-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FaceDecalCfg : CfgBase
local FaceDecalCfg = {
	TableName = "c_face_decal",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FaceDecalCfg, { __index = CfgBase })

FaceDecalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--FindCfgByRaceIDTribeGender
---@param RaceID number
---@param Tribe number
---@param Gender number
function FaceDecalCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d", RaceID, Tribe, Gender)
	return self:FindAllCfg(SearchConditions)
end

return FaceDecalCfg
