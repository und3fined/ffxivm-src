--
--Author: loiafeng
--Date: 2024-06-12 14:24:31
--Description: 管理加成状态，如搭档加成，部队加成
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local TimeUtil = require("Utils/TimeUtil")
local BonusStateUtil = require("Game/BonusState/BonusStateUtil")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local BuffDefine = require("Game/Buff/BuffDefine")
local BonusStateBuffCfg = require("TableCfg/BonusStateBuffCfg")

local MainTargetBuffsVM = require("Game/Buff/VM/MainTargetBuffsVM")
local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")

local EventID = require("Define/EventID")
local EventMgr
local GameNetworkMgr

local CS_CMD = ProtoCS.CS_CMD
local BONUS_STATE_CMD = ProtoCS.BonusStateCmd

---@class BonusStateMgr : MgrBase
local BonusStateMgr = LuaClass(MgrBase)

function BonusStateMgr:OnInit()
    self.BonusStateMap = {}  ---@type table<RoleID, table<BonusStateID, BonusStateDetail>>
end

function BonusStateMgr:OnBegin()
	EventMgr = _G.EventMgr
	GameNetworkMgr = _G.GameNetworkMgr
end

function BonusStateMgr:OnEnd()

end

function BonusStateMgr:OnShutdown()
end

function BonusStateMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BONUS_STATE, BONUS_STATE_CMD.BonusStateCmdUpdate, self.OnNetMsgBonusStateUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BONUS_STATE, BONUS_STATE_CMD.BonusStateCmdRemove, self.OnNetMsgBonusStateRemove)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BONUS_STATE, BONUS_STATE_CMD.BonusStateCmdPull, self.OnNetMsgBonusStatePull)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BONUS_STATE, BONUS_STATE_CMD.BonusStateCmdPullByRoleID, self.OnNetMsgBonusStateCmdPullByRoleID)
end

function BonusStateMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
    self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
end

function BonusStateMgr:OnRegisterTimer()
    self:RegisterTimer(self.OnTimerCheckBonusStateEndTime, 3, 3, 0)
end

----------------------------------------------------------------
---Internal

---@class BonusState
---@field ID number
---@field EndTime number
---@field Enable boolean

---@class BonusStateUpdateParams
---@field ID number
---@field EndTime number
---@field Enable boolean
---@field IsAdded boolean
---@field IsRemoved boolean

---@return BonusStateUpdateParams
local function PackBonusStateUpdateParams(ID, EndTime, Enable, IsAdded, IsRemoved)
    return { ID = ID, EndTime = EndTime, Enable = Enable, IsAdded = IsAdded, IsRemoved = IsRemoved }
end

function BonusStateMgr:UpdateBonusStates(RoleID, States)
    if nil == RoleID or 0 == RoleID or nil == States or #States == 0 then
        return
    end

    if nil == self.BonusStateMap[RoleID] then
        self.BonusStateMap[RoleID] = {}
    end

    local RoleBonusStates = self.BonusStateMap[RoleID]
    local UpdatedStates = {}

    for _, State in ipairs(States) do
        local OldState = RoleBonusStates[State.ID]
        -- 有变化的状态才需要更新
        if nil == OldState or OldState.EndTime ~= State.EndTime or OldState.Enable ~= State.Enable then
            RoleBonusStates[State.ID] = State
            table.insert(UpdatedStates, PackBonusStateUpdateParams(State.ID, State.EndTime, State.Enable, nil == OldState, false))
        end
    end

    if #UpdatedStates > 0 then
        self.SendBonusStateEvent(RoleID, UpdatedStates)
    end
end

function BonusStateMgr:RemoveBonusStates(RoleID, IDs)
    if nil == IDs or #IDs == 0 or nil == self.BonusStateMap[RoleID] then
        return
    end

    local RoleBonusStates = self.BonusStateMap[RoleID]
    local RemovedStates = {}

    for _, ID in ipairs(IDs) do
        local OldState = RoleBonusStates[ID]
        if OldState ~= nil then
            RoleBonusStates[ID] = nil
            table.insert(RemovedStates, PackBonusStateUpdateParams(ID, OldState.EndTime, OldState.Enable, false, true))
        end
    end

    if table.empty(RoleBonusStates) then
        self.BonusStateMap[RoleID] = nil
    end

    if #RemovedStates > 0 then
        self.SendBonusStateEvent(RoleID, RemovedStates)
    end
