local LuaClass = require("Core/LuaClass")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneCombatCfg = require("TableCfg/SceneCombatCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local PWorldEntPol = require("Game/PWorld/Entrance/Policy/PWorldEntPol")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local TimeUtil = require("Utils/TimeUtil")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local PolUtil = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")

---@class PWorldEntPolPVP : PWorldEntPol
local PWorldEntPolPVP = LuaClass(PWorldEntPol)

function PWorldEntPolPVP:CheckFilter(EntID)
    local Type = SceneEnterCfg:FindValue(EntID, "TypeID")
    if PWorldEntUtil.IsCrystalline(Type) then
        return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDPvPColosseumCrystal)
    end

    return false
end

function PWorldEntPolPVP:CheckJoinPre(EntID)
    local RoleVM = MajorUtil.GetMajorRoleVM(true)
    if RoleVM == nil then
        _G.FLOG_ERROR("PWorldEntPolPVP:CheckJoinPre RoleVM = NIL")
        return false, {}
    end

    local Prof = RoleVM.Prof
    local Lv = RoleVM.Level
    local EquipLv = _G.EquipmentMgr:CalculateEquipScore()
    local IsCombatAdvancedProf = _G.ProfMgr.CheckProfClass(Prof, 22) -- 如果后续对不上了查查表是不是改ID了，这里不是用枚举会有风险
    local ReqEquipLv = self:GetRequireEquipLv(EntID)
    local ReqLv = self:GetRequireLv(EntID)
    local IsInEventTime = self:CheckIsInEventTime(EntID)

    local Cfg = SceneEnterCfg:FindCfgByKey(EntID)
    local IsOpen = not (PWorldEntUtil.IsCrystallineRank(Cfg.TypeID) or PWorldEntUtil.IsCrystallineCustom(Cfg.TypeID))
    local Ret = {
        IsOpen = IsOpen,
        IsPassMem = IsCombatAdvancedProf,
        IsPassLv = Lv >= ReqLv,
        IsPassEquipLv = EquipLv >= ReqEquipLv,
        IsPassTime = IsInEventTime,
    }

    local IsPass = true

    for _, V in pairs(Ret) do
        IsPass = IsPass and V
    end

    return IsPass, Ret
end

function PWorldEntPolPVP:GetRewardData(EntCfg)
    local RewardsData = {}

    if not EntCfg then
        return
    end

    local Cfg = EntCfg

    local FirstPassRewards = Cfg.InitialRewards
    local NormalRewards = Cfg.Rewards

    for Idx, ID in ipairs(FirstPassRewards) do
        local Cnt = Cfg.InitialRewardCnt[Idx] or 0
        local Data = PolUtil.MakeRewardData(ID, Cnt, PWorldEntDefine.RewardType.FirstPass, Cfg.ID)
        table.insert(RewardsData, Data)
    end

    for Idx, ID in ipairs(NormalRewards) do
        local Cnt = Cfg.RewardCnt[Idx] or 0
        local Data = PolUtil.MakeRewardData(ID, Cnt, PWorldEntDefine.RewardType.Norm, Cfg.ID)
        table.insert(RewardsData, Data)
    end

    return RewardsData
end

