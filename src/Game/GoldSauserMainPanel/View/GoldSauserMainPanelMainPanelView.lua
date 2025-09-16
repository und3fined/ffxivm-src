---
--- Author: Administrator
--- DateTime: 2023-12-29 20:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ProtoRes =  require("Protocol/ProtoRes")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local EventID = require("Define/EventID")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
--local DateTimeTools = require("Common/DateTimeTools")

local SCORE_TYPE = ProtoRes.SCORE_TYPE
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local AudioType = GoldSauserMainPanelDefine.AudioType
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local MiniCactpotMgr = require("Game/MiniCactpot/MiniCactpotMgr")
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr
local FashionEvaluationMgr = _G.FashionEvaluationMgr

local UIViewMgr
local UIViewID = _G.UIViewID
local ProtoCommon = require("Protocol/ProtoCommon")
local ModuleID = ProtoCommon.ModuleID


local UE = _G.UE
local UUIUtil = UE.UUIUtil
local FVector2D = UE.FVector2D
local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary
local EUMGSequencePlayMode = UE.EUMGSequencePlayMode

---@class GoldSauserMainPanelMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AirplaneGameItem GoldSauserMainPanelMainPanelAirplaneGameItemView
---@field BirdGameItem GoldSauserMainPanelBirdGameItemView
---@field Btn UFButton
---@field BtnChallengeNotes UFButton
---@field BtnData UFButton
---@field BtnMark UFButton
---@field BtnShop UFButton
---@field ChocoboRacesItem GoldSauserMainPanelChocoboRacesItemView
---@field ChocoboTournamentItem GoldSauserMainPanelChocoboTournamentItemView
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field EventSquareItem GoldSauserMainPanelEventSquareItemView
---@field FNeedMovePanel UFCanvasPanel
---@field FashionReportItem GoldSauserMainPanelFashionReportItemView
---@field FashionTargetRedDot CommonRedDotView
---@field GoldSauserMainPanelExplainWin_UIBP GoldSauserMainPanelExplainWinView
---@field IconChallengeDataLock UFImage
---@field IconChallengeNotesLock UFImage
---@field JumboCactpotItem GoldSauserMainPanelJumboCactpotItemView
---@field MI_DX_Sequence_GoldSaucerMain_5 UFImage
---@field MiniCactpotItem GoldSauserMainPanelMiniCactpotItemView
---@field Money CommMoneySlotView
---@field NewBtnGoto UFButton
---@field NextTripleTriadTournamentItem GoldSauserMainPanelNextTripleTriadTournamentItemView
---@field P_DX_GoldSaucerMain_3 UUIParticleEmitter
---@field PanelAddition UFHorizontalBox
---@field PanelAirplane UFCanvasPanel
---@field PanelAirplaneSuccess UFCanvasPanel
---@field PanelCactuar UFCanvasPanel
---@field PanelStartTime UFHorizontalBox
---@field PanelSuccess UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field SpineBook USpineWidget
---@field SpineCactuar USpineWidget
---@field T_Icon_GoldSaucerMain_2 UFImage
---@field TextAddition UFTextBlock
---@field TextGoto UFTextBlock
---@field TextPlayground UFTextBlock
---@field TextTime UFTextBlock
---@field TripleTriadCardItem GoldSauserMainPanelTripleTriadCardItemView
---@field AnimCactuarClick1 UWidgetAnimation
---@field AnimCactuarClick2 UWidgetAnimation
---@field AnimCactuarClick3 UWidgetAnimation
---@field AnimCactuarWalk UWidgetAnimation
---@field AnimCelebrationIn UWidgetAnimation
---@field AnimCelebrationLoop UWidgetAnimation
---@field AnimGameSuccess UWidgetAnimation
---@field AnimGameSuccessAirplane UWidgetAnimation
---@field AnimGoLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimToAirplaneGame UWidgetAnimation
---@field AnimToBirdGame UWidgetAnimation
---@field AnimToChocoboRaces UWidgetAnimation
---@field AnimToChocoboTournament UWidgetAnimation
---@field AnimToEventSquare UWidgetAnimation
---@field AnimToFashionReport UWidgetAnimation
---@field AnimToJumboCactpot UWidgetAnimation
---@field AnimToMiniCactpot UWidgetAnimation
---@field AnimToNextTripleTriadTournament UWidgetAnimation
---@field AnimToTripleTriadCard UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelMainPanelView = LuaClass(UIView, true)

function GoldSauserMainPanelMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AirplaneGameItem = nil
	--self.BirdGameItem = nil
	--self.Btn = nil
	--self.BtnChallengeNotes = nil
	--self.BtnData = nil
	--self.BtnMark = nil
	--self.BtnShop = nil
	--self.ChocoboRacesItem = nil
	--self.ChocoboTournamentItem = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.EventSquareItem = nil
	--self.FNeedMovePanel = nil
	--self.FashionReportItem = nil
	--self.FashionTargetRedDot = nil
	--self.GoldSauserMainPanelExplainWin_UIBP = nil
	--self.IconChallengeDataLock = nil
	--self.IconChallengeNotesLock = nil
	--self.JumboCactpotItem = nil
	--self.MI_DX_Sequence_GoldSaucerMain_5 = nil
	--self.MiniCactpotItem = nil
	--self.Money = nil
	--self.NewBtnGoto = nil
	--self.NextTripleTriadTournamentItem = nil
	--self.P_DX_GoldSaucerMain_3 = nil
	--self.PanelAddition = nil
	--self.PanelAirplane = nil
	--self.PanelAirplaneSuccess = nil
	--self.PanelCactuar = nil
	--self.PanelStartTime = nil
	--self.PanelSuccess = nil
	--self.PanelTime = nil
	--self.SpineBook = nil
	--self.SpineCactuar = nil
	--self.T_Icon_GoldSaucerMain_2 = nil
	--self.TextAddition = nil
	--self.TextGoto = nil
	--self.TextPlayground = nil
	--self.TextTime = nil
	--self.TripleTriadCardItem = nil
	--self.AnimCactuarClick1 = nil
	--self.AnimCactuarClick2 = nil
	--self.AnimCactuarClick3 = nil
	--self.AnimCactuarWalk = nil
	--self.AnimCelebrationIn = nil
	--self.AnimCelebrationLoop = nil
	--self.AnimGameSuccess = nil
	--self.AnimGameSuccessAirplane = nil
	--self.AnimGoLoop = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimToAirplaneGame = nil
	--self.AnimToBirdGame = nil
	--self.AnimToChocoboRaces = nil
	--self.AnimToChocoboTournament = nil
	--self.AnimToEventSquare = nil
	--self.AnimToFashionReport = nil
	--self.AnimToJumboCactpot = nil
	--self.AnimToMiniCactpot = nil
	--self.AnimToNextTripleTriadTournament = nil
	--self.AnimToTripleTriadCard = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AirplaneGameItem)
	self:AddSubView(self.BirdGameItem)
	self:AddSubView(self.ChocoboRacesItem)
	self:AddSubView(self.ChocoboTournamentItem)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.EventSquareItem)
	self:AddSubView(self.FashionReportItem)
	self:AddSubView(self.FashionTargetRedDot)
	self:AddSubView(self.GoldSauserMainPanelExplainWin_UIBP)
	self:AddSubView(self.JumboCactpotItem)
	self:AddSubView(self.MiniCactpotItem)
	self:AddSubView(self.Money)
	self:AddSubView(self.NextTripleTriadTournamentItem)
	self:AddSubView(self.TripleTriadCardItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelMainPanelView:InitConstStringInfo()
	self.TextPlayground:SetText(LSTR(350063))
	self.TextGoto:SetText(LSTR(350064))
	--self.JDCoinBoost:SetText(string.format(LSTR(350076), "50%"))
end

function GoldSauserMainPanelMainPanelView:OnInit()
	UIViewMgr = _G.UIViewMgr
	self.CloseBtn:SetCallback(self, self.OnCloseBtnClicked)
	self.AnimDelayCactusDisappearTimer = nil -- 正常流程仙人掌动画消失计时器
	self:InitConstStringInfo()

	--- 金碟庆典相关
	_G.GoldSauserCeremonyMgr:CachMouthDayData()
end

function GoldSauserMainPanelMainPanelView:OnDestroy()

end

function GoldSauserMainPanelMainPanelView:OnShow()
	--- 按钮状态和回调设置(确保EntranceWidget的ItemVM不为空)
	for _, GameID in pairs(GoldSauserGameClientType) do
		local EntranceView = self:GetEntranceWidgetByGameID(GameID)
		if EntranceView then
			if EntranceView.SetItemVM then
				local ItemVM = GoldSauserMainPanelMainVM:GetEntranceItemVMByBtnID(GameID)
				if ItemVM then
					EntranceView:SetItemVM(GoldSauserMainPanelMainVM:GetEntranceItemVMByBtnID(GameID)) 
				end
			end
			if EntranceView.SetCallBackFunc then
				EntranceView:SetCallBackFunc(self, self.OnEntranceItemClicked) 
			end
		end
	end
	GoldSauserMainPanelMgr:PreReqSevInfoForGameWhenOpenPanel()
	
	GoldSauserMainPanelMainVM:UpdatGoldSauserMainPanelInfo()

	GoldSauserMainPanelMainVM.IsChallengeNoteUnlock = _G.ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDChallengeNote)

	self:UpdateOtherModuleSevInfoContent(GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace)
	
	self:ChangeExplainViewVisibility(false)

	-- 货币栏状态
	local MoneyWidget = self.Money
	if MoneyWidget then
		MoneyWidget:UpdateView(SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)
	end

	local CurMapID = _G.PWorldMgr:GetCurrMapResID()
	if CurMapID and not GoldSauserMainPanelMgr:IsInJDMap(CurMapID) then
		self:PlayAnimation(self.AnimGoLoop, 0, 0)
	end

	self:SelectEntranceWhenOpenPanel()

	--- 金碟庆典相关
	_G.GoldSauserCeremonyMgr:TryUpdateTimeInfo()
	local RemainSecToStart = _G.GoldSauserCeremonyMgr:GetReaminSecToCeremony()
	if not _G.GoldSauserCeremonyMgr.bHaveShowCeremonyMgrThisLogin then
		if RemainSecToStart < 3600 * 24 and RemainSecToStart > 0 then
			MsgTipsUtil.ShowTipsByID(40295) -- 金碟庆典开始预告提示
			_G.GoldSauserCeremonyMgr.bHaveShowCeremonyMgrThisLogin = true
		end
	end

	if _G.GoldSauserCeremonyMgr:IsInCeremony() then
		self:PlayAnimation(self.AnimCelebrationIn)
		self:PlayAnimation(self.AnimCelebrationLoop, 0, 0)
	end
