local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local PVPModeStatisticsVM = require ("Game/PVP/VM/PVPModeStatisticsVM")

local GameMode = ProtoCS.Game.PvPColosseum.PvPColosseumMode

---@class PVPTypeStatisticsVM : UIViewModel
local PVPTypeStatisticsVM = LuaClass(UIViewModel)

function PVPTypeStatisticsVM:Ctor(GameType)
    self.GameType = GameType
	self.ModeStatistic = {
        [GameMode.Exercise] = PVPModeStatisticsVM.New(GameMode.Exercise),
        [GameMode.Rank] = PVPModeStatisticsVM.New(GameMode.Rank),
        [GameMode.Custom] = PVPModeStatisticsVM.New(GameMode.Custom),
    }
end

function PVPTypeStatisticsVM:UpdateVM(Data)
    local AllModeData = Data.AllModeResult
    for _, Mode in pairs(GameMode) do
        local Index = Mode + 1
        local ModeData = AllModeData[Index]
        local ModeVM = self:GetModeStatistic(Mode)
        if ModeVM then
            ModeVM:UpdateVM(ModeData)
        end
    end
    
end

function PVPTypeStatisticsVM:GetModeStatistic(Mode)
    return self.ModeStatistic and self.ModeStatistic[Mode] or nil
end

return PVPTypeStatisticsVM