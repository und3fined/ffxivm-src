---
--- Author: sammrli
--- DateTime: 2024-09-20
--- 目标：完成剪影小游戏
--- 

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local ProtoRes = require("Protocol/ProtoRes")

local EventID = require("Define/EventID")

---@class TargetCutout
local TargetCutout = LuaClass(TargetBase, true)

function TargetCutout:Ctor(_, Properties)
    self.GameID = tonumber(Properties[1]) or 0
end

function TargetCutout:DoStartTarget()
    --self:RegisterEvent(EventID.PuzzleFinishNotify, self.OnPuzzleFinishNotifyHandle)
    self:RegisterEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    --self:RegisterEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    --_G.PuzzleMgr:EnterPuzzleGame(ProtoRes.PuzzleGameType.Burritos, self.GameID)
    -- !拼装任务废弃,防止线上数据出错,保留目标节点。目标开始直接请求完成
    _G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
end

function TargetCutout:DoClearTarget()
    --_G.PuzzleMgr:ForceEndBurritos()
end

function TargetCutout:OnPuzzleFinishNotifyHandle(Params)
    if Params then
        if self.GameID == Params.PuzzleGameID then
            _G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
        end
    end
end

function TargetCutout:OnGameEventLoginRes(Params)
    if Params.bReconnect then --断线重连重新进入拼装游戏
        --_G.PuzzleMgr:EnterPuzzleGame(ProtoRes.PuzzleGameType.Burritos, self.GameID)
        -- !拼装任务废弃,防止线上数据出错,保留目标节点。目标开始直接请求完成
        _G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
    end
end

function TargetCutout:OnGameEventEnterWorld()
    if not _G.PWorldMgr:CurrIsInDungeon() then
        local IsRecover = _G.PuzzleMgr:IsBurritosGameNeedRecover()
        if IsRecover then
            _G.PuzzleMgr:EnterPuzzleGame(ProtoRes.PuzzleGameType.Burritos, self.GameID)
        end
    end
end

return TargetCutout