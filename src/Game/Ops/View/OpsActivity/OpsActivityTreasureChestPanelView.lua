---
--- Author: yutingzhan
--- DateTime: 2024-11-05 16:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local OpsActivityTreasureChestPanelVM = require("Game/Ops/VM/OpsActivityTreasureChestPanelVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local BagMgr = require("Game/Bag/BagMgr")
local EventID = require("Define/EventID")
local SaveKey = require("Define/SaveKey")
local DataReportUtil = require("Utils/DataReportUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local TimeUtil = require("Utils/TimeUtil")
local AudioUtil = require("Utils/AudioUtil")
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")

local LSTR = _G.LSTR
local USaveMgr = _G.UE.USaveMgr

local SCORE_TYPE = ProtoRes.SCORE_TYPE
local LotterySoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Play_Activity_TreasureChest_LotterySound.Play_Activity_TreasureChest_LotterySound'"

---@class OpsActivityTreasureChestPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnJumpOver UFButton
---@field BtnOpen CommBtnLView
---@field BtnPoster UFButton
---@field BtnRewardsPreview UFButton
---@field CommCheckBox CommCheckBoxView
---@field EFF2 UFCanvasPanel
---@field ImgKey UFImage
---@field ImgPoster UFImage
---@field MoneyBar CommMoneyBarView
---@field OwnedText UFTextBlock
---@field PanelBtn UFCanvasPanel
---@field PanelJumpOver UFCanvasPanel
---@field PanelOriginalPrice UFCanvasPanel
---@field PanelPoster UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextHint UFTextBlock
---@field TextJumpOver UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextQuantity URichTextBox
---@field TextRewardName UFTextBlock
---@field TextRewardsPreview UFTextBlock
---@field TextSubTitle URichTextBox
---@field TextTitle UFTextBlock
---@field Time OpsActivityTimeItemView
---@field TreasureChestFinalDrawTips OpsActivityTreasureChestFinalDrawTipsView
---@field AnimBack UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOpen UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityTreasureChestPanelView = LuaClass(UIView, true)

function OpsActivityTreasureChestPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnJumpOver = nil
	--self.BtnOpen = nil
	--self.BtnPoster = nil
	--self.BtnRewardsPreview = nil
	--self.CommCheckBox = nil
	--self.EFF2 = nil
	--self.ImgKey = nil
	--self.ImgPoster = nil
	--self.MoneyBar = nil
	--self.OwnedText = nil
	--self.PanelBtn = nil
	--self.PanelJumpOver = nil
	--self.PanelOriginalPrice = nil
	--self.PanelPoster = nil
	--self.TableViewSlot = nil
	--self.TextHint = nil
	--self.TextJumpOver = nil
	--self.TextOriginalPrice = nil
	--self.TextQuantity = nil
	--self.TextRewardName = nil
	--self.TextRewardsPreview = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.Time = nil
	--self.TreasureChestFinalDrawTips = nil
	--self.AnimBack = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOpen = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChestPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnOpen)
	self:AddSubView(self.CommCheckBox)
	self:AddSubView(self.MoneyBar)
	self:AddSubView(self.Time)
	self:AddSubView(self.TreasureChestFinalDrawTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChestPanelView:OnInit()
	UIUtil.SetIsVisible(self.MoneyBar.Money3, false)
	UIUtil.SetIsVisible(self.TreasureChestFinalDrawTips.Comm74Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.TreasureChestFinalDrawTips.Comm74Slot.IconChoose, false)
	self.TextOriginalPrice:SetText(1)
	self.AwardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnClickedSelectMemberItem, true)
	self.Binders = {
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
        {"AwardVMList", UIBinderUpdateBindableList.New(self, self.AwardTableViewAdapter)},
		{"BtnContent", UIBinderSetText.New(self, self.BtnOpen.TextContent)},
		{"ImgPoster", UIBinderSetBrushFromAssetPath.New(self, self.ImgPoster) },
		{"ImgKey", UIBinderSetBrushFromAssetPath.New(self, self.ImgKey) },
		{"TextRewardName", UIBinderSetText.New(self, self.TextRewardName)},
		{"ConsumePropNum", UIBinderSetText.New(self, self.TextQuantity)},
		{"CheckBoxState", UIBinderSetIsChecked.New(self, self.CommCheckBox.ToggleButton)},
		{"FinalRewardNum", UIBinderSetText.New(self, self.TreasureChestFinalDrawTips.Comm74Slot.RichTextQuantity)},
		{"FinalRewardIcon", UIBinderSetBrushFromAssetPath.New(self, self.TreasureChestFinalDrawTips.Comm74Slot.Icon)},
		{"FinalRewardImgQuanlity", UIBinderSetBrushFromAssetPath.New(self, self.TreasureChestFinalDrawTips.Comm74Slot.ImgQuanlity)},
    }
end

function OpsActivityTreasureChestPanelView:OnDestroy()

end

function OpsActivityTreasureChestPanelView:OnShow()
	self.TreasureChestFinalDrawTips.TextHint:SetText(LSTR(100012))
	self.TextHint:SetText(LSTR(100013))
	self.OwnedText:SetText(LSTR(100015))
	self.TextRewardsPreview:SetText(LSTR(100016))
	self.CommCheckBox:SetText(LSTR(100014))
	self.TextJumpOver:SetText(LSTR(100025))
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self:SetTextColor()
	self.ViewModel = OpsActivityTreasureChestPanelVM
	self.ViewModel:Update(self.Params)
	self:UpdateLotteryPanelInfo()
	self.MoneyBar.Money1:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, UIViewID.RechargingMainPanel, true)
	self.MoneyBar.Money2:UpdateView(self.ViewModel.LotteryPropID, false, UIViewID.OpsActivityTreasureChestBuyItemWinView, false)
	UIUtil.SetIsVisible(self.MoneyBar.Money2.ImgAdd, true, false, false)
	UIUtil.SetIsVisible(self.MoneyBar.Money2.BtnAdd,true, true, true)
