-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RaceFaceCfg : CfgBase
local RaceFaceCfg = {
	TableName = "c_race_face",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RaceFaceCfg, { __index = CfgBase })

RaceFaceCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---FindCfgByTribeIDAndGender
---@param TribeID number
---@param Gender number
---@return table<string,any> | nil
function RaceFaceCfg:FindCfgByTribeIDAndGender(TribeID, Gender)
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.Tribe == TribeID and v.Gender == Gender then
			return v
		end
	end

	local SearchConditions = string.format("Tribe = %d AND Gender = %d", TribeID, Gender)
	return self:FindCfg(SearchConditions)
end

return RaceFaceCfg
