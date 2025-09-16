--
-- Author: Carl
-- Date: 2023-10-08 16:57:14
-- Description:幻卡大赛报名信息VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local TimeUtil = _G.TimeUtil


---@class MagicCardTourneyInfoVM : UIViewModel
---@field TourneyFullName string @幻卡大赛全称(+奖杯名)
---@field AwardID number @奖品ID
---@field TourneyDate string @幻卡大赛持续时间文本
---@field TourneyEndTimeDate string @幻卡大赛结束时间
---@field CanSingUp boolean @是否可以大赛报名
---@field TourneyDes string @幻卡大赛说明
---@field SignUpTipText string @报名成功提示

local MagicCardTourneyInfoVM = LuaClass(UIViewModel)

function MagicCardTourneyInfoVM:Ctor()
    self.TourneyFullName = ""
    self.AwardIconPath = ""
    self.TourneyDate = ""
    self.TourneyEndTimeDate = ""
    self.CanSingUp = false
    self.TourneyID = 1
end

function MagicCardTourneyInfoVM:UpdateSignUpInfo(Data)
    if Data == nil then
        return
    end
    self.StartTime = Data.StartTime
    self.EndTime = Data.StartTime + TourneyDefine.Duration
    self.TourneyID = Data.TourneyID
    local TourneyData = TourneyVMUtils.GetTourneyDataByID(self.TourneyID)
    if TourneyData == nil then
        return 
    end
    self.TourneyName = (not string.isnilorempty(TourneyData.Title) and TourneyData.Title.."-"..TourneyData.CupName) or TourneyData.CupName
    self.TourneyDes = not string.isnilorempty(TourneyData.Desc) and TourneyData.Desc or TourneyDefine.AwardText
    self.RewardName = TourneyDefine.NumberOneAwardText
    
    if Data.StartTime then
        local TourneyStartTimeDate = TimeUtil.GetTimeFormat("%Y/%m/%d", self.StartTime)
        local LocalTourneyStartTimeDate = LocalizationUtil.GetTimeForFixedFormat(TourneyStartTimeDate, false)
        self.TourneyEndTimeDate = TimeUtil.GetTimeFormat("%Y/%m/%d", self.EndTime)
        local LocalTourneyEndTimeDate = LocalizationUtil.GetTimeForFixedFormat(self.TourneyEndTimeDate, true)
        self.TourneyDate = string.format(TourneyDefine.TourneyData, LocalTourneyStartTimeDate, LocalTourneyEndTimeDate)
    end
    
    self.CanSingUp = Data.CanSingUp
end

return MagicCardTourneyInfoVM