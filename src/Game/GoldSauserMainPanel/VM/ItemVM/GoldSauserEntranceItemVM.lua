---
--- Author: star
--- DateTime: 2024-01-03 10:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local RedDotBaseName = GoldSauserMainPanelDefine.RedDotBaseName
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local GoldSauserMainPanelBombItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelBombItemVM")
local GoldSaucerBirdGameCfg = require("TableCfg/GoldSaucerBirdGameCfg")
local GoldSaucerAirplaneGameCfg = require("TableCfg/GoldSaucerAirplaneGameCfg")
local CSMiniGameType = ProtoCS.MiniGameType
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local BirdBombState = GoldSauserMainPanelDefine.BirdBombState
local BirdGameBombCapacity = GoldSauserMainPanelDefine.BirdGameBombCapacity
local RandomStartLevel = GoldSauserMainPanelDefine.RandomStartLevel
local RandomNeedRoundNum = GoldSauserMainPanelDefine.RandomNeedRoundNum

local FLOG_INFO = _G.FLOG_INFO

---@class GoldSauserEntranceItemVM : UIViewModel

local GoldSauserEntranceItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSauserEntranceItemVM:Ctor()
    self.BtnID = nil
    self.GameType = nil
    self.State = nil
    self.IsGameStart = nil
    self.IsHighlight = nil
    self.IsEventAward = nil -- 金碟主界面入口玩法事件是否可以领奖
    self.IsGameNoFinish = nil -- 金碟主界面入口玩法是否在可参加时间内
    self.IsGameAward = nil -- 金碟主界面入口玩法是否有奖励领取
    self.IsEntranceLocked = nil
    self.RedDotName = nil
    self.EventAwardRedDotVisible = nil -- 事件奖励领取
end

function GoldSauserEntranceItemVM:OnInit()
    self.BtnID = nil
    self.GameType = 0 -- 对应配表的TaskType字段
    self.State = GoldSauserMainPanelDefine.MainPanelItemState.Default
    
    self.IsHighlight = false
    self.IsEventAward = false
    self:SetNoCheckValueChange("IsEventAward", true)
    self.EventAwardRedDotVisible = false -- 事件奖励领取
    self.IsGameNoFinish = false
    self.IsGameAward = false
    self.IsEntranceLocked = false
  
    -- 二期内容小游戏
    self.MiniGameType = CSMiniGameType.MiniGameTypeNone
    self.CurLevel = 1 -- 默认从第一个关卡开始
    self.IsGameStart = false
    self.RandomRoundIDList = nil -- 终关随机关卡ID列表
end

--- 实际初始化接口（开辟具体的空间）
function GoldSauserEntranceItemVM:SetInfo(InBtnId, InGameType, InState)
    self.BtnID = InBtnId
    self.GameType = InGameType
    self.State = InState
    self.RedDotName = string.format("%s/%s", RedDotBaseName, InBtnId)
    self:BindTheMiniGameType()
    self:CreateMiniGameVariable()
end

------ 小游戏部分 ------
function GoldSauserEntranceItemVM:BindTheMiniGameType()
    local ClientType = self.BtnID
    if not ClientType then
        return
    end

    if ClientType == GoldSauserGameClientType.GoldSauserGameTypeGateCircle then
        self.MiniGameType = CSMiniGameType.MiniGameTypeAirForceOne
    elseif ClientType == GoldSauserGameClientType.GoldSauserGameTypeGateMagic then
        self.MiniGameType = CSMiniGameType.MiniGameTypeCliffHanger
    end
end

