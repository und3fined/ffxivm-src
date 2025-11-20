
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")
local MsgTipsID = require("Define/MsgTipsID")
local EventID = require("Define/EventID")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")

local ItemUtil = require("Utils/ItemUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local DateTimeTools = require("Common/DateTimeTools")
local ItemUtil = require("Utils/ItemUtil")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")

local SeriesMalmstoneSeasonCfg = require("TableCfg/SeriesMalmstoneSeasonCfg")
local SeriesMalmstoneRewardCfg = require("TableCfg/SeriesMalmstoneRewardCfg")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")
local CrystallineRankCfg = require("TableCfg/CrystallineRankCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")

local UIBindableList = require("UI/UIBindableList")

local PVPInfoVM = require ("Game/PVP/Info/VM/PVPInfoVM")
local ItemVM = require("Game/Item/ItemVM")

local PVP_COLOSSEUM_CMD = ProtoCS.Game.PvPColosseum.CS_PVPCOLOSSEUM_CMD
local PVP_BTLMTL_TYPE = ProtoCS.Game.PvPColosseum.PvPColosseumBtlMtlType
local PVP_SEASON_REWARD_TYPE = ProtoCS.Game.PvPColosseum.PvPSeasonRewardType

local GameNetworkMgr = nil
local EventMgr = nil
local MountMgr = nil
local PWorldMgr = nil
local ScoreMgr = nil
local ChatMgr = nil
local RedDotMgr = nil
local UIViewMgr = nil
local ModuleOpenMgr = nil
local BagMgr = nil
local LSTR = nil
local FLOG_ERROR = nil
local FLOG_INFO = nil

local CS_CMD = ProtoCS.CS_CMD
local UVersionMgr = _G.UE.UVersionMgr

local PVPInfoMgr = LuaClass(MgrBase)

function PVPInfoMgr:OnInit()
	self:ResetData()
end

function PVPInfoMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    EventMgr = _G.EventMgr
    MountMgr = _G.MountMgr
    PWorldMgr = _G.PWorldMgr
    ChatMgr = _G.ChatMgr
    UIViewMgr = _G.UIViewMgr
	ScoreMgr = _G.ScoreMgr
	RedDotMgr = _G.RedDotMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
	BagMgr = _G.BagMgr
    LSTR = _G.LSTR
    FLOG_ERROR = _G.FLOG_ERROR
    FLOG_INFO = _G.FLOG_INFO
end

function PVPInfoMgr:OnEnd()
    GameNetworkMgr = nil
    EventMgr = nil
    MountMgr = nil
    PWorldMgr = nil
    ChatMgr = nil
	ScoreMgr = nil
	RedDotMgr = nil
    UIViewMgr = nil
	BagMgr = nil
    ModuleOpenMgr = nil
	BagMgr = nil
    LSTR = nil
    FLOG_ERROR = nil
    FLOG_INFO = nil
end

function PVPInfoMgr:OnShutdown()
	self:ResetData()
end

function PVPInfoMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)	-- 新系统解锁
end

function PVPInfoMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.BTLMATERIALS, self.OnNetRspBattleMaterialsQuery)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.STAR_ROADSIGN_REWARD, self.OnNetRspSeriesMalmstoneReward)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.STAR_ROADSIGN_LEVELUP_NTF, self.OnNetNtySeriesMalmstoneLevelUp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.BADGE_UPDATE, self.OnNetNtyHonorUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.SEASON_RANK, self.OnNetRspCrystallineRankingInfo)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.SEASON_REWARD, self.OnNetRspCrystallineSeasonReward)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.SEASON_RANK_HISTORY, self.OnNetRspCrystallineRankRecord)
end

function PVPInfoMgr:ResetData()
	self.BreakThroughRedDotName = nil
	self.SeasonStartTimerID = nil
	self.SeasonEndTimerID = nil
	self.WeeklyUpdateTimerID = nil
	self.HasInitCurVersionCfg = false
	self.CurVersionCfg = nil
	self.HasInitCurSeasonCfg = false
	self.CurSeasonCfg = nil
	self.SeriesMalmstoneAtLeastShowDay = nil
	self.CrystallineExerciseStartTimeData = nil
	self.CrystallineExerciseEndTimeData = nil
	self.CrystallineRankStartTimeData = nil
	self.CrystallineRankEndTimeData = nil
	self.CrystallineChangeMapTime = nil
	self.CrystallineExercisePWorldList = nil
	self.CrystallineRankPWorldList = nil
	self.CrystallineRankWinStarMax = nil
	self.CrystallineRankingInfoTimer1 = nil
	self.CrystallineRankingInfoTimer2 = nil
	self.CrystallineRankingInfoTimer3 = nil
end

-- region GameEvent

function PVPInfoMgr:OnPWorldReady()
	self:QueryData()

    -- 连接上服务器才能拉到服务器时间，所以不能在OnBegin就加Timer，这样时间会不准，进入地图后拿到正确时间再加，重连时也刷新一下Timer
	-- 游戏中赛季变化时请求新数据
	self:TryAddSeasonChangeTimer()
    -- 游戏中数据周更新时请求新数据
	self:TryAddWeeklyUpdateTimer()
	-- 水晶冲突排行榜刷新时间
	self:TryAddCrystallineRankingInfoUpdateTimer()
end

function PVPInfoMgr:OnModuleOpenNotify(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDBattle then
		self:QueryOverviewData()
	elseif ModuleID == ProtoCommon.ModuleID.ModuleIDPvPColosseumCrystal then
		self:QueryCrystalData()
		self:QueryCrystallineRankRecordData()
	end
end

---@private
--- 请求系统数据
function PVPInfoMgr:QueryData()
	self:QueryOverviewData()
	self:QueryCrystalData()
	self:QueryCrystallineRankRecordData()
end

-- endregion GameEvent

-- region NetMsgReq

--- 请求对战总览数据
function PVPInfoMgr:QueryOverviewData()
	local IsModuleOpen = ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattle)
	if IsModuleOpen then
		self:QueryPVPData(PVP_BTLMTL_TYPE.BMTOverview)
	end