end

function BonusStateMgr:SetBonusStates(RoleID, States)
    if RoleID == nil or RoleID == 0 then
        return
    end

    local UpdatedStates = {}
    local OldRoleBonusStates = self.BonusStateMap[RoleID] or {}

    if nil ~= States and #States > 0 then 
        self.BonusStateMap[RoleID] = {}
        local RoleBonusStates = self.BonusStateMap[RoleID]

        for _, State in ipairs(States) do
            local OldState = OldRoleBonusStates[State.ID]
            OldRoleBonusStates[State.ID] = nil
            RoleBonusStates[State.ID] = State

            -- 有变化的状态才需要更新
            if nil == OldState or OldState.EndTime ~= State.EndTime or OldState.Enable ~= State.Enable then
                table.insert(UpdatedStates, PackBonusStateUpdateParams(State.ID, State.EndTime, State.Enable, nil == OldState, false))
            end
        end
    end

    -- 剩下的状态为需要移除的状态
    for _, State in pairs(OldRoleBonusStates) do
        table.insert(UpdatedStates, PackBonusStateUpdateParams(State.ID, State.EndTime, State.Enable, false, true))
    end

    if #UpdatedStates > 0 then
        self.SendBonusStateEvent(RoleID, UpdatedStates)
    end
end

function BonusStateMgr:RequestMajorBonusState()
    local MsgID = CS_CMD.CS_CMD_BONUS_STATE
	local SubMsgID = BONUS_STATE_CMD.BonusStateCmdPull

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BonusStateMgr:RequestBonusState(RoleID)
    local MsgID = CS_CMD.CS_CMD_BONUS_STATE
	local SubMsgID = BONUS_STATE_CMD.BonusStateCmdPullByRoleID

	local MsgBody = {}
    MsgBody.PullRole = {RoleID = RoleID}
	MsgBody.Cmd = SubMsgID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BonusStateMgr.SendBonusStateEvent(RoleID, States)
	for _, State in ipairs(States) do
        local RoleEntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
        local IsBuddy = BonusStateUtil.IsBuddyBonusState(State.ID)

        local EntityID = RoleEntityID
        if IsBuddy then
            EntityID = _G.BuddyMgr:GetBuddyByMaster(EntityID)
        end

        --TODO(loiafeng): 统一绑定ActorVM
        if State.IsRemoved then
            if not IsBuddy and MajorUtil.IsMajorByRoleID(RoleID) then
                MajorBuffVM:RemoveBuff(State.ID, 0, BuffDefine.BuffSkillType.BonusState)
            elseif EntityID ~= nil and EntityID ~= 0 and EntityID == MainTargetBuffsVM.EntityID then
                MainTargetBuffsVM:RemoveBuff(State.ID, 0, BuffDefine.BuffSkillType.BonusState)
            end
        else
            if not IsBuddy and MajorUtil.IsMajorByRoleID(RoleID) then
                MajorBuffVM:AddOrUpdateBuff(State.ID, BuffDefine.BuffSkillType.BonusState, State)
            elseif EntityID ~= nil and EntityID ~= 0 and EntityID == MainTargetBuffsVM.EntityID then
                MainTargetBuffsVM:AddOrUpdateBuff(State.ID, BuffDefine.BuffSkillType.BonusState, State)
            end
        end

        if nil ~= EntityID and 0 ~= EntityID then
            local Params = {EntityID = EntityID, State = State}
            if State.IsRemoved then
                EventMgr:SendEvent(EventID.RemoveBonusState, Params)
            else
                EventMgr:SendEvent(EventID.AddOrUpdateBonusState, Params)
            end
        end
	end
end

----------------------------------------------------------------
---Callback

function BonusStateMgr:OnNetMsgBonusStateUpdate(MsgBody)
    local Update = MsgBody.Update
    local States = (Update or {}).States
    self:UpdateBonusStates(MajorUtil.GetMajorRoleID(), States)
end

function BonusStateMgr:OnNetMsgBonusStateRemove(MsgBody)
    local Remove = MsgBody.Remove
    local RemovedIDs = (Remove or {}).StateIDs
    self:RemoveBonusStates(MajorUtil.GetMajorRoleID(), RemovedIDs)
end

