local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

---@class RechargingHelpVM : UIViewModel
local RechargingHelpVM = LuaClass(UIViewModel)

function RechargingHelpVM:Ctor()
	self.CurrentPage = 1
	self.MaxPage = 3
	self.IsConfirm = false
	self.IsLeft = false
	self.IsRight = false
end

function RechargingHelpVM:OnInit()
end

function RechargingHelpVM:OnBegin()
end

function RechargingHelpVM:OnEnd()
end

function RechargingHelpVM:OnShutdown()
end

function RechargingHelpVM:GoLeftPage()
	if self.CurrentPage > 1 then
		self:ChangePage(self.CurrentPage - 1)
	end
end

function RechargingHelpVM:GoRightPage()
	if self.CurrentPage < self.MaxPage then
		self:ChangePage(self.CurrentPage + 1)
	end
end

function RechargingHelpVM:ChangePage(NewPage)
	self.CurrentPage = NewPage
	self.IsLeft = self.CurrentPage ~= 1
	self.IsRight = self.CurrentPage ~= self.MaxPage
	self.IsConfirm = self.CurrentPage == self.MaxPage
end

return RechargingHelpVM