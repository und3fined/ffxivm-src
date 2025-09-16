local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

---@class EquipmentJobBtnItemVM : UIViewModel
local EquipmentJobBtnItemVM = LuaClass(UIViewModel)

local ActiveOpacity = 1.0
local InactiveOpacity = 0.4

function EquipmentJobBtnItemVM:Ctor()
    self.ProfID = ProtoCommon.prof_type.PROF_TYPE_NULL
    self.bSelect = false
    self.IconColor = "FFFFFFFF"
	self.bActive = true
	self.Opacity = ActiveOpacity
end

function EquipmentJobBtnItemVM:SetSelect(bSelect)
    self.bSelect = bSelect
    if self.bSelect == true then
        self.IconColor = "FFF5CEFF"
    else
        self.IconColor = "FFFFFFFF"
    end
end

function EquipmentJobBtnItemVM:AdapterOnGetCanBeSelected()
    if MajorUtil.GetMajorProfID() == self.ProfID then
        return true
    end

    if not _G.ProfMgr:CanChangeProf(self.ProfID, true) then
        return false
    end

    return true
end

function EquipmentJobBtnItemVM:SetActive(bActive)
	self.bActive = bActive
	self.Opacity = bActive and ActiveOpacity or InactiveOpacity
end

return EquipmentJobBtnItemVM