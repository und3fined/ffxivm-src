---
--- Author: alex
--- DateTime: 2024-01-08 14:30
--- Description:金碟主界面侧边窗
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoRes =  require("Protocol/ProtoRes")
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local ScoreType = ProtoRes.SCORE_TYPE
local UIBinderSetText = require(("Binder/UIBinderSetText"))
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
--local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local LocalizationUtil = require("Utils/LocalizationUtil")
local GoldSauserMainPanelExplainWinVM
local DateTimeTools = require("Common/DateTimeTools")
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr
local LSTR = _G.LSTR
local UE = _G.UE
local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary

---@class GoldSauserMainPanelExplainWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGetReward UFButton
---@field BtnNoramlM1 UFButton
---@field BtnNoramlM2 UFButton
---@field BtnRecomL UFButton
---@field BtnRecomM1 UFButton
---@field BtnRecomM2 UFButton
---@field BtnRecomXS UFButton
---@field ButtonClose UFButton
---@field CommSlot CommBackpack74SlotView
---@field IconHint UFImage
---@field IconTobeViewed UFImage
---@field MaskButton UFButton
---@field PanelBenRecomM UFCanvasPanel
---@field PanelBenRecomXS UFCanvasPanel
---@field PanelBtn UFWidgetSwitcher
---@field PanelCompleted UFCanvasPanel
---@field PanelDare UFCanvasPanel
---@field PanelGameInfo UFCanvasPanel
---@field PanelLock UFHorizontalBox
---@field PanelTopInfo UFCanvasPanel
---@field RichTextInfo URichTextBox
---@field SizeBoxIcon USizeBox
---@field TableViewTask UTableView
---@field TextBtnL UFTextBlock
---@field TextBtnNoralM1 UFTextBlock
---@field TextBtnNoralM2 UFTextBlock
---@field TextBtnRecomM1 UFTextBlock
---@field TextBtnRecomM2 UFTextBlock
---@field TextBureau UFTextBlock
---@field TextCompletedHint UFTextBlock
---@field TextHine UFTextBlock
---@field TextIntegral UFTextBlock
---@field TextLock UFTextBlock
---@field TextTargetQuantity UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimClose UWidgetAnimation
---@field AnimOpen UWidgetAnimation
---@field NewVar_0 bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelExplainWinView = LuaClass(UIView, true)

function GoldSauserMainPanelExplainWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGetReward = nil
	--self.BtnNoramlM1 = nil
	--self.BtnNoramlM2 = nil
	--self.BtnRecomL = nil
	--self.BtnRecomM1 = nil
	--self.BtnRecomM2 = nil
	--self.BtnRecomXS = nil
	--self.ButtonClose = nil
	--self.CommSlot = nil
	--self.IconHint = nil
	--self.IconTobeViewed = nil
	--self.MaskButton = nil
	--self.PanelBenRecomM = nil
	--self.PanelBenRecomXS = nil
	--self.PanelBtn = nil
	--self.PanelCompleted = nil
	--self.PanelDare = nil
	--self.PanelGameInfo = nil
	--self.PanelLock = nil
	--self.PanelTopInfo = nil
	--self.RichTextInfo = nil
	--self.SizeBoxIcon = nil
	--self.TableViewTask = nil
	--self.TextBtnL = nil
	--self.TextBtnNoralM1 = nil
	--self.TextBtnNoralM2 = nil
	--self.TextBtnRecomM1 = nil
	--self.TextBtnRecomM2 = nil
	--self.TextBureau = nil
	--self.TextCompletedHint = nil
	--self.TextHine = nil
	--self.TextIntegral = nil
	--self.TextLock = nil
	--self.TextTargetQuantity = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--self.AnimClose = nil
	--self.AnimOpen = nil
	--self.NewVar_0 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelExplainWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelExplainWinView:InitConstStringInfo()
	self.TextLock:SetText(LSTR(350057))
	self.TextCompletedHint:SetText(LSTR(350065))
end

function GoldSauserMainPanelExplainWinView:OnInit()
	GoldSauserMainPanelExplainWinVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelExplainWinVM()
	--self.TableViewDescAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDesc)
	self.TableViewTaskAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTask)
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)
	self:InitConstStringInfo()
end

function GoldSauserMainPanelExplainWinView:OnDestroy()

end

function GoldSauserMainPanelExplainWinView:OnShow()
	local ScoreIcon = _G.ScoreMgr:GetScoreIconName(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	GoldSauserMainPanelExplainWinVM.Icon = ScoreIcon
	self:UpdateBottomBtnShow()
end

function GoldSauserMainPanelExplainWinView:OnHide()

end

function GoldSauserMainPanelExplainWinView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.CommBtnM_Enter, self.OnEnterBtnClicked)
	-- 九宫幻卡
	UIUtil.AddOnClickedEvent(self, self.BtnRecomXS, self.OnEnterBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnNoramlM2, self.OnExtend1BtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRecomM2, self.OnExtend2BtnClicked)
	-- 陆行鸟竞赛
	UIUtil.AddOnClickedEvent(self, self.BtnNoramlM1, self.OnExtend2BtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRecomM1, self.OnEnterBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnGetReward, self.OnAwardBtnClicked)
	self.CommSlot:SetClickButtonCallback(self, self.OnAwardBtnTipsClicked)
	-- 其他
	UIUtil.AddOnClickedEvent(self, self.BtnRecomL, self.OnEnterBtnClicked)
	-- Mask屏蔽界面
	UIUtil.AddOnClickedEvent(self, self.MaskButton, self.OnMaskButtonClicked)
	-- 退出界面
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnButtonCloseClicked)
end

