--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2025-03-25 19:28:52
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-03-25 19:50:36
FilePath: \Script\Game\PWorld\Vote\PWorldVoteMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local MsgTipsID = require("Define/MsgTipsID")
local AudioUtil = require("Utils/AudioUtil")
local LogableMgr = require("Common/LogableMgr")
local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")

local EventID
---@deprecated
local PWorldVoteVM
local GameNetworkMgr

local CS_CMD_CONFIRM = ProtoCS.CS_CMD.CS_CMD_MATCH_CONFIRM
local SUB_CONFIRM_CMD = ProtoCS.CS_MATCH_CONFIRM_CMD
local CS_CMD_VOTE = ProtoCS.CS_CMD.CS_CMD_VOTE
local SUB_MSG_ID = ProtoCS.VoteSubCmd
local PollTypeDef = ProtoCS.PollType
local VoteObjTypeDef = ProtoCS.VoteObjType
local EnterSceneOptionDef = ProtoCS.EnterSceneOption

local ERR = _G.FLOG_ERROR

---@class PWorldVoteMgr: LogableMgr
local PWorldVoteMgr = LuaClass(LogableMgr)

function PWorldVoteMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
    PWorldVoteVM = _G.PWorldVoteVM
    EventID = _G.EventID

    self.VoteEnterSceneInfo = {}
end

function PWorldVoteMgr:OnEnd()
	self:EndCDAudio()
end

function PWorldVoteMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD_VOTE, SUB_MSG_ID.VoteSubCmd_Poll,            self.OnMsgStartVote)
	self:RegisterGameNetMsg(CS_CMD_VOTE, SUB_MSG_ID.VoteSubCmd_Vote,            self.OnMsgVote)
	self:RegisterGameNetMsg(CS_CMD_VOTE, SUB_MSG_ID.VoteSubCmd_PollNtf,         self.OnMsgNtfStartVote)
	self:RegisterGameNetMsg(CS_CMD_VOTE, SUB_MSG_ID.VoteSubCmd_VoteNtf,         self.OnMsgNtfVote)
	self:RegisterGameNetMsg(CS_CMD_VOTE, SUB_MSG_ID.VoteSubCmd_VoteResultNtf,   self.OnMsgNtfFinishVote)
	self:RegisterGameNetMsg(CS_CMD_VOTE, SUB_MSG_ID.VoteSubCmd_PollTimeOutNtf,  self.OnMsgNtfVoteTimeOut)
	self:RegisterGameNetMsg(CS_CMD_VOTE, SUB_MSG_ID.VoteSubCmd_CancelVoteNtf,   self.OnMsgNtfVoteCancel)
	self:RegisterGameNetMsg(CS_CMD_CONFIRM, SUB_CONFIRM_CMD.CS_MATCH_CONFIRM_CMD_QUERY,           self.OnMsgNtfVoteQuery)
    self:RegisterGameNetMsg(CS_CMD_VOTE, SUB_MSG_ID.VoteSubCmd_Query,           self.OnMsgNtfVoteQuery)
end

function PWorldVoteMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnRoleLoginRes)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.TeamQueryFinish, self.OnTeamQueryFinish)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfChanged)
end

function PWorldVoteMgr:OnRoleLoginRes()
    -- self:ReqQueryTeam()
    self:ReqQuerySelf()
end

function PWorldVoteMgr:OnPWorldExit()
    -- left emtpy
end

function PWorldVoteMgr:OnTeamQueryFinish()
    for _, RoleID in _G.TeamMgr:IterTeamMembers() do
        if RoleID and RoleID ~= 0 then
            local Prof = _G.TeamMgr:GetTeamMemberProf(RoleID)
            local Level = _G.TeamMgr:GetTeamMemberLevel(RoleID)
            local RVM = _G.TeamMgr.FindRoleVM(RoleID, true)
            if Prof and Prof ~= 0 and RVM then
                RVM:SetProf(Prof)
            end
            if Level and Level ~= 0 and RVM then
                RVM:SetLevel(Level)
            end
        end
    end

    PWorldVoteVM:UpdateTeamProfInfo()
