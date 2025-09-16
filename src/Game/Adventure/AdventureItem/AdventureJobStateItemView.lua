---
--- Author: Administrator
--- DateTime: 2025-03-10 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class AdventureJobStateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconJob UFImage
---@field IconRecommendTask UFImage
---@field ImgBG UFImage
---@field PanelOngoing UFCanvasPanel
---@field SizeBoxJob USizeBox
---@field SizeBoxRecommend USizeBox
---@field TextOngoing UFTextBlock
---@field CustomFont SlateFontInfo
---@field CustomTextColor SlateColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureJobStateItemView = LuaClass(UIView, true)

function AdventureJobStateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconJob = nil
	--self.IconRecommendTask = nil
	--self.ImgBG = nil
	--self.PanelOngoing = nil
	--self.SizeBoxJob = nil
	--self.SizeBoxRecommend = nil
	--self.TextOngoing = nil
	--self.CustomFont = nil
	--self.CustomTextColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureJobStateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureJobStateItemView:OnInit()

end

function AdventureJobStateItemView:OnDestroy()

end

function AdventureJobStateItemView:OnShow()

end

function AdventureJobStateItemView:OnHide()

end

function AdventureJobStateItemView:OnRegisterUIEvent()

end

function AdventureJobStateItemView:OnRegisterGameEvent()

end

function AdventureJobStateItemView:OnRegisterBinder()

end

function AdventureJobStateItemView:SetProfTagShow()
	UIUtil.SetIsVisible(self.SizeBoxJob, true)
	UIUtil.SetIsVisible(self.SizeBoxRecommend, false)
end

function AdventureJobStateItemView:SetRecommendTagShow()
	UIUtil.SetIsVisible(self.SizeBoxJob, false)
	UIUtil.SetIsVisible(self.SizeBoxRecommend, true)
end

return AdventureJobStateItemView