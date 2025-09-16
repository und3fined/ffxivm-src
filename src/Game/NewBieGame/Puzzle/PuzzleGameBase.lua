--[[
Author: lightpaw_Leo
Date: 2024-07-30 19:02:12
Description: 
--]]
local LuaClass = require("Core/LuaClass")
local PuzzleBurritosDefine = require("Game/NewBieGame/Puzzle/PuzzleBurritos/PuzzleBurritosDefine")
local UIUtil = require("Utils/UIUtil")
local PuzzleDefine = require("Game/NewBieGame/Puzzle/PuzzleDefine")
local PuzzleBurritosVM = require("Game/NewBieGame/Puzzle/PuzzleBurritos/PuzzleBurritosVM")
local DataReportUtil = require("Utils/DataReportUtil")
local TimeUtil = require("Utils/TimeUtil")
local AudioUtil = require("Utils/AudioUtil")
local PuzzleDirectoryCfg = require("TableCfg/PuzzleDirectoryCfg")
local UIViewMgr = _G.UIViewMgr
local UIViewID = require("Define/UIViewID")
local UE = _G.UE
local PuzzleGameBase = LuaClass()

function PuzzleGameBase:Ctor()
    self.GameCfg = nil
    self.FinishNum = 0
    self.CountTimer = nil
    self.RemainTime = 0
    self.PuzzleMainPanel = nil
    self.NoRightOpTime = 0 -- 没有正确操作累计时间
    self.bIsDraging = false
    self.bSuccess = false
    self.bAutoPuzzleInEnd = false
    self.bInAutoMove = false
    self.ShowTipItemID = nil
    self.TimerCollects = {}
    self.EndTimeStamp = 0 -- 游戏结束的时间戳
end

function PuzzleGameBase:OnEnd()
    self.GameCfg = nil
    self.FinishNum = 0
    self.RemainTime = 0
    self.PuzzleMainPanel = nil
    self.NoRightOpTime = 0
    self.bIsDraging = false
    self.bSuccess = false
    self.bAutoPuzzleInEnd = false
    self.bInAutoMove = false
    self.ShowTipItemID = nil
    self.PuzzleItemIDTable = nil
    self.EndTimeStamp = 0 -- 游戏结束的时间戳
    local TimerCollects = self.TimerCollects
    for _, v in pairs(TimerCollects) do
        local TimerHandle = v
        _G.TimerMgr:CancelTimer(TimerHandle)
    end
    self.TimerCollects = {}
end

function PuzzleGameBase:GetMainViewID()
end

function PuzzleGameBase:OnGetDefaultSize()
    return UE.FVector2D(404, 404)
end

function PuzzleGameBase:InitPuzzleGame(GameID, InGameTime)
    local UIViewID = self:GetMainViewID()

    local GameCfg = PuzzleDirectoryCfg:FindCfgByKey(GameID)
    if GameCfg == nil then
        _G.FLOG_ERROR("Puzzle gamecfg is nil. GameID = %s", GameID)
        return
    end
    self:InitGameTime(GameCfg, InGameTime)
    self.GameCfg = table.deepcopy(GameCfg)

    self:HideQuestInfoTips()

    do
        -- 所有的可移动目标，显示
        self.ValidMoveItemIDTable = self:OnGetMoveItemIDTable()

        if (self.ValidMoveItemIDTable ~= nil) then
            for Key, Value in pairs (self.ValidMoveItemIDTable) do
                PuzzleBurritosVM:SetMoveBreadVisible(Value, true)
            end
        else
            _G.FLOG_ERROR("PuzzleGameBase 游戏初始化出错 , ValidMoveItemIDTable 为空 ，请检查")
            return
        end
    end

    do
        -- 隐藏所有的摆放目标
        self.ValidDestItemIDTable = self:OnGetDestItemIDTable()
        if (self.ValidDestItemIDTable ~= nil) then
            for Key, Value in pairs (self.ValidDestItemIDTable) do
                PuzzleBurritosVM:SetYesBreadVisible(Value, false)
            end
        else
            _G.FLOG_ERROR("PuzzleGameBase 游戏初始化出错 , ValidDestItemIDTable 为空 ，请检查")
            return
        end
    end

    UIViewMgr:ShowView(UIViewID, self.GameCfg)
