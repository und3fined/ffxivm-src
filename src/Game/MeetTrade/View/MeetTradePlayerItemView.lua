---
--- Author: usakizhang
--- DateTime: 2025-01-04 14:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MeetTradePlayerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Check UFCanvasPanel
---@field ConfirmEffect UFCanvasPanel
---@field ImgState UFImage
---@field PlayerHeadSlot PersonInfoPlayerItemView
---@field TextPlayerName UFTextBlock
---@field WaitEffect UFCanvasPanel
---@field AnimCheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MeetTradePlayerItemView = LuaClass(UIView, true)

function MeetTradePlayerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Check = nil
	--self.ConfirmEffect = nil
	--self.ImgState = nil
	--self.PlayerHeadSlot = nil
	--self.TextPlayerName = nil
	--self.WaitEffect = nil
	--self.AnimCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MeetTradePlayerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MeetTradePlayerItemView:OnInit()

end

function MeetTradePlayerItemView:OnDestroy()

end

function MeetTradePlayerItemView:OnShow()

end

function MeetTradePlayerItemView:OnHide()

end

function MeetTradePlayerItemView:OnRegisterUIEvent()

end

function MeetTradePlayerItemView:OnRegisterGameEvent()

end

function MeetTradePlayerItemView:OnRegisterBinder()

end

function MeetTradePlayerItemView:UpdateAnimationEffect(IsReadyForTrade)
	UIUtil.SetIsVisible(self.ImgState, not IsReadyForTrade)
	UIUtil.SetIsVisible(self.WaitEffect, not IsReadyForTrade)
	UIUtil.SetIsVisible(self.Check, IsReadyForTrade)
	UIUtil.SetIsVisible(self.ConfirmEffect, IsReadyForTrade)
	if IsReadyForTrade then
		self:PlayAnimation(self.AnimCheck)
	end
end
return MeetTradePlayerItemView