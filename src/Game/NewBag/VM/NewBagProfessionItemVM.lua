local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

---@class NewBagProfessionItemVM.lua : UIViewModel
local NewBagProfessionItemVM = LuaClass(UIViewModel)

local ActiveOpacity = 1.0
local InactiveOpacity = 0.4
---Ctor
function NewBagProfessionItemVM:Ctor()
    self.ProfID = nil
    self.bSelect = nil
    self.IconColor = "FFFFFFFF"
	self.bActive = nil
	self.Opacity = ActiveOpacity
    self.Value = nil

    self.DrugIcon = nil
	self.SetVisible = nil
	self.NotSetVisible = nil
	self.NotDrugVisible = nil
end

function NewBagProfessionItemVM:SetSelect(bSelect)
    self.bSelect = bSelect
    if self.bSelect == true then
        self.IconColor = "FFF5CEFF"
    else
        self.IconColor = "FFFFFFFF"
    end
end

function NewBagProfessionItemVM:UpdateVM(Value)
    self.Value = Value
    self.ProfID = Value.Prof
    self:SetActive(Value.bActive)
    self:SetDrugInfo()
end

function NewBagProfessionItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Prof == self.ProfID
end

function NewBagProfessionItemVM:SetActive(bActive)
	self.bActive = bActive
	self.Opacity = bActive and ActiveOpacity or InactiveOpacity
end

function NewBagProfessionItemVM:SetDrugInfo()
    if self.ProfID == nil then
        return
    end
    local MedicineID = _G.BagMgr.ProfMedicineTable[self.ProfID]
	if _G.BagMgr:IsMedicineItem(MedicineID) ==false then
        self.SetVisible = false
        self.NotSetVisible = true
        self.NotDrugVisible = false
    else
        self.SetVisible = true
        self.NotSetVisible = false
        self.NotDrugVisible = _G.BagMgr:GetItemNum(MedicineID) == 0
        self.DrugIcon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(MedicineID)) 
	end

end

--要返回当前类
return NewBagProfessionItemVM