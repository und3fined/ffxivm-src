---
--- Author: Administrator
--- DateTime: 2025-07-09 11:00
--- Description:
---

local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local UIUtil = require("Utils/UIUtil")
local PhotoMediaUtil = require("Game/Photo/Util/PhotoMediaUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ItemUtil = require("Utils/ItemUtil")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")

local ItemVM = require("Game/Item/ItemVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")
local CrystallineStatisticParamCfg = require("TableCfg/CrystallineStatisticParamCfg")
local SeriesMalmstoneSeasonCfg = require("TableCfg/SeriesMalmstoneSeasonCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")

local StatisticType = ProtoRes.CRYSTALLINE_STATISTIC_TYPE
local RankType = ProtoRes.Game.pvp_rank_type
local RankRewardType = ProtoCS.Game.PvPColosseum.PvPSeasonRewardType.PvPSeasonRewardType_Seg

local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local ShareMgr = _G.ShareMgr
local ObjectMgr = _G.ObjectMgr

local UE = _G.UE
local Anchor = UE.FAnchors()
Anchor.Minimum = UE.FVector2D(0, 0)
Anchor.Maximum = UE.FVector2D(0, 0)
local Alignment = UE.FVector2D(0, 0)
local Margin = UE.FMargin()
Margin.Left = 0
Margin.Top = -178
Margin.Right = 700
Margin.Bottom = 540

---@class PVPCrystalRoadPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnNext UFButton
---@field BtnPrevious UFButton
---@field BtnReward CommBtnLView
---@field BtnShare CommBtnLView
---@field CommEmpty CommBackpackEmptyView
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field PVPColosseumStar1 PVPColosseumStarItemView
---@field PVPColosseumStar2 PVPColosseumStarItemView
---@field PVPColosseumStar3 PVPColosseumStarItemView
---@field PVPDanBronze PVPDanBronzeView
---@field PVPDanCrystal PVPDanCrystalView
---@field PVPDanDiamond PVPDanDiamondView
---@field PVPDanGold PVPDanGoldView
---@field PVPDanPlatinum PVPDanPlatinumView
---@field PVPDanSilver PVPDanSilverView
---@field PanelDan UFCanvasPanel
---@field PanelData UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelRank UFCanvasPanel
---@field TableViewReward UTableView
---@field TextBattleCount UFTextBlock
---@field TextBattleCountTitle UFTextBlock
---@field TextBattleStyle UFTextBlock
---@field TextBattleStyleTitle UFTextBlock
---@field TextDanBronze UFTextBlock
---@field TextDanCrystal UFTextBlock
---@field TextDanDiamond UFTextBlock
---@field TextDanGold UFTextBlock
---@field TextDanPlatinum UFTextBlock
---@field TextDanSilver UFTextBlock
---@field TextFinalRank UFTextBlock
---@field TextFinalRankTitle UFTextBlock
---@field TextHighestWinCount UFTextBlock
---@field TextHighestWinCountTitle UFTextBlock
---@field TextKillCount UFTextBlock
---@field TextKillCountTitle UFTextBlock
---@field TextLikeCount UFTextBlock
---@field TextLikeCountTitle UFTextBlock
---@field TextMostLikeMap UFTextBlock
---@field TextMostLikeMapTitle UFTextBlock
---@field TextMostLikeProf UFTextBlock
---@field TextMostLikeProfTitle UFTextBlock
---@field TextRankPromoteTitle UFTextBlock
---@field TextSeasonTitle UFTextBlock
---@field TextTimeBronze UFTextBlock
---@field TextTimeCrystal UFTextBlock
---@field TextTimeDiamond UFTextBlock
---@field TextTimeGold UFTextBlock
---@field TextTimePlatinum UFTextBlock
---@field TextTimeSilver UFTextBlock
---@field TextWinCount UFTextBlock
---@field TextWinCountTitle UFTextBlock
---@field TextWinRate UFTextBlock
---@field TextWinRateTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystalRoadPanelView = LuaClass(UIView, true)

function PVPCrystalRoadPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnNext = nil
	--self.BtnPrevious = nil
	--self.BtnReward = nil
	--self.BtnShare = nil
	--self.CommEmpty = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.PVPColosseumStar1 = nil
	--self.PVPColosseumStar2 = nil
	--self.PVPColosseumStar3 = nil
	--self.PVPDanBronze = nil
	--self.PVPDanCrystal = nil
	--self.PVPDanDiamond = nil
	--self.PVPDanGold = nil
	--self.PVPDanPlatinum = nil
	--self.PVPDanSilver = nil
	--self.PanelDan = nil
	--self.PanelData = nil
	--self.PanelEmpty = nil
	--self.PanelRank = nil
	--self.TableViewReward = nil
	--self.TextBattleCount = nil
	--self.TextBattleCountTitle = nil
	--self.TextBattleStyle = nil
	--self.TextBattleStyleTitle = nil
	--self.TextDanBronze = nil
	--self.TextDanCrystal = nil
	--self.TextDanDiamond = nil
	--self.TextDanGold = nil
	--self.TextDanPlatinum = nil
	--self.TextDanSilver = nil
	--self.TextFinalRank = nil
	--self.TextFinalRankTitle = nil
	--self.TextHighestWinCount = nil
	--self.TextHighestWinCountTitle = nil
	--self.TextKillCount = nil
	--self.TextKillCountTitle = nil
	--self.TextLikeCount = nil
	--self.TextLikeCountTitle = nil
	--self.TextMostLikeMap = nil
	--self.TextMostLikeMapTitle = nil
	--self.TextMostLikeProf = nil
	--self.TextMostLikeProfTitle = nil
	--self.TextRankPromoteTitle = nil
	--self.TextSeasonTitle = nil
	--self.TextTimeBronze = nil
	--self.TextTimeCrystal = nil
	--self.TextTimeDiamond = nil
	--self.TextTimeGold = nil
	--self.TextTimePlatinum = nil
	--self.TextTimeSilver = nil
	--self.TextWinCount = nil
	--self.TextWinCountTitle = nil
	--self.TextWinRate = nil
	--self.TextWinRateTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystalRoadPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnReward)
	self:AddSubView(self.BtnShare)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.PVPColosseumStar1)
	self:AddSubView(self.PVPColosseumStar2)
	self:AddSubView(self.PVPColosseumStar3)
	self:AddSubView(self.PVPDanBronze)
	self:AddSubView(self.PVPDanCrystal)
	self:AddSubView(self.PVPDanDiamond)
	self:AddSubView(self.PVPDanGold)
	self:AddSubView(self.PVPDanPlatinum)
	self:AddSubView(self.PVPDanSilver)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystalRoadPanelView:OnInit()
	self.RewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)
	self.BtnBack:AddBackClick(self, self.OnClickHideBtn)
end

function PVPCrystalRoadPanelView:OnDestroy()

end

function PVPCrystalRoadPanelView:OnShow()
	self:SetFixText()
	self:InitPanel(self.Params)
end

function PVPCrystalRoadPanelView:OnHide()
	self:RemoveShareTimer()
	if self.RankWidget then
		WidgetPoolMgr:RecycleWidget(self.RankWidget)
		self.RankWidget = nil
	end
end

function PVPCrystalRoadPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPrevious, self.OnClickBtnPrevious)
	UIUtil.AddOnClickedEvent(self, self.BtnNext, self.OnClickBtnNext)
	UIUtil.AddOnClickedEvent(self, self.BtnShare, self.OnClickBtnShare)
	UIUtil.AddOnClickedEvent(self, self.BtnReward, self.OnClickBtnReward)
end

function PVPCrystalRoadPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PVPCrystallineRankRewardReceived, self.OnCrystallineRankRewardReceived)
end

function PVPCrystalRoadPanelView:OnRegisterBinder()

end

function PVPCrystalRoadPanelView:OnClickHideBtn()
	self:Hide()
	
	local IsFromInfo = self.Params and self.Params.IsFromInfo
	if IsFromInfo then
		local Params = {
			TabType = PVPInfoDefine.TabType.CrystallineRankRecord,
		}
		UIViewMgr:ShowView(UIViewID.PVPInfoPanel, Params)
	end
end

function PVPCrystalRoadPanelView:SetFixText()
	self.TextRankPromoteTitle:SetText(LSTR(130104))
	self.TextBattleCountTitle:SetText(LSTR(130105))
	self.TextWinCountTitle:SetText(LSTR(130106))
	self.TextWinRateTitle:SetText(LSTR(130107))
	self.TextHighestWinCountTitle:SetText(LSTR(130108))
	self.TextKillCountTitle:SetText(LSTR(130109))
	self.TextLikeCountTitle:SetText(LSTR(130110))
	self.TextMostLikeMapTitle:SetText(LSTR(130111))
	self.TextMostLikeProfTitle:SetText(LSTR(130112))
	self.TextBattleStyleTitle:SetText(LSTR(130113))
	self.TextFinalRankTitle:SetText(LSTR(130114))
	self.CommEmpty:SetTipsContent(LSTR(130121))
	self.BtnShare:SetBtnName(LSTR(130116))
	self.BtnReward:SetBtnName(LSTR(130117))
