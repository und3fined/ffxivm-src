-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FishCfg : CfgBase
local FishCfg = {
	TableName = "c_fish_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Description',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FishCfg, { __index = CfgBase })

FishCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function FishCfg:FindAllCfgByItemID(ItemID)
    local Specifier = "ItemID"
    return self:FindAllCfg(string.format("%s = %d", Specifier, ItemID))
end

function FishCfg:FindAllFishIDByItemID(ItemID, ColumnName)
    local FishCfgs = self:FindAllCfgByItemID(ItemID)

    if (FishCfgs == nil) then
        return nil
    end

    local Result = {}
    for _, Cfg in pairs(FishCfgs) do
        table.insert(Result, Cfg[ColumnName])
    end

    return Result
end

function FishCfg:FindAllIDsByItemID(ItemID)
    local IDSpecifier = "ID"
    return self:FindAllFishIDByItemID(ItemID, IDSpecifier)
end

return FishCfg