function GoldSauserEntranceItemVM:CreateMiniGameVariable()
    local MiniGameType = self.MiniGameType
    if not MiniGameType then
        return
    end

    if CSMiniGameType.MiniGameTypeCliffHanger == MiniGameType then
        --self.BombListVMs = UIBindableList.New(GoldSauserMainPanelBombItemVM)
        self:CreateBirdGameBombListViewModel()
        self.BombRound = 1
        self.RoundCounter = nil
        self.BombCreatedPosList = {} -- 炸弹生成的序号列表
        self.BombRedRemainNum = 0 -- 变红炸弹剩余数量
        self.GameResult = nil -- 游戏结果
        self:SetNoCheckValueChange("GameResult", true)
        self.IsRoundEnding = false -- 是否处于轮次结算中
        self.SingleRoundStep = 0 -- 单轮中炸弹变红的步骤
        self.DisableClickBombByGameSettle = false -- 结算表现后禁止点击炸弹
    end
end

function GoldSauserEntranceItemVM:SetIsGameStart(InIsStart)
    self.IsGameStart = InIsStart
end

function GoldSauserEntranceItemVM:GetIsGameStart()
    return self.IsGameStart
end

function GoldSauserEntranceItemVM:SetCurLevel(Level)
    self.CurLevel = Level
    self:ConstructRandomLevelRoundCfgs(Level)
end

function GoldSauserEntranceItemVM:ConstructRandomLevelRoundCfgs(Level)
    if not Level or Level < RandomStartLevel then
        return
    end
    local RltList = {}
    local SrcCfgs
    local MiniGameType = self.MiniGameType
    local DstIDs = {}
    if CSMiniGameType.MiniGameTypeAirForceOne == MiniGameType then
        SrcCfgs = GoldSaucerAirplaneGameCfg:FindAllCfg(string.format("Level = %d", Level))
        for _, Cfg in ipairs(SrcCfgs) do
            local ID = Cfg.ID
            if ID then
               table.insert(DstIDs, ID)
            end
        end
    elseif CSMiniGameType.MiniGameTypeCliffHanger == MiniGameType then
        SrcCfgs = GoldSaucerBirdGameCfg:FindAllCfg(string.format("Level = %d", Level))
        for _, Cfg in ipairs(SrcCfgs) do
            local ID = Cfg.ID
            if ID then
               table.insert(DstIDs, ID)
            end
        end
    end
    table.shuffle(DstIDs)
    for Index = 1, RandomNeedRoundNum do
        local ID = DstIDs[Index]
        if ID then
            table.insert(RltList, ID)
        else
            break
        end
    end
    table.sort(RltList)
    self.RandomRoundIDList = RltList
end

function GoldSauserEntranceItemVM:GetRoundTableCfg(Round)
    local CurLevel = self.CurLevel
    if not Round or not CurLevel then
        return
    end
    local MiniGameType = self.MiniGameType
    if not MiniGameType or MiniGameType == CSMiniGameType.MiniGameTypeNone then
        return
    end

    if CurLevel < RandomStartLevel then
        if MiniGameType == CSMiniGameType.MiniGameTypeAirForceOne then
            return GoldSaucerAirplaneGameCfg:FindCfg(string.format("Level = %d AND Round = %d", CurLevel, Round))
        elseif CSMiniGameType.MiniGameTypeCliffHanger == MiniGameType then
            return GoldSaucerBirdGameCfg:FindCfg(string.format("Level = %d AND Round = %d", CurLevel, Round))
        end
    else
        local RandomRoundIDList = self.RandomRoundIDList
        if not RandomRoundIDList or not next(RandomRoundIDList) then
            return
        end
        local CfgKey = RandomRoundIDList[Round]
        if not CfgKey then
            return
        end
        if MiniGameType == CSMiniGameType.MiniGameTypeAirForceOne then
            return GoldSaucerAirplaneGameCfg:FindCfgByKey(CfgKey)
        elseif CSMiniGameType.MiniGameTypeCliffHanger == MiniGameType then
            return GoldSaucerBirdGameCfg:FindCfgByKey(CfgKey)
        end
    end
end


function GoldSauserEntranceItemVM:GetCurLevel()
    return self.CurLevel
end

