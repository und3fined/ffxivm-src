---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:大赛大字文本提示（报名成功，大赛结束等）
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TourneyVM = _G.MagicCardTourneyVM

---@class CardsTourneyMissionTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextBigTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyMissionTipsView = LuaClass(UIView, true)

function CardsTourneyMissionTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextBigTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyMissionTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyMissionTipsView:OnInit()
	self.Binders = {
		--{"SignUpTipText", UIBinderSetText.New(self, self.TextBigTips) },
	}
end

function CardsTourneyMissionTipsView:OnDestroy()

end

function CardsTourneyMissionTipsView:OnShow()
	if self.Params == nil then
		return
	end
	local TipText = self.Params.TipText
	local CallBack = self.Params.CallBack
	if TipText then
		self.TextBigTips:SetText(TipText)
	end

	local function HideFunc()
		if CallBack ~= nil then
			CallBack()
		end
		self:Hide()
	end
	self:RegisterTimer(HideFunc, 3)
end

function CardsTourneyMissionTipsView:OnHide()

end

function CardsTourneyMissionTipsView:OnRegisterUIEvent()

end

function CardsTourneyMissionTipsView:OnRegisterGameEvent()

end

function CardsTourneyMissionTipsView:OnRegisterBinder()
	-- if TourneyVM.SignUpVM then
	-- 	self:RegisterBinders(TourneyVM.SignUpVM, self.Binders)
	-- end
end

return CardsTourneyMissionTipsView