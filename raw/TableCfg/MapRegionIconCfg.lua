-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MapRegionIconCfg : CfgBase
local MapRegionIconCfg = {
	TableName = "c_map_region_icon_cfg",
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

setmetatable(MapRegionIconCfg, { __index = CfgBase })

MapRegionIconCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY
-- 过滤掉没配图片的Region
function MapRegionIconCfg:GetAllValidRegion()
	local function SortPredicate(Left, Right)
		return Left.ID < Right.ID
	end
	local AllCfg = MapRegionIconCfg:FindAllCfg("Icon is not null and trim(Icon) != ''")
	table.sort(AllCfg, SortPredicate)
	return AllCfg
end

return MapRegionIconCfg
