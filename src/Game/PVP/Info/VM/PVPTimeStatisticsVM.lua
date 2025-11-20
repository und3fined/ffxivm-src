local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

---@class PVPTimeStatisticsVM : UIViewModel
local PVPTimeStatisticsVM = LuaClass(UIViewModel)

function PVPTimeStatisticsVM:Ctor(Time)
    self.Time = Time
	self.BattleCount = 0
	self.WinCount = 0
	self.FailCount = 0
	self.Kill = 0
	self.Death = 0
	self.Assist = 0
	self.Cure = 0
	self.Survival = 0
	self.Output = 0
	self.EscortTime = 0 -- 单位是ms
end

function PVPTimeStatisticsVM:UpdateVM(Param)
    self.BattleCount = Param.BtlNum
    self.WinCount = Param.WinNum
    self.FailCount = Param.FailNum
    self.Kill = Param.K
    self.Death = Param.D
    self.Assist = Param.A
    self.Cure = Param.Cure
    self.Survival = Param.Survival
    self.Output = Param.Output
    self.EscortTime = Param.EscortTime
end

return PVPTimeStatisticsVM