---
--- Author: star
--- DateTime: 2024-01-08 14:30
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local DialogueUtil = require("Utils/DialogueUtil")
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local MiniCactpotMgr = require("Game/MiniCactpot/MiniCactpotMgr")
local TimeUtil = require("Utils/TimeUtil")
--local ProtoCommon =  require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local GoldSauserMainPanelTextListVM =  require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelTextListVM")
local GoldSauserMainPanelTasklistVM =  require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelTasklistVM")
local GoldSaucerGameDescCfg = require("TableCfg/GoldSaucerGameDescCfg")
local GoldSaucerCfg = require("TableCfg/GoldSaucerCfg")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local LSTR = _G.LSTR
local RedDotBaseName = GoldSauserMainPanelDefine.RedDotBaseName
local ProtoCS =  require("Protocol/ProtoCS")
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr
local ProtoRes =  require("Protocol/ProtoRes")
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
---@class GoldSauserMainPanelExplainWinVM : UIViewModel

local GoldSauserMainPanelExplainWinVM = LuaClass(UIViewModel)

local RoundDefaultContent = LSTR(350042)
local ScoreDefaultContent = LSTR(350043)

---Ctor
function GoldSauserMainPanelExplainWinVM:Ctor()
    self.GameId = nil
    self.GameType = nil
    self.TitleText = nil
    self.DescContentText = nil -- 玩法描述文本
    self.bShowPanelGameInfo = nil -- 是否显示辅助信息区
    self.TextBureau = nil -- 规则面板（对局）
    self.TextIntegral = nil -- 规则面板（积分）
    self.bUnlock = nil -- 玩法是否解锁
    self.QuestIconVisible = false -- 任务图标是否显示
    self.LockQuestName = nil -- 解锁需完成的任务/玩法提示信息
    self.HintTextColor = nil
    self.bAwardToGet = nil -- 是否处于奖励待领取状态
    self.EndTimeStamp = nil -- 时限结束时间戳
    self.IsShowJoinText = nil
    self.IsShowTimeText = nil
    self.IsFinishAllEvent = nil
    self.JoinText = nil
    self.TimeText = nil
    self.EventTextstr = nil
    self.PromptText1 = nil
    self.PromptText2 = nil
    self.DescTextList = UIBindableList.New(GoldSauserMainPanelTextListVM)
    self.EventList = UIBindableList.New(GoldSauserMainPanelTasklistVM)
    self.RedDotName = nil

    -- 玩法挑战货币状态
    self.Icon = nil
    self.Num = nil -- 当前玩法挑战奖励数量
    self.NumVisible = nil -- 是否显示奖励货币数量
    self.IconChooseVisible = nil -- 货币Item选中状态图标
    self.HideItemLevel = true -- 是否隐藏道具等级文本

    self.bTaskCompleteMax = nil -- 玩法事件完成是否上限
    self.IconTobeViewVisible = false -- 待查看图标是否显示
end

function GoldSauserMainPanelExplainWinVM:OnInit()
    self.GameId = 0
    self.GameType = 0
    self.TitleText = ""
    self.DescContentText = ""
    self.bShowPanelGameInfo = false
    self.TextBureau = ""
    self.TextIntegral = ""

    self.bUnlock = false -- 玩法是否解锁
    self.QuestIconVisible = false -- 任务图标是否显示
    self.IconTobeViewVisible = false -- 待查看图标是否显示
    self.LockQuestName = "" -- 解锁需完成的任务
    self.HintTextColor = GoldSauserMainPanelDefine.HintColor
    self.IsShowTimeText = false -- 是否显示时间限制面板
    self.bAwardToGet = false
    self.bShowTopInfo = true -- 是否显示Top面板
 
    self.IsShowPromptText = false
    self.IsShowJoinText = false
  
    self.IsFinishAllEvent = false
    self.JoinText = ""
    self.EndTimeStamp = 0
    self.TimeText = 0
    self.EventTextstr = ""
    self.PromptText1 = ""
    self.PromptText2 = ""
    self.RedDotName = nil

    -- 货币Item
    self.Icon = ""
    self.Num = ""
    self.NumVisible = false
    self.HideItemLevel = true
    self.IconChooseVisible = false

    self.bTaskCompleteMax = false

    self.GameTypeReward = 0 -- 标记领取过奖励的ExplainGameID
