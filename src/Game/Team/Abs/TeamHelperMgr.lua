local LuaClass = require("Core/LuaClass")
local LogableMgr = require("Common/LogableMgr")
local ProtoCS = require("Protocol/ProtoCS")

local CS_CMD <const> = ProtoCS.CS_CMD
local SUB_MSG_ID <const> = ProtoCS.Team.Team.CS_SUBMSGID_TEAM
local TeamMemberDataQueryType <const> = ProtoCS.Team.Team.TeamMemberDataQueryType


---@class TeamHelperMgr: LogableMgr
local TeamHelperMgr = LuaClass(LogableMgr)

function TeamHelperMgr:OnInit()
    self:SetLogName("TeamHelperMgr")
end

function TeamHelperMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CsQueryTeamMemberData, self.OnNetMsgTeamMemberData)
end

local function GetTeamMemberQueryKey(TeamID, Type)
    return string.sformat("%s-%s", TeamID, Type)
end

---@param TeamID number
---@param Type number
---@param Data any
---@param Callback function | nil
---@param Timeout number | nil if nil default 5 secs
---@param TimeoutCallback function | nil
function TeamHelperMgr:QueryTeamMemberData(TeamID, Type, Data, Callback, Timeout, TimeoutCallback)
    if TeamID == nil or TeamID == 0 then
        return
    end

    local MsgBody = {
        SubCmd = SUB_MSG_ID.CsQueryTeamMemberData,
        TeamID = TeamID,
        TeamMemData = {
            TeamID = TeamID,
            QueryType = Type,
        }
    }
    if Type == TeamMemberDataQueryType.TeamMemberDataQueryTypeCounter then
        MsgBody.TeamMemData.CounterIDs = Data
    end
        
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CsQueryTeamMemberData, MsgBody)

    if type(Callback) ~= 'function' then
       return 
    end

    if self.CallbackTimerIds == nil then
       self.CallbackTimerIds = {} 
    end

    self:RemoveTeamMemberQueryCallback(TeamID, Type)
    local TimeoutTimerID = self:RegisterTimer(function()
        self:LogErr("time out for QueryTeamMemberData, team id: %s, type %s", TeamID, Type)
        self:RemoveTeamMemberQueryCallback(TeamID, Type)
        if TimeoutCallback then
           TimeoutCallback(TeamID, Type) 
        end
    end, Timeout or 5)

    self.CallbackTimerIds[GetTeamMemberQueryKey(TeamID, Type)] = {
        TimerID = TimeoutTimerID,
        Callback = Callback
    }
end

---@private
function TeamHelperMgr:OnNetMsgTeamMemberData(MsgBody)
    local TeamMemData = MsgBody.TeamMemData

    if TeamMemData == nil then
        self:LogErr("TeamHelperMgr:OnNetMsgTeamMemberData get nil data")
       return 
    end

    local Data = self:RemoveTeamMemberQueryCallback(TeamMemData.TeamID, TeamMemData.QueryType)
    if Data then
       Data.Callback(TeamMemData) 
    end
end

---@private
function TeamHelperMgr:RemoveTeamMemberQueryCallback(TeamID, Type)
    if self.CallbackTimerIds == nil then
        return
    end

    local Key = GetTeamMemberQueryKey(TeamID, Type)
    local Data = self.CallbackTimerIds[Key]
    if Data ~= nil then
       self:UnRegisterTimer(Data.TimerID)
    end
    self.CallbackTimerIds[Key] = nil

    return Data
end


return TeamHelperMgr

