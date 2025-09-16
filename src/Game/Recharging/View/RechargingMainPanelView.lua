---
--- Author: zimuyi
--- DateTime: 2024-01-22 10:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
-- local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CommonUtil = require("Utils/CommonUtil")
local ProtoRes = require("Protocol/ProtoRes")
-- local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local SaveKey = require("Define/SaveKey")

local RechargingDefine = require("Game/Recharging/RechargingDefine")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local RechargingMainVM = require("Game/Recharging/VM/RechargingMainVM")

local OperationUtil = require("Utils/OperationUtil")

local USaveMgr = _G.UE.USaveMgr
local FLOG_INFO = _G.FLOG_INFO

local StallCount = 6 -- 充值档位数量
local ShopkeeperRestTime = 60 -- 待机状态休闲动作时间间隔

---@class RechargingMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnConsult UFButton
---@field BtnGiftEntry UFButton
---@field BtnGiftEntry1 UFButton
---@field BtnHelp CommInforBtnView
---@field ButtonClose CommonCloseBtnView
---@field CrystalSlot CommMoneySlotView
---@field DebugPoint UFButton
---@field FCanvasPanel UFCanvasPanel
---@field FCanvasPanel_29 UFCanvasPanel
---@field HorizontalMessage UFHorizontalBox
---@field HorizontalTitle UFHorizontalBox
---@field ModelToImage CommonModelToImageView
---@field PanelGif UFCanvasPanel
---@field PanelGif1 UFCanvasPanel
---@field PanelRechargeGift UFCanvasPanel
---@field PanelRechargeGift1 UFCanvasPanel
---@field PanelTataru UFCanvasPanel
---@field RichTextMessage URichTextBox
---@field TableViewList UTableView
---@field TextGiftEntry UFTextBlock
---@field TextGiftEntry1 UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimHelpHide UWidgetAnimation
---@field AnimHelpShow UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOutBackUp UWidgetAnimation
---@field AnimRawIn UWidgetAnimation
---@field AnimRawReturn UWidgetAnimation
---@field AnimTataruIn UWidgetAnimation
---@field AnimTataruReturn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingMainPanelView = LuaClass(UIView, true)

function RechargingMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnConsult = nil
	--self.BtnGiftEntry = nil
	--self.BtnGiftEntry1 = nil
	--self.BtnHelp = nil
	--self.ButtonClose = nil
	--self.CrystalSlot = nil
	--self.DebugPoint = nil
	--self.FCanvasPanel = nil
	--self.FCanvasPanel_29 = nil
	--self.HorizontalMessage = nil
	--self.HorizontalTitle = nil
	--self.ModelToImage = nil
	--self.PanelGif = nil
	--self.PanelGif1 = nil
	--self.PanelRechargeGift = nil
	--self.PanelRechargeGift1 = nil
	--self.PanelTataru = nil
	--self.RichTextMessage = nil
	--self.TableViewList = nil
	--self.TextGiftEntry = nil
	--self.TextGiftEntry1 = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.AnimHelpHide = nil
	--self.AnimHelpShow = nil
	--self.AnimLoop = nil
	--self.AnimOutBackUp = nil
	--self.AnimRawIn = nil
	--self.AnimRawReturn = nil
	--self.AnimTataruIn = nil
	--self.AnimTataruReturn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.ButtonClose)
	self:AddSubView(self.CrystalSlot)
	self:AddSubView(self.ModelToImage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingMainPanelView:OnInit()
	self.ShopkeeperRestTimerHandle = nil
	self.DefaultCameraLocation = nil
	self.bShowCharacter = false
	self.DoRechargeOnce = false
	local PlatformName = CommonUtil.GetPlatformName()
	self.HasHelp = PlatformName == "IOS" or PlatformName == "Windows"
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	self.Binders = {
		{ "TradeItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "RewardState", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStateChanged) },
		{ "bIsRewardIcon", UIBinderSetIsVisible.New(self, self.PanelGif) },
		{ "bIsRewardIcon", UIBinderSetIsVisible.New(self, self.PanelGif1) },
		-- { "bIsRewardTips", UIBinderSetIsVisible.New(self, self.HorizontalMessage) },
		{ "bShowRewardPage", UIBinderValueChangedCallback.New(self, nil, self.OnShowRewardPageChanged) },
		{ "RewardTips", UIBinderSetText.New(self, self.RichTextMessage) },
		{ "RechargedStall", UIBinderValueChangedCallback.New(self, nil, self.OnStallRecharged) },
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "TextSubtitle", UIBinderSetText.New(self, self.TextSubtitle) },
		{ "TextGiftEntry", UIBinderSetText.New(self, self.TextGiftEntry) },
		{ "TextGiftEntry", UIBinderSetText.New(self, self.TextGiftEntry1) },
	}
end

function RechargingMainPanelView:OnDestroy()

end

function RechargingMainPanelView:OnShow()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_REBATE, true) then
		UIUtil.SetIsVisible(self.FCanvasPanel, false)
		_G.FLOG_ERROR("Recharging system is not opened yet.")
		return
	else
		UIUtil.SetIsVisible(self.FCanvasPanel, true)
	end

	-- 是否显示帮助
	if not self.HasHelp then
		-- UIUtil.SetIsVisible(self.BorderHelpTips, false, false, false)
		UIUtil.SetIsVisible(self.BtnHelp, false, false, false)
	end

	-- 是否显示看板娘
	self.bShowCharacter = RechargingMgr:ShouldShowShopkeeper()
	if self.bShowCharacter then
		FLOG_INFO(string.format("Quest %d is already finished", RechargingMgr:GetCharacterShowQuestID()))
	else
		FLOG_INFO(string.format("Quest %d is not finished", RechargingMgr:GetCharacterShowQuestID()))
	end
	UIUtil.SetIsVisible(self.PanelRechargeGift, not self.bShowCharacter)
	UIUtil.SetIsVisible(self.PanelRechargeGift1, self.bShowCharacter)
	if self.bShowCharacter then
		-- 开启休息定时器
		self:ResetShopkeeperRestTimer()
	end

	-- 入场动效
	local bFromGift = false
	if nil ~= self.Params then
		bFromGift = self.Params.bFromGift
	end

	local Animation = nil
	if bFromGift == true then
		Animation = self.bShowCharacter and self.AnimTataruReturn or self.AnimRawReturn
		self:StopAnimation(self.AnimOutBackUp)
		self:UnRegisterTimer(self.AnimOutTimerHandle)
	else
		Animation = self.bShowCharacter and self.AnimTataruIn or self.AnimRawIn
	end
	self:PlayAnimation(Animation)

	-- 充值档位
	self:GenerateCommodities()
	
	-- 充值数据查询与更新
	RechargingMgr:OnMainPanelShow()
	self.CrystalSlot:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS, false, nil, true)

	if nil ~= OperationUtil.IsEnableCustomService and not OperationUtil.IsEnableCustomService() then
		UIUtil.SetIsVisible(self.BtnConsult, false)
	end
