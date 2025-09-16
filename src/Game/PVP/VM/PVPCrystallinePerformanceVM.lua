local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")
local ProtoCS = require("Protocol/ProtoCS")
local PVPInfoVM = require ("Game/PVP/VM/PVPInfoVM")
local PVPPerformanceDetailItemVM = require ("Game/PVP/VM/PVPPerformanceDetailItemVM")
local CrystallineStatisticParamCfg = require("TableCfg/CrystallineStatisticParamCfg")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")

local UIBindableList = require("UI/UIBindableList")

local GameMode = ProtoCS.Game.PvPColosseum.PvPColosseumMode
local TimeType = ProtoCS.Game.PvPColosseum.PvpColosseumBtlResultClass
local StatisticType = ProtoRes.CRYSTALLINE_STATISTIC_TYPE

local DefaultModeFilterValue = -1 -- -1表示比赛模式下拉菜单的【全部】选项
local DefaultTimeFilterValue = TimeType.CurSeason

local LSTR = _G.LSTR
local GameModeNameMap = PVPInfoDefine.GameModeNameMap
local TimeTypeNameMap = PVPInfoDefine.TimeTypeNameMap

---@class PVPCrystallinePerformanceVM : UIViewModel
local PVPCrystallinePerformanceVM = LuaClass(UIViewModel)

function PVPCrystallinePerformanceVM:Ctor()
    self.RankDetailVMList = UIBindableList.New(PVPPerformanceDetailItemVM)
	self.ExerciseDetailVMList =  UIBindableList.New(PVPPerformanceDetailItemVM)
	self.PerformanceDetailVMList = UIBindableList.New(PVPPerformanceDetailItemVM)
    self.ModeFilterList = nil
    self.ModeFilter = DefaultModeFilterValue
    self.TimeFilterList = nil
    self.TimeFilter = DefaultTimeFilterValue
    self.PerformanceData = nil  -- 用于刷新五维图
end

function PVPCrystallinePerformanceVM:ShowData()
    self:ShowRankDetail()
    self:ShowExerciseDetail()
    self:UpdateFilterList()
end

function PVPCrystallinePerformanceVM:GetTypeStatistic()
    local TypeStatistic = PVPInfoVM:GetTypeStatistic(ProtoCS.Game.PvPColosseum.PvPColosseumGameType.Crystal)
    return TypeStatistic
end

function PVPCrystallinePerformanceVM:ShowRankDetail()
    local TypeStatistic = self:GetTypeStatistic()
    if TypeStatistic == nil then return end

    local ModeStatistic = TypeStatistic:GetModeStatistic(GameMode.Rank)
    local TimeStatistic = ModeStatistic:GetTimeStatistic(TimeType.CurSeason)
    local CurSeasonWinRate = 0
    if TimeStatistic.BattleCount ~= 0 then
        CurSeasonWinRate =  (TimeStatistic.WinCount / TimeStatistic.BattleCount) * 100  -- 乘100为百分比
    end

    local VMList = {
        { Desc = LSTR(130015), Value = ModeStatistic.BattleCount },
        { Desc = LSTR(130016), Value = TimeStatistic.BattleCount },
        { Desc = LSTR(130017), Value = string.format(LSTR(130057), CurSeasonWinRate) },
        { Desc = LSTR(130018), Value = LSTR(130063) },
        { Desc = LSTR(130019), Value = LSTR(130064) },
    } 

    self.RankDetailVMList:UpdateByValues(VMList)
end

function PVPCrystallinePerformanceVM:ShowExerciseDetail()
    local TypeStatistic = self:GetTypeStatistic()
    if TypeStatistic == nil then return end

    local ModeStatistic = TypeStatistic:GetModeStatistic(GameMode.Exercise)
    local TimeStatistic = ModeStatistic:GetTimeStatistic(TimeType.CurSeason)
    local CurSeasonWinRate = 0
    if TimeStatistic.BattleCount ~= 0 then
        CurSeasonWinRate =  (TimeStatistic.WinCount / TimeStatistic.BattleCount) * 100  -- 乘100为百分比
    end
    local VMList = {
        { Desc = LSTR(130015), Value = ModeStatistic.BattleCount },
        { Desc = LSTR(130016), Value = TimeStatistic.BattleCount },
        { Desc = LSTR(130017), Value = string.format(LSTR(130057), CurSeasonWinRate) },
    }

    self.ExerciseDetailVMList:UpdateByValues(VMList)
