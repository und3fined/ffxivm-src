local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local RechargingGiftItemVM = require("Game/Recharging/VM/RechargingGiftItemVM")

---@class RechargingGiftVM : UIViewModel
local RechargingGiftVM = LuaClass(UIViewModel)

function RechargingGiftVM:Ctor()
	self.GiftItemVMList = UIBindableList.New(RechargingGiftItemVM)
	self.TextTitle = _G.LSTR(940011)
end

function RechargingGiftVM:OnInit()
end

function RechargingGiftVM:OnBegin()
end

function RechargingGiftVM:OnEnd()
end

function RechargingGiftVM:OnShutdown()
end

return RechargingGiftVM