end

function PWorldVoteMgr:OnMajorProfChanged()
    if PWorldVoteVM then
        PWorldVoteVM:UpdateTeamProfInfo()
    end
end

function PWorldVoteMgr:OnMsgStartVote(MsgBody)
    -- nothing
end

function PWorldVoteMgr:OnMsgVote(MsgBody)
    -- nothing
end

function PWorldVoteMgr:OnMsgNtfStartVote(MsgBody)
    local Msg = MsgBody.PollNtf
    if not Msg then
        return
    end

    self:OnMsgVoteStartOrQureyInner(Msg)
end

function PWorldVoteMgr:OnMsgNtfVoteQuery(MsgBody)
    local Msg = MsgBody.Query
    if not Msg then
        self:SetEnterSceneVoteInfo()
        self:ClearLocalEnterSceneTimeoutTimer()
        return
    end

    self:OnMsgVoteStartOrQureyInner(Msg)
    local VoteRecords = Msg.VoteRecords
    for _, Item in pairs(VoteRecords or {}) do
        self:SetEnterSceneVoteOption(Item.ActorID, Item.Option)
    end
end

function PWorldVoteMgr:OnMsgVoteStartOrQureyInner(Msg)
    local ID = Msg.ID
    local PollType = Msg.PollType
    local VoteObjType = Msg.VoteObjType

    if PollTypeDef.PollType_EnterScene == PollType then
        local EnterSceneNtf = Msg.EnterSceneNtf
        local EnterScene = EnterSceneNtf.EnterScene
        local SceneID = EnterScene.ID
        local Model = EnterScene.Model
        local RoleInfos = EnterSceneNtf.Actors
        self:SetEnterSceneVoteInfo(SceneID, RoleInfos, ID, VoteObjType, Model, PollType, Msg)
    elseif PollTypeDef.PollType_Chocobo == PollType then
        if Msg.EnterChocoboNtf == nil then return end

        local EnterChocoboNtf = Msg.EnterChocoboNtf
        local EnterChocobo = EnterChocoboNtf.EnterChocobo
        local RoleInfos = EnterChocoboNtf.Actors
        local SceneID = EnterChocobo.SceneID

        local Model = PWorldQuestDefine.ClientSceneMode.SceneModeChocboRank
        if VoteObjType and VoteObjType == ProtoCS.VoteObjType.VoteObjType_Team then
            Model = PWorldQuestDefine.ClientSceneMode.SceneModeChocoboRoom
        end
        
        self:SetEnterSceneVoteInfo(SceneID, RoleInfos, ID, VoteObjType, Model, PollType, Msg)
    elseif PollTypeDef.PoolType_Tournament == PollType then
        if Msg.TournamentNtf == nil then return end

        local TournamentNtf = Msg.TournamentNtf
        --local EnterChocobo = EnterChocoboNtf.EnterChocobo
        local RoleInfos = {}-- TournamentNtf.RoleIDs
        for _, RoleID in ipairs(TournamentNtf.RoleIDs) do
            table.insert(RoleInfos, {ActorID = RoleID})
        end
        local SceneID = PWorldEntUtil.GetMagicCardTourneyPWorldID()
        self:SetEnterSceneVoteInfo(SceneID, RoleInfos, ID, VoteObjType, nil, PollType, Msg)
    elseif PollTypeDef.PoolType_CrystalConflict == PollType then
        local CrystalConflictNtf = Msg.CrystalConflictNtf
        local Model = CrystalConflictNtf.Model
        local RoleInfos = CrystalConflictNtf.Actors
        local SceneID = nil
        if Model == ProtoCS.PvPColosseumMode.Exercise then
            SceneID = 1218010
        elseif Model == ProtoCS.PvPColosseumMode.Rank then
            SceneID = 1218020
        end
        self:SetEnterSceneVoteInfo(SceneID, RoleInfos, ID, VoteObjType, Model, PollType, Msg)
    end
end

