---
--- Author: ccppeng
--- DateTime: 2024-11-01 15:58
--- Description:
---
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecoTypeConfig = FashionDecoDefine.FashionDecoTypeConfig
local LSTR = _G.LSTR
---@class FashionDecoUtil
local FashionDecoUtil = {}
function FashionDecoUtil.FindFashionDecoTypeConfigByType(InType)
	for _, v in ipairs(FashionDecoTypeConfig) do
		if v.Type == InType then
			return v
		end
	end
end


return FashionDecoUtil