end

--- 请求水晶冲突表现数据
function PVPInfoMgr:QueryCrystalData()
	local IsModuleOpen = ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDPvPColosseumCrystal)
	if IsModuleOpen then
		self:QueryPVPData(PVP_BTLMTL_TYPE.BMTCrystal)
	end
end

--- 请求对战数据
function PVPInfoMgr:QueryPVPData(DataType)
	local PvPColosseumBtlMtlReq = {
		Type = DataType
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.BTLMATERIALS, "BtlMtlReq", PvPColosseumBtlMtlReq)
end

--- 请求领取星里路标奖励
---@param IDList table 需要领取的奖励ID列表
function PVPInfoMgr:RequestReceiveReward(IDList)
	if IDList == nil or #IDList == 0 then return end

	if not self:CheckSeriesMalmstoneRewardSpace(IDList) then return end

	local PvPStarRoadSignRewardReq = {
		ID = IDList
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.STAR_ROADSIGN_REWARD, "StarRoadSignRewardReq", PvPStarRoadSignRewardReq)
end

--- 请求水晶冲突排行榜数据
function PVPInfoMgr:QueryCrystallineRankingInfo(SeasonID)
	if SeasonID == nil or SeasonID == 0 then return end

	local PvPColosseumSeasonRankReq = {
		SeasonID = SeasonID
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.SEASON_RANK, "PvPColosseumSeasonRankReq", PvPColosseumSeasonRankReq)
end

--- 请求水晶冲突历史赛季数据
function PVPInfoMgr:QueryCrystallineRankRecordData()
	local IsModuleOpen = ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDPvPColosseumCrystal)
	if IsModuleOpen then
		local PvPColosseumSeasonRankHistoryReq = {}
		self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.SEASON_RANK_HISTORY, "PvPColosseumSeasonRankHistoryReq", {PvPColosseumSeasonRankHistoryReq})
	end
end

--- 请求领取水晶冲突赛季奖励
function PVPInfoMgr:RequestCrystallineSeasonReward(RewardType, SeasonID)
	if RewardType == nil or SeasonID == nil or RewardType == PVP_SEASON_REWARD_TYPE.PvPSeasonRewardType_NONE then return end

	local PvPColosseumSeasonRewardReq = {
		Type = RewardType,
		SeasonID = SeasonID
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.SEASON_REWARD, "PvPColosseumSeasonRewardReq", PvPColosseumSeasonRewardReq)
end

function PVPInfoMgr:SendPVPNetMsg(SubMsgID, DataKey, Data)
	local CsReq = {
		Cmd = SubMsgID
	}

    if DataKey ~= nil then
        CsReq[DataKey] = Data
    end

	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PvPColosseum, SubMsgID, CsReq)
end

-- endregion NetMsgReq

-- region NetMsgRes

function PVPInfoMgr:OnNetRspBattleMaterialsQuery(MsgBody)
	local Rsp = MsgBody and MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	local Type = Rsp.Type
	local Data = Rsp[Rsp.Data]

	if Type == PVP_BTLMTL_TYPE.BMTOverview then
		PVPInfoVM:SetPVPOverviewData(Data)
		self:CheckRedDot()
	elseif Type == PVP_BTLMTL_TYPE.BMTCrystal then
		PVPInfoVM:SetPVPCrystalData(Data)
	end
end

function PVPInfoMgr:OnNetRspSeriesMalmstoneReward(MsgBody)
	local Rsp = MsgBody and MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	PVPInfoVM:UpdateSeriesMalmstoneRewardData(Rsp.ID)
	self:CheckRedDot()
	self:ShowRewardPanel(Rsp.RewardItems)
	EventMgr:SendEvent(EventID.PVPSeriesRewardDataUpdate, { UpdateRewards = Rsp.ID })
end

function PVPInfoMgr:OnNetNtySeriesMalmstoneLevelUp(MsgBody)
	if _G.PWorldMgr:CurrIsInPVPColosseum() then
		self:RegisterTimer(function()
			MsgTipsUtil.ShowTipsByID(MsgTipsID.SeriesMalmstoneLevelUp)
        end, 2)
	else
		MsgTipsUtil.ShowTipsByID(MsgTipsID.SeriesMalmstoneLevelUp)

		-- 局内出来会请求全量数据，不用独立更新，局外独立更新一下
		local NtfData = MsgBody and MsgBody[MsgBody.Data]
		if NtfData then
			local Data = NtfData[NtfData.Result]
			if Data then
				PVPInfoVM:SetSeriesMalmstoneData(Data)
				self:CheckRedDot()
				EventMgr:SendEvent(EventID.PVPSeriesDataUpdate)
			end
		end
	end
end

function PVPInfoMgr:OnNetNtyHonorUpdate(MsgBody)
	local NtfData = MsgBody and MsgBody[MsgBody.Data]
	if NtfData == nil then return end
	local Data = NtfData[NtfData.PvpBadgeResult]
	if Data == nil then return end
    
	PVPInfoVM:SetHonorData(Data)
end

