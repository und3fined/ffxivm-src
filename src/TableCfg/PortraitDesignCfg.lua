-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PortraitDesignCfg : CfgBase
local PortraitDesignCfg = {
	TableName = "c_portrait_design_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'UnlockDesc',
            },
            {
                Name = 'UnknownDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PortraitDesignCfg, { __index = CfgBase })

PortraitDesignCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---根据类型获取设计信息列表
---@param Type ProtoCommon.DesignerType @设计类型
function PortraitDesignCfg:GetDesignInfosByType(Type)
	local SearchConditions = string.format("TypeID = %d AND Hide != TRUE", Type)
	return self:FindAllCfg(SearchConditions)
end

---指定ID是否默认解锁
---@param ID number @设计ID
function PortraitDesignCfg:IsDefaultUnlock(ID)
	local Cfg = self:FindCfgByKey(ID)
	if Cfg then
		return Cfg.UnlockType == 1
	end
end

---获取Icon
---@param ID number @设计ID
function PortraitDesignCfg:GetIcon(ID)
	local Cfg = self:FindCfgByKey(ID)
	if Cfg then
		return Cfg.Icon
	end
end

return PortraitDesignCfg