end

function RechargingMainPanelView:OnHide()
	if self.HasHelp then
		-- 关闭帮助提示
		self:PlayAnimation(self.AnimHelpHide)
		self.Interacted = false
	end
end

function RechargingMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGiftEntry, self.OnGiftEntryClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnGiftEntry1, self.OnGiftEntryClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnConsult, self.OnServiceClicked)
	if self.HasHelp then
		UIUtil.AddOnClickedEvent(self, self.BtnHelp.BtnInfor, self.OnHelpClicked)
	end
	self.ButtonClose:SetCallback(self, self.OnCloseClicked)
end

function RechargingMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RechargeShopkeeperPlayAction, self.OnShopkeeperPlayAction)

	if self.HasHelp then
		self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnInteracted)
	end
end

function RechargingMainPanelView:OnRegisterBinder()
	self:RegisterBinders(RechargingMainVM, self.Binders)
end

function RechargingMainPanelView:OnRegisterTimer()
	-- 每经过24小时，进入充值页面延迟5秒无交互，显示帮助提示
	if self.HasHelp then
		local LastInteractionTime = USaveMgr.GetInt(SaveKey.RechargingInteractionTime, 0, false)
		if TimeUtil.GetLocalTime() - LastInteractionTime > RechargingDefine.HelpTipsShowInterval then
			self:RegisterTimer(self.OnTimerCheckInteraction, 5, 0, 1)
		end
	end
end

function RechargingMainPanelView:OnShopkeeperPlayAction()
	self:ResetShopkeeperRestTimer()
end

function RechargingMainPanelView:OnInteracted(MouseEvent)
	self.Interacted = true
end

function RechargingMainPanelView:OnTimerCheckInteraction()
	if not self.Interacted then
		self:PlayAnimation(self.AnimHelpShow)
		USaveMgr.SetInt(SaveKey.RechargingInteractionTime, TimeUtil.GetLocalTime(), false)
	end
end

function RechargingMainPanelView:GenerateCommodities()
	RechargingMainVM:GenerateCommodities(StallCount)
end

function RechargingMainPanelView:OnGiftEntryClicked()
	RechargingMgr:ShowGiftPanel()
	if self.bShowCharacter then
		RechargingMgr:PlayAnimation(RechargingMgr:GetCharacterTransitionAction())
		self:StopShopkeeperRestTimer()
	end
	self:PlayAnimation(self.AnimOutBackUp)
	self.AnimOutTimerHandle = self:RegisterTimer(function() self:Hide() end, self.AnimOutBackUp:GetEndTime())
end

function RechargingMainPanelView:OnRewardStateChanged(NewState)
	if NewState == RechargingDefine.RewardState.Ready then
		self:PlayAnimation(self.AnimGiftShow)
	else
		self:PlayAnimation(self.AnimGiftHide)
	end
end

function RechargingMainPanelView:OnShowRewardPageChanged(NewValue, OldValue)
	
end

function RechargingMainPanelView:OnServiceClicked()
	--RechargingMgr:OnServiceClicked()
	OperationUtil.OpenCustomService(OperationUtil.CustomServiceSceneID.Recharge)
end

function RechargingMainPanelView:OnHelpClicked()
	self:PlayAnimation(self.AnimHelpHide)
	RechargingMgr:OnHelpClicked()
end

function RechargingMainPanelView:OnCloseClicked()
	RechargingMgr:CloseMainPanel()
end

function RechargingMainPanelView:OnStallRecharged(NewValue, OldValue)
	if nil == OldValue and self.DoRechargeOnce then
		return
	end
	if NewValue == 0 then
		return
	end
	self.DoRechargeOnce = true
	local AnimStr = string.format("AnimGet%d", NewValue)
	self:PlayAnimation(self[AnimStr])
end

function RechargingMainPanelView:ResetShopkeeperRestTimer()
	if nil ~= self.ShopkeeperRestTimerHandle then
		self:UnRegisterTimer(self.ShopkeeperRestTimerHandle)
	end
	self.ShopkeeperRestTimerHandle = self:RegisterTimer(
		function() RechargingMgr:PlayActionTimeline(RechargingMgr:GetCharacterRestActionID()) end, ShopkeeperRestTime)
end

function RechargingMainPanelView:StopShopkeeperRestTimer()
	if nil ~= self.ShopkeeperRestTimerHandle then
		self:UnRegisterTimer(self.ShopkeeperRestTimerHandle)
	end
end

return RechargingMainPanelView