function PWorldEntPolPVP:GetEntInfo(EntID)
    local Ret = {
        EntCfg                  = nil,
        PWorldID                = nil,
        BG                      = nil,
        PWorldName              = nil,
        MaxMatchCnt             = nil,
        PWorldRequireLv         = nil,
        PWorldRequireEquipLv    = nil,
        PWorldSyncLv            = nil,
        IsChocoboRandomTrack    = nil,
        CombatCfg               = nil,
    }

    local EntCfg = SceneEnterCfg:FindCfgByKey(EntID)
    Ret.EntCfg = EntCfg or {}
    if EntCfg == nil then
        _G.FLOG_ERROR("PWorldEntPolPVP:GetEntInfo invalid EntID ".. tostring(EntID) )
        return Ret 
    end

    Ret.PWorldID = EntCfg.ID
    Ret.BG = EntCfg.BG

    Ret.MaxMatchCnt = PWorldEntDefine.NormMatchMaxCnt

    local PCfg = PworldCfg:FindCfgByKey(Ret.PWorldID)
    local CombatCfg = SceneCombatCfg:FindCfgByKey(Ret.PWorldID)
    if PCfg then
        if PWorldEntUtil.IsCrystallineExercise(EntCfg.TypeID) then
            Ret.PWorldName = _G.LSTR(1320137)
        elseif PWorldEntUtil.IsCrystallineRank(EntCfg.TypeID) then
            Ret.PWorldName = _G.LSTR(1320138)
        else
            Ret.PWorldName = PCfg.PWorldName
        end
        Ret.PWorldRequireLv = PCfg.PlayerLevel
    else
        Ret.PWorldName = ""
        Ret.PWorldRequireLv = 0
        _G.FLOG_ERROR("PWorldEntPolPVP:GetEntInfo PCfg = nil PWorldID = " .. tostring(Ret.PWorldID) )
    end

    Ret.PWorldRequireEquipLv = CombatCfg and CombatCfg.EquipLv or 0
    Ret.PWorldSyncLv = CombatCfg and CombatCfg.SyncMaxLv or 0
    Ret.CombatCfg = CombatCfg
    
    return Ret
end

function PWorldEntPolPVP:GetRequireLv(EntID)
    local PCfg = PworldCfg:FindCfgByKey(EntID)
    return PCfg and PCfg.PlayerLevel or 0
end

function PWorldEntPolPVP:GetRequireEquipLv(EntID)
    local CombatCfg = SceneCombatCfg:FindCfgByKey(EntID)
    return CombatCfg and CombatCfg.EquipLv or 0
end

local function GetTimeAndCheck(CurServerTime, StartTimeTable, EndTimeTable)
    local StartTime = os.time(StartTimeTable)
    local EndTime = os.time(EndTimeTable)
    local IsInEventTime = CurServerTime >= StartTime and CurServerTime <= EndTime
    return IsInEventTime, StartTime, EndTime
end