function PWorldVoteMgr:OnMsgNtfVote(MsgBody)
    local Msg = MsgBody.VoteNtf
    if not Msg then
        return
    end

    local VoterID = Msg.VoterID -- RoleID
    local Option = Msg.Option
    self:SetEnterSceneVoteOption(VoterID, Option)

    if Option ~= 1 and VoterID ~=  MajorUtil.GetMajorRoleID() then
        if _G.TeamMgr:IsTeamMemberByRoleID(VoterID) then
            local RVM = _G.RoleInfoMgr:FindRoleVM(Msg.VoterID)
            if RVM then
                _G.MsgTipsUtil.ShowTipsByID(146042, nil, RVM.Name)
            else
                _G.FLOG_ERROR("zhg PWorldVoteMgr:OnMsgNtfVote RoleVM = nil RoleID = " .. tostring(VoterID))
            end
        else
            _G.MsgTipsUtil.ShowTipsByID(103073)
        end
    end
end

function PWorldVoteMgr:OnMsgNtfFinishVote(MsgBody)
    local Msg = MsgBody.VoteResult
    if not Msg then
        return
    end

    self:MarkVoteTimeOut(Msg.ID)
end

function PWorldVoteMgr:OnMsgNtfVoteTimeOut(MsgBody)
    local Msg = MsgBody.TimeOut
    if not Msg then
        return
    end

    self:MarkTimeoutAndTip(Msg.ID)
end

---@private
function PWorldVoteMgr:MarkVoteTimeOut(VoteID)
    if self:GetEnterSceneVoteID() == VoteID and VoteID ~= nil then
        self:SetEnterSceneVoteInfo()
        return true
    elseif self:GetEnterSceneVoteID() ~= nil then
       self:LogErr("invalid timeout for vote, cur: %s, msg id: %s, trace: %s", self:GetEnterSceneVoteID(), VoteID, debug.traceback()) 
    end
end

---@private
function PWorldVoteMgr:MarkTimeoutAndTip(VoteID)
    if self:MarkVoteTimeOut(VoteID) then
        _G.MsgTipsUtil.ShowTipsByID(146071)
    end
end

function PWorldVoteMgr:OnMsgNtfVoteCancel(MsgBody)
    local Msg = MsgBody.CancelVote
    if not Msg then
        return
    end

    local PollType = Msg.PollType

    self:MarkVoteTimeOut(Msg.ID)

    if Msg.Reason == ProtoCS.CancelVoteReason.CancelVoteReasonTeamMemChg then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldVoteCancelMemChg)
    end
end

--[[
    Request
]]
function PWorldVoteMgr:ReqVote(SubCmd, Params)
    local MsgBody = Params
    MsgBody.Cmd = SubCmd
    GameNetworkMgr:SendMsg(CS_CMD_VOTE, SubCmd, MsgBody)
end

function PWorldVoteMgr:ReqConfirm(SubCmd, Params)
    local MsgBody = Params
    MsgBody.Cmd = SubCmd
    GameNetworkMgr:SendMsg(CS_CMD_CONFIRM, SubCmd, MsgBody)
end

--[[
    Private
]]

function PWorldVoteMgr:StartVoteNtf()
    _G.PWorldMatchMgr:PauseSideBar()
end

function PWorldVoteMgr:EndVoteNtf()
    _G.PWorldMatchMgr:TryResumeSideBar()
end

