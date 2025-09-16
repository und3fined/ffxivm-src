--
-- Author: sammrli
-- Date: 2023-07-30
-- Description: 传送帮助
--

local TransCfg = require("TableCfg/TransCfg")
local QuestHelper = require("Game/Quest/QuestHelper")

---@class TransHelper
local TransHelper = {}

---@type PlayPostSequence 播放传送后动画
---@param TransID number
function TransHelper.PlayPostSequence(TransID)
    if TransID then
        local Cfg = TransCfg:FindCfgByKey(TransID)
        if Cfg and Cfg.PostAmin and Cfg.PostAmin > 0 then
            QuestHelper.QuestPlaySequence(Cfg.PostAmin)
            return true
        end
    end
    return false
end

---@type PlayPreSequence 播放传送前动画
---@param TransID number
function TransHelper.PlayPreSequence(TransID)
    if TransID then
        local Cfg = TransCfg:FindCfgByKey(TransID)
        if Cfg and Cfg.PreAmin and Cfg.PreAmin > 0 then
            QuestHelper.QuestPlaySequence(Cfg.PreAmin)
            return true
        end
    end
    return false
end

return TransHelper