end

function PVPCrystalRoadPanelView:OnClickBtnPrevious()
	UIUtil.SetIsVisible(self.PanelRank, true)
	UIUtil.SetIsVisible(self.PanelData, false)
end

function PVPCrystalRoadPanelView:OnClickBtnNext()
	UIUtil.SetIsVisible(self.PanelData, true)
	UIUtil.SetIsVisible(self.PanelRank, false)
end

function PVPCrystalRoadPanelView:OnClickBtnShare()
	if self.ShareTimerID then return end

	local function ShareCallback()
		self:RemoveShareTimer()
		self:SetWidgetsVisibleWhenShare(false)
		PhotoMediaUtil.CapScreen(function (W, H, AR) 
			local Tex = UE.UMediaUtil.CovertColorsToTexture2D("", AR, W, H)
			UE.UUIUtil.SetTextureHighQuality(Tex, UE.TextureCompressionSettings.TC_EditorIcon)
			ShareMgr:OpenShareActivityUIWithTexture(Tex, W, H, 1)
			ObjectMgr:CollectGarbage(false)
			self:SetWidgetsVisibleWhenShare(true)
		end, true)
	end
	local Delay = 0.2
	self.ShareTimerID = self:RegisterTimer(ShareCallback, Delay)
end

function PVPCrystalRoadPanelView:OnClickBtnReward()
	local SeasonID = self.Params and self.Params.SeasonID
	if SeasonID then
		PVPInfoMgr:RequestCrystallineSeasonReward(RankRewardType, SeasonID)
	end
end

function PVPCrystalRoadPanelView:OnCrystallineRankRewardReceived(Params)
	local Type = Params and Params.Type
	local ReceivedSeasonID = Params and Params.SeasonID
	local CurSeasonID = self.Params and self.Params.SeasonID
	if Type == RankRewardType and CurSeasonID == ReceivedSeasonID then
		self.BtnReward:SetIsDone(true, LSTR(130118))
		self:UpdateRewardReceived()
	end
end

function PVPCrystalRoadPanelView:InitPanel(Params)
	local SeasonID = Params and Params.SeasonID
	if SeasonID and SeasonID > 0 then
		self:SetTitleText(SeasonID)
		
		local Data = PVPInfoMgr:GetCrystallineRankRecordData(SeasonID)
		local IsEmpty = Data == nil or Data.BtlNum <= 0
		if not IsEmpty then
			local IsShowReward = Params.IsShowReward
			if IsShowReward then
				self:UpdateReward(SeasonID, Data.RankID)
				self.BtnShare:SetIsNormalState(true)
				self.BtnReward:SetIsRecommendState(true)
			else
				self.BtnShare:SetIsRecommendState(true)
			end
			UIUtil.SetIsVisible(self.BtnReward, IsShowReward, true)
			UIUtil.SetIsVisible(self.TableViewReward, IsShowReward)
			UIUtil.SetIsVisible(self.PanelRank, true)
			UIUtil.SetIsVisible(self.PanelData, false)
			UIUtil.SetIsVisible(self.PanelEmpty, false)

			self:ShowRankInfo(Data.RankType)
			self:ShowBattleInfo(Data)
		else
			UIUtil.SetIsVisible(self.PanelRank, false)
			UIUtil.SetIsVisible(self.PanelData, false)
			UIUtil.SetIsVisible(self.PanelEmpty, true)
		end
	end
end

function PVPCrystalRoadPanelView:SetTitleText(SeasonID)
	local Cfg = SeriesMalmstoneSeasonCfg:FindCfgByKey(SeasonID)
	if Cfg then
		local Text = string.format(LSTR(130103), Cfg.Season)
		self.TextSeasonTitle:SetText(Text)
	end
end

