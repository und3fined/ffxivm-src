-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupUplevelpermissionCfg : CfgBase
local GroupUplevelpermissionCfg = {
	TableName = "c_group_uplevelpermission_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Permission',
            },
            {
                Name = 'Describe',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupUplevelpermissionCfg, { __index = CfgBase })

GroupUplevelpermissionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY
local AllCfgs

--- 获取所有权限信息
function GroupUplevelpermissionCfg:GetAllPermissionCfg()
	if not AllCfgs then
		AllCfgs = self:FindAllCfg()
	end
	return AllCfgs
end

--- 获取对应类型权限
---@param Type number @权限类别
function GroupUplevelpermissionCfg:GetPermissionByType(Type)
	if Type == nil then return end
	local SearchConditions = string.format("Type=%d", Type)
	local Cfg = self:FindAllCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg
end

-- --- 获取对应等级Class
-- ---@param Type number @权限类别
-- function GroupUplevelpermissionCfg:GetPermissionClassByType(Type)
-- 	if Type == nil then return end
-- 	local SearchConditions = string.format("Type=%d", Type)
-- 	local Cfg = self:FindCfg(SearchConditions)
-- 	if nil == Cfg then return end
-- 	return Cfg.Class
-- end

return GroupUplevelpermissionCfg