function PVPInfoMgr:OnNetRspCrystallineRankingInfo(MsgBody)
	local Rsp = MsgBody and MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	local SeasonID = Rsp.SeasonID
	local RankingInfo = Rsp.TopRank
	local RankingInfoSelf = Rsp.SelfRankInfo
	if SeasonID ~= 0 then
		PVPInfoVM:SetCrystallineRankingInfoSelf(SeasonID, RankingInfoSelf)
		PVPInfoVM:SetCrystallineRankingInfo(SeasonID, RankingInfo)

		local Params = {
			SeasonID = SeasonID,
			SelfInfo = RankingInfoSelf,
			RankingInfo = RankingInfo,
		}
		EventMgr:SendEvent(EventID.PVPCrystallineRankingInfoUpdate, Params)
	end
end

function PVPInfoMgr:OnNetRspCrystallineSeasonReward(MsgBody)
	local Rsp = MsgBody and MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	local EventType = nil
	if Rsp.Type == PVP_SEASON_REWARD_TYPE.PvPSeasonRewardType_Rank then
		EventType = EventID.PVPCrystallineRankingRewardReceived
		MsgTipsUtil.ShowTipsByID(338050)	-- 领取成功
	elseif Rsp.Type == PVP_SEASON_REWARD_TYPE.PvPSeasonRewardType_Seg then
		EventType = EventID.PVPCrystallineRankRewardReceived
		self:ShowRewardPanel(Rsp.Items)
		PVPInfoVM:SetSetHasGetLaskSeasonRankReward(true)
	end

	if EventType then
		EventMgr:SendEvent(EventType, { SeasonID = Rsp.SeasonID, Type = Rsp.Type })
	end
end

function PVPInfoMgr:OnNetRspCrystallineRankRecord(MsgBody)
	local Rsp = MsgBody and MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	local HistoryData = Rsp.SeasonRankHistory or {}
	for _, Record in ipairs(HistoryData) do
		PVPInfoVM:SetCrystallineRankRecordData(Record.SeasonID, Record)
	end

	PVPInfoVM:SetHasGetLaskSeasonRankReward(Rsp.GetLastRankSegReward)
end

-- endregion NetMsgRes

-- region Private Function

---@private
function PVPInfoMgr:CheckRedDot()
	local CurSeasonCfg = self:GetCurSeasonSeriesMalmstoneCfg()
	if CurSeasonCfg == nil then
		if self.BreakThroughRedDotName then
			RedDotMgr:DelRedDotByName(self.BreakThroughRedDotName)
			self.BreakThroughRedDotName = nil
		end

		local RewardRedDotName = RedDotMgr:GetRedDotNameByID(PVPInfoDefine.RedDotID.SeriesMalmstoneReward)
		if RewardRedDotName then
			RedDotMgr:DelRedDotByName(RewardRedDotName)
		end

        return
    end
	
	if PVPInfoVM:GetNeedBreakThrough() then
		local BreakThroughLevel = PVPInfoVM:GetSeriesMalmstoneLevel() + 1
		local ParentRedDotName = RedDotMgr:GetRedDotNameByID(PVPInfoDefine.RedDotID.SeriesMalmstoneBreakThrough)
		if ParentRedDotName then
			local CurRedDotName = ParentRedDotName .. "/" .. CurSeasonCfg.SeasonID .. "/" .. BreakThroughLevel
			if RedDotMgr:GetIsSaveDelRedDotByName(CurRedDotName) == false then
				RedDotMgr:AddRedDotByName(CurRedDotName, nil, true)
				self.BreakThroughRedDotName = CurRedDotName
			end
		end
	end

	local RewardRedDotName = RedDotMgr:GetRedDotNameByID(PVPInfoDefine.RedDotID.SeriesMalmstoneReward)
	if RewardRedDotName then
		if PVPInfoVM:GetHasSeriesReward() then
			RedDotMgr:AddRedDotByName(RewardRedDotName, nil, true)
		else
			RedDotMgr:DelRedDotByName(RewardRedDotName)
		end
	end
end

---@private
function PVPInfoMgr:TryAddSeasonChangeTimer()
	local CurVersionCfg = self:GetCurVersionSeriesMalmstoneCfg()
	if CurVersionCfg then
		local BeginTimeString = CurVersionCfg.StarRoadBeginTime
		if not string.isnilorempty(BeginTimeString) then
			local ServerTime = TimeUtil.GetServerLogicTime()
			local BeginTime = TimeUtil.GetTimeFromServerZoneString(BeginTimeString)
			local RemainTime = math.ceil(BeginTime - ServerTime)
			if RemainTime > 0 then
				self:ClearSeasonStartTimer()
				FLOG_INFO(string.format("[PVPInfoMgr][TryAddSeasonChangeTimer]Add season begin timer: %s", DateTimeTools.TimeFormat(RemainTime, "smart-h-m-s", true)))
				self.SeasonStartTimerID = self:RegisterTimer(function()
					self.SeasonStartTimerID = nil
					self:QueryData()
					self.CurSeasonCfg = CurVersionCfg
					PVPInfoVM:SetIsSeriesOpening(true)
				end, RemainTime)
			end
		end

		local EndTimeString = CurVersionCfg.StarRoadEndTime
		if not string.isnilorempty(EndTimeString) then
			local ServerTime = TimeUtil.GetServerLogicTime()
			local EndTime = TimeUtil.GetTimeFromServerZoneString(EndTimeString)
			local RemainTime = math.ceil(EndTime - ServerTime)
			if RemainTime > 0 then
				self:ClearSeasonEndTimer()
				FLOG_INFO(string.format("[PVPInfoMgr][TryAddSeasonChangeTimer]Add season end timer: %s", DateTimeTools.TimeFormat(RemainTime, "smart-h-m-s", true)))
				self.SeasonEndTimerID = self:RegisterTimer(function()
					self.SeasonEndTimerID = nil
					self:QueryData()
					if CurVersionCfg.Season ~= 0 then
						FLOG_INFO("[PVPInfoMgr][TryAddSeasonChangeTimer]Season end remove query ranking timer")
						self:ClearCrystallineRankingInfoUpdateTimer()
						FLOG_INFO("[PVPInfoMgr][TryAddSeasonChangeTimer]Season end query final ranking")
						self:QueryCrystallineRankingInfo(CurVersionCfg.SeasonID)
					end
					PVPInfoVM:SetIsSeriesOpening(false)
					self.CurSeasonCfg = nil
				end, RemainTime)
			end
		end
	end
