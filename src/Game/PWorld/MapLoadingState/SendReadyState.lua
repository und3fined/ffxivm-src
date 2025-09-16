local LuaClass = require("Core/LuaClass")
local LoadingStateBase = require("Game/PWorld/MapLoadingState/LoadingStateBase")

--上报Ready给服务器
local SendReadyState = LuaClass(LoadingStateBase, true)

function SendReadyState:Ctor()
end

function SendReadyState:EnterState()
    local LoadWorldReason =  _G.PWorldMgr:GetLoadWorldReason()
    --过场动画结束后触发回到原地图，此时不检测
    if (LoadWorldReason == _G.UE.ELoadWorldReason.RestoreNormal) then
        return
    end

    local function CheckSendReady(bWaitSequenceFinish)
        _G.FLOG_INFO("PWorldMgr SendReadyState:CheckSendReady bWaitSequenceFinish=%s", tostring(bWaitSequenceFinish))
        --加个保护，Sequence播放失败，这里重置状态，避免没有上报ready
        if (bWaitSequenceFinish and not _G.StoryMgr:SequenceIsPlaying()) then
            bWaitSequenceFinish = false
        end

        --没有过场动画，则直接上报，否则等到播放完成后上报
        if (not bWaitSequenceFinish) then
            _G.PWorldMgr:OnAutoPlaySequenceFinish()
        end
    end

    local bChangeMap = _G.PWorldMgr:IsChangeMap()
    local bChangePWorld = _G.PWorldMgr:IsChangePWorld()
    if (bChangeMap or bChangePWorld) then
        local CurrMapResID = _G.PWorldMgr:GetCurrMapResID()
        local bHasQuestAutoPlaySeq = _G.QuestMgr:PlayQuestMapSequence(CurrMapResID)
        --检测自动播放的过场sequence，需要放到major创建之后
        --优先任务sequence
        --只有PWorldEnterRsp.Flag为0时表示“准备期间进入”需要播放开场动画，其它（断线重连、中途加入等）跳过开场动画
        local bWaitSequenceFinish = false
        local PWorldDynDataMgr = _G.PWorldMgr:GetPWorldDynDataMgr()
        local EnterMapServerFlag = _G.PWorldMgr:GetEnterMapServerFlag()
        if (not bHasQuestAutoPlaySeq) then
            if (EnterMapServerFlag == 0) then
                bWaitSequenceFinish = PWorldDynDataMgr:ExecMovieSequenceAutoPlay()

            elseif (EnterMapServerFlag == 3) then -- 准备期间断线重连
                if _G.PWorldMgr:CurrIsInSingleDungeon() then
                    bWaitSequenceFinish = PWorldDynDataMgr:ExecMovieSequenceAutoPlay()
                else
                    local CutSceneSequence = PWorldDynDataMgr:GetAutoPlaySequence()
                    if _G.StoryMgr:SequenceIsPlaying() then
                        if CutSceneSequence and CutSceneSequence.ID > 0 then
                            local CurrSeqID = _G.StoryMgr:GetCurrentSequenceID()
                            bWaitSequenceFinish = CutSceneSequence.ID == CurrSeqID
                        end
                    end

                    if not bWaitSequenceFinish and CutSceneSequence and CutSceneSequence.ID > 0 then
                        _G.PWorldMgr:SendMovieEnd(CutSceneSequence.ID, 1, 0)
                    end
                end
            end
        end

        CheckSendReady(bWaitSequenceFinish)
    end
end

function SendReadyState:ExitState()
end

return SendReadyState
