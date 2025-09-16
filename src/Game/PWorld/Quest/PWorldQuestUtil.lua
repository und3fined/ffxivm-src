local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")

local M = {}

function M.PWorldQuestEnable(PWorldID)
    local Cfg = SceneEnterCfg:FindCfgByKey(PWorldID)
    return Cfg ~= nil
end

function M.GetSceneModeIcon(Mode)
    return PWorldQuestDefine.SceneModeIconDef[Mode] or ""
end

function M.GetSceneModeName(Mode)
    return PWorldQuestDefine.SceneModeNameDef[Mode] or ""
end

return M