function PWorldVoteMgr:SetEnterSceneVoteInfo(SceneID, RoleInfos, ID, VoteObjType, Model, PollType, Msg)
    local LastVoteSceneID <const> = self:GetEnterSceneID()

    self.VoteEnterSceneInfo.SceneID = SceneID
    self.VoteEnterSceneInfo.RoleInfos = RoleInfos
    self.VoteEnterSceneInfo.ID = ID
    self.VoteEnterSceneInfo.VoteObjType = VoteObjType
    self.VoteEnterSceneInfo.Msg = table.deepcopy(Msg or {})
    self.Model = Model
    self.CurPollType = PollType

    self.RandomEntID = 0
    -- 投票的成员可能是通过日随，也可能不是，找到自己是不是日随，是日随显示日随ID
    local MajorID = MajorUtil.GetMajorRoleID()
    for _, Info in pairs(RoleInfos or {}) do
        if MajorID == Info.ActorID and Info.DailyRandomPoolID ~= nil then
            self.RandomEntID = Info.DailyRandomPoolID
            break
        end
    end
    
    -- 如果是陆行鸟竞赛，补齐假的AI
    if self.CurPollType == ProtoCS.PollType.PollType_Chocobo then
        local TargetLength = 8
        local CurrentLength = #self.VoteEnterSceneInfo.RoleInfos

        if CurrentLength < TargetLength then
            for i = CurrentLength + 1, TargetLength do
                table.insert(self.VoteEnterSceneInfo.RoleInfos, { ActorID = 0, HasReady = true})
            end
        end
    end

    PWorldVoteVM:UpdateVM()
    self:SetVoteConfirmSidebarVisible(false)
    local bShowVoteView = self:IsVoteEnterScenePending()

    if PollType == PollTypeDef.PollType_EnterScene or PollType == PollTypeDef.PoolType_CrystalConflict then
        local RemainTime = math.max( 0,  self:GetEnterSceneStartTime() + self:GetEnterSceneDuration() - _G.TimeUtil.GetServerTime())
        self:ClearLocalEnterSceneTimeoutTimer()
        if RemainTime > 0 then
            self.TimerIDEnterSceneTimeout = self:RegisterTimer(self.OnLocalEnterSceneTimeOut, RemainTime + 2, nil, nil, {VoteID=ID})
        else
            bShowVoteView = false
        end
    end

    self:ShowPWorldVoteView(bShowVoteView)

    if SceneID then
        self:StartVoteNtf()
    else
        if LastVoteSceneID then
            _G.EventMgr:SendEvent(_G.EventID.TeamVoteEnterSceneEnd, LastVoteSceneID)
        end
        self:EndVoteNtf()
    end
end

function PWorldVoteMgr:OnLocalEnterSceneTimeOut(Param)
    self:MarkTimeoutAndTip(Param.VoteID)
end

---@private
function PWorldVoteMgr:ClearLocalEnterSceneTimeoutTimer()
    if self.TimerIDEnterSceneTimeout then
        self:UnRegisterTimer(self.TimerIDEnterSceneTimeout)
        self.TimerIDEnterSceneTimeout = nil
    end
end

function PWorldVoteMgr:SetEnterSceneVoteOption(RoleID, Option)
    local RoleInfo = table.find_item(self.VoteEnterSceneInfo.RoleInfos, RoleID, "ActorID")
    if not RoleInfo then
        self:LogErr("PWorldVoteMgr:SetEnterSceneVoteOption not find info RoleID %s, trace:\n%s", RoleID, debug.traceback())
        return
    end

    RoleInfo.Option = Option
    PWorldVoteVM:SetReady(RoleID, Option == 1)
    if PWorldVoteVM.IsMajorReady then
       self:EndCDAudio() 
    end
end

--[[
    Public Req
]]

function PWorldVoteMgr:ReqQueryTeam()
    local Params = {
        Query = {

        }
    }
    self:ReqConfirm(SUB_CONFIRM_CMD.CS_MATCH_CONFIRM_CMD_QUERY, Params)
end

function PWorldVoteMgr:ReqQuerySelf()
    local Params = {
        Query = {

        }
    }
    self:ReqVote(SUB_MSG_ID.VoteSubCmd_Query, Params)
end

function PWorldVoteMgr:ReqStartVoteEnterPWorld(EntID, EntTy, Model)
    local HasTeam = _G.TeamMgr:IsInTeam()
    local Op = HasTeam and EnterSceneOptionDef.EnterSceneTeam or EnterSceneOptionDef.EnterSceneSingle
    local VoteObjType = HasTeam and VoteObjTypeDef.VoteObjType_Team or VoteObjTypeDef.VoteObjType_Self
    local IsRandom = PWorldEntUtil.IsDailyRandom(EntTy)
    local Params = {
        Poll = {
            PollType = PollTypeDef.PollType_EnterScene,
            VoteObjType = VoteObjType,
            EnterScene = {
                EnterScene = {
                    ID = EntID,
                    IsRandom = IsRandom,
                    Model = Model,
                },
                Option = Op,
            }
        }
    }

    self:ReqVote(SUB_MSG_ID.VoteSubCmd_Poll, Params)
