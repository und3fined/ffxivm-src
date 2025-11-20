---
--- Author: v_vvxinchen
--- DateTime: 2025-07-28 14:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local OpsLolitaBuyVM = require("Game/Ops/VM/OpsLolitaBuyVM")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require ("Protocol/ProtoRes")
local ScoreCfg = require("TableCfg/ScoreCfg")
local LSTR = _G.LSTR

---@class OpsLolitaMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnBuy OpsCommBtnLView
---@field BtnVideo1 UFButton
---@field BtnVideo2 UFButton
---@field CommSingleBox CommSingleBoxView
---@field IconVideco1 UFImage
---@field IconVideco2 UFImage
---@field LolitaGiftCard OpsLolitaGiftCardItemView
---@field LolitaSuitBuy1 OpsLolitaSuitBuyItemView
---@field LolitaSuitBuy2 OpsLolitaSuitBuyItemView
---@field LolitaSuitBuy3 OpsLolitaSuitBuyItemView
---@field LolitaSuitBuy4 OpsLolitaSuitBuyItemView
---@field LolitaSuitBuy5 OpsLolitaSuitBuyItemView
---@field LolitaSuitItem1 OpsLolitaSuitItemView
---@field LolitaSuitItem2 OpsLolitaSuitItemView
---@field LolitaSuitItem3 OpsLolitaSuitItemView
---@field LolitaSuitItem4 OpsLolitaSuitItemView
---@field LolitaSuitItem5 OpsLolitaSuitItemView
---@field OpsActivityTime OpsActivityTimeItemView
---@field OpsCommTopFeaturesPanel OpsCommTopFeaturesPanelView
---@field PanelBuy UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PanelVideo1 UFCanvasPanel
---@field PanelVideo2 UFCanvasPanel
---@field TextGetReward UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTilte UFTextBlock
---@field TextTilteBuy UFTextBlock
---@field UMGVideoPlayer1 UMGVideoPlayerView
---@field UMGVideoPlayer2 UMGVideoPlayerView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLolitaMainPanelView = LuaClass(UIView, true)

function OpsLolitaMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnBuy = nil
	--self.BtnVideo1 = nil
	--self.BtnVideo2 = nil
	--self.CommSingleBox = nil
	--self.IconVideco1 = nil
	--self.IconVideco2 = nil
	--self.LolitaGiftCard = nil
	--self.LolitaSuitBuy1 = nil
	--self.LolitaSuitBuy2 = nil
	--self.LolitaSuitBuy3 = nil
	--self.LolitaSuitBuy4 = nil
	--self.LolitaSuitBuy5 = nil
	--self.LolitaSuitItem1 = nil
	--self.LolitaSuitItem2 = nil
	--self.LolitaSuitItem3 = nil
	--self.LolitaSuitItem4 = nil
	--self.LolitaSuitItem5 = nil
	--self.OpsActivityTime = nil
	--self.OpsCommTopFeaturesPanel = nil
	--self.PanelBuy = nil
	--self.PanelMain = nil
	--self.PanelVideo1 = nil
	--self.PanelVideo2 = nil
	--self.TextGetReward = nil
	--self.TextSubTitle = nil
	--self.TextTilte = nil
	--self.TextTilteBuy = nil
	--self.UMGVideoPlayer1 = nil
	--self.UMGVideoPlayer2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLolitaMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.CommSingleBox)
	self:AddSubView(self.LolitaGiftCard)
	self:AddSubView(self.LolitaSuitBuy1)
	self:AddSubView(self.LolitaSuitBuy2)
	self:AddSubView(self.LolitaSuitBuy3)
	self:AddSubView(self.LolitaSuitBuy4)
	self:AddSubView(self.LolitaSuitBuy5)
	self:AddSubView(self.LolitaSuitItem1)
	self:AddSubView(self.LolitaSuitItem2)
	self:AddSubView(self.LolitaSuitItem3)
	self:AddSubView(self.LolitaSuitItem4)
	self:AddSubView(self.LolitaSuitItem5)
	self:AddSubView(self.OpsActivityTime)
	self:AddSubView(self.OpsCommTopFeaturesPanel)
	self:AddSubView(self.UMGVideoPlayer1)
	self:AddSubView(self.UMGVideoPlayer2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLolitaMainPanelView:OnInit()
	self.ViewModel = OpsLolitaBuyVM.New()
	self.Binders = {
		{"TitleText", UIBinderSetText.New(self, self.TextTilte)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextSubTitle)},
		{"RewardStatus", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStatusChanged)}
    }
	self.TextGetReward:SetText(LSTR(100166))--"已获得全部物品"
	UIUtil.SetIsVisible(self.BtnBuy.TextLowest, true)
	self.BtnBuy.TextLowest:SetText(LSTR(100167))--"最低单价"
	UIUtil.SetIsVisible(self.OpsCommTopFeaturesPanel.BtnVideo, false)

	--OpsLolitaBuyPanel
	self.TextTilteBuy:SetText(LSTR(100144)) --"洛丽塔套装购买"
	self.CommSingleBox.Content = LSTR(10006) --"全选"