end

function GoldSauserMainPanelMainPanelView:OnSelectEntranceWhenOpenPanel(SelectedGameID)
	if not SelectedGameID then
		return
	end

	local TaskType = GoldSauserMainPanelMgr:FindGameParentTypeByGameEntranceID(SelectedGameID)
	if TaskType then
		self:OnEntranceItemClicked(SelectedGameID, TaskType)
	end
end

function GoldSauserMainPanelMainPanelView:SelectEntranceWhenOpenPanel()
	local Params = self.Params
	if not Params then
		return
	end

	local SelectedGameID = Params.SelectedGameType
	if not SelectedGameID then
		return
	end

	local TaskType = GoldSauserMainPanelMgr:FindGameParentTypeByGameEntranceID(SelectedGameID)
	if TaskType then
		self:OnEntranceItemClicked(SelectedGameID, TaskType)
	end
end

function GoldSauserMainPanelMainPanelView:OnHide()
	local OldSelecedBtnID = GoldSauserMainPanelMainVM:GetCurrentSelectBtnID()
	--- 清除选中
	self:SetItemStateByBtnID(OldSelecedBtnID, GoldSauserMainPanelDefine.MainPanelItemState.Default)
	GoldSauserMainPanelMainVM:SetCurrentSelectBtnID(0)
	GoldSauserMainPanelMainVM:SetIsEventSquareCenter(false)
	--- 位置回正
	self:UpdateEntranceSelectAnimByGameID(OldSelecedBtnID, false)
	--- 计时器销毁
	if self.GameStartTimer then
		_G.TimerMgr:CancelTimer(self.MiniGameTimer)
		self.GameStartTimer = nil
	end

	self:HideTheCactus()

	-- 金碟庆典相关
	_G.GoldSauserCeremonyMgr:StopUpdateTimeInfo()

	self:StopAllAnimations()
end

function GoldSauserMainPanelMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChallengeNotes, self.OnBtnChallengeNotesClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnData, self.OnBtnDataClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnMark, self.OnBtnMarkClicked)
	UIUtil.AddOnClickedEvent(self, self.NewBtnGoto, self.OnBtnGotoClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnBtnShopClicked)
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function GoldSauserMainPanelMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
	self:RegisterGameEvent(EventID.GoldSauserCactusShowOrHide, self.OnCactusShowOrHide)
	self:RegisterGameEvent(EventID.GoldSauserSelectedEntrance, self.OnSelectEntranceWhenOpenPanel)
	self:RegisterGameEvent(EventID.ExcuteAsyncInfoFromOtherModule, self.OnUpdateEntranceSpecialState)
	self:RegisterGameEvent(EventID.HideUI, self.OnNotifyRelativePanelClose)
end

