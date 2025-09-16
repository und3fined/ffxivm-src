---
--- Author: anypkvcai
--- DateTime: 2021-05-10 16:20
--- Description:
---

local UILayer = require("UI/UILayer")

---@class UILayerConfig
local UILayerConfig = {
	LayerMutex = {
		[UILayer.Normal] = UILayer.Low | UILayer.AboveLow | UILayer.Lowest,
		[UILayer.High] = UILayer.Low | UILayer.Lowest,
		[UILayer.Exclusive] = (UILayer.All & ~(UILayer.Exclusive | UILayer.Loading | UILayer.Network | UILayer.BelowHigh)),
		--[UILayer.Network] = (UILayer.All & ~(UILayer.Network | UILayer.Loading)),

	}
}

return UILayerConfig