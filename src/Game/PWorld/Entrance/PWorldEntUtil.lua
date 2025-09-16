
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local SceneDailyRandomTaskPoolCfg = require("TableCfg/SceneDailyRandomTaskPoolCfg")

local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local PworldCfg = require("TableCfg/PworldCfg")
local PWorldEntPolUtil = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ScenePoolType = ProtoCommon.ScenePoolType
local SceneMode = ProtoCommon.SceneMode
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local MatchTestRlt = PWorldEntDefine.MatchTestRlt
local ProtoRes = require("Protocol/ProtoRes")
local JoinErrorCode = PWorldEntDefine.JoinErrorCode

local PWorldEntUtil = {}

local function GetCounterValue(CounterID)
    return _G.CounterMgr:GetCounterCurrValue(CounterID) or 0
end

-------------------------------------------------------------------------------------------------------
---@see 副本类型策略

--- GetPol
---@param EntID any entrance id which is pworld id
---@param EntTy any entrance type
---@return PWorldEntPol a pol
function PWorldEntUtil.GetPol(EntID, EntTy)
    if PWorldEntUtil.IsDailyRandom(EntTy) then
        if PWorldEntUtil.IsEntDirector(EntID, EntTy) then
            return require("Game/PWorld/Entrance/Policy/PWorldEntPolDT")
        else
            return require("Game/PWorld/Entrance/Policy/PWorldEntPolDR")
        end
    elseif PWorldEntUtil.IsChocoboTrack(EntTy) then
        return require("Game/PWorld/Entrance/Policy/PWorldEntPolChocobo")
    elseif PWorldEntUtil.IsPVP(EntTy) then
        return require("Game/PWorld/Entrance/Policy/PWorldEntPolPVP")
    else
        return require("Game/PWorld/Entrance/Policy/PWorldEntPolNM")
    end
end

local TypeKey = "TypeID"
-- local CateKey = "TypeID"

-------------------------------------------------------------------------------------------------------
---@see 转译配置表并组织数据

local function GatherCfgTreeViewData(InType)
    local Cfg = PWorldEntUtil.IsDailyRandom(InType) and SceneEnterDailyRandomCfg or SceneEnterCfg
    local All = Cfg:FindAllCfg()
    local Dict = {}
    local PriorityDict = {}
    for _, V in ipairs(All) do
        local Cate = 1 -- V[CateKey]    #TODO PENDING DELETE
        local Type = V[TypeKey]
        if Type == InType then

            local Pol = PWorldEntUtil.GetPol(V.ID, InType)
            local Test = Pol:CheckFilter(V.ID)

            -- Test = true
            if Test then
                if Dict[Cate] == nil then
                    Dict[Cate] = {Cate = Cate, Type = InType, IDs = {}}
                    PriorityDict[Cate] = {}
                end
                table.insert(Dict[Cate].IDs, V.ID)
                PriorityDict[Cate][V.ID] = V.Priority or 0
            end
        end
    end

    -- sort
    for Cate, Info in pairs(Dict) do
        table.sort(Info.IDs, function(A, B)
            return PriorityDict[Cate][A] < PriorityDict[Cate][B]
        end)
    end
    return Dict
end

