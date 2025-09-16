---
--- Author: chriswang
--- DateTime: 2022-01-23 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

---@class GatherChainTipsView : InfoTipsBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FText_Content UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatherChainTipsView = LuaClass(InfoTipsBaseView, true)

function GatherChainTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FText_Content = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatherChainTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatherChainTipsView:OnInit()

end

function GatherChainTipsView:OnDestroy()

end

function GatherChainTipsView:OnShow()
	self.Super:OnShow()
	self.Text_Content:SetText(self.Params.Content)
end

function GatherChainTipsView:OnHide()

end

function GatherChainTipsView:OnRegisterUIEvent()

end

function GatherChainTipsView:OnRegisterGameEvent()

end

function GatherChainTipsView:OnRegisterBinder()

end

return GatherChainTipsView