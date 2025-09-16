---
--- Author: Administrator
--- DateTime: 2023-12-19 09:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local AudioUtil = require("Utils/AudioUtil")
local LSTR = _G.LSTR

---@class JumboCactpotRewardBonusNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnHelp CommInforBtnView
---@field ImgLight01 UFImage
---@field ImgLight02 UFImage
---@field ImgLight03 UFImage
---@field ImgLight04 UFImage
---@field ImgLight05 UFImage
---@field ImgLight06 UFImage
---@field ImgLight07 UFImage
---@field ImgNowLight01 UFImage
---@field ImgNowLight02 UFImage
---@field ImgNowLight03 UFImage
---@field ImgNowLight04 UFImage
---@field ImgNowLight05 UFImage
---@field ImgNowLight06 UFImage
---@field ImgNowLight07 UFImage
---@field Node01 JumboCactpotBonusItemView
---@field Node02 JumboCactpotBonusItemView
---@field Node03 JumboCactpotBonusItemView
---@field Node04 JumboCactpotBonusItemView
---@field Node05 JumboCactpotBonusItemView
---@field Node06 JumboCactpotBonusItemView
---@field Node07 JumboCactpotBonusItemView
---@field PopUpBG CommonPopUpBGView
---@field Probar UProgressBar
---@field TableViewReward UTableView
---@field TextAll UFTextBlock
---@field TextBeginReward UFTextBlock
---@field TextBeginReward01 UFTextBlock
---@field TextBeginReward02 UFTextBlock
---@field TextBeginReward03 UFTextBlock
---@field TextBeginReward04 UFTextBlock
---@field TextBeginReward05 UFTextBlock
---@field TextReward UFTextBlock
---@field TextReward01 UFTextBlock
---@field TextReward02 UFTextBlock
---@field TextReward03 UFTextBlock
---@field TextReward04 UFTextBlock
---@field TextReward05 UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotRewardBonusNewView = LuaClass(UIView, true)

function JumboCactpotRewardBonusNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnHelp = nil
	--self.ImgLight01 = nil
	--self.ImgLight02 = nil
	--self.ImgLight03 = nil
	--self.ImgLight04 = nil
	--self.ImgLight05 = nil
	--self.ImgLight06 = nil
	--self.ImgLight07 = nil
	--self.ImgNowLight01 = nil
	--self.ImgNowLight02 = nil
	--self.ImgNowLight03 = nil
	--self.ImgNowLight04 = nil
	--self.ImgNowLight05 = nil
	--self.ImgNowLight06 = nil
	--self.ImgNowLight07 = nil
	--self.Node01 = nil
	--self.Node02 = nil
	--self.Node03 = nil
	--self.Node04 = nil
	--self.Node05 = nil
	--self.Node06 = nil
	--self.Node07 = nil
	--self.PopUpBG = nil
	--self.Probar = nil
	--self.TableViewReward = nil
	--self.TextAll = nil
	--self.TextBeginReward = nil
	--self.TextBeginReward01 = nil
	--self.TextBeginReward02 = nil
	--self.TextBeginReward03 = nil
	--self.TextBeginReward04 = nil
	--self.TextBeginReward05 = nil
	--self.TextReward = nil
	--self.TextReward01 = nil
	--self.TextReward02 = nil
	--self.TextReward03 = nil
	--self.TextReward04 = nil
	--self.TextReward05 = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardBonusNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.Node01)
	self:AddSubView(self.Node02)
	self:AddSubView(self.Node03)
	self:AddSubView(self.Node04)
	self:AddSubView(self.Node05)
	self:AddSubView(self.Node06)
	self:AddSubView(self.Node07)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardBonusNewView:OnInit()
	self.TableViewRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward, nil, true)

	self.Binders = {
		{ "BuySum", UIBinderSetText.New(self, self.TextAll)},
		{ "Stage1stInitNum", UIBinderSetText.New(self, self.Node01.TextCount)},
		{ "Stage2stInitNum", UIBinderSetText.New(self, self.Node02.TextCount)},
		{ "Stage3stInitNum", UIBinderSetText.New(self, self.Node03.TextCount)},
		{ "Stage4stInitNum", UIBinderSetText.New(self, self.Node04.TextCount)},
		{ "Stage5stInitNum", UIBinderSetText.New(self, self.Node05.TextCount)},
		{ "Stage6stInitNum", UIBinderSetText.New(self, self.Node06.TextCount)},
		{ "Stage7stInitNum", UIBinderSetText.New(self, self.Node07.TextCount)},

		{ "BaseRewardNum1", UIBinderSetTextFormatForMoney.New(self, self.TextBeginReward01)},
		{ "BaseRewardNum2", UIBinderSetTextFormatForMoney.New(self, self.TextBeginReward02)},
		{ "BaseRewardNum3", UIBinderSetTextFormatForMoney.New(self, self.TextBeginReward03)},
		{ "BaseRewardNum4", UIBinderSetTextFormatForMoney.New(self, self.TextBeginReward04)},
		{ "BaseRewardNum5", UIBinderSetTextFormatForMoney.New(self, self.TextBeginReward05)},--

		{ "FinishStage", UIBinderValueChangedCallback.New(self, nil, self.OnFinishStageChanged)},

		{ "StagePro", UIBinderSetPercent.New(self, self.Probar)},

		{ "JumbRewardBuffList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter)},
	}
end

function JumboCactpotRewardBonusNewView:OnDestroy()

end

function JumboCactpotRewardBonusNewView:OnShow()
	AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.RewardBouns)

	self:InitLSTRText()
