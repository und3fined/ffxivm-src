-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class AttrDefCfg : CfgBase
local AttrDefCfg = {
	TableName = "c_attr_def_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'AttrName',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(AttrDefCfg, { __index = CfgBase })

AttrDefCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function AttrDefCfg:GetAttrNameByID(ID)
	local Cfg = self:FindCfgByID(ID)
	if nil == Cfg then return end

	return Cfg.AttrName
end

function AttrDefCfg:GetAttrDescByID(ID)
	local Cfg = self:FindCfgByID(ID)
	if nil == Cfg then return end

	return Cfg.Desc
end

function AttrDefCfg:GetAttrNumShowTypeByID(ID)
	local Cfg = self:FindCfgByID(ID)
	if nil == Cfg then return end

	return Cfg.NumShowType
end

function AttrDefCfg:GetAttrTipsShowTypeByID(ID)
	local Cfg = self:FindCfgByID(ID)
	if nil == Cfg then return end

	return Cfg.TIPSShowType
end

---FindCfgByID
---@param ID common.attr_type
---@return table<string,any> | nil
function AttrDefCfg:FindCfgByID(ID)
	if nil == ID then
		return nil
	end

	local CachedData = self:GetCachedData()
	for _, v in pairs(CachedData) do
		if v.Attr == ID then
			return v
		end
	end

	local SearchConditions = "Attr = " .. ID
	return self:FindCfg(SearchConditions)
end

return AttrDefCfg