end


function GoldSauserMainPanelExplainWinVM:SetRewardGameType(TaskType)
    self.GameTypeReward = TaskType
end

--- 设定玩法挑战事件是否上限
function GoldSauserMainPanelExplainWinVM:SetTaskCompleteMax(bMax)
    self.bTaskCompleteMax = bMax
    if bMax then
        self.EventTextstr = string.format(LSTR(350095))
    end
end

--- 获得玩法挑战事件是否上限
function GoldSauserMainPanelExplainWinVM:GetTaskCompleteMax()
    return self.bTaskCompleteMax
end

function GoldSauserMainPanelExplainWinVM:SetInfo(InGameId, TaskType)
    self.GameId = InGameId
    self.GameType = TaskType
    self:SetTitleAndDescContentText()
  
    --- 防止切换时事件协议未下发
    self.IsFinishAllEvent = false
   
    self.RedDotName = string.format("%s/%s/Explain", RedDotBaseName, tostring(InGameId))
end

--- 设定玩法的解锁状态
---@param LockParam table@玩法的多种信息
function GoldSauserMainPanelExplainWinVM:SetGameLockState(LockParam)
    local GameID = self.GameId
    if not GameID then
        return
    end
    local bUnLock = LockParam.Unlock
    self.bUnlock = bUnLock
    self.HintTextColor = bUnLock and GoldSauserMainPanelDefine.HintColor or GoldSauserMainPanelDefine.LockQuestColor
    local bShowEndTime = bUnLock and self:GetIsTimeLimitGame(GameID)
    self.IsShowTimeText = bShowEndTime
    self.bShowTopInfo = not bUnLock or bShowEndTime
    
    self.LockQuestName = LockParam.QuestName or ""
    self.QuestIconVisible = not bUnLock and self.LockQuestName ~= ""
end

--- 设定玩法标题以及描述文本
function GoldSauserMainPanelExplainWinVM:SetTitleAndDescContentText()
    local GameID = self.GameId
    if not GameID then
        return
    end

    local SearchConditions = string.format("GameType=%d", GameID) 
    local DescCfg = GoldSaucerGameDescCfg:FindCfg(SearchConditions)
    if not DescCfg then
        return
    end
    self.DescContentText = DescCfg.Desc or "???"
    self.TitleText = DescCfg.Name or "???"
end

---@是否是有辅助信息的玩法
function GoldSauserMainPanelExplainWinVM:IsHaveAssistInfo(InGameId)
    for _, GameId in pairs(GoldSauserMainPanelDefine.AssistInfoGameType) do
        if InGameId == GameId then
            return true
        end
    end
    return false
end

--- 设置辅助信息栏内容
---@param RoundStr string@对局信息文本
---@param ScoreStr string@得分信息文本
function GoldSauserMainPanelExplainWinVM:SetAssistPanelInfo(RoundStr, ScoreStr)
    self.bShowPanelGameInfo = self.bUnlock and self:IsHaveAssistInfo(self.GameId)
    self.TextBureau = string.format("%s%s", RoundDefaultContent, RoundStr or "")
    self.TextIntegral = string.format("%s%s", ScoreDefaultContent, ScoreStr or "")
end

--- 设定玩法的提示信息
---@param LockParam table@玩法的多种信息
function GoldSauserMainPanelExplainWinVM:SetHintContent(HintStr, bAwardToGet, IconTobeViewVisible)
    if not self.bUnlock then
        self.IconTobeViewVisible = false
        return
    end
    self.bAwardToGet = bAwardToGet
    self.LockQuestName = HintStr or ""
    self.IconTobeViewVisible = IconTobeViewVisible
end

---@是否是时间限制的玩法
function GoldSauserMainPanelExplainWinVM:GetIsTimeLimitGame(InGameId)
    for _, GameId in pairs(GoldSauserMainPanelDefine.TimeLimitGameType) do
        if InGameId == GameId then
            return true
        end
    end
    return false
end

--- 设定玩法的时限结束时间戳
---@param EndTime number @结束时间戳 MS
function GoldSauserMainPanelExplainWinVM:SetTimeLimitEndTimeStamp(EndTime)
    local CurrentTime = TimeUtil.GetServerTimeMS()

    if EndTime <= CurrentTime or self.bAwardToGet then
        self.IsShowTimeText = false
        return
    end
    self.EndTimeStamp = EndTime
