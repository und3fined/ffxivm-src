---
--- Author: Administrator
--- DateTime: 2024-05-30 10:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GoldSaucerGameCommCriticalItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_0 UFCanvasPanel
---@field TextQuantity UFTextBlock
---@field AnimCriticalIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerGameCommCriticalItemView = LuaClass(UIView, true)

function GoldSaucerGameCommCriticalItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_0 = nil
	--self.TextQuantity = nil
	--self.AnimCriticalIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerGameCommCriticalItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerGameCommCriticalItemView:OnInit()

end

function GoldSaucerGameCommCriticalItemView:OnDestroy()

end

function GoldSaucerGameCommCriticalItemView:OnShow()

end

function GoldSaucerGameCommCriticalItemView:OnHide()

end

function GoldSaucerGameCommCriticalItemView:OnRegisterUIEvent()

end

function GoldSaucerGameCommCriticalItemView:OnRegisterGameEvent()

end

function GoldSaucerGameCommCriticalItemView:OnRegisterBinder()

end

function GoldSaucerGameCommCriticalItemView:ShowCriticalTips(Content)
	self.TextQuantity:SetText(Content)
	self:PlayAnimation(self.AnimCriticalIn)
end

return GoldSaucerGameCommCriticalItemView