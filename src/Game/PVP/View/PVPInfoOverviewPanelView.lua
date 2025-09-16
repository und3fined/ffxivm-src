---
--- Author: Administrator
--- DateTime: 2024-06-03 14:07
--- Description:
---

local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local PVPInfoVM = require ("Game/PVP/VM/PVPInfoVM")
local MajorUtil = require("Utils/MajorUtil")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")
local PworldCfg = require("TableCfg/PworldCfg")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")
local PVPHonorCfg = require("TableCfg/PVPHonorCfg")
local PVPHonorItemVM = require ("Game/PVP/VM/PVPHonorItemVM")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterDynamicEntryBox = require("UI/Adapter/UIAdapterDynamicEntryBox")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")

local EasyTraceMapMgr = _G.EasyTraceMapMgr
local PVPInfoMgr = _G.PVPInfoMgr
local RedDotMgr = _G.RedDotMgr
local UIViewMgr = _G.UIViewMgr
local ModuleOpenMgr = _G.ModuleOpenMgr
local LSTR = _G.LSTR

---@class PVPInfoOverviewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSeries CommBtnMView
---@field BtnTransfer UFButton
---@field JobSlot CommPlayerSimpleJobSlotView
---@field PanelCrystalline UFCanvasPanel
---@field PanelFrontline UFCanvasPanel
---@field PlayerHeadSlot CommHeadView
---@field ProgressBarSeriesExp UFProgressBar
---@field RichTextHonor URichTextBox
---@field RichTextSeries URichTextBox
---@field RichTextSeriesLevel URichTextBox
---@field RichTextSeriesRemainTime URichTextBox
---@field TableViewHonor UTableView
---@field TableViewJob UTableView
---@field TextCrystallineCount UFTextBlock
---@field TextCrystallineName UFTextBlock
---@field TextFrontlineCount UFTextBlock
---@field TextFrontlineName UFTextBlock
---@field TextLikedCount UFTextBlock
---@field TextLikedName UFTextBlock
---@field TextNoUsedJob UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextSeriesExp UFTextBlock
---@field TextTransfer UFTextBlock
---@field TextUsedJob UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPInfoOverviewPanelView = LuaClass(UIView, true)

function PVPInfoOverviewPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSeries = nil
	--self.BtnTransfer = nil
	--self.JobSlot = nil
	--self.PanelCrystalline = nil
	--self.PanelFrontline = nil
	--self.PlayerHeadSlot = nil
	--self.ProgressBarSeriesExp = nil
	--self.RichTextHonor = nil
	--self.RichTextSeries = nil
	--self.RichTextSeriesLevel = nil
	--self.RichTextSeriesRemainTime = nil
	--self.TableViewHonor = nil
	--self.TableViewJob = nil
	--self.TextCrystallineCount = nil
	--self.TextCrystallineName = nil
	--self.TextFrontlineCount = nil
	--self.TextFrontlineName = nil
	--self.TextLikedCount = nil
	--self.TextLikedName = nil
	--self.TextNoUsedJob = nil
	--self.TextPlayerName = nil
	--self.TextSeriesExp = nil
	--self.TextTransfer = nil
	--self.TextUsedJob = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPInfoOverviewPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSeries)
	self:AddSubView(self.JobSlot)
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPInfoOverviewPanelView:OnInit()
	self.BtnSeries.RedDot:SetRedDotIDByID(PVPInfoDefine.RedDotID.SeriesMalmstone)
	self.HonorList = UIAdapterTableView.CreateAdapter(self, self.TableViewHonor, self.OnSelectHonor, true)
	self.MostUsedProfList = UIAdapterTableView.CreateAdapter(self, self.TableViewJob)
	self.InfoBinders = {
		{ "CrystallineBattleCount", UIBinderValueChangedCallback.New(self, nil, self.OnCrystallineBattleCountChanged) },
		{ "FrontlineBattleCount", UIBinderValueChangedCallback.New(self, nil, self.OnFrontlineBattleCountChanged) },
		{ "PVPLikedCount", UIBinderSetText.New(self, self.TextLikedCount) },
		{ "SeriesData", UIBinderValueChangedCallback.New(self, nil, self.OnSeriesDataChanged) },
		{ "HonorData", UIBinderValueChangedCallback.New(self, nil, self.OnHonorDataChanged) },
		{ "MostUsedProf", UIBinderValueChangedCallback.New(self, nil, self.OnMostUsedProfChanged) },
		{ "IsSeriesOpening", UIBinderValueChangedCallback.New(self, nil, self.OnIsSeriesOpeningChanged) },
	}
	self.MajorBinders = {
		{ "Name", UIBinderSetText.New(self, self.TextPlayerName) },
		{ "Prof", UIBinderSetProfIcon.New(self, self.JobSlot.ImgJob) },
		{ "Level", UIBinderSetText.New(self, self.JobSlot.TextLevel) },
		{ "RoleID", UIBinderValueChangedCallback.New(self, nil, self.OnRoleIDChanged) },
	}
