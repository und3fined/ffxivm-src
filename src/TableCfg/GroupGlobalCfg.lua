-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupGlobalCfg : CfgBase
local GroupGlobalCfg = {
	TableName = "c_group_global_cfg",
    LruKeyType = nil,
	KeyName = "Type",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'StrValue',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupGlobalCfg, { __index = CfgBase })

GroupGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--- 通过类别获取Value
function GroupGlobalCfg:GetValueByType(Type, Index)
	if Type == nil then return end
	local SearchConditions = string.format("Type=%d", Type)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.Value[Index or 1]
end

--- 通过类别获取StrValue
function GroupGlobalCfg:GetStrValueByType(Type, Index)
	if Type == nil then return end
	local SearchConditions = string.format("Type=%d", Type)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	if table.length(Cfg.StrValue or {}) < 1 then return end
	return Cfg.StrValue[Index or 1]
end

return GroupGlobalCfg
