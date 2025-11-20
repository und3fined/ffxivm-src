---
--- Author: Administrator
--- DateTime: 2025-07-14 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MysterMerchantMgr = require("Game/MysterMerchant/MysterMerchantMgr")
local MysterMerchantVM = require("Game/MysterMerchant/VM/MysterMerchantVM")
local MysterMerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")

---@class MysterMerchantRewardsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtn CommBtnXLView
---@field ImgArrowGreen UFImage
---@field ImgArrowOrange UFImage
---@field ImgTreasureLight UFImage
---@field PanelBubble UFCanvasPanel
---@field PanelFailure UFCanvasPanel
---@field PanelGrandTreasure UFCanvasPanel
---@field PanelTreasureChest UFCanvasPanel
---@field SpineFrontGrass USpineWidget
---@field SpineMysterMerchant USpineWidget
---@field TextBubble UFTextBlock
---@field TextInvest UFTextBlock
---@field TextInvestmentAmount UFTextBlock
---@field TextLoad UFTextBlock
---@field TextReport UFTextBlock
---@field TextReportAmount UFTextBlock
---@field TextTitleGreen UFTextBlock
---@field TextTitleOrange UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MysterMerchantRewardsWinView = LuaClass(UIView, true)

function MysterMerchantRewardsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBtn = nil
	--self.ImgArrowGreen = nil
	--self.ImgArrowOrange = nil
	--self.ImgTreasureLight = nil
	--self.PanelBubble = nil
	--self.PanelFailure = nil
	--self.PanelGrandTreasure = nil
	--self.PanelTreasureChest = nil
	--self.SpineFrontGrass = nil
	--self.SpineMysterMerchant = nil
	--self.TextBubble = nil
	--self.TextInvest = nil
	--self.TextInvestmentAmount = nil
	--self.TextLoad = nil
	--self.TextReport = nil
	--self.TextReportAmount = nil
	--self.TextTitleGreen = nil
	--self.TextTitleOrange = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MysterMerchantRewardsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MysterMerchantRewardsWinView:OnInit()
	self.Binders = {
		{"InvestResultText", UIBinderSetText.New(self, self.TextTitleGreen) },
		{"InvestResultText", UIBinderSetText.New(self, self.TextTitleOrange) },
		{"RewardMultipleText", UIBinderSetText.New(self, self.TextBubble) },
		{"SpentCoinText", UIBinderSetText.New(self, self.TextInvestmentAmount) },
		{"RewardCoinText", UIBinderSetText.New(self, self.TextReportAmount) },
		{"InvestResult", UIBinderValueChangedCallback.New(self, nil, self.OnInvestResultChanged)}
	}
end

function MysterMerchantRewardsWinView:OnDestroy()

end

function MysterMerchantRewardsWinView:OnShow()
	self:PlayUISound()
	self:SetLSTR()
end

function MysterMerchantRewardsWinView:OnHide()

end

function MysterMerchantRewardsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtn, self.OnClickedBtnGreReward)
end

function MysterMerchantRewardsWinView:OnRegisterGameEvent()

end

function MysterMerchantRewardsWinView:OnRegisterBinder()
	self:RegisterBinders(MysterMerchantVM, self.Binders)
end

function MysterMerchantRewardsWinView:PlayUISound()
	AudioUtil.LoadAndPlay2DSound(MysterMerchantDefine.SoundPath.InvestRewardStart)
	local ExcavateFinishTime = 2.87 -- 挖土动效结束时间
	local ShowResultFinishTime = 3.83 -- 结果展示结束时间
	local InvestResult = MysterMerchantVM.InvestResult
	local ResultSoundName = MysterMerchantDefine.SoundPath.InvestResultFailed
	if InvestResult == MysterMerchantDefine.EnumInvestResult.Success then
		ResultSoundName = MysterMerchantDefine.SoundPath.InvestResultSuccess
	elseif InvestResult == MysterMerchantDefine.EnumInvestResult.SpecialSuccess then
		ResultSoundName = MysterMerchantDefine.SoundPath.InvestResultSuperSuccess
	end

	local function PlayResultSound()
		AudioUtil.LoadAndPlay2DSound(ResultSoundName)
	end
	self:RegisterTimer(function ()
		AudioUtil.LoadAndPlay2DSound(ResultSoundName)
	end, ExcavateFinishTime)

	self:RegisterTimer(function ()
		AudioUtil.LoadAndPlay2DSound(MysterMerchantDefine.SoundPath.InvestResultNumText)
	end, ShowResultFinishTime)
end

function MysterMerchantRewardsWinView:SetLSTR()
	self.TextInvest:SetText(_G.LSTR(1110059)) -- 1110059("投资金额")
	self.TextReport:SetText(_G.LSTR(1110060)) -- 1110060("回报金额")
	self.CommBtn.TextContent:SetText(_G.LSTR(1110061)) -- 1110061("领取回报")
	self.TextLoad:SetText(_G.LSTR(1110062)) -- 1110062("草丛发出叮呤咣啷的声音")
end

function MysterMerchantRewardsWinView:OnClickedBtnGreReward()
	local CurMerchantID = MysterMerchantVM.MerchantID
	MysterMerchantMgr:SendMsgInvestRewardReq(CurMerchantID)
	self:Hide()
end

function MysterMerchantRewardsWinView:OnInvestResultChanged(InvestResult)
	UIUtil.SetIsVisible(self.TextTitleGreen, InvestResult == MysterMerchantDefine.EnumInvestResult.Failed)
	UIUtil.SetIsVisible(self.TextTitleOrange, InvestResult >= MysterMerchantDefine.EnumInvestResult.Success)
	UIUtil.SetIsVisible(self.PanelBubble, InvestResult >= MysterMerchantDefine.EnumInvestResult.Success)

	-- 动效
	local Color = InvestResult == MysterMerchantDefine.EnumInvestResult.Failed and "313131FF" or "B56728FF"
	UIUtil.TextBlockSetColorAndOpacityHex( self.TextReport, Color)
	UIUtil.TextBlockSetColorAndOpacityHex( self.TextReportAmount, Color) -- 回报金额颜色
	UIUtil.SetIsVisible(self.PanelFailure, InvestResult == MysterMerchantDefine.EnumInvestResult.Failed)
	UIUtil.SetIsVisible(self.ImgTreasureLight, InvestResult >= MysterMerchantDefine.EnumInvestResult.Success)
	UIUtil.SetIsVisible(self.PanelTreasureChest, InvestResult >= MysterMerchantDefine.EnumInvestResult.Success)
	UIUtil.SetIsVisible(self.PanelGrandTreasure, InvestResult == MysterMerchantDefine.EnumInvestResult.SpecialSuccess)
end


return MysterMerchantRewardsWinView