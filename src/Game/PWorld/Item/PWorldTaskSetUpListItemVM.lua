--[[
Author: jususchen jususchen@tencent.com
Date: 2024-06-28 11:16:37
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-03-07 11:48:57
FilePath: \Script\Game\PWorld\Item\PWorldTaskSetUpListItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PWorldTaskSetUpListItemVM = LuaClass(UIViewModel)

function PWorldTaskSetUpListItemVM:Ctor()
    self.Op = nil
    self.Icon = ""
    self.Text = ""
end

function PWorldTaskSetUpListItemVM:IsEqualVM(V)
    return V and V.Op == self.Op and self.Op ~= nil
end

function PWorldTaskSetUpListItemVM:UpdateVM(V)
    self.Op = V.Op

    local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
    if self.Op == 999 then
        self.Text = _G.LSTR(1310105)
    else
        local TaskType = _G.PWorldEntDetailVM:ToTaskType(self.Op)
        self.Text = PWorldQuestUtil.GetSceneModeName(TaskType) or ""
    end

    local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
    self.Icon =  TeamRecruitUtil.GetSceneModeIconByOp(self.Op)
end

return PWorldTaskSetUpListItemVM