end

---@private
function PVPInfoMgr:ClearSeasonStartTimer()
	if self.SeasonStartTimerID then
		self:UnRegisterTimer(self.SeasonStartTimerID)
		self.SeasonStartTimerID = nil
	end
end

---@private
function PVPInfoMgr:ClearSeasonEndTimer()
	if self.SeasonEndTimerID then
		self:UnRegisterTimer(self.SeasonEndTimerID)
		self.SeasonEndTimerID = nil
	end
end

---@private
function PVPInfoMgr:TryAddWeeklyUpdateTimer()
	local RemainTime = 0
	local UpdateWeekDay = PVPInfoDefine.SeriesMalmstoneDataWeeklyUpdateTime.WeekDay
	local UpdateHour = PVPInfoDefine.SeriesMalmstoneDataWeeklyUpdateTime.Hour
	local UpdateSec = UpdateWeekDay * 24 * 3600 + UpdateHour * 3600	-- 更新时间对于周日0点经过了多少秒
	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerDate = os.date("*t", ServerTime)
	local CurSec = (ServerDate.wday - 1) * 24 * 3600 + ServerDate.hour * 3600 + ServerDate.min * 60 + ServerDate.sec --当前时间相对于周日0点过了多久
	local WeekCycleTime = 7 * 24 * 3600

	if ServerDate.wday <= UpdateWeekDay and ServerDate.hour < UpdateHour then --没有到周一更新时间
		RemainTime = UpdateSec - CurSec
	else --超过了周一更新时间则要算到下周更新时间
		RemainTime = 7 * 24 * 3600 - (CurSec - UpdateSec)
	end
	
	self:ClearWeeklyUpdateTimer()
	self.WeeklyUpdateTimerID = self:RegisterTimer(function()
		self:QueryData()
	end, RemainTime, WeekCycleTime, 0)
end

---@private
function PVPInfoMgr:ClearWeeklyUpdateTimer()
	if self.WeeklyUpdateTimerID then
		self:UnRegisterTimer(self.WeeklyUpdateTimerID)
		self.WeeklyUpdateTimerID = nil
	end
end

---@private
function PVPInfoMgr:TryAddCrystallineRankingInfoUpdateTimer()
	local CurSeasonCfg = self:GetCurSeasonSeriesMalmstoneCfg()
	if CurSeasonCfg == nil or CurSeasonCfg.Season == 0 then return end

	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerDate = os.date("*t", ServerTime)
	local UpdateSec = 0
	local UpdateTimeCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_RANK_UPDATE_TIME)
	local Time1Hour = UpdateTimeCfg and UpdateTimeCfg.Value[1] or 0
	local Time1Min = UpdateTimeCfg and UpdateTimeCfg.Value[2] or 0
	local Time2Hour = UpdateTimeCfg and UpdateTimeCfg.Value[3] or 10
	local Time2Min = UpdateTimeCfg and UpdateTimeCfg.Value[4] or 0
	local Time3Hour = UpdateTimeCfg and UpdateTimeCfg.Value[5] or 18
	local Time3Min = UpdateTimeCfg and UpdateTimeCfg.Value[6] or 0
	local DayCycleTime = 24 * 60 * 60
	
	local function AddTimer(UpdateHour, UpdateMin, UpdateSec)
		local UpdateTime = UpdateHour * 60 * 60 + UpdateMin * 60 + UpdateSec
		local RemainTime = UpdateTime - (ServerDate.hour * 60 * 60 + ServerDate.min * 60 + ServerDate.sec)
		if RemainTime < 0 then
			RemainTime = DayCycleTime + RemainTime
		end

		if RemainTime then
			return self:RegisterTimer(function()
				if CurSeasonCfg and CurSeasonCfg.Season ~= 0 then
					FLOG_INFO(string.format("[PVPInfoMgr][TryAddCrystallineRankingInfoUpdateTimer]Update ranking info: %2d:%2d:%2d", UpdateHour, UpdateMin, UpdateSec))
					self:QueryCrystallineRankingInfo(CurSeasonCfg.SeasonID)
				end
			end, RemainTime, DayCycleTime, 0)
		end
	end

	self:ClearCrystallineRankingInfoUpdateTimer()
	self.CrystallineRankingInfoTimer1 = AddTimer(Time1Hour, Time1Min, UpdateSec)
	self.CrystallineRankingInfoTimer2 = AddTimer(Time2Hour, Time2Min, UpdateSec)
	self.CrystallineRankingInfoTimer3 = AddTimer(Time3Hour, Time3Min, UpdateSec)
end

---@private
function PVPInfoMgr:ClearCrystallineRankingInfoUpdateTimer()
	if self.CrystallineRankingInfoTimer1 then
		self:UnRegisterTimer(self.CrystallineRankingInfoTimer1)
		self.CrystallineRankingInfoTimer1 = nil
	end
	if self.CrystallineRankingInfoTimer2 then
		self:UnRegisterTimer(self.CrystallineRankingInfoTimer2)
		self.CrystallineRankingInfoTimer2 = nil
	end
	if self.CrystallineRankingInfoTimer3 then
		self:UnRegisterTimer(self.CrystallineRankingInfoTimer3)
		self.CrystallineRankingInfoTimer3 = nil
	end