function GoldSauserMainPanelMainPanelView:OnRegisterBinder()
	local Binders = {
		-- { "GoldSauserCurrencyNum", UIBinderSetText.New(self, self.TextGoldQuantity) },
		{ "CactusClickedCount", UIBinderValueChangedCallback.New(self, nil, self.OnCactusClicked)},
		{ "CurrentSelectBtnID", UIBinderValueChangedCallback.New(self, nil, self.OnCurrentSelectBtnIDChanged)},
		{ "IsMiniGameStart", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameStart) },
		--{ "IsEventSquareCenter", UIBinderValueChangedCallback.New(self, nil, self.SetEventSquareItemCenter) },
		{ "TopCelebrationTime", UIBinderSetText.New(self, self.TextTime)},
		{ "DownCelebrationTime", UIBinderSetText.New(self, self.TextAddition)},
		-- { "CelebrPanelAddition", UIBinderSetText.New(self, self.JDCoinBoost)},

		{ "IsShowTimePanel", UIBinderSetIsVisible.New(self, self.PanelStartTime)},
		{ "IsInCelebration", UIBinderSetIsVisible.New(self, self.PanelAddition)},
		{ "MiniGameSuccess", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameSuccessShow)},
		{ "MiniGameAirplaneSuccess", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameAirplaneSuccess)},
		{ "IsDataItemUnlock", UIBinderSetIsVisible.New(self, self.IconChallengeDataLock, true)},
		{ "IsChallengeNoteUnlock", UIBinderSetIsVisible.New(self, self.IconChallengeNotesLock, true)},
	}

	self:RegisterBinders(GoldSauserMainPanelMainVM, Binders)
end

function GoldSauserMainPanelMainPanelView:OnMiniGameAirplaneSuccess(NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimGameSuccessAirplane)
		GoldSauserMainPanelMainVM.MiniGameAirplaneSuccess = false
	end
end

function GoldSauserMainPanelMainPanelView:OnMiniGameSuccessShow(NewValue, OldValue)
	if OldValue == nil and NewValue == nil then
		return
	end

	if NewValue then
		self:PlayAnimation(self.AnimGameSuccess)
	end
end



--- 涉及跨界面的判断也集成到金碟主界面内，方便统一管理，且界面关闭后即反注册，不再调用
function GoldSauserMainPanelMainPanelView:OnNotifyRelativePanelClose(ViewID)
	local ViewNeedCheck = GoldSauserMainPanelDefine.ViewNeedCactusCheckAfterClosed
	if not ViewNeedCheck or not next(ViewNeedCheck) then
		return
	end

	if ViewNeedCheck[ViewID] then
		GoldSauserMainPanelMgr:CheckCactusState()
	end
end

function GoldSauserMainPanelMainPanelView:OnMoneyUpdate()
	self.Money:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)
end

function GoldSauserMainPanelMainPanelView:OnCactusShowOrHide(bShow, bPlayHideAnim)
	if bShow then
		self:CactusStartMove()
	else
		self:CactusHide(bPlayHideAnim)
	end
end

--- 根据入口游戏ID获取对应蓝图SubView
function GoldSauserMainPanelMainPanelView:GetEntranceWidgetByGameID(GameID)
	if GameID == GoldSauserGameClientType.GoldSauserGameTypeGateCircle then
		return self.AirplaneGameItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeGateMagic then
		return self.BirdGameItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeGateShow then
		return self.EventSquareItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeChocobo then
		return self.ChocoboRacesItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeChocoboRace then
		return self.ChocoboTournamentItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFairyColor then
		return self.JumboCactpotItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot then
		return self.MiniCactpotItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCard then
		return self.TripleTriadCardItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
		return self.NextTripleTriadTournamentItem
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
		return self.FashionReportItem
	end
end

--- 根据入口游戏ID获取对应蓝图选中动画
function GoldSauserMainPanelMainPanelView:GetEntranceSelectAnimByGameID(GameID)
	if GameID == GoldSauserGameClientType.GoldSauserGameTypeGateCircle then
		return self.AnimToAirplaneGame
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeGateMagic then
		return self.AnimToBirdGame
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeGateShow then
		return self.AnimToEventSquare
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeChocobo then
		return self.AnimToChocoboRaces
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeChocoboRace then
		return self.AnimToChocoboTournament
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFairyColor then
		return self.AnimToJumboCactpot
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot then
		return self.AnimToMiniCactpot
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCard then
		return self.AnimToTripleTriadCard
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
		return self.AnimToNextTripleTriadTournament
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
		return self.AnimToFashionReport
	end
end

function GoldSauserMainPanelMainPanelView:OnUpdateEntranceSpecialState(GameID)
	self:UpdateOtherModuleSevInfoContent(GameID)
end