end

function PVPCrystallinePerformanceVM:UpdateFilterList()
    self:UpdateModeFilterList()
    self:UpdateTimeFilterList()
end

function PVPCrystallinePerformanceVM:UpdateModeFilterList()
    local FilterTypes = {}
    local Name = nil
    local ItemData = nil
    
    Name = LSTR(130026)
    ItemData = { Mode = -1 }
    table.insert(FilterTypes, { Name = Name, ItemData = ItemData })
    Name = GameModeNameMap[GameMode.Exercise]
    ItemData = { Mode = GameMode.Exercise }
    table.insert(FilterTypes, { Name = Name, ItemData = ItemData })
    Name = GameModeNameMap[GameMode.Rank]
    ItemData = { Mode = GameMode.Rank }
    table.insert(FilterTypes, { Name = Name, ItemData = ItemData })

    self.ModeFilterList = FilterTypes
end

function PVPCrystallinePerformanceVM:UpdateTimeFilterList()
    local FilterTypes = {}

    local Name = TimeTypeNameMap[TimeType.CurSeason]
    local ItemData = { Time = TimeType.CurSeason }
    table.insert(FilterTypes, { Name = Name, ItemData = ItemData })
    Name = TimeTypeNameMap[TimeType.LastSeason]
    ItemData = { Time = TimeType.LastSeason }
    table.insert(FilterTypes, { Name = Name, ItemData = ItemData })
    Name = TimeTypeNameMap[TimeType.CurWeek]
    ItemData = { Time = TimeType.CurWeek }
    table.insert(FilterTypes, { Name = Name, ItemData = ItemData })

    self.TimeFilterList = FilterTypes
end

function PVPCrystallinePerformanceVM:SetModeFilter(ModeFilterValue)
    self.ModeFilter = ModeFilterValue
end

function PVPCrystallinePerformanceVM:SetTimeFilter(TimeFilterValue)
    self.TimeFilter = TimeFilterValue
end

function PVPCrystallinePerformanceVM:UpdatePerformanceDetail()
    local TypeStatistic = self:GetTypeStatistic()
    if TypeStatistic == nil then return end

    local ModeList = self:GetModeListFromFilter(self.ModeFilter)
    if ModeList == nil then return end

    local BattleCount = 0
    local EscortTime = 0
    local Output = 0
    local Survival = 0
    local Cure = 0
    local Kill = 0
    local Death = 0
    local Assist = 0
    local KDA = 0

    for _, Mode in pairs(ModeList) do
        local ModeStatistic = TypeStatistic:GetModeStatistic(Mode)
        if ModeStatistic == nil then
            _G.FLOG_ERROR("[PVPCrystallinePerformanceVM]Mode statistic is nil")
            return
        end

        local TimeStatistic = ModeStatistic:GetTimeStatistic(self.TimeFilter)
        if TimeStatistic == nil then
            _G.FLOG_ERROR("[PVPCrystallinePerformanceVM]Time statistic is nil")
            return
        end

        if TimeStatistic.BattleCount ~= 0 then
            BattleCount = BattleCount + TimeStatistic.BattleCount
            EscortTime = EscortTime + TimeStatistic.EscortTime
            Output = Output + TimeStatistic.Output
            Survival = Survival + TimeStatistic.Survival
            Cure = Cure + TimeStatistic.Cure
            Kill = Kill + TimeStatistic.Kill
            Death = Death + TimeStatistic.Death
            Assist = Assist + TimeStatistic.Assist
        end
    end

    if BattleCount ~= 0 then
        EscortTime = (EscortTime / 1000) / BattleCount
        Output = Output / BattleCount
        Survival = Survival / BattleCount
        Cure = Cure / BattleCount
    end

    -- 对小数做向上取整展示
    Output = math.ceil(Output)
    Survival = math.ceil(Survival)
    Cure = math.ceil(Cure)

    KDA = Kill + Assist
    local DeathParamCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_BTLLOSSRATE)
    local DeathParam = DeathParamCfg and DeathParamCfg.Value[1]/10000 or 0.35
    local Denominator = Death + DeathParam
    if Denominator ~= 0 then
        KDA = KDA / Denominator
    end

    self:ShowDataList(EscortTime, Output, Survival, Cure, KDA)
    self:ShowDataDiagram(EscortTime, Output, Survival, Cure, KDA)
