--日期和时间相关操作

local DateTimeTools =
{
}

--获取TimeZone
function DateTimeTools.GetTimeZone()
	local TimeNow = os.time()
	local TimeZone = os.difftime(TimeNow, os.time(os.date("!*t", TimeNow))) / 3600
	return TimeZone
end

--获取当前时区时间与UTC时区时间之间的相差秒数
local function GetSecondsDiffFromLocalToUTC()
    local TimeNow = os.time()
    local TimeDiffSeconds = os.difftime(TimeNow, os.time(os.date("!*t", TimeNow)))
    return TimeDiffSeconds
end

--转换成指定时区时间(秒)
local function ChangeToTimeZoneTime(Time, TimeZone)
    local LocalTime = Time - GetSecondsDiffFromLocalToUTC() + TimeZone * 3600
    return LocalTime
end

--转换成UTC+8时区时间(秒)
function DateTimeTools.ChangeToUTC8Time(Time)
    return ChangeToTimeZoneTime(Time, 8)
end

--指定日期转换成时间（秒数）
function DateTimeTools.DateToTime(DateTable)
	if (DateTable == nil) then
		return 0
	end
	--isdst：忽略夏令时，否则如阿拉斯加地区转换不对
	DateTable.isdst = false
    return DateTimeTools.ChangeToUTC8Time(os.time(DateTable))
end


function DateTimeTools.DateZoneToTime(DateTable, TimeZone)
	if (DateTable == nil) then
		return 0
	end
	--isdst：忽略夏令时，否则如阿拉斯加地区转换不对
	DateTable.isdst = false
    return ChangeToTimeZoneTime(os.time(DateTable), TimeZone)
end

-- 显示UTC+8时区的时间格式化
function DateTimeTools.DateFormat( Format, Time )
	if Time == nil then Time = 0 end
	return os.date("!" .. Format, Time + 28800)
end

-- 显示UTC+8时区的data （table的形式）
function DateTimeTools.GetDateTable(Time )
	if Time == nil then Time = 0 end
	return os.date("!*t", Time + 28800)
end

--秒转换成指定格式的字符串
--Seconds： 秒
--Format： 格式
--bUseChinese： 是否使用中文
function DateTimeTools.TimeFormat(InSeconds, Format, bUseChinese, bUseChineseSymbol)
	if (InSeconds < 0) then
		InSeconds = 0
	end
	local Hour = math.modf(InSeconds/3600)
	local Minute = math.modf((InSeconds/60)%60)
	local Second = math.modf(InSeconds%60)
	local Colon = bUseChineseSymbol and "：" or ":"
	if (Format == "mm:ss") then
		if (bUseChinese) then
			return string.format(LSTR("%02d分%02d秒"), Minute, Second)
		else
			return string.format("%02d%s%02d", Minute, Colon, Second)
		end

	elseif (Format == "hh:mm") then
		if (Second > 0) then
			Minute = Minute + 1
        end

		if (Minute == 60) then
			Hour = Hour + 1
			Minute = 0
		end
		if (bUseChinese) then
			return string.format(LSTR("%02d时%02d分"), Hour, Minute)
		else
			return string.format("%02d%s%02d", Hour, Colon, Minute)
        end

	elseif (Format == "hh:mm:ss") then
		if (bUseChinese) then
			return string.format(LSTR("%02d时%02d分%02d秒"), Hour, Minute, Second)
		else
			return string.format("%02d%s%02d%s%02d", Hour, Colon, Minute, Colon, Second)
        end

	elseif (Format == "dd:hh") then
		local _Day = math.floor(InSeconds / 86400)
		local _Hour = math.floor((InSeconds % 86400) / 3600)
        if (bUseChinese) then
            return string.format(LSTR("%d天%02d时"), _Day, _Hour)
        else
            return string.format("%d%s%02d%s", _Day, Colon, _Hour, Colon)
        end
		
	elseif (Format == "dd:hh:mm") then
		local _Day = math.floor(InSeconds / 86400)
		local _Hour = math.floor((InSeconds % 86400) / 3600)
        local _Minute = math.floor((InSeconds % 3600) / 60)
        if (bUseChinese) then
            return string.format(LSTR("%d天%02d时%02d分"), _Day, _Hour, _Minute)
        else
            return string.format("%d%s%02d%s%02d", _Day, Colon, _Hour, Colon, _Minute)
        end

	elseif (Format == "smart-h:mm:ss") then
        if (bUseChinese) then
			if Hour == 0 then
				return string.format(LSTR("%02d分%02d秒"), Minute, Second)
			else
				return string.format(LSTR("%d时%02d分%02d秒"), Hour, Minute, Second)
			end
        else
			if Hour == 0 then
				return string.format("%02d%s%02d", Minute, Colon, Second)
			else
				return string.format("%d%s%02d%s%02d", Hour, Colon, Minute, Colon, Second)
			end
        end
	elseif (Format == "smart-ss") then
		if (bUseChinese) then
			return string.format(LSTR("%02d秒"), Second)
		else
			return string.format("%02d", Second)
		end
	elseif (Format == "smart-h-m-s") then
		if (bUseChinese) then
			local HourText = ""
			if Hour > 0 then
				HourText = string.format(LSTR("%d小时"), Hour)
			end

			local MinuteText = ""
			if Minute > 0 then
				MinuteText = string.format(LSTR("%d分"), Minute)
			end

			local SecondText = ""
			if Second > 0 then
				SecondText = string.format(LSTR("%d秒"), Second)
			end
			return string.format("%s%s%s", HourText, MinuteText, SecondText)
		else
			return string.format("%d%s%d%s%d", Hour, Colon, Minute, Colon, Second)
		end
	else
		return ""
	end
end

function DateTimeTools.GetOutputTime(Timestamp, Connector, StarIndex, NeedRemain)
	if NeedRemain==nil then NeedRemain=false end
    local os_date
    if Timestamp == -1 then
        os_date = os.date("*t")
    else

        os_date = os.date("*t",Timestamp)
    end

    local Arr = {}
    table.insert(Arr, os_date.year)
    table.insert(Arr, os_date.month)
    table.insert(Arr, os_date.day)
    table.insert(Arr, os_date.hour)
    table.insert(Arr, os_date.min)
    table.insert(Arr, os_date.sec)

    local TimeStr = ""
    for i = 1, #Arr do
		if NeedRemain or (not NeedRemain and i >= StarIndex) then
			TimeStr = TimeStr..DateTimeTools.AddZeroToString(Arr[i])
			if (i >= StarIndex) and (i < #Arr) then
				TimeStr = TimeStr..Connector
			end
		end
    end

    return TimeStr
end

function DateTimeTools.AddZeroToString(Num, AddZeroNum)
	if AddZeroNum==nil then AddZeroNum = 2 end
    local NumStr = tostring(Num)
    local ZeroNum = AddZeroNum - #NumStr

    if ZeroNum >= 0 then
        NumStr = string.rep("0", ZeroNum) .. NumStr
    end

    return NumStr
end

return DateTimeTools