function PVPCrystalRoadPanelView:UpdateReward(SeasonID, RankID)
	local Cfg = SeriesMalmstoneSeasonCfg:FindCfgByKey(SeasonID)
	if Cfg then
		local RankType = PVPInfoMgr:GetCrystallineRankType(RankID)
		local LootID = Cfg.RankReward and Cfg.RankReward[RankType] or 0
		local DataList = {}
		local VMList = {}
		local LootCfg = LootMappingCfg:FindCfg(string.format("ID=%d", LootID))
		if LootCfg then
			for _, Program in pairs(LootCfg.Programs or {}) do
				local RewardItemList = ItemUtil.GetLootItems(Program.ID)
				if RewardItemList then
					table.merge_table(DataList, RewardItemList)
				end
			end
		end

		for _, Data in ipairs(DataList) do
			local VM = ItemVM.New()
			VM:UpdateVM(Data, { IsCanBeSelected = false })
			table.insert(VMList, VM)
		end
		
		self.RewardList:UpdateAll(VMList)
	end
end

function PVPCrystalRoadPanelView:UpdateRewardReceived()
	local Count = self.RewardList:GetNum()
	for Index = 1, Count do
		local Data = self.RewardList:GetItemDataByIndex(Index)
		if Data then
			Data.IsMask = true
			Data.IconReceivedVisible = true
		end
	end
end

function PVPCrystalRoadPanelView:ShowRankInfo(RankInfos)
	local function SetRankData(Type, RankNameWidget, TimeWidget, RankWidget)
		local Name = ProtoEnumAlias.GetAlias(ProtoRes.Game.pvp_rank_type, Type)
		if Name then
			if RankNameWidget then
				RankNameWidget:SetText(Name)
			end
		end

		local Time = RankInfos[Type]
		local TimeString = LSTR(130122)
		if Time then
			TimeString = LocalizationUtil.LocalizeStringDate_Timestamp_YMD(Time)
		end
		if TimeWidget then
			TimeWidget:SetText(TimeString)
		end

		local IsAchieved = Time ~= nil
		RankWidget:SetIsAchieved(IsAchieved)
	end
	SetRankData(RankType.RT_BRONZE, self.TextDanBronze, self.TextTimeBronze, self.PVPDanBronze)
	SetRankData(RankType.RT_SILVER, self.TextDanSilver, self.TextTimeSilver, self.PVPDanSilver)
	SetRankData(RankType.RT_GOLD, self.TextDanGold, self.TextTimeGold, self.PVPDanGold)
	SetRankData(RankType.RT_BIRKIN, self.TextDanPlatinum, self.TextTimePlatinum, self.PVPDanPlatinum)
	SetRankData(RankType.RT_DIAMOND, self.TextDanDiamond, self.TextTimeDiamond, self.PVPDanDiamond)
	SetRankData(RankType.RT_CRYSTALE, self.TextDanCrystal, self.TextTimeCrystal, self.PVPDanCrystal)
end

function PVPCrystalRoadPanelView:ShowBattleInfo(Data)
	local BattleCount = Data.BtlNum
	local WinCount = Data.WinNum
	local WinRateText = ""
	if BattleCount ~= 0 then
		local WinRate = WinCount / BattleCount * 100	-- 化作百分比
		WinRateText = string.format(LSTR(130119), WinRate)
	end
	self.TextBattleCount:SetText(BattleCount)
	self.TextWinCount:SetText(WinCount)
	self.TextWinRate:SetText(WinRateText)
	self.TextHighestWinCount:SetText(Data.ContinueWinNum)
	self.TextKillCount:SetText(Data.K)
	self.TextLikeCount:SetText(Data.LikeNum)
	self:SetMostLikeMapText(Data.MapUsedNum)
	self:SetMostLikeProfText(Data.ProfUsedNum)
	self:SetBattleStyleText(Data)
	self.TextFinalRank:SetText(PVPInfoMgr:GetCrystallineRankName(Data.RankID))
	self:SetRankBP(PVPInfoMgr:GetCrystallineRankType(Data.RankID))
	self:SetWinStar(PVPInfoMgr:GetCrystallineRankWinStar(Data.RankID))
end

function PVPCrystalRoadPanelView:SetMostLikeMapText(MapData)
	local MostCount = 0
	local MostCountID = nil
	for PWorldID, Count in pairs(MapData) do
		if Count > MostCount then
			MostCount = Count
			MostCountID = PWorldID
		end
	end

	if MostCountID then
		local PWorldName = PWorldEntUtil.GetPWorldEntName(MostCountID)
		self.TextMostLikeMap:SetText(PWorldName)
	end
end

function PVPCrystalRoadPanelView:SetMostLikeProfText(ProfData)
	local MostCount = 0
	local MostCountProf = nil
	for Prof, Count in pairs(ProfData) do
		if Count > MostCount then
			MostCount = Count
			MostCountProf = Prof
		end
	end

	if MostCountProf then
		local Text = RoleInitCfg:FindRoleInitProfName(MostCountProf)
		self.TextMostLikeProf:SetText(Text)
	end