--- 检查是否在水晶冲突可匹配时间内，不传参则默认使用练习赛作判断，可以获取到目前区间等数据
---@param EntID uint64 副本ID
---@alias EventTimeData { StartTime: date, EndTime: date, IsCrossDay: boolean|nil }
---@alias CurIntervalData { StartTime: date, EndTime: date, Interval: integer, MapID: uint64, MapName: string }
---@alias NextIntervalData { StartTime: date, EndTime: date, Interval: integer, MapID: uint64, MapName: string }
---@return boolean, EventTimeData, CurIntervalData, NextIntervalData 是否在活动时间, 活动时间数据, 当前区间数据, 下一区间数据
function PWorldEntPolPVP:CheckIsInEventTime(EntID)
    EntID = EntID or 1218010
    local IsInEventTime = false
    local EventTimeData = {}
    local CurIntervalData = {}
    local NextIntervalData = {}
    local EnterCfg = SceneEnterCfg:FindCfgByKey(EntID)
    local Type = EnterCfg and EnterCfg.TypeID or 0
    local StartTime = 0
    local EndTime = 0
    if PWorldEntUtil.IsCrystalline(Type) then
        -- 是否在活动时间
        local CurServerTime = TimeUtil.GetServerLogicTime()
        local CurTimeTable = os.date("*t", CurServerTime)
        local StartTimeCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_ACTTIMEBEGIN)
        local EndTimeCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_ACTTIMEEND)
        local StartTimeHour = StartTimeCfg and StartTimeCfg.Value[1] or 10
        local StartTimeMin = StartTimeCfg and StartTimeCfg.Value[2] or 0
        local EndTimeHour = EndTimeCfg and EndTimeCfg.Value[1] or 1
        local EndTimeMin = EndTimeCfg and EndTimeCfg.Value[2] or 0
        local StartTimeTable = {
            year = CurTimeTable.year,
            month = CurTimeTable.month,
            day = CurTimeTable.day,
            hour = StartTimeHour,
            min = StartTimeMin,
            sec = 0
        }
        local EndTimeTable = {
            year = CurTimeTable.year,
            month = CurTimeTable.month,
            day = CurTimeTable.day,
            hour = EndTimeHour,
            min = EndTimeMin,
            sec = 0
        }

        local function TimeToSec(Hour, Min, Sec)
            return Hour * 3600 + Min * 60 + Sec
        end
    
        local StartSec = TimeToSec(StartTimeHour, StartTimeMin, 0)
        local EndSec = TimeToSec(EndTimeHour, EndTimeMin, 0)
        local IsCrossDay = EndSec <= StartSec
        EventTimeData.IsCrossDay = IsCrossDay

        if not IsCrossDay then
            IsInEventTime, StartTime, EndTime = GetTimeAndCheck(CurServerTime, StartTimeTable, EndTimeTable)
        else
            EventTimeData.IsCrossDay = true
            StartTimeTable.day = CurTimeTable.day - 1
            EndTimeTable.day = CurTimeTable.day
            IsInEventTime, StartTime, EndTime = GetTimeAndCheck(CurServerTime, StartTimeTable, EndTimeTable)

            -- 如果不在前一天的活动时间里再判断是否在今天开始的活动时间里
            if not IsInEventTime then
                StartTimeTable.day = CurTimeTable.day
                EndTimeTable.day = CurTimeTable.day + 1
                IsInEventTime, StartTime, EndTime = GetTimeAndCheck(CurServerTime, StartTimeTable, EndTimeTable)
            end
        end

        EventTimeData.StartTime = StartTimeTable
        EventTimeData.EndTime = EndTimeTable

        -- 练习赛和段位赛还需要知道目前时间段的副本名和时间
        local IsCrystallineExercise = PWorldEntUtil.IsCrystallineExercise(Type)
        local IsCrystallineRank = PWorldEntUtil.IsCrystallineRank(Type)
        if IsCrystallineExercise or IsCrystallineRank then
            local ChangeMapTimeCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_PVPMAPCYCLETIME)
            local ChangeMapSecond = ChangeMapTimeCfg and ChangeMapTimeCfg.Value[1] or 5400

            local TotalEventTime = EndTime - StartTime
            local TotalIntervals = math.floor(TotalEventTime / ChangeMapSecond)
            
            local PassedInterval = 0
            local CurInterval = 1
            local NextInterval = 1
            if not IsCrossDay then
                PassedInterval = math.floor((CurServerTime - StartTime) / ChangeMapSecond)
            else
                local MidnightOfStartTimeTable = {
                    year = StartTimeTable.year,
                    month = StartTimeTable.month,
                    day = StartTimeTable.day + 1,
                    hour = 0,
                    min = 0,
                    sec = 0
                }
                local MidnightOfStartTime =  os.time(MidnightOfStartTimeTable)
                local StartToMidnightSecond = MidnightOfStartTime - StartTime

                local MidnightToEndTimeTable = {
                    year = EndTimeTable.year,
                    month = EndTimeTable.month,
                    day = EndTimeTable.day,
                    hour = 0,
                    min = 0,
                    sec = 0
                }
                local MidnightToEndTime = os.time(MidnightToEndTimeTable)
                local MidnightToEndSecond = EndTime - MidnightToEndTime
                local CurrentFromStartToMidnight = math.min(CurServerTime, StartToMidnightSecond + StartTime)
                local PassedIntervalsBeforeMidnight = math.floor((CurrentFromStartToMidnight - StartTime) / ChangeMapSecond)
                local CurrentFromMidnightToEnd = math.max(0, CurServerTime - StartTime - StartToMidnightSecond)
                local PassedIntervalsAfterMidnight = math.floor(CurrentFromMidnightToEnd / ChangeMapSecond)
                PassedInterval = PassedIntervalsBeforeMidnight + PassedIntervalsAfterMidnight
            end

            CurInterval = PassedInterval + 1
            local PWorldOrderList = {}
            if IsCrystallineExercise then
                local PWorldListCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_MAPCYCLE_EXERCISE)
                PWorldOrderList = PWorldListCfg and PWorldListCfg.Value or {}
            elseif IsCrystallineRank then
                local PWorldListCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_MAPCYCLE_SEG)
                PWorldOrderList = PWorldListCfg and PWorldListCfg.Value or {}
            end
            local PWorldCount = #PWorldOrderList

            if IsInEventTime then
                -- 当前区间开始时间等于已经过区间的结束时间
                local CurMapIntervalStartTime = StartTime + PassedInterval * ChangeMapSecond
                -- 当前区间结束时间等于开始时间加上间隔
                local CurMapIntervalEndTime = CurMapIntervalStartTime + ChangeMapSecond
                CurIntervalData.StartTime = os.date("*t", CurMapIntervalStartTime)
                CurIntervalData.EndTime = os.date("*t", CurMapIntervalEndTime)
                CurIntervalData.Interval = CurInterval
                local CurMapIndex = CurInterval % PWorldCount
                if CurMapIndex == 0 then
                    CurMapIndex = 3
                end
                CurIntervalData.MapID = PWorldOrderList[CurMapIndex]
                CurIntervalData.MapName = PWorldEntUtil.GetPWorldEntName(PWorldOrderList[CurMapIndex])
                
                if CurInterval ~= TotalIntervals then
                    -- 下区间开始时间等于当前区间的结束时间
                    local NextMapIntervalStartTime = StartTime + CurInterval * ChangeMapSecond
                    -- 下区间结束时间等于开始时间加上间隔
                    local NextMapIntervalEndTime = NextMapIntervalStartTime + ChangeMapSecond
                    NextIntervalData.StartTime = os.date("*t", NextMapIntervalStartTime)
                    NextIntervalData.EndTime = os.date("*t", NextMapIntervalEndTime)
                    
                    NextInterval = CurInterval + 1
                    local NextMapIndex = NextInterval % PWorldCount
                    if NextMapIndex == 0 then
                        NextMapIndex = 3
                    end
                    NextIntervalData.MapID = PWorldOrderList[NextMapIndex]
                    NextIntervalData.MapName = PWorldEntUtil.GetPWorldEntName(PWorldOrderList[NextMapIndex])
                else
                    -- 当前是最后一个区间则下区间开始时间为活动开始时间
                    -- 展示上只取小时和分钟，所以就算是不在同一天也不影响，只要是活动开始时间就可以
                    local NextMapIntervalEndTime = StartTime + ChangeMapSecond
                    local NextMapIntervalEndTimeTable = os.date("*t", NextMapIntervalEndTime)
                    NextIntervalData.StartTime = StartTimeTable
                    NextIntervalData.EndTime = NextMapIntervalEndTimeTable
                    
                    NextInterval = 1
                    NextIntervalData.MapID = PWorldOrderList[NextInterval]
                    NextIntervalData.MapName = PWorldEntUtil.GetPWorldEntName(PWorldOrderList[NextInterval])
                end
            else
                -- 当前非活动时间则下区间开始时间为活动开始时间
                -- 展示上只取小时和分钟，所以就算是不在同一天也不影响，只要是活动开始时间就可以
                local NextMapIntervalEndTime = StartTime + ChangeMapSecond
                local NextMapIntervalEndTimeTable = os.date("*t", NextMapIntervalEndTime)
                NextIntervalData.StartTime = StartTimeTable
                NextIntervalData.EndTime = NextMapIntervalEndTimeTable
                NextInterval = 1
                NextIntervalData.MapID = PWorldOrderList[NextInterval]
                NextIntervalData.MapName = PWorldEntUtil.GetPWorldEntName(PWorldOrderList[NextInterval])
            end
        end
    end
    return IsInEventTime, EventTimeData, CurIntervalData, NextIntervalData
end

function PWorldEntPolPVP:CheckEnter(EntID)
    return false
end

return PWorldEntPolPVP