end

function PWorldVoteMgr:ReqStartVoteEnterChocoboRoom(EntID)
    local HasTeam = _G.TeamMgr:IsInTeam()
    local VoteObjType = HasTeam and VoteObjTypeDef.VoteObjType_Team or VoteObjTypeDef.VoteObjType_Self
    local Params = {
        Poll = {
            PollType = PollTypeDef.PollType_Chocobo,
            VoteObjType = VoteObjType,
            EnterChocobo = {
                SceneID = EntID
            }
        }
    }

    self:ReqVote(SUB_MSG_ID.VoteSubCmd_Poll, Params)
end

function PWorldVoteMgr:ReqStartVoteEnterMagicCardTourneyRoom(EntID, EntTy, Model)
    local HasTeam = _G.TeamMgr:IsInTeam()
    -- local VoteObjType = HasTeam and VoteObjTypeDef.VoteObjType_Team or VoteObjTypeDef.VoteObjType_Self
    -- local Params = {
    --     Poll = {
    --         PollType = PollTypeDef.PoolType_Tournament,
    --         VoteObjType = VoteObjType,
    --         EnterChocobo = {
    --             SceneID = EntID
    --         }
    --     }
    -- }
    local Op = HasTeam and EnterSceneOptionDef.EnterSceneTeam or EnterSceneOptionDef.EnterSceneSingle
    local VoteObjType = HasTeam and VoteObjTypeDef.VoteObjType_Team or VoteObjTypeDef.VoteObjType_Self
    local IsRandom = PWorldEntUtil.IsDailyRandom(EntTy)
    local Params = {
        Poll = {
            PollType = PollTypeDef.PoolType_Tournament,
            VoteObjType = VoteObjType,
            EnterScene = {
                EnterScene = {
                    ID = EntID,
                    IsRandom = IsRandom,
                    Model = Model,
                },
                Option = Op,
            }
        }
    }

    self:ReqVote(SUB_MSG_ID.VoteSubCmd_Poll, Params)
end

function PWorldVoteMgr:ReqVoteEnterPWorld(IsReady)
    if self:GetCurPollType() == PollTypeDef.PollType_Chocobo then
        self:ReqVoteEnterChocobo(IsReady)
    elseif self:GetCurPollType() == PollTypeDef.PoolType_Tournament then
        self:ReqVoteEnterCardTourney(IsReady)
    elseif self:GetCurPollType() == PollTypeDef.PoolType_CrystalConflict then
        self:ReqVoteEnterCrystalline(IsReady)
    else
        self:ReqVoteEnterPWorldNormal(IsReady)
    end

    if _G.SingBarMgr:GetMajorIsSinging() then --[sammrli]打断吟唱
        _G.SingBarMgr:OnBreakSingOver()
    end
end

function PWorldVoteMgr:ReqVoteEnterPWorldNormal(IsReady)
    if not IsReady then
        self.LastRefuseVotePWorldNormal = os.time()
    end

    local ID = self.VoteEnterSceneInfo.ID
    local VoteObjType = self.VoteEnterSceneInfo.VoteObjType

    if not ID then
        ERR("invalid vote id: %s", debug.traceback())
        return
    end

    local Option = IsReady and 1 or 0
    local Params = {
        Vote = {
            VoteObjType = VoteObjType,
            PollType = PollTypeDef.PollType_EnterScene,
            Option = Option,
            ID = ID,
        }
    }

    self:ReqVote(SUB_MSG_ID.VoteSubCmd_Vote, Params)
end

