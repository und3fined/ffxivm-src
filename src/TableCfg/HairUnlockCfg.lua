-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HairUnlockCfg : CfgBase
local HairUnlockCfg = {
	TableName = "c_hair_unlock",
    LruKeyType = nil,
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

setmetatable(HairUnlockCfg, { __index = CfgBase })

HairUnlockCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function HairUnlockCfg:FindCfgByID(ID)
	if nil == ID then
		return nil
	end
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.HairID == ID then
			return v
		end
	end

	local SearchConditions = "HairID = " .. ID
	return self:FindCfg(SearchConditions)
end

function HairUnlockCfg:FindCfgByItemID(ID)
	if nil == ID then
		return nil
	end

	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.UnlockItemID == ID then
			return v
		end
	end

	local SearchConditions = "UnlockItemID = " .. ID
	return self:FindCfg(SearchConditions)
end
return HairUnlockCfg