end

function PVPInfoOverviewPanelView:OnDestroy()

end

function PVPInfoOverviewPanelView:OnShow()
	self:SetFixText()
	PVPInfoVM:CheckSeriesMalmstoneOpening()
	self:TryAddRemainTimeTimer()
end

function PVPInfoOverviewPanelView:OnHide()

end

function PVPInfoOverviewPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSeries, self.OnClickBtnSeries)
	UIUtil.AddOnClickedEvent(self, self.BtnTransfer, self.OnClickBtnTransfer)
end

function PVPInfoOverviewPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PVPSeriesRewardDataUpdate, self.OnPVPSeriesRewardDataUpdate)	-- 星里路标界面领完奖退出来刷新按钮文本
end

function PVPInfoOverviewPanelView:OnRegisterBinder()
	if PVPInfoVM then
		self:RegisterBinders(PVPInfoVM, self.InfoBinders)
	end

	local MajorVM = MajorUtil.GetMajorRoleVM()
	if MajorVM then
		self:RegisterBinders(MajorVM, self.MajorBinders)
	end
end

function PVPInfoOverviewPanelView:OnSelectHonor(Index, ItemVM, ItemView)
	local Params = {
		HonorID = ItemVM.ID
	}
	UIViewMgr:ShowView(UIViewID.PVPHonorPanel, Params)
end

function PVPInfoOverviewPanelView:OnCrystallineBattleCountChanged(NewValue, OldValue)
	local IsModuleOpen = ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDPvPColosseumCrystal)
	UIUtil.SetIsVisible(self.PanelCrystalline, IsModuleOpen)
	if IsModuleOpen then
		self.TextCrystallineCount:SetText(NewValue)
	end
end

function PVPInfoOverviewPanelView:OnFrontlineBattleCountChanged(NewValue, OldValue)
	local IsModuleOpen = false--目前GM系统解锁会影响判断，等纷争前线开始做才改正式判断 ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDPvPColosseumFrontLine)
	UIUtil.SetIsVisible(self.PanelFrontline, IsModuleOpen)
	if IsModuleOpen then
		self.TextFrontlineCount:SetText(NewValue)
	end
end

function PVPInfoOverviewPanelView:OnSeriesDataChanged(NewValue, OldValue)
	local CurLevel = NewValue and NewValue.Level or 0
	local LevelText = string.format(LSTR(130005), CurLevel)
	self.RichTextSeriesLevel:SetText(LevelText)

	local CurSeasonCfg = PVPInfoMgr:GetCurSeasonSeriesMalmstoneCfg()
	if CurSeasonCfg then
		local ExpText = nil
		local Percent = 0
		if CurLevel >= CurSeasonCfg.LevelMax then
			ExpText = LSTR(130067)
			Percent = 1
		else
			local CurExp = PVPInfoMgr:GetCurSeriesMalmstoneExp()
			local NeedExp = PVPInfoMgr:GetCurSeriesMalmstoneLevelUpExp(CurLevel)
			
			if CurExp and NeedExp then
				ExpText = string.format(LSTR(130051), CurExp, NeedExp)

				if NeedExp ~= 0 then
					Percent = CurExp / NeedExp
				end
			end
		end

		if ExpText then
			self.TextSeriesExp:SetText(ExpText)
		end

		self.ProgressBarSeriesExp:SetPercent(Percent)
	end

	self:SetBtnSeriesText()
end

