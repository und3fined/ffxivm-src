-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupStoreCfg : CfgBase
local GroupStoreCfg = {
	TableName = "c_group_store_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'GroupDefaultName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupStoreCfg, { __index = CfgBase })

GroupStoreCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---FindCfgByUsePermissionId
---@param UsePermissionId number
---@return table<string,any> | nil
function GroupStoreCfg:FindCfgByUsePermissionId(UsePermissionId)
	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.UsePermissionId == UsePermissionId then
			return v
		end
	end
	local SearchConditions = string.format("UsePermissionId=%d", UsePermissionId)
	local Cfg = self:FindCfg(SearchConditions)
	return Cfg
end

return GroupStoreCfg
