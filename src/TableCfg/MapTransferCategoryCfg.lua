-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MapTransferCategoryCfg : CfgBase
local MapTransferCategoryCfg = {
	TableName = "c_MapTransferCategory_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MapTransferCategoryCfg, { __index = CfgBase })

MapTransferCategoryCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function MapTransferCategoryCfg:GetAllCategoryCfg(SearchConditions)
	local function SortPredicate(Left, Right)
		if Left.SortPriority ~= Right.SortPriority then
			return Left.SortPriority < Right.SortPriority
		end
		if Left.ID ~= Right.ID then
			return Left.ID < Right.ID
		end
		return false
	end

	local AllCfg = MapTransferCategoryCfg:FindAllCfg(SearchConditions)
	table.sort(AllCfg, SortPredicate)
	return AllCfg
end

return MapTransferCategoryCfg