end

---@private
function PVPInfoMgr:ShowRewardPanel(Rewards)
	local Params = {}
	Params.Title = LSTR(130071)

	local VMList = UIBindableList.New(ItemVM)
	local RewardList = {}
	for _, Reward in ipairs(Rewards) do
		if RewardList[Reward.ItemID] ~= nil then
			RewardList[Reward.ItemID].Num = RewardList[Reward.ItemID].Num + Reward.ItemNum
		else
			RewardList[Reward.ItemID] = { ResID = Reward.ItemID, Num = Reward.ItemNum }
		end
	end
	for _, Reward in pairs(RewardList) do
		VMList:AddByValue({GID = 1, ResID = Reward.ResID, Num = Reward.Num, IsValid = true, NumVisible = true, ItemNameVisible = true })
	end
	Params.ItemVMList = VMList
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
end

---@private
function PVPInfoMgr:CheckSeriesMalmstoneRewardSpace(IDList)
	if IDList == nil or #IDList == 0 then return false end

	local BagItemMap = {}
	local ScoreItemMap = {}

	for _, ID in pairs(IDList) do
		local Cfg = SeriesMalmstoneRewardCfg:FindCfgByKey(ID)
		if Cfg then
			local ItemID = Cfg.BasicReward[1].ID
			local ItemNum = Cfg.BasicReward[1].Num
			if ItemUtil.ItemIsScore(ItemID) then
				local ItemCurNum = ScoreItemMap[ItemID] or 0
				ScoreItemMap[ItemID] = ItemCurNum + ItemNum

				local Residual = ScoreMgr:GetScoreResidualValue(ItemID)
				if ScoreItemMap[ItemID] > Residual then
					MsgTipsUtil.ShowTipsByID(338049)	-- 战利水晶超出上限
					return false
				end
			else
				local ItemCurNum = BagItemMap[ItemID] or 0
				BagItemMap[ItemID] = ItemCurNum + ItemNum
			end
		end
	end

	local BagNeedSpace = BagMgr:CheckLootItemInfo(BagItemMap, true)
	if BagNeedSpace > BagMgr:GetBagLeftNum() then
		MsgTipsUtil.ShowTipsByID(338054)	-- 背包已满
		return false
	end

	return true
end

-- endregion

-- region Public Interface

--- 获取当前水晶冲突段位
---@return uint32 段位ID
function PVPInfoMgr:GetCurCrystallineRank()
	return PVPInfoVM:GetCurCrystallineRank()
end

--- 获取当前赛季水晶冲突最高段位
---@return uint32 段位ID
function PVPInfoMgr:GetSeasonHighestCrystallineRank()
	return PVPInfoVM:GetSeasonHighestCrystallineRank()
end

--- 是否拥有某荣耀徽章
---@param HonorID uint32 荣耀徽章ID
---@return boolean 是否拥有
function PVPInfoMgr:IsOwnHonor(HonorID)
	return PVPInfoVM:IsOwnHonor(HonorID)
end

--- 获取荣耀徽章获得时间
---@param HonorID uint32 荣耀徽章ID
---@return boolean 是否拥有
function PVPInfoMgr:GetHonorGetTime(HonorID)
	return PVPInfoVM:GetHonorGetTime(HonorID)
end

--- 获取荣耀徽章达成参数
---@param HonorID uint32 荣耀徽章ID
---@return int32 参数计数
function PVPInfoMgr:GetHonorParam(HonorID)
	return PVPInfoVM:GetHonorParam(HonorID)
end

--- 该目标是否已突破，只针对【还没突破的等级】，【已突破的等级】服务器会清空【目标】计数
---@param TargetID uint32 目标ID
---@return boolean 是否已突破
---@return int32 目标计数
function PVPInfoMgr:IsTargetBrokeThrough(TargetID)
	return PVPInfoVM:IsTargetBrokeThrough(TargetID)
end

--- 是否已领取该等级奖励
---@param Level uint32 等级
---@return boolean 是否已领取
function PVPInfoMgr:IsReceivedRewardByLevel(Level)
	local CurLevelCfg = self:GetSeriesMalmstoneLevelCfg(Level)
	if CurLevelCfg == nil then return true end
	return PVPInfoVM:IsReceivedReward(CurLevelCfg.ID)
end

--- 是否已领取奖励
---@param ID uint32 配置ID
---@return boolean 是否已领取
function PVPInfoMgr:IsReceivedRewardByID(ID)
	return PVPInfoVM:IsReceivedReward(ID)
end

--- 获取星里路标等级
---@return int32 等级
function PVPInfoMgr:GetSeriesMalmstoneLevel()
	return PVPInfoVM:GetSeriesMalmstoneLevel()
end

--- 获取星里路标当前经验
---@return int32 经验
function PVPInfoMgr:GetCurSeriesMalmstoneExp()
	if ScoreMgr == nil then
		FLOG_ERROR("PVPInfoMgr:GetCurSeriesMalmstoneExp ScoreMgr nil")
		return 0
	end

	return ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_SERIES_EXP)
end

--- 获取当前星里路标等级升级所需经验
---@param Level uint32 等级
---@return int32 经验
function PVPInfoMgr:GetSeriesMalmstoneLevelUpExp(Level)
	local CurLevelCfg = self:GetSeriesMalmstoneLevelCfg(Level)
	return CurLevelCfg and CurLevelCfg.UpExp or 0
end

