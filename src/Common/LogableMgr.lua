--[[
Author: jususchen jususchen@tencent.com
Date: 2024-09-24 18:58:21
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-09-29 11:07:56
FilePath: \Script\Common\LogableMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")


---@class LogableMgr: MgrBase
local LogableMgr = LuaClass(MgrBase)

---@param v string
function LogableMgr:SetLogName(v)
    self.NameToLog = v
end

---@param v boolean
function LogableMgr:SetDisable(v)
    self.bDisableLog = v
end

---@param fmt string
function LogableMgr:LogInfo(fmt, ...)
    if self.bDisableLog then
        return
    end

    _G.FLOG_INFO("<%s>(%s):: %s", self.NameToLog, self, string.sformat(fmt, ...))
end

---@param fmt string
function LogableMgr:LogErr(fmt, ...)
    if self.bDisableLog then
        return
    end

    _G.FLOG_ERROR("<%s>(%s):: error: %s", self.NameToLog, self, string.sformat(fmt, ...))
end

---@param fmt string
function LogableMgr:LogWarn(fmt, ...)
    if self.bDisableLog then
        return
    end

    _G.FLOG_WARNING("<%s>(%s):: %s", self.NameToLog, self, string.sformat(fmt, ...))
end

--- ToTableStringSafe
---@param t table
---@return string
function LogableMgr.ToTableStringSafe(t)
    if type(t) == 'table' then
       return _G.table_to_string_block(t, 20) 
    else
        return tostring(t)
    end
end

return LogableMgr