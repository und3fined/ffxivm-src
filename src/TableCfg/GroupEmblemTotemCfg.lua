-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupEmblemTotemCfg : CfgBase
local GroupEmblemTotemCfg = {
	TableName = "c_group_emblem_totem_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupEmblemTotemCfg, { __index = CfgBase })

GroupEmblemTotemCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY
local AllCfgs
--- 获取所有寓意物
function GroupEmblemTotemCfg:GetAllEmblemTotemCfg()
	if not AllCfgs then
		AllCfgs = self:FindAllCfg()
	end
	return AllCfgs
end

--- 获取队徽寓意物
function GroupEmblemTotemCfg:GetEmblemTotemIconByID(ID)
	if ID == nil then return end
	local SearchConditions = string.format("ID=%d", ID)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.Icon
end

return GroupEmblemTotemCfg