end

function OpsActivityTreasureChestPanelView:OnHide()
	_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsActivityTreasureChest, false)
end

function OpsActivityTreasureChestPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnOpen, self.OnBtnOpenClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnPoster, self.OnImgPosterClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnCheck, self.OnBtnCheckClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnRewardsPreview, self.OnBtnRewardsPreviewClick)
	UIUtil.AddOnClickedEvent(self,  self.MoneyBar.Money2.BtnAdd, self.OnPropsBtnAddClick)
	UIUtil.AddOnClickedEvent(self,  self.MoneyBar.Money1.BtnAdd, self.OnScoreBtnAddClick)
	UIUtil.AddOnClickedEvent(self,  self.TreasureChestFinalDrawTips.Comm74Slot.Btn, self.OnFinalRewardClick)
	UIUtil.AddOnStateChangedEvent(self, self.CommCheckBox.ToggleButton, self.OnCheckBoxClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnJumpOver, self.OnBtnJumpOverClick)
end

function OpsActivityTreasureChestPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateLotteryInfo, self.UpdateLotteryPanelInfo)
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.ShowLotteryReward)
	self:RegisterGameEvent(EventID.PurchaseLotteryProps, self.OnPurchaseLotteryProps)
	self:RegisterGameEvent(EventID.OpsTreasureChestSkipAnimation, self.OnClickRewardCheckBox)
end

function OpsActivityTreasureChestPanelView:OnRegisterBinder()
	self:RegisterBinders(OpsActivityTreasureChestPanelVM, self.Binders)
end

function OpsActivityTreasureChestPanelView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ItemID == nil then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView, nil, nil, 30)
end

function OpsActivityTreasureChestPanelView:OnPurchaseLotteryProps()
	self.MoneyBar.Money2.TextMoneyAmount:SetText(_G.ScoreMgr.FormatScore(BagMgr:GetItemNum(self.ViewModel.LotteryPropID)))
