--
-- Author: henghaoli
-- Date: 2024-04-07 16:08:00
-- Description: 管理Skill表现相关
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ObjectPool = require("Game/ObjectPool/ObjectPool")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local SkillPreloadCfg = require("TableCfg/SkillPreloadCfg")
local StatusSingingCfg = require("TableCfg/StatusSingingCfg")
local StorageSkillCfg = require("TableCfg/StorageSkillCfg")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local SkillActionConfig = require("Game/Skill/SkillAction/SkillActionConfig")
local SelectTargetBase = require ("Game/Skill/SelectTarget/SelectTargetBase")
local SkillAssetLoader = require("Game/Skill/SkillAction/SkillAssetLoader")

local CellNameMap = SkillActionConfig.CellNameMap
local SingCellNameMap = SkillActionConfig.SingCellNameMap
local CellObjectPoolSizeMap = SkillActionConfig.CellObjectPoolSizeMap
local SingCellObjectPoolSizeMap = SkillActionConfig.SingCellObjectPoolSizeMap
local DefaultCellObjectPoolSize = SkillActionConfig.DefaultCellObjectPoolSize
local DefaultSingCellObjectPoolSize = SkillActionConfig.DefaultSingCellObjectPoolSize
local DefaultParseCellDataTimeLimit = SkillActionConfig.DefaultParseCellDataTimeLimit
local LuaPathPrefix = "Game/Skill/SkillAction/SkillCell/"

local SkillMode = ProtoCommon.SkillMode

local pbslice = require("pb.slice")
local pb = require("pb")

local UE = _G.UE
local FLuaLruCache = UE.FLuaLruCache
local FProfileTag = UE.FProfileTag
local StaticBegin = FProfileTag.UnsafeStaticBegin
local StaticEnd = FProfileTag.UnsafeStaticEnd
local TimerMgr
local USkillMgr

local LoadedSkillIDMap
local LoadedSingIDMap

local function ClearLoadedMap()
    LoadedSkillIDMap = {}
    LoadedSingIDMap = {}
end

local GetMicrosecondTimestamp = UE.UCommonUtil.GetMicrosecondTimestamp
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

local AllocObject <const> = ObjectPool.AllocObject
local FreeObject <const> = ObjectPool.FreeObject

local StackTop = 1



-- 因为CellData是会缓存复用的, 将其设置为只读
local function Readonly()
	error("Attempt to modify readonly skill cell data!")
end

-- __index是为了兼容UE JsonConverter奇怪的小驼峰
local CellDataMetaTable = {
    __newindex = Readonly,
    __index = UE.USkillUtil.CellDataIndex
}



---@class SkillActionMgr : MgrBase
local SkillActionMgr = LuaClass(MgrBase)

function SkillActionMgr:OnInit()
    SkillAssetLoader.Init()
end

function SkillActionMgr:OnBegin()
    local ESkillActionType = ProtoRes.ESkillActionType
    local ActionClassMap = {}
    local CellPoolMap = {}
    local SingCellPoolMap = {}

    -- 初始化对象池, 10ms左右
    do
        local _ <close> = CommonUtil.MakeProfileTag("SkillActionMgr:OnBegin-InitCellObjectPool")
        for Name, Value in pairs(ESkillActionType) do
            local ActionClassName = "skillaction." .. string.gsub(Name, "ESkillActionType_", "")
            ActionClassMap[Value] = ActionClassName

            local CellName = CellNameMap[Value]
            if CellName then
                local CellClass = require(LuaPathPrefix .. CellName)
                local function CellCtor()
                    return CellClass.New()
                end
                local CellPool = ObjectPool.New(CellCtor)
                CellPool:PreLoadObject(CellObjectPoolSizeMap[Value] or DefaultCellObjectPoolSize)
                CellPoolMap[Value] = CellPool
            end

            local SingCellName = SingCellNameMap[Value]
            if SingCellName then
                local CellClass = require(LuaPathPrefix .. SingCellName)
                local function CellCtor()
                    return CellClass.New()
                end
                local SingCellPool = ObjectPool.New(CellCtor)
                SingCellPool:PreLoadObject(SingCellObjectPoolSizeMap[Value] or DefaultSingCellObjectPoolSize)
                SingCellPoolMap[Value] = SingCellPool
            end
        end
    end

    self.ActionClassMap = ActionClassMap
    self.CellPoolMap = CellPoolMap
    self.SingCellPoolMap = SingCellPoolMap

    self.CellDataListMap = FLuaLruCache()
    self.CellDataListMap:Init(SkillActionConfig.CellDataListLruCacheSize)

    self.SingCellDataListMap = FLuaLruCache()
    self.SingCellDataListMap:Init(SkillActionConfig.SingCellDataListLruCacheSize)

    TimerMgr = _G.TimerMgr
    USkillMgr = UE.USkillMgr.Get()

    self.PreLoadStack = {}
    StackTop = 1
    LoadedSkillIDMap = {}
    LoadedSingIDMap = {}



    -- set hooks, 10ms左右
    do
        local _ <close> = CommonUtil.MakeProfileTag("SkillActionMgr:OnBegin-SetHooks")
        for Name, _, Type in pb.types() do
            if Type == "message" and string.startsWith(Name, ".skillaction.") then
                pb.hook(Name, function(CellData)
                    setmetatable(CellData, CellDataMetaTable)
                end)
            end
        end
    end

    -- 技能预加载map
    local _ <close> = CommonUtil.MakeProfileTag("SkillActionMgr:OnBegin-InitSkillPreLoadMap")
    self.SkillPreLoadMap = {
        [SkillMode.SKILL_MODE_PVE] = {},
        [SkillMode.SKILL_MODE_PVP] = {},
    }
    local SkillPreLoadMap = self.SkillPreLoadMap

    local CfgList = SkillPreloadCfg:FindAllCfg()
    for _, Cfg in ipairs(CfgList) do
        SkillPreLoadMap[Cfg.SkillMode][Cfg.Prof] = Cfg.SkillList
    end
