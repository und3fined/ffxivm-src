local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class BuddySkillTypeItemVM : UIViewModel
local BuddySkillTypeItemVM = LuaClass(UIViewModel)

---Ctor
function BuddySkillTypeItemVM:Ctor()
    self.TagText = nil
    self.IconPath = nil
end

function BuddySkillTypeItemVM:UpdateVM(Value)
	self.TagText = Value.TagText
	self.IconPath = Value.IconPath
end

function BuddySkillTypeItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.TagText == self.TagText and  Value.IconPath == self.IconPath
end




--要返回当前类
return BuddySkillTypeItemVM