local LuaClass = require("Core/LuaClass")
local LoadingStateBase = require("Game/PWorld/MapLoadingState/LoadingStateBase")

 --自动播放的过场动画需要加载LevelStreamingVolume配置的子关卡
local LoadSubLevelInSequenceState = LuaClass(LoadingStateBase, true)

function LoadSubLevelInSequenceState:Ctor()
end

function LoadSubLevelInSequenceState:EnterState()
    local bLoadSequenceSublevel = _G.PWorldMgr:NeedLoadSublevelsInAutoSequence()
    _G.FLOG_INFO("PWorldMgr LoadSubLevelInSequenceState:EnterState bLoadSequenceSublevel=%s", bLoadSequenceSublevel)
    if (bLoadSequenceSublevel) then
        --需要在地图动态数据初始化执行之后，PWorldDynDataMgr:Init()
        local CutSceneSequence = _G.PWorldMgr:GetAutoPlaySequenceFromDynData()
        local CutsceneCfg
        if (CutSceneSequence == nil) then
            local CurrMapResID = _G.PWorldMgr:GetCurrMapResID()
            local SequenceID =  _G.QuestMgr:GetAutoPlaySequenceId(CurrMapResID)
            if (SequenceID == nil or SequenceID <= 0) then
                _G.PWorldMgr:OnLoadWorldFinish()
                return false
            end

            CutsceneCfg = _G.StoryMgr:GetDynamicCutsceneCfgByID(SequenceID)
        else
            CutsceneCfg = _G.StoryMgr:GetDynamicCutsceneCfgByPath(CutSceneSequence.SequencePath)
        end

        local bLoadAllSubLevels = true --默认加载所有子level，叙事策划不想用关卡编辑器来配置, 统一通过表格控制某些Sequence不加载所有子level
        local bSkipLoadLevelStreaming = false
        if (CutsceneCfg ~= nil) then
            bLoadAllSubLevels = CutsceneCfg.LoadAllSubLevels ~= nil and CutsceneCfg.LoadAllSubLevels > 0 or false
            bSkipLoadLevelStreaming = CutsceneCfg.ForbidLoadLevelStreaming ~= nil and CutsceneCfg.ForbidLoadLevelStreaming > 0 or false
        end

        local function OnAllSeqSublevelLoaded()
            _G.PWorldMgr:OnLoadWorldFinish()
        end

        bLoadSequenceSublevel = _G.StorySubLevelLoader:LoadSublevels(nil, bLoadAllSubLevels, bSkipLoadLevelStreaming, OnAllSeqSublevelLoaded)
         --等子关卡加载完成后再初始化数据，播放auto sequence
         if (not bLoadSequenceSublevel) then
            _G.PWorldMgr:OnLoadWorldFinish()
        end
    else
        _G.PWorldMgr:OnLoadWorldFinish()
    end
end

function LoadSubLevelInSequenceState:ExitState()
end

return LoadSubLevelInSequenceState