function GoldSauserMainPanelMainPanelView:UpdateOtherModuleSevInfoContent(GameID)
	local MsgUpdated = GoldSauserMainPanelMgr:GetTheMsgUpdateState(GameID)
	if not MsgUpdated then
		return
	end

	if GameID == GoldSauserGameClientType.GoldSauserGameTypeFairyColor then
		if  JumboCactpotMgr:IsLottory() then
			self.JumboCactpotItem.ItemVM:SetIsGameAward(true)
		else
			self.JumboCactpotItem.ItemVM:SetIsGameAward(false)
		end
		if  JumboCactpotMgr:IsExistJumbCount() then
			self.JumboCactpotItem.ItemVM:SetIsGameNoFinish(true)
		else
			self.JumboCactpotItem.ItemVM:SetIsGameNoFinish(false)
		end
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot then
		local LeftChance = MiniCactpotMgr:GetLeftChance() or 0
		if LeftChance > 0 then
			self.MiniCactpotItem.ItemVM:SetIsGameNoFinish(true)
		else
			self.MiniCactpotItem.ItemVM:SetIsGameNoFinish(false)
		end
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
		if  MagicCardTourneyMgr:IsCanGetReward() then
			self.TripleTriadCardItem.ItemVM:SetIsGameAward(true)
			self.NextTripleTriadTournamentItem.ItemVM:SetIsGameAward(true)
		else
			self.TripleTriadCardItem.ItemVM:SetIsGameAward(false)
			self.NextTripleTriadTournamentItem.ItemVM:SetIsGameAward(false)
		end
		if not MagicCardTourneyMgr:IsFinishedTourney() and not GoldSauserMainPanelMgr:IsGameEntranceLocked(GameID) then
			self.TripleTriadCardItem.ItemVM:SetIsGameNoFinish(true)
			self.NextTripleTriadTournamentItem.ItemVM:SetIsGameNoFinish(true)
		else
			self.TripleTriadCardItem.ItemVM:SetIsGameNoFinish(false)
			self.NextTripleTriadTournamentItem.ItemVM:SetIsGameNoFinish(false)
		end
	elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
		local FashionInfo = FashionEvaluationMgr:GetEvaluationInfo()
        if FashionInfo then
            local RemainTimes = FashionInfo.WeekRemainTimes or 0
            self.FashionReportItem.ItemVM:SetIsGameNoFinish(RemainTimes > 0)
        end
	end
end

function GoldSauserMainPanelMainPanelView:UpdateViewContentDependOtherModuleSevInfo()
	---设置高亮
	self:UpdateOtherModuleSevInfoContent(GoldSauserGameClientType.GoldSauserGameTypeFairyColor)
	self:UpdateOtherModuleSevInfoContent(GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot)
	self:UpdateOtherModuleSevInfoContent(GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace)
end

--- 根据入口游戏ID更新对应Widget选中动画动效
---@param GameID GoldSauserGameClientType
---@param bSelect boolean@是否选中
function GoldSauserMainPanelMainPanelView:UpdateEntranceSelectAnimByGameID(GameID, bSelect)
	local Anim = self:GetEntranceSelectAnimByGameID(GameID)
	if not Anim then
		return
	end

	local PlayMode = bSelect and EUMGSequencePlayMode.Forward or EUMGSequencePlayMode.Reverse
	self:PlayAnimation(Anim, 0, 1, PlayMode)
	return Anim:GetEndTime()
end

function GoldSauserMainPanelMainPanelView:CancelOffset()
	local Offset = _G.UE.FMargin()
	Offset.Left = 0
	Offset.Top = 0
	Offset.Right = 0
	Offset.Bottom = 0
	UUIUtil.CanvasSlotSetOffsets(self.FNeedMovePanel, Offset)
end

function GoldSauserMainPanelMainPanelView:OnBtnClicked()
	GoldSauserMainPanelMainVM:AddCactusClickedCount()
end

function GoldSauserMainPanelMainPanelView:OnBtnGotoClicked()
	local IsInPanelMiniGame = GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true)
    if IsInPanelMiniGame then
        return
    end
	DataReportUtil.ReportEnterEntertainSceneByUI()
	GoldSauserMainPanelMgr:BtnClickGoToGoldSauserMainGame(GoldSauserGameClientType.GoldSauserGameTypeNone)
	GoldSauserMainPanelMgr:TriggerCactusHide()
end

function GoldSauserMainPanelMainPanelView:OnBtnDataClicked()
	local IsInPanelMiniGame = GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true)
    if IsInPanelMiniGame then
        return
    end
	
	local IsDataItemUnlock = GoldSauserMainPanelMainVM.IsDataItemUnlock
	if not IsDataItemUnlock then
		local Cfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_GOLD_SAUSER_MAIN_DATE_ITEM_UNLOCK_LIMIT)
		if Cfg then
			local LimitValueList = Cfg.Value
			if LimitValueList then
				local LimitValue = LimitValueList[1] or 0
				MsgTipsUtil.ShowTips(string.format(LSTR(350080), LimitValue))
			end
		end
		return
	end

	UIViewMgr:ShowView(UIViewID.GoldSauserMainPanelDataWinItem)
	GoldSauserMainPanelMgr:PlayAudio(AudioType.SubView)
	GoldSauserMainPanelMgr:TriggerCactusHide()
end

function GoldSauserMainPanelMainPanelView:OnBtnMarkClicked()
	local IsInPanelMiniGame = GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true)
    if IsInPanelMiniGame then
        return
    end

	GoldSauserMainPanelMgr:OpenAwardWinPanel()
	GoldSauserMainPanelMgr:PlayAudio(AudioType.SubView)
	GoldSauserMainPanelMgr:TriggerCactusHide()