end

function OpsLolitaMainPanelView:OnDestroy()

end

function OpsLolitaMainPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self.ViewModel:Update(self.Params)
	self:ShowSuitItems()	
	self:SetVideoPlayer()
	self:ShowMain()
end

function OpsLolitaMainPanelView:ShowSuitItems()
	local ViewModel = self.ViewModel
	for i = 1, 5 do
		self["LolitaSuitItem"..i]:SetParams({SuitDataList = ViewModel.SuitDataList})
		self["LolitaSuitBuy"..i]:SetParams({SuitDataList = ViewModel.SuitDataList, View = self})
	end
end

function OpsLolitaMainPanelView:OnRewardStatusChanged()
	local ViewModel = self.ViewModel
	local RewardStatus = ViewModel.RewardStatus
	local IsRewardStatusNo = RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo

	if UIUtil.IsVisible(self.PanelMain) then
		--购买价格
		local GoodsID = ViewModel:GetLowestPriceGoodsID()
		if GoodsID then
			self.BtnBuy:SetBtnPriceByGoodsID(GoodsID, IsRewardStatusNo)
		end
	end
	
	--购买价格/奖励获得的显隐状态
	self.BtnBuy.Money = IsRewardStatusNo
	UIUtil.SetIsVisible(self.BtnBuy.PanelMoney, IsRewardStatusNo)
	UIUtil.SetIsVisible(self.TextGetReward, not IsRewardStatusNo)
	
	--购买按钮状态
	if IsRewardStatusNo then
		local BtnText = LSTR(100145)  --"购 买"
		self.BtnBuy.BtnText = BtnText
		self.BtnBuy:SetBtnName(BtnText)
		self.BtnBuy.CommBtnL:SetIsRecommendState(true)
	else
		if UIUtil.IsVisible(self.PanelMain) then
			local BtnText = LSTR(100146) --"查 看"
			self.BtnBuy.BtnText = BtnText
			self.BtnBuy:SetBtnName(BtnText)
			self.BtnBuy.CommBtnL:SetIsNormalState(true)
		else
			self.BtnBuy.CommBtnL:SetIsDoneState(true, LSTR(1290003)) --已购买
		end
	end
end

function OpsLolitaMainPanelView:SetVideoPlayer()
	local MoviePath = self.ViewModel.MoviePath
	for i = 1, 2 do
		local UMGVideoPlayer = self["UMGVideoPlayer"..i]
		if MoviePath then
			UMGVideoPlayer:SetVideoPath(MoviePath)
			UMGVideoPlayer:SetPlayMovieEndCallBack(self, function()
				UMGVideoPlayer:SetVolume(false)
				UMGVideoPlayer:OnResume()
			end)
			UMGVideoPlayer:OnRewind()
			UMGVideoPlayer:SetNoUIMode(true)
			UMGVideoPlayer:SetPreviewMode(true)
			UIUtil.SetIsVisible(UMGVideoPlayer.CloseButton, false)
		else
			UMGVideoPlayer:OnClose()
		end
		UMGVideoPlayer:HideAllUI()
	end