end

function JumboCactpotRewardBonusNewView:InitLSTRText()
	self.TextTitle:SetText(LSTR(240087)) 		-- 奖励加成 

	self.TextTips:SetText(LSTR(240088))	 -- 累计注数越多，奖励越多
	self.TextReward:SetText(LSTR(240089)) 	-- 奖项

	self.TextReward01:SetText(string.format(LSTR(240090), 1)) -- %d等奖
	self.TextReward02:SetText(string.format(LSTR(240090), 2))
	self.TextReward03:SetText(string.format(LSTR(240090), 3))
	self.TextReward04:SetText(string.format(LSTR(240090), 4))
	self.TextReward05:SetText(string.format(LSTR(240090), 5))
	self.TextBeginReward:SetText(LSTR(240091)) -- 初始奖励
end


function JumboCactpotRewardBonusNewView:OnHide()
	JumboCactpotMgr.bClickBtnWaitOpen = false

end

function JumboCactpotRewardBonusNewView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClicked)
	-- UIUtil.AddOnClickedEvent(self, self.BtnHelp, self.OnBtnHelpClicked)

end

function JumboCactpotRewardBonusNewView:OnRegisterGameEvent()

end

function JumboCactpotRewardBonusNewView:OnRegisterBinder()
    self:RegisterBinders(JumboCactpotVM.RewardBounsVM, self.Binders)
end

function JumboCactpotRewardBonusNewView:OnFinishStageChanged(FinishStage)
	local ColorDefine = JumboCactpotDefine.ColorDefine
	for i = 1, 7 do
		local NodeIndex = string.format("Node0%d", i) 							-- 用于控制Node
		UIUtil.SetIsVisible(self[NodeIndex].PanelNode, FinishStage >= i)
		UIUtil.SetIsVisible(self[NodeIndex].ImgArrowAnim, FinishStage == i)
		UIUtil.SetIsVisible(self[NodeIndex].ImgArrow, false)

		UIUtil.SetIsVisible(self[NodeIndex].ImgLight, FinishStage == i)
		UIUtil.SetColorAndOpacityHex(self[NodeIndex].TextCount, i <= FinishStage and ColorDefine.Yellow or ColorDefine.Black)

		local NowLightIndex = string.format("ImgNowLight0%d", i) 					-- 用于控制ImgNowLight
		UIUtil.SetIsVisible(self[NowLightIndex], FinishStage == i)

		local ImgLightIndex = string.format("ImgLight0%d", i)						-- 用于控制Node
		UIUtil.SetIsVisible(self[ImgLightIndex], FinishStage >= i)
	end
end

function JumboCactpotRewardBonusNewView:OnBtnCloseClicked()
	self:Hide()
end

return JumboCactpotRewardBonusNewView