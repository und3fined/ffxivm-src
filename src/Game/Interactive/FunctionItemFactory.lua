
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")
local FunctionQuest = require("Game/Interactive/FunctionItem/FunctionQuest")
local FunctionDeafaultTalk = require("Game/Interactive/FunctionItem/FunctionDeafaultTalk")
local FunctionQuit = require("Game/Interactive/FunctionItem/FunctionQuit")
local FunctionDialogueChoice = require("Game/Interactive/FunctionItem/FunctionDialogueChoice")
local FunctionNPCQuit = require("Game/Interactive/FunctionItem/FunctionNPCQuit")
local FunctionNpcOld = require("Game/Interactive/FunctionItem/FunctionNpcOld")
local FunctionInteractiveDesc = require("Game/Interactive/FunctionItem/FunctionInteractiveDesc")
local FunctionCustomTalk = require("Game/Interactive/FunctionItem/FunctionCustomTalk")
local FunctionNpcBranch = require("Game/Interactive/FunctionItem/FunctionNpcBranch")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local ProtoCS = require("Protocol/ProtoCS")

local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS

--按Entrance的TargetType的不同，产生的二级列表方式也不同
--  比如Npc的先产生QuestMgr的交互项，然后是npc表里配置的，最后再是离开
--  比如采集物，需要GatherMgr产生交互项：视野内的采集物

local FunctionItemFactory = LuaClass()


--以后有需要再按Type，记录各个子类，然后通过Type获取
--现在直接在这里按类型处理了

function FunctionItemFactory:CreateFunction(FuncType, DisplayName, FuncParams)
    local IFuncUnit = nil

    if FuncType == LuaFuncType.QUIT_FUNC then
        IFuncUnit = FunctionQuit.New()
    elseif FuncType == LuaFuncType.NPCQUIT_FUNC then
        IFuncUnit = FunctionNPCQuit.New()
    elseif FuncType == LuaFuncType.OLDNPC_FUNC then
        IFuncUnit = FunctionNpcOld.New()
    else
    end

    if IFuncUnit == nil then
        FLOG_ERROR("Interactive Factory:CreateFunction Failed")
        return nil
    end
    
    IFuncUnit:Init(DisplayName, FuncParams)

    return IFuncUnit
end

--走交互表的通用交互
function FunctionItemFactory:CreateInteractiveDescFunc(FuncParams, bOnlyCheck, bShowConditionFaildTips)
    local InteractiveID = FuncParams.FuncValue
    local EntityID = FuncParams.EntityID
    local Cfg = InteractivedescCfg:FindCfgByKey(InteractiveID)
    if not Cfg then
        FLOG_ERROR("Interactive descCfg id: %d need Cofig", InteractiveID)
        return nil
    end

    -- 对于不满足条件的交互项，也会显示出来
    --InteractiveMgr.CurInteractEntrance.EntityID`
    if Cfg.IsForceShow == 0 and not ConditionMgr:CheckConditionByID(Cfg.ConditionID, FuncParams.ConditionParams, bShowConditionFaildTips) then
        return nil
    end

    --针对Fate的NPC交互处理
    if Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_START_FATE or 
    Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_PROCESS_FATE then
        local FataState = _G.FateMgr:CheckNpcFateState(EntityID)
        if FataState == nil then
            return nil
        end

        if Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_START_FATE and FataState ~= ProtoCS.FateState.FateState_WaitNPCTrigger then
            return nil
        end

        if Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_PROCESS_FATE and 
        not(FataState == ProtoCS.FateState.FateState_InProgress or FataState == ProtoCS.FateState.FateState_EndSubmitItem)then
            return nil
        end
    elseif(Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_FANTASYCARD) then
        -- 如果是九宫幻卡，那么要完成幻卡任务，又或者是解锁了幻卡系统功能才行
        local bFinish = _G.MagicCardMgr:HasFinishTargetQuest()
        if (not bFinish) then
            return nil
        end
        
        -- 新需求，这里需要看一下，互动的NPC是否有前置任务，如果没有完成前置任务，那么也不显示 2024-8-5
        local bFinishPreQuest = _G.MagicCardMgr:HasFinishPreQuestByEntityID(EntityID)
        if (not bFinishPreQuest) then
            return nil
        end
    elseif(Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_SWITCH_COMPANION) then
        -- 如果是切换宠物，拥有的宠物数量必须大于1
        local CompanionList = _G.CompanionMgr:GetOwnedCompanions()
        if #CompanionList <= 1 then
            return nil
        end
    elseif Cfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_TREASUREHUNT then
        local IsBoxBelongMajorOrTeam = _G.TreasureHuntMgr:IsBoxBelongMajorOrTeam(EntityID)
        if not IsBoxBelongMajorOrTeam then
            return nil
        end
    end

    if bOnlyCheck then
        return true
    end

    if Cfg.ConditionID and Cfg.ConditionID > 0 then
        FuncParams.ConditionID = Cfg.ConditionID
    end

    local  IFuncUnit = FunctionInteractiveDesc.New()
    --这里传入的是交互表，而不是交互物（需要交互的entityid、resid）
    IFuncUnit:Init(FuncParams.DisplayName or Cfg.DisplayName, FuncParams)

    return IFuncUnit
end

--如果有条件检测就在这里做
function FunctionItemFactory:CreateQuestFunc(DisplayName, FuncParams)
    local IFuncUnit = FunctionQuest.New()
    IFuncUnit:Init(DisplayName, FuncParams)

    return IFuncUnit
end
function FunctionItemFactory:CreateDeafaultTalkFunc(DisplayName, FuncParams)
    local IFuncUnit = FunctionDeafaultTalk.New()
    IFuncUnit:Init(DisplayName, FuncParams)

    return IFuncUnit
end

--如果有条件检测就在这里做
function FunctionItemFactory:CreateDialogueChoiceFunc(DisplayName, FuncParams)
    local IFuncUnit = FunctionDialogueChoice.New()
    IFuncUnit:Init(DisplayName, FuncParams)

    return IFuncUnit
end

function FunctionItemFactory:CreateCustomTalkFunc(DisplayName, FuncParams)
    local IFuncUnit = FunctionCustomTalk.New()
    IFuncUnit:Init(DisplayName, FuncParams)

    return IFuncUnit
end

function FunctionItemFactory:CreateNpcDialogBranch(DisplayName, FuncParams)
    local IFuncUnit = FunctionNpcBranch.New()
    IFuncUnit:Init(DisplayName, FuncParams)

    return IFuncUnit
end

return FunctionItemFactory