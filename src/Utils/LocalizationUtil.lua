--
-- Author: anypkvcai
-- Date: 2023-10-27 15:48
-- Description:
--

local CommonUtil = require("Utils/CommonUtil")
local CommonDefine = require("Define/CommonDefine")
local LocDBUtil = require("Utils/LocDBUtil")

local FLOG_WARNING = _G.FLOG_WARNING
local FDIR_EXISTFILE = _G.FDIR_EXISTFILE
local CultureName = CommonDefine.CultureName
local UCommonUtil = _G.UE.UCommonUtil

local LocresDir = _G.UE4.UKismetSystemLibrary.GetProjectDirectory() .. "Content/Localization/Game/"
local LocresFileName = "/Game.locres"

local LocresFiles = {
    [CultureName.Chinese] = LocresDir .. CultureName.Chinese .. LocresFileName,
    [CultureName.Japanese] = LocresDir .. CultureName.Japanese .. LocresFileName,
    [CultureName.English] = LocresDir .. CultureName.English .. LocresFileName,
    [CultureName.Korean] = LocresDir .. CultureName.Korean .. LocresFileName,
    [CultureName.French] = LocresDir .. CultureName.French .. LocresFileName,
}

local DefaultLocalizationNameSpace = "module"
local MapLocDBCfg = {
    ["c_balloon_cfg"]   = true,
    ["c_dialog_cfg"]    = true,
    ["c_quest_cfg"]     = true,
    ["c_scenario_text"] = true,
    ["c_sysnotice_cfg"] = true,
    ["c_yell_cfg"]      = true,
}

local CultureColumn = {
    [CultureName.Chinese]  = "zh",
    [CultureName.Japanese] = "ja",
    [CultureName.English]  = "en",
    [CultureName.Korean]   = "ko",
    [CultureName.French]   = "fr",
    [CultureName.German]   = "de",
}

local CultureTimeZone = {
    [CultureName.Chinese]  = 8,
    [CultureName.Japanese] = 9,
    [CultureName.English]  = 0,
    [CultureName.Korean]   = 9,
    [CultureName.French]   = 1,
    [CultureName.German]   = 1,
}

local PrefixForAozyTime = {
    [CultureName.Chinese]  = "艾",
    [CultureName.Japanese] = "ET",
    [CultureName.English]  = "ET",
    [CultureName.Korean]   = "ET",
    [CultureName.French]   = "HE",
    [CultureName.German]   = "EZ",
}

local PrefixForServeTime = {
    [CultureName.Chinese]  = "服",
    [CultureName.Japanese] = "ST",
    [CultureName.English]  = "ST",
    [CultureName.Korean]   = "ST",
    [CultureName.French]   = "HS",
    [CultureName.German]   = "SZ",
}
---本地化时间显示的时间单位
---@class LocalizationTimeUnit
local LocalizationTimeUnit = {
    ["Second"] = "s",
    ["Minute"] = "m",
    ["Hour"] = "h",
    ["Day"] = "d",
}

---@class LocalizationUtil
local LocalizationUtil = {
    LocalDateCfg = {},
    TimeZoneFMTs = {
        { Pattern = "（UTC%d+）", Repl = "（UTC%d）" },
        { Pattern = "%(UTC%d+%)", Repl = "(UTC%d)" },
    },
}

function LocalizationUtil.GetLocalDateCfg()
    local Ret = LocalizationUtil.LocalDateCfg or {}
    if #Ret > 0 then
        return Ret
    end

    local LocalizationDateTranslateCfg = require("TableCfg/LocalizationDateTranslateCfg")
    local CfgList = LocalizationDateTranslateCfg:FindAllCfg()

    for _, v in ipairs(CfgList) do
        local Pattern = v.Pattern
        if not string.isnilorempty(Pattern) then
            Pattern = string.gsub(Pattern, "-", "%%-")
            table.insert(Ret, {
                Pattern = Pattern,
                Chinese = v.Chinese,
                Japanese = v.Japanese,
                Korean = v.Korean,
                English = v.English,
                German = v.German,
                French = v.French
            })
        end
    end

    LocalizationUtil.LocalDateCfg = Ret

    return Ret