--- 获取当前游戏版本星里路标配置
---@return table 配置列
function PVPInfoMgr:GetCurVersionSeriesMalmstoneCfg()
	if self.HasInitCurVersionCfg then
		return self.CurVersionCfg
	else
		local CurVersionCfg = nil
		local Cfgs = SeriesMalmstoneSeasonCfg:FindAllCfg()
		if Cfgs then
			for _, Cfg in pairs(Cfgs) do
				local BeginVersion = Cfg.BeginVersion
				local EndVersion = Cfg.EndVersion

				if not string.isnilorempty(BeginVersion) and not string.isnilorempty(EndVersion) then
					-- 开始版本 <= 目前版本 < 结束版本
					local IsBelowOrEqualCurVersion = UVersionMgr.IsBelowOrEqualGameVersion(BeginVersion)
					local IsAboveCurVersion = not UVersionMgr.IsBelowOrEqualGameVersion(EndVersion)

					if IsBelowOrEqualCurVersion and IsAboveCurVersion then
						CurVersionCfg = Cfg
						break
					end
				end
			end
		end

		self.HasInitCurVersionCfg = true
		self.CurVersionCfg = CurVersionCfg
		return CurVersionCfg
	end
end

--- 获取本赛季星里路标配置
---@return table 配置列
function PVPInfoMgr:GetCurSeasonSeriesMalmstoneCfg()
	if self.HasInitCurSeasonCfg then
		return self.CurSeasonCfg
	else
		local CurSeasonCfg = nil
		local Cfg = self:GetCurVersionSeriesMalmstoneCfg()
		if Cfg then
			local BeginTimeString = Cfg.StarRoadBeginTime
			local EndTimeString = Cfg.StarRoadEndTime

			local ServerTime = TimeUtil.GetServerLogicTime()
			local IsAfterBeginTime = false
			local IsBeforeEndTime = false
			
			if not string.isnilorempty(BeginTimeString) then
				local BeginTime = TimeUtil.GetTimeFromServerZoneString(BeginTimeString)
				IsAfterBeginTime = ServerTime >= BeginTime
			end

			if not string.isnilorempty(EndTimeString) then
				local EndTime = TimeUtil.GetTimeFromServerZoneString(EndTimeString)
				IsBeforeEndTime = ServerTime < EndTime
			end

			if IsAfterBeginTime and IsBeforeEndTime then
				CurSeasonCfg = Cfg
			end
		end

		self.HasInitCurSeasonCfg = true
		self.CurSeasonCfg = CurSeasonCfg
		PVPInfoVM:SetIsSeriesOpening(CurSeasonCfg ~= nil)
		return CurSeasonCfg
	end
end

--- 获取当前版本星里路标某等级配置
---@param Level uint32 等级
---@return table 配置列
function PVPInfoMgr:GetSeriesMalmstoneLevelCfg(Level)
	local Cfg = self:GetCurVersionSeriesMalmstoneCfg()
	if Cfg == nil then return nil end

	local SearchCondition = string.format("GroupID == %d AND Level == %d", Cfg.LevelGroup, Level)
	local CurLevelCfg = SeriesMalmstoneRewardCfg:FindCfg(SearchCondition)

    return CurLevelCfg
end

--- 获取星里路标经验积分类型
---@return ProtoRes.SCORE_TYPE 积分类型
function PVPInfoMgr:GetSeriesMalmstoneExpScoreType()
	return ProtoRes.SCORE_TYPE.SCORE_TYPE_SERIES_EXP
end

--- 获取PVP战利水晶积分类型
---@return ProtoRes.SCORE_TYPE 积分类型
function PVPInfoMgr:GetPVPTrophyCrystalScoreType()
	return ProtoRes.SCORE_TYPE.SCORE_TYPE_ZL_CRYSTAL
end

--- 获取当前突破等级红点名
---@return string 红点名
function PVPInfoMgr:GetBreakThroughRedDotName()
	return self.BreakThroughRedDotName
end

--- 获取本赛季星里路标剩余时间
---@return uint32 剩余时间(秒)
function PVPInfoMgr:GetCurSeasonSeriesMalmstoneRemainTime()
    local RemainTime = 0

    local Cfg = self:GetCurSeasonSeriesMalmstoneCfg()
    if Cfg then
		local EndTimeString = Cfg.StarRoadEndTime
		if not string.isnilorempty(EndTimeString) then
			local ServerTime = TimeUtil.GetServerLogicTime()
			local EndTime = TimeUtil.GetTimeFromServerZoneString(EndTimeString)
			RemainTime = EndTime - ServerTime
		end
    end

    return RemainTime
end

--- 获取星里路标最少展示天数
---@return uint32 天数
function PVPInfoMgr:GetSeriesMalmstoneAtLeastShowDay()
	if self.SeriesMalmstoneAtLeastShowDay then
		return self.SeriesMalmstoneAtLeastShowDay
	else
		local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_STARROADSIGNS)
		self.SeriesMalmstoneAtLeastShowDay = Cfg and Cfg.Value[1] or 45
		return self.SeriesMalmstoneAtLeastShowDay
    end
end

--- 获取水晶冲突匹配功能是否开启
function PVPInfoMgr:GetPVPMatchAvailable(EntType)
	local IsAvailable = false

	if PWorldEntUtil.IsCrystallineExercise(EntType) then
        local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_EXCERSIZE_SWITCH)
		IsAvailable = Cfg and Cfg.Value[1] == 1
	elseif PWorldEntUtil.IsCrystallineRank(EntType) then
        local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_RANK_SWITCH)
		IsAvailable = Cfg and Cfg.Value[1] == 1
	end

	return IsAvailable
end

