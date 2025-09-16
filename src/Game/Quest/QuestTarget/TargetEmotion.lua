---
--- Author: lydianwang
--- DateTime: 2022-03-15
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local ActorUtil = require("Utils/ActorUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local NpcDialogMgr = require("Game/NPC/NpcDialogMgr")
local MajorUtil = require("Utils/MajorUtil")
local QuestHelper = require("Game/Quest/QuestHelper")
local CommonUtil = require("Utils/CommonUtil")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local EActorType = _G.UE.EActorType
local EventID = _G.EventID
local QuestMgr = nil


local EEmotionTargetType = {
    None = 0,
    Npc = 1,
    EObj = 2,
    Area = 3,
}

---@class TargetEmotion
local TargetEmotion = LuaClass(TargetBase, true)

function TargetEmotion:Ctor(_, Properties)
    self.EmotionID = tonumber(Properties[1])
    self.NpcID = tonumber(Properties[2])
    self.WrongEmotionDialogID = tonumber(Properties[3])
    self.EObjID = tonumber(Properties[4])
    self.AreaID = tonumber(Properties[5])
    self.AreaMapID = tonumber(Properties[6])
    
    self.bRevertMark = false
    self.bInArea = false

    local EType = EEmotionTargetType
    self.EmotionTargetType = EType.None
    if (self.NpcID or 0) ~= 0 then
        self.EmotionTargetType = EType.Npc
    elseif (self.EObjID or 0) ~= 0 then
        self.EmotionTargetType = EType.EObj
    elseif ((self.AreaID or 0) ~= 0) and ((self.AreaMapID or 0) ~= 0) then
        self.EmotionTargetType = EType.Area
    end

    QuestMgr = _G.QuestMgr
end

function TargetEmotion:DoStartTarget(bRevert)
    if bRevert then
        self.bRevertMark = true
    end
    if self.EmotionTargetType == EEmotionTargetType.Area then
        self:RegisterEvent(EventID.AreaTriggerBeginOverlap, self.OnEnterTrigger)
        self:RegisterEvent(EventID.AreaTriggerEndOverlap, self.OnLeaveTrigger)
        QuestMgr.QuestRegister:RegisterQuestTrigger(self.AreaMapID, self.AreaID)
    end

    self:RegisterEvent(EventID.PostEmotionEnter, self.OnEmotionEnter)
    self:RegisterEvent(EventID.PostEmotionEnd, self.OnEmotionEnd)
    _G.EventMgr:SendEvent(EventID.QuestTargetEmotionStart, {
        EmotionID = self.EmotionID,
        NpcResID = self.NpcID,
        EObjResID = self.EObjID,
        QuestID = self.QuestID,
        QuestTargetID = self.TargetID,
        AreaID = self.AreaID,
        AreaMapID = self.AreaMapID,
    })
end

function TargetEmotion:DoClearTarget()
    if self.EmotionTargetType == EEmotionTargetType.Area then
        QuestMgr.QuestRegister:UnRegisterQuestTrigger(self.MapID, self.AreaID)
    end

    if UIViewMgr:IsViewVisible(UIViewID.CommEasytoUseView) then
		UIViewMgr:HideView(UIViewID.CommEasytoUseView)
	end

    _G.EventMgr:SendEvent(EventID.QuestTargetEmotionEnd, {
        EmotionID = self.EmotionID,
        NpcResID = self.NpcID,
        EObjResID = self.EObjID,
        QuestID = self.QuestID,
        QuestTargetID = self.TargetID,
        AreaID = self.AreaID,
        AreaMapID = self.AreaMapID,
    })
end

function TargetEmotion:OnEmotionEnter(EventParams)
    local FromEntityID = EventParams.ULongParam1
    if FromEntityID ~= MajorUtil.GetMajorEntityID() then return end

    if not self:CheckEmotionTarget(EventParams.ULongParam2) then
        return
    end

    if not QuestHelper.CheckCanProceed(self.QuestID) then
        return
    end

    local EmotionID = EventParams.IntParam1
    if EmotionID ~= self.EmotionID then
        return
    end

    UIViewMgr:HideView(UIViewID.EmotionMainPanel)
    --设置提交状态
    QuestMgr:SetSubmitingStatus(true)
end

function TargetEmotion:OnEmotionEnd(EventParams)
    local FromEntityID = EventParams.ULongParam1
    if FromEntityID ~= MajorUtil.GetMajorEntityID() then print("test EntityID failed") return end

    local EmotionID = EventParams.IntParam1

    --设置提交状态
    QuestMgr:SetSubmitingStatus(false)

    local bInterrupted = EventParams.BoolParam1
    if bInterrupted then
        print("test bInterrupted failed")
        if EmotionID == self.EmotionID then
            local CancalReason = EventParams.IntParam2
            if CancalReason == EmotionDefines.CancelReason.MOVE then
                MsgTipsUtil.ShowTipsByID(70006)
            end
        end
        return
    end

    local ToEntityID = EventParams.ULongParam2
    if not self:CheckEmotionTarget(ToEntityID) then
        print("test CheckEmotionTarget failed") return
    end

    local EType = EEmotionTargetType
    local Type = self.EmotionTargetType
    if Type == EType.Npc or Type == EType.EObj then
        -- 检查距离，情感动作未提供距离数据或检查机制，任务先自行检查
        local Major = MajorUtil.GetMajor()
        local Actor = ActorUtil.GetActorByEntityID(ToEntityID)
        if Major == nil or Actor == nil then return end
        local Distance = (Major:FGetActorLocation() - Actor:FGetActorLocation()):Size()
        local GlobalCfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_COMMON_INTERACTIVE_RANGE)
        local CfgDistance = 600
        if GlobalCfg and GlobalCfg.Value and GlobalCfg.Value[1] > 33 then
            CfgDistance = GlobalCfg.Value[1]
        end
        if Distance > CfgDistance then
            MsgTipsUtil.ShowErrorTips(_G.LSTR(591005)) --591005("距离太远。")
            print("test Distance failed") return
        end
    end

    if not QuestHelper.CheckCanProceed(self.QuestID) then
        QuestHelper.PlayRestrictedDialog(self.QuestID, self.TargetID)
        print("test CheckCanProceed failed") return
    end

    if EmotionID ~= self.EmotionID then
        if self.WrongEmotionDialogID ~= 0 then
            UIViewMgr:HideView(UIViewID.EmotionMainPanel)

            local function PlayDialogFunc()
                NpcDialogMgr:PlayDialogLib(self.WrongEmotionDialogID, ToEntityID, nil, nil, nil, true, true)
            end

            local function PlaySeqFunc()
                QuestHelper.QuestPlaySequence(self.WrongEmotionDialogID)
            end

            QuestHelper.PlayDialogOrSequence(self.WrongEmotionDialogID, PlayDialogFunc, PlaySeqFunc)
        end
        print("test EmotionID failed") return
    end

    if Type == EType.Npc then
        QuestMgr:SendFinishTarget(self.QuestID, self.TargetID, self.NpcID, nil, EActorType.Npc)
    elseif Type == EType.EObj then
        QuestMgr:SendFinishTarget(self.QuestID, self.TargetID, self.EObjID, nil, EActorType.EObj)
    else
        QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
    end
