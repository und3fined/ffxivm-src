---
--- Author: frankjfwang
--- DateTime: 2022-05-20 17:43
--- Description:
---


local Log = {}

local type = type
local string = string
local debug = debug
local tostring = tostring
local pairs = pairs

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO

local ModulePrefix = "MagicCard"
local AppendCallerFuncInfo = false

local function AppendInfo(Msg)
    if AppendCallerFuncInfo then
        local Info = debug.getinfo(3, "Sn")
        local CallerFuncName, SrcName = Info.name, Info.short_src
        if type(CallerFuncName) ~= "string" or CallerFuncName == "?" then
            return string.format("[%s]: %s", ModulePrefix, Msg)
        end
        return string.format("[%s] [%s.%s]: %s", ModulePrefix, SrcName, CallerFuncName, Msg)
    else
        return string.format("[%s]: %s", ModulePrefix, Msg)
    end
end

function Log.Info(Msg, ...)
    FLOG_INFO(AppendInfo(Msg), ...)
end

Log.I = Log.Info

function Log.Warning(Msg, ...)
    FLOG_WARNING(AppendInfo(Msg), ...)
end

Log.W = Log.Warning

function Log.Error(Msg, ...)
    FLOG_ERROR(AppendInfo(Msg), ...)
end

Log.E = Log.Error

---@return boolean @if check true
function Log.Check(TrueCondition, FailedMsg, ...)
    if not TrueCondition then
        if type(FailedMsg) ~= "string" then
            Log.E("Check Failed!")
        else
            Log.E(string.format("Check Failed! %s", FailedMsg), ...)
        end
        return false
    else
        return true
    end
end

function Log.EnumValueToKey(SrcTable, Value)
    if type(SrcTable) == "table" and Value ~= nil then
        for k, v in pairs(SrcTable) do
            if Value == v then
                return tostring(k)
            end
        end
    end

    return tostring(Value)
end

return Log