-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CharaVoiceTypeChsCfg : CfgBase
local CharaVoiceTypeChsCfg = {
	TableName = "c_chara_voice_type_chs_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CharaVoiceTypeChsCfg, { __index = CfgBase })

CharaVoiceTypeChsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY
---FindCfgByRaceIDTribeGender
---@param RaceID number
---@param Tribe number
---@param Gender number
function CharaVoiceTypeChsCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d", RaceID, Tribe, Gender)
	return self:FindAllCfg(SearchConditions)
end

return CharaVoiceTypeChsCfg
