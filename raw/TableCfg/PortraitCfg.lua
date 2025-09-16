-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PortraitCfg : CfgBase
local PortraitCfg = {
	TableName = "c_portrait_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PortraitCfg, { __index = CfgBase })

PortraitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取所有肖像信息列表
---@return table
function PortraitCfg:GetPortraitList()
	local Ret = self:FindAllCfg()
	return Ret or {}
end

---获取肖像图标
---@param ID number @肖像ID 
---@return string 
function PortraitCfg:GetPortraitIcon( ID )
	local Ret = self:FindCfgByKey(ID)
	if Ret then
		return Ret.Icon
	end
end

return PortraitCfg