end

-- 移动物品的ID列表，子类覆写提供
function PuzzleGameBase:OnGetMoveItemIDTable()
    return nil
end

-- 摆放目标区域ID列表，子类覆写提供
function PuzzleGameBase:OnGetDestItemIDTable()
    return nil
end

function PuzzleGameBase:UpdateShadowVisible(InNum)
end

function PuzzleGameBase:GetOneNotFinishPuzzleItemID()
    if (self.ValidDestItemIDTable == nil) then
        return nil
    end
    for Key, Value in pairs (self.ValidDestItemIDTable) do
        return Value
    end
end

function PuzzleGameBase:HideQuestInfoTips()
    if UIViewMgr:IsViewVisible(UIViewID.QuestInfoTips) then
        UIViewMgr:HideView(UIViewID.QuestInfoTips)
    end
end

--- @type 是否处于游戏结束最终的自动拼装过程
function PuzzleGameBase:SetbAutoPuzzleInEnd(bAutoPuzzle)
    self.bAutoPuzzleInEnd = bAutoPuzzle
end

function PuzzleGameBase:GetbAutoPuzzleInEnd()
    return self.bAutoPuzzleInEnd
end

--- @type 是否处于自动移动过程中_非结束的自动拼装
function PuzzleGameBase:SetbAutoMove(bAutoMove)
    self.bInAutoMove = bAutoMove
end

function PuzzleGameBase:GetbAutoMove()
    return self.bInAutoMove
end

function PuzzleGameBase:SetShowTipItemID(ID)
    self.ShowTipItemID = ID
end

function PuzzleGameBase:GetShowTipItemID()
    return self.ShowTipItemID
end

function PuzzleGameBase:ResetShowTipItemID()
    self.ShowTipItemID = nil
end

function PuzzleGameBase:SetMainView(MainPanel)
    self.PuzzleMainPanel = MainPanel
end

--- @type 设置零散区拼图大小位置以及角度
function PuzzleGameBase:SetPuzzleItemPosAngleAndSize(PuzzleItem, Cfg)
    local ToCopyImg = self.PuzzleMainPanel[string.format("ImgYesBread%02d", Cfg.ID)]
    local NeedSize
    if not ToCopyImg then
        NeedSize = self:OnGetDefaultSize()
    else
        NeedSize = UIUtil.GetWidgetSize(ToCopyImg)
    end
    UIUtil.CanvasSlotSetSize(PuzzleItem, NeedSize)
    PuzzleItem:SetSize(NeedSize)

    local InitLocation = UE.FVector2D(Cfg.InitLocation[1], Cfg.InitLocation[2])
    UIUtil.CanvasSlotSetPosition(PuzzleItem, InitLocation)
    PuzzleItem:SetRenderTransformAngle(Cfg.Angle)
    return InitLocation
end

--- @type 当完成一块拼图
function PuzzleGameBase:OnFinishOnePuzzleItem(PuzzleItemID, MoveOp)
    -- if not self:IsTimeOut() then // 到时间后最后一次机会也算成功
    if MoveOp ~= PuzzleDefine.MoveToTargetOp.ByTimeOutAutoMove then
        self:AddFinishNum()
    end
    -- end

    if (self.PuzzleMainPanel ~= nil and self.PuzzleMainPanel:IsValid()) then
        self.PuzzleMainPanel:EndHelpTip()
    end

    PuzzleBurritosVM:SetYesBreadVisible(PuzzleItemID, true)
    self:ResetNoRightOpTime()
    self:CheckIsSuccess()

    if (self.ValidDestItemIDTable ~= nil) then
        for Key, Value in pairs(self.ValidDestItemIDTable) do
            if (Value == PuzzleItemID) then
                self.ValidDestItemIDTable[Key] = nil
                break
            end
        end
    end
end