end


function OpsActivityTreasureChestPanelView:OnImgPosterClick()
	ItemTipsUtil.ShowTipsByResID(self.ViewModel.FinalAwardItemID, self.ImgPoster, {X = 0, Y = 0})
end

function OpsActivityTreasureChestPanelView:OnBtnCheckClick()
    if self.ViewModel.VideoNode then
        UIViewMgr:ShowView(UIViewID.CommonVideoPlayerView, {VideoPath = self.ViewModel.VideoNode.StrParam})
    else
		if self.ViewModel.FinalAwardSuitID and self.ViewModel.FinalAwardSuitID ~= 0 then
			_G.PreviewMgr:OpenPreviewView(self.ViewModel.FinalAwardSuitID)
		else
			_G.PreviewMgr:OpenPreviewView(self.ViewModel.FinalAwardItemID)
		end
	end
	--珍品宝箱活动埋点(大奖预览/大奖视频)
	DataReportUtil.ReportActivityClickFlowData(OpsActivityTreasureChestPanelVM.ActivityID, "3")
end


function OpsActivityTreasureChestPanelView:OnBtnJumpOverClick()
    self:StopLotterySound()
	self:StopAnimation(self.AnimOpen)
	self:UnRegisterTimer(self.ShowRewardTimer)
	local OpsMainView = UIViewMgr:FindView(UIViewID.OpsActivityMainPanel)
	UIUtil.SetIsVisible(OpsMainView.CommMenu, true)
	UIUtil.SetIsVisible(OpsMainView.CloseBtn, true)
	UIUtil.SetIsVisible(OpsMainView.CommonTitle, true)
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, self.RewardParams)
end

function OpsActivityTreasureChestPanelView:StopLotterySound()
    if self.LotterySoundHandle ~= nil then
        AudioUtil.StopAsyncAudioHandle(self.LotterySoundHandle)
    end
end

