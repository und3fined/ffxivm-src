--
-- Author: sammrli
-- Date: 2024-4-3 14:55
-- Description:系统模块工具
--

local LuaClass = require("Core/LuaClass")

local MajorUtil = require("Utils/MajorUtil")

local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local SystemModulesDefine = require("Game/SystemModules/SystemModulesDefine")

local SystemModulesUtil = LuaClass()

-- ==================================================
-- 公共接口
-- ==================================================

---是否使用过系统模块
---@param ModulesID number@系统模块ID
function SystemModulesUtil.IsUsed(ModulesID)
    local RoleID = MajorUtil.GetMajorRoleID()
    local StrContent = _G.ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.SystemModulesUsed)
    local UsedValue = tonumber(StrContent) or 0
    if ModulesID & UsedValue == ModulesID then
        return true
    end
    return false
end

---设置使用过系统模块
---@param ModulesID number@系统模块ID
function SystemModulesUtil.SetUsed(ModulesID)
    local RoleID = MajorUtil.GetMajorRoleID()
    local StrContent = _G.ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.SystemModulesUsed)
    local UsedValue = tonumber(StrContent) or 0
    UsedValue = UsedValue | ModulesID
    _G.ClientSetupMgr:SendSetReq(ClientSetupID.SystemModulesUsed, tostring(UsedValue))
end


-- ==================================================
-- 方便外部调用的接口
-- ==================================================

---是否使用过陆行鸟运输
---@return boolean
function SystemModulesUtil.IsUsedChocoboTransport()
    return SystemModulesUtil.IsUsed(SystemModulesDefine.ChocoboTransport)
end

---设置使用过陆行鸟运输
function SystemModulesUtil.SetUsedChocoboTransport()
    SystemModulesUtil.SetUsed(SystemModulesDefine.ChocoboTransport)
end

return SystemModulesUtil