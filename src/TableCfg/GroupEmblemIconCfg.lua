-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupEmblemIconCfg : CfgBase
local GroupEmblemIconCfg = {
	TableName = "c_group_emblem_icon_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupEmblemIconCfg, { __index = CfgBase })

GroupEmblemIconCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY



local AllCfgs
--- 获取所有队徽盾纹配置
function GroupEmblemIconCfg:GetAllEmblemIconCfg()
	if not AllCfgs then
		AllCfgs = self:FindAllCfg()
	end
	return AllCfgs
end

--- 获取队徽盾纹
function GroupEmblemIconCfg:GetEmblemIconByID(ID)
	if ID == nil then return end
	local SearchConditions = string.format("ID=%d", ID)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.Icon
end

return GroupEmblemIconCfg