end

---本地化字符串中的日期（B本地化.xlsx-日期翻译）
---@param Str string @输入字符串
---return string
function LocalizationUtil.LocalizeStringDate(Str)
    local Ret = Str
    local LocalDateCfg = LocalizationUtil.GetLocalDateCfg()
    ---记录已经替换过的字符串，防止有子串替换父串
    local LocalizeStringList = {}
    for _, v in ipairs(LocalDateCfg) do
        local Pattern = string.gsub(v.Pattern, "(%%%d+)", "(%%d+)")

        local Repl = nil
        if CommonUtil.IsCurCultureChinese() then
            Repl = v.Chinese
        elseif CommonUtil.IsCurCultureJapanese() then
            Repl = v.Japanese
        elseif CommonUtil.IsCurCultureKorean() then
            Repl = v.Korean
        elseif CommonUtil.IsCurCultureEnglish() then
            Repl = v.English
        elseif CommonUtil.IsCurCultureGerman() then
            Repl = v.German
        elseif CommonUtil.IsCurCultureFrench() then
            Repl = v.French
        end

        if not string.isnilorempty(Repl) then
            local Start, End = string.find(Ret, Pattern)
            if Start and End then
                local March = string.sub(Ret, Start, End)
                local Placeholders = "{" .. tostring(v.Index) .. "}"
                LocalizeStringList[Placeholders] = string.gsub(March, Pattern, Repl)
                Ret = string.gsub(Ret, Pattern, Placeholders)
            end
        end
    end

    for k, v in pairs(LocalizeStringList) do
        Ret = string.gsub(Ret, k, v)
    end

    return Ret
end

---本地化字符串中的日期（B本地化.xlsx-日期翻译）
---@param Timestamp number @时间戳
---return string @ 中文格式(年-月-日 时:分:秒，比如“2022-02-11 15:39:16”)
function LocalizationUtil.LocalizeStringDate_Timestamp_YMDHMS(Timestamp)
    if nil == Timestamp or Timestamp < 0 then
        return
    end

    return LocalizationUtil.LocalizeStringDate(os.date("%Y-%m-%d %H:%M:%S", Timestamp))  
end

---本地化字符串中的日期（B本地化.xlsx-日期翻译）
---@param Timestamp number @时间戳
---return string @ 中文格式(年/月/日，比如“2022/02/11”)
function LocalizationUtil.LocalizeStringDate_Timestamp_YMD(Timestamp)
    if nil == Timestamp or Timestamp < 0 then
        return
    end

    return LocalizationUtil.LocalizeStringDate(os.date("%Y/%m/%d", Timestamp))  
end

---本地化字符串中的时区
---@param Str string @输入字符串
---return string
function LocalizationUtil.LocalizeTimeZone(Str)
    local Ret = Str
    local CurCultureName = CommonUtil.GetCurrentCultureName()
    local TimeZone = CultureTimeZone[CurCultureName]
    if nil == TimeZone then
        return Ret
    end

    for _, v in ipairs(LocalizationUtil.TimeZoneFMTs) do
        local Repl = string.format(v.Repl, TimeZone)
        Ret = string.gsub(Ret, v.Pattern, Repl)
    end

    return Ret
end

---本地化时间显示--固定格式显示，yyyy/mm/dd hh:mm 、 yyyy/mm/dd 、mm/dd hh:mm、 yyyy/mm/dd--yyyy/mm/dd、 无多语言适配
---@param Str string @输入的时间字符串
---@param bShowUTC boolean @是否显示UTC+8
---@return string @ 本地化后的时间
------适用场景: yyyy/mm/dd hh:mm 强调特殊日期节点(如:比赛时间)  yyyy/mm/dd 存在纪念的日期场景
function LocalizationUtil.GetTimeForFixedFormat(Str, bShowUTC)
    local Ret = LocalizationUtil.LocalizeStringDate(Str)
    if bShowUTC then
        Ret = Ret .. " （UTC+8）"
    end
    return Ret
