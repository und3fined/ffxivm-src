local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local ProfUtil = require("Game/Profession/ProfUtil")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

local PWorldRewardVM = LuaClass(UIViewModel)

function PWorldRewardVM:Ctor()
    self.QuaImg = ""
	self.Icon = ""
	self.HasGot = false

	self.LackFunc = ""
	self.FuncImg = ""
	self.ShowFunc = ""

	self.ShowTipDaily = false
	self.ShowTipFirst = false

	self.Cnt = 0
end

function PWorldRewardVM:UpdateVM(Data)
	self.Data = Data
	self.ID = Data.ID
	self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Data.ID)) or ""

	self.QuaImg = ItemUtil.GetItemColorIcon(Data.ID) or "" --_G.BagMgr:GetItemIcon(Data.ID) or ""
	self.HasGot = Data.HasGot

	self.ShowFunc = Data.LackFunc ~= nil
	if self.ShowFunc then
		self.LackFunc = Data.LackFunc
		self.FuncImg = ProfUtil.LackProfFunc2Icon(Data.LackFunc)
	end

	self.ShowTipDaily = Data.ShowTipDaily
	self.ShowTipFirst = Data.ShowTipFirst
	self.bWeekly = Data.bWeekly
end

function PWorldRewardVM:IsEqualVM(Data)
	return Data.ID == self.Data.ID
end

function PWorldRewardVM:UpdMatch()
	local EntSet = SceneEnterTypeCfg:GetPWorldEntIDs(self.TypeID)
	local Matches = _G.PWorldMatchMgr:GetMatchItems()

	local HasOverlap = table.set_has_overlap(EntSet, Matches)
	self.IsMatching = HasOverlap
end

return PWorldRewardVM