function BonusStateMgr:OnNetMsgBonusStatePull(MsgBody)
    local Pull = MsgBody.Pull
    local States = (Pull or {}).States
    self:SetBonusStates(MajorUtil.GetMajorRoleID(), States)
end

function BonusStateMgr:OnNetMsgBonusStateCmdPullByRoleID(MsgBody)
    local PullRole = MsgBody.PullRole
    if nil == PullRole then
        return
    end

    local RoleID = PullRole.RoleID
    local States = PullRole.States
    self:SetBonusStates(RoleID, States)
end

local function ShouldRemoveBonusState(RoleID, StateID, EndTime)
    if EndTime == 0 or EndTime > TimeUtil.GetServerTime() then
        return false
    end

    if BonusStateBuffCfg:FindValue(StateID or 0, "DelayRemove") == 0 then
        -- 不需要延迟移除
        return true
    end

    local Actor = ActorUtil.GetActorByRoleID(RoleID)
    if nil == Actor then return true end
    local StateComp = Actor:GetStateComponent()
    if nil == StateComp then return true end

    return not StateComp:IsCrafting() and not StateComp:IsGathering()
end

function BonusStateMgr:OnTimerCheckBonusStateEndTime()
    local RemoveList = {}

    for RoleID, BonusStates in pairs(self.BonusStateMap) do
        local StateIDsToRemove = {}
        for StateID, State in pairs(BonusStates) do
            if ShouldRemoveBonusState(RoleID, StateID, State.EndTime) then
                table.insert(StateIDsToRemove, StateID)
            end
        end
        if #StateIDsToRemove > 0 then
            table.insert(RemoveList, table.pack(RoleID, StateIDsToRemove))
        end
    end

    for _, StateToMove in ipairs(RemoveList) do
        self:RemoveBonusStates(table.unpack(StateToMove))
    end
end

function BonusStateMgr:OnGameEventTargetChangeMajor(EntityID)
    if (EntityID or 0) == 0 then
        return
    end

    local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID) or 0
    if RoleID <= 0 and ActorUtil.IsBuddy(EntityID) then
        RoleID = ActorUtil.GetOwnerRoleID(EntityID) or 0
    end

    -- 不需要拉取自己
    if RoleID > 0 and not MajorUtil.IsMajorByRoleID(RoleID) then
        self:RequestBonusState(RoleID)
    end
end

function BonusStateMgr:OnGameEventRoleLoginRes(Params)
    -- 登录或断线重连后主动拉取一次
    self:RequestMajorBonusState()
end

----------------------------------------------------------------
---Interface

---GetMajorBonusStates 获取玩家或搭档的加成状态（引用，请勿修改）
---@param RoleID number
---@param IsBuddy? boolean 是否为搭档。搭档仅获取搭档加成，玩家仅获取玩家加成
---@return table
function BonusStateMgr:GetBonusStates(RoleID, IsBuddy)
    local Result = {}

    IsBuddy = IsBuddy and true or false
    local States = (self.BonusStateMap or {})[RoleID] or {}
    for ID, State in pairs(States) do
        local IsBuddyState = BonusStateUtil.IsBuddyBonusState(ID)
        if (IsBuddy and IsBuddyState) or (not IsBuddy and not IsBuddyState) then  -- 同或
            table.insert(Result, State)
        end
    end

    return Result
end

---GetBonusStatesByEntityID 获取玩家或搭档的加成状态（引用，请勿修改）
---@return table
function BonusStateMgr:GetBonusStatesByEntityID(EntityID)
    local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID) or 0
    if RoleID > 0 then
        return self:GetBonusStates(RoleID)
    elseif ActorUtil.IsBuddy(EntityID) then
        return self:GetBonusStates(ActorUtil.GetOwnerRoleID(EntityID), true)
    end
    return {}
end

---HasBonusStateMajor 查询玩家是否拥有某个加成状态（这里玩家搭档的加成也算在玩家身上）
---@return boolean
function BonusStateMgr:HasBonusState(RoleID, StateID)
    return ((self.BonusStateMap or {})[RoleID] or {})[StateID] ~= nil
end

---HasBonusStateMajor 查询主角是否拥有某个加成状态（这里搭档的加成也算在主角身上）
---@return boolean
function BonusStateMgr:HasBonusStateMajor(StateID)
    return self:HasBonusState(MajorUtil.GetMajorRoleID(), StateID)
end

---
----------------------------------------------------------------

return BonusStateMgr