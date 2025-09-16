--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-03 16:13:08
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-09 10:08:47
FilePath: \Script\Game\Team\TeamHelper.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local ProtoCommon = require("Protocol/ProtoCommon")


local TeamMgrNames = {
    "TeamMgr",
    "PWorldTeamMgr",
    "PWorldEntourageTeamMgr",
    "PVPTeamMgr"
}

local TeamHelper = {

    --- Get Proper Team Manager at Current Time.
    ---@return ATeamMgr
    GetTeamMgr = function()
        if _G.PWorldMgr:CurrIsInDungeon() then
            if (_G.PWorldMgr:GetCurrPWorldTableCfg() or {}).CanPK == 1 then
               return _G.PVPTeamMgr 
            end

            local Mode = _G.PWorldMgr:GetMode()
            if Mode == ProtoCommon.SceneMode.SceneModeStory then
                return _G.PWorldEntourageTeamMgr
            else
                return _G.PWorldTeamMgr
            end
        end

        return _G.TeamMgr;
    end,

    ---@param Func function(@param ATeamMgr)
    IterTeamMgrs = function (Func)
        for _, MgrName in ipairs(TeamMgrNames) do
            local Mgr = _G[MgrName]
            if Mgr then
               Func(Mgr) 
            end
        end
    end

}

return TeamHelper;
