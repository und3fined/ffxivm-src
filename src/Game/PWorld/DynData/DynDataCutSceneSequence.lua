
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local DynDataBase = require("Game/PWorld/DynData/DynDataBase")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local CutsceneConditionCfg = require("TableCfg/CutsceneConditionCfg")
local StorySetting = require("Game/Story/StorySetting")
local MajorUtil = require("Utils/MajorUtil")

---@class DynDataCutSceneSequence
local DynDataCutSceneSequence = LuaClass(DynDataBase, true)


--- 数据    含义            播放前      播放中      播放后
--- Status  结束时间        0           非0         0
--- Extra   未完成玩家列表  ""          "1,2,3"     ""
---
--- 后台不管理IsAutoPlay动画的数据
--- 单人本开始播放后，Status会一直保持非0，直到收到VideoEnd；多人本超时后Status会恢复成0
---
--- 播片前断线重连: StoppedDynDataSeqID ~= self.ID, 单人本播片，多人本上报VideoEnd
--- 播片中断线, 播片中重连: SequenceIsPlaying == true, 不管
--- 播片中断线, 播片/跳过后重连: StoppedDynDataSeqID == self.ID, 不管，网络模块自动重新上报VideoEnd

--CutSceneSequence
function DynDataCutSceneSequence:Ctor()
    self.SequencePath = nil
    self.IsAutoPlay = false
    self.IsResetFadeWhenStop = false
    self.SceneCharacterShowType = 0
    self.FadeOutTime = 0
    self.FadeOutWhiteColor = false
    self.AnimationCondition = 0
    self.IsBlackScreenAfterPlay = false
    self.bIsCanSkip = false
    self.LcutType = 0
    self.LcutDynParams = nil
    self.CheckNewbieForSkip = false

    -- 非协议属性
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MAP_MOVIE_SEQUENCE
    self.bSvrMajorPlaying = false
    self.bCurrIsInit = false
end

function DynDataCutSceneSequence:Destroy()
    self.bCurrIsInit = false
    self.Super:Destroy()
end

function DynDataCutSceneSequence:OnLoadData(MovieSequence)
    self.ID = MovieSequence.ID
    self.SequencePath = MovieSequence.SequencePath
    self.IsResetFadeWhenStop = MovieSequence.IsResetFadeWhenStop
    self.IsAutoPlay = MovieSequence.IsAutoPlay
    self.SceneCharacterShowType = MovieSequence.SceneCharacterShowType
    self.FadeOutTime = MovieSequence.FadeOutTime
    self.FadeOutWhiteColor = MovieSequence.FadeOutWhiteColor
    self.AnimationCondition = MovieSequence.AnimationCondition
    self.IsBlackScreenAfterPlay = MovieSequence.IsBlackScreenAfterPlay
    self.bIsCanSkip = MovieSequence.IsCanSkip
    self.LcutType = MovieSequence.LcutType or 0
    self.LcutDynParams = MovieSequence.LcutDynParams
    self.CheckNewbieForSkip = MovieSequence.CheckNewbieForSkip
end

-- 登录和断线重连都会设置bInit
function DynDataCutSceneSequence:SetIsInit(bInit)
    self.bCurrIsInit = bInit
end

function DynDataCutSceneSequence:UpdateState(NewState)
    local LastState = self.State
    self.Super:UpdateState(NewState)

    if NewState == 0 then
        return -- IsAutoPlay动画后台不存状态，不受UpdateState控制
    end
    
    local PWorldMgr = _G.PWorldMgr
    if (PWorldMgr:UpdateMapDynDataInClientRestore()) then
        return --客户端本地切地图请求数据导致的重新UpdateState，不处理，避免重复播放
    end

    if self.bCurrIsInit and (PWorldMgr.EnterMapServerFlag == 1) then -- 断线重连后首次更新
        self.bCurrIsInit = false

        if not _G.StoryMgr:SequenceIsPlaying() then -- 客户端正在播片就当无事发生
            if PWorldMgr.StoppedDynDataSeqID == self.ID then
                PWorldMgr:SendMovieEnd(self.ID, 1, 0)
            else
                if PWorldMgr:CurrIsInSingleDungeon() then
                    self:PlayCutSceneSequence()
                else
                    PWorldMgr:SendMovieEnd(self.ID, 1, 0)
                end
            end
        end

    elseif (LastState == 0 and self.bSvrMajorPlaying) then
        self:PlayCutSceneSequence()
    end
end

