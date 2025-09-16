--
-- Author: kofhuang
-- Date: 2023-12-25
-- Description:后台下发的AI行为
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local LineVoiceCfg = require("TableCfg/LineVoiceCfg")
local AudioUtil = require("Utils/AudioUtil")
local ActorUtil = require("Utils/ActorUtil")
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local CS_CMD = ProtoCS.CS_CMD
local CS_Perform_Action_CMD = ProtoCS.PerformActionCmd

local ActionType = {
    Invalid = 0,
    Yell = 1,
    ActionTimeline = 2,
    Voice = 3
}

---@class PerformanceActionMgr : MgrBase
local PerformanceActionMgr = LuaClass(MgrBase)

function PerformanceActionMgr:OnInit()
    self:ResetData()
end

function PerformanceActionMgr:OnEnd()
    self:ResetData()
end

function PerformanceActionMgr:ResetData()
    self.TimerIndex = 1
    self.TimerIndexMap = {}
end

function PerformanceActionMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_PERFORM_ACTION,
        CS_Perform_Action_CMD.CS_PERFORM_ACTION_CMD_YELL,
        self.OnPerformanceActionCmdYell
    )
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_PERFORM_ACTION,
        CS_Perform_Action_CMD.CS_PERFORM_ACTION_CMD_ACTION_TIME_LINE,
        self.OnPerformanceActionCmdTimeline
    )
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_PERFORM_ACTION,
        CS_Perform_Action_CMD.CS_PERFORM_ACTION_CMD_LINE_VOICE,
        self.OnPerformanceActionCmdLineVoice
    )
end

