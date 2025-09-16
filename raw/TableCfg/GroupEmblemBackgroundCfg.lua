-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupEmblemBackgroundCfg : CfgBase
local GroupEmblemBackgroundCfg = {
	TableName = "c_group_emblem_background_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupEmblemBackgroundCfg, { __index = CfgBase })

GroupEmblemBackgroundCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local AllCfgs
--- 获取所有队徽背景配置
function GroupEmblemBackgroundCfg:GetAllEmblemBgCfg()
	if not AllCfgs then
		AllCfgs = self:FindAllCfg()
	end
	return AllCfgs
end

--- 获取队徽背景
function GroupEmblemBackgroundCfg:GetEmblemBgColorByID(ID)
	if ID == nil then return end
	local SearchConditions = string.format("ID=%d", ID)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.ColorHex
end

return GroupEmblemBackgroundCfg
