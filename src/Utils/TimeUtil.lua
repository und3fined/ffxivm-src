--
-- Author: anypkvcai
-- Date: 2020-08-05 14:29:03
-- Description:
--

local TimeDefine = require("Define/TimeDefine")
local AozyTimeDefine = TimeDefine.AozyTimeDefine

local TimeType = TimeDefine.TimeType
local TimeNameConfig = TimeDefine.TimeNameConfig
local TimeIconConfig = TimeDefine.TimeIconConfig
local LSTR = _G.LSTR

local UTimerMgr = _G.UE.UTimerMgr:Get()

---@class TimeUtil
local TimeUtil = {

	--服务器每周更新时间
	ServerUpdateWeekInfo = {
		WeekDay = 2,
		Hour = 16
	},

	ServerUpdateDailyTime = 11 --服务器每天更新时间
}

---GetTimeFormat
---@param Format string @"%Y-%m-%d %H:%M:%S"
---@Time number
function TimeUtil.GetTimeFormat(Format, Time)
	return os.date(Format, Time)
end

---GetTimeFromString
---@param TimeString string    @"%Y-%m-%d %H:%M:%S"
---@return number Time          @时间戳（秒）
function TimeUtil.GetTimeFromString(TimeString)
	local Year, Month, Day, Hour, Minute, Second = string.match(TimeString, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	local Time = os.time({year = Year, month = Month, day = Day, hour = Hour, min = Minute, sec = Second})
	return Time
end

--[[
-- 暂未使用
---GetPlatformTimeSeconds
---@return number @platform time in seconds
function TimeUtil.GetPlatformTimeSeconds()
	return UTimerMgr.GetPlatformTimeSeconds()
end

---GetWorldTimeSeconds @Returns time in seconds since world was brought up for play, IS stopped when game pauses, IS dilated/clamped
---@return number @time in seconds since world was brought up for play
function TimeUtil.GetWorldTimeSeconds()
	return UTimerMgr.GetWorldTimeSeconds()
end

---GetWorldRealTimeSeconds @Returns time in seconds since world was brought up for play, does NOT stop when game pauses, NOT dilated/clamped
---@return number     @time in seconds since world was brought up for play
function TimeUtil.GetWorldRealTimeSeconds()
	return UTimerMgr.GetWorldRealTimeSeconds()
end

---GetWorldDeltaSeconds @Returns the frame delta time in seconds adjusted by e.g. time dilation
---@return number  @frame delta time in seconds adjusted by e.g. time dilation
function TimeUtil.GetWorldDeltaSeconds()
	return UTimerMgr.GetWorldDeltaSeconds()
end
--]]

---GetLocalTime
---@return number           @本地时间戳（秒） 如果修改了设备时间 获取的时间也会变化 一般用于显示本地时间或改时间了也不影响功能
function TimeUtil.GetLocalTime()
	return UTimerMgr.GetLocalTime()
end

---GetLocalTimeMS			lua侧毫秒统一以MS结尾
---@return number           @本地时间戳（毫秒） 如果修改了设备时间 获取的时间也会变化 一般用于显示本地时间或改时间了也不影响功能
function TimeUtil.GetLocalTimeMS()
	return UTimerMgr.GetLocalTimeMS()
end

---GetLocalTimeFormat
---@param Format string @"%Y-%m-%d %H:%M:%S"
function TimeUtil.GetLocalTimeFormat(Format)
	local Time = TimeUtil.GetLocalTime()

	return TimeUtil.GetTimeFormat(Format, Time)
end

---GetGameTimeMS  	        lua侧毫秒统一以MS结尾
---@return number           @游戏时间（毫秒） PlatformTime, 因为GCloud用的本地时间，游戏也用LocalTime就行，不用支持游戏启动改时间
function TimeUtil.GetGameTimeMS()
	return UTimerMgr:GetGameTimeMS()
end

---GetGameTime
---@return number           @游戏时间（秒） PlatformTime, 因为GCloud用的本地时间，游戏也用LocalTime就行，不用支持游戏启动改时间
function TimeUtil.GetGameTime()
	return UTimerMgr:GetGameTime()
end

---GetServerTime
---@return number           @服务器物理时时间戳（秒） 移动同步、战斗应该用物理时间
function TimeUtil.GetServerTime()
	return UTimerMgr:GetServerTime()
end

---GetServerTimeMS  	    lua侧毫秒统一以MS结尾
---@return number           @服务器物理时时间戳（毫秒） 移动同步、战斗应该用物理时间
function TimeUtil.GetServerTimeMS()
	return UTimerMgr:GetServerTimeMS()
end

---GetServerTimeFormat
---@param Format string @"%Y-%m-%d %H:%M:%S"
function TimeUtil.GetServerTimeFormat(Format)
	local Time = TimeUtil.GetServerTime()

	return TimeUtil.GetTimeFormat(Format, Time)
end

---GetServerLogicTime
---@return number           @服务器逻辑时间戳（秒） GM可修改 正式环境和服务器时间一样 玩法才会去用逻辑时间
function TimeUtil.GetServerLogicTime()
	return UTimerMgr:GetServerLogicTime()
end

---GetServerLogicTimeMS  	lua侧毫秒统一以MS结尾
---@return number           @服务器物理时时间戳（毫秒） GM可修改 正式环境和服务器时间一样 玩法才会去用逻辑时间
function TimeUtil.GetServerLogicTimeMS()
	return UTimerMgr:GetServerLogicTimeMS()
end

---GetServerLogicTimeFormat
---@param Format string @"%Y-%m-%d %H:%M:%S"
function TimeUtil.GetServerLogicTimeFormat(Format)
	local Time = TimeUtil.GetServerLogicTime()

	return TimeUtil.GetTimeFormat(Format, Time)
end

---GetAozyTimeFormat
---艾欧泽亚时间 1h=175s=2分55秒，12h=35分，一天=70分(4200秒)
function TimeUtil.GetAozyTimeFormat()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local Hour = math.floor(ServerTime / AozyTimeDefine.AozyHour2RealSec % 24)
	local Minute = math.floor(ServerTime % AozyTimeDefine.AozyHour2RealSec * AozyTimeDefine.RealSec2AozyMin)

	return string.format("%02d:%02d", Hour, Minute)
end

--- GetAozyDay
--- doc website = https://violarulan.github.io/blog/earth-time-to-eorzea-time/
--- verify website = http://caiji.ffxiv.cn/#/?type=forkList
function TimeUtil.GetAozyMoon()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local Day = math.floor(ServerTime / AozyTimeDefine.AozyDay2RealSec)
	local Moon = (Day // 32 + 1) % 12
	return Moon
end

---@return number
function TimeUtil.GetAozyDay()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local Day = math.floor(ServerTime / AozyTimeDefine.AozyDay2RealSec)
	return Day
end

---GetAozyHour
---@return number
function TimeUtil.GetAozyHour()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local Hour = math.floor(ServerTime / AozyTimeDefine.AozyHour2RealSec % 24)
	return Hour
end

---GetAozyMinute
---@return number
function TimeUtil.GetAozyMinute()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local Minute = math.floor(ServerTime % AozyTimeDefine.AozyHour2RealSec * AozyTimeDefine.RealSec2AozyMin)
	return Minute
end

---GetAozyMinute
---@return number
function TimeUtil.GetAozySec()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local Sec = math.floor(ServerTime * AozyTimeDefine.RealSec2AozyMin) * 60
	return Sec
end

---获取到下一个整点艾欧泽亚时的真实秒数
---@return number
function TimeUtil.GetToNextAozyHourRealSec()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local TotalHourNextOnTheHour = math.floor(ServerTime / AozyTimeDefine.AozyHour2RealSec) + 1
	local TotalSecNextOnTheHour = TotalHourNextOnTheHour * AozyTimeDefine.AozyHour2RealSec
	return TotalSecNextOnTheHour - ServerTime
end

function TimeUtil.GetAozyDate(OffSec, OffMin, OffHour)
	local Sec = (_G.TimeUtil.GetServerLogicTime() + 2) * AozyTimeDefine.RealSec2AozyMin * 60

	Sec = Sec // 8 * 8
	
	if OffSec then
		Sec = Sec + OffSec
	end

	if OffMin then
		Sec = Sec + OffMin * 60
	end

	if OffHour then
		Sec = Sec + OffHour * 60 * 60
	end

	return TimeUtil.GetAozyDateBySec(Sec)
end

function TimeUtil.GetAozyDateBySec(AozyTimeInSec)
	local Sec = (AozyTimeInSec % 60)
	local Min = (AozyTimeInSec // 60) % 60
	local Bell = (AozyTimeInSec // (60 * 60)) % 24
	local Sun = (AozyTimeInSec // (60 * 60 * 24)) % 32 + 1
	local Moon = ((AozyTimeInSec // (60 * 60 * 24 * 32)) % 12) + 1
	local Year = (AozyTimeInSec // (60 * 60 * 24 * 32 * 12)) + 1
	return Sec, Min, Bell, Sun, Moon, Year
end

--- region 星月&灵月
function TimeUtil.GetMoonTypeInfoByMoon(InMoon)
	return {
		Moon = (InMoon // 2) + 1,
		Type = ((InMoon % 2) == 1) and TimeDefine.MoonType.Star or TimeDefine.MoonType.Spirit,
	}
end

function TimeUtil.GetMoonTypeText(MoonTypeInfo)
	if (not MoonTypeInfo) or (not MoonTypeInfo.Moon) or (not MoonTypeInfo.Type) then
		_G.FLOG_ERROR('[TimeUtil] TimeUtil.GetMoonTypeText MoonTypeInfo Invalid')
		return
	end

	return string.format("%s%d" .. _G.LSTR(610005), 
				TimeDefine.MoonTypeName[MoonTypeInfo.Type], 
				MoonTypeInfo.Moon)
end

--- endregion 星月&灵月

function TimeUtil.CheckCrossDay()
	-- body
end

---GetTimeFormat
---@param Type TimeType
---@param Format string @"%Y-%m-%d %H:%M:%S"
function TimeUtil.GetTimeFormatByType(Type, Format)
	if TimeType.Local == Type then
		return TimeUtil.GetLocalTimeFormat(Format)
	elseif TimeType.Server == Type then
		return TimeUtil.GetServerLogicTimeFormat(Format)
	else
		return TimeUtil.GetAozyTimeFormat()
	end
end

function TimeUtil.GetTimeName(Type)
	return TimeNameConfig[Type]
end

function TimeUtil.GetTimeIcon(Type)
	return TimeIconConfig[Type]
end

---GetWeeklyUpdateTimeTotalSecs @离下次服务器周更新时间还有多少秒
---@return number
function TimeUtil.GetWeeklyUpdateTimeTotalSecs()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local TotalSec = 0
	local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600
	local TmTime = os.date("*t",LocalServeTime)

	if TmTime.wday <= TimeUtil.ServerUpdateWeekInfo.WeekDay and TmTime.hour < TimeUtil.ServerUpdateWeekInfo.Hour then --没有到周二更新时间
		local CurrSec = (TmTime.wday -1) * 3600 * 24 + TmTime.hour * 3600 + TmTime.min * 60 + TmTime.sec --当前时间相对于周日0点过了多久
		local UpdateTimeSec = 2 * 3600 * 24 + 16 * 3600
		TotalSec = UpdateTimeSec - CurrSec
	else --超过了周二更新时间则要算到下周更析时间
		local CurrSec = (TmTime.wday - 1) * 3600 * 24 + TmTime.hour * 3600 + TmTime.min * 60 + TmTime.sec
		local PreUpdateTimeSec = 2 * 3600 * 24 + 16 * 3600

		TotalSec = 7 * 3600 * 24 - (CurrSec - PreUpdateTimeSec)
	end

	return TotalSec
end

---GetDailyUpadteTimeTotalSecs @离下次服务器天更新时间还有多少秒
---@return number
function TimeUtil.GetDailyUpadteTimeTotalSecs()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local TotalSec = 0
	local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600
	local TmTime = os.date("*t",LocalServeTime)

	if TmTime.hour >= TimeUtil.ServerUpdateDailyTime then
		TotalSec = 24 * 3600 - ((TmTime.hour - TimeUtil.ServerUpdateDailyTime) * 3600 + TmTime.min * 60 + TmTime.sec)
	else
		TotalSec = (TimeUtil.ServerUpdateDailyTime - TmTime.hour) * 3600 - (TmTime.min * 60 + TmTime.sec)
	end

	return TotalSec
end

---根据服务器当前时间得到一天中的时间(秒为单位)
---@return number
function TimeUtil.GetGameDayTimeSinceServerTime()
	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600
	local TmTime = os.date("*t",LocalServeTime)

	local CurrSec = TmTime.hour * 3600 + TmTime.min * 60 + TmTime.sec
	return CurrSec
end

function TimeUtil.GetDateByTimeStamp(TimeStamp)
	local Date = os.date("*t", TimeStamp)
	return Date
end

--- 根据时间戳计算本周周一零点
function TimeUtil.GetMondayZero(TimeStamp)
	if not TimeStamp then return end

	local OneDayTime = 86400
	local Current = os.date("*t", TimeStamp)
	local WeekDay = Current.wday - 1
    if WeekDay == 0 then
		WeekDay = 7
	end

	local ToMondayTime = (WeekDay - 1) * OneDayTime
	local Monday_zero = TimeStamp - ToMondayTime - Current.hour * 3600 - Current.min * 60 - Current.sec
    
    return Monday_zero
end

--- 根据时间戳计算当天的零点
function TimeUtil.GetCurTimeStampZero(TimeStamp)
	if not TimeStamp then return end
	local DateTable = os.date("!*t", TimeStamp)
	DateTable.hour = 0
	DateTable.min = 0
	DateTable.sec = 0

	return os.time(DateTable)
end

--- 根据时间戳计算当天的特定时的时间戳
---@param Hour number @0 ~ 23
function TimeUtil.GetCurTimeStampCertainHour(TimeStamp, Hour)
	if not TimeStamp then return end
	if Hour < 0 or Hour > 23 then
		return
	end
	local DateTable = os.date("*t", TimeStamp)
	DateTable.hour = Hour
	DateTable.min = 0
	DateTable.sec = 0

	return os.time(DateTable)
end

---获取格式化时间（时:分:秒，xx:xx:xx）
---@param Time number @时间，单位秒
---return string
function TimeUtil.GetFmtTime_HMS(Time)
    local Sec = math.floor(Time % 60)
    local Min = math.floor((Time % 3600) / 60)
    local Hour = math.floor(Time / 3600)

    return string.format("%02d:%02d:%02d", Hour, Min, Sec)
end

function TimeUtil.GetFmtTime_MS(Time)
    local Sec = math.floor(Time % 60)
    local Min = math.floor(Time / 60)
 
    return string.format("%02d:%02d", Min, Sec)
end

---获取离线描述
---@param Timestamp number @离线时间戳，单位秒
function TimeUtil.GetOfflineDesc(Timestamp)
	if nil == Timestamp then
		return ""
	end

	local ServerTime = TimeUtil.GetServerTime()
	local Time = math.max(ServerTime - Timestamp, 60) -- 至少显示1分钟

	local Min = 60
	local Hour = 60 * Min 
	if Time < Hour then
		return string.format(LSTR(10046), math.floor(Time/Min)) -- "%d分钟"
	end

	local Day = 24 * Hour 
	if Time < Day then
		return string.format(LSTR(10047), math.floor(Time/Hour)) -- "%d小时"
	end

	local Month = 30 * Day 
	if Time < Month then
		return string.format(LSTR(10048), math.floor(Time/Day)) -- "%d天"
	else
		return LSTR(10049) -- "30天"
	end
end


---GetNextDailyUpadteTime @获取距离下次跨天时间,跨天时间点取策划配置
---@return number
function TimeUtil.GetNextDailyUpadteTime()
	local CommUpdateDailyTime = TimeUtil.GetDailyCycleTimeCfg()
	if nil == CommUpdateDailyTime then
		return
	end
	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local TotalSec = 0
	local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600
	local TmTime = os.date("*t",LocalServeTime)
	if TmTime.hour >= CommUpdateDailyTime then
		TotalSec = 24 * 3600 - ((TmTime.hour - CommUpdateDailyTime) * 3600 + TmTime.min * 60 + TmTime.sec)
	else
		TotalSec = (CommUpdateDailyTime - TmTime.hour) * 3600 - (TmTime.min * 60 + TmTime.sec)
	end

	return TotalSec
end

---GetIsCurDailyCycleTime @获取时间戳是否在当前跨天时间周期内
---@param Timestamp number @时间戳，单位秒
---@return number
function TimeUtil.GetIsCurDailyCycleTime(Timestamp)
	local CommUpdateDailyTime = TimeUtil.GetDailyCycleTimeCfg()
	if nil == CommUpdateDailyTime then
		return
	end
	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local OffsetTime = CommUpdateDailyTime * 3600
	local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600 - OffsetTime
	local TmTime = os.date("*t", LocalServeTime)
	local CompareTime = os.date("*t", Timestamp - OffsetTime)
	local IsCurDailyCycleTime = false
	if TmTime.year == CompareTime.year and TmTime.month == CompareTime.month and TmTime.day == CompareTime.day then
		IsCurDailyCycleTime = true
	end
	return IsCurDailyCycleTime
end

function TimeUtil.GetIsCurWeekCycleTime(Timestamp)
	local CommUpdateDailyTime = TimeUtil.GetDailyCycleTimeCfg()
	if nil == CommUpdateDailyTime then
		return
	end

	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local OffsetTime = CommUpdateDailyTime * 3600
	local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600 - OffsetTime

	local Monday = os.date("*t", LocalServeTime)
	local WeekDay = Monday.wday - 1
    if WeekDay == 0 then
		WeekDay = 7
	end
	local MondayStamp = LocalServeTime - WeekDay * 24 * 3600
	local MondayDate = os.date("*t", MondayStamp)


	local CompareTime = Timestamp - OffsetTime
	local Compare = os.date("*t", CompareTime)
	local CompareWeekDay = Compare.wday - 1
    if CompareWeekDay == 0 then
		CompareWeekDay = 7
	end
	local CompareStamp = CompareTime - CompareWeekDay * 24 * 3600
	local CompareDate = os.date("*t", CompareStamp)

	return MondayDate.year == CompareDate.year and MondayDate.month == CompareDate.month and MondayDate.day == CompareDate.day
	
end

function TimeUtil.GetIsCurMonthCycleTime(Timestamp)
	local CommUpdateDailyTime = TimeUtil.GetDailyCycleTimeCfg()
	if nil == CommUpdateDailyTime then
		return
	end

	local ServerTime = TimeUtil.GetServerLogicTime()
	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local OffsetTime = CommUpdateDailyTime * 3600
	local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600 - OffsetTime

	local Month = os.date("*t", LocalServeTime)
	Month.day = 1
	local MonthStamp = os.time(Month)
	local MonthDate = os.date("*t", MonthStamp)

	local CompareTime = os.date("*t", Timestamp - OffsetTime)
	CompareTime.day = 1
	local CompareStamp = os.time(CompareTime)
	local CompareDate = os.date("*t", CompareStamp)

	return MonthDate.year == CompareDate.year and MonthDate.month == CompareDate.month and MonthDate.day == CompareDate.day

end


---GetDailyCycleTimeCfg @获取跨天时间配置
---@return number
function TimeUtil.GetDailyCycleTimeCfg()
	local GlobalCfg = require("TableCfg/GlobalCfg")
	local ProtoRes = require("Protocol/ProtoRes")
	local Value = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GlobalCfgCrossDayOffset, "Value") ---通用跨天更新时间
	local CommUpdateDailyTime = Value[1]
	return CommUpdateDailyTime
end

---GetOpenServerTime @获取开服时间(单位:秒)
function TimeUtil.GetOpenServerTime()
	local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
	return _G.LoginMgr:GetMapleNodeOpenServerTS(CurWorldID)
end

---GetOpenServerOffsetTS @获取开服偏移时间戳
---@param OffDay number
---@param OffHour number
---@return number
function TimeUtil.GetOpenServerOffsetTS(OffDay, OffHour)
	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local ZoneTS = ServerZone * 3600 --时区对应偏移的TimeStamp
	local OpenTS = TimeUtil.GetOpenServerTime() --开服TimeStamp
	local UTCOPenTS = OpenTS + ZoneTS --转换成utc开服TimeStamp
	local Days = math.floor(UTCOPenTS / 86400)
	local SecondOfDay = UTCOPenTS - Days * 86400
	local DayStartHour = TimeUtil.GetDailyCycleTimeCfg()
	if SecondOfDay < DayStartHour * 3600 then
		Days = Days - 1
	end
	local OffsetTS = (Days + OffDay) * 86400 + (DayStartHour + OffHour) * 3600
	return OffsetTS - ZoneTS --转回时区时间
end

return TimeUtil

