---
--- Author: Carl
--- DateTime: 2024-08-09 17:30
--- Description:大赛大字文本提示（报名成功，大赛结束等）
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")

---@class CardsTourneyMissionTipsNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTips UFCanvasPanel
---@field PanelTips02 UFCanvasPanel
---@field TextBigTips UFTextBlock
---@field TextBigTips02 UFTextBlock
---@field TextTips02 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyMissionTipsNewView = LuaClass(UIView, true)

function CardsTourneyMissionTipsNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelTips = nil
	--self.PanelTips02 = nil
	--self.TextBigTips = nil
	--self.TextBigTips02 = nil
	--self.TextTips02 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyMissionTipsNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyMissionTipsNewView:OnInit()
	self.TipWidgetsToShow = {
		[MagicCardTourneyDefine.TipsType.SignUpSuccess] = self.PanelTips02,
		[MagicCardTourneyDefine.TipsType.TourneyFinished] = self.PanelTips,
	}

	self.TipTextWidgets = {
		[MagicCardTourneyDefine.TipsType.SignUpSuccess] = self.TextBigTips02,
		[MagicCardTourneyDefine.TipsType.TourneyFinished] = self.TextBigTips,
	}
	UIUtil.SetIsVisible(self.PanelTips, false)
	UIUtil.SetIsVisible(self.PanelTips02, false)
end

function CardsTourneyMissionTipsNewView:OnDestroy()

end

function CardsTourneyMissionTipsNewView:OnShow()
	if self.Params == nil then
		return
	end

	local TipType = self.Params.TipType
	local InTipText = self.Params.TipText
	if TipType then
		local ToShowWidget = self.TipWidgetsToShow[TipType]
		UIUtil.SetIsVisible(ToShowWidget, true)
		local TextWidget = self.TipTextWidgets[TipType]
		local TipText = InTipText ~= nil and InTipText or MagicCardTourneyDefine.TipsContent[TipType]
		if TipText then
			TextWidget:SetText(TipText)
		end
		
		local TakeAwardTimeText = ""
		if TipType == MagicCardTourneyDefine.TipsType.TourneyFinished then
			local EndTime = TourneyVM:GetTourneyEndTime()
			if EndTime and EndTime > 0 then
				local EndTimeText = _G.TimeUtil.GetTimeFormat("%Y/%m/%d %H:%M:%S", EndTime)
				local LocalEndTimeText = LocalizationUtil.GetTimeForFixedFormat(EndTimeText, true) --时间本地化
				TakeAwardTimeText = string.format(MagicCardTourneyDefine.TourneyFinishRewardTimeText, LocalEndTimeText)
			end
		end
		self.TextTips02:SetText(TakeAwardTimeText)
	end
	local CallBack = self.Params.CallBack

	local function HideFunc()
		if CallBack ~= nil then
			CallBack()
		end
		self:Hide()
	end
	self:RegisterTimer(HideFunc, 3)
end

function CardsTourneyMissionTipsNewView:OnHide()

end

function CardsTourneyMissionTipsNewView:OnRegisterUIEvent()

end

function CardsTourneyMissionTipsNewView:OnRegisterGameEvent()

end

function CardsTourneyMissionTipsNewView:OnRegisterBinder()

end

return CardsTourneyMissionTipsNewView