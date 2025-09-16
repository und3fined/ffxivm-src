-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupMemberCategoryCfg : CfgBase
local GroupMemberCategoryCfg = {
	TableName = "c_group_member_category_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupMemberCategoryCfg, { __index = CfgBase })

GroupMemberCategoryCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local AllCfgs
--- 获取所有阶级Icon
function GroupMemberCategoryCfg:GetAllCategoryCfg()
	if not AllCfgs then
		AllCfgs = self:FindAllCfg()
	end
	return AllCfgs
end

--- 获取阶级Icon
function GroupMemberCategoryCfg:GetCategoryIconByID(ID)
	if ID == nil then return end
	local SearchConditions = string.format("ID=%d", ID)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.Icon
end

return GroupMemberCategoryCfg