function PVPInfoOverviewPanelView:OnHonorDataChanged(NewValue, OldValue)
	local Cfgs = PVPHonorCfg:FindAllCfg()
	if Cfgs == nil then return end

	local function OwnHonorSortFunction(VM1, VM2)
		local ID1 = VM1.ID
		local ID2 = VM2.ID
		
		local GetTime1 = PVPInfoMgr:GetHonorGetTime(ID1)
		local GetTime2 = PVPInfoMgr:GetHonorGetTime(ID2)
		if GetTime1 and GetTime2 then
			if GetTime1 ~= GetTime2 then
				return GetTime1 > GetTime2
			end
		end

		local Cfg1 = PVPHonorCfg:FindCfgByKey(ID1)
		local Cfg2 = PVPHonorCfg:FindCfgByKey(ID2)

		if Cfg1 and Cfg2 then
			if Cfg1.SortID ~= Cfg2.SortID then
				return Cfg1.SortID < Cfg2.SortID
			end

			if Cfg1.ID ~= Cfg2.ID then
				return Cfg1.ID < Cfg2.ID
			end
		end
		return false
	end

	local OwnHonorVMList = {}
	local OwnHonorTypeMap = {}
	local OwnHonorMap = NewValue and NewValue.BadgeID or {}
	for ID, GetTime in pairs(OwnHonorMap) do
		local Cfg = PVPHonorCfg:FindCfgByKey(ID)
		if Cfg and self:CheckHonorTypeIsOpen(Cfg.Type) then
			local HonorType = Cfg.Type
			if OwnHonorTypeMap[HonorType] == nil then
				OwnHonorTypeMap[HonorType] = Cfg
			else
				if Cfg.Level > OwnHonorTypeMap[HonorType].Level then
					OwnHonorTypeMap[HonorType] = Cfg
				end
			end
		end
	end

	for _, Cfg in pairs(OwnHonorTypeMap) do
		local VM = PVPHonorItemVM.New()
		VM:UpdateVM(Cfg)
		-- 特殊处理：总览页里的徽章展示类型名，不展示配置名
		VM.Name = ProtoEnumAlias.GetAlias(ProtoRes.Game.pvp_badgetype, Cfg.Type)
		table.insert(OwnHonorVMList, VM)
	end
	table.sort(OwnHonorVMList, OwnHonorSortFunction)

	local function NotOwnHonorSortFunction(VM1, VM2)
		local Cfg1 = PVPHonorCfg:FindCfgByKey(VM1.ID)
		local Cfg2 = PVPHonorCfg:FindCfgByKey(VM2.ID)

		if Cfg1 and Cfg2 then
			if Cfg1.SortID ~= Cfg2.SortID then
				return Cfg1.SortID < Cfg2.SortID
			end

			if Cfg1.ID ~= Cfg2.ID then
				return Cfg1.ID < Cfg2.ID
			end
		end
		return false
	end
	local NotOwnHonorVMList = {}
	local HonorType = ProtoRes.Game.pvp_badgetype
	local TypeCount = 0
	for _, Type in pairs(HonorType) do
		if Type ~= HonorType.BadgeType_None and Type ~= HonorType.BadgeType_MaxValue then
			if self:CheckHonorTypeIsOpen(Type) then
				TypeCount = TypeCount + 1
				if OwnHonorTypeMap[Type] == nil then
					local Cfg = PVPHonorCfg:FindMinLevelCfgByType(Type)
					if Cfg then
						local VM = PVPHonorItemVM.New()
						VM:UpdateVM(Cfg)
						-- 特殊处理：总览页里的徽章展示类型名，不展示配置名
						VM.Name = ProtoEnumAlias.GetAlias(ProtoRes.Game.pvp_badgetype, Cfg.Type)
						table.insert(NotOwnHonorVMList, VM)
					end
				end
			end
		end
	end
	table.sort(NotOwnHonorVMList, NotOwnHonorSortFunction)

	local HonorVMList = {}
	HonorVMList = table.merge_table(HonorVMList, OwnHonorVMList)
	HonorVMList = table.merge_table(HonorVMList, NotOwnHonorVMList)
	self.HonorList:UpdateAll(HonorVMList)
	self.RichTextHonor:SetText(string.format(LSTR(130050), #OwnHonorVMList, TypeCount))
end

function PVPInfoOverviewPanelView:OnMostUsedProfChanged(NewValue, OldValue)
	local HasMostUsedProf = false
	if NewValue and #NewValue > 0 then
		local ProfList = {}
		for _, ProfID in pairs(NewValue) do
			local ProfVM = SimpleProfInfoVM.New()
			ProfVM:UpdateVM({ ProfID = ProfID })
			table.insert(ProfList, ProfVM)
		end
		self.MostUsedProfList:UpdateAll(ProfList)
		HasMostUsedProf = true
	end

	UIUtil.SetIsVisible(self.TextUsedJob, HasMostUsedProf)
	UIUtil.SetIsVisible(self.TableViewJob, HasMostUsedProf)
	UIUtil.SetIsVisible(self.TextNoUsedJob, not HasMostUsedProf)
end

function PVPInfoOverviewPanelView:OnIsSeriesOpeningChanged(NewValue, OldValue)
	if NewValue then
		self:SetBtnSeriesText()
	else
		self.BtnSeries:SetText(LSTR(130046))
	end

	self.BtnSeries:SetIsEnabled(NewValue, true)
end

function PVPInfoOverviewPanelView:OnRoleIDChanged(NewValue, OldValue)
	if NewValue == nil then return end

	self.PlayerHeadSlot:SetInfo(NewValue)
end

function PVPInfoOverviewPanelView:OnClickBtnSeries()
	if PVPInfoVM:GetIsSeriesOpening() == true then
		RedDotMgr:DelRedDotByName(PVPInfoMgr:GetBreakThroughRedDotName())
		UIViewMgr:ShowView(UIViewID.PVPSeriesMalmstonePanel)
	else
		MsgTipsUtil.ShowTipsByID(338034)
	end
end

function PVPInfoOverviewPanelView:OnClickBtnTransfer()
	local PworldIDCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_PVPMAINCITY_SCENERESID)
	if PworldIDCfg then
		local MapID = PworldCfg:GetFirstMapID(PworldIDCfg.Value[1])
		local CrystalType = ProtoRes.TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP
		local SearchCondition = string.format("MapID == %d and Type == %d", MapID, CrystalType)
		local CrystalCfg = TeleportCrystalCfg:FindCfg(SearchCondition)
		if CrystalCfg then
			EasyTraceMapMgr:ShowEasyTraceMap(13026, "", { CrystalID = CrystalCfg.CrystalID })
		end
	end
end

function PVPInfoOverviewPanelView:OnPVPSeriesRewardDataUpdate(Params)
	if Params == nil or Params.UpdateRewards == nil then return end

	self:SetBtnSeriesText()
end

function PVPInfoOverviewPanelView:SetBtnSeriesText()
	local HasSeriesReward = PVPInfoVM:GetHasSeriesReward()
	local NeedBreakThrough = PVPInfoVM:GetNeedBreakThrough()
	local Text = LSTR(130046)
	if NeedBreakThrough then
		Text = LSTR(130041)
	elseif HasSeriesReward then
		Text = LSTR(130047)
	end
	self.BtnSeries:SetText(Text)
end

function PVPInfoOverviewPanelView:SetFixText()
	self.TextCrystallineName:SetText(LSTR(130002))
	self.TextFrontlineName:SetText(LSTR(130027))
	self.TextLikedName:SetText(LSTR(130028))
	self.TextUsedJob:SetText(LSTR(130029))
	self.TextNoUsedJob:SetText(LSTR(130030))
	self.TextTransfer:SetText(LSTR(130031))
	self.RichTextSeries:SetText(LSTR(130039))
end

function PVPInfoOverviewPanelView:CheckHonorTypeIsOpen(HonorType)
	local Cfgs = PVPHonorCfg:FindCfgsByType(HonorType)
	if Cfgs == nil then return false end

	for _, Cfg in pairs(Cfgs) do
		if Cfg.IsOpen == 0 then
			return false
		end
	end

	return true
end

function PVPInfoOverviewPanelView:TryAddRemainTimeTimer()
	local function UpdateRemainTime()
		local RemainTime = PVPInfoMgr:GetCurSeasonSeriesMalmstoneRemainTime()
		if RemainTime > 0 then
			local TimeString = LocalizationUtil.GetCountdownTimeForLongTime(RemainTime)
			if TimeString then
				local Text = string.format(LSTR(130068), TimeString)
				self.RichTextSeriesRemainTime:SetText(Text)
			end
		else
			self.RichTextSeriesRemainTime:SetText(LSTR(130069))
		end
	end

	self:RegisterTimer(UpdateRemainTime, 0, 1, 0)
end

return PVPInfoOverviewPanelView