end

function PVPCrystalRoadPanelView:SetBattleStyleText(Data)
	local Cure = Data.Cure
	local Survival = Data.Survival
	local Output = Data.Output
	local EscortTime = Data.EscortTime
	local Kill = Data.K
	local Death = Data.D
	local Assist = Data.A
	local KDA = Kill + Assist
    local DeathParamCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_BTLLOSSRATE)
    local DeathParam = DeathParamCfg and DeathParamCfg.Value[1]/10000 or 0.35
    local Denominator = Death + DeathParam
    if Denominator ~= 0 then
        KDA = KDA / Denominator
    end
	
	local EscortTimePercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_ESCORT, EscortTime)
    local OutputPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_OUTPUT, Output)
    local SurvivalPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_SURVIVAL, Survival)
    local KDAPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_KDA, KDA)
    local CurePercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_CURE, Cure)
	
	local StyleOrderList = {}
	-- 押运 输出 生存 治疗 战损 相同数值的先展示靠前的
	table.insert(StyleOrderList, { Percent = EscortTimePercent, Text = LSTR(130098) })
	table.insert(StyleOrderList, { Percent = OutputPercent, Text = LSTR(130099) })
	table.insert(StyleOrderList, { Percent = SurvivalPercent, Text = LSTR(130100) })
	table.insert(StyleOrderList, { Percent = CurePercent, Text = LSTR(130102) })
	table.insert(StyleOrderList, { Percent = KDAPercent, Text = LSTR(130101) })

	local HighestIndex = 0
	local HighestPercent = -1
	for Index, Data in ipairs(StyleOrderList) do
		if Data.Percent > HighestPercent then
			HighestIndex = Index
			HighestPercent = Data.Percent
		end
	end

	local Text = ""
	if HighestIndex ~= 0 then
		Text = StyleOrderList[HighestIndex].Text
	end
	self.TextBattleStyle:SetText(Text)
end

function PVPCrystalRoadPanelView:GetDataPercent(DataType, Data)
    local TenKPercent = 0
    local Cfg = CrystallineStatisticParamCfg:FindCfgByKey(DataType)
    if Cfg then
		local Min = Cfg.DiagramMin
		local Max = Cfg.DiagramMax
		local DataMin = Cfg.DiagramDataMin
		local DataMax = Cfg.DiagramDataMax

		local ClampedData = math.clamp(Data, DataMin, DataMax)
        TenKPercent = math.floor(((ClampedData - Min) / (Max - Min)) * 10000)	-- 万分比比较更精确
    end
    return TenKPercent
end

function PVPCrystalRoadPanelView:SetRankBP(RankType)
	local RankBP = PVPInfoDefine.RankBPMap[RankType]
	if not string.isnilorempty(RankBP) then
		local function OnComplete(Widget)
			if Widget then
				if UE.UCommonUtil.IsObjectValid(self.PanelDan) then
					self.PanelDan:AddChildToCanvas(Widget)
					UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
					UIUtil.CanvasSlotSetAlignment(Widget, Alignment)
					UIUtil.CanvasSlotSetOffsets(Widget, Margin)
					self:AddSubView(Widget)
					self.RankWidget = Widget
				else
					WidgetPoolMgr:RecycleWidget(Widget)
				end
			end
		end

		WidgetPoolMgr:CreateWidgetAsyncByName(RankBP, nil, OnComplete, true, true)
	end
end

function PVPCrystalRoadPanelView:SetWinStar(WinStar)
	for Index = 1, PVPInfoMgr:GetCrystallineRankWinStarMax() do
		local VariableName = "PVPColosseumStar" .. Index
		local StarGlow = WinStar >= Index
		self[VariableName]:SetStarGlow(StarGlow)
	end
end

function PVPCrystalRoadPanelView:RemoveShareTimer()
	if self.ShareTimerID then
		self:UnRegisterTimer(self.ShareTimerID)
		self.ShareTimerID = nil
	end
end

function PVPCrystalRoadPanelView:SetWidgetsVisibleWhenShare(Visible)
	UIUtil.SetIsVisible(self.BtnShare, Visible, true)
	UIUtil.SetIsVisible(self.TableViewReward, Visible)
	if self.Params and self.Params.IsShowReward then
		UIUtil.SetIsVisible(self.BtnReward, Visible, true)
	end
end

return PVPCrystalRoadPanelView