end

---本地化时间显示---兼容UIAdapterCountDown旧版获取格式化时间的接口,若无必要请直接调用GetCountdownTimeXXX样式的函数
---@param RemainTime number @剩余时间:秒s
---@param Format string @格式 四种格式"mm:ss"、"hh:mm:ss"、"smart-t"、"smart-t-t",samra-t表示以天/小时/分钟/秒为单位的倒计时,"smart-t-t"表示长时间倒计时，精度随剩余时间变化。
---@param bUseChinese boolean@是否使用中文,兼容用参数,无用
---@param MinTimeUnit string @最小时间单位，"smart-t"格式需要提供的参数,"d"表示天，"h"表示小时，"m"表示分钟，"s"表示秒，默认为"s"
---return string @ 本地化后的时间
function LocalizationUtil.GetCountdownTime(RemainTime, Format, bUseChinese, MinTimeUnit)
    if Format == "smart-t-t" then
        return LocalizationUtil.GetCountdownTimeForLongTime(RemainTime)
    elseif Format == "smart-t" then
        return LocalizationUtil.GetCountdownTimeForSimpleTime(RemainTime, MinTimeUnit)
    elseif Format == "mm:ss" or Format == "hh:mm:ss" then
        return LocalizationUtil.GetCountdownTimeForShortTime(RemainTime, Format)
    ---兼容UIAdapterCountDown旧版获取格式化时间的接口
    elseif Format == "hh:mm" then
        return LocalizationUtil.GetCountdownTimeForShortTime(RemainTime, "hh:mm:ss")
    elseif Format == "dd:hh" or Format == "dd:hh:mm" then
        return LocalizationUtil.GetCountdownTimeForShortTime(RemainTime, Format)
    else
        return nil
    end
end

---本地化时间显示--长时间倒计时，精度随剩余时间变化
---@param  RemainTime number @剩余时间:秒s
----@return string @时间格式xx天xx小时:2天5小时、3小时3分钟、3分钟3秒、0分钟1秒
---适用场景:长时间的倒计时(如：活动、挑战任务等)
function LocalizationUtil.GetCountdownTimeForLongTime(RemainTime)
    if nil == RemainTime then
        return
    end
    if RemainTime < 0 then
        RemainTime = 0
    end
    local Day = math.floor(RemainTime / 86400)
    RemainTime = RemainTime - Day * 86400
    local Hour = math.floor(RemainTime / 3600)
    RemainTime = RemainTime - Hour * 3600
    local Minute = math.floor(RemainTime / 60)
    RemainTime = RemainTime - Minute * 60
    local Second = math.floor(RemainTime)
    if Day > 0 then
        return string.format(LSTR(1500001), Day, Hour) --- "%d天%d小时"
    elseif Hour > 0 or Minute >= 1 then
        return string.format(LSTR(1500002), Hour, Minute) --- "%d小时%d分钟"
    else
        return string.format(LSTR(1500003), Minute, Second) --- "%d分钟%d秒"
    end
end

