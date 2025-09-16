---
--- Author: star
--- DateTime: 2023-12-29 10:08
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local ScoreMgr = require("Game/Score/ScoreMgr")
--local ProtoCommon =  require("Protocol/ProtoCommon")
local ProtoCS =  require("Protocol/ProtoCS")
local MiniGameType = ProtoCS.MiniGameType
local GoldSaucerTaskTypeCfg = require("TableCfg/GoldSaucerTaskTypeCfg")
local GoldSauserEntranceItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserEntranceItemVM")
local GoldSauserMainPanelDataWinItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelDataWinItemVM")
local GoldSauserMainPanelExplainWinVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelExplainWinVM")
local GoldSauserMainPanelTyphonGameItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelTyphonGameItemVM")
local GoldSauserMainPanelBodyguardGameItemVM  = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelBodyguardGameItemVM")
local GoldSauserChallengeNotesVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserChallengeNotesVM")
local GoldSauserMainPanelAwardWinVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelAwardWinVM")
local TimeUtil = require("Utils/TimeUtil")
local GoldSaucerCfg = require("TableCfg/GoldSaucerCfg")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local FLOG_ERROR = _G.FLOG_ERROR

local UIViewMgr

---@class GoldSauserMainPanelMainVM : UIViewModel

local GoldSauserMainPanelMainVM = LuaClass(UIViewModel)

local BtnIdforMiniGameTypeMap = 
{
    [MiniGameType.MiniGameTypeAirForceOne] = GoldSauserMainPanelDefine.GameGateSubType.AirplaneGame,
    [MiniGameType.MiniGameTypeCliffHanger] = GoldSauserMainPanelDefine.GameGateSubType.BirdGame,
    --[MiniGameType.MiniGameTypeBodyGuard] = GoldSauserMainPanelDefine.GameGateSubType.EventSquare,
    --[MiniGameType.MiniGameTypeTyphon] = GoldSauserMainPanelDefine.GameGateSubType.EventSquare,
}

---Ctor
---@param bool IsCelebration 是否是庆典时间
---@param number GoldSauserCurrencyNum 金蝶币
---@param number CactusClickedCount 仙人掌点击次数
function GoldSauserMainPanelMainVM:Ctor()
    self.GoldSauserCurrencyNum = nil
    self.CactusClickedCount = nil
    self.GamePlayItemList = nil
    self.CurrentSelectBtnID = nil
    self.MiniGameType = nil
    self.IsMiniGameStart = nil
    self.IsEventSquareCenter = nil
    self.ChallengNoteVM = nil
    self.MiniGameSuccess = nil
    self:SetNoCheckValueChange("MiniGameSuccess", true)
    self.MiniGameAirplaneSuccess = nil
    self:SetNoCheckValueChange("MiniGameAirplaneSuccess", true)
    self.IsDataItemUnlock = nil -- 趣味解锁是否已解锁
    self.IsChallengeNoteUnlock = nil -- 挑战笔记是否解锁
    self.AwardWinPanelVM = GoldSauserMainPanelAwardWinVM.New()

    -- 金碟庆典
    self.IsShowTimePanel = nil 
    self.IsInCelebration = nil
end

function GoldSauserMainPanelMainVM:OnInit()
    self.IsCelebration = false
    self.GoldSauserCurrencyNum = 0
    self.CactusClickedCount = 0
    self.CurrentSelectBtnID = 0
    self.TopCelebrationTime = ""
    self.DownCelebrationTime = ""
    self.GoldSauserMainPanelDataWinItemVM = GoldSauserMainPanelDataWinItemVM.New()
    self.GoldSauserMainPanelDataWinItemVM:OnInit()

    self.GoldSauserMainPanelExplainWinVM = GoldSauserMainPanelExplainWinVM.New()
    self.GoldSauserMainPanelExplainWinVM:OnInit()

    self.GoldSauserMainPanelTyphonGameItemVM = GoldSauserMainPanelTyphonGameItemVM.New()
    self.GoldSauserMainPanelTyphonGameItemVM:OnInit()
   
    self.GoldSauserMainPanelBodyguardGameItemVM = GoldSauserMainPanelBodyguardGameItemVM.New()
    self.GoldSauserMainPanelBodyguardGameItemVM:OnInit()

    self.IsEventSquareCenter = false

    UIViewMgr = _G.UIViewMgr

    self.ChallengNoteVM = GoldSauserChallengeNotesVM.New() 