--- @type 检测是否成功
function PuzzleGameBase:CheckIsSuccess()
    if self:bIsSuccess() and self.PuzzleMainPanel ~= nil then
        self.PuzzleMainPanel:OnFinish(false)
    end
end

function PuzzleGameBase:AddFinishNum()
    self.FinishNum = self.FinishNum + 1
    self.bSuccess = self.FinishNum >= self:OnGetDestCount()
    FLOG_WARNING("Already FinishNum = %d", self.FinishNum)
end

function PuzzleGameBase:OnGetDestCount()
    -- 子类覆写这个，否则会报错
end

--- @type 获取是否已经成功
function PuzzleGameBase:bIsSuccess()
    return self.bSuccess
end

--- @type 最后玩家还在拼图 则时间到了不结束  等玩家最后的操作结束再检查是否需要自动拼图
function PuzzleGameBase:ReCheckIsFinish(InbNotForceCancelDrag)
    if not self.bSuccess and self.RemainTime <= 0 and self.PuzzleMainPanel ~= nil then
        self.PuzzleMainPanel:OnTimeOut(InbNotForceCancelDrag)
    end
end

--- @type 设置可移动img显隐
function PuzzleGameBase:SetMoveBreadVisible(ID, bVisible)
    PuzzleBurritosVM:SetMoveBreadVisible(ID, bVisible)
end

--- @type 设置正确位置img显隐
function PuzzleGameBase:SetYesBreadVisible(ID, bVisible)
    PuzzleBurritosVM:SetYesBreadVisible(ID, bVisible)
end

--- @type 初始化剩余时间文本
function PuzzleGameBase:InitGameTime(GameCfg, InGameTime)
    local RemainTime = 40
    if (GameCfg == nil) then
        _G.FLOG_ERROR("PuzzleGameBase:InitGameTime 出错，传入的 GameCfg 为空，将使用默认时间 40，请检查")
    end

    if (InGameTime ~= nil and InGameTime > 0) then
        self.RemainTime = InGameTime
    else
        self.RemainTime = RemainTime
    end

    local NeedText = LocalizationUtil.GetTimerForHighPrecision(self.RemainTime)

    PuzzleBurritosVM:SetTimeText(NeedText)
end

--- @type 时间开始倒计时
function PuzzleGameBase:BeginCountDown()
    local GameCfg = self.GameCfg
    local Interval = 1
    self.EndTimeStamp = TimeUtil.GetServerTime() + self.RemainTime
    local function CountDown()
        local RemainTime = self.EndTimeStamp - TimeUtil.GetServerTime()
        local NeedText = LocalizationUtil.GetTimerForHighPrecision(RemainTime)
        PuzzleBurritosVM:SetTimeText(NeedText)        

        if GameCfg.bNeedPartRangeTip == 1 and not self.bIsDraging and not self:IsTimeOut() then
            self.NoRightOpTime = self.NoRightOpTime + Interval
            if self.NoRightOpTime >= GameCfg.TipWaitTime then
                self.PuzzleMainPanel:ShowHelpTip()
                self:ResetNoRightOpTime()
            end
        end

        self.RemainTime = RemainTime
        if RemainTime < 0 and self.CountTimer ~= nil then
            PuzzleMgr:TimeOut()
            self:StopCountDown()
            self:OnTimeRunOut()
        end
    end
    self.CountTimer = _G.TimerMgr:AddTimer(self, CountDown, 0, Interval, 0)
    table.insert(self.TimerCollects, self.CountTimer)
end

function PuzzleGameBase:StopCountDown()
    if self.CountTimer ~= nil then
        _G.TimerMgr:CancelTimer(self.CountTimer)
        self.CountTimer = nil
    end
end

function PuzzleGameBase:OnTimeRunOut()
    local NeedText = LocalizationUtil.GetTimerForHighPrecision(0)
    PuzzleBurritosVM:SetTimeText(NeedText)
    if not self.bIsDraging and not self:GetbAutoMove() then
        self.PuzzleMainPanel:OnTimeOut()
    end
end