function GoldSauserEntranceItemVM:GetDisableClickBombByGameSettle()
    return self.DisableClickBombByGameSettle
end

------ 拯救雏鸟使用接口 ------
--- 创建炸弹VM
function GoldSauserEntranceItemVM:CreateBirdGameBombListViewModel()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end

    local BombListVMs = {}
    local ExistLen = #BombListVMs or 0
    if ExistLen < BirdGameBombCapacity then
        for Index = 1, BirdGameBombCapacity do
            local BombItemVM = GoldSauserMainPanelBombItemVM.New()
            BombItemVM:UpdateVM({
                Index = Index,
                State = BirdBombState.Default
            })
            table.insert(BombListVMs, BombItemVM)
        end
        self.BombListVMs = BombListVMs
    end
end

--- 创建炸弹VM
function GoldSauserEntranceItemVM:DestoryBirdGameBombListViewModel()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end

    local BombListVMs = self.BombListVMs
    if not BombListVMs then
        return
    end

    self.BombListVMs = nil
end

--- 清除炸弹状态
function GoldSauserEntranceItemVM:ClearBombListViewModel()
    local BombListVMs = self.BombListVMs
    if not BombListVMs then
        return
    end
   
    for Index = 1, BirdGameBombCapacity do
        local BombItemVM = BombListVMs[Index]
        if BombItemVM then
            BombItemVM:SetTheBombState(BirdBombState.Default) -- 清除所有炸弹的状态
        end
    end
end

--- 初始化炸弹分布棋盘
function GoldSauserEntranceItemVM:InitBirdGameBombList()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end
    self:ClearBombListViewModel()
    self.BombRound = 1
    self.RoundCounter = 0
end

function GoldSauserEntranceItemVM:ChooseCreatedBombsIdxList(BombNeedCreate)
    local BombPosToPickRemain = {}
    for Index = 1, BirdGameBombCapacity do
        table.insert(BombPosToPickRemain, Index)
    end

    local BombToCreateIdxList = {}
    --[[local function RemovePosIndexWithCross(Index)
        table.remove_item(BombPosToPickRemain, Index)
        local LeftPos = Index - 1
        if LeftPos >= 1 then
            table.remove_item(BombPosToPickRemain, LeftPos)
        end

        local RightPos = Index + 1
        if RightPos <= BirdGameBombCapacity then
            table.remove_item(BombPosToPickRemain, RightPos)
        end

        local UpPos = Index - 4
        if UpPos >= 1 then
            table.remove_item(BombPosToPickRemain, UpPos)
        end

        local DownPos = Index + 4
        if DownPos <= BirdGameBombCapacity then
            table.remove_item(BombPosToPickRemain, DownPos)
        end
    end
    while (BombNeedCreate > 0) do
        math.randomseed(os.time())
        local RandomMax = table.length(BombPosToPickRemain)
        local RandomIndex = math.random(1, RandomMax)
        local BombIndex = BombPosToPickRemain[RandomIndex]
        table.insert(BombToCreateIdxList, BombIndex)
        RemovePosIndexWithCross(BombIndex)
        BombNeedCreate = BombNeedCreate - 1
    end--]]
    table.shuffle(BombPosToPickRemain)
    for Index = 1, BombNeedCreate do
        local Idx = BombPosToPickRemain[Index]
        if Idx then
            table.insert(BombToCreateIdxList, Idx)
        end
    end
    return BombToCreateIdxList
end