end

--- 初始化界面各个玩法入口VM
---@param EventGameIDs table@所有玩法事件id（服务器通信用）TaskType List
---@param GameID2GameEntranceID table<number|table>@TaskType 2 EntranceID(GoldSauserGameClientType)
function GoldSauserMainPanelMainVM:InitGamePlayItemList(EventGameIDs, GameID2GameEntranceID)
    if not EventGameIDs or not next(EventGameIDs) then
        FLOG_ERROR("GoldSauserMainPanelMainVM:InitGamePlayItemList EventGameIDs is Empty")
        return
    end
    if not GameID2GameEntranceID or not next(GameID2GameEntranceID) then
        FLOG_ERROR("GoldSauserMainPanelMainVM:InitGamePlayItemList GameID2GameEntranceID is Empty")
        return
    end
    local GamePlayItemList = {}
    for _, Value in pairs(EventGameIDs) do
        local EntranceIDs = GameID2GameEntranceID[Value]
        if EntranceIDs and next(EntranceIDs) then
            for _, EntranceID in ipairs(EntranceIDs) do
                local EntranceVM = GoldSauserEntranceItemVM.New()
                EntranceVM:OnInit()
                EntranceVM:SetInfo(EntranceID, Value, GoldSauserMainPanelDefine.MainPanelItemState.Default)
                GamePlayItemList[EntranceID] = EntranceVM
            end
        end
    end
    self.GamePlayItemList = GamePlayItemList
end

function GoldSauserMainPanelMainVM:SetCurrentSelectBtnID(BtnID)
    self.CurrentSelectBtnID = BtnID
end

function GoldSauserMainPanelMainVM:GetCurrentSelectBtnID()
    return self.CurrentSelectBtnID
end

function GoldSauserMainPanelMainVM:SetIsEventSquareCenter(IsEventSquareCenter)
    self.IsEventSquareCenter = IsEventSquareCenter
end

function GoldSauserMainPanelMainVM:GetIsEventSquareCenter()
    return self.IsEventSquareCenter
end

function GoldSauserMainPanelMainVM:GetEntranceItemVMByBtnID(BtnID)
    if self.GamePlayItemList and self.GamePlayItemList[BtnID] then
        return self.GamePlayItemList[BtnID]
    end
end

function GoldSauserMainPanelMainVM:UpdatGoldSauserCurrencyNum()
    local ScoreValue = ScoreMgr:GetScoreValueByID(GoldSauserMainPanelDefine.GoldSauserCurrencyID)
    if ScoreValue then
        self.GoldSauserCurrencyNum = ScoreValue
    end
end

function GoldSauserMainPanelMainVM:UpdatGoldSauserMainPanelInfo()
    self:UpdatGoldSauserCurrencyNum()
end


function GoldSauserMainPanelMainVM:OnReset()
    if self.GamePlayItemList then
        for _, ItemVM in pairs(self.GamePlayItemList) do
            ItemVM:OnReset()
        end
    end
end

function GoldSauserMainPanelMainVM:OnBegin()
    if self.GamePlayItemList then
        for _, ItemVM in pairs(self.GamePlayItemList) do
            ItemVM:OnBegin()
        end
    end
end

function GoldSauserMainPanelMainVM:OnEnd()
    if self.GamePlayItemList then
        for _, ItemVM in pairs(self.GamePlayItemList) do
            ItemVM:OnEnd()
        end
    end
end

