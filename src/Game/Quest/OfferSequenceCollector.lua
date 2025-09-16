
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")

local TypeHintTalkBefore = ProtoRes.QUEST_CLIENT_ACTION_TYPE.QUEST_CLIENT_ACTION_HINT_TALK_BEFORE

-- OfferSequence 是端游开始任务前的一个过程。
-- 手游一开始没有引入，现在只能单独管理，不方便放到任务状态更新环节里。
-- QuestMgr:TryActivateQuest创建，Chapter:Accept移除
---@class OfferSequence
local OfferSequence = LuaClass()

function OfferSequence:Ctor(ChapterID)
    self.ChapterID = ChapterID
    self.Behaviors = {} -- list < ClientBehaviorBase >
end

---@class OfferSequenceCollector
local OfferSequenceCollector = LuaClass()

function OfferSequenceCollector:Ctor()
    self:InitData()
end

function OfferSequenceCollector:InitData()
    self.OfferSequences = {}
end

function OfferSequenceCollector:CreateOfferSequence(ChapterID, QuestCfgItem)
    if (ChapterID or 0) == 0 then
        _G.FLOG_ERROR("CreateOfferSequence get invalid param")
        return nil
    end

    local OS = self.OfferSequences[ChapterID]
    if OS ~= nil then
        return OS
    end

    local NewOS = OfferSequence.New(ChapterID)

    local QuestMgr = _G.QuestMgr
    for _, BehaviorID in ipairs(QuestCfgItem.TaskAcceptExpression) do
        local Behavior = QuestMgr.CreateClientBehavior(QuestCfgItem.id, BehaviorID)
        if Behavior.BehaviorType == TypeHintTalkBefore then
            table.insert(NewOS.Behaviors, Behavior)
            if Behavior.RegisterHintTalk then
                Behavior:RegisterHintTalk()
            end
        end
    end

    self.OfferSequences[ChapterID] = NewOS
    return NewOS
end

function OfferSequenceCollector:RemoveOfferSequence(ChapterID)
    self.OfferSequences[ChapterID] = nil
end

function OfferSequenceCollector.CheckNeedCreateOfferSequence(ChapterCfgItem)
    return (ChapterCfgItem ~= nil) and (ChapterCfgItem.HasOfferSequence == 1)
end

return OfferSequenceCollector