end

--- 刷新玩法挑战事件相关信息
---@param RewardNeedNum number@奖励需要完成的事件数量，由外部传入，保持规则一致
function GoldSauserMainPanelExplainWinVM:SetEventInfo(Event, RewardNeedNum)
    local EventDataList = {}
    local DoneNum  = 0
    local AwardNum = 0

    -- 判定是否需要显示任务刷新动效
    local NeedRefresh = false
    local RewardGameType = self.GameTypeReward
    if RewardGameType then
        NeedRefresh = RewardGameType == self.GameType
        self.GameTypeReward = nil
    end

    for _, Data in ipairs(Event) do
        local function MakeTheItemData()
            local ServerEvtID = Data.ID
            local ServerEvtNum = Data.Num
            if not ServerEvtID or not ServerEvtNum then
                return
            end

            local Cfg = GoldSaucerCfg:FindCfgByKey(ServerEvtID)
            if not Cfg then
                return
            end
           
            local MaxNum = Cfg.TaskNum or 0
            local Rewards = Cfg.Rewards
            --AwardNum = AwardNum + Rewards
            if AwardNum == 0 then
                AwardNum = Rewards
            end

            local EventData = {}
            EventData.ID = ServerEvtID
            EventData.Num = ServerEvtNum
            EventData.bNeedRefresh = NeedRefresh
            local BaseDesc = Cfg.Desc or ""
            local TaskParam = Cfg.TaskParam or 0
            local DescWithParam 
            if MaxNum > 0 and TaskParam > 0 then
                DescWithParam = string.format(BaseDesc, ServerEvtID, ServerEvtID)
                EventData.DescriptionStr = DialogueUtil.ParseLabel(DescWithParam)
            elseif TaskParam > 0 or MaxNum > 0 then
                DescWithParam = string.format(BaseDesc, ServerEvtID)
                EventData.DescriptionStr = DialogueUtil.ParseLabel(DescWithParam)
            else
                EventData.DescriptionStr = BaseDesc
            end

            if EventData.Num and MaxNum then
                if EventData.Num < MaxNum then
                    EventData.RightWidgetIndex = 0
                    EventData.MaxNum = tostring(MaxNum)
                elseif EventData.Num >= MaxNum then
                    EventData.RightWidgetIndex = 1
                    DoneNum = DoneNum + 1
                end
            end
            return EventData
        end

        local ItemData = MakeTheItemData()
        if ItemData then
            table.insert(EventDataList, ItemData)
        end
    end
    table.sort(EventDataList, function(A, B)
        return A.ID < B.ID
    end)

    local CanAwardReceive = DoneNum > 0 and DoneNum >= RewardNeedNum
    self.IsFinishAllEvent = CanAwardReceive
    for _,  EvtData in ipairs(EventDataList) do
        EvtData.bRewardCanReceive = CanAwardReceive
    end

    self.EventTextstr = string.format(LSTR(350044), DoneNum, RewardNeedNum)
    self.NumVisible = AwardNum >= 0
    self.Num = AwardNum
    self.HideItemLevel = true
    self.EventList:UpdateByValues(EventDataList)
end

function GoldSauserMainPanelExplainWinVM:GetGameType()
    return self.GameType
end

function GoldSauserMainPanelExplainWinVM:SetGameId(InGameId)
    self.GameId = InGameId
end

function GoldSauserMainPanelExplainWinVM:GetGameId()
    return self.GameId
end

function GoldSauserMainPanelExplainWinVM:IsEventIDNeedShow(EventID)
    local Cfg = GoldSaucerCfg:FindCfgByKey(EventID)
    if not Cfg then
        return
    end
    local GameSubType = Cfg.GameSubType
    if GameSubType and next(GameSubType) then
        for _, GameID in ipairs(GameSubType) do
            if GameID == self.GameId then
                return true
            end
        end
    end
end

function GoldSauserMainPanelExplainWinVM:OnReset()

end

function GoldSauserMainPanelExplainWinVM:OnBegin()

end

function GoldSauserMainPanelExplainWinVM:OnEnd()

end

function GoldSauserMainPanelExplainWinVM:OnShutdown()

end

return GoldSauserMainPanelExplainWinVM
