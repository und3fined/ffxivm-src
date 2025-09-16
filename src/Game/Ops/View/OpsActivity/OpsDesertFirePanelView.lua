---
--- Author: Administrator
--- DateTime: 2024-12-26 11:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local OpsDesertFirePanelVM = require("Game/Ops/VM/OpsDesertFirePanelVM")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local SaveKey = require("Define/SaveKey")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local ProtoCS = require("Protocol/ProtoCS")
local RichTextUtil = require("Utils/RichTextUtil")

local SCORE_TYPE = ProtoRes.SCORE_TYPE
local EventID = require("Define/EventID")
---@class OpsDesertFirePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy OpsCommBtnLView
---@field BtnFullScreen UFButton
---@field BtnStrategy UFButton
---@field IconMoney UFImage
---@field IconShare UFImage
---@field ImgVideo UFImage
---@field Money CommMoneySlotView
---@field OpsActivityPreviewBtn_UIBP OpsActivityPreviewBtnView
---@field PanelBuy UFCanvasPanel
---@field PanelMoney UFHorizontalBox
---@field PanelShare UFCanvasPanel
---@field PanelStrategy UFCanvasPanel
---@field PanelTag UFCanvasPanel
---@field RichText URichTextBox
---@field ShareTips OpsActivityShareTipsItemView
---@field TextPrice UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTag UFTextBlock
---@field TextTilte UFTextBlock
---@field Time OpsActivityTimeItemView
---@field ToggleBtnPlay UToggleButton
---@field ToggleBtnSound UToggleButton
---@field UMGVideoPlayer UMGVideoPlayerView
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsDesertFirePanelView = LuaClass(UIView, true)

function OpsDesertFirePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnFullScreen = nil
	--self.BtnStrategy = nil
	--self.IconMoney = nil
	--self.IconShare = nil
	--self.ImgVideo = nil
	--self.Money = nil
	--self.OpsActivityPreviewBtn_UIBP = nil
	--self.PanelBuy = nil
	--self.PanelMoney = nil
	--self.PanelShare = nil
	--self.PanelStrategy = nil
	--self.PanelTag = nil
	--self.RichText = nil
	--self.ShareTips = nil
	--self.TextPrice = nil
	--self.TextSubTitle = nil
	--self.TextTag = nil
	--self.TextTilte = nil
	--self.Time = nil
	--self.ToggleBtnPlay = nil
	--self.ToggleBtnSound = nil
	--self.UMGVideoPlayer = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsDesertFirePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.Money)
	self:AddSubView(self.OpsActivityPreviewBtn_UIBP)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	self:AddSubView(self.UMGVideoPlayer)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsDesertFirePanelView:OnInit()
	self.ViewModel = OpsDesertFirePanelVM.New()
	self.Binders = {
        {"TitleText", UIBinderSetText.New(self, self.TextTilte)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextSubTitle)},
		{"PlayState", UIBinderSetCheckedState.New(self, self.ToggleBtnPlay)},
		{"SoundState", UIBinderSetCheckedState.New(self, self.ToggleBtnSound)},
		{"ShareOrStrategyIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconShare)},
		{"ShareOrStrategyText", UIBinderSetText.New(self, self.RichText)},
		{"BuyActionVisible", UIBinderSetIsVisible.New(self, self.PanelShare)},
		{"BuyActionVisible", UIBinderSetIsVisible.New(self, self.PanelBuy)},
		{"DiscountMoneyVisible", UIBinderSetIsVisible.New(self, self.PanelMoney)},
		{"DiscountedText", UIBinderSetTextFormatForMoney.New(self, self.TextPrice)},
		{"BuyTagText", UIBinderSetText.New(self, self.TextTag)},
		{"BuyTagVisible", UIBinderSetIsVisible.New(self, self.PanelTag)},
    }

	UIUtil.SetIsVisible(self.UMGVideoPlayer, false)
	self.UMGVideoPlayer:HideAllUI()

end

function OpsDesertFirePanelView:OnDestroy()

end