---本地化时间显示--以天/小时/分钟/秒为单位的倒计时
---@param RemainTime number @剩余时间:秒s
---@param MinTimeUnit string @需要的最小时间的单位,传参"s","m","h","d"  单位:秒/分钟/小时/天
---return string @时间格式xx天/xx小时/xx分钟:2天、12小时、59分钟
---适用场景:仅需要写入单个时间的场景
function LocalizationUtil.GetCountdownTimeForSimpleTime(RemainTime, MinTimeUnit)
    if nil == RemainTime then
        return
    end
    if RemainTime < 0 then
        RemainTime = 0
    end
    ---默认精度为Day
    MinTimeUnit = MinTimeUnit or LocalizationTimeUnit.Day
    ---分别计算不同时间精度下的时间
    local TimeForSecounds = RemainTime
    local TimeForMinutes = math.floor(TimeForSecounds / 60)
    TimeForSecounds = math.floor(TimeForSecounds - TimeForMinutes * 60)
    local TimeForHours = math.floor(TimeForMinutes / 60)
    TimeForMinutes = TimeForMinutes - TimeForHours * 60
    local TimeForDays = math.floor(TimeForHours / 24)
    TimeForHours = TimeForHours - TimeForDays * 24
    ---根据最大显示精度确定结果
    if TimeForDays > 0 or MinTimeUnit == LocalizationTimeUnit.Day then
        return string.format(LSTR(1500004), TimeForDays)  --- "%d天"
    elseif TimeForHours > 0 or MinTimeUnit == LocalizationTimeUnit.Hour then
        return string.format(LSTR(1500005), TimeForHours) --- "%d小时"
    elseif TimeForMinutes > 0 or MinTimeUnit == LocalizationTimeUnit.Minute then
        return string.format(LSTR(1500006), TimeForMinutes) --- "%d分钟"
    else
        return string.format(LSTR(1500007), TimeForSecounds) --- "%d秒"
    end
end

---本地化时间显示--倒计时，mm:ss / hh:mm:ss ,无多语言适配
---@param RemainTime number @剩余时间:秒s
---@param Format string @格式 两种格式"mm:ss"、"hh:mm:ss",默认为"mm:ss"
----@return string @时间格式xx分钟xx秒:61:54、01:54
------适用场景: mm:ss适用于短时间倒计时，需要玩家快速处理 hh:mm:ss玩家主动制作行为，需要玩家感受时间的流逝
function LocalizationUtil.GetCountdownTimeForShortTime(RemainTime, Format)
    if nil == RemainTime then
        return
    end
    if RemainTime < 0 then
        RemainTime = 0
    end
    ---这里将时分秒表述为字符串形式，方便后续统一操作
    local Hour = ""
    local Minute = ""
    local Second = ""
    if nil ~= Format and Format == "hh:mm:ss" then
        local HourTime = math.floor(RemainTime / 3600)
        Hour = string.format("%02d:", HourTime)
        RemainTime = RemainTime - HourTime * 3600
        local MinuteTime = math.floor(RemainTime / 60)
        Minute = string.format("%02d", MinuteTime)
        RemainTime = RemainTime - MinuteTime * 60
        Second = string.format("%02d", RemainTime)
    elseif Format == "mm:ss" then
        local MinuteTime = math.floor(RemainTime / 60)
        Minute = string.format("%02d", MinuteTime)
        RemainTime = RemainTime - MinuteTime * 60
        Second = string.format("%02d", RemainTime)
    end
    return string.format("%s%s:%s", Hour, Minute, Second)
end

---本地化时间显示--高精度计时器时间显示，mm:ss 无多语言适配
---@param Time number @输入的时间,用时秒s
------适用场景: 匹配场景，局内比赛时间
function LocalizationUtil.GetTimerForHighPrecision(Time)
    if nil == Time then
        return
    end
    if Time < 0 then
        Time = 0
    end
    local TimeForSecounds = math.floor(Time)
    local TimeForMinutes = math.floor(TimeForSecounds / 60)
    TimeForSecounds = TimeForSecounds - TimeForMinutes * 60
    return string.format("%02d:%02d", TimeForMinutes, TimeForSecounds)
end

