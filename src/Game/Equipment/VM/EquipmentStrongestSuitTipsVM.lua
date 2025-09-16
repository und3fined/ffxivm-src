local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class EquipmentStrongestSuitTipsVM : UIViewModel
local EquipmentStrongestSuitTipsVM = LuaClass(UIViewModel)

function EquipmentStrongestSuitTipsVM:Ctor()
    self.CurrentScore = 0
    self.StrongestScore = 0
    self.AddScore = 0
    self.bHasChange = false
	self.CurrentPage = 1
	self.OpacityPage1 = 1
	self.OpacityPage2 = 0.5
end

function EquipmentStrongestSuitTipsVM:SwitchPage()
	self:ChangePage(self.CurrentPage % 2 + 1)
end

function EquipmentStrongestSuitTipsVM:ChangePage(Page)
	if Page == 0 or Page > 2 then
		return
	end
	self.CurrentPage = Page
	self.OpacityPage1 = 1 / self.CurrentPage
	self.OpacityPage2 = 0.5 * self.CurrentPage
end

return EquipmentStrongestSuitTipsVM