end

function OpsLolitaMainPanelView:OnClickBtnVideo(UMGVideoPlayer)
	local MoviePath = self.ViewModel.MoviePath
	if MoviePath then
		UMGVideoPlayer:SetVolume(true)
		UIViewMgr:ShowView(_G.UIViewID.CommonVideoPlayerView, {VideoPath = MoviePath, SeekValue = UMGVideoPlayer:GetSeekValue(), HideCallBack = 
		function ()
			UMGVideoPlayer:SetVolume(false)
			UMGVideoPlayer:OnResume()
		end
		})
	end
end

function OpsLolitaMainPanelView:OnHide()
	self.UMGVideoPlayer1:OnClose()
	self.UMGVideoPlayer2:OnClose()
end

function OpsLolitaMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickBtnBuy)
	self.BtnBack:AddBackClick(self, self.ShowMain)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox.ToggleButton, self.AllSelectedCallback)
	UIUtil.AddOnClickedEvent(self, self.BtnVideo1, self.OnClickBtnVideo, self.UMGVideoPlayer1)
	UIUtil.AddOnClickedEvent(self, self.BtnVideo2, self.OnClickBtnVideo, self.UMGVideoPlayer2)
end

function OpsLolitaMainPanelView:OnClickBtnBuy()
	if UIUtil.IsVisible(self.PanelBuy) then
		self:GoToBuy()
	else
		self:ShowBuy()
	end
end

function OpsLolitaMainPanelView:ShowBuy()
	UIUtil.SetIsVisible(self.PanelBuy, true)
	UIUtil.SetIsVisible(self.CommSingleBox, true)
	UIUtil.SetIsVisible(self.PanelMain, false)
	UIUtil.SetIsVisible(self.UMGVideoPlayer2, true)
	UIUtil.SetIsVisible(self.BtnBuy.TextLowest, false)
	local OpsMainView = UIViewMgr:FindVisibleView(_G.UIViewID.OpsActivityMainPanel)
	if OpsMainView then
		UIUtil.SetIsVisible(OpsMainView.CloseBtn, false, true)
	end

	self:BuyPanelOnShow()
end

function OpsLolitaMainPanelView:ShowMain()
	UIUtil.SetIsVisible(self.PanelMain, true)
	UIUtil.SetIsVisible(self.PanelBuy, false)
	UIUtil.SetIsVisible(self.CommSingleBox, false)
	UIUtil.SetIsVisible(self.UMGVideoPlayer1, true)
	UIUtil.SetIsVisible(self.BtnBuy.TextLowest, true)
	self:OnRewardStatusChanged()
	local OpsMainView = UIViewMgr:FindVisibleView(_G.UIViewID.OpsActivityMainPanel)
	if OpsMainView then
		UIUtil.SetIsVisible(OpsMainView.CloseBtn, true, true)
	end
end


function OpsLolitaMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.OpsNodeRewardGet)
	self:RegisterGameEvent(_G.EventID.StoreBatchBuyParams, self.OnStoreBatchBuy)
	self:RegisterGameEvent(_G.EventID.OpsLolitaNodeChanged, self.OnOpsLolitaNodeChanged)
end

function OpsLolitaMainPanelView:OpsNodeRewardGet()
	local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData ~= nil then
		self.Params.NodeList = NodeData.NodeList
		self.ViewModel:UpdateOnNodeChanged(NodeData.NodeList)
	end
end

function OpsLolitaMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.LolitaGiftCard:SetParams({Data = self.ViewModel})
end