---本地化时间显示--低精度计时器时间显示，x分钟/小时/天前
---@param Time number @输入的时间,用时秒s
---@param MaxTimeForDays number @最大显示时间，例如输入30，超过30天则显示30天以上
------适用场景: 离线计时
function LocalizationUtil.GetTimerForLowPrecision(Time, MaxTimeForDays)
    if nil == Time then
        return
    end
    if Time < 0 then
        Time = 0
    end
    MaxTimeForDays = MaxTimeForDays or 30
    local TimeForSecounds = math.floor(Time)
    local TimeForMinutes = math.floor(TimeForSecounds / 60)
    TimeForSecounds = TimeForSecounds - TimeForMinutes * 60
    local TimeForHours = math.floor(TimeForMinutes / 60)
    TimeForMinutes = TimeForMinutes - TimeForHours * 60
    local TimeForDays = math.floor(TimeForHours / 24)
    TimeForHours = TimeForHours - TimeForDays * 24
    if TimeForDays > 0 and TimeForDays > MaxTimeForDays then
        return string.format(LSTR(1500008), 30) --- %天以上
    elseif TimeForDays > 0 then
        return string.format(LSTR(1500009), TimeForDays) --- %天前
    elseif TimeForHours > 0 then
        return string.format(LSTR(1500010), TimeForHours) --- %小时前
    else
        return string.format(LSTR(1500011), TimeForMinutes) --- %分钟前
    end
end

-- ---本地化时间显示--时间跨度显示(跨天)
-- ---@param Str string @输入的时间字符串
-- ---@param bShowUTC boolean @是否显示UTC+8
-- ------适用场景: 活动、赛季时间的时间跨度
-- ---@return string
-- function LocalizationUtil.GetTimeRange(Str, bShowUTC)
--     local Ret = LocalizationUtil.LocalizeStringDate(Str)
--     if bShowUTC then
--         Ret = Ret .. " (UTC+8)"
--     end
--     return Ret
-- end

----本地化时间显示--时间跨度显示(当天)
---------适用场景: 当天的时间跨度的前缀
---@return string
-- function LocalizationUtil.GetTimeTypeForAozy(Str)
--     local Ret = Str
--     return Ret
-- end


----本地化图片路径转换
---------适用场景: 将输入的图片Path转换为本地语言的路径的图片
---@param InPath string
---@return string
function LocalizationUtil.GetLocalizedAssetPath(InPath)
    -- 语言列
    --local Name = CommonUtil.GetCurrentCultureName()
    --local LocalColumnName = CommonDefine.CultureName[Name]
    local LocalColumnName = CommonUtil.GetCurrentCultureName()
    if nil == LocalColumnName then
        return InPath
    end
    if "zh" == LocalColumnName then 
        LocalColumnName = "chs"
    end
    local Ret = string.gsub(InPath, "\\","/")
    local ReplaceString = "/"..LocalColumnName.."/"
    if string.find(Ret,"/chs/") then
        Ret = string.gsub(Ret, "/chs/",ReplaceString)
    elseif string.find(Ret,"/CHS/") then
        Ret = string.gsub(Ret, "/CHS/",ReplaceString)
    elseif string.find(Ret,"/ja/") then
        Ret = string.gsub(Ret, "/ja/",ReplaceString)
    elseif string.find(Ret,"/JA/") then
        Ret = string.gsub(Ret, "/JA/",ReplaceString)
    elseif string.find(Ret,"/en/") then
        Ret = string.gsub(Ret, "/en/",ReplaceString)
    elseif string.find(Ret,"/EN/") then
        Ret = string.gsub(Ret, "/EN/",ReplaceString)
    elseif string.find(Ret,"/ko/") then
        Ret = string.gsub(Ret, "/ko/",ReplaceString)
    elseif string.find(Ret,"/KO/") then
        Ret = string.gsub(Ret, "/KO/",ReplaceString)
    elseif string.find(Ret,"/fr/") then
        Ret = string.gsub(Ret, "/fr/",ReplaceString)
    elseif string.find(Ret,"/FR/") then
        Ret = string.gsub(Ret, "/FR/",ReplaceString)
    elseif string.find(Ret,"/de/") then
        Ret = string.gsub(Ret, "/de/",ReplaceString)
    elseif string.find(Ret,"/DE/") then
        Ret = string.gsub(Ret, "/DE/",ReplaceString)
    end
    return Ret
