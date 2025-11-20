---
--- Author: HugoWong
--- DateTime: 2025-07-02 16:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")

local PVPInfoVM = require ("Game/PVP/Info/VM/PVPInfoVM")
local PVPCrystallineLeaderBoardVM = require ("Game/PVP/Info/VM/PVPCrystallineLeaderBoardVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR

---@class PVPCrystallineLeaderBoardPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDownSeason CommDropDownListView
---@field EmptyPanel CommBackpackEmptyView
---@field MajorInfo PVPCrystallineLeaderBoardItemView
---@field RichTextTime URichTextBox
---@field TableViewInfo UTableView
---@field TextProfTitle UFTextBlock
---@field TextRankTitle UFTextBlock
---@field TextRankingTitle UFTextBlock
---@field TextRoleTitle UFTextBlock
---@field TextStarScoreTitle UFTextBlock
---@field TextWinCountTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystallineLeaderBoardPanelView = LuaClass(UIView, true)

function PVPCrystallineLeaderBoardPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDownSeason = nil
	--self.EmptyPanel = nil
	--self.MajorInfo = nil
	--self.RichTextTime = nil
	--self.TableViewInfo = nil
	--self.TextProfTitle = nil
	--self.TextRankTitle = nil
	--self.TextRankingTitle = nil
	--self.TextRoleTitle = nil
	--self.TextStarScoreTitle = nil
	--self.TextWinCountTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystallineLeaderBoardPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDownSeason)
	self:AddSubView(self.EmptyPanel)
	self:AddSubView(self.MajorInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystallineLeaderBoardPanelView:OnInit()
	self.ViewModel = PVPCrystallineLeaderBoardVM.New()
	self.InfoList = UIAdapterTableView.CreateAdapter(self, self.TableViewInfo)
	self.Binders = {
		{ "CurShowSeasonID", UIBinderValueChangedCallback.New(self, nil, self.OnCurShowSeasonIDhanged) },
		{ "SeasonList", UIBinderValueChangedCallback.New(self, nil, self.OnSeasonListChanged) },
		{ "InfoVMList", UIBinderUpdateBindableList.New(self, self.InfoList) },
		{ "CurShowEmpty", UIBinderSetIsVisible.New(self, self.TableViewInfo, true) },
		{ "CurShowEmpty", UIBinderSetIsVisible.New(self, self.MajorInfo, true) },
		{ "CurShowEmpty", UIBinderSetIsVisible.New(self, self.EmptyPanel) },
	}
end

function PVPCrystallineLeaderBoardPanelView:OnDestroy()

end

function PVPCrystallineLeaderBoardPanelView:OnShow()
	self:SetFixText()
end

function PVPCrystallineLeaderBoardPanelView:OnHide()
	self.ViewModel.CurShowSeasonID = 0
end

function PVPCrystallineLeaderBoardPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownSeason, self.OnSelectionChangedSeason)
end

function PVPCrystallineLeaderBoardPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PVPCrystallineRankingInfoUpdate, self.OnCrystallineRankingInfoUpdate)
end

function PVPCrystallineLeaderBoardPanelView:OnRegisterBinder()
	if self.ViewModel then
		local MajorInfoVM = self.ViewModel.MajorInfoVM
		if MajorInfoVM then
			self.MajorInfo:SetParams({ Data = MajorInfoVM})
		end

		self:RegisterBinders(self.ViewModel, self.Binders)
	end
end

function PVPCrystallineLeaderBoardPanelView:OnCurShowSeasonIDhanged(NewValue, OldValue)
	local EmptyText = LSTR(130080)
	local TimeText = ""
	local CurVersionCfg = PVPInfoMgr:GetCurVersionSeriesMalmstoneCfg()
	if CurVersionCfg and CurVersionCfg.SeasonID == NewValue then
		local OpenDelayTime = PVPInfoMgr:GetCrystallineLeaderBoardOpenDelay()
		local BeginTimeString = CurVersionCfg.BeginTime
		local BeginTime = TimeUtil.GetTimeFromServerZoneString(BeginTimeString)
		local OpenTimeTable = os.date("*t", BeginTime)
		OpenTimeTable.hour = OpenTimeTable.hour + OpenDelayTime
		local OpenTime = os.time(OpenTimeTable)
		local ServerTime = TimeUtil.GetServerLogicTime()
		local RemainTime = math.ceil(OpenTime - ServerTime)

		if RemainTime <= 0 then
			local IsSeriesOpening = PVPInfoVM:GetIsSeriesOpening()
			if IsSeriesOpening then
				local EndTimeString = CurVersionCfg.StarRoadEndTime
				if not string.isnilorempty(EndTimeString) then
					local EndTime = TimeUtil.GetTimeFromServerZoneString(EndTimeString)
					local EndTimeText = LocalizationUtil.LocalizeStringDate_Timestamp_YMDHMS(EndTime)
					TimeText = string.format(LSTR(130081), EndTimeText)
				end
			else
				TimeText = LSTR(130090)
			end
		else
			EmptyText = LSTR(130078)
			local TimeString = LocalizationUtil.GetCountdownTimeForLongTime(RemainTime)
			if TimeString then
				TimeText = string.format(LSTR(130077), TimeString)
			end
		end
	else
		TimeText = LSTR(130090)
	end

	self.EmptyPanel:SetTipsContent(EmptyText)
	self.RichTextTime:SetText(TimeText)
end

function PVPCrystallineLeaderBoardPanelView:OnSeasonListChanged(NewValue, OldValue)
	if NewValue == nil then return end

	self.DropDownSeason:UpdateItems(NewValue)
end

function PVPCrystallineLeaderBoardPanelView:OnSelectionChangedSeason(Index, ItemData, ItemView, IsByClick)
	local Data = ItemData.ItemData
	local SeasonID = Data.SeasonID
	self.ViewModel:ShowSeasonInfo(SeasonID)
end

function PVPCrystallineLeaderBoardPanelView:OnCrystallineRankingInfoUpdate(Params)
	if Params == nil then return end

	if self.ViewModel.CurShowSeasonID == Params.SeasonID then
		self.ViewModel:ShowSeasonInfo(Params.SeasonID)
	end
end

function PVPCrystallineLeaderBoardPanelView:SetFixText()
	self.TextRankingTitle:SetText(LSTR(130082))
	self.TextRoleTitle:SetText(LSTR(130083))
	self.TextProfTitle:SetText(LSTR(130084))
	self.TextRankTitle:SetText(LSTR(130085))
	self.TextStarScoreTitle:SetText(LSTR(130086))
	self.TextWinCountTitle:SetText(LSTR(130087))
end

return PVPCrystallineLeaderBoardPanelView