local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")

local TreasureHuntTransferLIstItemVM = LuaClass(UIViewModel)

function TreasureHuntTransferLIstItemVM:Ctor()
	self.TeamMemberName = ""
	self.TeamMemberRoleID = nil
	self.ProfID     = nil
    self.Level      = "" 
	self.ImgFocusVisible = true
	self.ProfInfoVM = SimpleProfInfoVM.New()
end

function TreasureHuntTransferLIstItemVM:UpdateVM(Value)
	if nil == Value then return end
	self.TeamMemberName = Value.TeamMemberName
	self.TeamMemberRoleID = Value.TeamMemberRoleID
	self.ProfID     = Value.Prof
	self.Level      = ""
	self.ProfInfoVM:UpdateVM(self)
end

function TreasureHuntTransferLIstItemVM:IsEqualVM(Value)
	return nil ~= Value and self.TeamMemberName == Value.TeamMemberName
end

return TreasureHuntTransferLIstItemVM