end

function GoldSauserMainPanelMainPanelView:OnCloseBtnClicked()
	UIViewMgr:HideView(UIViewID.GoldSauserEntranceMainPanel)
	GoldSauserMainPanelMgr:TriggerCactusHide()
end

function GoldSauserMainPanelMainPanelView:OnBtnShopClicked()
	local IsInPanelMiniGame = GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true)
    if IsInPanelMiniGame then
        return
    end
	_G.ShopMgr:OpenShop(GoldSauserMainPanelDefine.KingDeeShopID) -- HideOthers,走OnShow
	GoldSauserMainPanelMgr:PlayAudio(AudioType.SubView)
	GoldSauserMainPanelMgr:TriggerCactusHide()
end

function GoldSauserMainPanelMainPanelView:OnBtnChallengeNotesClicked()
	local IsInPanelMiniGame = GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true)
    if IsInPanelMiniGame then
        return
    end
	if not _G.ModuleOpenMgr:ModuleState(ModuleID.ModuleIDChallengeNote) then
		return
	end
	UIViewMgr:ShowView(UIViewID.GoldSaucerMainPanelChallengeNotesWin)
	GoldSauserMainPanelMgr:PlayAudio(AudioType.SubView)
	GoldSauserMainPanelMgr:TriggerCactusHide()
end

function GoldSauserMainPanelMainPanelView:ReturnToTheMainPanel()
	--- 小游戏触发延时
	--[[if GoldSauserMainPanelMainVM.IsMiniGameStart then
		self.GameStartTimer = _G.TimerMgr:AddTimer(self, self.SetMiniGameStart, 3, 3, 1)
		GoldSauserMainPanelMainVM.IsMiniGameStart = false
	end--]]

	-- 检测仙人掌状态
	if not self:IsAnimationPlaying(self.AnimCactuarWalk) then
		GoldSauserMainPanelMgr:CheckCactusState()
	end
end

function GoldSauserMainPanelMainPanelView:UpdateEntranceItemViewWhenCloseExplainView()
	local OldSelecedBtnID = GoldSauserMainPanelMainVM:GetCurrentSelectBtnID()
	--- 清除上次选中
	self:SetItemStateByBtnID(OldSelecedBtnID, GoldSauserMainPanelDefine.MainPanelItemState.Default)
	GoldSauserMainPanelMainVM:SetCurrentSelectBtnID(0)
	--- 位置回正
	return self:UpdateEntranceSelectAnimByGameID(OldSelecedBtnID, false)
end

---小游戏触发延时
function GoldSauserMainPanelMainPanelView:OnMiniGameStart(IsMiniGameStart)
	--[[if IsMiniGameStart then
		if not UIUtil.IsVisible(self.GoldSauserMainPanelExplainWin_UIBP) then
			self.GameStartTimer = _G.TimerMgr:AddTimer(self, self.SetMiniGameStart, 3, 3, 1)
			GoldSauserMainPanelMainVM.IsMiniGameStart = false
		end
	end--]]
end

---小游戏触发
function GoldSauserMainPanelMainPanelView:SetMiniGameStart()
	--GoldSauserMainPanelMainVM:SetMiniGameStart()
	---计时器销毁
	--[[if self.GameStartTimer then
		_G.TimerMgr:CancelTimer(self.MiniGameTimer)
		self.GameStartTimer = nil
	end--]]
end

------------------------ 玩法交互按钮相关 start ------------------------

--- 更新玩法侧边栏的辅助信息
function GoldSauserMainPanelMainPanelView:UpdateAssistPanelView(BtnID)
	local function SyncViewInfo(Param)
		GoldSauserMainPanelMainVM:SetAssistPanelInfo(Param.Round, Param.Score)
	end

	local bAssistAsync, Round, Score = GoldSauserMainPanelMgr:GetGameAssistInfo(BtnID, SyncViewInfo)
	if not bAssistAsync then
		SyncViewInfo({Round = Round, Score = Score})
	end
end

--- 更新玩法侧边栏的提示信息
function GoldSauserMainPanelMainPanelView:UpdateHintPanelView(BtnID)
	local function SyncViewInfo(Param)
		GoldSauserMainPanelMainVM:SetHintContent(Param.HintText, Param.bAwardToGet, Param.IconTobeViewVisible)
	end

	local bHintAsync, HintText, bAwardToGet, IconTobeViewVisible = GoldSauserMainPanelMgr:GetGameHintInfo(BtnID, SyncViewInfo)
	if not bHintAsync then
		SyncViewInfo({HintText = HintText, bAwardToGet = bAwardToGet, IconTobeViewVisible = IconTobeViewVisible})
	end
end

