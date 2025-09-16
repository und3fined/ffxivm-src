-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RaceCfg : CfgBase
local RaceCfg = {
	TableName = "c_race_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'RaceName',
            },
            {
                Name = 'TribeName',
            },
            {
                Name = 'RaceDesc',
            },
            {
                Name = 'TribeDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RaceCfg, { __index = CfgBase })

RaceCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---FindCfgByRaceID
---@param RaceID number
---@return table<string,any> | nil
function RaceCfg:FindCfgByRaceID(RaceID)
	if nil == RaceID then
		return
	end

	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.RaceID == RaceID then
			return v
		end
	end

	local SearchConditions = string.format("RaceID = %d", RaceID)
	return self:FindCfg(SearchConditions)
end

---FindCfgByRaceIDGenderAndTribe
---@param RaceID number @种族ID
---@param Gender number @性别
---@param Tribe number @部落
---@return table<string,any> | nil
function RaceCfg:FindCfgByRaceIDGenderAndTribe(RaceID, Gender, Tribe)
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.RaceID == RaceID and v.Gender == Gender and v.Tribe == Tribe then
			return v
		end
	end

	local SearchConditions = string.format("RaceID = %d AND Gender = %d", RaceID, Gender)
	return self:FindCfg(SearchConditions)
end

---FindCfgByRaceIDTribeGender
---@param RaceID number
---@param Tribe number
---@param Gender number
function RaceCfg:FindCfgByRaceIDTribeGender(RaceID, Tribe, Gender)
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.RaceID == RaceID and v.Tribe == Tribe and v.Gender == Gender then
			return v
		end
	end

	local SearchConditions = string.format("RaceID = %d AND Tribe = %d AND Gender = %d", RaceID, Tribe, Gender)
	return self:FindCfg(SearchConditions)
end

function RaceCfg:FindCfgByTribeID(TribeID)
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.Tribe == TribeID then
			return v
		end
	end
	local SearchConditions = string.format("Tribe = %d", TribeID)
	return self:FindCfg(SearchConditions)
end

---GetRaceTribeName
---@param TribeID number
---@return string
function RaceCfg:GetRaceTribeName(TribeID)
	local Cfg = self:FindCfgByTribeID(TribeID)
	if nil == Cfg then return end
	return table.concat({Cfg.RaceName, Cfg.TribeName}, "-")
end

---GetRaceName
---@param RaceID number
---@return string
function RaceCfg:GetRaceName(RaceID)
	local Cfg = self:FindCfgByRaceID(RaceID)
	if nil == Cfg then return end

	return Cfg.RaceName
end

function RaceCfg:GetFirstRaceID(Gender)
	local SearchConditions = string.format("Gender = %d", Gender)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end

	return Cfg.RaceID
end

function RaceCfg:GetFirstTribeID(Gender)
	local SearchConditions = string.format("Gender = %d", Gender)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end

	return Cfg.Tribe
end

function RaceCfg:GetRaceHeadIDByRaceIDGenderAndTribe(RaceID, Gender, Tribe)
	local Cfg = self:FindCfgByRaceIDGenderAndTribe(RaceID, Gender, Tribe)
	if nil == Cfg then return end

	return Cfg.RaceHeadID
end

function RaceCfg:GetRacePortraitIDByRaceIDGenderAndTribe(RaceID, Gender, Tribe)
	local Cfg = self:FindCfgByRaceIDGenderAndTribe(RaceID, Gender, Tribe)
	if nil == Cfg then return end

	return Cfg.RacePortraitID
end

return RaceCfg