--region 只有OpsLolitaBuyPanel会调用
function OpsLolitaMainPanelView:BuyPanelOnShow()
	--全选按钮取消勾选
	self.CommSingleBox:SetChecked(false)
	self:AllSelectedCallback(nil, _G.UE.EToggleButtonState.UnChecked)

	--选中
	for i = 1, 5 do
		local ItemView = self["LolitaSuitBuy"..i]
		local SuitData = ItemView.SuitData
		if SuitData and SuitData.IsBuy == false then
			ItemView:OnSelectChanged(true)
			break
		end
	end
end

function OpsLolitaMainPanelView:AllSelectedCallback(_, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	for i = 1, 5 do
		self["LolitaSuitBuy"..i]:OnSelectChanged(IsChecked)
	end
end

function OpsLolitaMainPanelView:OnTableViewSelectChanged(UpdateSingleBox)
	local IsAllCheck = true
	local TotalPrice = 0
	local GoodsID = 0
	for i = 1, 5 do
		local ItemView = self["LolitaSuitBuy"..i]
		local SuitData = ItemView.SuitData
		if SuitData and ItemView.bSelected then
			local BuyGoodPrice = SuitData.BuyGoodPrice
			TotalPrice = TotalPrice + BuyGoodPrice
			if GoodsID == 0 then
				GoodsID = SuitData.GoodsID
			end
		else
			IsAllCheck = false
		end
	end
	
	--全选Toggle状态
	if UpdateSingleBox then
		local IsChecked = self.CommSingleBox:GetChecked()
		if IsChecked ~= IsAllCheck then
			self.CommSingleBox:SetChecked(IsAllCheck)
		end
	end

	--价格变化
	local IsRewardStatusNo = self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo
	if IsRewardStatusNo then
		self.BtnBuy:SetBtnPriceByGoodsID(GoodsID, true)
		self.BtnBuy.TextPrice:SetText(TotalPrice)
		self.TotalPrice = TotalPrice
	else
		self.BtnBuy.CommBtnL:SetIsDoneState(true, LSTR(1290003)) --已购买
	end
end

function OpsLolitaMainPanelView:GoToBuy()
	local BatchList = {}
	local TotalPrice = self.TotalPrice
	local PriceDataID = ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS
	local ScoreValue = _G.ScoreMgr:GetScoreValueByID(PriceDataID)
	if ScoreValue < TotalPrice then
		local TempScoreCfg = ScoreCfg:FindCfgByKey(PriceDataID)
		if TempScoreCfg == nil then
			return
		end
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.CommonMsgBox) then
			_G.UIViewMgr:HideView(_G.UIViewID.CommonMsgBox, true)
		end
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			LSTR(950032),	--- "代币不足"
			string.format(LSTR(950034), TempScoreCfg.NameText),	--- "%s不足，是否前往充值？"
			function()
				if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_REBATE, true) then
					-- 打开充值界面
					_G.RechargingMgr:ShowMainPanel()
					_G.RechargingMgr:OnChangedMainPanelCloseBtnToBack(true)
				end
			end,
			nil,
			LSTR(950030),	--- "取消"
			LSTR(950033)	--- "确认"
		)
	else
		for i = 1, 5 do
			local ItemView = self["LolitaSuitBuy"..i]
			local SuitData = ItemView.SuitData
			if SuitData and ItemView.bSelected then
				table.insert(BatchList, {GoodID = SuitData.GoodsID, Num = 1})
			end
		end
		--购买
		_G.StoreMgr:SendMsgMallInfoBatchPruchase(BatchList)
	end
end

function OpsLolitaMainPanelView:OnStoreBatchBuy(MsgBody)
	local MallInfo = MsgBody.BatchPruchase
	local PurchasedIDList = MallInfo.Infos
	_G.StoreMgr:ShowCommonRewardPanel(PurchasedIDList)
end
--endregion

function OpsLolitaMainPanelView:OnOpsLolitaNodeChanged()
	local SuitDataList = self.ViewModel.SuitDataList
	for i = 1, 5 do
		self["LolitaSuitItem".. i]:SetBuyState(SuitDataList)
		self["LolitaSuitBuy".. i]:SetBuyState(SuitDataList)
	end
end

return OpsLolitaMainPanelView