function OpsActivityTreasureChestPanelView:ShowLotteryReward(MsgBody)
	if MsgBody == nil or MsgBody.NodeOperate == nil or MsgBody.NodeOperate.Result == nil then
		return
	end
	local LotteryInfo = MsgBody.NodeOperate.Result
	_G.LootMgr:SetDealyState(true)
	_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsActivityTreasureChest, true)
	self:UpdateLotteryPanelInfo()
	local Params = {}
	local RewardItem = {}
	-- 抽到的是否是大奖
	local IsFinalAward = false
	local Reward = LotteryInfo.LotteryDrawGetReward.LotteryDrawReward
	for k, v in ipairs(Reward) do
		if v.ItemID ~= self.ViewModel.LotteryPropID then
			table.insert(RewardItem,{ResID = Reward[k].ItemID, Num = Reward[k].ItemNum})
			if Reward[k].ItemID == self.ViewModel.FinalAwardItemID then
				IsFinalAward = true
				-- 大奖才有分享
				Params.ShareNode = self.ViewModel.ShareNode
				Params.ShareNodeCfg = self.ViewModel.ShareNodeCfg
				Params.ActivityID = self.ViewModel.ActivityID
			end
		end
	end
	self.MoneyBar.Money2.TextMoneyAmount:SetText(_G.ScoreMgr.FormatScore(BagMgr:GetItemNum(self.ViewModel.LotteryPropID)))
	Params.LotteryAwards = true
	Params.IsFinalAward = IsFinalAward
	Params.ItemList = RewardItem
	local IsFinishLottery = false
	if self.ViewModel.LotteryConsumeNum then
		IsFinishLottery = self.DrawNum  == #self.ViewModel.LotteryConsumeNum
		Params.IsFinishLottery = IsFinishLottery
	end
	if IsFinishLottery then
		Params.ShowBtn = false
	else
		local function BtnLeftCB()
			_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsActivityTreasureChest, false)
			if USaveMgr.GetInt(SaveKey.OpsSkipAnimation, 0, true) <= 0 then
				self:PlayAnimation(self.AnimBack)
			end
			UIViewMgr:HideView(UIViewID.CommonRewardPanel)
		end
		Params.ShowBtn = true
		Params.ShowBtnLeft = true
		Params.ShowBtnRight = true
		Params.ActivityID = self.ViewModel.ActivityID
		Params.BtnLeftText = LSTR(10002)
		Params.BtnRightText = LSTR(100017)
		Params.BtnLeftCB = BtnLeftCB
		local function BtnOpenClick()
			local IsReOpenClick = true
			self:OnBtnOpenClick(IsReOpenClick)
			--珍品宝箱活动埋点(点击再开一次)
			DataReportUtil.ReportActivityClickFlowData(OpsActivityTreasureChestPanelVM.ActivityID, "2")
		end
		Params.BtnRightCB = BtnOpenClick
		Params.PropItemID = self.ViewModel.LotteryPropID
		if self.ViewModel.LotteryConsumeNum then
			Params.ConsumePropNum = self.ViewModel.LotteryConsumeNum[self.DrawNum + 1]
		end
	end
	self.RewardParams = Params
	if USaveMgr.GetInt(SaveKey.OpsSkipAnimation, 0, true) == self.ViewModel.ActivityID then
		UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
	else
		self.LotterySoundHandle = AudioUtil.LoadAndPlay2DSound(LotterySoundPath)
		self:PlayAnimation(self.AnimOpen)
		local OpsMainView = UIViewMgr:FindView(UIViewID.OpsActivityMainPanel)
		UIUtil.SetIsVisible(OpsMainView.CommMenu, false)
		UIUtil.SetIsVisible(OpsMainView.CloseBtn, false)
		UIUtil.SetIsVisible(OpsMainView.CommonTitle, false)
		self.ShowRewardTimer = self:RegisterTimer(function()
			self:StopAnimation(self.AnimOpen)
			UIUtil.SetIsVisible(OpsMainView.CommMenu, true)
			UIUtil.SetIsVisible(OpsMainView.CloseBtn, true)
			UIUtil.SetIsVisible(OpsMainView.CommonTitle, true)
			UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
		end, 3)
	end
end

function OpsActivityTreasureChestPanelView:OnPropsBtnAddClick()
	if self.ViewModel.PurchaseNum == nil then
		return
	end
	if self.ViewModel.ExchangeNode == nil or self.ViewModel.ExchangeNode.Target == nil then
		return
	end
	-- 已购次数达到最大购买次数Target
	if self.ViewModel.PurchaseNum >= self.ViewModel.ExchangeNode.Target then
		MsgTipsUtil.ShowTips(LSTR(100028))
	else
		UIViewMgr:ShowView(UIViewID.OpsActivityTreasureChestBuyItemWinView)
		--珍品宝箱活动埋点(钥匙+按钮)
		DataReportUtil.ReportActivityClickFlowData(OpsActivityTreasureChestPanelVM.ActivityID, "6")
	end
end

function OpsActivityTreasureChestPanelView:OnScoreBtnAddClick()
	--珍品宝箱活动埋点(水晶点+按钮)
	DataReportUtil.ReportActivityClickFlowData(OpsActivityTreasureChestPanelVM.ActivityID, "5")
end

