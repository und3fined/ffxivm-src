--[[
Author: andre_lightpaw <andre@lightpaw.com>
Date: 2024-08-07 14:18:26
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-20 14:14:31
FilePath: \Script\Game\PWorld\Team\PWorldEntourageTeamVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local ATeamVM = require("Game/Team/Abs/ATeamVM")
local ProfUtil = require("Game/Profession/ProfUtil")

---@class PWorldEntourageTeamVM : ATeamVM
local PWorldEntourageTeamVM = LuaClass(ATeamVM)

function PWorldEntourageTeamVM:Ctor()
    self.IsShowBtnBar = false
end

function PWorldEntourageTeamVM:UpdateVM()
    local SceneEncourageNpcCfg = require("TableCfg/SceneEncourageNpcCfg")
    local TeamDefine = require("Game/Team/TeamDefine")
    local ProtoCS = require("Protocol/ProtoCS")
    local DataList = {}
    for _, V in pairs(_G.PWorldTeamMgr.SceneTeamData or {}) do
        local IsEntourage = V.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypeFaith
        local Cfg = IsEntourage and SceneEncourageNpcCfg:FindCfgByKey(V.RoleID) or nil
        local RVM = V.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer and _G.RoleInfoMgr:FindRoleVM(V.RoleID, true) or {}
        table.insert(DataList, {
            EntourageID = IsEntourage and V.RoleID or nil,
            IsEntourage = IsEntourage or nil,
            EntityID = V.EntityID,
            RoleID  = not IsEntourage and V.RoleID or nil,
            ProfID = (IsEntourage and Cfg) and Cfg.ProfType or V.ProfID,
            Level =  IsEntourage and V.Level or V.Level,
            Name = (IsEntourage and Cfg) and Cfg.Name or (RVM and RVM.Name) or "",
        })
    end

    self:UpdateTeamMembers(DataList)
end

local function MemSort(a, b)
    if a.IsEntourage ~= b.IsEntourage then
        return not a.IsEntourage
    else
        return ProfUtil.SortByProfID(a, b)
    end
end
function PWorldEntourageTeamVM:GetMainTeamMemSort()
	return MemSort
end
local function SimpleMemSort(lhs, rhs)
    return false
end

function PWorldEntourageTeamVM:GetSimpleMemSort()
	return SimpleMemSort
end

return PWorldEntourageTeamVM
