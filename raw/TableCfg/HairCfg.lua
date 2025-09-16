-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HairCfg : CfgBase
local HairCfg = {
	TableName = "c_hair",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'HaircutDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(HairCfg, { __index = CfgBase })

HairCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function HairCfg:GetFirstHairByTribeAndGender(Tribe, Gender)
	local SearchConditions = string.format("Tribe = %d AND Gender = %d", Tribe,Gender)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end

	return Cfg.ID
end

--FindCfgByRaceIDTribeGenderVesion
---@param RaceID number
---@param Tribe number
---@param Gender number
function HairCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d And VersionName is not null AND trim(VersionName) != ''", RaceID, Tribe, Gender)
	return self:FindAllCfg(SearchConditions)
end

function HairCfg:FindCfgByID(ID)
	return self:FindCfgByKey(ID)
end

return HairCfg
