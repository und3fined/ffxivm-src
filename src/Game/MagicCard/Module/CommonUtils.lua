---
--- Author: frankjfwang
--- DateTime: 2022-05-20 17:43
--- Description:
---

local TimerMgr = nil ---@class TimerMgr
local NpcDialogMgr = nil ---@class NpcDialogMgr
local MagicCardMgr = nil ---@class MagicCardMgr
local EventID = require("Define/EventID")

local Async = require("Game/MagicCard/Module/AsyncUtils")
local Log = require("Game/MagicCard/Module/Log")
--local UWidgetAnimationPlayCallbackProxy = _G.UE.UWidgetAnimationPlayCallbackProxy

---@class MagicCardCommonUtils
local M = {}

function M.Init()
    TimerMgr = _G.TimerMgr
    NpcDialogMgr = _G.NpcDialogMgr
    MagicCardMgr = _G.MagicCardMgr
end

function M.PlayNpcDialog(NpcEntityId, NpcDialogLibID, OnFinishCallback)
    local function FinishDialogCallback(_, Params)
        Log.I("finish play npcdialog id: [%d]", Params.DialogLibID or 0)
        if Params.DialogLibID == NpcDialogLibID then
            MagicCardMgr:UnRegisterGameEvent(EventID.FinishDialog, FinishDialogCallback)
            if (OnFinishCallback ~=nil) then
                OnFinishCallback()
            end
        end
    end
    MagicCardMgr:RegisterGameEvent(EventID.FinishDialog, FinishDialogCallback)

    NpcDialogMgr:PlayDialogLib(NpcDialogLibID, NpcEntityId)
end

M.PlayNpcDialogAsync = Async.Wrap(M.PlayNpcDialog)

function M.Delay(DelayTime, Callback)
    TimerMgr:AddTimer(nil, Callback, DelayTime, 0, nil)
end

M.DelayAsync = Async.Wrap(M.Delay)

function M.DelayNextFrame(Callback)
    TimerMgr:AddTimer(nil, Callback, 0.01, 0, nil)
end

M.DelayNextFrameAsync = Async.Wrap(M.DelayNextFrame)

function M.PlayUIAnimation(Widget, Anim, OnFinishCallback)
    if Anim then
        Widget:PlayAnimation(Anim)
        M.Delay(Anim:GetEndTime(), OnFinishCallback)
    else
        Log.E("Anim is nil!")
        if (OnFinishCallback ~= nil) then
            OnFinishCallback()
        end
    end
end

M.PlayUIAnimationAsync = Async.Wrap(M.PlayUIAnimation)

return M
