local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local PVPTimeStatisticsVM = require ("Game/PVP/VM/PVPTimeStatisticsVM")

local TimeType = ProtoCS.Game.PvPColosseum.PvpColosseumBtlResultClass

---@class PVPModeStatisticsVM : UIViewModel
local PVPModeStatisticsVM = LuaClass(UIViewModel)

function PVPModeStatisticsVM:Ctor(Mode)
    self.Mode = Mode
	self.BattleCount = 0
    self.TimeStatistic = {
        [TimeType.CurSeason] = PVPTimeStatisticsVM.New(TimeType.CurSeason),
        [TimeType.LastSeason] = PVPTimeStatisticsVM.New(TimeType.LastSeason),
        [TimeType.CurWeek] = PVPTimeStatisticsVM.New(TimeType.CurWeek),
    }
end

function PVPModeStatisticsVM:UpdateVM(Data)
    self.BattleCount = Data.BtlNum
    local AllTimeData = Data.AllBtlResult
    for _, Time in pairs(TimeType) do
        local Index = Time + 1
        local TimeData = AllTimeData[Index]
        local TimeVM = self:GetTimeStatistic(Time)
        if TimeVM then
            TimeVM:UpdateVM(TimeData)
        end
    end
end

function PVPModeStatisticsVM:GetTimeStatistic(Time)
    return self.TimeStatistic and self.TimeStatistic[Time] or nil
end

return PVPModeStatisticsVM