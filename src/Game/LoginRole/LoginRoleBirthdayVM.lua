local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

local ProfUtil = require("Game/Profession/ProfUtil")
local CalendarCfg = require("TableCfg/CalendarCfg")

---@class LoginRoleBirthdayVM : UIViewModel
local LoginRoleBirthdayVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR

function LoginRoleBirthdayVM:Ctor()
    self.TextMonthStr = ""--星1月
    self.TextDateStr = ""--星1月1日
    self.TextActualDateStr = ""--（1月1日）
    self.DateList = {}
    -- self.MonthList2 = {"星一月", "灵一月", "星二月", "灵二月", "星三月", "灵三月",
    --                     "星四月", "灵四月", "星五月", "灵五月", "星六月", "灵六月"}

    self.MonthList = {LSTR(980103), LSTR(980104), LSTR(980105), LSTR(980106), LSTR(980107), LSTR(980108),
                    LSTR(980109), LSTR(980110), LSTR(980111), LSTR(980112), LSTR(980113), LSTR(980114)}
    -- self.MonthList = {"星1月", "灵1月", "星2月", "灵2月", "星3月", "灵3月",
    --                     "星4月", "灵4月", "星5月", "灵5月", "星6月", "灵6月"}
    --该阶段的数据
    self.SelectMonthIndex = 1
    self.SelectDayIndex = 1
    --该阶段的数据
end

function LoginRoleBirthdayVM:OnInit()
    self.DateList = {}
    for index = 1, 32 do
        table.insert(self.DateList, tostring(index))
    end
end

function LoginRoleBirthdayVM:InitCalendarList()
    if self.Calendar then
        return
    end

    local CalendarList = CalendarCfg:FindAllCfg()
    if CalendarList then
        self.Calendar = {}

        local DayListByMonth = {}
        for index = 1, #CalendarList do
            local Cfg = CalendarList[index]
            DayListByMonth[Cfg.Month] = DayListByMonth[Cfg.Month] or {}
            table.insert(DayListByMonth[Cfg.Month], Cfg)
        end

        for Month, CfgList in ipairs(DayListByMonth) do
            self.Calendar[Month] = self.Calendar[Month] or {}
            -- FLOG_INFO("=================== Month：%d", Month)

            for index = 1, #CfgList do
                local Cfg = CfgList[index]
                local NextDay = 32
                if index < #CfgList then
                    NextDay = CfgList[index + 1].Day - 1
                end

                local RealDay = Cfg.RealDay
                for Day = Cfg.Day, NextDay do
                    self.Calendar[Cfg.Month][Day] = RealDay
                    -- FLOG_INFO("Day -> Real : %d, %d", Day, RealDay)
                    RealDay = RealDay + 1
                end
            end
        end
    end
end

function LoginRoleBirthdayVM:OnBegin()
end

function LoginRoleBirthdayVM:OnEnd()
end

function LoginRoleBirthdayVM:OnShutdown()
end

function LoginRoleBirthdayVM:DiscardData()
    FLOG_INFO("LoginRoleBirthdayVM:DiscardData")
    self.SelectMonthIndex = 1
    self.SelectDayIndex = 1
end

function LoginRoleBirthdayVM:Restore()
	local SaveData = _G.LoginUIMgr.LoginReConnectMgr.SaveData
    self:SelectMonth(SaveData.MonthIndex)
    self:SelectDate(SaveData.DayIndex)
end

function LoginRoleBirthdayVM:SelectMonth(MonthIndex)
    FLOG_INFO("LoginRoleBirthdayVM:SelectMonth %d", MonthIndex)
    self.SelectMonthIndex = MonthIndex
    self:UpdateUI()
    
    _G.LoginUIMgr.LoginReConnectMgr:SaveValue("MonthIndex", MonthIndex)
end

function LoginRoleBirthdayVM:SelectDate(DateIndex)
    FLOG_INFO("LoginRoleBirthdayVM:SelectDate %d", DateIndex)
    self.SelectDayIndex = DateIndex
    self:UpdateUI()
    
    _G.LoginUIMgr.LoginReConnectMgr:SaveValue("DayIndex", DateIndex)
end

function LoginRoleBirthdayVM:UpdateUI()
    local MonthIdx = self.SelectMonthIndex
    self.TextMonthStr = self.MonthList[MonthIdx]   --原来是中文的一二三
    self.TextDateStr = string.format(LSTR(980064), self.MonthList[MonthIdx], self.SelectDayIndex)    --%s%d日
    local RealDay = self:GetRealDay(MonthIdx, self.SelectDayIndex)
    self.TextActualDateStr = string.format(LSTR(980065), MonthIdx, RealDay)--（%d月%d日）
end

function LoginRoleBirthdayVM:GetRealDay(Month, Day)
    if not self.Calendar then
        self:InitCalendarList()
    end

    local RealDay = self.Calendar[Month][Day]
    if RealDay then
        return RealDay
    end

    return Day
end

function LoginRoleBirthdayVM:GetBirthdayStr(Month, Day)
    return string.format(LSTR(980064), self.MonthList[Month], Day)
end

function LoginRoleBirthdayVM:GetRealBirthdayStr(Month, Day)
    local RealDay = self:GetRealDay(Month, Day)
    return string.format(LSTR(980066), Month, RealDay)--("%d月%d日")
end

return LoginRoleBirthdayVM