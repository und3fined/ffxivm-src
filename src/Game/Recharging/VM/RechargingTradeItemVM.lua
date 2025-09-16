local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ScoreMgr = require("Game/Score/ScoreMgr")
local RechargingUtil = require("Game/Recharging/RechargingUtil")

local LSTR = _G.LSTR

---@class RechargingTradeItemVM : UIViewModel
local RechargingTradeItemVM = LuaClass(UIViewModel)

function RechargingTradeItemVM:Ctor()
    self.Order = 1
	self.Icon = ""
	self.Crystas = 0
	self.Bonus = 0
	self.CrystasFormatted = ""
	self.BonusFormatted = ""
	self.PhysicalCurrency = 0
	self.BonusRate = 0
	self.DoDisplayBonusRate = false
	self.BonusTips = LSTR(940019)
end

function RechargingTradeItemVM:OnInit()
end

function RechargingTradeItemVM:OnBegin()
end

function RechargingTradeItemVM:OnEnd()
end

function RechargingTradeItemVM:OnShutdown()
end

function RechargingTradeItemVM:UpdateVM(Value)
	self.Order = Value.Order
	self.Icon = Value.Icon
	self.Crystas = Value.Crystas
	self.Bonus = Value.Bonus
	self.CrystasFormatted = ScoreMgr.FormatScore(Value.Crystas)
	self.BonusFormatted = ScoreMgr.FormatScore(Value.Bonus)
	self.ProductID = Value.ProductID
	self.PhysicalCurrency = RechargingUtil.Crystas2PhysicalCurrency(Value.Crystas)
	self.BonusRate = math.floor(Value.Bonus / Value.Crystas * 100 + 0.5)
	self.DoDisplayBonusRate = Value.DoDisplayBonusRate
end

return RechargingTradeItemVM