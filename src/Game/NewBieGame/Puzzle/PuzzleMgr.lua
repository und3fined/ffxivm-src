--[[
Author: lightpaw_Leo
Date: 2024-07-30 19:02:12
Description: 剪影拼装全局Mgr
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local PuzzleDefine = require("Game/NewBieGame/Puzzle/PuzzleDefine")
local PuzzleBurritosGameInst = require("Game/NewBieGame/Puzzle/PuzzleBurritos/PuzzleBurritosGameInst")
local PuzzlePenguinJigsawGameIns = require("Game/NewBieGame/Puzzle/PuzzleBurritos/PuzzlePenguinJigsawGameIns")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local EventMgr = require("Event/EventMgr")

local GameID = PuzzleDefine.GameID
local PuzzleMgr = LuaClass(MgrBase)

function PuzzleMgr:OnInit()
    self.PuzzleGameInst = nil
    self.bIsDebug = false
    self.LeaveMapID = nil
    self.IsPuzzling = false
    self.CurGameID = nil
    self.GameStarted = false
    self.bTimeOut = false
    self.IsNeedRecoverGame = false -- 是否需要重新进入游戏
end

function PuzzleMgr:GetIsTimeOut()
    return self.bTimeOut
end

function PuzzleMgr:OnBegin()
end

function PuzzleMgr:OnEnd()
    self:GameEnd(PuzzleDefine.EndType.TimeOutEnd)
end

function PuzzleMgr:OnShutdown()
end

function PuzzleMgr:OnRegisterNetMsg()
end

function PuzzleMgr:OnRegisterGameEvent()
    --self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.PuzzleFinishNotify, self.OnPuzzleFinishNotifyHandle)
end

function PuzzleMgr:OnGameEventEnterWorld()
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    local CurGameType = self.GameType
    if not CurGameType then
        return
    end
    local bBurritos = CurGameType ~= nil and CurGameType == ProtoRes.Game.PuzzleGameType.Burritos
    if self.IsPuzzling and self.LeaveMapID and self.LeaveMapID == MapID and self.CurGameID and bBurritos then
        self:EnterPuzzleGame(self.GameType, self.CurGameID)
        self.LeaveMapID = nil
    end
end

function PuzzleMgr:OnPWorldExit(_)
    -- 任务流程拼装剪影专属逻辑
    local bBurritos = self.GameType ~= nil and self.GameType == ProtoRes.Game.PuzzleGameType.Burritos
    if self.IsPuzzling and bBurritos then
        self:ForceEndBurritos()
        self.IsNeedRecoverGame = true
    end
end

--- 主线拼装剪影游戏是否需要恢复
function PuzzleMgr:IsBurritosGameNeedRecover()
    return self.IsNeedRecoverGame
end

--- @ 完成
function PuzzleMgr:OnPuzzleFinishNotifyHandle(Params)
    if Params.PuzzleGameID == self.CurGameID then
        self:SetCurGameData(nil, false, nil)
    end
end

function PuzzleMgr:EnterDebugMode()
    self.bIsDebug = true
end

function PuzzleMgr:ResetGameMode()
    self.bIsDebug = false
end

-- function PuzzleMgr:Test(InGameType, InGameID, InGameTime)
--     local TargetGameID = tonumber(InGameID)
--     local TargeTime = nil
--     if (InGameTime ~= nil) then
--         TargeTime = tonumber(InGameTime)
--     end

--     self:EnterPuzzleGame(InGameType, TargetGameID, TargeTime)
-- end

function PuzzleMgr:FinishOnePuzzleItem(PuzzleItemID, MoveOp)
    if (self.PuzzleGameInst == nil) then
        return
    end

    self.PuzzleGameInst:OnFinishOnePuzzleItem(PuzzleItemID, MoveOp)
end

-- 获取一个没有完成的 PuzzleItemID
function PuzzleMgr:GetOneNotFinishPuzzleItemID()
    if (self.PuzzleGameInst == nil) then
        return nil
    end

    return self.PuzzleGameInst:GetOneNotFinishPuzzleItemID()
end

-- 策划调试用
function PuzzleMgr:Test1(GameID)
    PuzzleMgr:EnterPuzzleGame(1, GameID)
end
function PuzzleMgr:Test2(GameID)
    PuzzleMgr:EnterPuzzleGame(2, GameID)
end

-- InGameTime 可以外部指定游戏剩余时间
---PuzzleMgr.EnterPuzzleGame Description of the function
---@param InGameID   number 游戏ID，注意是 拼装剪影的表格ID
---@param InGameTime number 外部指定的游戏时间，不传入则使用表格的数据
---@return  Type Description
function PuzzleMgr:EnterPuzzleGame(InGameType, InGameID, InGameTime)
    if InGameType == ProtoRes.Game.PuzzleGameType.Burritos then
        self.PuzzleGameInst = PuzzleBurritosGameInst.New()
    elseif (InGameType == ProtoRes.Game.PuzzleGameType.PenguinJigsaw) then
        self.PuzzleGameInst = PuzzlePenguinJigsawGameIns.New()
    else
        _G.FLOG_ERROR("传入的游戏类型 : %s , 不正确，请检查", InGameType)
        return
    end
    if self.PuzzleGameInst == nil then
        FLOG_ERROR("EnterPuzzleGame Fail! GameID = %s", InGameID)
        return
    end
    if self.IsNeedRecoverGame then
        self.IsNeedRecoverGame = false -- 当再次进入一次游戏则重置状态
    end
    self:SetCurGameData(InGameType, true, InGameID)
    self.PuzzleGameInst:InitPuzzleGame(InGameID, InGameTime)
end

--- @type 设置零散区拼图大小位置以及角度
function PuzzleMgr:SetPuzzleItemPosAngleAndSize(PuzzleItem, Cfg, PuzzleMainPanel)
    return self.PuzzleGameInst:SetPuzzleItemPosAngleAndSize(PuzzleItem, Cfg, PuzzleMainPanel)
end

--- @type 检测是否成功
function PuzzleMgr:CheckIsSuccess(FinishNum)
    self.PuzzleGameInst:CheckIsSuccess(FinishNum)
end

--- @type 增加完成图片的数量
function PuzzleMgr:AddFinishNum()
    self.PuzzleGameInst:AddFinishNum()
end

--- @type 获取是否已经成功
function PuzzleMgr:bIsSuccess()
    return self.PuzzleGameInst:bIsSuccess()
end

--- @type 最后玩家还在拼图 则时间到了不结束  等玩家最后的操作结束再检查是否需要自动拼图
function PuzzleMgr:ReCheckIsFinish(InbNotForceCancelDrag)
    if (not self.GameStarted) then
        return
    end

    -- if (self.bTimeOut) then
    --     return
    -- end

    if not self.bIsDebug and self.PuzzleGameInst ~= nil then
        self.PuzzleGameInst:ReCheckIsFinish(InbNotForceCancelDrag)
    end
end

--- @type 设置拼图背景的显隐
function PuzzleMgr:UpdateShadowVisible(Num)
    self.PuzzleGameInst:UpdateShadowVisible(Num)
end

--- @type 设置可移动img显隐
function PuzzleMgr:SetMoveBreadVisible(ID, bVisible)
    self.PuzzleGameInst:SetMoveBreadVisible(ID, bVisible)
end

--- @type 设置正确位置img显隐
function PuzzleMgr:SetYesBreadVisible(ID, bVisible)
    self.PuzzleGameInst:SetYesBreadVisible(ID, bVisible)
end

--- @type 时间开始倒计时
function PuzzleMgr:BeginCountDown()
    self.GameStarted = true
    self.PuzzleGameInst:BeginCountDown()
end

function PuzzleMgr:HasGameStarted()
    return self.GameStarted
end

function PuzzleMgr:StopCountDown()
    self.GameStarted = false
    self.PuzzleGameInst:StopCountDown()
end

function PuzzleMgr:OnTimeRunOut()
    self.PuzzleGameInst:OnTimeRunOut()
end

--- @type 是否在剪影范围
function PuzzleMgr:bIsPuzzleRange(Pos)
    if (self.PuzzleGameInst == nil) then
        return false
    end
    return self.PuzzleGameInst:bIsPuzzleRange(Pos)
end

function PuzzleMgr:ResetNoRightOpTime()
    if (self.PuzzleGameInst ~= nil) then
        self.PuzzleGameInst:ResetNoRightOpTime()
    end
end

--- @type 自动移动到目标位置
function PuzzleMgr:AutoMoveToTargetLoc(PuzzleItem, TargetPos, bSuccess, MoveOp)
    self.PuzzleGameInst:AutoMoveToTargetLoc(PuzzleItem, TargetPos, bSuccess, MoveOp)
end

--- @type 当移动到目标位置
--- @param MoveOp 通过什么操作把拼图移动到目标位置
function PuzzleMgr:OnMoveToTarget(PuzzleItem, bSuccess, MoveOp)
    self.PuzzleGameInst:OnMoveToTarget(PuzzleItem, bSuccess, MoveOp)
end

function PuzzleMgr:GetGameInst()
    return self.PuzzleGameInst
end

-- 记录当前是否在游戏中
function PuzzleMgr:SetCurGameData(InGameType, IsPuzzling, CurGameID)
    self.IsPuzzling = IsPuzzling
    self.CurGameID = CurGameID
    self.GameType = InGameType
end

function PuzzleMgr:TimeOut()
    -- 超时之后就不让操作
    self.bTimeOut = true
end

function PuzzleMgr:GameEnd(EndType)
    self.bTimeOut = false
    self.GameStarted = false
    if self.PuzzleGameInst ~= nil then
        self.PuzzleGameInst:GameEnd(EndType)
        self.PuzzleGameInst = nil
    end
end

function PuzzleMgr:ForceEndBurritos()
    self.bTimeOut = false
    self.GameStarted = false
    if self.PuzzleGameInst ~= nil then
        PuzzleMgr:TimeOut()
        self.PuzzleGameInst:StopCountDown()
        self.PuzzleGameInst:OnTimeRunOut()
        self.PuzzleGameInst:OnEnd()
        self.PuzzleGameInst = nil
    end
    UIViewMgr:HideView(UIViewID.PuzzleBurritosMainPanel)
end

function PuzzleMgr:TestEnd()
    self:RegisterTimer(self.ForceEndBurritos, 10)
end

function PuzzleMgr:CheckIsInPuzzle()
    return UIViewMgr:IsViewVisible(UIViewID.PuzzleBurritosMainPanel)
end

return PuzzleMgr
