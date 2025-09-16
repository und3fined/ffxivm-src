--
-- Author: Carl
-- Date: 2025-3-24 16:57:14
-- Description:高光表现文本列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")

---@class DepartHighLightItemVM : UIViewModel
local DepartHighLightItemVM = LuaClass(UIViewModel)

function DepartHighLightItemVM:Ctor()
    self.HightLightContent = "" -- 表现记录文本
end


function DepartHighLightItemVM:IsEqualVM(Value)
    return true
end

function DepartHighLightItemVM:UpdateVM(Value)
    local GameID = Value.GameID
    local Progress = Value.DayMaxProgress
    local Time = Value.DayMaxValueTime
    local TimeText = ""
    if Time and Time > 0 then
        TimeText = LocalizationUtil.LocalizeStringDate_Timestamp_YMD(Time) --时间本地化
    end
    local Content = DepartOfLightVMUtils.GetActivityHighLightDesc(GameID)
    if not string.isnilorempty(Content) then
        self.HightLightContent = string.format(Content, TimeText, Progress)
    end
end

return DepartHighLightItemVM