function OpsDesertFirePanelView:OnShow()
	self.Money:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, nil, true)
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end

	self:UpdateUI()

	self.UMGVideoPlayer:SetVideoPath(self.ViewModel.VideoPlayerPath)
	self.UMGVideoPlayer:SetPlayMovieEndCallBack(self, self.PlayMovieEnd)
	self.UMGVideoPlayer:SetVolume(self.ViewModel:BSoundChecked())
	UIUtil.SetIsVisible(self.UMGVideoPlayer.CloseButton, false)
	UIUtil.SetIsVisible(self.UMGVideoPlayer, true)
	self.UMGVideoPlayer:OnRewind()

	--[[local OpsDesertFirePrompt = _G.UE.USaveMgr.GetInt(SaveKey.OpsDesertFirePrompt, 0, true) or 0
	if OpsDesertFirePrompt == 0 and self.ViewModel.ShareBuyData and self.ViewModel.ShareBuyData.Status == ProtoCS.Game.Activity.enStatus.None then
		UIViewMgr:ShowView(UIViewID.OpsDesertFinePanelPlanWin,{ShareBuyNodeID = self.ViewModel.ShareBuyNodeCfg.NodeID})
		_G.UE.USaveMgr.SetInt(SaveKey.OpsDesertFirePrompt, 1, true)
	end]]--

	if self.ViewModel.ShareBuyNodeCfg then
		self.OpsActivityPreviewBtn_UIBP:SetTitleText(self.ViewModel.ShareBuyNodeCfg.JumpButton)
		self.OpsActivityPreviewBtn_UIBP:SetSubTitleText()
	end
	self.UMGVideoPlayer:SetNoUIMode(true)
	self.UMGVideoPlayer:SetPreviewMode(true)
end



function OpsDesertFirePanelView:UpdateUI(MsgBody)
	self.ViewModel:Update(self.Params)
	self.BtnBuy:SetDisplayContent(self.ViewModel.BuyText, self.ViewModel.BuyPriceText, self.ViewModel.BuyPriceVisible)

	if MsgBody and MsgBody.NodeOperate then
		if MsgBody.NodeOperate.OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypeShareBuyPurchase then
			if self.ViewModel.ShareBuyData == nil or self.ViewModel.ShareBuyNodeCfg == nil then
				return
			end
			local Params = {}
			Params.ItemList = {}
			local Rewards = self.ViewModel.ShareBuyNodeCfg.Rewards
			if Rewards then
				for i = 1, #Rewards do
					if Rewards[i].ItemID > 0 and Rewards[i].Num > 0  then
						table.insert(Params.ItemList, { ResID = Rewards[i].ItemID, Num = Rewards[i].Num})
					end
				end
			end
			   
			if #Params.ItemList > 0 then
				_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
		
			end
		elseif MsgBody.NodeOperate.OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypeShardBuyInput then
			_G.MsgTipsUtil.ShowTipsByID(342017)
			UIViewMgr:HideView(UIViewID.OpsDesertFinePanelPlanWin)
			self:OnClickedBuy()
		end
		
	end

	
end

function OpsDesertFirePanelView:PlayMovieEnd()
	self.UMGVideoPlayer:OnResume()
end

function OpsDesertFirePanelView:OnHide()
	self.UMGVideoPlayer:OnClose()
end

function OpsDesertFirePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnPlay, self.OnClickedPlay)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnSound, self.OnClickedSound)
	UIUtil.AddOnClickedEvent(self, self.BtnFullScreen, self.OnClickedFullScreen)

	UIUtil.AddOnClickedEvent(self, self.BtnStrategy, self.OnClickShareOrStrategyBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickedBuy)
	UIUtil.AddOnClickedEvent(self, self.OpsActivityPreviewBtn_UIBP.BtnView, self.OnClickedPreviewBtn)
end

function OpsDesertFirePanelView:OnClickedPlay()
	self.ViewModel:UpdatePlayState()
	if self.ViewModel:BPlayChecked() then
		self.UMGVideoPlayer:OnPause()
	else
		self.UMGVideoPlayer:OnResume()
	end
end

function OpsDesertFirePanelView:OnClickedSound()
	self.ViewModel:UpdateSoundState()
	self.UMGVideoPlayer:SetVolume(self.ViewModel:BSoundChecked())
end

function OpsDesertFirePanelView:OnClickedFullScreen()
	UIViewMgr:ShowView(UIViewID.CommonVideoPlayerView, {VideoPath = self.ViewModel.VideoPlayerPath, SeekValue = self.UMGVideoPlayer:GetSeekValue(), HideCallBack = 
	function ()
		self:PlayMovieEnd()
	end
	})
end

function OpsDesertFirePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdateUI)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateUI)

	self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
	self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function OpsDesertFirePanelView:OnGameEventAppEnterBackground(Params)
	FLOG_INFO("OpsDesertFirePanelView:OnGameEventAppEnterBackground")
	self.UMGVideoPlayer:OnPause()
end

function OpsDesertFirePanelView:OnGameEventAppEnterForeground(Params)
	FLOG_INFO("OpsDesertFirePanelView:OnGameEventAppEnterForeground")
	if self.ViewModel:BPlayChecked() then
		self.UMGVideoPlayer:OnPause()
	else
		self.UMGVideoPlayer:OnResume()
	end
end

function OpsDesertFirePanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsDesertFirePanelView:OnClickShareOrStrategyBtn()
	if self.ViewModel == nil then
		return
	end

	if self.ViewModel.ShareBuyData == nil or self.ViewModel.ShareBuyNodeCfg == nil then
		return
	end
	local Status = self.ViewModel.ShareBuyData.Status
	if Status == ProtoCS.Game.Activity.enStatus.None then
		UIViewMgr:ShowView(UIViewID.OpsDesertFinePanelPlanWin, {ShareBuyNodeID = self.ViewModel.ShareBuyNodeCfg.NodeID})
	elseif Status == ProtoCS.Game.Activity.enStatus.OriginalPayed then
		--分享优惠码
		UIViewMgr:ShowView(UIViewID.OpsDesertFineShareCodeWin, {ActivityID = self.Params.ActivityID})
	elseif Status == ProtoCS.Game.Activity.enStatus.CodeInputed then
		--未购买-优惠
		UIViewMgr:ShowView(UIViewID.OpsDesertFinePanelPlanWin,{Mask = true, CouponCode = self.ViewModel.ShareBuyData.CouponCode})
	end

end
	
function OpsDesertFirePanelView:OnClickedBuy()
	if self.ViewModel == nil then
		return
	end

	if self.ViewModel.ShareBuyData == nil or self.ViewModel.ShareBuyNodeCfg == nil then
		return
	end
	local Status = self.ViewModel.ShareBuyData.Status
	if Status == ProtoCS.Game.Activity.enStatus.None then
		_G.StoreMgr:OpenExternalPurchaseInterface(self.ViewModel.ShareBuyNodeCfg.Params[4], {BuyPrice = self.ViewModel.ShareBuyNodeCfg.Params[1], 
		ScoreID = SCORE_TYPE.SCORE_TYPE_STAMPS,
		ClickedBuyCallBack = function()
			self:BuyShopItem()
			            end})
	elseif Status == ProtoCS.Game.Activity.enStatus.CodeInputed then
		local CouponCodeRitchText = RichTextUtil.GetText(string.format("%s", self.ViewModel.ShareBuyData.CouponCode or ""), "d1ba81", 0, nil)
		_G.StoreMgr:OpenExternalPurchaseInterface(self.ViewModel.ShareBuyNodeCfg.Params[4], {BuyPrice = self.ViewModel.ShareBuyNodeCfg.Params[2], 
		ScoreID = SCORE_TYPE.SCORE_TYPE_STAMPS,
		OriginalPrice = self.ViewModel.ShareBuyNodeCfg.Params[1],
		ShopDesc = string.format("%s%s\n%s", _G.LSTR(1470023), CouponCodeRitchText, _G.LSTR(1470024)),
		ClickedBuyCallBack = function()
			self:BuyShopItem()
			            end})
	elseif Status == ProtoCS.Game.Activity.enStatus.OriginalPayed then
		UIViewMgr:ShowView(UIViewID.OpsDesertFineRebateTaskWin, self.Params)
	end

end

function OpsDesertFirePanelView:BuyShopItem()
	if self.ViewModel == nil then
		return
	end

	if self.ViewModel.ShareBuyNodeCfg == nil then
		return
	end

	local Status = self.ViewModel.ShareBuyData.Status
	local ScoreValue = _G.ScoreMgr:GetScoreValueByID(SCORE_TYPE.SCORE_TYPE_STAMPS)
	if Status == ProtoCS.Game.Activity.enStatus.None then
		local BuyPrice = self.ViewModel.ShareBuyNodeCfg.Params[1]
		if BuyPrice > ScoreValue then
			local CostName = _G.ScoreMgr:GetScoreNameText(SCORE_TYPE.SCORE_TYPE_STAMPS) or ""
			_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(990038), CostName))
			return
		end
	elseif Status == ProtoCS.Game.Activity.enStatus.CodeInputed then
		local BuyPrice = self.ViewModel.ShareBuyNodeCfg.Params[2]
		if BuyPrice > ScoreValue then
			local CostName = _G.ScoreMgr:GetScoreNameText(SCORE_TYPE.SCORE_TYPE_STAMPS) or ""
			_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(990038), CostName))
			return
		end
	end


	local Data = {}
	_G.OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.ShareBuyNodeCfg.NodeID, ProtoCS.Game.Activity.NodeOpType.NodeOpTypeShareBuyPurchase,
		{ShareBuyPurchase = Data})
end

-- 点击预览按钮
function OpsDesertFirePanelView:OnClickedPreviewBtn()
	if self.ViewModel == nil then return end
	if self.ViewModel.ShareBuyNodeCfg == nil then
		return
	end
	if self.ViewModel.ShareBuyNodeCfg.JumpParam then
		_G.OpsActivityMgr:Jump(self.ViewModel.ShareBuyNodeCfg.JumpType, self.ViewModel.ShareBuyNodeCfg.JumpParam)
	end
end


return OpsDesertFirePanelView