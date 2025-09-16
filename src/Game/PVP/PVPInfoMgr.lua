
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")
local MsgTipsID = require("Define/MsgTipsID")
local EventID = require("Define/EventID")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")

local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local DateTimeTools = require("Common/DateTimeTools")

local SeriesMalmstoneSeasonCfg = require("TableCfg/SeriesMalmstoneSeasonCfg")
local SeriesMalmstoneRewardCfg = require("TableCfg/SeriesMalmstoneRewardCfg")
local PVPInfoVM = require ("Game/PVP/VM/PVPInfoVM")

local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")

local PVP_COLOSSEUM_CMD = ProtoCS.Game.PvPColosseum.CS_PVPCOLOSSEUM_CMD
local PVP_BTLMTL_TYPE = ProtoCS.Game.PvPColosseum.PvPColosseumBtlMtlType

local GameNetworkMgr = nil
local EventMgr = nil
local MountMgr = nil
local PWorldMgr = nil
local ScoreMgr = nil
local ChatMgr = nil
local RedDotMgr = nil
local UIViewMgr = nil
local ModuleOpenMgr = nil
local LSTR = nil
local FLOG_ERROR = nil
local FLOG_INFO = nil
local CS_CMD = ProtoCS.CS_CMD

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
    ModuleOpenMgr = nil
    LSTR = nil
    FLOG_ERROR = nil
    FLOG_INFO = nil
end

function PVPInfoMgr:OnShutdown()
	self:ResetData()
end

function PVPInfoMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
	self:RegisterGameEvent(EventID.ModuleOpenUpdated, self.OnModuleOpenUpdated) --系统列表更新/新系统解锁
end

function PVPInfoMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.BTLMATERIALS, self.OnNetRspBattleMaterialsQuery)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.STAR_ROADSIGN_REWARD, self.OnNetRspSeriesMalmstoneReward)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.STAR_ROADSIGN_LEVELUP_NTF, self.OnNetNtySeriesMalmstoneLevelUp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.BADGE_UPDATE, self.OnNetNtyHonorUpdate)
end

function PVPInfoMgr:ResetData()
	self.BreakThroughRedDotName = nil
	self.SeasonChangeTimerID = nil
	self.WeeklyUpdateTimerID = nil
end

-- region GameEvent

function PVPInfoMgr:OnPWorldReady()
	self:CheckQueryData()

    -- 连接上服务器才能拉到服务器时间，所以不能在OnBegin就加Timer，这样时间会不准，进入地图后拿到正确时间再加，重连时也刷新一下Timer
	-- 游戏中赛季变化时请求新数据
	self:TryAddSeasonChangeTimer()
    -- 游戏中数据周更新时请求新数据
	self:TryAddWeeklyUpdateTimer()
end

function PVPInfoMgr:OnModuleOpenUpdated()
	self:CheckQueryData()
end

---@private
--- 请求系统数据
function PVPInfoMgr:CheckQueryData()
	local IsModuleOpen = ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattle)
	if IsModuleOpen then
		FLOG_INFO("[PVPInfoMgr]Query PVPInfo data")
		self:QueryOverviewData()
	end

	local IsCrystallineModuleOpen = ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDPvPColosseumCrystal)
	if IsCrystallineModuleOpen then
		FLOG_INFO("[PVPInfoMgr]Query Crystalline data")
		self:QueryCrystalData()
	end
end

-- endregion GameEvent

-- region NetMsgReq

--- 请求对战总览数据
function PVPInfoMgr:QueryOverviewData()
	self:QueryPVPData(PVP_BTLMTL_TYPE.BMTOverview)
end

--- 请求水晶冲突数据
function PVPInfoMgr:QueryCrystalData()
	self:QueryPVPData(PVP_BTLMTL_TYPE.BMTCrystal)
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

	local PvPStarRoadSignRewardReq = {
		ID = IDList
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.STAR_ROADSIGN_REWARD, "StarRoadSignRewardReq", PvPStarRoadSignRewardReq)
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
		if NtfData == nil then return end
			local Data = NtfData[NtfData.Result]
			if Data then
				PVPInfoVM:SetSeriesMalmstoneData(Data)
				self:CheckRedDot()
				EventMgr:SendEvent(EventID.PVPSeriesDataUpdate)
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

-- endregion NetMsgRes

-- region Private Function

