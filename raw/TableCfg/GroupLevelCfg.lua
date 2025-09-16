-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupLevelCfg : CfgBase
local GroupLevelCfg = {
	TableName = "c_group_level_cfg",
    LruKeyType = nil,
	KeyName = "Level",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupLevelCfg, { __index = CfgBase })

GroupLevelCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--- 通过部队等级获取部队成员上限
---@param Level number @部队等级
function GroupLevelCfg:GetMemberLimitByLevel(Level)
	if Level == nil then return end
	local SearchConditions = string.format("Level=%d", Level)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.MaxMemberCount
end

--- 通过部队等级获取部队本级所需经验
---@param Level number @部队等级
function GroupLevelCfg:GetGroundScoreByLevel(Level)
	if Level == nil then return end
	local SearchConditions = string.format("Level=%d", Level)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.Score
end

--- 通过部队等级获取部队当前每日最大经验
---@param Level number @部队等级
function GroupLevelCfg:GetGroundMaxScoreByLevel(Level)
	if Level == nil then return end
	local SearchConditions = string.format("Level=%d", Level)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.MaxScore
end

return GroupLevelCfg
