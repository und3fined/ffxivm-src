
local LuaClass = require("Core/LuaClass")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local ProtoRes = require("Protocol/ProtoRes")
local InteractionIconCfg = require("TableCfg/InteractionIconCfg")
local QuestDefine = require("Game/Quest/QuestDefine")

local EActorType = _G.UE.EActorType
local table_to_string = _G.table_to_string
local QuestMgr = nil

local FunctionQuest = LuaClass(FunctionBase)

function FunctionQuest:Ctor()
    self.FuncType = LuaFuncType.QUEST_FUNC
    self.QuestTargetType = nil
end

function FunctionQuest:OnInit(_, FuncParams)
    if FuncParams then
        self.QuestParams = FuncParams.QuestParams -- RegisterQuestOnActor()生成
    end
    if FuncParams.QuestParams then
        self.QuestID = FuncParams.QuestParams.QuestID
        self:SetIconPath(FuncParams.QuestParams.Icon)

        --额外处理,丰富目标表现
        self:InitShowInfo(FuncParams.QuestParams)
    end
    QuestMgr = _G.QuestMgr
end

function FunctionQuest:InitShowInfo(QuestParams)
    if not QuestParams then
        return
    end

    --特殊处理,丰富目标表现
    local TargetCfgItem = QuestHelper.GetTargetCfgItem(QuestParams.QuestID, QuestParams.TargetID)
    if TargetCfgItem then
        self.QuestTargetType = TargetCfgItem.m_iTargetType
        if TargetCfgItem.m_iTargetType == ProtoRes.QUEST_TARGET_TYPE.QUEST_TARGET_TYPE_EMOTION then
            self:SetIconPath("Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_Action.UI_NPC_Icon_Action'")
            self:SetDisplayName(_G.LSTR(90022))
        elseif TargetCfgItem.m_iTargetType == ProtoRes.QUEST_TARGET_TYPE.QUEST_TARGET_TYPE_GET_ITEM then
            self:SetDisplayName(_G.LSTR(90023))
        elseif TargetCfgItem.m_iTargetType == ProtoRes.QUEST_TARGET_TYPE.QUEST_TARGET_TYPE_INTERACT then
            local IconIndex = tonumber(TargetCfgItem.Properties[4])
            local DisplayName = TargetCfgItem.Properties[5]
            if IconIndex then
                local InteractionIconCfgItem = InteractionIconCfg:FindCfgByKey(IconIndex)
                if InteractionIconCfgItem then
                    self:SetIconPath(InteractionIconCfgItem.IconPath)
                end
            end
            if not string.isnilorempty(DisplayName) and DisplayName ~= "0" then
                self:SetDisplayName(DisplayName)
            end
        end
    end
end

function FunctionQuest:OnClick()
    if self.QuestParams == nil then
        _G.FLOG_ERROR("FunctionQuest:OnClick() FunctionQuest #%d not found", self.FuncParams.FuncValue or 0)
        return false
    end
    _G.FLOG_INFO("FunctionQuest:OnClick() QuestParams:\n%s", table_to_string(self.QuestParams))

    local LockMask = self.LockMask
    if LockMask == 1 then
        QuestHelper.PlayRestrictedDialog(self.QuestID, self.TargetID)
        return
    end

    if self.QuestParams.ActorType == EActorType.Npc then
        return self:NpcClick()
    elseif self.QuestParams.ActorType == EActorType.EObj then
        return self:EObjClick()
    end

    return false
end

function FunctionQuest:DialogSwitchCameraOrTurn(Callback)
    if self.FuncParams.IsEntranceItem then
        if self.QuestTargetType and self.QuestTargetType == ProtoRes.QUEST_TARGET_TYPE.QUEST_TARGET_TYPE_EMOTION then
            _G.NpcDialogMgr:OnlySwitchCameraOrTurn(self.FuncParams.CameraData, true, Callback)
        else
            _G.NpcDialogMgr:OnlySwitchCameraOrTurn(self.FuncParams.CameraData, false, Callback)
        end
    else
        Callback()
    end
end

function FunctionQuest:NpcClick()
   -- 如果是容错任务
    local Callback
    if _G.QuestFaultTolerantMgr:IsFaultTolerantQuest(self.QuestParams.QuestID) then
        if not _G.QuestFaultTolerantMgr:CheckCanProceed(self.QuestParams.QuestID) then
            Callback = function() 
                QuestHelper.PlayRestrictedDialog(self.QuestParams.QuestID, self.QuestParams.TargetID)
            end
            self:DialogSwitchCameraOrTurn(Callback)
            return true
        end
        if not _G.QuestFaultTolerantMgr:CheckCanSubmit(self.QuestParams.QuestID, self.QuestParams.TargetID) then
            return true
        end
    else
        if not QuestHelper.CheckCanProceedWithLoot(self.QuestParams.QuestID, nil, nil, self.QuestParams.TargetID) then
            Callback = function() 
                QuestHelper.PlayRestrictedDialog(self.QuestParams.QuestID, self.QuestParams.TargetID)
            end
            self:DialogSwitchCameraOrTurn(Callback)
            return true
        end
    end

    local DialogOrSequenceID = self.QuestParams.DialogOrSequenceID or 0

    local function PlayDialogFunc()
        QuestHelper.PlayDialogWithQuestParams(self.QuestParams, DialogOrSequenceID, nil)
    end

    local function PlaySeqFunc()
        QuestHelper.QuestPlaySequence(DialogOrSequenceID, function(_)
            _G.NpcDialogMgr:CheckNeedEndInteraction()
            QuestMgr:OnQuestInteractionFinished(self.QuestParams)
        end)
    end

    local function PlayFailedFunc()
        QuestMgr:OnQuestInteractionFinished(self.QuestParams)
    end

    Callback = function() 
        QuestHelper.PlayDialogOrSequence(DialogOrSequenceID, PlayDialogFunc, PlaySeqFunc, PlayFailedFunc)
    end
    local DType = QuestDefine.GetDialogueType(DialogOrSequenceID)
    if DType == QuestDefine.DialogueType.DialogueSequence
    or DType == QuestDefine.DialogueType.CutSceneSequence then
        QuestHelper.PlayDialogOrSequence(DialogOrSequenceID, PlayDialogFunc, PlaySeqFunc, PlayFailedFunc)
    else
        self:DialogSwitchCameraOrTurn(Callback)
    end
    return true
end

function FunctionQuest:EObjClick()
    if not QuestHelper.CheckCanProceedWithLoot(self.QuestParams.QuestID, nil, nil, self.QuestParams.TargetID) then
        if not _G.QuestFaultTolerantMgr:IsFaultTolerantQuest(self.QuestParams.QuestID) then
            -- 判断是不是容错任务,容错任务目前没有限制,直接走后面的逻辑
            QuestHelper.PlayRestrictedDialog(self.QuestParams.QuestID, self.QuestParams.TargetID, false)
            return true
        end
    end

    QuestMgr:OnQuestInteractionFinished(self.QuestParams)
    return true
end

return FunctionQuest
