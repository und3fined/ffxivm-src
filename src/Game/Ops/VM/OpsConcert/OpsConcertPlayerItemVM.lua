local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
---@class OpsConcertPlayerItemVM : UIViewModel
local OpsConcertPlayerItemVM = LuaClass(UIViewModel)
---Ctor
function OpsConcertPlayerItemVM:Ctor()
    self.RoleID = nil
    self.ProfInfoVM = nil
    self.Level = nil
end

function OpsConcertPlayerItemVM:UpdateVM(Params)
    if Params == nil then
		return
	end
    self.RoleID = Params.RoleID
    self.ProfInfoVM = SimpleProfInfoVM.New()
    self.ProfID = Params.ProfID
    self.Level = Params.Level
    self.ProfInfoVM:UpdateVM(Params)
end

return OpsConcertPlayerItemVM