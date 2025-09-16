---
--- Author: chriswang
--- DateTime: 2022-09-23 14:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimerMgr = _G.TimerMgr
---@class MiniCactpotRewardTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_CDBar URadialImage
---@field Text_Value UFTextBlock
---@field AnimBigPrize UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MiniCactpotRewardTipsView = LuaClass(UIView, true)

function MiniCactpotRewardTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_CDBar = nil
	--self.Text_Value = nil
	--self.AnimBigPrize = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MiniCactpotRewardTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MiniCactpotRewardTipsView:OnInit()

end

function MiniCactpotRewardTipsView:OnDestroy()

end

function MiniCactpotRewardTipsView:OnShow()
	-- self.Text_Value:SetText(self.Params)	-- self.Params	奖励的数量

	
	self.DelayPlayAnimTimerID = self:RegisterTimer(self.DelayPlayAnim, 0.028, 0, 1, self.Params)


	local function Hide()
		self:Hide()
	end
	self:RegisterTimer(Hide, 2, 0, 1, nil)
	-- self.CDBarTimerID = _G.TimerMgr:AddTimer(self, self.UpdateCDBar, 0, 0.02, 0, nil)
	-- self.CDBarStartTime = _G.TimeUtil.GetLocalTimeMS()
end

function MiniCactpotRewardTipsView:DelayPlayAnim(AwardCoins)
	if AwardCoins >= 10000 then
		self:PlayAnimation(self.AnimBigPrize)
	else
		self:PlayAnimation(self.AnimSmallPrize)
	end
end

-- function MiniCactpotRewardTipsView:UpdateCDBar()
-- 	local LeftTime = 4000 - (_G.TimeUtil.GetLocalTimeMS() - self.CDBarStartTime)
-- 	if LeftTime < 0 then
-- 		LeftTime = 0

-- 		if self.CDBarTimerID then
-- 			_G.TimerMgr:CancelTimer(self.CDBarTimerID)
-- 			self.CDBarTimerID = nil
-- 		end

-- 		self:OnClickButtonMask()
-- 	end

-- 	self.FImg_CDBar:SetPercent(LeftTime / 4000)
-- end

-- function MiniCactpotRewardTipsView:OnHide()
-- 	if self.DelayPlayAnimTimerID then
-- 		_G.TimerMgr:CancelTimer(self.DelayPlayAnimTimerID)
-- 		self.DelayPlayAnimTimerID = nil
-- 	end

-- 	if self.CDBarTimerID then
-- 		_G.TimerMgr:CancelTimer(self.CDBarTimerID)
-- 		self.CDBarTimerID = nil
-- 	end
-- end

function MiniCactpotRewardTipsView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.ButtonMask, self.OnClickButtonMask)
end

function MiniCactpotRewardTipsView:OnRegisterGameEvent()

end

function MiniCactpotRewardTipsView:OnRegisterBinder()

end

function MiniCactpotRewardTipsView:OnClickButtonMask()
	self:Hide()
end

return MiniCactpotRewardTipsView