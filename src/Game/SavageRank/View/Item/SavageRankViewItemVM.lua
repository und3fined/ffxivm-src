local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SavageRankViewItemVM : UIViewModel
local SavageRankViewItemVM = LuaClass(UIViewModel)

---Ctor
function SavageRankViewItemVM:Ctor()
	self.Name = ""
	self.OpenText = ""
	self.SelectVisible = false
	self.PanelOpeningVisible = false
	self.IsOpen = nil
	self.IsEnd = nil
	self.TabIcon = nil
end

function SavageRankViewItemVM:OnInit()

end
 
---UpdateVM
---@param List table
function SavageRankViewItemVM:UpdateVM(List)
	self.ID = List.ID
	self.Name = List.Name
	self.PanelOpeningVisible = List.IsOpen
	self.IsOpen = List.IsOpen
	self.IsEnd = List.IsEnd
	self.OpenText = _G.LSTR(1450021) --开启中
	self.TabIcon = List.BackgroudImageIcon
end

function SavageRankViewItemVM:SetTabText()

end

function SavageRankViewItemVM:UpdateSelectState(Value)
	self.SelectVisible = Value
end

function SavageRankViewItemVM:IsEqualVM(Value)
end

return SavageRankViewItemVM