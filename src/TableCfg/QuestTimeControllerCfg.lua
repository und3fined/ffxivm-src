-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class QuestTimeControllerCfg : CfgBase
local QuestTimeControllerCfg = {
	TableName = "c_quest_time_controller_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(QuestTimeControllerCfg, { __index = CfgBase })

QuestTimeControllerCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function QuestTimeControllerCfg:GetCacheCfgByKey(ID)
    if not ID then
        return { StartTime=0, EndTime=0}
    end
    local TimeCacheMap = self.TimeCacheMap
    if not TimeCacheMap then
        TimeCacheMap = {}
        self.TimeCacheMap = TimeCacheMap
    end
    local TimeCache = TimeCacheMap[ID]
    if TimeCache then
        return TimeCache
    end
    local NewCache = { StartTime=0, EndTime=0}
    local Cfg = self:FindCfgByKey(ID)
    if not Cfg then
        return NewCache
    end
    NewCache.StartTime = self:GetTimeStamp(Cfg.StartTime)
    NewCache.EndTime = self:GetTimeStamp(Cfg.EndTime)
    TimeCacheMap[ID] = NewCache
    return NewCache
end

function QuestTimeControllerCfg:GetTimeStamp(Str)
    if string.isnilorempty(Str) then
        return 0
    end
    local year, month, day, hour, min, sec = Str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if not year then
        return 0
    end
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    hour = tonumber(hour)
    min = tonumber(min)
    sec = tonumber(sec)
    local time_table = {
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = min,
        sec = sec
    }
    return os.time(time_table) --本地时区
end

return QuestTimeControllerCfg
