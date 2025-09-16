local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class PerformanceInstrumentItemVM : UIViewModel
local PerformanceInstrumentItemVM = LuaClass(UIViewModel)

---Ctor
function PerformanceInstrumentItemVM:Ctor()
	self.InstrumentData = nil
	self.Name = ""
	self.TypeName = ""
	self.SelectedVisible = false
	self.AnimChencked = false
	self.FavorVisible = false
	self.BigIconPath = ""
	self.SmallIconPath = ""
	self.BaseIconPath = ""
end

function PerformanceInstrumentItemVM:SetData(InstrumentData)
	self.InstrumentData = InstrumentData
	if InstrumentData then
		self.Name = InstrumentData.Name
		self.TypeName = MusicPerformanceUtil.GetInstrumentTypeName(InstrumentData.Type)
		self.BigIconPath = InstrumentData.BigIcon
		self.SmallIconPath = InstrumentData.SmallIcon
		self.BaseIconPath = InstrumentData.BaseIcon
	end
end

function PerformanceInstrumentItemVM:OnInit()
end

function PerformanceInstrumentItemVM:OnBegin()
end

function PerformanceInstrumentItemVM:OnEnd()
end

function PerformanceInstrumentItemVM:OnShutdown()
end

return PerformanceInstrumentItemVM