function OpsActivityTreasureChestPanelView:OnBtnOpenClick(IsReOpenClick)
	local LotteryPropNum = BagMgr:GetItemNum(OpsActivityTreasureChestPanelVM.LotteryPropID)
	if LotteryPropNum == nil  or OpsActivityTreasureChestPanelVM.ConsumePropNum == nil then
		return
	end
	if LotteryPropNum < OpsActivityTreasureChestPanelVM.ConsumePropNum then
		if UIViewMgr:IsViewVisible(UIViewID.CommonRewardPanel) then
			UIViewMgr:HideView(UIViewID.CommonRewardPanel)
		end
		UIViewMgr:ShowView(UIViewID.OpsActivityTreasureChestBuyItemWinView)
	else
		local LastReOpenTime = 0
		local LastOpenTime = 0
		if IsReOpenClick then
			LastReOpenTime = self.ReOpenClickTime or 0
		else
			LastOpenTime = self.ClickOpenTime or 0
		end
		local CurrentTime = TimeUtil.GetServerTime()
		if (IsReOpenClick and CurrentTime - LastReOpenTime >= 1) or
			(not IsReOpenClick and CurrentTime - LastOpenTime > 1) then
			if UIViewMgr:IsViewVisible(UIViewID.CommonRewardPanel) then
				UIViewMgr:HideView(UIViewID.CommonRewardPanel)
			end
			self.ReOpenClickTime = CurrentTime
			self.ClickOpenTime = CurrentTime
			 _G.LootMgr:SetDealyState(true)
			 local Data = {NodeID = OpsActivityTreasureChestPanelVM.LotteryNodeID}
			 OpsActivityMgr:SendActivityNodeOperate(
				 OpsActivityTreasureChestPanelVM.LotteryNodeID,
				 ProtoCS.Game.Activity.NodeOpType.NodeOpTypeLotteryDrawNoLayBack,
				 {LotteryDrawGetReward = Data}
			 )
		end
	end
end

function OpsActivityTreasureChestPanelView:OnCheckBoxClick(_, ButtonState)
	local bChecked = UIUtil.IsToggleButtonChecked(ButtonState)
	USaveMgr.SetInt(SaveKey.OpsSkipAnimation, bChecked and self.ViewModel.ActivityID or 0, true)
end

function OpsActivityTreasureChestPanelView:OnClickRewardCheckBox(ButtonState)
	if self and self.ViewModel and  self.ViewModel.ActivityID then
		local bChecked = UIUtil.IsToggleButtonChecked(ButtonState)
		self.CommCheckBox:SetChecked(bChecked, false)
		self:OnCheckBoxClick(_, ButtonState)
	end
end

function OpsActivityTreasureChestPanelView:OnBtnRewardsPreviewClick()
	if self.LotteryInfo then
		UIViewMgr:ShowView(UIViewID.OpsActivityPrizePoolWinView, self.LotteryInfo)
		--珍品宝箱活动埋点(奖池预览)
		DataReportUtil.ReportActivityClickFlowData(OpsActivityTreasureChestPanelVM.ActivityID, "4")
	end
end