function PerformanceActionMgr:OnPerformanceActionCmdYell(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("OnPerformanceActionCmdYell: MsgBody is nil")
        return
    end
    local YellData = MsgBody.Yell
    if nil == YellData then
        FLOG_ERROR("接受信息 , 需要播放 Yell , 但是没有消息内容，请检查")
        return
    end

    local EntityID = YellData.EntityID
    local YellID = YellData.YellID
    local YellGroupID = YellData.YellGroupID
    local TargetActor = ActorUtil.GetActorByEntityID(EntityID)
    if (TargetActor == nil or not _G.SpeechBubbleMgr:BubbleCanPlay(EntityID)) then
        -- 这里有可能下发的时候角色还没有创建，放入tick检测
        local Params = {}
        Params.EntityID = YellData.EntityID
        Params.YellID = YellData.YellID
        Params.YellGroupID = YellData.YellGroupID
        Params.ActionType = ActionType.Yell
        self:PrepareTickCheckForEntity(Params)
    else
        self:InternalPerformSpeechBubble(YellData)
    end
end

function PerformanceActionMgr:InternalPerformSpeechBubble(Params)
    local EntityID = Params.EntityID
    local YellID = Params.YellID
    local YellGroupID = Params.YellGroupID
    if YellID > 0 then
        _G.SpeechBubbleMgr:ShowBubbleByID(EntityID, YellID)
    else
        _G.SpeechBubbleMgr:ShowBubbleGroup(EntityID, YellGroupID)
    end

    FLOG_INFO(
        "OnPerformanceActionCmdYell: EntityID=" .. EntityID .. ",YellID=" .. YellID .. ", YellGroupID=" .. YellGroupID
    )
end

--- func desc
---@param Params table，包含EntityID,ActionType,和后续的ID，每个对应的不同
function PerformanceActionMgr:PrepareTickCheckForEntity(Params)
    if (Params == nil) then
        FLOG_ERROR("PerformanceActionMgr:TickCheckForEntity 传入的 Params 为空")
        return
    end

    local CurIndex = self.TimerIndex
    local TimerID = self:RegisterTimer(
        --这里的tick做成这样是因为找不到角色的情况小，不需要成为一个常驻的tick
        function()
            local EntityID = Params.EntityID
            local YellID = Params.YellID
            local YellGroupID = Params.YellGroupID
            local TargetActor = ActorUtil.GetActorByEntityID(EntityID)
            if (TargetActor == nil or not _G.SpeechBubbleMgr:BubbleCanPlay(EntityID)) then
                return
            end
        
            if (Params.ActionType == ActionType.Yell) then
                self:InternalPerformSpeechBubble(Params)
            elseif (Params.ActionType == ActionType.ActionTimeline) then
                self:InternalPerformActiontimeline(Params)
            elseif (Params.ActionType == ActionType.Voice) then
                self:InternalPerformVoice(Params)
            else
                FLOG_ERROR("错误的 ActionType : %s", tostring(Params.ActionType))
            end
            if (self.TimerIndexMap[CurIndex] ~= nil) then
                self:UnRegisterTimer(self.TimerIndexMap[CurIndex])
                table.remove_item(self.TimerIndexMap[CurIndex])
            end
        end,
        0.3, -- 延迟, 避免数据未设置
        0.5,
        3
    )

    self.TimerIndexMap[CurIndex] = TimerID
    self.TimerIndex = self.TimerIndex + 1
end

function PerformanceActionMgr:OnPerformanceActionCmdTimeline(MsgBody)
    if (MsgBody == nil) then
        FLOG_ERROR("OnPerformanceActionCmdTimeline 协议为空，请检查")
        return
    end
    if (MsgBody.Cmd ~= ProtoCS.PerformActionCmd.CS_PERFORM_ACTION_CMD_ACTION_TIME_LINE) then
        FLOG_ERROR("协议出错，不是 CS_PERFORM_ACTION_CMD_ACTION_TIME_LINE")
        return
    end
    local _data = MsgBody.ActionTimeLine
    if (_data == nil) then
        FLOG_ERROR("协议出错，消息内没有 ActionTimeLine 数据")
        return
    end
    local AnimComp = ActorUtil.GetActorAnimationComponent(_data.EntityID)
    if (AnimComp == nil) then        
        -- 这里有可能下发的时候角色还没有创建，放入缓存中，检测4此，每次tick是0.5
        local Params = {}
        Params.EntityID = _data.EntityID
        Params.ID = _data.ID
        Params.ActionType = ActionType.ActionTimeline
        self:PrepareTickCheckForEntity(Params)
        return
    end

    self:InternalPerformActiontimeline(_data)
end

function PerformanceActionMgr:InternalPerformActiontimeline(Params)
    local AnimComp = ActorUtil.GetActorAnimationComponent(Params.EntityID)
    if (AnimComp == nil) then
        return
    end
    FLOG_INFO(string.format("OnPerformActionTimeline , EntityID : [%s],  ID : [%s]", Params.EntityID, Params.ID))
    AnimComp:PlayActionTimeline(Params.ID)
end

function PerformanceActionMgr:OnPerformanceActionCmdLineVoice(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("OnPerformanceActionCmdLineVoice: MsgBody is nil")
        return
    end
    local LineVoiceData = MsgBody.LineVoice
    if nil == LineVoiceData then
        FLOG_ERROR("错误，接受播放 Void 但是没有数据")
        return
    end

    local EntityID = LineVoiceData.EntityID
    local TargetActor = ActorUtil.GetActorByEntityID(EntityID)
    if (TargetActor == nil) then
        local Params = {}
        Params.EntityID = LineVoiceData.EntityID
        Params.ID = LineVoiceData.ID
        Params.ActionType = ActionType.Voice
        self:InternalPerformVoice(Params)
        return
    end

    self:InternalPerformVoice(LineVoiceData)
end

function PerformanceActionMgr:InternalPerformVoice(Params)
    local ID = Params.ID

    local Cfg = LineVoiceCfg:FindCfgByKey(ID)
    local SoundPath = Cfg and Cfg.EventPath

    AudioUtil.LoadAndPlaySoundEvent(Params.EntityID, SoundPath)
    FLOG_INFO("OnPerformanceActionCmdLineVoice: EntityID=" .. Params.EntityID .. ",ID=" .. ID .. ",SoundPath=" .. SoundPath)
end

return PerformanceActionMgr
