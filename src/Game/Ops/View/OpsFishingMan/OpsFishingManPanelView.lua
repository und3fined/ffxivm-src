---
--- Author: Administrator
--- DateTime: 2025-07-22 16:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local OpsFishingManPanelVM = require("Game/Ops/VM/OpsFishingMan/OpsFishingManPanelVM")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local ProtoCS = require("Protocol/ProtoCS")
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local EventID = require("Define/EventID")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemCfg = require("TableCfg/ItemCfg")

---@class OpsFishingManPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy OpsCommBtnLView
---@field BtnFullScreen UFButton
---@field BtnStrategy UFButton
---@field IconMoney UFImage
---@field IconShare UFImage
---@field ImgVideo UFImage
---@field OpsActivityPreviewBtn OpsActivityPreviewBtnView
---@field OpsMoneySlot OpsCommMoneySlotView
---@field PanelBuy UFCanvasPanel
---@field PanelMoney UFHorizontalBox
---@field PanelShare UFCanvasPanel
---@field PanelStrategy UFCanvasPanel
---@field RichText URichTextBox
---@field ShareTips OpsActivityShareTipsItemView
---@field TextExclusive UFTextBlock
---@field TextPrice UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTilte UFTextBlock
---@field Time OpsActivityTimeItemView
---@field ToggleBtnPlay UToggleButton
---@field ToggleBtnSound UToggleButton
---@field UMGVideoPlayer UMGVideoPlayerView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsFishingManPanelView = LuaClass(UIView, true)

function OpsFishingManPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnFullScreen = nil
	--self.BtnStrategy = nil
	--self.IconMoney = nil
	--self.IconShare = nil
	--self.ImgVideo = nil
	--self.OpsActivityPreviewBtn = nil
	--self.OpsMoneySlot = nil
	--self.PanelBuy = nil
	--self.PanelMoney = nil
	--self.PanelShare = nil
	--self.PanelStrategy = nil
	--self.RichText = nil
	--self.ShareTips = nil
	--self.TextExclusive = nil
	--self.TextPrice = nil
	--self.TextSubTitle = nil
	--self.TextTilte = nil
	--self.Time = nil
	--self.ToggleBtnPlay = nil
	--self.ToggleBtnSound = nil
	--self.UMGVideoPlayer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsFishingManPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.OpsActivityPreviewBtn)
	self:AddSubView(self.OpsMoneySlot)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	self:AddSubView(self.UMGVideoPlayer)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsFishingManPanelView:OnInit()
	self.ViewModel = OpsFishingManPanelVM.New()
	self.Binders = {
        {"TitleText", UIBinderSetText.New(self, self.TextTilte)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextSubTitle)},
		{"PlayState", UIBinderSetCheckedState.New(self, self.ToggleBtnPlay)},
		{"SoundState", UIBinderSetCheckedState.New(self, self.ToggleBtnSound)},
		{"ShareOrStrategyIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconShare)},
		{"ShareOrStrategyText", UIBinderSetText.New(self, self.RichText)},
		{"BuyActionVisible", UIBinderSetIsVisible.New(self, self.PanelShare)},
		--{"BuyActionVisible", UIBinderSetIsVisible.New(self, self.PanelBuy)},
		{"DiscountMoneyVisible", UIBinderSetIsVisible.New(self, self.PanelMoney)},
		{"DiscountedText", UIBinderSetTextFormatForMoney.New(self, self.TextPrice)},
		--{"BuyTagText", UIBinderSetText.New(self, self.TextTag)},
		--{"BuyTagVisible", UIBinderSetIsVisible.New(self, self.PanelTag)},
    }

	UIUtil.SetIsVisible(self.UMGVideoPlayer, false)
	self.UMGVideoPlayer:HideAllUI()
end

function OpsFishingManPanelView:OnDestroy()

end