local function GatherChocoboCfgTreeViewData()
    local All = SceneEnterCfg:FindAllCfg()
    local Dict = {}
    local PriorityDict = {}
    local Cate = 1 -- V[CateKey]
    for _, V in ipairs(All) do
        local Type = V[TypeKey]
        if Type == ProtoCommon.ScenePoolType.ScenePoolChocobo then
            if Dict[Cate] == nil then
                Dict[Cate] = {Cate = Cate, Type = Type, IDs = {}}
                PriorityDict[Cate] = {}
            end
            table.insert(Dict[Cate].IDs, V.ID)
            PriorityDict[Cate][V.ID] = V.Priority or 0
        end
    end

    -- sort
    -- #TODO Remove Cate
    for i, Info in pairs(Dict) do
        table.sort(Info.IDs, function(A, B)
            return PriorityDict[i][A] < PriorityDict[i][B]
        end)
    end

    ---随机赛道
    Cate = 2
    local Index = math.floor(math.random(1, #Dict[1].IDs))
    if Dict[Cate] == nil then
        Dict[Cate] = {Cate = Cate, Type =  ProtoCommon.ScenePoolType.ScenePoolChocoboRandomTrack, IDs = {}}
        PriorityDict[Cate] = {}
    end
    local TempID = Dict[1].IDs[Index]
    table.insert(Dict[Cate].IDs, TempID)
    PriorityDict[Cate][TempID] = 0

    --交换
    local TempDict = Dict[Cate]
    Dict[Cate] = Dict[1]
    Dict[1] = TempDict

    return Dict
end

local function GatherCrystallineTreeViewData(Type)
    local Pol = PWorldEntUtil.GetPol(nil, Type)
    if Pol == nil then
        _G.FLOG_ERROR("[GatherCrystallineTreeViewData]Get pvp policy nil")
        return
    end
    
    local All = SceneEnterCfg:FindAllCfg()
    local Dict = {}
    local PriorityDict = {}
    local Category = 1
    -- 练习赛
    for _, Cfg in ipairs(All) do
        local CfgType = Cfg[TypeKey]
        if CfgType == ScenePoolType.ScenePoolPVPCrystal then
            if Cfg.IsHideInList ~= 1 then
                local Test = Pol:CheckFilter(Cfg.ID)
                if Test then
                    if Dict[Category] == nil then
                        Dict[Category] = {Cate = Category, Type = CfgType, IDs = {}}
                        PriorityDict[Category] = {}
                    end
                    table.insert(Dict[Category].IDs, Cfg.ID)
                    PriorityDict[Category][Cfg.ID] = Cfg.Priority or 0
                end
            end
        end
    end

    Category = 2
    -- 段位赛
    for _, Cfg in ipairs(All) do
        local CfgType = Cfg[TypeKey]
        if CfgType == ScenePoolType.ScenePoolPVPCrystalRank then
            if Cfg.IsHideInList ~= 1 then
                local Test = Pol:CheckFilter(Cfg.ID)
                if Test then
                    if Dict[Category] == nil then
                        Dict[Category] = {Cate = Category, Type = CfgType, IDs = {}}
                        PriorityDict[Category] = {}
                    end
                    table.insert(Dict[Category].IDs, Cfg.ID)
                    PriorityDict[Category][Cfg.ID] = Cfg.Priority or 0
                end
            end
        end
    end

    Category = 3
    -- 自定赛
    for _, Cfg in ipairs(All) do
        local CfgType = Cfg[TypeKey]
        if CfgType == ScenePoolType.ScenePoolPVPCrystalCustom then
            if Cfg.IsHideInList ~= 1 then
                local Test = Pol:CheckFilter(Cfg.ID)
                if Test then
                    if Dict[Category] == nil then
                        Dict[Category] = {Cate = Category, Type = CfgType, IDs = {}}
                        PriorityDict[Category] = {}
                    end
                    table.insert(Dict[Category].IDs, Cfg.ID)
                    PriorityDict[Category][Cfg.ID] = Cfg.Priority or 0
                end
            end
        end
    end

    for Cate, Info in pairs(Dict) do
        table.sort(Info.IDs, function(A, B)
            return PriorityDict[Cate][A] < PriorityDict[Cate][B]
        end)
    end
    return Dict
end

-- 生成&合并 副本入口列表
function PWorldEntUtil.GetPWordTreeViewCfg(Type)
    if Type == ProtoCommon.ScenePoolType.ScenePoolChocobo then
       return GatherChocoboCfgTreeViewData()
    end

    if Type == ProtoCommon.ScenePoolType.ScenePoolPVPCrystal then
        return GatherCrystallineTreeViewData(Type)
    end

    return GatherCfgTreeViewData(Type)
end

-- 生成副本类型列表数据
function PWorldEntUtil.GetPWordTypeListViewData()
    local Data = {
        [1] = {
            PWorldTypeID = 1,
        },

        [2] = {
            PWorldTypeID = 2,
        },

        [3] = {
            PWorldTypeID = 3,
        },

        [4] = {
            PWorldTypeID = 4,
        },
    }

    return Data
end

-------------------------------------------------------------------------------------------------------
---@see 常用的工具函数

-- 是否是日随
function PWorldEntUtil.IsDailyRandom(TypeID)
    return TypeID == ScenePoolType.ScenePoolRandom
end

--是否陆行鸟
function PWorldEntUtil.IsChocoboTrack(TypeID)
    return TypeID == ScenePoolType.ScenePoolChocobo or TypeID == ScenePoolType.ScenePoolChocoboRandomTrack
end

--是否陆行鸟随机赛道
function PWorldEntUtil.IsChocoboRandomTrack(TypeID)
    return TypeID == ScenePoolType.ScenePoolChocoboRandomTrack
end

--是否PVP
function PWorldEntUtil.IsPVP(TypeID)
    return PWorldEntUtil.IsCrystalline(TypeID) or PWorldEntUtil.IsFrontline(TypeID)
end

--是否水晶冲突
function PWorldEntUtil.IsCrystalline(TypeID)
    return PWorldEntUtil.IsCrystallineExercise(TypeID) or PWorldEntUtil.IsCrystallineRank(TypeID) or PWorldEntUtil.IsCrystallineCustom(TypeID)
end

--是否水晶冲突练习赛
function PWorldEntUtil.IsCrystallineExercise(TypeID)
    return TypeID == ScenePoolType.ScenePoolPVPCrystal
end

--是否水晶冲突段位赛
function PWorldEntUtil.IsCrystallineRank(TypeID)
    return TypeID == ScenePoolType.ScenePoolPVPCrystalRank
end

--是否水晶冲突自定赛
function PWorldEntUtil.IsCrystallineCustom(TypeID)
    return TypeID == ScenePoolType.ScenePoolPVPCrystalCustom
end

-- 是否纷争前线
function PWorldEntUtil.IsFrontline(TypeID)
    return false
end

function PWorldEntUtil.IsMuren(EntID)
    local Cfg = SceneEnterCfg:FindCfgByKey(EntID)
    return Cfg and Cfg.TypeID == ScenePoolType.ScenePoolMuRen
end

-- 获取幻卡对局室ID
function PWorldEntUtil.GetMagicCardTourneyPWorldID()
    local EnterTypeCfg = SceneEnterTypeCfg:FindCfg(string.format("Type == %d", ScenePoolType.ScenePoolFantasyCard))
    local TypeID = EnterTypeCfg and EnterTypeCfg.ID or 0
    local Cfg = SceneEnterCfg:FindCfg(string.format("TypeID == %d", TypeID))
    return Cfg and Cfg.ID
end

-- 获取副本入口名
function PWorldEntUtil.GetPWorldEntName(EntID, IsRandom)
    if IsRandom then
        local Cfg = SceneEnterDailyRandomCfg:FindCfgByKey(EntID)
        if Cfg then
            return Cfg.Name
        end
    else
        local PCfg = PworldCfg:FindCfgByKey(EntID)
        if PCfg then
            return PCfg.PWorldName
        end
    end

    return ""
end

-- 获取参加的成员列表
function PWorldEntUtil.GetPWorldEntranceJoinMemIDList()
    return PWorldEntPolUtil.GetPWorldEntranceJoinMemIDList()
end

-- 获取参加成员的职能表
function PWorldEntUtil.GetMemProfFuncDict(MemRoleIDList)
    return PWorldEntPolUtil.GetMemProfFuncDict(MemRoleIDList)
end

-- 获取副本需要的职能表
function PWorldEntUtil.GetRequireMemProfFunc(PWEntID, Ty)
    return PWorldEntPolUtil.GetRequireMemProfFunc(PWEntID, Ty)
end

-- 获取副本需要的成员数
function PWorldEntUtil.GetRequireMemCnt(PWEntID, Ty)
    if PWorldEntUtil.IsPVP(Ty) then
        local EntCfg = SceneEnterCfg:FindCfgByKey(PWEntID)
        if EntCfg == nil then return 0 end

        return EntCfg.PVPAdvanceProfNum
    else
        Ty = Ty or SceneMode.SceneModeNormal
        local EntCfg = PWorldEntUtil.IsDailyRandom(Ty) and SceneEnterDailyRandomCfg:FindCfgByKey(PWEntID) or SceneEnterCfg:FindCfgByKey(PWEntID)
        if not EntCfg then
            return 0
        end
        local RecoverClassCnt = EntCfg.NurseProfNum
        local GuardClassCnt = EntCfg.GuardProfNum
        local AttackClassCnt = EntCfg.AttackProfNum
        local MaxMemCnt = RecoverClassCnt + GuardClassCnt + AttackClassCnt
        return MaxMemCnt
    end
end

-- 根据副本类型，检查自己能不能参加
function PWorldEntUtil.PreCheck(EntID, EntTy)
    return PWorldEntUtil.GetPol(EntID, EntTy):CheckJoinPre(EntID)
end

-- 判断是不是日随中的指导者副本类型
function PWorldEntUtil.IsEntDirector(EntID, EntTy)
    if not PWorldEntUtil.IsDailyRandom(EntTy) then
        return false
    end

    local DRCfg = SceneEnterDailyRandomCfg:FindCfgByKey(EntID)
    if not DRCfg then
        return false
    end

    return DRCfg.ID == 4
 end

function PWorldEntUtil.JoinCheck()
    local PWorldEntDetailVM = _G.PWorldEntDetailVM
    local EntID = PWorldEntDetailVM.CurEntID
    local EntTy = PWorldEntDetailVM.EntTy
    return PWorldEntUtil.GetPol(EntID, EntTy):CheckJoin(EntID)
end

function PWorldEntUtil.EnterTest()
    local PWorldEntDetailVM = _G.PWorldEntDetailVM
    local EntID = PWorldEntDetailVM.CurEntID
    local EntTy = PWorldEntDetailVM.EntTy
    return PWorldEntUtil.GetPol(EntID, EntTy):CheckEnter(EntID)
end

function PWorldEntUtil.MatchCheck()
    local PWorldMatchMgr = _G.PWorldMatchMgr
    local EntType = _G.PWorldEntDetailVM.EntTy
    local MatchCnt = PWorldMatchMgr:GetMatchItemCnt()

    local IsPVP = PWorldEntUtil.IsPVP(EntType)
    if IsPVP then
        local NoMatch = MatchCnt == 0
        local NoChoco = PWorldMatchMgr:GetMatchChocoboEntID() == -1
        if NoMatch and NoChoco then
            local PVPMatchCnt = PWorldMatchMgr:GetCrystallineItemCnt() + PWorldMatchMgr:GetFrontlineItemCnt()
            if PVPMatchCnt < PWorldEntDefine.PVPMatchMaxCnt then
                return true
            else
                return false, MatchTestRlt.PVPMatchOverflow
            end
        else
            return false, MatchTestRlt.PoolTypePVPMutex
        end
    elseif EntType == ProtoCommon.ScenePoolType.ScenePoolChocobo then
        local ret = MatchCnt == 0 and PWorldMatchMgr:GetMatchChocoboEntID() == -1
        return ret, MatchTestRlt.ChocoboMatchOverflow
    end

    if MatchCnt == 0 then
        return true
    end

    local PWorldMatchVM = _G.PWorldMatchVM
	local IsRandCur = PWorldMatchVM.IsDailyRandom -- 是否已在匹配日随
	local IsRandPool = PWorldEntUtil.IsDailyRandom(EntType) -- 现在想匹配的是否日随

    if IsRandCur then
        if IsRandPool then
            if MatchCnt < PWorldEntDefine.RandMatchMaxCnt then
                return true
            else
                return false, MatchTestRlt.RandMatchOverflow
            end
        else
            return false, 146030
        end
    else
        if not IsRandPool then
            if MatchCnt < PWorldEntDefine.NormMatchMaxCnt then
                return true
            else
                return false, MatchTestRlt.NormMatchOverflow
            end
        else
            return false, MatchTestRlt.PoolTypeFromNormToRand
        end

    end
end

-- 默认副本模式
function PWorldEntUtil.GetRandDefaultMode()
    return SceneMode.SceneModeNormal
end

-- 是否在执导者副本任务中
function PWorldEntUtil.IsInDirector()
    local PWorldID = _G.PWorldMgr:GetCurrPWorldResID()
    local DTID = 4 --指导者任务
    local DRCfg = SceneEnterDailyRandomCfg:FindCfgByKey(DTID) or {}
    local PoolCfg = SceneDailyRandomTaskPoolCfg:FindCfgByKey(DRCfg.PoolID) or {}
    for _, ID in pairs(PoolCfg.ID or {}) do
        if PWorldID == ID then
            return true
        end
    end
end

-------------------------------------------------------------------------------------------------------
---@see 界面显示外部接口

--- 每日随机
function PWorldEntUtil.ShowPWorldEntViewDR(EntID)
    if not EntID then
        return
    end

    PWorldEntUtil.ShowPWorldEntView(ScenePoolType.ScenePoolRandom, EntID)
end

--- 非每日随机
function PWorldEntUtil.ShowPWorldEntViewNM(EntID)
    if not EntID then
        return
    end

    local Cfg = SceneEnterCfg:FindCfgByKey(EntID)

    if Cfg then
        PWorldEntUtil.ShowPWorldEntView(Cfg.TypeID, EntID)
    else
        FLOG_ERROR("ShowPWorldEntViewNM cfg = nil EntID = " .. tostring(EntID))
    end
end

--- 显示副本入口
--- @param Type 副本入口类型
--- @param ID 该类型下副本入口ID
function PWorldEntUtil.ShowPWorldEntView(TypeID, EntID)
    _G.UIViewMgr:ShowView(_G.UIViewID.PWorldEntranceSelectPanel, {
        EID = EntID,
        TypeID = TypeID,
    })
end

local function GetPrettyHardPriority(Cfg)
    return Cfg and Cfg["ZeroFormPriority"] or 0
end

--- 是否为高难本
---@param Ent any
function PWorldEntUtil.IsPrettyHardPWorld(Ent)
    return GetPrettyHardPriority(PWorldEntUtil.GetCfg(Ent, SceneEnterCfg)) > 0
end

function PWorldEntUtil.IsPrettyHardEntranceJoinable(EntID)
    local Cfg =  SceneEnterCfg:FindCfgByKey(EntID)
    if not PWorldEntUtil.IsPrettyHardPWorld(Cfg) then
       return false
    end

    local Level = GetPrettyHardPriority(Cfg)
    if Level == 1 then
       return true
    end

    local PreCfg =  SceneEnterCfg:FindCfg(string.sformat("ZeroFormPriority = %s", Level - 1)) 
    if PreCfg == nil then
       return false 
    end

    return PWorldEntUtil.IsEntancePass(PreCfg.ID), PreCfg.ID
end

function PWorldEntUtil.IsEntancePass(EntID)
    local Cfg = PWorldEntUtil.GetCfg(EntID, PworldCfg)
    
    if Cfg then
        if Cfg.SucceedCounterID == nil then
            return false 
        end
        return (_G.CounterMgr:GetCounterCurrValue(Cfg.SucceedCounterID) or 0) > 0
    end
end

function PWorldEntUtil.GetCfg(V, CfgType)
    if type(V) == 'table' then
       return V 
    end

    if CfgType then
       return CfgType:FindCfgByKey(V)
    end
end

function PWorldEntUtil.IsWeeklyRewardNotMatch(Data)
    local CounterDatas = Data and Data.Counters or {}

    local CounterID
    if #CounterDatas > 0 then
        CounterID = CounterDatas[1].Counters[1].CounterID
    end

    local bGet = (_G.CounterMgr:GetCounterCurrValue(CounterID) or 0) > 0
    for _, v in ipairs(CounterDatas) do
        if ((v.Counters[1].Value or 0) > 0) ~= bGet then
            return true 
        end
    end
end

function PWorldEntUtil.IsWeeklyRewardGet(EntID)
    local CounterID = PWorldEntUtil.GetWeeklyRewardCounterID(EntID)
    if CounterID then
        return (_G.CounterMgr:GetCounterCurrValue(CounterID) or 0) > 0
    end
end

function PWorldEntUtil.GetWeeklyRewardCounterID(EntID)
    local Cfg = SceneEnterCfg:FindCfgByKey(EntID)
    if Cfg then
       return Cfg.ZeroFormWeeklyCounter
    end
end

function PWorldEntUtil.IsPassPWorld(EntID)
    local Cfg = PworldCfg:FindCfgByKey(EntID)
    return GetCounterValue(Cfg and Cfg.SucceedCounterID or nil) > 0
end

local function IsPassRandomPool(Cfg)
    local UnlockSceneNum = Cfg.UnlockSceneNum or 0
    if UnlockSceneNum <= 0 then
       return true 
    end

    local SuccCnt = 0
    local PreQuestList = PWorldEntPolUtil.GetDRPreQuestList(Cfg.ID)
    if PreQuestList == nil or #PreQuestList == 0 then
       return true 
    end

    for _, QID in pairs(PreQuestList) do
        if PWorldEntPolUtil.HasPreQuestFinish(QID) then
            SuccCnt = SuccCnt + 1
        end

        if SuccCnt >= UnlockSceneNum then
            return true
        end
    end
end

function PWorldEntUtil.IsDailyRandomUnlocked(EntID)
    local Cfg = SceneEnterDailyRandomCfg:FindCfgByKey(EntID)
    if Cfg == nil then
        return false
    end

    if Cfg.PreQuestID and Cfg.PreQuestID ~= 0 and not PWorldEntPolUtil.HasPreQuestFinish(Cfg.PreQuestID) then
       return false 
    end

    for _, PWorldID in ipairs(Cfg.PassSceneIDs or {}) do
        if not PWorldEntUtil.IsPassPWorld(PWorldID) then
            return false 
        end
    end

    if not IsPassRandomPool(Cfg) then
       return false 
    end

    return true
end

function PWorldEntUtil.GoToPWorldEntranceUI(Params)
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDEntertain) then
        _G.MsgTipsUtil.ShowTipsByID(260568)
        return false
    end

    _G.UIViewMgr:ShowView(_G.UIViewID.PWorldEntrancePanel, Params)
    return true
end

return PWorldEntUtil