function GoldSauserEntranceItemVM:CreateBirdGameBombs()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end

    local Round = self.BombRound or 1
    local BirdCfg = self:GetRoundTableCfg(Round)
    if not BirdCfg then
        return
    end
    
    local BombListVMs = self.BombListVMs
    if not BombListVMs then
        return
    end

    self:ClearBombListViewModel()

    local BombNeedCreate = BirdCfg.BombCreateNum or 0
    if BombNeedCreate <= 0 then
        return
    end

    local BombToCreateIdxList = self:ChooseCreatedBombsIdxList(BombNeedCreate)
    if not BombToCreateIdxList or not next(BombToCreateIdxList) then
        return
    end

    self.BombCreatedPosList = BombToCreateIdxList
    self.BombRedRemainNum = 0

    -- 计算炸弹变红需要进行的阶段数
    local BombTurnRedNum = BirdCfg.BombTurnRedNum or 0
    local BombNeedCleanNum = BirdCfg.BombNeedCleanNum or 0
    self.SingleRoundStep = math.ceil(BombNeedCleanNum / BombTurnRedNum)

    for _, PosIndex in ipairs(BombToCreateIdxList) do
        local BombItemVM = BombListVMs[PosIndex]
        if BombItemVM then
            BombItemVM:SetTheBombState(BirdBombState.Created)
        end
    end
end

function GoldSauserEntranceItemVM:NotifyBirdGameBombsTurnRed()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end

    local Round = self.BombRound or 1
    local BirdCfg = self:GetRoundTableCfg(Round)
    if not BirdCfg then
        return
    end
    
    local BombListVMs = self.BombListVMs
    if not BombListVMs then
        return
    end
    
    local BombNeedTurn = BirdCfg.BombTurnRedNum or 0
    if BombNeedTurn <= 0 then
        return
    end
    --self.BombRedRemainNum = BombNeedTurn
    local BombCreatedPosList = self.BombCreatedPosList
    if not BombCreatedPosList or not next(BombCreatedPosList) then
        return
    end

    --table.shuffle(BombCreatedPosList)
 
    for _ = BombNeedTurn, 1, -1 do
        local PosIndex = BombCreatedPosList[#BombCreatedPosList]
        if PosIndex then
            local BombItemVM = BombListVMs[PosIndex]
            if BombItemVM then
                local BombState = BombItemVM:GetTheBombState()
                if BirdBombState.Created == BombState then
                    BombItemVM:SetTheBombState(BirdBombState.TurnToRed)
                    FLOG_INFO("BirdBomb: VM TurnRed %d", PosIndex)
                    self.BombRedRemainNum = self.BombRedRemainNum + 1
                end
            end
            BombCreatedPosList[#BombCreatedPosList] = nil
        end
    end
end

function GoldSauserEntranceItemVM:NotifyRedBirdGameBombsExplode()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end
    
    local BombListVMs = self.BombListVMs
    if not BombListVMs then
        return
    end
    
    for Index = 1, #BombListVMs do
        local BombItemVM = BombListVMs[Index]
        if BombItemVM then
            local BombState = BombItemVM:GetTheBombState()
            if BirdBombState.TurnToRed == BombState then
                BombItemVM:SetTheBombState(BirdBombState.Exploded)
            else
                BombItemVM:SetTheBombState(BirdBombState.Default)
            end
        end       
    end
    self.DisableClickBombByGameSettle = false
end

--- 将未变红的炸弹取消显示
function GoldSauserEntranceItemVM:ChangeTheBombCreatedToDefault()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end
    
    local BombListVMs = self.BombListVMs
    if not BombListVMs then
        return
    end
    
    for Index = 1, #BombListVMs do
        local BombItemVM = BombListVMs[Index]
        if BombItemVM then
            local BombState = BombItemVM:GetTheBombState()
            if BirdBombState.Created == BombState then
                BombItemVM:SetTheBombState(BirdBombState.Default)
            end
        end       
    end
    self.DisableClickBombByGameSettle = false
end

function GoldSauserEntranceItemVM:CleanRedBirdGameBomb(BombIndex)
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end
    
    local BombListVMs = self.BombListVMs
    if not BombListVMs then
        return
    end
    local BombItemVM = BombListVMs[BombIndex]
    if BombItemVM then
        local BombState = BombItemVM:GetTheBombState()
        if BirdBombState.TurnToRed == BombState then
            self.BombRedRemainNum = self.BombRedRemainNum - 1
            BombItemVM:SetTheBombState(BirdBombState.Cleared)
        end
    end
    if self.BombRedRemainNum <= 0 then
        self:CheckTheStepResult()
        --print("CheckTheStepResult CleanRedBirdGameBomb", TimeUtil.GetLocalTimeMS())
    end--]]