function OpsFishingManPanelView:OnShow()
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
	UIUtil.SetIsVisible(self.UMGVideoPlayer, true)
	UIUtil.SetIsVisible(self.UMGVideoPlayer.CloseButton, false)
	self.UMGVideoPlayer:OnRewind()

	if self.ViewModel.ShareBuyNodeCfg then
		self.TextExclusive:SetText(self.ViewModel.ShareBuyNodeCfg.JumpButton)
		self.OpsActivityPreviewBtn:SetTitleText(_G.LSTR(1470027))
		self.OpsActivityPreviewBtn:SetSubTitleText()
	end
	self.UMGVideoPlayer:SetNoUIMode(true)
	self.UMGVideoPlayer:SetPreviewMode(true)

	self.BtnBuy.RedDot:SetRedDotNameByString(_G.OpsActivityMgr:GetRedDotName(self.Params.Activity.ClassifyID, self.Params.ActivityID, "Reward"))
end

function OpsFishingManPanelView:UpdateUI(MsgBody)
	self.ViewModel:Update(self.Params)
	self.BtnBuy:SetDisplayContent(self.ViewModel.BuyText, self.ViewModel.BuyPriceText, self.ViewModel.BuyPriceVisible, self.ViewModel.BuyTagText, self.ViewModel.Discount)

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

function OpsFishingManPanelView:PlayMovieEnd()
	self.UMGVideoPlayer:OnResume()
end


function OpsFishingManPanelView:OnHide()
	self.UMGVideoPlayer:OnClose()
end

function OpsFishingManPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnPlay, self.OnClickedPlay)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnSound, self.OnClickedSound)
	UIUtil.AddOnClickedEvent(self, self.BtnFullScreen, self.OnClickedFullScreen)

	UIUtil.AddOnClickedEvent(self, self.BtnStrategy, self.OnClickShareOrStrategyBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.OnClickedBuy)
	UIUtil.AddOnClickedEvent(self, self.OpsActivityPreviewBtn.BtnView, self.OnClickedPreviewBtn)
end

function OpsFishingManPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdateUI)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateUI)

	self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
	self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function OpsFishingManPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsFishingManPanelView:OnGameEventAppEnterBackground(Params)
	FLOG_INFO("OpsDesertFirePanelView:OnGameEventAppEnterBackground")
	self.UMGVideoPlayer:OnPause()
end

function OpsFishingManPanelView:OnGameEventAppEnterForeground(Params)
	FLOG_INFO("OpsDesertFirePanelView:OnGameEventAppEnterForeground")
	if self.ViewModel:BPlayChecked() then
		self.UMGVideoPlayer:OnPause()
	else
		self.UMGVideoPlayer:OnResume()
	end
end

function OpsFishingManPanelView:OnClickedPlay()
	self.ViewModel:UpdatePlayState()
	if self.ViewModel:BPlayChecked() then
		self.UMGVideoPlayer:OnPause()
	else
		self.UMGVideoPlayer:OnResume()
	end
end

function OpsFishingManPanelView:OnClickedSound()
	self.ViewModel:UpdateSoundState()
	self.UMGVideoPlayer:SetVolume(self.ViewModel:BSoundChecked())
end

function OpsFishingManPanelView:OnClickedFullScreen()
	UIViewMgr:ShowView(UIViewID.CommonVideoPlayerView, {VideoPath = self.ViewModel.VideoPlayerPath, SeekValue = self.UMGVideoPlayer:GetSeekValue(), HideCallBack = 
	function ()
		self:PlayMovieEnd()
	end
	})
end

function OpsFishingManPanelView:OnClickShareOrStrategyBtn()
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
	