--- 获取水晶冲突练习赛匹配开始时间
---@return table Timetable
function PVPInfoMgr:GetCrystallineExerciseStartTimeData()
	if self.CrystallineExerciseStartTimeData then
		return self.CrystallineExerciseStartTimeData
	else
        local StartTimeCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_ACTTIMEBEGIN)
		self.CrystallineExerciseStartTimeData = {
			hour = StartTimeCfg and StartTimeCfg.Value[1] or 12,
			min = StartTimeCfg and StartTimeCfg.Value[2] or 0,
			sec = StartTimeCfg and StartTimeCfg.Value[3] or 0,
		}
		return self.CrystallineExerciseStartTimeData
	end
end

--- 获取水晶冲突练习赛匹配结束时间
---@return table Timetable
function PVPInfoMgr:GetCrystallineExerciseEndTimeData()
	if self.CrystallineExerciseEndTimeData then
		return self.CrystallineExerciseEndTimeData
	else
        local EndTimeCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_ACTTIMEEND)
		self.CrystallineExerciseEndTimeData = {
			hour = EndTimeCfg and EndTimeCfg.Value[1] or 23,
			min = EndTimeCfg and EndTimeCfg.Value[2] or 59,
			sec = EndTimeCfg and EndTimeCfg.Value[3] or 59,
		}
		return self.CrystallineExerciseEndTimeData
	end
end

--- 获取水晶冲突段位赛匹配开始时间
---@return table Timetable
function PVPInfoMgr:GetCrystallineRankStartTimeData()
	if self.CrystallineRankStartTimeData then
		return self.CrystallineRankStartTimeData
	else
        local StartTimeCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_RANK_ACT_BEGINTIME)
		self.CrystallineRankStartTimeData = {
			hour = StartTimeCfg and StartTimeCfg.Value[1] or 19,
			min = StartTimeCfg and StartTimeCfg.Value[2] or 0,
			sec = StartTimeCfg and StartTimeCfg.Value[3] or 0,
		}
		return self.CrystallineRankStartTimeData
	end
end

--- 获取水晶冲突段位赛匹配结束时间
---@return table Timetable
function PVPInfoMgr:GetCrystallineRankEndTimeData()
	if self.CrystallineRankEndTimeData then
		return self.CrystallineRankEndTimeData
	else
        local EndTimeCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_RANK_ACT_ENDTIME)
		self.CrystallineRankEndTimeData = {
			hour = EndTimeCfg and EndTimeCfg.Value[1] or 22,
			min = EndTimeCfg and EndTimeCfg.Value[2] or 0,
			sec = EndTimeCfg and EndTimeCfg.Value[3] or 0,
		}
		return self.CrystallineRankEndTimeData
	end
end

--- 获取水晶冲突匹配地图轮换时间
---@return uint32 秒数
function PVPInfoMgr:GetCrystallineChangeMapTime()
	if self.CrystallineChangeMapTime then
		return self.CrystallineChangeMapTime
	else
        local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_PVPMAPCYCLETIME)
		self.CrystallineChangeMapTime = Cfg and Cfg.Value[1] or 5400
		return self.CrystallineChangeMapTime
	end
end

--- 获取水晶冲突练习赛地图轮换列表
---@return table 副本IDList
function PVPInfoMgr:GetCrystallineExercisePWorldList()
	if self.CrystallineExercisePWorldList then
		return self.CrystallineExercisePWorldList
	else
        local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_MAPCYCLE_EXERCISE)
		self.CrystallineExercisePWorldList = Cfg and Cfg.Value or {}
		return self.CrystallineExercisePWorldList
	end
end

--- 获取水晶冲突段位赛地图轮换列表
---@return table 副本IDList
function PVPInfoMgr:GetCrystallineRankPWorldList()
	if self.CrystallineRankPWorldList then
		return self.CrystallineRankPWorldList
	else
        local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_MAPCYCLE_SEG)
		self.CrystallineRankPWorldList = Cfg and Cfg.Value or {}
		return self.CrystallineRankPWorldList
	end
end

--- 获取水晶冲突段位胜利之星上限
---@return uint32 数量
function PVPInfoMgr:GetCrystallineRankWinStarMax()
	if self.CrystallineRankWinStarMax then
		return self.CrystallineRankWinStarMax
	else
        local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_RANK_WINSTAR_LIMIT)
		self.CrystallineRankWinStarMax = Cfg and Cfg.Value[1] or 3
		return self.CrystallineRankWinStarMax
	end
end

--- 获取水晶冲突排行榜开放延迟时间
---@return uint32 小时
function PVPInfoMgr:GetCrystallineLeaderBoardOpenDelay()
	local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_RANK_DELAY_SHOW)
	return Cfg and Cfg.Value[1] or 72
end

--- 获取水晶冲突排行榜上榜最少场次
---@return uint32 场次
function PVPInfoMgr:GetCrystallineLeaderBoardAtLeastBattleCount()
	local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_RANK_NEEDBTLNUM)
	return Cfg and Cfg.Value[1] or 3
end

--- 获取自身水晶冲突排行榜数据
---@param SeasonID uint32 赛季ID
---@return PvPColosseumSeasonRankRsp.Rank 协议数据
function PVPInfoMgr:GetCrystallineRankingInfoSelf(SeasonID)
	return PVPInfoVM:GetCrystallineRankingInfoSelf(SeasonID)
end

--- 获取水晶冲突排行榜数据，没有数据的会自动拉取并发送更新事件
---@param SeasonID uint32 赛季ID
---@return PvPColosseumSeasonRankRsp.Rank 协议数据
function PVPInfoMgr:GetCrystallineRankingInfo(SeasonID)
	local Info = PVPInfoVM:GetCrystallineRankingInfo(SeasonID)
	if Info == nil then
		self:QueryCrystallineRankingInfo(SeasonID)
	end
	return Info
end