function GoldSauserMainPanelExplainWinView:OnRegisterGameEvent()

end

function GoldSauserMainPanelExplainWinView:OnRegisterBinder()
	self.CommSlot:SetParams({Data = GoldSauserMainPanelExplainWinVM})
	local Binders = {
		{ "TitleText", UIBinderSetText.New(self, self.TextTitle) },
		{ "DescContentText", UIBinderSetText.New(self, self.RichTextInfo) },
		{ "EventList", UIBinderUpdateBindableList.New(self, self.TableViewTaskAdapter)},
		{ "bShowPanelGameInfo", UIBinderSetIsVisible.New(self, self.PanelGameInfo) },
		{ "IsShowTimeText", UIBinderSetIsVisible.New(self, self.TextTime) },
		{ "bUnlock", UIBinderSetIsVisible.New(self, self.PanelLock, true) },
		{ "QuestIconVisible", UIBinderSetIsVisible.New(self, self.SizeBoxIcon) },
		{ "IconTobeViewVisible", UIBinderSetIsVisible.New(self, self.IconTobeViewed) },
		{ "bUnlock", UIBinderSetIsVisible.New(self, self.PanelDare) },
		{ "LockQuestName", UIBinderSetText.New(self, self.TextHine) },
		{ "HintTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextHine) },
		{ "TextBureau", UIBinderSetText.New(self, self.TextBureau) },
		{ "TextIntegral", UIBinderSetText.New(self, self.TextIntegral) },
		{ "bShowTopInfo", UIBinderSetIsVisible.New(self, self.PanelTopInfo) },
		{ "EventTextstr", UIBinderSetText.New(self, self.TextTargetQuantity) },
		{ "AwardNum", UIBinderSetText.New(self, self.TextQuantity) },
		{ "IsFinishAllEvent", UIBinderSetIsVisible.New(self, self.CommSlot.PanelAvailable) },
		{ "IsFinishAllEvent", UIBinderSetIsVisible.New(self, self.CommSlot.Btn, true, true) },
		{ "IsFinishAllEvent", UIBinderSetIsVisible.New(self, self.BtnGetReward, nil, true) },
		--{ "bNotShowItemLevel", UIBinderSetIsVisible.New(self, self.CommSlot.RichTextLevel, true) },
		{ "EndTimeStamp", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 1, true, true)},
		{ "bTaskCompleteMax", UIBinderSetIsVisible.New(self, self.PanelCompleted) },
		{ "bTaskCompleteMax", UIBinderSetIsVisible.New(self, self.TableViewTask, true) },
		{ "bTaskCompleteMax", UIBinderSetIsVisible.New(self, self.CommSlot, true) },
	}
	self:RegisterBinders(GoldSauserMainPanelExplainWinVM, Binders)
end

function GoldSauserMainPanelExplainWinView:CloseTheExplainPanel()
	local ParentView = self.ParentView
	if not ParentView then
		return
	end

	ParentView:UpdateEntranceItemViewWhenCloseExplainView()
	local DelayShowTime = 0.2 -- 延时处理防止主界面背景图太小露出场景图
	self:RegisterTimer(function()
		self:PlayAnimation(self.AnimClose)
	end, DelayShowTime)
end

function GoldSauserMainPanelExplainWinView:OnButtonCloseClicked()
	self:CloseTheExplainPanel()
end

function GoldSauserMainPanelExplainWinView:OnMaskButtonClicked()
	self:CloseTheExplainPanel()
end

function GoldSauserMainPanelExplainWinView:OnEnterBtnClicked()
	--GoldSauserMainPanelMgr:TransferByPanel()
	GoldSauserMainPanelMgr:BtnClickGoToGoldSauserMainGame(GoldSauserMainPanelExplainWinVM:GetGameId())
end

function GoldSauserMainPanelExplainWinView:OnExtend1BtnClicked()
	self:Extend1ClickFunc()
end

function GoldSauserMainPanelExplainWinView:OnExtend2BtnClicked()
	self:Extend2ClickFunc()
end

function GoldSauserMainPanelExplainWinView:OnAwardBtnClicked()
	if GoldSauserMainPanelExplainWinVM.IsFinishAllEvent then
		local TaskType = GoldSauserMainPanelExplainWinVM:GetGameType()
		if TaskType then
			GoldSauserMainPanelExplainWinVM:SetRewardGameType(TaskType)
			GoldSauserMainPanelMgr:SendGetGoldSauserRewardMsg(TaskType)
		end
	end
end

function GoldSauserMainPanelExplainWinView:OnAwardBtnTipsClicked()
	ItemTipsUtil.ShowTipsByResID(ScoreType.SCORE_TYPE_KING_DEE, self.CommSlot)
