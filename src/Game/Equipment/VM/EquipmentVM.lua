local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class EquipmentVM : UIViewModel
local EquipmentVM = LuaClass(UIViewModel)

function EquipmentVM:Ctor()
    self.ItemList = nil --当前装备ItemList
    self.OnList = nil
    self.OffList = nil
    self.lstProfDetail = nil
	self.bShowProfDetail = false
    self.UnSteadyMap = nil  --动态属性部分
end

function EquipmentVM:OnInit()
    
end

function EquipmentVM:OnBegin()
    
end

function EquipmentVM:OnEnd()
    
end

function EquipmentVM:OnShutdown()
    
end

return EquipmentVM