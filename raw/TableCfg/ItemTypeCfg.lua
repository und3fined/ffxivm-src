-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ItemTypeCfg : CfgBase
local ItemTypeCfg = {
	TableName = "c_item_type_cfg",
    LruKeyType = nil,
	KeyName = "ItemType",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ItemTypeName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ItemTypeCfg, { __index = CfgBase })

ItemTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function ItemTypeCfg:GetTypeName(ItemType)
	local Cfg = self:FindCfgByKey(ItemType)
	if nil == Cfg then return "" end

	return Cfg.ItemTypeName
end

return ItemTypeCfg


