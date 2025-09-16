local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class MusicPerformanceRewardSlotVM : UIViewModel
local MusicPerformanceRewardSlotVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceRewardSlotVM:Ctor()
	self.QuaImg = ""
	self.Icon = ""
	self.HasGot = false
	self.TextNum = ""
	self.ShowTipDaily = false
	self.ShowTipFirst = false
    self.ShowFunc = false
	self.IsShowTextNum = true
end

function MusicPerformanceRewardSlotVM:OnInit()
end

function MusicPerformanceRewardSlotVM:OnBegin()
end

function MusicPerformanceRewardSlotVM:OnEnd()
end

function MusicPerformanceRewardSlotVM:OnShutdown()
end

function MusicPerformanceRewardSlotVM:UpdateVM(Data)
	self.Data = Data
	self.ID = Data.ID
	self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Data.ID)) or ""

	self.QuaImg = ItemUtil.GetItemColorIcon(Data.ID) or "" --_G.BagMgr:GetItemIcon(Data.ID) or ""
	self.HasGot = Data.HasGot

	self.TextNum = tostring(Data.Count)
end

function MusicPerformanceRewardSlotVM:IsEqualVM(Data)
	return Data.ID == self.Data.ID
end

return MusicPerformanceRewardSlotVM