end


function PVPCrystallinePerformanceVM:GetModeListFromFilter(ModeFilter)
    if ModeFilter == DefaultModeFilterValue then
        return { GameMode.Rank, GameMode.Exercise }
    else
        return { ModeFilter }
    end
end

function PVPCrystallinePerformanceVM:ShowDataList(EscortTime, Output, Survival, Cure, KDA)
    local EscortTimePercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_ESCORT, EscortTime, false)
    local OutputPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_OUTPUT, Output, false)
    local SurvivalPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_SURVIVAL, Survival, false)
    local CurePercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_CURE, Cure, false)
    local KDAPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_KDA, KDA, false)

    local EscortTimeString = string.format(LSTR(130058), EscortTime)
    local OutputString = string.format(LSTR(130059), Output)
    local SurvivalString = string.format(LSTR(130060), Survival)
    local CureString = string.format(LSTR(130061), Cure)
    local KDAString = string.format(LSTR(130062), KDA)

    local VMList = {
        { Desc = LSTR(130020), Value = EscortTimeString, Percent = EscortTimePercent },
        { Desc = LSTR(130021), Value = OutputString, Percent = OutputPercent },
        { Desc = LSTR(130022), Value = SurvivalString, Percent = SurvivalPercent },
        { Desc = LSTR(130023), Value = CureString, Percent = CurePercent },
        { Desc = LSTR(130024), Value = KDAString, Percent = KDAPercent },
    }

    self.PerformanceDetailVMList:UpdateByValues(VMList)
end

function PVPCrystallinePerformanceVM:ShowDataDiagram(EscortTime, Output, Survival, Cure, KDA)
    local EscortTimePercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_ESCORT, EscortTime, true)
    local OutputPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_OUTPUT, Output, true)
    local SurvivalPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_SURVIVAL, Survival, true)
    local CurePercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_CURE, Cure, true)
    local KDAPercent = self:GetDataPercent(StatisticType.CRYSTALLINE_STATISTIC_KDA, KDA, true)

    self.PerformanceData = {
        EscortTime = EscortTime,
        EscortTimePercent = EscortTimePercent,
        Output = Output,
        OutputPercent = OutputPercent,
        Survival = Survival,
        SurvivalPercent = SurvivalPercent,
        Cure = Cure,
        CurePercent = CurePercent,
        KDA = KDA,
        KDAPercent = KDAPercent,
    }
end

function PVPCrystallinePerformanceVM:GetDataPercent(DataType, Data, IsDiagram)
    local Min, Max, DataMin, DataMax
    local Percent = 0
    local Cfg = CrystallineStatisticParamCfg:FindCfgByKey(DataType)
    if Cfg then
        if IsDiagram then
            Min = Cfg.DiagramMin
            Max = Cfg.DiagramMax
            DataMin = Cfg.DiagramDataMin
            DataMax = Cfg.DiagramDataMax
        else
            Min = Cfg.DetailMin
            Max = Cfg.DetailMax
            DataMin = Cfg.DetailDataMin
            DataMax = Cfg.DetailDataMax
        end
    end
    if Min and Max then
        local ClampedData = math.clamp(Data, DataMin, DataMax)
        Percent = (ClampedData - Min) / (Max - Min)
    end
    return Percent
end

return PVPCrystallinePerformanceVM