function GoldSauserMainPanelMainVM:OnShutdown()
    if self.GamePlayItemList then
        for _, ItemVM in pairs(self.GamePlayItemList) do
            ItemVM:OnShutdown()
        end
    end
    self.GamePlayItemList = nil
  
    self.GoldSauserMainPanelDataWinItemVM:OnShutdown()
    self.GoldSauserMainPanelDataWinItemVM = nil
    self.GoldSauserMainPanelExplainWinVM:OnShutdown()
    self.GoldSauserMainPanelExplainWinVM = nil
    self.GoldSauserMainPanelTyphonGameItemVM:OnShutdown()
    self.GoldSauserMainPanelTyphonGameItemVM = nil
    self.GoldSauserMainPanelBodyguardGameItemVM:OnShutdown()
    self.GoldSauserMainPanelBodyguardGameItemVM = nil
    self.ChallengNoteVM = nil 
end

function GoldSauserMainPanelMainVM:SetCactusClickedCount(InCount)
    self.CactusClickedCount = InCount
end

function GoldSauserMainPanelMainVM:GetCactusClickedCount()
    return self.CactusClickedCount or 0
end

function GoldSauserMainPanelMainVM:AddCactusClickedCount()
    self.CactusClickedCount = self.CactusClickedCount + 1
end

--- 通知触发小游戏
function GoldSauserMainPanelMainVM:SetGameNotify(MiniGamePanelType, Level)
    local ClientType = BtnIdforMiniGameTypeMap[MiniGamePanelType]
    if not ClientType then
        return
    end

    if MiniGamePanelType == MiniGameType.MiniGameTypeCliffHanger then
        return -- 2025.4.27 监修未过，暂时屏蔽小雏鸟游戏
    end

    local EntranceVM = self:GetEntranceItemVMByBtnID(ClientType)
    if not EntranceVM then
        return
    end
    EntranceVM:SetIsGameStart(true)
    EntranceVM:SetCurLevel(Level)
end

function GoldSauserMainPanelMainVM:SetSauserCelebrationInfo(Active, IsShowPreview, TopTimeInfo, DownTimeInfo)
    self.IsInCelebration = Active
    self.IsShowTimePanel = IsShowPreview
    self.TopCelebrationTime = TopTimeInfo
    self.DownCelebrationTime = DownTimeInfo
end
------------------------------------------------ 子页面VM start -------------------------------------------------------------------
function GoldSauserMainPanelMainVM:GetGoldSauserMainPanelDataWinItemVM()
    return self.GoldSauserMainPanelDataWinItemVM
end

function GoldSauserMainPanelMainVM:GetGoldSauserMainPanelExplainWinVM()
    return self.GoldSauserMainPanelExplainWinVM
end

function GoldSauserMainPanelMainVM:GetGoldSauserMainPanelTyphonGameItemVM()
    return self.GoldSauserMainPanelTyphonGameItemVM
end

function GoldSauserMainPanelMainVM:GetGoldSauserMainPanelBodyguardGameItemVM()
    return self.GoldSauserMainPanelBodyguardGameItemVM
end

--- 获取挑战笔记的ViewModel
function GoldSauserMainPanelMainVM:GetGoldSauserMainPanelChallengNoteVM()
    return self.ChallengNoteVM
end

function GoldSauserMainPanelMainVM:UpdateDataItemInfo(EventPool, PercentList)
    self.GoldSauserMainPanelDataWinItemVM:SetInfo(EventPool, PercentList)
end

