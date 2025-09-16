local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ProfessionLevelItemVM = require("Game/Profession/VM/ProfessionLevelItemVM")

---@class ProfessionRangeItemVM : UIViewModel
local ProfessionRangeItemVM = LuaClass(UIViewModel)

---Ctor
function ProfessionRangeItemVM:Ctor()
	self.IconPath = ""
	self.Title = ""
	self.BgPath = ""

	self.LevelItemVMList = nil
end

return ProfessionRangeItemVM