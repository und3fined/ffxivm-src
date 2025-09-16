--
-- Author: anypkvcai
-- Date: 2020-10-23 10:14:28
-- Description:
-- Update:
--  1.调用C++侧日志打印方法，可选择使用LogFGame or LogUnlua标识，默认为LogUnlua
--  2.print实际也是调用了C++侧的Global_Print方法来实现打印

---@class LogMgr
local LogMgr = {}
local ULogMgr = _G.UE.ULogMgr

local ELogFileLevel = {
	Info = 0,
	Warning = 1,
	Error = 2,
}

---Info
---@param Msg string
function LogMgr.Info(Msg, ...)
	if ULogMgr.GetLogFileLevel() == ELogFileLevel.Info then
		return ULogMgr.Info(string.format(Msg, ...), true)
	end
end

---Warning
---@param Msg string
function LogMgr.Warning(Msg, ...)
	if ULogMgr.GetLogFileLevel() <= ELogFileLevel.Warning then
		return ULogMgr.Warning(string.format(Msg, ...), true)
	end
end

---Error
---@param Msg string
function LogMgr.Error(Msg, ...)
	return ULogMgr.Error(string.format(Msg, ...), true)
end

---Screen
---@param Msg string
function LogMgr.Screen(Msg, ...)
	if ULogMgr.GetLogToScreen() == true then
		return ULogMgr.Screen(string.format(Msg, ...))
	end
end

---ScreenColor
---@param Color userdata       @_G.UE.FColor
---@param Msg string
function LogMgr.ScreenColor(Color, Msg, ...)
	if ULogMgr.GetLogToScreen() == true then
		return ULogMgr.ScreenColor(Color, string.format(Msg, ...))
	end
end

_G.FLOG_INFO = LogMgr.Info
_G.FLOG_WARNING = LogMgr.Warning
_G.FLOG_ERROR = LogMgr.Error
_G.FLOG_SCREEN = LogMgr.Screen
_G.FLOG_SCREEN_COLOR = LogMgr.ScreenColor

return LogMgr