end

function SkillActionMgr:OnEnd()
end

function SkillActionMgr:OnShutdown()
    SkillAssetLoader.UnInit()
end

function SkillActionMgr:OnRegisterNetMsg()
end

function SkillActionMgr:OnRegisterGameEvent()
    local EventID = _G.EventID
    self:RegisterGameEvent(EventID.WorldPreLoad, self.OnWorldPreLoad)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnMajorCreate)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnProfSwitch)
end

function SkillActionMgr:GetActionList(SubSkillID)
    local _ <close> = CommonUtil.MakeProfileTag("SkillActionMgr:GetActionList")
    local CellPoolMap = self.CellPoolMap
    local CellDataList = self:GetCellDataList(SubSkillID)
    -- local Actions = table.new(#CellDataList, 0)
    local Actions = {}
    for _, CellData in ipairs(CellDataList) do
        local Type = CellData.Type
        local CellPool = CellPoolMap[Type]
        if CellPool then
            local CellObject = AllocObject(CellPool)
            CellObject.CellData = CellData
            table.insert(Actions, CellObject)
        else
            -- FLOG_WARNING("Cell class of type %d is not implemented yet.", Type)
        end
    end

    return Actions
end

function SkillActionMgr:GetSingActionList(SingID)
    local _ <close> = CommonUtil.MakeProfileTag("SkillActionMgr:GetSingActionList")

    -- TODO # - 后面改成SingCellMap
    local SingCellPoolMap = self.SingCellPoolMap
    local SingCellDataList = self:GetSingCellDataList(SingID)
    local Actions = {}
    for _, CellData in ipairs(SingCellDataList) do
        local Type = CellData.Type
        local SingCellPool = SingCellPoolMap[Type]
        if SingCellPool then
            local CellObject = AllocObject(SingCellPool)
            CellObject.CellData = CellData
            table.insert(Actions, CellObject)
        else
            FLOG_WARNING("Sing cell class of type %d is not implemented yet.", Type)
        end
    end

    return Actions
end

function SkillActionMgr:GetCellDataList(SubSkillID, TimeLimit)
    local CellDataListMap = self.CellDataListMap
    local CellDataList = CellDataListMap:FindAndTouch(SubSkillID)

    if CellDataList then
        return CellDataList
    end

    local StartTime
    if TimeLimit then
        StartTime = GetMicrosecondTimestamp()
    end

    local UDBMgr = UE.UDBMgr.Get()
    local SubSkillIDStr = tostring(SubSkillID)
    local U8Array = UDBMgr:LuaGetBlob("c_skill_sub_cfg", "ID = " .. SubSkillIDStr, "ProtoDisplay")
    local Slice = pbslice.new_with_raw_pointer(U8Array:GetData(), U8Array:Length())

    CellDataList = self:ParseBinaryActionData(Slice, SubSkillID, nil, StartTime, TimeLimit)
    CellDataListMap:Add(SubSkillID, CellDataList)
    return CellDataList
end

function SkillActionMgr:GetSingCellDataList(SingID, TimeLimit)
    local SingCellDataListMap = self.SingCellDataListMap
    local SingCellDataList = SingCellDataListMap:FindAndTouch(SingID)

    if SingCellDataList then
        return SingCellDataList
    end

    local StartTime
    if TimeLimit then
        StartTime = GetMicrosecondTimestamp()
    end

    local UDBMgr = UE.UDBMgr.Get()
    local SingIDStr = tostring(SingID)
    local U8Array = UDBMgr:LuaGetBlob("c_status_singing_cfg", "ID = " .. SingIDStr, "ProtoDisplay")
    local Slice = pbslice.new_with_raw_pointer(U8Array:GetData(), U8Array:Length())

    SingCellDataList = self:ParseBinaryActionData(Slice, nil, SingID, StartTime, TimeLimit)
    SingCellDataListMap:Add(SingID, SingCellDataList)
    return SingCellDataList
end

function SkillActionMgr:ParseBinaryActionData(Slice, SubSkillID, SingID, StartTime, TimeLimit)
    local _ <close> = CommonUtil.MakeProfileTag("SkillActionMgr:ParseBinaryActionData")
    pb.option("enable_hooks")
    local Status, CellDataList = xpcall(
        self.ParseBinaryActionDataInternal,
        CommonUtil.XPCallLog, self,
        Slice, SubSkillID, SingID, StartTime, TimeLimit)
    pb.option("disable_hooks")

    return Status and CellDataList or {}
end

function SkillActionMgr:ParseBinaryActionDataInternal(Slice, SubSkillID, SingID, StartTime, TimeLimit)
    local ActionClassMap = self.ActionClassMap
    local ActionCount = Slice:unpack("v") or 0
    local IDType = SubSkillID and "SubSkillID" or "SingID"
    local ID = SubSkillID or SingID
    local CellDataList = {}

    for i = 1, ActionCount do
        if StartTime then
            local CurrentTime = GetMicrosecondTimestamp()
            if CurrentTime - StartTime > TimeLimit then
                -- 只有协程会调用到这里, 先消掉上层ParseBinaryActionData的ProfileTag
                StaticEnd()
                coroutine.yield()
                StaticBegin("SkillActionMgr:ParseBinaryActionData")
                StartTime = GetMicrosecondTimestamp()
            end
        end
        local MessageType = Slice:unpack("v")
        local MessageTypeName = ActionClassMap[MessageType]
        local MessageLength = Slice:unpack("v")

        if MessageTypeName and MessageTypeName ~= "skillaction.None" then
            -- local CellData =  { Type = MessageType }
            -- pb.resetdefaults(MessageTypeName, CellData)
            if MessageLength > 0 then
                local MessageSlice = Slice:unpack("c", MessageLength)
                local CellData = pb.decode(MessageTypeName, MessageSlice)
                rawset(CellData, "Type", MessageType)
                table.insert(CellDataList, CellData)
            else
                FLOG_WARNING(
                    "[SkillActionMgr] %s - %d, Num Cell - %d: Message length is 0!", IDType, ID, i)
            end
        end
    end

    if ActionCount == 0 then
        FLOG_WARNING("[SkillActionMgr] Empty ProtoDisplay, %s: %d.", IDType, ID)
    end

    return CellDataList
end

function SkillActionMgr:FreeCellObject(Type, CellObject)
    FreeObject(self.CellPoolMap[Type], CellObject)
end

function SkillActionMgr:FreeSingCellObject(Type, CellObject)
    FreeObject(self.SingCellPoolMap[Type], CellObject)
end



local PreLoadFieldsMap = SkillActionConfig.PreLoadFieldsMap
local PreLoadInterval = SkillActionConfig.PreLoadInterval

local AssetsToLoad = UE.TArray(UE.FString)
local TArrayClear = AssetsToLoad.Clear
local TArrayAdd = AssetsToLoad.Add



function SkillActionMgr:ActivatePreLoadTimer()
    if self.PreLoadTimerID then
        return
    end

    self.PreLoadTimerID = TimerMgr:AddTimer(self, self.OnPreLoadTick, 0, PreLoadInterval, 0)
end

function SkillActionMgr:DeactivatePreLoadTimer()
    local PreLoadTimerID = self.PreLoadTimerID
    if PreLoadTimerID then
        TimerMgr:CancelTimer(PreLoadTimerID)
        self.PreLoadTimerID = nil
    end
end

---外部预加载主技能调用的接口
---@param SkillID number
function SkillActionMgr:PreLoadMainSkill(SkillID)
    self:PushPreLoadOperation({
        Func = self.AsyncPreLoadMainSkill,
        ID = SkillID
    })
end

---外部预加载吟唱技能调用的接口
---@param SingID number
function SkillActionMgr:PreLoadSingSkill(SingID)
    self:PushPreLoadOperation({
        Func = self.AsyncPreLoadSingSkill,
        ID = SingID
    })
end

---@param PreLoadParams table 一个表, 包含一个协程和一些必要的参数
function SkillActionMgr:PushPreLoadOperation(PreLoadParams)
    self:ActivatePreLoadTimer()
    self.PreLoadStack[StackTop] = PreLoadParams
    StackTop = StackTop + 1
end

function SkillActionMgr:OnPreLoadTick()
    if StackTop == 1 then
        self:DeactivatePreLoadTimer()
        return
    end

    local _ <close> = CommonUtil.MakeProfileTag("SkillActionMgr:OnPreLoadTick")
    local PreLoadStack = self.PreLoadStack
    local PreLoadParams = PreLoadStack[StackTop - 1]

    local CoroutineHandle = PreLoadParams.CoroutineHandle
    if CoroutineHandle then
        local Status, ErrorMsg = coroutine.resume(CoroutineHandle, self, PreLoadParams.ID)
        if not Status then
            xpcall(error, CommonUtil.XPCallLog, ErrorMsg)
        end

        if coroutine.status(CoroutineHandle) == "dead" then
            StackTop = StackTop - 1
            PreLoadStack[StackTop] = nil
        end
    else
        CoroutineHandle = coroutine.create(PreLoadParams.Func)
        if not CoroutineHandle then
            FLOG_ERROR("[SkillActionMgr] Failed to create coroutine for preload.")
            StackTop = StackTop - 1
            PreLoadStack[StackTop] = nil
        end
        PreLoadParams.CoroutineHandle = CoroutineHandle
    end
end

local function CheckAssetNameValid(AssetName)
    if type(AssetName) == "string" and #AssetName > 0 and AssetName ~= "None" and AssetName ~= "NONE" then
        return true
    end

    return false
end

function SkillActionMgr:OnPreLoadSkillInternal(CellDataList)
    TArrayClear(AssetsToLoad)
    local bHasAsset = false

    for _, CellData in ipairs(CellDataList) do
        local PreLoadFields = PreLoadFieldsMap[CellData.Type]
        local PreLoadConfigType = type(PreLoadFields)
        if PreLoadConfigType == "table" then
            for _, FieldName in ipairs(PreLoadFields) do
                local AssetName = CellData[FieldName]
                if CheckAssetNameValid(AssetName) then
                    TArrayAdd(AssetsToLoad, AssetName)
                    bHasAsset = true
                end
            end
        elseif PreLoadConfigType == "function" then
            local AssetsInCellData = PreLoadFields(CellData)
            for _, AssetName in ipairs(AssetsInCellData) do
                if CheckAssetNameValid(AssetName) then
                    TArrayAdd(AssetsToLoad, AssetName)
                    bHasAsset = true
                end
            end
        end
    end

    if bHasAsset then
        USkillMgr:LoadObjectsAsync(AssetsToLoad)
    end
end

function SkillActionMgr:AsyncPreLoadSubSkill(SubSkillID)
    local Cfg = SkillSubCfg:FindCfgByKey(SubSkillID)
    if not Cfg then
        return
    end
    -- coroutine.yield()

    USkillMgr:PreLoadSubSkillInfo(SubSkillID)
    coroutine.yield()

    local CellDataList = self:GetCellDataList(SubSkillID, DefaultParseCellDataTimeLimit)
    coroutine.yield()

    SelectTargetBase:PreloadSkillInfo(SubSkillID, Cfg)
    -- coroutine.yield()

    self:OnPreLoadSkillInternal(CellDataList)
end

function SkillActionMgr:AsyncPreLoadSingSkill(SingID)
    if LoadedSingIDMap[SingID] then
        return
    end
    LoadedSingIDMap[SingID] = true

    local Cfg = StatusSingingCfg:FindCfgByKey(SingID)
    if not Cfg then
        return
    end
    -- coroutine.yield()

    local SingCellDataList = self:GetSingCellDataList(SingID, DefaultParseCellDataTimeLimit)
    -- coroutine.yield()

    self:OnPreLoadSkillInternal(SingCellDataList)
end

function SkillActionMgr:AsyncPreLoadMainSkill(SkillID)
    if LoadedSkillIDMap[SkillID] then
        return
    end
    LoadedSkillIDMap[SkillID] = true

    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if not Cfg then
        return
    end
    -- coroutine.yield()

    SelectTargetBase:PreloadMainSkillInfo(SkillID, Cfg)
    USkillMgr:PreLoadMainSkillInfo(SkillID)
    coroutine.yield()

    local SubSkillList = Cfg.IdList
    for _, SubSkill in ipairs(SubSkillList) do
        self:AsyncPreLoadSubSkill(SubSkill.ID)
        coroutine.yield()
    end

    if Cfg.IsSing > 0 then
        self:AsyncPreLoadSingSkill(Cfg.SingID)
        coroutine.yield()
    end

    local StorageCfg = StorageSkillCfg:FindCfgByKey(SkillID)
    if StorageCfg ~= nil then
        self:AsyncPreLoadSingSkill(StorageCfg.SingID)
        coroutine.yield()

        local LevelList = StorageCfg.LevelList
        for _, LevelCfg in ipairs(LevelList) do
            self:AsyncPreLoadMainSkill(LevelCfg.SkillID)
            coroutine.yield()
        end
    end
end

function SkillActionMgr:OnWorldPreLoad()
    ClearLoadedMap()
end

--只有指定副本才允许职业技能预加载
--通常允许预加载时不支持转职
local function AllowMajorSkillInfoPreLoad()
    --幻想药副本中，不需要加载职业技能相关资源，可以防止幻想药UI加载缓慢的情况
    local PWorldInfo = _G.PWorldMgr:GetCurrPWorldTableCfg()
    if PWorldInfo and (PWorldInfo.MainPanelUIType == _G.LoginMapType.Fantasia or PWorldInfo.MainPanelUIType == _G.LoginMapType.HairCut) then
        return false
    end
    return true
end

function SkillActionMgr:OnMajorCreate()
    if not AllowMajorSkillInfoPreLoad() then
        return
    end

    local ProfID = MajorUtil.GetMajorProfID()
    self:OnProfSwitch({ ProfID = ProfID })
end

local Pattern = "(%d+)%-?(%d*)"
local function ParseSkillListStr(SkillListStr)
    local SkillList = {}
    for Start, End in string.gmatch(SkillListStr, Pattern) do
        Start = tonumber(Start)
        End = tonumber(End)
        if End then
            for i = Start, End do
                table.insert(SkillList, i)
            end
        else
            table.insert(SkillList, Start)
        end
    end
    return SkillList
end

function SkillActionMgr:OnProfSwitch(Params)
    local _ <close> = CommonUtil.MakeProfileTag("SkillActionMgr:OnProfSwitch")
    local SkillPreLoadMap = self.SkillPreLoadMap
    StackTop = 1  -- 清一下栈, 此时如果有未处理的任务就不处理了
    if not SkillPreLoadMap then
        FLOG_ERROR("[SkillActionMgr] Try to preload skill before SkillActionMgr init!")
        return
    end
    SelectTargetBase:ClearAllCache()
    ClearLoadedMap()

    local ProfID = Params.ProfID
    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local bPVP = PworldCfg:FindValue(CurrPWorldResID, "CanPK")
    local CurrSkillMode = bPVP ~= 0 and SkillMode.SKILL_MODE_PVP or SkillMode.SKILL_MODE_PVE

    local ProfSkillPreLoadMap = SkillPreLoadMap[CurrSkillMode]
    if not ProfSkillPreLoadMap then
        return
    end

    local AdvancedProfID = ProfUtil.GetAdvancedProf(ProfID)
    local SkillList = ProfSkillPreLoadMap[AdvancedProfID]
    if not SkillList then
        return
    end

    if type(SkillList) == "string" then
        SkillList = ParseSkillListStr(SkillList)
        ProfSkillPreLoadMap[AdvancedProfID] = SkillList
    end

    local Len = #SkillList
    for i = Len, 1, -1 do
        self:PreLoadMainSkill(SkillList[i])
    end
end

function SkillActionMgr:LogPoolInfo()
    FLOG_INFO("--------------- SkillActionMgr Start ---------------")
    local CellPoolMap = self.CellPoolMap or {}
    for Type, CellObjectPool in pairs(CellPoolMap) do
        local TypeName = CellNameMap[Type]
        SkillActionUtil.LogPoolInfo(TypeName, CellObjectPool, CellObjectPoolSizeMap[Type] or DefaultCellObjectPoolSize)
        FLOG_INFO(" ")
    end
    FLOG_INFO("--------------- SkillActionMgr End   ---------------")
end

return SkillActionMgr