---@private
function PVPInfoMgr:CheckRedDot()
	if self:GetCurSeasonSeriesMalmstoneCfg() == nil then
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
			local CurRedDotName = ParentRedDotName .. "/" .. BreakThroughLevel
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
	-- 如果目前不在赛季中，接下来也没有新赛季，那就不用刷新数据
	local SeasonChangeTimeString = nil
	local CurSeasonCfg = self:GetCurSeasonSeriesMalmstoneCfg()
	if CurSeasonCfg then
		SeasonChangeTimeString = CurSeasonCfg.EndTime
	else
		local NextSeasonCfg = self:GetNextSeasonSeriesMalmstoneCfg()
		if NextSeasonCfg then
			SeasonChangeTimeString = NextSeasonCfg.BeginTime
		end
	end

	if SeasonChangeTimeString == nil then return end

	local ServerTime = TimeUtil.GetServerLogicTime()
	local SeasonChangeTime = TimeUtil.GetTimeFromString(SeasonChangeTimeString)
	local RemainTime = math.ceil(SeasonChangeTime - ServerTime)	-- 向上取整，等本赛季结束/新赛季开始后再拉新数据

	self:ClearSeasonChangeTimer()
	self.SeasonChangeTimerID = self:RegisterTimer(function()
		self:CheckQueryData()
		-- 请求完后重新添加下一次赛季变化倒计时
		self:TryAddSeasonChangeTimer()
	end, RemainTime)
end

---@private
function PVPInfoMgr:ClearSeasonChangeTimer()
	if self.SeasonChangeTimerID then
		self:UnRegisterTimer(self.SeasonChangeTimerID)
		self.SeasonChangeTimerID = nil
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

	if ServerDate.wday <= UpdateWeekDay and ServerDate.hour < UpdateHour then --没有到周一更新时间
		RemainTime = UpdateSec - CurSec
	else --超过了周一更新时间则要算到下周更新时间
		RemainTime = 7 * 24 * 3600 - (CurSec - UpdateSec)
	end
	
	self:ClearWeeklyUpdateTimer()
	self.WeeklyUpdateTimerID = self:RegisterTimer(function()
		self:CheckQueryData()
		-- 请求完后重新添加下一次周更新计时
		self:TryAddWeeklyUpdateTimer()
	end, RemainTime)
end

---@private
function PVPInfoMgr:ClearWeeklyUpdateTimer()
	if self.WeeklyUpdateTimerID then
		self:UnRegisterTimer(self.WeeklyUpdateTimerID)
		self.WeeklyUpdateTimerID = nil
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

-- endregion

-- region Public Interface

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
	local CurLevelCfg = self:GetCurSeasonSeriesMalmstoneLevelCfg(Level)
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
function PVPInfoMgr:GetCurSeriesMalmstoneLevelUpExp(Level)
	local CurLevelCfg = self:GetCurSeasonSeriesMalmstoneLevelCfg(Level)
	return CurLevelCfg and CurLevelCfg.UpExp or 0
end

--- 获取本赛季星里路标配置
---@return table 配置列
function PVPInfoMgr:GetCurSeasonSeriesMalmstoneCfg()
	local ServerTime = TimeUtil.GetServerLogicTime()
    local Cfgs = SeriesMalmstoneSeasonCfg:FindAllCfg()
    if Cfgs == nil then return nil end

    for _, Cfg in pairs(Cfgs) do
        local BeginTime = TimeUtil.GetTimeFromString(Cfg.BeginTime)
        local EndTime = TimeUtil.GetTimeFromString(Cfg.EndTime)
        if BeginTime <= ServerTime and ServerTime <= EndTime then
            return Cfg
        end
    end

    return nil
end

--- 获取下赛季星里路标配置
---@return table 配置列
function PVPInfoMgr:GetNextSeasonSeriesMalmstoneCfg()
	local ServerTime = TimeUtil.GetServerLogicTime()
    local Cfgs = SeriesMalmstoneSeasonCfg:FindAllCfg()
    if Cfgs == nil then return nil end

	local NextSeasonCfg = nil
	local ClosestBeginTime = math.maxinteger
    for _, Cfg in pairs(Cfgs) do
        local BeginTime = TimeUtil.GetTimeFromString(Cfg.BeginTime)
		local TimeToBegin = BeginTime - ServerTime
		if TimeToBegin > 0 then
			if TimeToBegin < ClosestBeginTime then
				ClosestBeginTime = TimeToBegin
            	NextSeasonCfg = Cfg
			end
        end
    end

    return NextSeasonCfg
end

--- 获取本赛季星里路标某等级配置
---@param Level uint32 等级
---@return table 配置列
function PVPInfoMgr:GetCurSeasonSeriesMalmstoneLevelCfg(Level)
	local CurSeasonCfg = self:GetCurSeasonSeriesMalmstoneCfg()
	if CurSeasonCfg == nil then return nil end

	local SearchCondition = string.format("GroupID == %d AND Level == %d", CurSeasonCfg.LevelGroup, Level)
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

    local CurSeasonCfg = self:GetCurSeasonSeriesMalmstoneCfg()
    if CurSeasonCfg then
        local ServerTime = TimeUtil.GetServerLogicTime()
        local EndTimeString = CurSeasonCfg.EndTime
        local EndTime = TimeUtil.GetTimeFromString(EndTimeString)
        RemainTime = EndTime - ServerTime
    end

    return RemainTime
end

-- endregion Public Interface

return PVPInfoMgr