--- 获取水晶冲突赛季记录数据
---@param SeasonID uint32 赛季ID
---@return PvPColosseumSeasonRankHistoryRsp 协议数据
function PVPInfoMgr:GetCrystallineRankRecordData(SeasonID)
	return PVPInfoVM:GetCrystallineRankRecordData(SeasonID)
end

--- 获取是否已领取水晶冲突上赛季段位奖励
---@return boolean 是否已领取
function PVPInfoMgr:GetHasGetLaskSeasonRankReward()
	return PVPInfoVM:GetHasGetLaskSeasonRankReward()
end

--- 打开水晶之路界面
---@param SeasonID uint32 赛季ID
---@param IsShowReward boolean 是否显示领奖按钮
---@param IsFromInfo boolean 是否在对战资料中打开
function PVPInfoMgr:OpenCrystallinePathPanel(SeasonID, IsShowReward, IsFromInfo)
	local Params = {
		SeasonID = SeasonID,
		IsShowReward = IsShowReward,
		IsFromInfo = IsFromInfo,
	}
	UIViewMgr:ShowView(UIViewID.PVPCrystalRoadPanel, Params)
end

--- 获取是否参与过水晶冲突段位赛
---@return boolean 是否参与过
function PVPInfoMgr:GetParticipatedCrystallineRank()
	return PVPInfoVM:GetParticipatedCrystallineRank()
end

--- 获取水晶冲突段位名
---@param RankID uint32 段位ID
---@return string 段位名
function PVPInfoMgr:GetCrystallineRankName(RankID)
    return CrystallineRankCfg:FindValue(RankID, "RankName") or ""
end

--- 获取段位胜利之星
---@param RankID uint32 段位ID
---@return uint32 胜利之星数量
function PVPInfoMgr:GetCrystallineRankWinStar(RankID)
    return CrystallineRankCfg:FindValue(RankID, "WinStar") or 0
end

--- 获取段位计算方式
---@param RankID uint32 段位ID
---@return ProtoRes.Game.pvp_rank_result_mode 结算方式
function PVPInfoMgr:GetCrystallineRankScoreType(RankID)
    return CrystallineRankCfg:FindValue(RankID, "ResultMode") or ProtoRes.Game.pvp_rank_result_mode.RRM_None
end

--- 获取段位类型
---@param RankID uint32 段位ID
---@return ProtoRes.Game.pvp_rank_type 段位类型
function PVPInfoMgr:GetCrystallineRankType(RankID)
    return CrystallineRankCfg:FindValue(RankID, "Type") or ProtoRes.Game.pvp_rank_type.RT_None
end

--- 领取水晶冲突赛季排名奖励
function PVPInfoMgr:GetCrystallineRankingReward()
	local RewardMap = {}
	local Cfgs = SeriesMalmstoneSeasonCfg:FindAllCfg()
	for _, Cfg in ipairs(Cfgs or {}) do
		for _, RewardCfg in ipairs(Cfg.RankProof) do
			if BagMgr:GetItemByResID(RewardCfg.ProofID) then
                local SearchCondition = string.format("ID == %d", RewardCfg.CurRewardIdx)
				local LootCfg = LootMappingCfg:FindCfg(SearchCondition)
				if LootCfg then
					local RewardItemList = ItemUtil.GetLootItems(LootCfg.Program[1].ID)
					for _, Item in pairs(RewardItemList) do
						if Item.IsScore and Item.ResID == self:GetPVPTrophyCrystalScoreType() then
							table.insert(RewardMap, { SeasonID = Cfg.SeasonID, Count = Item.Num })
						end
					end
				end
				break
			end
		end
	end

	local function SorFunction(Reward1, Reward2)
		return Reward1.Count > Reward2.Count and Reward1.SeasonID < Reward2.SeasonID
	end

	table.sort(RewardMap, SorFunction)

	local MaxRewardSeasonID = RewardMap[1] and RewardMap[1].SeasonID
	if MaxRewardSeasonID then
		if ScoreMgr:GetScoreResidualValue(self:GetPVPTrophyCrystalScoreType()) >= RewardMap[1].Count then
			self:RequestCrystallineSeasonReward(PVP_SEASON_REWARD_TYPE.PvPSeasonRewardType_Rank, MaxRewardSeasonID)
		else
			MsgTipsUtil.ShowTipsByID(338049)	-- 超出上限
		end
	else
		MsgTipsUtil.ShowTipsByID(338048)	-- 没有证书无法领取
	end
end

--- 领取水晶冲突赛季段位奖励
function PVPInfoMgr:GetCrystallineRankReward()
	if self:GetHasGetLaskSeasonRankReward() then
		MsgTipsUtil.ShowTipsByID(338053)	-- 已领取
	else
		local Cfg = self:GetCurVersionSeriesMalmstoneCfg()
		if Cfg then
			local LastSeason = Cfg.Season - 1
			if LastSeason <= 0 then
				MsgTipsUtil.ShowTipsByID(338052)	-- 第一赛季时按未参与处理
				return
			end

			local SearchCondition = string.format("Season == %d", LastSeason)
			local LastSeasonCfg = SeriesMalmstoneSeasonCfg:FindCfg(SearchCondition)
			if LastSeasonCfg then
				local SeasonID = LastSeasonCfg.SeasonID
				local RecordData = self:GetCrystallineRankRecordData(SeasonID)
				if RecordData and RecordData.BtlNum > 0 and self:GetCrystallineRankType(RecordData.RankID) >= ProtoRes.Game.pvp_rank_type.RT_BRONZE then
					self:OpenCrystallinePathPanel(SeasonID, true)
				else
					MsgTipsUtil.ShowTipsByID(338052)	-- 上赛季未参与段位赛或未到青铜
				end
			end
		end
	end
end

-- endregion Public Interface

return PVPInfoMgr