--- 更新单一TaskType的事件数据
function GoldSauserMainPanelMainVM:UpdateEventData(Event)
    -- 金碟主界面二期规则修改
    if not Event or not next(Event) then
        return
    end

    local FirstEvtUnderTaskType = Event[1]
    local FstEvtID = FirstEvtUnderTaskType.ID
    if not FstEvtID then
        FLOG_ERROR("GoldSauserMainPanelMainVM:UpdateEventData: The Evt Have Invalid ID")
        return
    end
    local Cfg = GoldSaucerCfg:FindCfgByKey(FstEvtID)
    if not Cfg then
        return
    end

    local GameType = Cfg.GameType
    if not GameType then
        return
    end
    local TaskTypeCfg = GoldSaucerTaskTypeCfg:FindCfgByKey(GameType)
    if not TaskTypeCfg then
        return
    end

    local RewardNeedNum = TaskTypeCfg.FinishRefreshNum
    if not RewardNeedNum then
        return
    end

    local DoneNum = 0
    for _, Data in ipairs(Event) do
        local EventID = Data.ID or 0
        local Cfg = GoldSaucerCfg:FindCfgByKey(EventID)
        if Cfg then
            local Num = Data.Num or 0
            local MaxNum = Cfg.TaskNum or 0
            if Num >= MaxNum then
                DoneNum = DoneNum + 1
                break
            end
        end
    end

    local TaskType = TaskTypeCfg.TaskType
    if not TaskType then
        return
    end

    local ExplainVM = self.GoldSauserMainPanelExplainWinVM
    if not ExplainVM then
        return
    end
   
    for _, ItemVM in pairs(self.GamePlayItemList) do
        if ItemVM:GetGameType() == TaskType then
            local bEvtReward = DoneNum >= RewardNeedNum
            ItemVM:SetIsEventAward(bEvtReward)
            ItemVM:SetEventAwardRedDotVisible(bEvtReward)
        end 
    end

    if ExplainVM:GetGameType() ~= 0 then
        local ExplainViewShowItems = {}
        for _, Evt in ipairs(Event) do
            if ExplainVM:IsEventIDNeedShow(Evt.ID) then
                table.insert(ExplainViewShowItems, Evt)
            end
        end
        ExplainVM:SetEventInfo(ExplainViewShowItems, RewardNeedNum)
    end
end

function GoldSauserMainPanelMainVM:TaskCompleteToMax()
    local ExplainWinVM = self.GoldSauserMainPanelExplainWinVM
    if ExplainWinVM then
        ExplainWinVM:SetTaskCompleteMax(true)
        for _, ItemVM in pairs(self.GamePlayItemList) do
            ItemVM:SetIsEventAward(false)
            ItemVM:SetEventAwardRedDotVisible(false)
        end
    end
end

--- 设定玩法侧边栏基础信息（不依赖服务器下发内容）
function GoldSauserMainPanelMainVM:SetExplainWinInfo(BtnID, TaskType, Param)
    local GoldSauserMainPanelExplainWinVM = self.GoldSauserMainPanelExplainWinVM
    if not GoldSauserMainPanelExplainWinVM then
        return
    end
    GoldSauserMainPanelExplainWinVM:SetInfo(BtnID, TaskType)
    GoldSauserMainPanelExplainWinVM:SetGameLockState(Param)
end

--- 设定玩法侧边栏辅助信息（可能依赖服务器下发内容）
function GoldSauserMainPanelMainVM:SetAssistPanelInfo(RoundStr, ScoreStr)
    local GoldSauserMainPanelExplainWinVM = self.GoldSauserMainPanelExplainWinVM
    if not GoldSauserMainPanelExplainWinVM then
        return
    end
    GoldSauserMainPanelExplainWinVM:SetAssistPanelInfo(RoundStr, ScoreStr)
end

--- 设定玩法底部提示信息（可能依赖服务器下发内容）
function GoldSauserMainPanelMainVM:SetHintContent(HintText, bAwardToGet, IconTobeViewVisible)
    local GoldSauserMainPanelExplainWinVM = self.GoldSauserMainPanelExplainWinVM
    if not GoldSauserMainPanelExplainWinVM then
        return
    end
    GoldSauserMainPanelExplainWinVM:SetHintContent(HintText, bAwardToGet, IconTobeViewVisible)
end

--- 设定玩法时限信息（可能依赖服务器下发内容）
---@param EndStamp number @毫秒
function GoldSauserMainPanelMainVM:SetTimeLimitContent(EndStamp)
    local GoldSauserMainPanelExplainWinVM = self.GoldSauserMainPanelExplainWinVM
    if not GoldSauserMainPanelExplainWinVM then
        return
    end
    GoldSauserMainPanelExplainWinVM:SetTimeLimitEndTimeStamp(EndStamp)
end

------------------------------------------------ 子页面VM end -------------------------------------------------------------------

return GoldSauserMainPanelMainVM