end

function GoldSauserEntranceItemVM:CheckTheStepResult()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end

    local SingleRoundStep = self.SingleRoundStep or 0
    if SingleRoundStep == 0 then
        return
    end
   
    local BombRedRemainNum = self.BombRedRemainNum or 0
    if BombRedRemainNum > 0 then
        self:SetGameResult(false)
    else
        if SingleRoundStep == 1 then
            local CurBombRound = self.BombRound or 1
            local NextRoundCfg = self:GetRoundTableCfg(CurBombRound + 1)
            if not NextRoundCfg then
                self:SetGameResult(true)
            else
                self.BombRound = CurBombRound + 1
                self:AddRoundCounter()
                self.SingleRoundStep = 0
            end
        else
            self.SingleRoundStep = SingleRoundStep - 1
        end  
    end
end

function GoldSauserEntranceItemVM:SetGameResult(bSuccess)
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end
    
    local OldGameResult = self.GameResult
    if bSuccess ~= nil and OldGameResult ~= bSuccess then
        self.DisableClickBombByGameSettle = true
    end

    self.GameResult = bSuccess
    self.RoundCounter = 0
    self.SingleRoundStep = 0
end

function GoldSauserEntranceItemVM:AddRoundCounter()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end
    
    self.RoundCounter = self.RoundCounter + 1
end

function GoldSauserEntranceItemVM:GetRedToExplodeTime()
    if self.MiniGameType ~= CSMiniGameType.MiniGameTypeCliffHanger then
        return
    end
    local CurBombRound = self.BombRound or 1
    local RoundCfg = self:GetRoundTableCfg(CurBombRound)
    if not RoundCfg then
        return
    end

    return RoundCfg.RedToExplodeTime
end

------ 拯救雏鸟使用接口 end ------

------ 小游戏部分 end ------

function GoldSauserEntranceItemVM:SetState(InState)
    self.State = InState
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   

function GoldSauserEntranceItemVM:GetState()
    return self.State
end

function GoldSauserEntranceItemVM:GetBtnID()
    return self.BtnID
end

function GoldSauserEntranceItemVM:GetGameType()
    return self.GameType
end

function GoldSauserEntranceItemVM:SetIsHighlight(IsHighlight)
    self.IsHighlight = IsHighlight
end

function GoldSauserEntranceItemVM:GetIsHighlight()
    return self.IsHighlight
end

function GoldSauserEntranceItemVM:SetEventAwardRedDotVisible(bVisible)
    self.EventAwardRedDotVisible = bVisible
end

function GoldSauserEntranceItemVM:SetIsEventAward(IsEventAward)
    self.IsEventAward = IsEventAward
end

function GoldSauserEntranceItemVM:GetIsEventAward()
    return self.IsEventAward
end

function GoldSauserEntranceItemVM:SetIsGameNoFinish(IsGameNoFinish)
    self.IsGameNoFinish = IsGameNoFinish
end

function GoldSauserEntranceItemVM:GetIsGameNoFinish()
    return self.IsGameNoFinish
end

function GoldSauserEntranceItemVM:SetIsGameAward(IsGameAward)
    self.IsGameAward = IsGameAward
end

function GoldSauserEntranceItemVM:GetIsGameAward()
    return self.IsGameAward
end

function GoldSauserEntranceItemVM:OnReset()

end

function GoldSauserEntranceItemVM:OnBegin()

end

function GoldSauserEntranceItemVM:OnEnd()

end

function GoldSauserEntranceItemVM:OnShutdown()

end

return GoldSauserEntranceItemVM