function PuzzleGameBase:IsTimeOut()
    return tonumber(self.RemainTime) <= 0
end

function PuzzleGameBase:SetIsDraging(bIsDraging)
    self.bIsDraging = bIsDraging
end

--- @type 是否在剪影范围
function PuzzleGameBase:bIsPuzzleRange(Pos)
end

--- @type 重置出现Tip的时间
function PuzzleGameBase:ResetNoRightOpTime()
    self.NoRightOpTime = 0
end

--- @type 自动移动到目标位置
function PuzzleGameBase:AutoMoveToTargetLoc(PuzzleItem, TargetPos, bSuccess, MoveOp)
    self:ResetNoRightOpTime()

    local TargetPos = bSuccess and PuzzleItem.FinishLocation or TargetPos
    PuzzleItem:PlayAnimPuzzleRestore(TargetPos.X, TargetPos.Y, PuzzleItem.Angle, bSuccess)

    local TmpTimer = _G.TimerMgr:AddTimer(
        self,
        function()
            self:OnMoveToTarget(PuzzleItem, bSuccess, MoveOp)
        end,
        PuzzleItem:GetAnimPuzzleRestoreTime() + 0.25
    )
    table.insert(self.TimerCollects, TmpTimer)
end

--- @type 当移动到目标位置
--- @param MoveToTargetOp 通过什么操作把拼图碎片移动到了目标位置
function PuzzleGameBase:OnMoveToTarget(PuzzleItem, bSuccess, MoveOp)
    local PuzzleMainPanel = self.PuzzleMainPanel
    self:ResetNoRightOpTime()
    local MoveToTargetOp = PuzzleDefine.MoveToTargetOp
    if bSuccess then
        local WaitTime = 0.2
        if MoveOp == MoveToTargetOp.ByDrag then
            WaitTime = 1
            PuzzleItem:PlayAnimPuzzleRestore(
                PuzzleItem.FinishLocation.X,
                PuzzleItem.FinishLocation.Y,
                PuzzleItem.Angle,
                MoveOp == MoveToTargetOp.ByDrag
            )
        end
        local function OnRotateFinish()
            self:OnFinishOnePuzzleItem(PuzzleItem.ID, MoveOp)
            if MoveOp ~= MoveToTargetOp.ByTimeOutAutoMove then
                self:ReCheckIsFinish()
                AudioUtil.LoadAndPlayUISound(self:GetCorrectAutioPath())
            else
                AudioUtil.LoadAndPlayUISound(PuzzleDefine.BurritoAudioPath.AutoFinish)
            end
            UIUtil.SetIsVisible(PuzzleItem, false)
            PuzzleMainPanel:OnCheckPuzzleItemFinish(bSuccess)
            PuzzleMainPanel:PlayAnimation(PuzzleMainPanel[string.format("AnimCorrect%d", PuzzleItem.ID)])
            self:SetbAutoMove(false)
        end
        local Tmp2 = _G.TimerMgr:AddTimer(self, OnRotateFinish, WaitTime)
        table.insert(self.TimerCollects, Tmp2)
    else
        -- 校验不成功回到初始位置
        UIUtil.CanvasSlotSetPosition(PuzzleItem, PuzzleItem.InitLocation)
        -- self:Reset
        PuzzleMainPanel:OnCheckPuzzleItemFinish(bSuccess)
        PuzzleMainPanel:ResetSelectBread(false)
        self:SetbAutoMove(false)
        if MoveOp ~= MoveToTargetOp.ByTimeOutAutoMove then
            self:ReCheckIsFinish()
        end
    end
end

--- @type 游戏结束
function PuzzleGameBase:GameEnd(EndType)
    local NeedTime = tonumber(self.RemainTime) > 0 and tonumber(self.RemainTime) or 0
    local UseTime = self.GameCfg.Time - NeedTime
    DataReportUtil.ReportGunbreakerFlowData(UseTime, self.GameCfg.ID, EndType)
    self:OnEnd()
end

function PuzzleGameBase:GetCorrectAutioPath()

end

return PuzzleGameBase
