-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CustomizeFaceCfg : CfgBase
local CustomizeFaceCfg = {
	TableName = "c_customize_face",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MainMenu',
            },
            {
                Name = 'SubMenu',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CustomizeFaceCfg, { __index = CfgBase })

CustomizeFaceCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---FindCfgByRaceIDTribeGender
---@param RaceID number
---@param Tribe number
---@param Gender number
function CustomizeFaceCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d", RaceID, Tribe, Gender)
	return self:FindAllCfg(SearchConditions)
end

return CustomizeFaceCfg