function OpsFishingManPanelView:OnClickedBuy()
	if self.ViewModel == nil then
		return
	end

	if self.ViewModel.ShareBuyData == nil or self.ViewModel.ShareBuyNodeCfg == nil then
		return
	end
	local Status = self.ViewModel.ShareBuyData.Status
	if Status == ProtoCS.Game.Activity.enStatus.None then
		_G.StoreMgr:OpenExternalPurchaseInterfaceByNewUIBP(self.ViewModel.ShareBuyNodeCfg.Params[4], {BuyPrice = self.ViewModel.ShareBuyNodeCfg.Params[1], 
		ScoreID = SCORE_TYPE.SCORE_TYPE_STAMPS,
		ClickedBuyCallBack = function()
			self:BuyShopItem()
			            end})
	elseif Status == ProtoCS.Game.Activity.enStatus.CodeInputed then
		local CouponCodeRitchText = RichTextUtil.GetText(string.format("%s", self.ViewModel.ShareBuyData.CouponCode or ""), "d1ba81")
		_G.StoreMgr:OpenExternalPurchaseInterfaceByNewUIBP(self.ViewModel.ShareBuyNodeCfg.Params[4], {BuyPrice = self.ViewModel.ShareBuyNodeCfg.Params[2], 
		ScoreID = SCORE_TYPE.SCORE_TYPE_STAMPS,
		OriginalPrice = self.ViewModel.ShareBuyNodeCfg.Params[1],
		ShopDesc = string.format("%s%s\n%s", _G.LSTR(1470023), CouponCodeRitchText, _G.LSTR(1470024)),
		ClickedBuyCallBack = function()
			self:BuyShopItem()
			            end})
	elseif Status == ProtoCS.Game.Activity.enStatus.OriginalPayed then
		UIViewMgr:ShowView(UIViewID.OpsDesertFineRebateTaskWin, self.Params)

	elseif Status == ProtoCS.Game.Activity.enStatus.DiscountPayed then
    	if _G.PWorldMgr:CurrIsInDungeon() then
			_G.MsgTipsUtil.ShowTips(_G.LSTR(1470032))
        	return
    	end

		local DataList = {}
		local Rewards = self.ViewModel.ShareBuyNodeCfg.Rewards
		if Rewards then
			for i = 1, #Rewards do
				if Rewards[i].ItemID > 0 and Rewards[i].Num > 0  then
					local Cfg = ItemCfg:FindCfgByKey(Rewards[i].ItemID)
					if Cfg and Cfg.EquipmentID > 0 then
						local TempEquipmentCfg = EquipmentCfg:FindCfgByEquipID(Cfg.EquipmentID)
						if TempEquipmentCfg and TempEquipmentCfg.AppearanceID > 0 then
							table.insert(DataList, {AppearanceID = TempEquipmentCfg.AppearanceID })
						end
					end
				end
			end
		end

		local SuitID = 0
		local Cfgs = ClosetSuitCfg:FindAllCfg(string.format("TabIndex = 2 or TabIndex == 3"))
		local requiredItems = {}
		for _, v in ipairs(DataList) do
			if v.AppearanceID then
				local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(v.AppearanceID)
				requiredItems[EquipID] = true
			end
		end
			
		for _, v in ipairs(Cfgs) do
			if v.AppItems and next(v.AppItems) then
				local TempSuitID = _G.WardrobeMgr:FindMatchingSuitID(v, requiredItems)
				if TempSuitID ~= 0 then
					SuitID = TempSuitID
					break
				end
			end
		end
		UIViewMgr:ShowView(UIViewID.WardrobeMainPanel, {SuitID = SuitID})
	end

end

function OpsFishingManPanelView:BuyShopItem()
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
function OpsFishingManPanelView:OnClickedPreviewBtn()
	if self.ViewModel == nil then return end
	if self.ViewModel.ShareBuyNodeCfg == nil then
		return
	end
	if self.ViewModel.ShareBuyNodeCfg.JumpParam then
		_G.OpsActivityMgr:Jump(self.ViewModel.ShareBuyNodeCfg.JumpType, self.ViewModel.ShareBuyNodeCfg.JumpParam)
	end
end

return OpsFishingManPanelView