end

function TargetEmotion:GetNpcID()
    return self.NpcID or 0
end

function TargetEmotion:GetEObjID()
    return self.EObjID or 0
end

function TargetEmotion:CheckEmotionTarget(ToEntityID)
    local EType = EEmotionTargetType
    local Type = self.EmotionTargetType

    if Type == EType.Npc then
        local AttrComp = ActorUtil.GetActorAttributeComponent(ToEntityID)
        return (AttrComp ~= nil) and (AttrComp.ObjType == EActorType.Npc) and (AttrComp.ResID == self.NpcID)

    elseif Type == EType.EObj then
        local AttrComp = ActorUtil.GetActorAttributeComponent(ToEntityID)
        return (AttrComp ~= nil) and (AttrComp.ObjType == EActorType.EObj) and (AttrComp.ResID == self.EObjID)

    elseif Type == EType.Area then
        return self.bInArea
    end
    
    return false
end

function TargetEmotion:OnEnterTrigger(EventParam)
    local bReverted = self.bRevertMark
    self.bRevertMark = false
    if EventParam.bTriggeredOnCreate and bReverted then
        -- 回退此目标会重新创建触发器，创建时会触发一次
        -- 如果不忽略这次触发，会有反复回退反复触发的问题
        return
    end

    if EventParam.AreaID == self.AreaID then
        if self.AreaMapID ~= _G.PWorldMgr:GetCurrMapResID() then
            return
        end
        self.bInArea = true
    end
end

function TargetEmotion:OnLeaveTrigger(EventParam)
    if EventParam.AreaID == self.AreaID then
        if self.AreaMapID ~= _G.PWorldMgr:GetCurrMapResID() then
            return
        end
        self.bRevertMark = false
        self.bInArea = false
    end
end

return TargetEmotion