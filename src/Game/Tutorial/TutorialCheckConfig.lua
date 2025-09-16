

local CheckConfig = {

    -- 剧情辅助器副本引导
    [96] = {
        CheckFunc = function()
            local PWorldEntDetailVM = require("Game/PWorld/Entrance/PWorldEntDetailVM")
            return PWorldEntDetailVM.IsShowBtnEncourage
        end,
    }
}


local function IsPassTutorialCheck(Cfg)
    local TutorialID <const> = Cfg and Cfg.TutorialID or nil

    if TutorialID == nil then
       return true 
    end

   local Config <const> = CheckConfig[TutorialID]
    if Config == nil then
         return true
    end

    local CheckFunc = Config.CheckFunc
    if type(CheckFunc) ~= "function" then
        _G.FLOG_ERROR("invalid check function for tutorial ID: %s", TutorialID)
        return true
    end

    return CheckFunc(Cfg)
end


local TutorialCheckConfig = {
    IsPassTutorialCheck = IsPassTutorialCheck,
}

return TutorialCheckConfig