function OpsActivityTreasureChestPanelView:UpdateLotteryPanelInfo()
	if self.Params == nil or self.Params.NodeList == nil then
		return
	end
	local NodeList = self.Params.NodeList
	for _, Node in ipairs(NodeList) do
		local Extra = Node.Extra
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
		if NodeCfg then
			if NodeCfg.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypeExchange then
				--已购次数
				self.ViewModel.PurchaseNum = Extra.Progress.Value
			elseif NodeCfg.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypeLotteryDrawNoLayBack then
				self.LotteryInfo = Extra.Lottery
			end
		end
	end
	local LotteryInfo = self.LotteryInfo
	if LotteryInfo == nil then
		return
	end
	self.DrawNum = LotteryInfo.DrawNum
	self.Params:UpdateTreasureChestRedDot(self.Params.Activity, self.Params.NodeList)
	local TotalAwards = table.array_concat(self.ViewModel.LotteryAwardNodes, {self.ViewModel.FinalAward})
	UIUtil.SetIsVisible(self.OwnedText, false)
	local DropedID = LotteryInfo.DropedResID
	self.DropedResID = {}
	for i, v in ipairs(TotalAwards)do
		if table.contain(DropedID, v.ID) then
			if v.ID == self.ViewModel.FinalAward.ID then
				UIUtil.SetIsVisible(self.OwnedText, true)
			else
				self.ViewModel.LotteryAwardNodes[i].IconReceivedVisible = true
			end
			table.insert(self.DropedResID, v.DropID)
		end
	end
	self.ViewModel.AwardVMList:UpdateByValues(self.ViewModel.LotteryAwardNodes)
	self.FinishedLottery = false
	UIUtil.SetIsVisible(self.TreasureChestFinalDrawTips, false)
	self.ViewModel.DrawNum = self.DrawNum
	self.ViewModel.ConsumePropNum = self.ViewModel.LotteryConsumeNum[self.DrawNum + 1]
	local function UpdateQuantityColor()
        local LotteryPropNum = BagMgr:GetItemNum(OpsActivityTreasureChestPanelVM.LotteryPropID)
		if LotteryPropNum ~= nil and OpsActivityTreasureChestPanelVM.ConsumePropNum ~= nil then
			local colorHex = (LotteryPropNum < OpsActivityTreasureChestPanelVM.ConsumePropNum) 
                        and "DC5868FF" or "FFEEBBFF"
			UIUtil.SetColorAndOpacityHex(self.TextQuantity, colorHex)
		end
    end
	-- 所有奖品都抽完
	if self.DrawNum == #self.ViewModel.LotteryConsumeNum  then
		UIUtil.SetIsVisible(self.PanelBtn, false)
		UIUtil.SetIsVisible(self.CommCheckBox, false)
		UIUtil.SetIsVisible(self.TextHint, true)
		UIUtil.SetIsVisible(self.OwnedText,true)
		UIUtil.SetIsVisible(self.EFF2, false)
		self.FinishedLottery = true
	elseif self.DrawNum == 0 then
		self.BtnOpen:SetText(LSTR(100019))
		UIUtil.SetIsVisible(self.PanelBtn, true)
		UIUtil.SetIsVisible(self.PanelOriginalPrice, true)
		UIUtil.SetIsVisible(self.TextHint, false)
		UIUtil.SetIsVisible(self.OwnedText,false)
		UIUtil.SetIsVisible(self.EFF2, true)
		UIUtil.SetIsVisible(self.CommCheckBox, true)
		UpdateQuantityColor()
	else 
		self.BtnOpen:SetText(LSTR(100020))
		UIUtil.SetIsVisible(self.PanelBtn, true)
		UIUtil.SetIsVisible(self.PanelOriginalPrice, false)
		UIUtil.SetIsVisible(self.TextHint, false)
		UIUtil.SetIsVisible(self.EFF2, false)
		UIUtil.SetIsVisible(self.CommCheckBox, true)
		UpdateQuantityColor()
		-- 最后一抽
		if self.DrawNum + 1 == #self.ViewModel.LotteryConsumeNum then
			for _, Node in ipairs(table.array_concat(self.ViewModel.LotteryAwardNodes, {self.ViewModel.FinalAward})) do
				if not table.contain(self.DropedResID, Node.DropID) then
					if Node.DropID == self.ViewModel.FinalAwardItemID then
						UIUtil.SetIsVisible(self.TreasureChestFinalDrawTips, true)
						self.ViewModel:SetFinalRewardTips(self.ViewModel.FinalAwardItemID, self.ViewModel.FinalAward.DropNum)
					end
					break
				end
			end
		end
	end
end

function OpsActivityTreasureChestPanelView:OnFinalRewardClick()
	ItemTipsUtil.ShowTipsByResID(self.ViewModel.FinalAwardItemID, self.TreasureChestFinalDrawTips.Comm74Slot, {X = 0, Y = 0})
end

function OpsActivityTreasureChestPanelView:SetTextColor()
	if self.Params.Activity == nil then
		return
	end
	local FColor = _G.UE.FLinearColor
	local Activity = self.Params.Activity
	if Activity.TitleColor and Activity.TitleColor ~= "" then
		self.TextTitle:SetColorAndOpacity(FColor.FromHex(Activity.TitleColor))
	end
	if Activity.SubTitleColor and Activity.SubTitleColor ~= "" then
		self.TextSubTitle:SetColorAndOpacity(FColor.FromHex(Activity.SubTitleColor))
	end
end

return OpsActivityTreasureChestPanelView