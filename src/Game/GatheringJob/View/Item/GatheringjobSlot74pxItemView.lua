---
--- Author: chriswang
--- DateTime: 2024-07-02 15:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GatheringjobSlot74pxItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot CommBackpackSlotView
---@field ImgCollection UFImage
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringjobSlot74pxItemView = LuaClass(UIView, true)

function GatheringjobSlot74pxItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot = nil
	--self.ImgCollection = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringjobSlot74pxItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringjobSlot74pxItemView:OnInit()

end

function GatheringjobSlot74pxItemView:OnDestroy()

end

function GatheringjobSlot74pxItemView:OnShow()

end

function GatheringjobSlot74pxItemView:OnHide()

end

function GatheringjobSlot74pxItemView:OnRegisterUIEvent()

end

function GatheringjobSlot74pxItemView:OnRegisterGameEvent()

end

function GatheringjobSlot74pxItemView:OnRegisterBinder()

end

return GatheringjobSlot74pxItemView