function PWorldVoteMgr:ReqVoteEnterChocobo(IsReady)
    local ID = self.VoteEnterSceneInfo.ID
    local VoteObjType = self.VoteEnterSceneInfo.VoteObjType

    if not ID then
        ERR(string.format("PWorldVoteMgr:ReqVoteEnterChocobo ID not exist"))
        return
    end
    
    local Option = IsReady and 1 or 0
    local Params = {
        Vote = {
            VoteObjType = VoteObjType,
            PollType = PollTypeDef.PollType_Chocobo,
            Option = Option,
            ID = ID,
        }
    }

    self:ReqVote(SUB_MSG_ID.VoteSubCmd_Vote, Params)
end

function PWorldVoteMgr:ReqVoteEnterCardTourney(IsReady)
    local ID = self.VoteEnterSceneInfo.ID
    local VoteObjType = self.VoteEnterSceneInfo.VoteObjType

    if not ID then
        ERR(string.format("PWorldVoteMgr:ReqVoteEnterChocobo ID not exist"))
        return
    end
    
    local Option = IsReady and 1 or 0
    local Params = {
        Vote = {
            VoteObjType = VoteObjType,
            PollType = PollTypeDef.PoolType_Tournament,
            Option = Option,
            ID = ID,
        }
    }

    self:ReqVote(SUB_MSG_ID.VoteSubCmd_Vote, Params)
end

function PWorldVoteMgr:ReqVoteEnterCrystalline(IsReady)
    local ID = self.VoteEnterSceneInfo.ID
    local VoteObjType = self.VoteEnterSceneInfo.VoteObjType

    if not ID then
        ERR(string.format("PWorldVoteMgr:ReqVoteEnterCrystalline ID not exist"))
        return
    end
    
    local Option = IsReady and 1 or 0
    local Params = {
        Vote = {
            VoteObjType = VoteObjType,
            PollType = PollTypeDef.PoolType_CrystalConflict,
            Option = Option,
            ID = ID,
        }
    }

    self:ReqVote(SUB_MSG_ID.VoteSubCmd_Vote, Params)
end
-------------------------------------------------------------------------------------------------------
---@see query
--[[
    Info
    message VoteEnterSceneActor{
        uint64 ActorID = 1;
        int32 Prof = 2;
        int32 Level = 3;
        int32 DailyRandomPoolID = 4;
    }
]]

-- Enter scene query
function PWorldVoteMgr:GetEnterSceneRoleInfo(RoleID)
    local Info = table.find_item(self.VoteEnterSceneInfo.RoleInfos or {}, RoleID, "ActorID")
    if Info then
       return table.makeconst(table.shallowcopy(Info, true))
    end
end

function PWorldVoteMgr:GetEnterSceneMajorInfo()
    return self:GetEnterSceneRoleInfo(MajorUtil.GetMajorRoleID())
end

function PWorldVoteMgr:GetEnterSceneRoleInfos()
    local Infos = {}
    for i, v in ipairs(self.VoteEnterSceneInfo.RoleInfos or {}) do
        table.insert(Infos, table.makeconst(table.shallowcopy(v, true)))
    end
    return Infos
end

function PWorldVoteMgr:GetEnterSceneRoleCnt()
    return #(self.VoteEnterSceneInfo.RoleInfos or {})
end

function PWorldVoteMgr:GetEnterSceneID()
    return self.VoteEnterSceneInfo.SceneID
end

function PWorldVoteMgr:GetCurPollType()
    if self.CurPollType == nil then
        return PollTypeDef.PollType_EnterScene
    end
    return self.CurPollType
end

function PWorldVoteMgr:GetEnterSceneStartTime()
    return (self.VoteEnterSceneInfo.Msg and self.VoteEnterSceneInfo.Msg.Validity) and self.VoteEnterSceneInfo.Msg.Validity.StartTime or 0
end

function PWorldVoteMgr:GetEnterSceneDuration()
    return (self.VoteEnterSceneInfo.Msg and self.VoteEnterSceneInfo.Msg.Validity) and self.VoteEnterSceneInfo.Msg.Validity.Duration or 60
end

function PWorldVoteMgr:GetEnterSceneVoteID()
    return self.VoteEnterSceneInfo.Msg and self.VoteEnterSceneInfo.Msg.ID or nil
end

function PWorldVoteMgr:IsVoteEnterScenePending()
    return self:GetEnterSceneRoleCnt() > 0
