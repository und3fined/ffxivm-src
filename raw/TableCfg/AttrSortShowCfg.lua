-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class AttrSortShowCfg : CfgBase
local AttrSortShowCfg = {
	TableName = "c_attr_sort_show_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(AttrSortShowCfg, { __index = CfgBase })

AttrSortShowCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function AttrSortShowCfg:GetAttrSortList(InShowType, InShowSheet, InShowTag)
	local Ret = {}

	local SearchConditions
	if InShowSheet == nil then
		SearchConditions = string.format("ShowType=%d and ShowTag=%d", InShowType, InShowTag)
	else
		SearchConditions = string.format("ShowType=%d and ShowSheet=%d and ShowTag=%d", InShowType, InShowSheet, InShowTag)
	end

	local AllCfg = self:FindAllCfg(SearchConditions)
	if nil == AllCfg or #AllCfg == 0 then return Ret end

	---按ShowNum排序
	local function SortComparison(Left, Right)
		local LeftShowNum = Left.ShowNum
		local RightShowNum = Right.ShowNum

		if LeftShowNum ~= RightShowNum then
			return LeftShowNum < RightShowNum
		end

		return false
	end
	table.sort(AllCfg, SortComparison)
	return AllCfg
end

return AttrSortShowCfg
