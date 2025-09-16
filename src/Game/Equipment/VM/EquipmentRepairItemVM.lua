local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")

local EndureState = EquipmentDefine.EndureState

---@class EquipmentRepairItemVM : UIViewModel
local EquipmentRepairItemVM = LuaClass(UIViewModel)

function EquipmentRepairItemVM:Ctor()
	self.SlotItemVM = nil
	self.EquipName = ""
	self.EndureDeg = 0 --百分数
	self.EndureDegProgress = 0
	self.Discount = 0 --百分数
	self.FormattedDiscount = ""
    self.Price = 0
	self.FormattedPrice = ""
	self.bCanRepair = false
	self.EndureState = EndureState.Normal
	self.Part = 0
	self.GID = 0
	self.bSelected = false
	self.bPlayAnimFix = false
	self.AnimFixLeastTime = 0
	self.ScoreType = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
end

function EquipmentRepairItemVM:SetEndureDeg(EndureDeg)
	self.EndureDeg = EndureDeg
	self.EndureDegProgress = EndureDeg / 100.0
	self.EndureState = EndureDeg == 100.0 and EndureState.Full or EndureState.Normal
	self:UpdateCanRepair()
end

function EquipmentRepairItemVM:SetPrice(Price)
	self.Price = math.ceil(Price)
	self.FormattedPrice = ScoreMgr.FormatScore(self.Price)
	self:UpdateCanRepair()
end

function EquipmentRepairItemVM:SetDiscount(Discount)
	self.Discount = Discount
	self.FormattedDiscount = Discount > 0 and string.format("-%d%%", Discount) or LSTR(1050085)
end

function EquipmentRepairItemVM:UpdateCanRepair()
	self.bCanRepair = self.Price <= ScoreMgr:GetScoreValueByID(self.ScoreType) and self.EndureDeg < 100
end

function EquipmentRepairItemVM:PlayFixAnim()
	self.bPlayAnimFix = true
	return 1.0 - self.EndureDegProgress + self.AnimFixLeastTime
end

return EquipmentRepairItemVM