--- 自定义技能栏位
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local CommonUtil = require("Utils/CommonUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProtoRes = require("Protocol/ProtoRes")
local SkillSystemGlobalCfg = require("TableCfg/SkillSystemGlobalCfg")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local EventID = require("Define/EventID")
local Json = require("Core/Json")
local ObjectGCType = require("Define/ObjectGCType")

local SkillSystemMgr, PWorldMgr, ClientSetupMgr, EventMgr
local EMapType <const>    = SkillUtil.MapType
local DragOpPath <const> = "Class'/Game/UI/BP/Skill/Item/SkillCustomDragDropOperation.SkillCustomDragDropOperation_C'"
local PROF_ID_MAX <const> = 100  -- 计算ClientSetupID用，假设ProfID永远不会超过100个
local EmptyTable <const>  = {}



---@class SkillCustomMgr : MgrBase
local SkillCustomMgr = LuaClass(MgrBase)

function SkillCustomMgr:OnInit()
    SkillSystemMgr = _G.SkillSystemMgr
    PWorldMgr = _G.PWorldMgr
    ClientSetupMgr = _G.ClientSetupMgr
    EventMgr = _G.EventMgr

    -- SetupID 和 CustomIndexMap的映射
    self.CachedSetupMap = {}
end

function SkillCustomMgr:OnBegin()
    self.DragOpClass = ObjectMgr:LoadClassSync(DragOpPath, ObjectGCType.Hold)
end

function SkillCustomMgr:OnEnd()
end

function SkillCustomMgr:OnShutdown()

end

function SkillCustomMgr:OnRegisterNetMsg()

end

function SkillCustomMgr:OnRegisterGameEvent()
end

-- 每个职业的PVE和PVP都可以单独设置技能栏位, 都有一个独立的SetupID
local function GetClientSetupID(bMajor)
    local ProfID
    local MapType
    if bMajor then
        ProfID = MajorUtil.GetMajorProfID()
        local Cfg = PWorldMgr:GetCurrPWorldTableCfg()
        local bCanPK = Cfg and Cfg.CanPK > 0
        MapType = bCanPK and EMapType.PVP or EMapType.PVE
    else
        ProfID = SkillSystemMgr.ProfID
        MapType = SkillSystemMgr:GetCurrentMapType()
    end
    if ProfID and MapType and ProfID > 0 and MapType > 0 then
        ProfID = ProfUtil.GetAdvancedProf(ProfID)
        return ClientSetupID.SkillCustomIndex_Start + (MapType - 1) * PROF_ID_MAX + ProfID
    end
end

function SkillCustomMgr:Enter()
    local SetupID = GetClientSetupID(false) or 0
    local CusotmIndexMap = self.CachedSetupMap[SetupID]
    if not CusotmIndexMap then
        FLOG_ERROR("[SkillCustomMgr:Enter] Cannot find CusotmIndexMap for SetupID %d", SetupID)
    end
    self.EditingCusotmIndexMap = table.deepcopy(CusotmIndexMap or {})
    EventMgr:SendEvent(EventID.SkillCustomEnter)

    self.CurrentSelectedIndex = nil
    self.CurrentDraggedIndex = nil
    self.CurrentHoveringIndex = nil
    self.CurrentPressedIndex = nil
end

function SkillCustomMgr:Leave()
    EventMgr:SendEvent(EventID.SkillCustomLeave)
    self.EditingCusotmIndexMap = nil
end

function SkillCustomMgr:GetCustomIndex(OriginalIndex, bMajor)
    -- 看这块耗时情况, ClientSetupID可以缓存一下
    local _ <close> = CommonUtil.MakeProfileTag("SkillCustomMgr:GetCustomIndex")
    local SetupID = GetClientSetupID(bMajor)
    local CustomIndexMap = self.CachedSetupMap[SetupID]
    if not CustomIndexMap then
        return OriginalIndex
    end
    return CustomIndexMap[OriginalIndex] or OriginalIndex
end

function SkillCustomMgr:GetCustomIndexMap(bMajor)
    local SetupID = GetClientSetupID(bMajor)
    return self.CachedSetupMap[SetupID]
end


--region 对外接口

local SetupIDList = {}


--- 设置技能自定义栏位
--- 当前只能在技能系统内发起, 这块逻辑获取的ProfID和MapType都是技能系统内的
--- # TODO - 后面如果其他地方也可能发起, 需要修改逻辑
---@param CustomIndexMap table - 技能自定义栏位的映射
function SkillCustomMgr:SetCustomIndexMap(CustomIndexMap)
    -- 设置技能栏位目前只会在技能系统里面
    local SetupID = GetClientSetupID(false)
    if not SetupID then
        FLOG_ERROR("[SkillCustomMgr:SetCustomIndexMap] Cannot get proper SetupID.")
        return
    end
    self.CachedSetupMap[SetupID] = table.deepcopy(CustomIndexMap)

    local StandardJsonDict = {}
    for k, v in pairs(CustomIndexMap) do
        StandardJsonDict[tostring(k)] = v
    end

    local EncodedStr = Json.encode(StandardJsonDict)
    ClientSetupMgr:SendSetReq(SetupID, EncodedStr)
end


--- 获取技能自定义栏位映射
---@param bMajor boolean - 是否是主角(false的情况为技能系统)
---@param Callback fun(bSuccess : boolean, CustomIndexMap : table) - 请求结果的回调
function SkillCustomMgr:ReqCustomIndexMap(bMajor, Callback)
    local SetupID = GetClientSetupID(bMajor)
    if not SetupID then
        FLOG_ERROR("[SkillCustomMgr:ReqCustomIndexMap] Cannot get proper SetupID.")
        -- 保证不阻塞Callback的逻辑
        Callback(false, EmptyTable)
        return
    end

    local CachedCustomIndexMap = self.CachedSetupMap[SetupID]
    if CachedCustomIndexMap then
        Callback(true, CachedCustomIndexMap)
        return
    end

    self:RegisterGameEvent(EventID.ClientSetupPost, self.OnClientSetupPost)
    self.SetupPostCallback = Callback
    self.ReqSetupID = SetupID

    SetupIDList[1] = SetupID
    ClientSetupMgr:SendQueryReq(SetupIDList)
end

local function ListToMap(List)
    local Map = {}
    for i = 1, #List do
        Map[tonumber(List[i])] = true
    end
    return Map
end

function SkillCustomMgr:IsIndexEditable(Index, MapType)
    if not self.EditableIndexMap then
        local skill_system_global_cfg_id = ProtoRes.skill_system_global_cfg_id
        self.EditableIndexMap = {
            [EMapType.PVE] = ListToMap(SkillSystemGlobalCfg:FindValue(skill_system_global_cfg_id.SKILLSYSTEM_CFG_CUSTOM_INDEX_PVE, "Value")),
            [EMapType.PVP] = ListToMap(SkillSystemGlobalCfg:FindValue(skill_system_global_cfg_id.SKILLSYSTEM_CFG_CUSTOM_INDEX_PVP, "Value")),
        }
    end

    return self.EditableIndexMap[MapType][Index]
end

local function GetOriginalIndex(CustomIndexMap, InIndex)
    for OriginalIndex, Index in pairs(CustomIndexMap) do
        if Index == InIndex then
            return OriginalIndex
        end
    end
    return InIndex
end

function SkillCustomMgr:SwapIndexInternal(IndexA, IndexB, OriginalIndexA, OriginalIndexB)
    local EditingCusotmIndexMap = self.EditingCusotmIndexMap
    EditingCusotmIndexMap[OriginalIndexA] = IndexB
    EditingCusotmIndexMap[OriginalIndexB] = IndexA

    EventMgr:SendEvent(EventID.SkillEditingIndexSwap, IndexA, IndexB, OriginalIndexA, OriginalIndexB)
end

function SkillCustomMgr:SwapOriginalIndex(OriginalIndexA, OriginalIndexB)
    local EditingCusotmIndexMap = self.EditingCusotmIndexMap
    if not EditingCusotmIndexMap then
        return
    end

    local IndexA = EditingCusotmIndexMap[OriginalIndexA] or OriginalIndexA
    local IndexB = EditingCusotmIndexMap[OriginalIndexB] or OriginalIndexB
    self:SwapIndexInternal(IndexA, IndexB, OriginalIndexA, OriginalIndexB)
end

function SkillCustomMgr:SwapEditingIndex(IndexA, IndexB)
    local EditingCusotmIndexMap = self.EditingCusotmIndexMap
    if not EditingCusotmIndexMap then
        return
    end

    local OriginalIndexA = GetOriginalIndex(EditingCusotmIndexMap, IndexA)
    local OriginalIndexB = GetOriginalIndex(EditingCusotmIndexMap, IndexB)
    self:SwapIndexInternal(IndexA, IndexB, OriginalIndexA, OriginalIndexB)
end

function SkillCustomMgr:SaveEditingIndexMap()
    self:SetCustomIndexMap(self.EditingCusotmIndexMap)
end

function SkillCustomMgr:RestoreToDefault()
    local EditingCusotmIndexMap = self.EditingCusotmIndexMap
    if not EditingCusotmIndexMap then
        return
    end

    for OrginalIndex, Index in pairs(EditingCusotmIndexMap) do
        if OrginalIndex ~= Index then
            self:SwapOriginalIndex(OrginalIndex, Index)
        end
    end
    self.EditingCusotmIndexMap = {}
end

--endregion


function SkillCustomMgr:OnClientSetupPost(Params)
    local SetupID = Params.IntParam1
    if SetupID ~= self.ReqSetupID then
        return
    end
    self:UnRegisterGameEvent(EventID.ClientSetupPost, self.OnClientSetupPost)

    local StandardJsonDict = Json.decode(Params.StringParam1) or EmptyTable
    local CustomIndexMap = {}
    for k, v in pairs(StandardJsonDict) do
        CustomIndexMap[tonumber(k)] = v
    end
    self.CachedSetupMap[Params.IntParam1] = CustomIndexMap

    if self.SetupPostCallback then
        self.SetupPostCallback(true, CustomIndexMap)
        self.SetupPostCallback = nil
    end
    self.ReqSetupID = nil
end

return SkillCustomMgr