end

function PWorldVoteMgr:IsGetWeeklyReward(RoleID)
    if RoleID == nil then
       return 
    end

    local Info = table.find_item(self.VoteEnterSceneInfo.RoleInfos or {}, RoleID, "ActorID")
    if Info then
       return Info.ZeroFormGot == true
    end
end

function PWorldVoteMgr:GetWeeklyRewardPickedCount()
    local Count = 0
    for _, Info in ipairs(self.VoteEnterSceneInfo.RoleInfos or {}) do
        if Info.ZeroFormGot then
            Count = Count + 1
        end
    end

    return Count
end

function PWorldVoteMgr:GetWeeklyRewardUnpickedCount()
    local Count = 0
    for _, Info in ipairs(self.VoteEnterSceneInfo.RoleInfos or {}) do
        if Info.ZeroFormGot then
            Count = Count + 1
        end
    end

    return #(self.VoteEnterSceneInfo.RoleInfos or {}) - Count
end

-- Show view

function PWorldVoteMgr:StartCDAudio()
	self:EndCDAudio()

    if not PWorldVoteVM.IsMajorReady then
        self.CDTimer = self:RegisterTimer(self.OnCDAudio, 0, 1, self:GetEnterSceneDuration())
    end
end

function PWorldVoteMgr:EndCDAudio()
    if self.CDTimer then
	    self:UnRegisterTimer(self.CDTimer)
    end
    self.CDTimer = nil
end

function PWorldVoteMgr:OnCDAudio()
	local Path = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_CFTimeCount.Play_SE_UI_SE_UI_CFTimeCount'"
	AudioUtil.LoadAndPlayUISound(Path)
end

function PWorldVoteMgr:ShowPWorldVoteView(bShow)
    if bShow then
        local List = {}
        if self:GetCurPollType() == PollTypeDef.PollType_Chocobo then
            for _, Info in pairs(self.VoteEnterSceneInfo.RoleInfos or {}) do
                if Info.ActorID > 0 then
                    table.insert(List, Info.ActorID)
                end
            end
            _G.RoleInfoMgr:QueryRoleSimples(List)
            _G.ChocoboMgr:QueryChocoboSimples(List)
        else
            for _, Info in pairs(self.VoteEnterSceneInfo.RoleInfos or {}) do
                table.insert(List, Info.RoleID)
            end
            _G.RoleInfoMgr:QueryRoleSimples(List, function() 
            end, nil, false)
        end 
    end

    if (bShow or false) ~= _G.UIViewMgr:IsViewVisible(_G.UIViewID.PWorldConfirm) then
        if bShow then
            _G.UIViewMgr:ShowView(_G.UIViewID.PWorldConfirm)
            self:StartCDAudio()
        else
            _G.UIViewMgr:HideView(_G.UIViewID.PWorldConfirm)
        end
    end

    if not bShow then
        self:EndCDAudio() 
    end
end

local ConfirmSideBarType = SidebarDefine.SidebarType.PWorldEnterConfirm
function PWorldVoteMgr:SetVoteConfirmSidebarVisible(IsVisible)
    local SidebarMgr = _G.SidebarMgr
    local IsExist = SidebarMgr:GetSidebarItemVM(ConfirmSideBarType) ~= nil
    if IsVisible then
        if IsExist then
            return
        end

        local Now = _G.TimeUtil.GetServerTime()
        local CD = self:GetEnterSceneDuration()
        local StartTime = self:GetEnterSceneStartTime()
        CD = CD - math.max(0, Now - StartTime)
        
        if StartTime == 0 or CD <= 0 then
           self:LogErr("PWorldVoteMgr:SetVoteConfirmSidebarVisible invalid start time or cd")
           return
        end
        SidebarMgr:AddSidebarItem(ConfirmSideBarType, StartTime, CD, nil, false, PWorldVoteVM.IsMajorReady and LSTR(1320094) or LSTR(1320085))
    else
        if not IsExist then
            return
        end

        SidebarMgr:RemoveSidebarItem(ConfirmSideBarType)
    end
end

return PWorldVoteMgr