end

--打开时尚目标界面
function GoldSauserMainPanelExplainWinView:OpenFashionCheckTargetPanel()
	_G.FashionEvaluationMgr:ShowTrackTargetView()
end

--打开幻卡图鉴
function GoldSauserMainPanelExplainWinView:OpenMagicCardCollectionMainPanel()
	MagicCardCollectionMgr:ShowMagicCardCollectionMainPanel()
end

--打开幻卡备战（幻卡编辑）
function GoldSauserMainPanelExplainWinView:OpenGameStartMagicCard()
	_G.MagicCardMgr:SendOpenGameStartReq(false)
end

--打开陆行鸟
function GoldSauserMainPanelExplainWinView:OpenChocoboPanel()
	_G.ChocoboMgr:ShowChocoboMainPanelView()
end

------------------------倒计时相关 Start ------------------------
------@type 当倒计时至最后
function GoldSauserMainPanelExplainWinView:TimeOutCallback()
	local bIsShowTimeText =  GoldSauserMainPanelExplainWinVM.IsShowTimeText
	if not bIsShowTimeText then
		return
	end
	---重新请求一次数据,非限时状态改变玩法不走此逻辑
	GoldSauserMainPanelMgr:SendGetGameEventViewDataMsg(GoldSauserMainPanelExplainWinVM:GetGameType())
end

---@type 此函数每1s调用一次 刷时间
---@param LeftTime number 剩余时间
function GoldSauserMainPanelExplainWinView:TimeUpdateCallback(LeftTime)
	local bIsShowTimeText =  GoldSauserMainPanelExplainWinVM.IsShowTimeText
	if not bIsShowTimeText then
		return
	end

	local TimeStr = LocalizationUtil.GetCountdownTimeForLongTime(LeftTime)
	local GameId = GoldSauserMainPanelExplainWinVM:GetGameId()
	if GameId == GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot then
		return string.format(LSTR(350028), TimeStr)
	elseif GameId == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
		return string.format(LSTR(350074), TimeStr)
	elseif GameId == GoldSauserGameClientType.GoldSauserGameTypeFairyColor then
		return string.format(LSTR(350075), TimeStr)
	else
		return string.format(LSTR(350029), TimeStr)
	end
end
------------------------倒计时相关 End ------------------------

function GoldSauserMainPanelExplainWinView:UpdateBottomBtnShow()
	local CurMapID = _G.PWorldMgr:GetCurrMapResID()
	if not CurMapID then
		return
	end
	
	local GameId = GoldSauserMainPanelExplainWinVM:GetGameId()
	if not GameId then
		return
	end

	local bInJD = GoldSauserMainPanelMgr:IsInJDMap(CurMapID)
	if not GoldSauserMainPanelMgr:IsGameUnlock(GameId) then
		UIUtil.SetIsVisible(self.BtnRecomL, bInJD, true)
		UIUtil.SetIsVisible(self.TextBtnL, bInJD)
		self.PanelBtn:SetActiveWidgetIndex(0)
		self.TextBtnL:SetText(LSTR(350030))
		return
	end

	if GameId == GoldSauserGameClientType.GoldSauserGameTypeFantasyCard then
		self.PanelBtn:SetActiveWidgetIndex(2)
		self.TextBtnNoralM2:SetText(LSTR(350031))
		self.TextBtnRecomM2:SetText(LSTR(350032))
		self.Extend1ClickFunc = self.OpenGameStartMagicCard
		self.Extend2ClickFunc = self.OpenMagicCardCollectionMainPanel
		UIUtil.SetIsVisible(self.PanelBenRecomXS, bInJD)
	elseif GameId == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
		self.PanelBtn:SetActiveWidgetIndex(1)
		self.TextBtnNoralM1:SetText(LSTR(350081))
		self.TextBtnRecomM1:SetText(LSTR(350034))
		self.Extend2ClickFunc = self.OpenFashionCheckTargetPanel
		UIUtil.SetIsVisible(self.PanelBenRecomM, bInJD)
	elseif GameId == GoldSauserGameClientType.GoldSauserGameTypeChocobo then
		self.PanelBtn:SetActiveWidgetIndex(1)
		self.TextBtnNoralM1:SetText(LSTR(350033))
		self.TextBtnRecomM1:SetText(LSTR(350034))
		self.Extend2ClickFunc = self.OpenChocoboPanel
		UIUtil.SetIsVisible(self.PanelBenRecomM, bInJD)
	else
		UIUtil.SetIsVisible(self.BtnRecomL, bInJD, true)
		UIUtil.SetIsVisible(self.TextBtnL, bInJD)
		self.PanelBtn:SetActiveWidgetIndex(0)
		self.TextBtnL:SetText(LSTR(350034))
	end
end

function GoldSauserMainPanelExplainWinView:OnAnimationFinished(Anim)
	if Anim == self.AnimClose then
		UIUtil.SetIsVisible(self, false)
		local ParentView = self.ParentView
		if ParentView then
			ParentView:ReturnToTheMainPanel()
		end
	end

end

return GoldSauserMainPanelExplainWinView