--- 更新玩法侧边栏的时限信息
function GoldSauserMainPanelMainPanelView:UpdateTimePanelView(BtnID)
	local function SyncViewInfo(Param)
		GoldSauserMainPanelMainVM:SetTimeLimitContent(Param.EndTime)
	end

	local bTimeAsync, EndTime = GoldSauserMainPanelMgr:GetGameTimeLimitInfo(BtnID, SyncViewInfo)
	if not bTimeAsync then
		SyncViewInfo({EndTime = EndTime})
	end
end

--- 显示入口上锁原因tips
function GoldSauserMainPanelMainPanelView:ShowEntranceLockedReasonTips(BtnID)
	if BtnID == GoldSauserGameClientType.GoldSauserGameTypeChocobo then
		MsgTipsUtil.ShowTips(LSTR(350020))
	elseif BtnID == GoldSauserGameClientType.GoldSauserGameTypeChocoboRace or BtnID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
		MsgTipsUtil.ShowTips(LSTR(350021))
	end
end

function GoldSauserMainPanelMainPanelView:ChangeSelectedGameEntrance(EntranceVM, BtnID, TaskType)
	if EntranceVM.IsEntranceLocked then
		self:ShowEntranceLockedReasonTips(BtnID)
		return
	end

	local OldSelecedBtnID = GoldSauserMainPanelMainVM:GetCurrentSelectBtnID()
	if OldSelecedBtnID == BtnID then
		return
	end
	local ExplainView = self.GoldSauserMainPanelExplainWin_UIBP
	if not ExplainView then
		return
	end
	self:SetItemStateByBtnID(OldSelecedBtnID, GoldSauserMainPanelDefine.MainPanelItemState.Default)
	self:UpdateEntranceSelectAnimByGameID(BtnID, true)
	GoldSauserMainPanelMainVM:SetCurrentSelectBtnID(BtnID)
	local State, Info = GoldSauserMainPanelMgr:IsGameUnlock(BtnID)
	GoldSauserMainPanelMainVM:SetExplainWinInfo(BtnID, TaskType, {Unlock = State, QuestName = Info})
	self:UpdateAssistPanelView(BtnID)
	self:UpdateHintPanelView(BtnID)
	self:UpdateTimePanelView(BtnID)
	GoldSauserMainPanelMgr:SendGetGameEventViewDataMsg(TaskType)
	self:ChangeExplainViewVisibility(true, true)
	ExplainView:UpdateBottomBtnShow()
	GoldSauserMainPanelMgr:PlayAudio(AudioType.SideView)
end

function GoldSauserMainPanelMainPanelView:OnEntranceItemClicked(BtnID, TaskType)
	if not BtnID or not TaskType then
		return
	end

	local IsInPanelMiniGame = GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true)
    if IsInPanelMiniGame then
        return
    end
	
	local EntranceVM = GoldSauserMainPanelMainVM:GetEntranceItemVMByBtnID(BtnID)
	if not EntranceVM then
		return
	end
	local IsEntranceGameExist = EntranceVM:GetIsGameStart()
	if IsEntranceGameExist then
		local EntranceView = self:GetEntranceWidgetByGameID(BtnID)
		if EntranceView and EntranceView.OnMiniGameBtnClicked then
			EntranceView:OnMiniGameBtnClicked()
		end
	else
		self:ChangeSelectedGameEntrance(EntranceVM, BtnID, TaskType)
	end
	GoldSauserMainPanelMgr:TriggerCactusHide()
end

function GoldSauserMainPanelMainPanelView:OnCurrentSelectBtnIDChanged(BtnID)
	self:SetItemStateByBtnID(BtnID, GoldSauserMainPanelDefine.MainPanelItemState.Selected)
end

function GoldSauserMainPanelMainPanelView:SetItemStateByBtnID(BtnID, State)
	if BtnID then
		local ItemVM = GoldSauserMainPanelMainVM:GetEntranceItemVMByBtnID(BtnID)
		---高亮退出选中还是高亮
		if ItemVM and ItemVM:GetIsHighlight() and State == GoldSauserMainPanelDefine.MainPanelItemState.Default then
			ItemVM:SetState(GoldSauserMainPanelDefine.MainPanelItemState.Highlight)
			return
		end
		if ItemVM and State then
			ItemVM:SetState(State)
		end
	end
end