end

---获取本地"多语言本地化资源"列表
function LocalizationUtil.GetLocalLocresList()
    local Ret = {}

    for k, v in pairs(LocresFiles) do
        if FDIR_EXISTFILE(v) then
            table.insert(Ret, k)
        end
    end

    return Ret
end

---GetLocalString
---@param Str string
---@param NameSpace string @命名空间
---@param IsFromExcel boolean @是否来源于表格数据
---@return string
function LocalizationUtil.GetLocalString(Str, Key, NameSpace, IsFromExcel)
	if type(Str) == "number" then
		Str = tostring(Str)
	end

	if string.isnilorempty(Str) then
		return Str
	end

	Key = Key or Str
	NameSpace = NameSpace or DefaultLocalizationNameSpace

    local LocalStr = nil
    if IsFromExcel and MapLocDBCfg[NameSpace] then
        -- 语言列
        local Name = CommonUtil.GetCurrentCultureName()
        local ColumnName = CultureColumn[Name]
        if nil == ColumnName then
            FLOG_WARNING("LocalizationUtil.GetLocalString, Culture(%s) does not define a Column", tostring(Name))
            return Str
        end

        LocalStr = LocDBUtil.FindValue(NameSpace, Str, ColumnName)
    else
        LocalStr = UCommonUtil.GetLocalString(Str, Key, NameSpace)
    end

    if not string.isnilorempty(LocalStr) then
        -- 有单复数形式的翻译，只返回单数
        local FlagPos = string.find(LocalStr, '|')
        if FlagPos then
            local Single = string.sub(LocalStr, 1, FlagPos - 1)
            return Single
        end
    end

	if not IsFromExcel and string.isnilorempty(LocalStr) then
		return Str
	end

	return LocalStr
end

---SplitStringPlural
---@param Str string
---@return string, string @单数字符串，复数字符串
function LocalizationUtil.SplitStringPlural(Str)
	local Ret_1 = Str
	local Ret_2 = nil

	local FlagPos = string.find(Str, "|")
	if FlagPos then
		Ret_1 = string.sub(Str, 1, FlagPos - 1)
		Ret_2 = string.sub(Str, FlagPos + 1)
	end

	return Ret_1, Ret_2
end

-- LSTR用法和UE4的LOCTEXT_NAMESPACE类似，有两个作用：一个是多语言构建时扫描LSTR参数里的常量，提取到翻译表里，另一个作用是运行时获取翻译后的多语言字符串
-- 需要翻译的字符串要通过LSTR函数获取，表格里读取的字符已经改成ukey了，不需要通过LSTR获取
-- 但日志、玩家自定义的名称（玩家名、部队名、聊天内容）、资源路径等不需要翻译的，不要用LSTR
-- 示例：
--  LSTR("中文字符串") 代码中的汉字（通过扫描代码提取到翻译表，匹配'LSTR\s*\(\s*\"([\w\W]*?)\"\s*\)'）
--  LSTR(Cfg.Name) 表格中的汉字（通过表格提取到翻译表）
-- string.format(LSTR("剩余%d天")，Num)  前后有关联的句子要放到一个字符串里，以免翻译的时候前后不连贯

-- 错误示例：
-- LSTR("AnimationName") 动画名不用翻译
-- LSTR("PlayerName") 玩家名不用翻译
-- FLOG(LSTR("日志")) 日志不用翻译
-- LSTR("中文1" + “中文2”) 只能有一个常量
-- LSTR("剩余") + Day + LSTR("天”） 要用LSTR("剩余%d天")保证翻译结果的正确性
-- LSTR("%d/%d") 没有中文不用翻译
-- LSTR(Cfg.Name) 新需求改用ukey了, 为了使用方便，对ukey无感知，如果是表需要本地化的字符，不再需要用LSTR

_G.LSTR = LocalizationUtil.GetLocalString

return LocalizationUtil
