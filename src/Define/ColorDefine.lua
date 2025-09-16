---
--- Author: anypkvcai
--- DateTime: 2021-06-02 14:06
--- Description:
---

local ColorUtil = require("Utils/ColorUtil")

local HexColor = {
	Gray = "f3f3f399", -- 灰色 按钮文字
}

local LinearColor = {
	Gray = ColorUtil.GetLinearColor(HexColor.Gray), -- 灰色 按钮文字
}

local ItemGradeColor = {
		-- ITEM_COLOR_WHITE = 1,	-- 白
	-- ITEM_COLOR_GREEN = 2,	-- 绿
	-- ITEM_COLOR_BLUE = 3,	-- 蓝
	-- ITEM_COLOR_PURPLE = 4,	-- 紫
	-- ITEM_COLOR_ORANGE = 5,	-- 橙
	-- ITEM_COLOR_RED = 6,	-- 红,
	"#d5d5d5",
	"#89bd88",
	"#6fb1e9",
	"#ac88dd",
	"#FFA500",
	"#EE0000"
}

-- 列表选中字色
local ListSelectedColor = {
	Selected = "d5d5d5",
	Normal = "828282"
}

---@class ColorDefine
local ColorDefine = {
	HexColor = HexColor,
	ListSelectedColor = ListSelectedColor,
	LinearColor = LinearColor,
	ItemGradeColor = ItemGradeColor
}

return ColorDefine