---演出广场拉近放大处理
function GoldSauserMainPanelMainPanelView:SetEventSquareItemCenter(IsEventSquareCenter)
	if not IsEventSquareCenter then
		self:CancelOffset()
		local Scale = FVector2D(1,1)
		self.FNeedMovePanel:SetRenderScale(Scale)
		return
	end
	--- 只能适配当前锚点,后续视觉效果接入后，看需不需要用屏幕坐标来处理
	local Magnification = 2
	local Position =  UIUtil.CanvasSlotGetPosition(self.EventSquareItem)	
	local Offset = _G.UE.FMargin()
	Offset.Left = - Position.X * Magnification
	Offset.Top = - Position.Y * Magnification
	Offset.Right = Position.X * Magnification
	Offset.Bottom = Position.Y * Magnification
	UUIUtil.CanvasSlotSetOffsets(self.FNeedMovePanel, Offset)
	local Scale = FVector2D(Magnification,Magnification)
	self.FNeedMovePanel:SetRenderScale(Scale)
end

--- 玩法侧边栏显示或隐藏
---@param bVisible boolean
function GoldSauserMainPanelMainPanelView:ChangeExplainViewVisibility(bVisible, bPlayAnim)
	local ExplainView = self.GoldSauserMainPanelExplainWin_UIBP
	if not ExplainView then
		return
	end

	local AnimToPlay = bVisible and ExplainView.AnimOpen or ExplainView.AnimClose

	if bVisible then
		UIUtil.SetIsVisible(self.GoldSauserMainPanelExplainWin_UIBP, true, true)
		if bPlayAnim then
			ExplainView:PlayAnimation(AnimToPlay)
		end
	else
		if bPlayAnim then
			ExplainView:PlayAnimation(AnimToPlay)
			local AnimEndTime = AnimToPlay:GetEndTime()
			self:RegisterTimer(function()
				UIUtil.SetIsVisible(self.GoldSauserMainPanelExplainWin_UIBP, false)
			end, AnimEndTime)
		else
			UIUtil.SetIsVisible(self.GoldSauserMainPanelExplainWin_UIBP, false)
		end
	end
end
------------------------ 玩法交互按钮相关 end ------------------------

------------------------ 仙人掌交互相关 Start ------------------------

function GoldSauserMainPanelMainPanelView:CactusStartMove()
	GoldSauserMainPanelMainVM:SetCactusClickedCount(0)
	UIUtil.SetIsVisible(self.Btn, false)
	UIUtil.SetIsVisible(self.PanelCactuar, true)
	-- 播放移动动画
	self:PlayAnimation(self.AnimCactuarWalk)
end

function GoldSauserMainPanelMainPanelView:HideTheCactus()
	if self.AnimDelayCactusDisappearTimer then
		self.AnimDelayCactusDisappearTimer = nil
	end
	self:StopAnimation(self.AnimCactuarWalk)
	UIUtil.SetIsVisible(self.PanelCactuar, false)
	GoldSauserMainPanelMgr:StartRunTimer()
end

function GoldSauserMainPanelMainPanelView:CactusHide(bPlayHideAnim)
	if not bPlayHideAnim then
		self:HideTheCactus()
		return
	end

	local AnimLeave = self.AnimCactuarClick3
	if not AnimLeave then
		return
	end

	self:PlayAnimation(AnimLeave)
	
	-- 放入计时器防止OnAnimationFinished事件出问题
	local AnimEndTime = AnimLeave:GetEndTime()
	self.AnimDelayCactusDisappearTimer = self:RegisterTimer(function()
		self:HideTheCactus()
	end, AnimEndTime)
end


function GoldSauserMainPanelMainPanelView:OnCactusClicked(CactusClickedCount)
	local ValidCount = GoldSauserMainPanelMgr:GetCactusCfgCountData(CactusClickedCount)
	if not ValidCount then
		return
	end

	if ValidCount == 1 then
		self:PlayAnimation(self.AnimCactuarClick1)
	elseif ValidCount == 2 then
		self:PlayAnimation(self.AnimCactuarClick2)
	elseif ValidCount == 3 then
		self:CactusHide(true)
		GoldSauserMainPanelMainVM:SetCactusClickedCount(0)
	end
end

------------------------ 仙人掌交互相关 end ------------------------
------------------------庆典倒计时相关 Start ------------------------
------@type 当倒计时至最后
function GoldSauserMainPanelMainPanelView:TimeOutCallback()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	--变化时服务器应该会下发
	--MsgTipsUtil.ShowTips(LSTR("庆典结束"))
end

---@type 此函数每1s调用一次 刷时间
---@param LeftTime number 剩余时间
function GoldSauserMainPanelMainPanelView:TimeUpdateCallback(LeftTime)
	local TimeStr = LocalizationUtil.GetCountdownTimeForLongTime(LeftTime)
	return ""
end
------------------------庆典倒计时相关 End ------------------------

function GoldSauserMainPanelMainPanelView:OnAnimationFinished(Anim)
	if Anim == self.AnimCactuarWalk then
		UIUtil.SetIsVisible(self.Btn, true, true)
	elseif Anim == self.AnimIn then
		--- 仙人掌交互运动
		GoldSauserMainPanelMgr:CheckCactusState()
	end
end

return GoldSauserMainPanelMainPanelView