function DynDataCutSceneSequence:UpdateMajorPlaying(Status, Extra)
    if Status == 0 or Extra == "" then
        self.bSvrMajorPlaying = false
        return
    end

    local RoleIDStrList = string.split(Extra, ",")
    if RoleIDStrList ~= nil and next(RoleIDStrList) ~= nil then
        local MajorRoleID = MajorUtil.GetMajorRoleID()
        for _, Str in ipairs(RoleIDStrList) do
            local RoleID = tonumber(Str)
            if MajorRoleID == RoleID then
                self.bSvrMajorPlaying = true
                return
            end
        end
    end

    self.bSvrMajorPlaying = false
end

function DynDataCutSceneSequence:ExecAutoPlay()
    if (self.IsAutoPlay) then
        if (_G.PWorldMgr.StoppedDynDataSeqID == self.ID) and (not _G.StoryMgr:SequenceIsPlaying()) then
            return false
        end
        self:PlayCutSceneSequence()
        if (_G.StoryMgr:SequenceIsPlaying()) then
            return true
        end
    end
    return false
end

function DynDataCutSceneSequence:GetAutoPlaySequence()
    if (not self.IsAutoPlay) then
        return nil
    end

    if (self.bIsCanSkip and self.CheckNewbieForSkip) then
        --队伍里没有新人且已经看过了
        if (not _G.PWorldMgr:HasNewbieInTeam() and StorySetting.IsSkip(self.ID)) then
            return nil
        end
    else
        if (StorySetting.IsSkip(self.ID)) then
            return nil
        end
    end
    
    return self
end

function DynDataCutSceneSequence:PlayCutSceneSequence()
    if self.LcutType > 1 then -- 如果配置了动态参数，则设置参数
        _G.SeqDynParamsMgr:SetDynParams(self.LcutType, self.LcutDynParams)
    end

    local bInSingleDungeon = _G.PWorldMgr:CurrIsInSingleDungeon()
    local bSkipQuestSeq = bInSingleDungeon and StorySetting.GetAutoSkipQuestSequence()

    if self.AnimationCondition and self.AnimationCondition > 0 then
        local CutsceneConditionCfgItem = CutsceneConditionCfg:FindCfgByKey(self.AnimationCondition)
        if CutsceneConditionCfgItem then
            if ConditionMgr:CheckConditionByID(CutsceneConditionCfgItem.ConditionID) then
                self:AnimCondPlayCutScene(bInSingleDungeon, bSkipQuestSeq, CutsceneConditionCfgItem)
                return
            end
        end
    end

    self:NormalPlayCutScene(bInSingleDungeon, bSkipQuestSeq)
end

function DynDataCutSceneSequence:AnimCondPlayCutScene(bInSingleDungeon, bSkipQuestSeq, CutsceneConditionCfgItem)
    local PWorldMgr = _G.PWorldMgr

    local function OnSequenceStoped()
        if self.LcutType > 1 then
            _G.SeqDynParamsMgr:Reset()
        end
        PWorldMgr.StoppedDynDataSeqID = self.ID -- 要用来做判断，以原始ID为准
        PWorldMgr:SendReady()
        _G.EventMgr:SendEvent(_G.EventID.PWorldMapMovieSequenceEnd)
    end

    if bSkipQuestSeq then
        PWorldMgr:SendMovieEnd(self.ID, 1, 0)
        OnSequenceStoped()
    else
        if bInSingleDungeon then
            _G.QuestMgr:SetInQuestSequence(true)
        end
        _G.StoryMgr:PlayCutSceneSequenceByID(CutsceneConditionCfgItem.SequenceID, OnSequenceStoped)
    end
end

function DynDataCutSceneSequence:NormalPlayCutScene(bInSingleDungeon, bSkipQuestSeq)
    local PWorldMgr = _G.PWorldMgr

    local function OnSequenceStoped()
        if self.LcutType > 1 then
            _G.SeqDynParamsMgr:Reset()
        end
        PWorldMgr.StoppedDynDataSeqID = self.ID
        _G.EventMgr:SendEvent(_G.EventID.PWorldMapMovieSequenceEnd)
    end

    if bSkipQuestSeq then
        PWorldMgr:SendMovieEnd(self.ID, 1, 0)
        OnSequenceStoped()
    else
        if bInSingleDungeon then
            _G.QuestMgr:SetInQuestSequence(true)
        end
        _G.StoryMgr:PlayCutSceneSequence(self, OnSequenceStoped)
    end
end

return DynDataCutSceneSequence