-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupPermissionCfg : CfgBase
local GroupPermissionCfg = {
	TableName = "c_group_permission_cfg",
    LruKeyType = nil,
	KeyName = "Type",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupPermissionCfg, { __index = CfgBase })

GroupPermissionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local AllCfgs

--- 获取所有权限
function GroupPermissionCfg:GetAllPermissionCfg()
	if not AllCfgs then
		AllCfgs = self:FindAllCfg()
	end
	return AllCfgs
end

--- 获取阶级Class
---@param Type number @权限类别
function GroupPermissionCfg:GetPermissionByType(Type)
	if Type == nil then return end
	local SearchConditions = string.format("Type=%d", Type)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg
end

--- 获取阶级Class
---@param Type number @权限类别
function GroupPermissionCfg:GetPermissionClassByType(Type)
	if Type == nil then return end
	local SearchConditions = string.format("Type=%d", Type)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.Class
end

return GroupPermissionCfg
