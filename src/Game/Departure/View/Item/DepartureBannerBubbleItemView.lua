---
--- Author: Administrator
--- DateTime: 2025-03-13 14:21
--- Description:动效中的气泡
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class DepartureBannerBubbleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBubble UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureBannerBubbleItemView = LuaClass(UIView, true)

function DepartureBannerBubbleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBubble = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureBannerBubbleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureBannerBubbleItemView:OnInit()

end

function DepartureBannerBubbleItemView:OnDestroy()

end

function DepartureBannerBubbleItemView:OnShow()

end

function DepartureBannerBubbleItemView:OnHide()

end

function DepartureBannerBubbleItemView:OnRegisterUIEvent()

end

function DepartureBannerBubbleItemView:OnRegisterGameEvent()

end

function DepartureBannerBubbleItemView:OnRegisterBinder()

end

function DepartureBannerBubbleItemView:SetIcon(IconPath)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgBubble, IconPath)
end

return DepartureBannerBubbleItemView