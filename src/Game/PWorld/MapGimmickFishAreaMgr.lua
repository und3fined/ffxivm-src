
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local FishMgr = require("Game/Fish/FishMgr")

-- 渔场Gimmick区域和其他Gimmick区域不同，需要单独处理，因此单独使用一个Mgr管理

---@class MapGimmickFishAreaMgr : MgrBase
local MapGimmickFishAreaMgr = LuaClass(MgrBase)

function MapGimmickFishAreaMgr:OnInit()
    self.CurrGimmickID = 0
    self.CurrFishAreaID = 0
    self.CurrAreaPriority = math.mininteger

    self.FishAreaPriorityMap = {}  -- 玩家当前所位于的区域的优先级（key-GimmickID,value-priority）
    self.FishGimmickAreaIDMap = {} -- 玩家所处Gimmick区域ID与渔场ID的映射(key-GimmickID,value-AreaID)
    
end

function MapGimmickFishAreaMgr:Reset()
    self:ClearCurrAreaID()

    self.FishAreaPriorityMap = {}
    self.FishGimmickAreaIDMap = {}
end

function MapGimmickFishAreaMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnWorldMapExit)
end

-- 发生传送时默认离开所有渔场，传送结束后
function MapGimmickFishAreaMgr:OnWorldMapExit()
    local AreaID = self.CurrGimmickID
    if AreaID and AreaID ~= 0 then
        FishMgr:OnExitFishArea(AreaID , true)
    end
    self:Reset()
end

function MapGimmickFishAreaMgr:SetCurrAreaID(GimmickID)
    self.CurrGimmickID = GimmickID
    self.CurrFishAreaID = self.FishGimmickAreaIDMap[GimmickID]
    self.CurrAreaPriority = self.FishAreaPriorityMap[GimmickID]
end

function MapGimmickFishAreaMgr:ClearCurrAreaID()
    self.CurrGimmickID = 0
    self.CurrFishAreaID = 0
    self.CurrAreaPriority = math.mininteger
end

-- 玩家进入钓鱼Gimmick区域触发
-- EventParam = {AreaID = DynData.ID , FishAreaID = FishAreaID , Priority = Priority }
function MapGimmickFishAreaMgr:EnterFishArea(Params)
    local AreaID = Params.FishAreaID
    local Priority = Params.Priority
    local GimmickID = Params.AreaID
    self.FishAreaPriorityMap[GimmickID] = Priority
    self.FishGimmickAreaIDMap[GimmickID] = AreaID
    FLOG_INFO("[MapGimmickFishAreaMgr]EnterFishArea AreaID = "..AreaID.."GimmickID = "..GimmickID)

    local MaxGimmickID = self:JudgePriority()
    if MaxGimmickID ~= self.CurrGimmickID then
        self:SetCurrAreaID(MaxGimmickID)
        local CurAreaID = self.CurrFishAreaID
        FishMgr:OnEnterFishArea(CurAreaID,MaxGimmickID)
    end
end

-- 玩家离开钓鱼Gimmick区域触发
-- EventParam = {AreaID = DynData.ID , FishAreaID = FishAreaID }
function MapGimmickFishAreaMgr:ExitFishArea(Params)
    local GimmickID = Params.AreaID
    self.FishAreaPriorityMap[GimmickID] = nil
    self.FishGimmickAreaIDMap[GimmickID] = nil
    FLOG_INFO("[MapGimmickFishAreaMgr]ExitFishArea GimmickID = "..GimmickID)

    local MaxGimmickID = self:JudgePriority()
    if MaxGimmickID == 0 then
        self:ClearCurrAreaID()
        FishMgr:OnExitFishArea(GimmickID, false)
    elseif MaxGimmickID ~= self.CurrGimmickID then
        self:SetCurrAreaID(MaxGimmickID)
        local CurAreaID = self.CurrFishAreaID
        FishMgr:OnEnterFishArea(CurAreaID,MaxGimmickID)
    end
end

-- 存在渔场重叠的情况,渔场重叠情况下使用区域优先级判定,在此找出优先级最高的所在区域,就是当前生效的渔场
function MapGimmickFishAreaMgr:JudgePriority()
    local FishAreaPriorityMap = self.FishAreaPriorityMap
    local MaxPriority = math.mininteger
    local MaxGimmickID = 0
    for k,v in pairs(FishAreaPriorityMap) do
        if nil ~= v and v > MaxPriority then
            MaxPriority = v
            MaxGimmickID = k
        end
    end
    return MaxGimmickID
end

return MapGimmickFishAreaMgr